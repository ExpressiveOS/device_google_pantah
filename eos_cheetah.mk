#
# SPDX-FileCopyrightText: 2026 The ExpressiveOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit ExpressiveOS common configuration
$(call inherit-product, vendor/expressiveos/config/common.mk)

# Inherit device configuration
DEVICE_CODENAME := cheetah
DEVICE_PATH := device/google/pantah
VENDOR_PATH := vendor/google/cheetah
$(call inherit-product, $(DEVICE_PATH)/aosp_$(DEVICE_CODENAME).mk)

# Device identifier. This must come after all inclusions
PRODUCT_NAME := eos_$(DEVICE_CODENAME)
PRODUCT_SYSTEM_BRAND := google
PRODUCT_SYSTEM_MANUFACTURER := Google
PRODUCT_SYSTEM_NAME := generic_system_google

# Boot animation
TARGET_SCREEN_HEIGHT := 3120
TARGET_SCREEN_WIDTH := 1440

# Custom flags
TARGET_HAS_UDFPS := true

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="cheetah-user 17 CP4A.261105.040.A1 16581829 release-keys" \
    BuildSystemDesc="generic_system_google-user 17 CP4A.261105.040.A1 16581829 release-keys" \
    BuildFingerprint=google/cheetah/cheetah:17/CP4A.261105.040.A1/16581829:user/release-keys \
    BuildSystemFingerprint=google/generic_system_google/generic:17/CP4A.261105.040.A1/16581829:user/release-keys \
    DeviceProduct=$(DEVICE_CODENAME)

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/app/GoogleExtShared/% \
    system/app/GooglePrintRecommendationService/% \
    system/priv-app/DocumentsUIGoogle/% \
    system/priv-app/GooglePackageInstaller/% \
    system/priv-app/TagGoogle/%

$(call inherit-product, $(VENDOR_PATH)/$(DEVICE_CODENAME)-vendor.mk)
