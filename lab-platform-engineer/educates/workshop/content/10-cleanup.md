---
title:  Cleanup
---

Now that we've finished testing, we can remove the *Space* and other resources we created for our sample application.

```execute
tanzu space delete {{< param  session_name >}}-s
tanzu availability-target delete {{< param  session_name >}}-at
tanzu profile delete {{< param  session_name >}}-p
```

Let's also remove our cluster from the platform, as it was temporary for use with this workshop.
```execute
tanzu operations cluster delete {{< param  session_name >}} --cluster-type attached --management-cluster-name attached --provisioner-name attached
```

Finally, we can delete the whole cluster group that we created for this workshop since we don't need it anymore.
```execute
tanzu operations clustergroup delete {{< param  session_name >}}-cg
```

