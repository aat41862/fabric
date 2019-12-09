#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

make docker

wget -qO "$PWD/manifest-tool" https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-amd64
chmod +x ./manifest-tool

docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY}"

for image in baseos peer orderer ccenv tools; do
  docker tag "hyperledger/fabric-${image}" "${DOCKER_ORG}/fabric-${image}:amd64-${RELEASE}"
  docker push "${DOCKER_ORG}/fabric-${image}:amd64-${RELEASE}"

  if [[ ${IS_RELEASE} == "true" ]]; then
    ./manifest-tool push from-args --platforms linux/amd64 --template "${DOCKER_ORG}/fabric-${image}:amd64-${RELEASE}" --target "${DOCKER_ORG}/fabric-${image}:${RELEASE}"
    ./manifest-tool push from-args --platforms linux/amd64 --template "${DOCKER_ORG}/fabric-${image}:amd64-${RELEASE}" --target "${DOCKER_ORG}/fabric-${image}:${RELEASE_TWO_DIGIT}"
  else
    docker tag "hyperledger/fabric-${image}" "${DOCKER_ORG}/fabric-${image}:amd64-latest"
    docker push "${DOCKER_ORG}/fabric-${image}:amd64-latest"
  fi
done
