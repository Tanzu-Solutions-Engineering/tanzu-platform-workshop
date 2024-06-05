#!/bin/bash

# Grab the Tanzu CLI and install the necessary plugins

mkdir -p /home/eduk8s/bin
mv /opt/packages/tanzu-cli/*/tanzu-cli-linux_amd64 /home/eduk8s/bin/tanzu
chmod +x /home/eduk8s/bin/tanzu

tanzu config eula accept
TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER=no tanzu plugin install --group vmware-tanzu/platform-engineer