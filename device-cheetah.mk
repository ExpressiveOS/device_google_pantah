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
    DMServiceOverlayVendorCheetah \
    FrameworkResOverlayVendorCheetah \
    PixelNfcOverlayCheetah \
    PixelWifiOverlay2023_midyear_F10 \
    SettingsGoogleCheetahOverlay \
    SettingsGoogleOverlayProductCheetah \
    SettingsOverlayGE2AE \
    SettingsOverlayGFE4J \
    SettingsOverlayGP4BC \
    SystemUIGoogleOverlayVendorCheetah

PRODUCT_PACKAGES += \
    UpdaterOverlayCheetah

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
    $(DEVICE_PATH)/recovery/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.cheetah.rc

PRODUCT_PACKAGES += \
    init.recovery.cheetah.touch.rc

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# UWB
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.uwb.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.uwb.xml

# VINTF
DEVICE_MANIFEST_FILE += \
    $(DEVICE_PATH)/vintf/manifest.xml
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/device_framework_matrix_product.xml

# Adaptive Connectivity Services (SCONE) and Google Fi (Tycho)
PRODUCT_PACKAGES += \
    SCONE-v77459 \
    Tycho

# NFC on after a clean flash, as stock
PRODUCT_PACKAGES += \
    NfcOverlayCheetah

# Keep Google Play services from preparing Google's OTAs (sysconfig/disable-google-ota.xml).
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/sysconfig/disable-google-ota.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/disable-google-ota.xml

# Values stock cheetah (CP3A.261005.002.A1) sets that our build left at the AOSP default
PRODUCT_PACKAGES += \
    ConnectivityOverlayStockCheetah \
    FrameworkResOverlayStockCheetah \
    MediaProviderOverlayStockCheetah \
    SettingsOverlayStockCheetah \
    SystemUIOverlayStockCheetah \
    WifiOverlayStockCheetah

# Wild Kernels' boot (EOS_WILD_BOOT, BoardConfig): its release, 6.x.y-androidNN-Wild, isn't a
# GKI release string, so the build's kernel VINTF check can't tell its kernel FCM level and
# fails. Off for that boot only: the kernel is Google's GKI of the same KMI with BakaSU and
# susfs added, booted on a phone first. A product variable, so here and not in BoardConfig.
ifneq ($(EOS_WILD_BOOT),)
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
endif
