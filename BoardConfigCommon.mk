#
# SPDX-FileCopyrightText: 2026 The ExpressiveOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Security - must be defined before including BoardConfig-common.mk
BOOT_SECURITY_PATCH := 2026-11-05
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)

KERNEL_IMAGES_PATH ?= vendor/google/$(TARGET_BOOTLOADER_BOARD_NAME)-kernel-images

include device/google/gs201/BoardConfig-common.mk

# Kernel
BOARD_KERNEL_CMDLINE += swiotlb=noforce

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/vendor \
    hardware/google/pixel-sepolicy/vibrator/common \
    hardware/google/pixel-sepolicy/vibrator/cs40l26

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/system_ext/private

SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/system_ext/public

# WiFi
include $(DEVICE_PATH)/wifi/BoardConfig-wifi.mk

# Wild Kernels (ExpressiveOS: root out of the box): expressiveos-cheetah/tools/eos-make.sh
# builds boot-wild.img (ksu/tools/wild-boot.sh: this boot image with Wild Kernels' BakaSU
# kernel for the phone's KMI) and sets EOS_WILD_BOOT to it, so the images and the OTA ship
# it, signed with the boot AVB key like any prebuilt boot.
ifneq ($(EOS_WILD_BOOT),)
BOARD_PREBUILT_BOOTIMAGE := $(EOS_WILD_BOOT)
endif
