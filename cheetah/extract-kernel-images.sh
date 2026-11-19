#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2026 The ExpressiveOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Generate vendor/google/cheetah-kernel-images from a Pixel 7 Pro (cheetah)
# factory image or inner image-cheetah-*.zip:
#   - images/{boot,dtbo,system_dlkm,vendor_dlkm}.img (stock prebuilts)
#   - radio/vendor_kernel_boot.img (stock vendor_kernel_boot repacked non-root
#     with focal_touch.ko + syna_touch.ko from stock vendor_dlkm.img so touch
#     works in AOSP Recovery while remaining blocklisted during first-stage
#     normal boot)
#   - Android.mk (add-radio-file-sha1-checked for radio/vendor_kernel_boot.img)
#
# Usage:
#   extract-kernel-images.sh [--out <output-dir>] <cheetah-*-factory-*.zip | image-cheetah-*.zip>
#
set -euo pipefail

MY_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TOP="$(cd "$MY_DIR/../../../.." && pwd -P)"
OUT="$TOP/vendor/google/cheetah-kernel-images"

if [[ "${1:-}" == "--out" ]]; then
    OUT="$(realpath -m "$2")"
    shift 2
fi

[[ $# -eq 1 ]] || { echo "usage: $0 [--out <dir>] <factory.zip | image-cheetah-*.zip>" >&2; exit 1; }
zip="$(realpath "$1")"

UNPACK_BOOTIMG="${EOS_UNPACK_BOOTIMG:-$TOP/system/tools/mkbootimg/unpack_bootimg.py}"
MKBOOTIMG="${EOS_MKBOOTIMG:-$TOP/system/tools/mkbootimg/mkbootimg.py}"
AVBTOOL="${EOS_AVBTOOL:-$TOP/out/host/linux-x86/bin/avbtool}"
[[ -x "$AVBTOOL" ]] || AVBTOOL="$TOP/external/avb/avbtool.py"

if [[ -n "${TMPDIR:-}" && "${TMPDIR}" != "/tmp" && -d "${TMPDIR}" && -w "${TMPDIR}" ]]; then
    work_dir="$TMPDIR"
elif [[ -d "$TOP/out" && -w "$TOP/out" ]]; then
    work_dir="$TOP/out"
else
    work_dir="/tmp"
fi
work="$(mktemp -d -p "$work_dir" .extract-cheetah-kimg.XXXXXX)"
trap 'rm -rf "$work"' EXIT

if unzip -Z1 "$zip" | grep -qE '(^|/)image-cheetah-.*\.zip$'; then
    inner="$(unzip -Z1 "$zip" | grep -E '(^|/)image-cheetah-.*\.zip$')"
    unzip -q -j "$zip" "$inner" -d "$work"
    image_zip="$work/$(basename "$inner")"
else
    image_zip="$zip"
fi

grep -q '^require board=.*cheetah' <(unzip -p "$image_zip" android-info.txt) ||
    { echo "not a cheetah image: $zip" >&2; exit 1; }
build_id="$(basename "$image_zip" .zip | sed 's/^image-cheetah-//')"

mkdir -p "$OUT"
find "$OUT" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
mkdir -p "$OUT/images" "$OUT/radio"

for img in boot dtbo system_dlkm vendor_dlkm; do
    unzip -q -p "$image_zip" "$img.img" > "$OUT/images/$img.img"
    [[ -s "$OUT/images/$img.img" ]] || { echo "missing $img.img" >&2; exit 1; }
done

unzip -q -p "$image_zip" vendor_kernel_boot.img > "$work/vendor_kernel_boot.src.img"
[[ -s "$work/vendor_kernel_boot.src.img" ]] || { echo "missing vendor_kernel_boot.img" >&2; exit 1; }

# Unpack stock vendor_kernel_boot.img and its LZ4 vendor_ramdisk00 as non-root
python3 "$UNPACK_BOOTIMG" --boot_img "$work/vendor_kernel_boot.src.img" --out "$work/vkb" --format=mkbootimg > "$work/mkbootimg.args"
mkdir -p "$work/ramdisk"
lz4 -dc "$work/vkb/vendor_ramdisk00" | (cd "$work/ramdisk" && cpio -id --quiet)

# Extract panel touch modules + dep/alias metadata from stock vendor_dlkm.img (non-root debugfs)
TOUCH_MODULES=(focal_touch.ko syna_touch.ko)
for mod in "${TOUCH_MODULES[@]}"; do
    rm -f "$work/ramdisk/lib/modules/$mod"
    debugfs -R "dump /lib/modules/$mod $work/ramdisk/lib/modules/$mod" "$OUT/images/vendor_dlkm.img" >/dev/null 2>&1
    [[ -s "$work/ramdisk/lib/modules/$mod" ]] || { echo "failed to extract $mod from vendor_dlkm.img" >&2; exit 1; }
    chmod 0644 "$work/ramdisk/lib/modules/$mod"
done
debugfs -R "dump /lib/modules/modules.dep $work/vdlkm.modules.dep" "$OUT/images/vendor_dlkm.img" >/dev/null 2>&1
debugfs -R "dump /lib/modules/modules.alias $work/vdlkm.modules.alias" "$OUT/images/vendor_dlkm.img" >/dev/null 2>&1

# Update modules.load, modules.load.recovery, modules.blocklist, modules.dep, modules.alias inside ramdisk
python3 - "$work" "${TOUCH_MODULES[@]}" << "PY"
import sys, os, re
work = sys.argv[1]
mods = sys.argv[2:]
mroot = os.path.join(work, "ramdisk", "lib", "modules")

# 1. modules.load & modules.load.recovery
load_path = os.path.join(mroot, "modules.load")
lines = [l.strip() for l in open(load_path) if l.strip()]
for m in mods:
    if m not in lines and f"/lib/modules/{m}" not in lines:
        lines.append(m)
with open(load_path, "w") as f:
    f.write("\n".join(lines) + "\n")
with open(os.path.join(mroot, "modules.load.recovery"), "w") as f:
    f.write("\n".join(lines) + "\n")

# 2. modules.blocklist (blocklist panel touch drivers during first-stage normal boot)
blk_path = os.path.join(mroot, "modules.blocklist")
blk_lines = [f"blocklist {m}" for m in mods]
with open(blk_path, "w") as f:
    f.write("\n".join(blk_lines) + "\n")

# 3. modules.dep
dep_path = os.path.join(mroot, "modules.dep")
dep_lines = [l.rstrip("\n") for l in open(dep_path) if l.strip()]
existing_keys = {l.split(":", 1)[0].strip() for l in dep_lines}
vdlkm_dep = open(os.path.join(work, "vdlkm.modules.dep")).read().splitlines()
for m in mods:
    key = f"/lib/modules/{m}"
    if key in existing_keys:
        continue
    for vl in vdlkm_dep:
        norm = vl.replace("/vendor_dlkm/lib/modules/", "/lib/modules/").replace("/vendor/lib/modules/", "/lib/modules/")
        if norm.startswith(key + ":"):
            # Keep only dependencies that actually exist in vendor_kernel_boot ramdisk
            lhs, rhs = norm.split(":", 1)
            kept = [d for d in rhs.split() if os.path.exists(os.path.join(mroot, os.path.basename(d)))]
            dep_lines.append((lhs + ": " + " ".join(kept)).rstrip())
            break
with open(dep_path, "w") as f:
    f.write("\n".join(dep_lines) + "\n")

# 4. modules.alias
alias_path = os.path.join(mroot, "modules.alias")
alias_lines = [l.rstrip("\n") for l in open(alias_path)]
alias_set = set(alias_lines)
mod_stems = {m[:-3].replace("-", "_") for m in mods} | {m[:-3] for m in mods}
for al in open(os.path.join(work, "vdlkm.modules.alias")).read().splitlines():
    parts = al.split()
    if len(parts) >= 3 and parts[0] == "alias" and parts[-1] in mod_stems and al not in alias_set:
        alias_lines.append(al)
        alias_set.add(al)
with open(alias_path, "w") as f:
    f.write("\n".join(alias_lines) + "\n")
PY

# Repack vendor_ramdisk00 non-root with deterministic root:root ownership and LZ4 legacy frame
(cd "$work/ramdisk" && find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R 0:0 --quiet) |
    lz4 -l -12 --favor-decSpeed > "$work/vkb/vendor_ramdisk00"

eval "mkboot_args=($(cat "$work/mkbootimg.args"))"
python3 "$MKBOOTIMG" "${mkboot_args[@]}" --vendor_boot "$OUT/radio/vendor_kernel_boot.img"

# Preserve stock AVB footer properties & partition size (64 MiB)
avb_props=()
if "$AVBTOOL" info_image --image "$work/vendor_kernel_boot.src.img" > "$work/avb.info" 2>/dev/null; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]+Prop:[[:space:]]+([^[:space:]]+)[[:space:]]+-\>[[:space:]]+'(.*)'$ ]]; then
            avb_props+=(--prop "${BASH_REMATCH[1]}:${BASH_REMATCH[2]}")
        fi
    done < "$work/avb.info"
fi
"$AVBTOOL" add_hash_footer \
    --image "$OUT/radio/vendor_kernel_boot.img" \
    --partition_name vendor_kernel_boot \
    --partition_size 67108864 \
    "${avb_props[@]}"

vkb_sha1="$(sha1sum "$OUT/radio/vendor_kernel_boot.img" | awk '{print $1}')"

cat > "$OUT/Android.mk" << MK
#
# Automatically generated by device/google/pantah/cheetah/extract-kernel-images.sh. DO NOT MODIFY
#

LOCAL_PATH := \$(call my-dir)

ifeq (\$(TARGET_DEVICE),cheetah)

\$(call add-radio-file-sha1-checked,radio/vendor_kernel_boot.img,$vkb_sha1)

endif
MK

echo "$build_id ($(basename "$image_zip"))" > "$OUT/SOURCE"
(cd "$OUT" && sha256sum images/*.img radio/*.img > SHA256SUMS)
echo "OK: $OUT ($build_id, vendor_kernel_boot sha1=$vkb_sha1)"
