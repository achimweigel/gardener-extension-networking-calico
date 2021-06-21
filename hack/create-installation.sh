#!/bin/bash
#
# Copyright (c) 2020 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# SPDX-License-Identifier: Apache-2.0

set -e

SOURCE_PATH="$(dirname $0)/.."
TMP_DIR="$(mktemp -d)"
INSTALLATION_PATH="${TMP_DIR}/installation.yaml"

REGISTRY="$(${SOURCE_PATH}/hack/get-cd-registry.sh)"
COMPONENT_NAME="$(${SOURCE_PATH}/hack/get-cd-component-name.sh)"

cat << EOF > ${INSTALLATION_PATH}
apiVersion: landscaper.gardener.cloud/v1alpha1
kind: Installation
metadata:
  name: networking-calico
spec:
  componentDescriptor:
    ref:
      repositoryContext:
        type: ociRegistry
        baseUrl: ${REGISTRY}
      componentName: ${COMPONENT_NAME}
      version: ${EFFECTIVE_VERSION}

  blueprint:
    ref:
      resourceName: networking-calico-controller-registration

  imports:
    targets:
      - name: cluster
        target: "#cluster"

  importDataMappings:

    controllerRegistration:
      concurrentSyncs: 50
      resources:
        requests:
          cpu: 100m
          memory: 512Mi
        limits:
          cpu: 1000m
          memory: 1Gi
      vpa:
        enabled: false

    imageVectorOverwrite: {}
EOF

echo "Installation stored at ${INSTALLATION_PATH}"