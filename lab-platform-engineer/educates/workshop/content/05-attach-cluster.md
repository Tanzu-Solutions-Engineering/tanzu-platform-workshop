---
title: Add a Kubernetes Cluster for Workloads to the Cluster Group
---

Tanzu Platform for Kubernetes currently provides **full lifecycle management** and support for 
- Tanzu Kubernetes Grid Service clusters running in vSphere with Tanzu
- AWS EKS clusters
The documentation is available [here](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-clusters.html)

Other Kubernetes distributions are not supported yet, which doesn't mean that Tanzu Platform for Kubernetes isn't working with them.

**For this workshop, we will use a [virtual Kubernetes cluster](https://www.vcluster.com/) that is already provisioned for you.**

```terminal:execute
description: Ensure Kubernetes context is set for workload cluster
command: unset KUBECONFIG && kubectl ctx $(yq eval '.current-context' vcluster-kubeconfig.yaml)
```
```execute
kubectl get nodes
kubectl get pods -A
```

As this cluster is not managed by Tanzu Platform for Kubernetes, we have to attach it as a self-managed cluster.

# Attach workload cluster 
## Option 1: Tanzu Platform GUI

In the Tanzu Platform GUI navigate to `Infrastructure > Kubernetes Clusters` and select your "{{< param  session_name >}}" *Cluster Group*. 

Click on the **Add Cluster** button, and select the **Attach self-managed cluster** option.

Set the **workshop session name** as the **name of the cluster**, and the ***Cluster Group***.
```copy
{{< param  session_name >}}
```

Add a **label** with the **key "workshop-session"** and **value "{{< param  session_name >}}" (the workshop session name)**. This label will be important for the configuration of the `Availability Target`.

Click **Next**, **copy the command** to install the cluster agent extensions in the workload cluster, and **run the command in the workshop's upper terminal**.

To verify whether the cluster is successfully onboarded to Tanzu Platform for Kubernetes, you can switch back to Tanzu Platform GUI, click (multiple times) on the **Verify connection** button which will also enable the **View your cluster** button.

## Option 2: tanzu CLI
To attach our workload cluster to Tanzu Platform for Kubernetes via the tanzu CLI, we first have to create a template file with the required configuration.
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
As you can see, we are setting the name of cluster like for the `Cluster Group` to our workshop session. We also add a **label** with the key "workshop-session" and the workshop session name as a value. This label will be important for the configuration of the `Availability Target`.

The following command will, based on the configuration in the template file, attach our workload cluster to Tanzu Platform for Kubernetes by installing cluster agent extensions into it.
```execute
tanzu operations cluster attach --file cluster-attach-values.yaml --kubeconfig vcluster-kubeconfig.yaml --skip-verify
```

To verify whether the cluster is successfully onboarded to Tanzu Platform for Kubernetes, you can run the following command (or use to Tanzu Platform GUI).
```execute
tanzu operations cluster get {{< param  session_name >}} --cluster-type attached
```

{{< note >}}
It could take some time until the workload cluster is successfully onboarded. Just rerun the `tanzu operations cluster get` command until this is the case.
{{< /note >}}

# Check whether Capabilities defined in Cluster Group are provided by the Cluster
You can run the following command to get all `PackageInstalls`, which is the underlying way of installing *Capabilities*.
```execute
kubectl get packageinstalls.packaging.carvel.dev -A
```

{{< note >}}
It could take some time until the `PackageInstalls` are synced to the cluster and reconciled. Just rerun the command until this is the case.
{{< /note >}}

For the `PackageInstall` of our **Container App** *Capability*, the description should be `Reconcile succeeded` if it was successfully installed.
```execute
kubectl get packageinstalls.packaging.carvel.dev container-apps.tanzu.vmware.com -n tanzu-cluster-group-system
```

With the [kapp CLI](https://carvel.dev/kapp/), we can easily see which Kubernetes resources the package has installed on our cluster.
```execute
kapp inspect -a container-apps.tanzu.vmware.com.app -n tanzu-cluster-group-system
```
