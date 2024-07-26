---
title: Prepare a Cluster Group with Capabilities
---

In a day in the life of a platform engineer, we will start by creating a *Cluster Group*, to structure the underlying Kubernetes infrastructure and define the *Capabilities* we want to install and make available to the application teams.

When you create a project, Tanzu Platform creates a *Cluster Group* with the name `run` for you. This *Cluster Group* makes it easy to just use all the `Capabilities` available by default with Tanzu Platform.

### Create Cluster Group

#### Option 1: Tanzu Platform GUI

In the Tanzu Platform GUI navigate to `Infrastructure > Kubernetes Clusters` and click the `Create Cluster Group` button. 


**Use the workshop session name with a suffix as the name of the *Cluster Group*.**
```copy
{{< param  session_name >}}-cg
```

{{< note >}}
We are adding a suffix to the name of the different resources we will create because there is a limitation that *Cluster Group* names and *Space* names must not be the same.
{{< /note >}}

**Make sure that the checkbox for Tanzu Application Engine is checked.**

#### Option 2: tanzu CLI
```section:begin
title: "Open instructions"
```

Create a *Cluster Group* template file with the workshop session name as the name of the *Cluster Group*, and the configuration to enable `Tanzu Application Engine` for it.
```editor:append-lines-to-file
file: ~/cluster-group-values.yaml
description: Add cluster group template file
text: |
  Name: {{< param  session_name >}}-cg
  Integrations: TANZU_APPLICATION_ENGINE
```

Ensure the correct project is set and use the tanzu CLI to create a cluster group based on the template file.
```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
tanzu operations clustergroup create -v cluster-group-values.yaml 
```
```section:end
```
### Add Capabilities to the Cluster Group

#### Option 1: Tanzu Platform GUI

In the Tanzu Platform GUI navigate to `Application Spaces > Capabilities`. 
The **Available** tab provides a list of all available *Capabilities* with the functionality to install them on `Cluster Groups`, and the **Installed** tab provides an overview of the *Capabilities* already installed on the different `Cluster Groups` with the functionality to uninstall and reconfigure them.

Currently, it's only possible to manage (install, uninstall, ...) them one by one, even if in most cases several *Capabilities* are installed at once.

Let's select the **Container App** *Capability* in the `Available` tab. 
Next, click on the `Install Package` button, use the defaults for the package name and version, and select your "{{< param  session_name >}}" *Cluster Group* as a deployment target. Some of the *Capabilities* and related packages also require or provide the option for custom configuration, which can be done in the `Advanced Configuration` section of the form.
Click on the `Install Package` button at the top of the form to finally install the *Capability* on the *Cluster Group*.

For those that are familiar with [kapp-controller](https://carvel.dev/kapp-controller/), the installation of a *Capability* is the configuration of a [PackageInstall](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#package-install) for a *Cluster Group* that will be synched to all the Kubernetes clusters in it.

#### Option 2: tanzu CLI
```section:begin
title: "Open instructions"
```

Ensure the correct project is set and set the context to your *Cluster Group*.
```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
tanzu operations clustergroup use {{< param  session_name >}}-cg
```

You can get a list of all available *Capabilities* (or the underlying [kapp-controller Packages](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#overview)) with the following command. 
```execute
tanzu package available list
```

Let's have a closer look at the **Container App** *Capability*, which we would like to install in our *Cluster Group* now.
```execute
tanzu package available get container-apps.tanzu.vmware.com
```

For a specific version of a *Capability's* underlying package, it's also possible to get an output of the configuration options via the `tanzu package available get <package-name>/<package-version> --values-schema` command.

As there are no configuration options available for the **Container App** *Capability*, we can just install it in our *Cluster Group* without additionally providing them via the `--values` or `--values-file` argument.
```execute
tanzu package install container-apps.tanzu.vmware.com -p container-apps.tanzu.vmware.com -v '>0.0.0'
```

In the end, the installation of a *Capability* is the configuration of a [PackageInstall](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#package-install) for a *Cluster Group* that will be synched to all the Kubernetes clusters in it.
```section:end
```

#### Option 3 (not recommended): kubectl CLI
```section:begin
title: "Open instructions"
```
As the Unified Control Plane of Tanzu Platform Kubernetes provides a Kubernetes-style API it's also possible to use `kubectl` or other Kubernetes tools to manage *Capabilities* in *Cluster Groups*.

Ensure the correct project is set and set the context to your *Cluster Group*.
```
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
tanzu operations clustergroup use {{< param  session_name >}}-cg
```
Set the `KUBECONFIG` environment variable to point to the tanzu CLI kubeconfig file.
```
export KUBECONFIG=~/.config/tanzu/kube/config
```

{{< note >}}
It's possible to install, delete, and update *Capabilities* in *Cluster Groups* via the underlying [PackageInstall](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#package-install) custom Kubernetes resources, but it's not possible to e.g. list and get details about available *Capabilities*/[kapp-controller Packages](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#overview). It's the job of the related Kubernetes controller to create the Package custom resources in a cluster based on a `PackageRepository` where we could get this info from, but Tanzu Platform's UCP is only a control plane without any running controllers.
{{< /note >}}

Get a list of all installed *Capabilities* in *Cluster Groups*.
```
kubectl get packageinstalls.packaging.carvel.dev
```

Get the `PackageInstall` resource for the **Container App** *Capability*.
```
kubectl get packageinstalls.packaging.carvel.dev container-apps.tanzu.vmware.com -o yaml
```

Switch back to default kubeconfig file.
```
unset KUBECONFIG
```
```section:end
```