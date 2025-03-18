#!/bin/bash
# Copyright (c) Kopexa GmbH
# SPDX-License-Identifier: BUSL-1.1

set -e

. ${GITHUB_ACTION_PATH}/../../lib/lib.sh

cd "${WORKING_DIRECTORY:-$GITHUB_WORKSPACE}"
go mod download
make compile
