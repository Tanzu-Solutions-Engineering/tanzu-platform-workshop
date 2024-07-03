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