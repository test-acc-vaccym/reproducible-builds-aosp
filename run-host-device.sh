#!/bin/bash
set -ex

# Environment sanity check
if [[ -z "${AOSP_REF}" ]]; then
    echo "Missing environment var <AOSP_REF>"
    exit 1
fi
if [[ -z "${BUILD_ID}" ]]; then
    echo "Missing environment var <BUILD_ID>"
    exit 1
fi
if [[ -z "${DEVICE_CODENAME}" ]]; then
    echo "Missing environment var <DEVICE_CODENAME>"
    exit 1
fi
if [[ -z "${GOOGLE_BUILD_TARGET}" ]]; then
    echo "Missing environment var <GOOGLE_BUILD_TARGET>"
    exit 1
fi
if [[ -z "${RB_BUILD_TARGET}" ]]; then
    echo "Missing environment var <RB_BUILD_TARGET>"
    exit 1
fi

GOOGLE_BUILD_ENV="Google"
RB_AOSP_BASE="/home/dev/aosp"
RB_BUILD_ENV="docker"

bash "./scripts/shared/build-device/10_clone-src-device.sh" "${AOSP_REF}"
bash "./scripts/shared/build-device/11_fetch-extract-vendor.sh" "${BUILD_ID}" "${DEVICE_CODENAME}"
bash "./scripts/shared/build-device/12_build-device.sh" "${AOSP_REF}" "${RB_BUILD_TARGET}" "${DEVICE_CODENAME}"
bash "./scripts/shared/build-device/13_fetch-extract-factory-images.sh" "${AOSP_REF}" "${BUILD_ID}" "${DEVICE_CODENAME}"
bash "./scripts/shared/analysis/20_install-simg2img.sh"
bash "./scripts/shared/analysis/21_diffoscope-files.sh" \
    "${RB_AOSP_BASE}/build/${AOSP_REF}/${GOOGLE_BUILD_TARGET}/${GOOGLE_BUILD_ENV}" \
    "${RB_AOSP_BASE}/build/${AOSP_REF}/${RB_BUILD_TARGET}/(lsb_release -si)(lsb_release -sr)" \
    "${RB_AOSP_BASE}/diff/${AOSP_REF}_${GOOGLE_BUILD_TARGET}_${GOOGLE_BUILD_ENV}__${AOSP_REF}_${RB_BUILD_TARGET}_(lsb_release -si)(lsb_release -sr)"