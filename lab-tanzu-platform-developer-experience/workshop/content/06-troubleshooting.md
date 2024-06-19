---
title: Troubleshooting
---
{{< note >}}
Troubleshooting and debugging is an area of the platform undergoing changes and enhancement, and so the process detailed in this section is a workaround until changes stabilize.  Today, what you can see from the platform about the running application is limited, but R&D has plans to add in metric and log viewing from the platform UI, live debugging for running applications, and other troubleshooting features.
{{< /note >}}

If your application is having trouble, we can access the cluster hosting your application to view its logs.  To do this, we need to determine which cluster or clusters your application is running on.  To do that, we can find the Availability Targets defined for your space, and then examine what clusters are matched for that Availability Target.

First, let's view the configuration for your space.
```execute
tanzu space get {{< param  session_name >}}
```

In the output, we can see the names of the availabilty targets for your space.  As a developer, you might not be able to see what specific clusters your application is running on or you may not be allowed to access those clusters directly.  In our environment our platform team has given us the ability to access the clusters our application is running on for troubleshooting purposes.  To access the logs for our application, we'll need to get a Kubernetes configuration file and use that to access our cluster.  Because our clusters are registered with Tanzu Platform, we can use our access rights in Tanzu Platform to access the clusters.

Click on this command to download a Kubernetes config file for our cluster.
```execute
AT_NAME=$(tanzu space get {{< param  session_name >}} -o json | jq -r ".status.availabilityTargets[0].name")
CLUSTER_NAME=$(tanzu availability-target get $AT_NAME -o json | jq -r ".status.clusters[0].name")
tanzu operations cluster kubeconfig get $CLUSTER_NAME -t eks > $HOME/at-cluster-kube.config
```

We could have instead navigated to the Tanzu Platform UI, and go to the "Infrastructure" -> "Kubernetes Clusters" section, and then choose the "Clusters" tab to view the clusters we have access to.  Then we could click on the name of the cluster we want to access, and then click on the "Actions" button in the upper right side of the window, and choose "Access this cluster".  That would allow us to download a Kubernetes config file to access our cluster.

We also don't know what the namespace is for our application since the platform manages all that for us.  We'll execute the following command to get the namespace.
```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
MANAGED_NAMESPACE=$(KUBECONFIG=$HOME/.config/tanzu/kube/config k get ManagedNamespace -l spaces.tanzu.vmware.com/space-name={{< param  session_name >}} -o json | jq -r ".items[0].status.placement.namespace")
tanzu space use {{< param  session_name >}}
```

Now that we have a Kubernetes configuration file to access our cluster, we can view the logs for our application.
```execute
kubectl --kubeconfig $HOME/at-cluster-kube.config logs deployment/inclusion -n $MANAGED_NAMESPACE
```

And we can stop viewing the logs by pressing Ctrl-C.
```execute
<ctrl+c>
```

Let's view a summary of what we've covered in the next section.