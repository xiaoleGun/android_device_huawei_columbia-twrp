#
# Copyright (C) 2023 Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Inherit from our custom product configuration.
$(call inherit-product, vendor/omni/config/common.mk)

# Release name
PRODUCT_RELEASE_NAME := columbia,kirin970

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := omni_columbia
PRODUCT_DEVICE := columbia
PRODUCT_BRAND := Huawei
PRODUCT_MODEL := Honor 10

# Kernel
PRODUCT_COPY_FILES += \
    device/huawei/columbia/dummykernel:kernel

PRODUCT_PACKAGES += \
    charger_res_images \
    charger
