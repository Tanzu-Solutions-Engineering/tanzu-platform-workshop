---
title: Workshop Overview
---

```terminal:execute
description: Switch to workload cluster context
command: export KUBECONFIG=$HOME/vcluster-kubeconfig.yaml
```
```terminal:execute
description: Switch to TP for K8s context
command: export KUBECONFIG=$HOME/.config/tanzu/kube/config
```
```terminal:execute
description: Switch to educates namespace context
command: unset KUBECONFIG
```

```execute
tanzu login
```

```execute
tanzu project list
```

```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
```

```execute
tanzu build config --build-plan-source-type=ucp --containerapp-registry $PUBLIC_REGISTRY_HOST/{name}
```
```execute
git clone https://github.com/timosalm/emoji-inclusion inclusion
```
```execute
cd inclusion
```
```execute
tanzu app init
```
```terminal:execute
description: Accept default application name
command: ""
```
```terminal:execute
description: Confirm default application source directory
command: ""
```
```terminal:execute
description: Confirm Cloud Native Buildpacks as build type
command: ""
```
```execute
tanzu deploy -y
```