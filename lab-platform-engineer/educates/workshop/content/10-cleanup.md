---
title: Remove Cluster and Group
---

Now that we've finished testing, we can remove the space we created for our sample application.

```execute
tanzu space delete {{< param  session_name >}}
```

Let's also remove our cluster from the platform, as it was temporary for use with this workshop.
```execute
tanzu operations cluster delete {{< param  session_name >}} --cluster-type attached --management-cluster-name attached --provisioner-name attached
```

Finally, we can delete the whole cluster group that we created for this workshop since we don't need it any more.
```execute
tanzu operations clustergroup delete {{< param  session_name >}}
```

