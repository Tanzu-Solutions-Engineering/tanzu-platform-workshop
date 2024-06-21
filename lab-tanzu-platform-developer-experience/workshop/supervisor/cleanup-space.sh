#!/bin/bash

# Stop script
stop_script() {
  TANZU_API_TOKEN=$TANZU_CLI_SPACE_CREATE_TOKEN tanzu context create space-admin --type tanzu --endpoint https://api.tanzu.cloud.vmware.com

  tanzu project use $TANZU_PLATFORM_PROJECT

  tanzu space delete $SESSION_NAME -y --no-color

  tanzu context delete space-admin -y
}
# Wait for supervisor to stop script
trap stop_script SIGINT SIGTERM

while true
do
    sleep 1
done