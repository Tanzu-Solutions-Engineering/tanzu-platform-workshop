#!/bin/bash

set -x
set -eo pipefail

if [ -n "$TANZU_CLI_SPACE_CREATE_TOKEN" ]; then
export TANZU_CLI_USE_TANZU_CLOUD_SERVICE_PROVIDER=true
TANZU_API_TOKEN=$TANZU_CLI_SPACE_CREATE_TOKEN tanzu context create space-admin --type tanzu --endpoint https://api.tanzu.cloud.vmware.com

tanzu project use $TANZU_PLATFORM_PROJECT

TANZU_BUILD_PLAN=$(kubectl get containerappbuildplans simple.tanzu.vmware.com -o json)

tanzu space create $SESSION_NAME $(echo $TANZU_PLATFORM_PROFILES | tr , '\n' | awk '{print "--profile " $1}' | tr '\n' ' ') $(echo $TANZU_PLATFORM_AVAILABILITY_TARGETS | tr , '\n' | awk '{print "--availability-target " $1}' | tr '\n' ' ') --update-strategy RollingUpdate -y --no-color

tanzu context delete space-admin -y

BUILDER=$(echo $TANZU_BUILD_PLAN | jq -r '.spec.buildpacks.builder')
docker pull $BUILDER

fi
