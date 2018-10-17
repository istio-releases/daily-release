#!/bin/bash

# Copyright 2018 Istio Authors

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Exit immediately for non zero status
set -e
# Check unset variables
set -u
# Print commands
set -x

# Helper functions
source "prow/utils.sh"
# import HUB, TAG, SHA, etc.
source "greenBuild.VERSION"


function test_istioctl_version() {
  local istioctl_bin=${1}
  local expected_hub=${2}
  local expected_tag=${3}

  hub=$(${istioctl_bin} version | grep -oP 'Hub: \K[^ ]+')
  tag=$(${istioctl_bin} version | grep -oP 'Version: \K[^ ]+' | head -n 1)
  [ "${hub}" == "${expected_hub}" ]
  [ "${tag}" == "${expected_tag}" ]
}

function test_helm_files() {
  local istio_path=${1}
  local expected_hub=${2}
  local expected_tag=${3}

  hub=$(grep -oP 'hub: \K[^ ]+' "${istio_path}"/install/kubernetes/helm/istio/values.yaml | head -n 1)
  tag=$(grep -oP 'tag: \K[^ ]+' "${istio_path}"/install/kubernetes/helm/istio/values.yaml | head -n 1)
  [ "${hub}" == "${expected_hub}" ]
  [ "${tag}" == "${expected_tag}" ]

  hub=$(grep -oP 'hub: \K[^ ]+' "${istio_path}"/install/kubernetes/helm/istio-remote/values.yaml | head -n 1)
  tag=$(grep -oP 'tag: \K[^ ]+' "${istio_path}"/install/kubernetes/helm/istio-remote/values.yaml | head -n 1)
  [ "${hub}" == "${expected_hub}" ]
  [ "${tag}" == "${expected_tag}" ]
}



# Assert HUB and TAG are matching from all istioctl binaries.

download_untar_istio_release "${ISTIO_REL_URL}/docker.io" "${TAG}" docker.io
test_istioctl_version docker.io/istio-${TAG}/bin/istioctl "docker.io/istio" "${TAG}"
# TODO The expected hub should be docker.io/istio instead. Update after fix
test_helm_files docker.io/istio-${TAG} "${HUB}" "${TAG}"

download_untar_istio_release "${ISTIO_REL_URL}/gcr.io" "${TAG}" gcr.io
test_istioctl_version gcr.io/istio-${TAG}/bin/istioctl "gcr.io/istio-release" "${TAG}"
test_helm_files docker.io/istio-${TAG} "${HUB}" "${TAG}"

download_untar_istio_release "${ISTIO_REL_URL}" "${TAG}"
test_istioctl_version istio-${TAG}/bin/istioctl "${HUB}" "${TAG}"
test_helm_files docker.io/istio-${TAG} "${HUB}" "${TAG}"

