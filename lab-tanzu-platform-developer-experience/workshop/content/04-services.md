---
title: Services
---
19.  Introduce services.  `tanzu service` command to show things we can do with services.
```execute
tanzu service --help
```
20.  `tanzu service type list` to show available catalog of services.  Mention platform team can control this catalog and could potentially expose other types of services in the future (cloud provider, custom services, etc).
```execute
tanzu service type list
```
21.  `tanzu service create PostgreSQLInstance/my-db` to create a new service instance.
```execute
tanzu service create PostgreSQLInstance/my-db
```
22.  `tanzu service list` to see created services.
```execute
tanzu service list
```
23.  `tanzu service get PostgreSQLInstance/my-db` to get some details about our service.  Highlight the "type spec" and mention these are configurable items the platform team allows for these service types (like storageGB).  Mention we can specify those values using the `tanzu service create PostgreSQLInstance/my-db --parameter storageGB=??` format, but don't execute that.
```execute
tanzu service get PostgreSQLInstance/my-db
```
24.  `tanzu service bind PostgreSQLInstance/my-db ContainerApp/emoji-inclusion --as db`
```execute
tanzu service bind PostgreSQLInstance/my-db ContainerApp/inclusion --as db
```
25.  Refesh app tab and notice the service is now bound and the change to the emoji view.
26.  Explain how this service is only available for apps in this space to use directly.  We're going to switch to a "shared" database instance that has been pre-provisioned for us by rebinding our app to a secret.
    1.  Add a secret to the UCP with the shared DB credentials and coordinates called `shared-db`.
    2.  `tanzu service unbind PostgreSQLInstance/my-db ContainerApp/emoji-inclusion` to remove the binding.
    3.  `tanzu service bind Secret/shared-db ContainerApp/emoji-inclusion --as db` to bind to the shared instance.
    4.  Refresh the app and notice all the different emojis that start to show up.
27.  `tanzu service delete PostgreSQLInstance/my-db` to clean up the unneeded DB now.
```execute
tanzu service delete PostgreSQLInstance/my-db
```
28. `tanzu app config servicebinding set db=postgresql` to add metadata to ContainerApp about needed service bindings.  Open up `emoji-inclusion.yaml` to show how the "alias" is set to "db" and the allowable types is set only to "postgresql".  `tanzu service type list` again to show where that "postgresql" binding type is coming from.
