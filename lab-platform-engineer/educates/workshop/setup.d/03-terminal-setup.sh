#!/bin/bash

set -x
set -eo pipefail

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew install ctx
kubectl krew install ns
kubectl krew install konfig

kubectl konfig import --save vcluster-kubeconfig.yaml

kubectl konfig import --save vcluster-kubeconfig.yaml
kubectl ctx $(yq eval '.current-context' vcluster-kubeconfig.yaml)
kubectl ns default

 

#kubectl konfig import --save .config/tanzu/kube/config


#alias k8s_ctx_vcluster="export KUBECONFIG=$HOME/vcluster-kubeconfig.yaml && kubectl config set-context --current --namespace=default"
#alias k8s_ctx_tp4k8s="export KUBECONFIG=$HOME/.config/tanzu/kube/config && kubectl config set-context --current --namespace=default"
#alias k8s_ctx_educates="unset KUBECONFIG && kubectl config set-context --current --namespace=$SESSION_NAMESPACE"


