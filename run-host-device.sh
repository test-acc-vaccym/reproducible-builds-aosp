#!/bin/bash

# Copyright 2020 Manuel Pöll
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit -o nounset -o pipefail -o xtrace

main() {

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
    if [[ -z "${RB_BUILD_TARGET}" ]]; then
        echo "Missing environment var <RB_BUILD_TARGET>"
        exit 1
    fi
    if [[ -z "${GOOGLE_BUILD_TARGET}" ]]; then
        echo "Missing environment var <GOOGLE_BUILD_TARGET>"
        exit 1
    fi

    local -r GOOGLE_BUILD_ENV="Google"
    local -r RB_AOSP_BASE="/home/dev/aosp"
    local -r RB_BUILD_ENV="docker"

    bash "./scripts/shared/build-device/10_clone-src-device.sh" "${AOSP_REF}"
    bash "./scripts/shared/build-device/11_fetch-extract-vendor.sh" "${BUILD_ID}" "${DEVICE_CODENAME}"
    bash "./scripts/shared/build-device/12_build-device.sh" "${AOSP_REF}" "${RB_BUILD_TARGET}" "${DEVICE_CODENAME}"
    bash "./scripts/shared/build-device/13_fetch-extract-factory-images.sh" "${AOSP_REF}" "${BUILD_ID}" "${DEVICE_CODENAME}"
    bash "./scripts/shared/analysis/20_diffoscope-files.sh" \
        "${RB_AOSP_BASE}/build/${AOSP_REF}/${GOOGLE_BUILD_TARGET}/${GOOGLE_BUILD_ENV}" \
        "${RB_AOSP_BASE}/build/${AOSP_REF}/${RB_BUILD_TARGET}/(lsb_release -si)(lsb_release -sr)" \
        "${RB_AOSP_BASE}/diff/${AOSP_REF}_${GOOGLE_BUILD_TARGET}_${GOOGLE_BUILD_ENV}__${AOSP_REF}_${RB_BUILD_TARGET}_(lsb_release -si)(lsb_release -sr)"
    bash "./scripts/shared/analysis/21_generate-csv.sh" "${RB_AOSP_BASE}/diff/${AOSP_REF}_${GOOGLE_BUILD_TARGET}_${GOOGLE_BUILD_ENV}__${AOSP_REF}_${RB_BUILD_TARGET}_(lsb_release -si)(lsb_release -sr)"
    bash "./scripts/shared/analysis/22_generate-summary-device.sh" "${RB_AOSP_BASE}/diff/${AOSP_REF}_${GOOGLE_BUILD_TARGET}_${GOOGLE_BUILD_ENV}__${AOSP_REF}_${RB_BUILD_TARGET}_(lsb_release -si)(lsb_release -sr)"
    bash "./scripts/shared/analysis/23_generate-html.sh" "${RB_AOSP_BASE}/diff/${AOSP_REF}_${GOOGLE_BUILD_TARGET}_${GOOGLE_BUILD_ENV}__${AOSP_REF}_${RB_BUILD_TARGET}_(lsb_release -si)(lsb_release -sr)"
    bash "./scripts/shared/analysis/24_generate-index-html.sh" "${RB_AOSP_BASE}/diff"
}

main "$@"
