---
title: Services
---
It's fairly typical that an application relies on some externally managed resources like databases, OAuth servers, caches, messaging servers and others to run.  Tanzu Platform for Kubernetes provides a way for platform teams to consolidate all the services that have the best support in your organization into a single catalog, and enables application developers to consume those services by simply binding them to their applications.  Let's explore binding platform managed and externally managed services to our application.

All of the service management commands are grouped under the `tanzu service` catagory in the CLI.  Call the following command to see the types of operations you can perform.
```execute
tanzu service --help
```

We can use the Tanzu CLI to have a look at the catalog of service types our platform team and service providers have made available for us.  This list is a curated list, and could be sourced from in cluster deployments, cloud-provider SaaS services, or really anything.  The nice thing is that you don't have to care how those services are managed.  You can consume them all in the same way using the flow we'll go through next.  First, let's call the following CLI command to view the catalog of service types our platform has for us to use.
```execute
tanzu service type list
```

Our application can use Postgres databases, and our platform team has made that type of service available to us.  Let's create an instance of that service so that we can use it with our app.  The `tanzu service create TYPE/NAME` command allows us to create a service of a specified TYPE and give it the name of NAME.  Can see in the list of service types we have a type called `PostgreSQLInstance` that looks promising.  Let's create an instance of that called `my-db` with the following command.
```execute
tanzu service create PostgreSQLInstance/my-db
```

Great!  Now we can have a look at the list of services in our space.  We should only have the one we just created called `my-db`.
```execute
tanzu service list
```

We can get some details about our service by using the `tanzu service get` command.
```execute
tanzu service get PostgreSQLInstance/my-db
```

In the output we can see a section called `PostgreSQLInstance type spec`.  These values are configurable items that our platform team allows us to specify when we create the service.  These values have some defaults that are applied if we don't specify anything, but we can selectively chose different configurations if we need to.  For example, maybe we want to have a database that allows more than 1 GB of storage.  We could have called the create command like this (don't execute this) `tanzu service create PostgreSQLInstance/my-db --parameter storageGB=10` to have created a Postgres instance with 10GB of storage.  Each service type will have different configuration options exposed, so you might need to talk with your platform team to find out all the options.

At this point we have a Postgres database, but our app doesn't know anything about it.  We can change that by *binding* our database instance to our application.  Binding associates the instance of a service with an application, and injects information about that service using [Service Bindings for Kubernetes](https://servicebinding.io/).  The specification standardizes how service information is injected into workloads via a specific directory structure and files mounted into a container application.  [Many libraries](https://servicebinding.io/application-developer/) know how to interpret this standardized information, and some like [Steeltoe](https://docs.steeltoe.io/api/v3/connectors/) and [Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) can automatically inject configuration to make consuming those services very easy.

We're working with a Spring Boot application, and our platform team is using the [Spring Boot Cloud Native buildpack from Packeto](https://github.com/paketo-buildpacks/spring-boot) to automatically add the Spring Cloud Bindings library to our application library path.  This means that our database configuration will be automatically injected and beans will be automatically created to use the bound database when our application starts up.  Let's bind the service to our application.
```execute
tanzu service bind PostgreSQLInstance/my-db ContainerApp/inclusion --as db
```

Let's refresh our application and see that the emoji has now changed for our app.  You can go to https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application if you accidentally closed the tab for it.  Click on the "Space URL" link at the upper middle of the page.

The Postgres service we are using is provisioned using automation for us in the platform.  But what if we have a database that is managed by another team, or an existing database that we need to keep using?  Don't worry!  We can still use the service binding mechanism to simplify this process.  We're going to switch to a shared Postgres database that all the workshop attendees can use together.  And if we are careful about how e format the information for the binding, we can even still use the Spring Cloud Bindings library to automatically configure the application for us.

If we have a look at the [Postgres section in the Spring Cloud Bindings README.md](https://github.com/spring-cloud/spring-cloud-bindings?tab=readme-ov-file#postgresql-rdbms), we can see that we need to include a `username`, and `password` setting.  We then can either specify a `jdbc-url` setting or the `host`, `port`, `database` values.  We can optionally add in additional configuration with the `sslmode`, `sslrootcert`, and `options` values if we need to fine tune the connection.  Let's create a secret with the info to connect to the shared database.
```editor:append-lines-to-file
file: ~/inclusion/db-secret.yaml
description: Create a secret manifest for the shared database
text: |
    apiVersion: v1
    kind: Secret
    metadata:
        name: shared-postgres
    type: Opaque
    stringData:
        host: postgres-test-{{< param workshop_name >}}.{{< param ingress_domain >}}
        port: 5432
        database: postgres
        username: postgres
        password: {{< param DB_PASSWORD >}}
```

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
