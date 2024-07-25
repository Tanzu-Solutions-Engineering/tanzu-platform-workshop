---
title: Define Application Environment Characteristics with Profiles
---

For the successful scheduling of the applications onto clusters, it's not only necessary to define a target group of clusters with an *Availability Target*, you also have to define the required *Capabilities* for your application which the target clusters have to provide. 
More information on how the scheduling works is available [here](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/concepts-about-spaces.html#space-scheduling-4).

***Profiles* are reusable building blocks for defining application environment characteristics or in other words required *Capabilities* and *Traits*.** 
*Profiles* are intended to be reused across *Spaces*. Tanzu Platform for Kubernetes provides for example ootb a "spring-prod.tanzu.vmware.com" *Profile* as a reusable way to create environments for running Spring applications in production. 

# Create a custom Profile

Let's create a *Profile* for our minimal workshop example.

## Option 1: Tanzu Platform GUI
In the Tanzu Platform GUI navigate to `Application Spaces > Profiles` or click [here](https://www.mgmt.cloud.vmware.com/hub/application-engine/profiles/profiles).

Next, click on the button in the upper right corner of the browser window labeled "Create Profile".

In the resulting dialog, click the "Step by Step" button to get the guided interface for creating the *Profile*.

Now, let's name our *Profile* the same as our session name by pasting the clipboard into the "Name" field.
```copy
{{< param  session_name >}}
```

Click "next", and select the **carvel-package-installer.tanzu.vmware.com *Trait***, which is required to deploy an application as a [kapp-controller Package](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#overview) - the default for Tanzu Application Platform.
As a reminder, *Traits* are collections of Kubernetes resources that are deployed into *Spaces* when they are created and usually rely on `Capabilities` available in the cluster. 

You can configure the *Trait* by clicking on the **"Configure carvel-package-installer.tanzu.vmware.com"** button. In this case the default value for the "ServiceAccountName" is fine.

After clicking "next", you can select the required *Capabilities*, which is in our case just **container-app.tanzu.vmware.com**.

With another click on a "next" button, you should see the summary page, where you can finally create the Profile with a click on the "Create" button.

You can check whether the *Profile* is ready by navigating to `Application Spaces > Profiles`, searching for your *Profile* in the list and clicking on the "View Details" button.

## Option 2: tanzu (or kubectl) CLI
To create a *Profile* with the tanzu CLI, we have to create a resource file with all the configurations like for the *Availability Target*.
```editor:append-lines-to-file
file: ~/profile.yaml
description: Add profile resource file
text: |
  apiVersion: spaces.tanzu.vmware.com/v1alpha1
  kind: Profile
  metadata:
    name: {{< param  session_name >}}
    namespace: default
  spec:
    requiredCapabilities:
      - name: container-app.tanzu.vmware.com
    traits:
      - values:
          inline:
            carvel-package-installer:
              serviceAccountName: carvel-package-installer
        excludedKeys: []
        name: carvel-package-installer.tanzu.vmware.com
```
As you can see, we use again the workshop session name for the name of the *Profile*.

The only defined required *Capability* is the **Container App**, which is the only one available on our workload cluster.

In addition, there is the **Carvel package installer *Trait*** configured, which is required to deploy an application as a [kapp-controller Package](https://carvel.dev/kapp-controller/docs/v0.50.x/packaging/#overview) - the default for Tanzu Application Platform.
As a reminder, *Traits* are collections of Kubernetes resources that are deployed into *Spaces* when they are created and usually rely on `Capabilities` available in the cluster. 

Finally, we can create the *Profile*.
```execute
tanzu profile create -f profile.yaml -y
```

Checking whether the *Profile* is ready is also possible with the tanzu CLI.
```execute
tanzu profile get {{< param  session_name >}}
```

### kubectl CLI
The resource file we created is in the form of a custom Kubernetes resource definition, which means that we can alternatively also directly manage (create, delete, edit) the *Profile* with kubectl.
```
export KUBECONFIG=~/.config/tanzu/kube/config
kubectl apply -f profile.yaml
kubectl get profiles.spaces.tanzu.vmware.com {{< param  session_name >}} -o yaml
unset KUBECONFIG  
```