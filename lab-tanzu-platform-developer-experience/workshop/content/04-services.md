---
title: Services
---
![Image showing an application with an arrow representing a ServiceBinding to a Postgres Database](../images/services.png)

It's fairly typical that an application relies on some externally managed resources like databases, OAuth servers, caches, messaging servers and others to run.  Tanzu Platform for Kubernetes provides a way for platform teams to consolidate all the services that have the best support in your organization into a single catalog and enables application developers to consume those services by simply binding them to their applications.  

Let's explore binding platform-managed and externally-managed services to our application.

All of the service management commands are grouped under the `tanzu service` category in the CLI.  Call the following command to see the types of operations you can perform.
```execute
tanzu service --help
```

![Image showing a Space containing a list of service types](../images/service-type-list.png)

We can use the Tanzu CLI to have a look at the catalog of service types our platform team and service providers have made available for us.  This list is a curated list, and could be sourced from in cluster deployments, cloud-provider SaaS services, or really anything.  The nice thing is that you don't have to care how those services are managed.  You can consume them all in the same way using the flow we'll go through next.  

First, let's call the following CLI command to view the catalog of service types our platform has for us to use.
```execute
tanzu service type list
```

Our application can use PostgreSQL databases, and our platform team has made that type of service available to us.  Let's create an instance of that service so that we can use it with our app.  The `tanzu service create TYPE/NAME` command allows us to create a service of a specified TYPE and give it the name of NAME.  As you can see in the list of service types, we have a type called `PostgreSQLInstance` that looks promising.  Let's create an instance of that called `my-db` with the following command.
```execute
tanzu service create PostgreSQLInstance/my-db
```

The CLI will prompt you for any additional configuration settings available for that service type.  In the case of our Postgres service, we can see that we're allowed to configure the storage size for the DB.  Since we don't need a lot of storage, we'll just leave the settings at defaults by opting to just finish the configuration.  Press `Enter` or click the section below to accept the defaults.
```terminal:execute
description: Accept default service parameters
command: ""
```

The CLI will also prompt you to automatically bind the service to an app.  Let's skip that step for now and come back to that in a bit by answering `N` to the prompt, or clicking the section below.
```terminal:execute
description: Don't bind the service yet
command: "N"
```

You can get a listing of the possible parameters for a service type before creating it.  The `tanzu service type get ...` command will give you more details about that service.  Let's investigate the Postgres service type.
```execute
tanzu service type get PostgreSQLInstance
```

In the output, you can see `storageGB` parameter we were prompted for earlier, and some details about it.  These values are configurable items that our platform team allows us to specify when we create the service. These values have some defaults that are applied if we don't specify anything, but we can selectively choose different configurations if we need to.  You can either let the CLI prompt you for these parameters, as we saw earlier, or you can pass in these parameters from the command line via the `--parameter` 

Great we have now created our own, small Postgres instance to work with! Now we can have a look at the list of services in our space. We should only have the one we just created called `my-db`.
```execute
tanzu service list
```

We can get some details about our service by using the `tanzu service get` command.
```execute
tanzu service get PostgreSQLInstance/my-db
```

In the output, we can see a section called `PostgreSQLInstance type spec`.  Since we didn't override the defaults, you can see that `storageGB` is `1` for our service.    

![Image showing a Service binding connected to an application and Postgres service and a set of secret values getting injected into the application](../images/service-binding.png)

At this point, we have a PostgreSQL database, but our app doesn't know anything about it. We can change that by *binding* our database instance to our application. Binding associates the instance of a service with an application, and injects information about that service using [Service Bindings for Kubernetes](https://servicebinding.io/).  The specification standardizes how service information is injected into workloads via a specific directory structure and files mounted into a container application.

[Many libraries](https://servicebinding.io/application-developer/) know how to interpret this standardized information, and some like [Steeltoe](https://docs.steeltoe.io/api/v3/connectors/) and [Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) can automatically inject configuration to make consuming those services very easy.

We're working with a Spring Boot application, and our platform team is using the [Spring Boot Cloud Native Buildpack from Packeto](https://github.com/paketo-buildpacks/spring-boot) to automatically add the Spring Cloud Bindings library to our application library path.  This means that our database configuration will be automatically injected and beans will be automatically created to use the bound database when our application starts up. Let's bind the service to our application.
```execute
tanzu service bind PostgreSQLInstance/my-db ContainerApp/inclusion --as db
```

Let's refresh our application and see that the emoji and the text in the header have changed for our app (from "powered by H2" to "powered by POSTGRESQL"). ![Image showing change to Inclusion app to show "powered by PostgreSQL" instead of "powered by H2"](../images/inclusion-postgres-binding.png)

If you don't see a change immediately, retry after waiting for 1 minute or so.  Changes to the application are rolled out gracefully, and load is not shifted to the new version of your application until it is healthy.  You can go to https://www.platform.tanzu.broadcom.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application if you accidentally closed the tab for it.  Click on the "Space URL" link at the upper middle of the page.

![Image showing a Service binding connected to an application and PreProvisonedService object and a set of secret values getting injected into the application.  The application is shown connected to an externally managed Postgres database](../images/preprovisioned-service.png)

The PostgreSQL service we are using is provisioned using automation for us in the platform. But what if we have a database that is managed by another team, or an existing database that we need to keep using? Don't worry! We can still use the service binding mechanism to simplify this process. We're going to switch to a shared PostgreSQL database that all the workshop attendees can use together.  To do that, we're going to create a `PreProvisionedService` type service.

If we have a look at the [PostgreSQL section in the Spring Cloud Bindings README.md](https://github.com/spring-cloud/spring-cloud-bindings?tab=readme-ov-file#postgresql-rdbms), we can see that it has a number of parameters that it looks for in a service binding including `username`, `password`, `host`, `port`, `database` values.  We can optionally add in additional configuration with the `sslmode`, `sslrootcert`, and `options` values if we need to fine-tune the connection.  Luckily, the Tanzu Platform already understands these common service types and the expected parameters so we don't have to look them up.

Let's create a `PreProvisionedService` to connect to the shared database.  First, let's start the creation process by executing the command below by clicking on that section.
```execute
tanzu service create PreProvisionedService/shared-postgres
```

The CLI will begin prompting us for all the information we need to provide.  Since we passed in the name for the service on the command-line, we can just accept the `Name` value as the default.  Click the section below or press `Enter` in the terminal to continue.

```terminal:execute
description: Accept default service name
command: ""
```

Next, you are prompted to enter a description.  You can click the section below to enter a description, or provide your own and press `Enter` in the terminal.
```execute
A shared PostgreSQL database for all workshop attendees.
```

Next, the CLI will prompt you to enter any contact info that others can use to contact you or your team if they have questions about the service.  Let's say we can be contacted by email by clicking the section below.
```execute
email
```

And then we can provide an email address by clicking the next section.
```execute
me@here.com
```

Next, `PreProvisionedService`'s allow you to specify multiple "Binding Connectors".  Binding connectors allow you to specify multiple sets of values that applications can be bound to.  One example is that you might need to specify one set of values for applications that have full read-write access to a database, and a different set for applications that only need read-only access.  In our case, we'll just use a single "Binding Connector", and we'll accept the default name of `main`.  Click the section below to accept that default connector name.
```terminal:execute
description: Accept default binding connector name
command: ""
```

Now, we need to specify the type of service binding that we're going to describe.We want to let Spring Cloud Bindings consider this service to be a Postgres DB type service, so we'll type `postgresql` to filter the list to the correct binding type, and then press `Enter`.  Click the section below to do that automatically.
```execute
postgresql
```
{{< note >}}
The `type` of a service binding is specified in the [Service Binding specification](https://github.com/servicebinding/spec?tab=readme-ov-file#provisioned-service) and is used by the Spring Cloud Bindings library to detect which type of data service the credentials are for.  The Service Binding specification doesn't specify any specific types as part of the standard, but there are some well known values that libraries like [Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) use.  If you specify your own, custom binding type string you would need to either provide plugins to your particular library to handle that binding, or manually parse that binding information in your application.
{{< /note >}}

Now, we're entering the home stretch!  We now need to supply all the values for the connection details to our shared Postgres DB.  Click each section **making sure that all sections turn to green**.
```terminal:execute
description: Select the "host" key
command: host
```
```terminal:execute
description: Enter the "host" value
command: postgres-test-{{< param environment_name >}}.{{< param ingress_domain >}}
```
```terminal:execute
description: Enter the "port" key
command: port
```
```terminal:execute
description: Enter the "port" value
command: 5432
```
```terminal:execute
description: Enter the "database" key
command: database
```
```terminal:execute
description: Enter the "database" value
command: postgres
```
```terminal:execute
description: Enter the "username" key
command: username
```
```terminal:execute
description: Enter the "username" value
command: postgres
```
```terminal:execute
description: Enter the "password" key
command: password
```
```terminal:execute
description: Enter the "password" value
command: {{< param DB_PASSWORD >}}
```

Validate once more that all the sections above that were entering the various values for the binding are green.  Now we can press the `Enter` key to finish out the configuration.
```terminal:execute
description: Finish PreProvisionedService configuration
command: ""
```

One final thing the platform will prompt for is to ask if you want to automatically configure EgressPoints for the service binding.  EgressPoints allow you to specify the connections your application needs outside of the cluster that it is running on.  This enables your space to have a "deny by default" posture for external connections, but easily enables developers and app operators to specify external services the applications should be allowed to connect to.  Let's select yes by entering `y` and pressing `Enter` by clicking the section below.
```execute
y
```
Then, we need to enter the host name of our shared Postgres DB again.
```execute
postgres-test-{{< param environment_name >}}.{{< param ingress_domain >}}
```

This is a `TCP` type connection, so let's select that.
```execute
TCP
```

And finally, we need to specify the port for our database server.
```execute
5432
```

As before, let's skip binding the service to our app just yet by entering `N` or clicking the section below when the CLI prompts us to bind.
```terminal:execute
description: Don't bind the service yet
command: 'N'
```

We now have all the information needed for our application to bind to the external Postgres DB and we've made sure we communicated to the platform that we need to be able to make a network connection to this external service.  Let's unbind our application from the small database we provisioned before so that we can bind to the shared database.
```execute
tanzu service unbind PostgreSQLInstance/my-db ContainerApp/inclusion
```

And to help preserve resources, let's delete that small database instance since we won't need it anymore.
```execute
tanzu service delete PostgreSQLInstance/my-db
```

Now, we can bind our application to the secret of the shared database we applied to our space.
```execute
tanzu service bind PreProvisionedService/shared-postgres ContainerApp/inclusion --as db
```

Great! The platform will restart our application to get it to pick up on the new binding. Let's refresh our application and see that the emoji has changed again for our app.  And as other users use the shared database, you'll start to see more emojis show up. You can go to https://www.platform.tanzu.broadcom.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application if you accidentally closed the tab for it. Click on the "Space URL" link at the upper middle of the page.

Remember in the section where we dove deeper into the application configuration and added contact metadata to our app?  We can also add information for application operators who need to deploy our app to other environments about the service bindings our application supports.  We can use `tanzu app config servicebinding` command to add information about the name of the binding and the types of services we support. First, let's display the service catalog on our platform again.

```execute
tanzu service type list
```

Notice that the output shows a `TYPE` column and a `BINDING TYPE` column.  We want to make sure to specify the value of the `BINDING TYPE` for the `TYPE` of service we allow.  So, since we support the `PostgreSQLInstance` service type, we'll want to specify `postgresql` in our `tanzu app config servicebinding` command.  Let's add a service binding reference with the alias `db` and binding type of `postgresql` to our application configuration.
```execute
tanzu app config servicebinding set db=postgresql
```

Now, have a look at the `inclusion/.tanzu/config/inclusion.yml` file to see the new binding reference.
```editor:select-matching-text
file: ~/inclusion/.tanzu/config/inclusion.yml
text: "  - name: db"
before: 0
after: 2
```
We can see the reference to our accepted service binding!  If our application supports multiple types of databases, we could add more types to the yaml file directly, or we can call the `tanzu app config servicebinding set db=<new-type>` command again replacing the `<new-type>` text with the additional binding type we support.

Fantastic!  We were able to create a PostgreSQL service instance for our application that has all the policies and best practices defined for our environment and delete the database when we didn't need it anymore.  We were also able to inject information about that service into our application using service bindings and remove the binding when we no longer needed it. We were able to add an externally managed service via a Secret and bind that information into our application.  We were also able to add information about the bindings and types our application supports for application operators that deploy our application to other environments.  And we were able to do all that with no code changes to our application!

Let's move on to explore scaling our application with Tanzu Platform for Kubernetes.