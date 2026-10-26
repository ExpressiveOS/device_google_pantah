#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-FileCopyrightText: The Calyx Institute
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit device configuration
DEVICE_CODENAME := cheetah
DEVICE_PATH := device/google/pantah
VENDOR_PATH := vendor/google/cheetah
$(call inherit-product, $(DEVICE_PATH)/aosp_$(DEVICE_CODENAME).mk)

# Device identifier. This must come after all inclusions
PRODUCT_NAME := lineage_$(DEVICE_CODENAME)
PRODUCT_SYSTEM_BRAND := google
PRODUCT_SYSTEM_MANUFACTURER := Google
PRODUCT_SYSTEM_NAME := generic_system_google

# Boot animation
TARGET_SCREEN_HEIGHT := 3120
TARGET_SCREEN_WIDTH := 1440
# Only ExpressiveOS's own animation (vendor/extra/bootanimation), not Evolution X's
# other styles (about 190 MiB in /product/media). Product config reads this file
# before the ones it inherits, so this wins over vendor/lineage's common.mk default
# (?= true) for every build of this tree.
TARGET_INCLUDE_BOOT_ANIMATIONS := false

# Custom flags
TARGET_HAS_UDFPS := true

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="cheetah-user 17 CP3A.261005.002.A1 16269273 release-keys" \
    BuildSystemDesc=generic_system_google-user 17 CP3A.261005.002.A1 16269273 release-keys \
    BuildFingerprint=google/cheetah/cheetah:17/CP3A.261005.002.A1/16269273:user/release-keys \
    BuildSystemFingerprint=google/generic_system_google/generic:17/CP3A.261005.002.A1/16269273:user/release-keys \
    DeviceProduct=$(DEVICE_CODENAME)

# Evolution X puts AppDataBackup in /system, which generic_system.mk's artifact-path
# rules forbid for device makefiles (its skip-on-Pixel check reads
# PRODUCT_MANUFACTURER, which inherited product makefiles never see). Allow it, as
# LineageOS does for its own /system additions.
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/permissions/privapp-permissions-appbackup.xml \
    system/priv-app/AppDataBackup/%

$(call inherit-product, $(VENDOR_PATH)/$(DEVICE_CODENAME)-vendor.mk)
