---
title:  Cleanup
---

Now that we've finished testing, we can remove the *Space* and other resources we created for our sample application.

{{< note >}}
It could take some time until the resources are finally deleted. So just rerun the commands until their preconditions are fulfilled and they succeed.
{{< /note >}}

```execute
tanzu space delete {{< param  session_name >}}-s -y
```
```execute
tanzu availability-target delete {{< param  session_name >}}-at -y
```
```execute
tanzu profile delete {{< param  session_name >}}-p -y
```

Let's also remove our cluster from the platform, as it was temporary for use with this workshop.
```execute
tanzu operations cluster delete {{< param  session_name >}} --cluster-type attached --management-cluster-name attached --provisioner-name attached
```

Finally, we can delete the whole cluster group that we created for this workshop since we don't need it anymore.
```execute
tanzu operations clustergroup delete {{< param  session_name >}}-cg
```

