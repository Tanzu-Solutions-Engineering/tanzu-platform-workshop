#!/bin/bash

set -e

TANZU_API_TOKEN=$TANZU_CLI_SPACE_CREATE_TOKEN tanzu context create space-admin --type tanzu --endpoint https://api.tanzu.cloud.vmware.com

tanzu project use $TANZU_PLATFORM_PROJECT

tanzu space create $SESSION_NAME $(echo $TANZU_PLATFORM_PROFILES | tr , '\n' | awk '{print "--profile " $1}' | tr '\n' ' ') $(echo $TANZU_PLATFORM_AVAILABILITY_TARGETS | tr , '\n' | awk '{print "--availability-target " $1}' | tr '\n' ' ') --update-strategy RollingUpdate -y --no-color

tanzu context delete space-admin -y