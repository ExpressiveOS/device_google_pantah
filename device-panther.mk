#
# SPDX-FileCopyrightText: 2021 The Android Open-Source Project
# SPDX-FileCopyrightText: 2026 The ExpressiveOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from gs201
include device/google/gs201/common.mk

# Overlays
PRODUCT_PACKAGES += \
    FrameworkResOverlayProductPantah \
    FrameworkResOverlayVendorPantah \
    ONSOverlayVendorPantah \
    PixelNfcOverlayPantah \
    SafetyRegulatoryInfoOverlayProductPantah \
    SystemUIGoogleOverlayVendorPantah

PRODUCT_PACKAGES += \
    DMServiceOverlayProductGs201 \
    DMServiceOverlayVendorPanther \
    FrameworkResOverlayVendorPanther \
    PixelNfcOverlayPanther \
    PixelWifiOverlay2023_midyear_F10 \
    SettingsGoogleOverlayProductPanther \
    SettingsGooglePantherOverlay \
    SettingsOverlayG03Z5 \
    SettingsOverlayGQML3 \
    SettingsOverlayGVU6C \
    SfpsOverlayGs201 \
    SystemUIGoogleOverlayVendorPanther \
     UDFPSOverlayVendorPanther

# PowerShare
include hardware/google/pixel/eos_powershare/device.mk

# Preinstalled packages
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/sysconfig/preinstalled-packages-prebuilt-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-prebuilt-product.xml \
    $(DEVICE_PATH)/sysconfig/preinstalled-packages-prebuilt-system_ext.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/preinstalled-packages-prebuilt-system_ext.xml

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/product.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/vendor.prop

# Recovery
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.panther.rc

PRODUCT_PACKAGES += \
    init.recovery.panther.touch.rc

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# VINTF
DEVICE_MANIFEST_FILE += \
    $(DEVICE_PATH)/vintf/manifest.xml
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/device_framework_matrix_product.xml
