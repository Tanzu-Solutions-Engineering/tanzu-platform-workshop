---
title: Create an Application Environment with a Space
---

Finally, everything is set up to create a `Space` for the application team. 

# Create a Space
[Official documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/getting-started-create-app-envmt.html#create-a-space-in-your-project-4)

## Option 1: Tanzu Platform GUI
In the Tanzu Platform GUI navigate to `Application Spaces > Spaces` or click [here](https://www.mgmt.cloud.vmware.com/hub/application-engine/spaces).

Next, click on the button in the upper right corner of the browser window labeled "Create Space".

In the resulting dialog, click the "Step by Step" button to get the guided interface for creating the *Space*.

Let's also use the session name as a name for our *Space* by pasting the clipboard into the "Name" field.
```copy
{{< param  session_name >}}
```

Also paste the session name/clipboard into the "Space Profiles" and "Availability Targets" filter fields and select the resources you've created.

For the *Availability Target*, the **"Replica(s)" is set to 1**, which is the default and means that the applications in the space will be deployed to one of the clusters matching the *Availability Target's* rules. As we only have one cluster available, you cannot increase it to deploy the application on multiple clusters for high availability. 

You can also configure the update strategy. Rolling update is the default and fine for this workshop.

Create the *Space* by clicking on the corresponding button.

While in the GUI, click on your newly created *Space* to see details.
It may take a few seconds for the space to go from `ERROR` (red), through `WARNING` (yellow), to `READY` (green) state. Click on the top-right `Refresh` link to update.

```section:begin
title: Option 2: tanzu CLI
```
It's possible to create a *Space* with the tanzu CLI, but unfortunately, the related CLI plugin doesn't work very well for it yet.
```execute
tanzu space create --help
```

So, let's again create a resource file with all the configurations.
```editor:append-lines-to-file
file: ~/space.yaml
description: Add space resource file
text: |
  apiVersion: spaces.tanzu.vmware.com/v1alpha1
  kind: Space
  metadata:
    name: {{< param  session_name >}}
    namespace: default
  spec:
    availabilityTargets:
    - name: {{< param  session_name >}}
      replicas: 1
    template:
      spec:
        profiles:
        - name: {{< param  session_name >}}
          values:
            inline: null
    updateStrategy:
      type: RollingUpdate
```
As you can see, we also use the session name as a name for our *Space* and specify our *Profile* and *Availability Target*.

For the *Availability Target*, the **"Replica(s)" is set to 1**, which is the default and means that the applications in the space will be deployed to one of the clusters matching the *Availability Target's* rules. As we only have one cluster available, you cannot increase it to deploy the application on multiple clusters for high availability. 

You can also configure the update strategy. Rolling update is the default and fine for this workshop.

You can then create the *Space* with the following command.
```execute
tanzu deploy --only space.yaml
```

We can also check whether the *Space* is ready with the tanzu CLI. It may take some time, and the space can also be in warning or error state for some time.
```execute
tanzu space get {{< param  session_name >}}
```
```section:end
```
```section:begin
title: Option 3: kubectl CLI
```
The resource file we created is in the form of a custom Kubernetes resource definition, which means that we can alternatively also directly manage (create, delete, edit) the *Space* with kubectl.
```
export KUBECONFIG=~/.config/tanzu/kube/config
kubectl apply -f space.yaml
kubectl get spaces.spaces.tanzu.vmware.com {{< param  session_name >}} -o yaml
unset KUBECONFIG  
```
```section:end
```
# Check resources created in the workload cluster
1. Let's access our TKGS cluster the same way we did earli
After the *Space* is ready, we can check what was applied for it on our workload cluster.

If you have a look at the Kubernetes namespaces, you should be able to see two namespaces that were created for our *Space*.
```execute
kubectl get ns
```

In the namespaces with the "-internal" suffix the `PackageInstalls` for the *Traits* will be applied, the other namespace is for all the resources running in the *Space*.
```execute
SPACE_NS_INTERNAL=$(kubectl get namespaces -o json | jq -r '.items[].metadata.name | select(endswith("-internal"))')
kubectl get pkgi -n $SPACE_NS_INTERNAL
```
In our case, there should be a `PackageInstall`for the "Carvel package installer" *Trait*.

With the kapp CLI, you can see which resources it has created in the *Space* namespace without the suffix.

```execute
APP_NAME=$(kapp list -n $SPACE_NS_INTERNAL --json | jq -r '.Tables[0].Rows[0].name')
kapp inspect -a $APP_NAME -n $SPACE_NS_INTERNAL
```

After you've created the *Space*, it's now time to deploy an example application to it to check whether everything works as expected.