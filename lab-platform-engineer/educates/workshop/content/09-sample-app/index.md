---
title: Deploy a simple Application to the Space
---

Let's validate that all of the setup we've prepared so far (*Cluster Group*, the workload cluster, *Availability Target*, *Profile*, *Space*) is properly configured and ready for application development teams to use.

First, we have to configure the build phase of our sample application. We need to specify the container registry to be used for storing the application containers and deployment manifests and use a build plan stored remotely, in the UCP.
```execute
tanzu build config --build-plan-source-type=ucp --containerapp-registry $PUBLIC_REGISTRY_HOST/{name}
```

The next step is to get the source code from a Git repository. 
```execute
git clone https://github.com/timosalm/emoji-inclusion inclusion
```
```execute
cd inclusion
```

Now, we need to add some configuration so that the platform understands the name, location of the source code, etc. of our application.
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
tanzu app config build non-secret-env set BP_JVM_VERSION=17
```

Last but not least, we have to target our *Space* ...
```execute
tanzu space use {{< param  session_name >}}
```
... and build and deploy our application.s
```execute
tanzu deploy -y
```

As we don't have added *Capabilities* for Ingress, global load balancing etc. for this simple example, you will not get a URL for your application via your *Space*.

