#!/bin/bash

set -x
set -eo pipefail

sed -i -e "s/REGISTRY_BASIC_AUTH_CREDENTIALS/$(echo -n $REGISTRY_USERNAME:$REGISTRY_PASSWORD | base64 -w 0)/" $HOME/.local/share/workshop/workshop-definition.json

# Workaround for Workshop CRD bug: https://github.com/vmware-tanzu-labs/educates-training-platform/issues/442
sed -i -e 's/"name": "public-registry",/"name": "public-registry",\n          "changeOrigin": false,/' $HOME/.local/share/workshop/workshop-definition.json