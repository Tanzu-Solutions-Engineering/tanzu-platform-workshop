---
title: Workshop Overview
---

```execute
tanzu login
```

```execute
tanzu project list
```

```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
```

## Cluster Group
```editor:append-lines-to-file
file: ~/cluster-group-values.yaml
description: Add cluster group template file
text: |
  Name: {{< param  session_name >}}
  Integrations: TANZU_APPLICATION_ENGINE
```
```execute
tanzu operations clustergroup create -v cluster-group-values.yaml 
```

## Attach workload cluster 
```editor:append-lines-to-file
file: ~/cluster-attach-values.yaml
description: Add template file for cluster attachment
text: |
  fullName:
    managementClusterName: attached
    provisionerName: attached
    name: {{< param  session_name >}}
  meta:
    description: Attaching cluster using tanzu cli
    labels:
      workshop-session: {{< param  session_name >}}
  spec:
    clusterGroupName: {{< param  session_name >}}
```
```execute
tanzu operations cluster attach --file cluster-attach-values.yaml --kubeconfig vcluster-kubeconfig.yaml
```

## Add capabilities to cluster group

WIP

https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-run-cluster-group.html

## Cleanup
```execute
tanzu operations cluster delete {{< param  session_name >}} --cluster-type attached --management-cluster-name attached --provisioner-name attached
anzu operations clustergroup delete {{< param  session_name >}}
```

# TMP
## App

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