#!/bin/bash

set -x
set -eo pipefail

BUILDER=$(echo $TANZU_BUILD_PLAN | jq '.spec.buildpacks.builder')
docker pull $BUILDER
