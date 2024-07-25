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

## Option 2: tanzu CLI
It's possible to create a *Space* with the tanzu CLI, but unfortunately, it's not possible to configure the replicas for an *Availability Target* (see Tanzu Platform GUI option for more details).
For this workshop, the defaults are fine, so it's not a restriction for us.

Let's also use the session name as a name for our *Space*, and specify our *Profile* and *Availability Target*.
```execute
tanzu space create {{< param  session_name >}} --profile {{< param  session_name >}} --availability-target {{< param  session_name >}}
```

We can also check whether the *Space* is ready with the tanzu CLI. It may take some time, and the space can be also be in warning or error state for some time.
```execute
tanzu space get {{< param  session_name >}}
```

## Option 3: kubectl CLI
To create a *Space* with the kubectl CLI, we have to create a resource file with all the configurations*.
```editor:append-lines-to-file
file: ~/space.yaml
description: Add space resource file
text: |
  apiVersion: spaces.tanzu.vmware.com/v1alpha1
  kind: Space
  metadata:
    name: {{< param  session_name >}}
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
As you can see, we also use the session name as a name for our *Space*, and specify our *Profile* and *Availability Target*.

As a next step, we can apply the resource to UCP.
```
export KUBECONFIG=~/.config/tanzu/kube/config
kubectl apply -f space.yaml
kubectl get spaces.spaces.tanzu.vmware.com {{< param  session_name >}} -o yaml
unset KUBECONFIG  
```

After you've created the *Space*, it's now time to deploy an example application to it to check whether everything works as expected.

# Check Space setup on the workload cluster
**TODO**