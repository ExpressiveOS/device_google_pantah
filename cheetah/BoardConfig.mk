#
# SPDX-FileCopyrightText: 2020 The Android Open-Source Project
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-FileCopyrightText: The Calyx Institute
# SPDX-License-Identifier: Apache-2.0
#

TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt
TARGET_BOOTLOADER_BOARD_NAME := $(DEVICE_CODENAME)
TARGET_SCREEN_DENSITY := 560

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/$(DEVICE_CODENAME)/vendor

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/$(DEVICE_CODENAME)/system_ext/private

SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/$(DEVICE_CODENAME)/system_ext/public

include $(DEVICE_PATH)/BoardConfigCommon.mk

include $(VENDOR_PATH)/BoardConfigVendor.mk

# Keep app odex on /system rather than system_other. Only a factory flash
# writes system_other to the inactive slot; zip and OTA installs never do, so
# SystemUIGoogle, SettingsGoogle and the other preopted priv-apps lose their
# AOT code after every update and run interpreted/JIT until background
# dexopt catches up (~180 MB, well inside super).
BOARD_USES_SYSTEM_OTHER_ODEX :=
