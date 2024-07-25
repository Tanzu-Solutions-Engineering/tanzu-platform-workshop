---
title: Sample App
---

***TODO:*** Deploy an application that is "pre-built" to the platform so that you can see a running app launch and access it via Ingress.

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
tanzu space use {{< param  session_name >}}
```

```execute
tanzu deploy -y
```