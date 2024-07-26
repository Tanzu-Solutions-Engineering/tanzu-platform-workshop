#!/bin/bash

set -x
set -eo pipefail

kubectl konfig import --save vcluster-kubeconfig.yaml
kubectl ctx $(yq eval '.current-context' vcluster-kubeconfig.yaml)
kubectl ns default