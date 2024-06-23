---
title: Scalability and Resiliency
---
![Image showing an application with specific memory and CPU settings, multiple container replicas, and distributed across multiple clusters](../images/vertical-replicas-multi-at.png)

Tanzu Platform for Kubernetes makes it simple to scale your application resources vertically and horizontally for performance and resilience. We'll explore the different options for scaling your applications.

First, let's have a look at our application details.
```execute
tanzu app get inclusion
```

Pay attention to the "Resources" section of the output. Notice how we have limits defined for CPU and memory?  We didn't set these so where did they come from? Tanzu Platform for Kubernetes has default resource limits for applications even if they didn't specify their own. This prevents applications from becoming greedy and starving other applications in the cluster of resources. But what if our application needs more memory and CPU to do its job properly? No problem! We can request more resources for our application, and the platform will schedule our application where its needs can best be met.

{{< note >}}
The units for memory are Megabytes, and the units for CPU are "[millicores](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu)."  Megabytes for memory probably make sense, but what are "millicores?"  With Tanzu Platform for Kubernetes, CPU cores are divided into 1000 pieces.  Your application can request 1/1000th of a CPU core as a minimum, or multiple cores.  If you needed only 1/2 of a CPU core, that would be "500m" or "500 millicores".  If you need a whole CPU core, that would be "1000m".  If you need 2 cores, that's "2000m".
{{< /note >}}


Let's vertically scale our application by requesting more CPU and memory resources to be allocated for our application container in the "on-disk" configuration for our application.
```execute
tanzu app config scale set cpu=400 memory=678
```

We can have a look at the change to our "on-disk" configuration to see the new section that was added.
```editor:select-matching-text
file: ~/inclusion/.tanzu/config/inclusion.yml
text: "resources:"
before: 0
after: 2
```

But when we look at the running application config again, we won't see these changes yet.
```execute
tanzu app get inclusion
```

We need to apply these "on-disk" changes to the running application.  We need to cause the installation values for our app to get regenerated and applied to the platform so we need to call the `tanzu deploy` command again.
```execute
tanzu deploy -y
```

Wait until the deployment is finished. When we look at the running application config again, we'll see our increased resources.
```execute
tanzu app get inclusion
```

Great! Our application now has some more CPU and memory to work with. However vertical scaling has its limits.  The machines that are actually running our applications have limited CPU and memory.  We can get around this limitation by horizontally scaling our application by adding more replicas of it running in each cluster. The great thing is that the platform will automatically handle splitting requests across both of our instances and check the health of each instance to determine if it can still handle requests.  Let's scale our application up to 2 replicas.
```execute
tanzu app config scale set replicas=2
```

Again, the previous command just changed the on-disk config, so we need to call the `tanzu deploy` command again to get the installation values regenerated and applied to the platform.
```execute
tanzu deploy -y
```

Wait until the deployment is finished.  When we look at the running application config again, we'll see the replica count is now 2.
```execute
tanzu app get inclusion
```

These vertical and horizontal scale configurations are now applied to the individual cluster your application is running on.  But we can get even _more_ resilience for our applications by having them scheduled across multiple clusters.  

Scheduling your application across multiple clusters is governed by the configuration of the space your application is part of.  If you look at https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/configuration, you will see your space configuration.  If you have a look at the "Space Scheduling" section, you will see the availability targets and replicas defined for your space.  These settings govern how many clusters your space is replicated to.

In our case, your platform engineers have given you a development space to use that has lower resilience than what is defined for production application spaces.  For production applications, platform engineers can have multiple clusters deployed in a single availability target, or spread your space across multiple availability targets and then your applications are distributed across those clusters.  Those availability targets could even span multiple clouds to achieve even higher resilience for your application.

{{< note >}}
Currently, multi-cluster scheduling works well for application containers but it doesn't automatically ensure that data replication is occurring for any data services your application might need to use.  If your application needs data to be replicated resiliently across targets today, your service operators will need to create a data service for you with those capabilities.

You may use a custom secret to inject credentials provided by your service operators for this external service into applications via service bindings as we covered in the services section of the workshop.
{{< /note >}}

So we've seen the multiple levels of scaling and resilience that are configurable for your application.  As an app developer, you can set the requested CPU, Memory and replicas to be provisioned within a single cluster for your application.  And platform engineers can specify how your application is scheduled across multiple clusters for cross-regional (and even cross-cloud!) resilience.