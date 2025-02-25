#!/bin/bash

. ${GITHUB_ACTION_PATH}/../../lib/lib.sh

cd "${WORKING_DIRECTORY:-$GITHUB_WORKSPACE}"
go mod download

${INPUT_command} | go-junit-report -iocopy -out junit.xml
