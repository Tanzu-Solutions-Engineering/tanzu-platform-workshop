---
title: Workshop Summary
---

In this session, we explored the developer experience with Tanzu Platform and covered:
- Logging in to the platform
- Building an application with Cloud Native Buildpacks
- Deploying an application
- Mapping a public route to an application
- Creating and Binding a service to an application
- Scaling an application
- Viewing logs for application Instances

[Creating and Managing Applications on Tanzu Platform for Kubernetes](https://techdocs.broadcom.com/us/en/vmware-tanzu/platform/tanzu-platform/saas/tnz-platform/spaces-index.html)

{{< note >}}
Please don't forget to delete the automatically created Space now or as soon as you don't need it anymore.
{{< /note >}}
```execute
tanzu space delete {{< param  session_name >}} -y
```
