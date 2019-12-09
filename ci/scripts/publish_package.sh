#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

curl -u"${ARTIFACTORY_USERNAME}":"${ARTIFACTORY_PASSWORD}" \
     -T "./release/${TARGET}/hyperledger-fabric-${TARGET}-${RELEASE}.tar.gz" \
     "https://hyperledger.jfrog.io/hyperledger/fabric-binaries/hyperledger-fabric-${TARGET}-${RELEASE}.tar.gz"