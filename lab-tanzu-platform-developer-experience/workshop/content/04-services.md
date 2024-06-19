---
title: Services
---
It's fairly typical that an application relies on some externally managed resources like databases, OAuth servers, caches, messaging servers and others to run.  
Tanzu Platform for Kubernetes provides a way for platform teams to consolidate all the services that have the best support in your organization into a single catalog and enables application developers to consume those services by simply binding them to their applications.  

Let's explore binding platform-managed and externally-managed services to our application.

All of the service management commands are grouped under the `tanzu service` category in the CLI.  Call the following command to see the types of operations you can perform.
```execute
tanzu service --help
```

We can use the Tanzu CLI to have a look at the catalog of service types our platform team and service providers have made available for us.  
This list is a curated list, and could be sourced from in cluster deployments, cloud-provider SaaS services, or really anything.  The nice thing is that you don't have to care how those services are managed.  You can consume them all in the same way using the flow we'll go through next.  

First, let's call the following CLI command to view the catalog of service types our platform has for us to use.
```execute
tanzu service type list
```

Our application can use PostgreSQL databases, and our platform team has made that type of service available to us.  
Let's create an instance of that service so that we can use it with our app.  The `tanzu service create TYPE/NAME` command allows us to create a service of a specified TYPE and give it the name of NAME.  
As you can see in the list of service types, we have a type called `PostgreSQLInstance` that looks promising.  
Let's create an instance of that called `my-db` with the following command.
```execute
tanzu service create PostgreSQLInstance/my-db
```

Great! Now we can have a look at the list of services in our space. We should only have the one we just created called `my-db`.
```execute
tanzu service list
```

We can get some details about our service by using the `tanzu service get` command.
```execute
tanzu service get PostgreSQLInstance/my-db
```

In the output, we can see a section called `PostgreSQLInstance type spec`.  These values are configurable items that our platform team allows us to specify when we create the service. These values have some defaults that are applied if we don't specify anything, but we can selectively choose different configurations if we need to.  
For example, maybe we want to have a database that allows more than 1 GB of storage. We could have called the create command like this (don't execute this) `tanzu service create PostgreSQLInstance/my-db --parameter storageGB=10` to have created a PostgreSQL instance with 10GB of storage. Each service type will have different configuration options exposed, so you might need to talk with your platform team to find out all the options.

At this point, we have a PostgreSQL database, but our app doesn't know anything about it. We can change that by *binding* our database instance to our application. Binding associates the instance of a service with an application, and injects information about that service using [Service Bindings for Kubernetes](https://servicebinding.io/).  
The specification standardizes how service information is injected into workloads via a specific directory structure and files mounted into a container application.  
[Many libraries](https://servicebinding.io/application-developer/) know how to interpret this standardized information, and some like [Steeltoe](https://docs.steeltoe.io/api/v3/connectors/) and [Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) can automatically inject configuration to make consuming those services very easy.

We're working with a Spring Boot application, and our platform team is using the [Spring Boot Cloud Native Buildpack from Packeto](https://github.com/paketo-buildpacks/spring-boot) to automatically add the Spring Cloud Bindings library to our application library path.  
This means that our database configuration will be automatically injected and beans will be automatically created to use the bound database when our application starts up. Let's bind the service to our application.
```execute
tanzu service bind PostgreSQLInstance/my-db ContainerApp/inclusion --as db
```

Let's refresh our application and see that the emoji and the text in the header have changed for our app (from "powered by H2" to "powered by POSTGRESQL").  You can go to https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application if you accidentally closed the tab for it.  
Click on the "Space URL" link at the upper middle of the page.

The PostgreSQL service we are using is provisioned using automation for us in the platform. But what if we have a database that is managed by another team, or an existing database that we need to keep using? Don't worry! We can still use the service binding mechanism to simplify this process. We're going to switch to a shared PostgreSQL database that all the workshop attendees can use together.
If we are careful about how we format the information for the binding, we can even still use the Spring Cloud Bindings library to automatically configure the application for us.

If we have a look at the [PostgreSQL section in the Spring Cloud Bindings README.md](https://github.com/spring-cloud/spring-cloud-bindings?tab=readme-ov-file#postgresql-rdbms), we can see that we need to include a `username`, and `password` setting.  We then can either specify a `jdbc-url` setting or the `host`, `port`, `database` values.  We can optionally add in additional configuration with the `sslmode`, `sslrootcert`, and `options` values if we need to fine-tune the connection. 

Let's create a secret with the info to connect to the shared database.
```editor:append-lines-to-file
file: ~/inclusion/.tanzu/config/preprovisioned-db-secret.yaml
description: Create a secret manifest for the shared database
text: |
    apiVersion: v1
    kind: Secret
    metadata:
        name: shared-postgres
    type: servicebinding.io/postgresql
    stringData:
        type: postgresql
        host: postgres-test-{{< param environment_name >}}.{{< param ingress_domain >}}
        port: "5432"
        database: postgres
        username: postgres
        password: {{< param DB_PASSWORD >}}
        provider: oss-helm
```
{{< note >}}
Both `type` and `provider` entries are part of the [ServiceBinding specification](https://github.com/servicebinding/spec?tab=readme-ov-file#provisioned-service) and are used by the Spring Cloud Bindings library to detect for which type of data service the credentials are.
{{< /note >}}

To bind our application to this secret, we have to configure an additional resource of type [`PreProvisionedService`](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/concepts-about-services.html#pre-provisioned-service) that enables applications within a Space to access services that have been pre-provisioned outside of that Space.
A reference to our Secret is configured as a Binding Connector which allows us to define multiple endpoints for a service, e.g. for a database that provides dedicated endpoints for read-write and read-only access.
```editor:append-lines-to-file
file: ~/inclusion/.tanzu/config/preprovisioned-db.yaml
description: Create a PreProvisionedService resource configuration
text: |
    apiVersion: services.tanzu.vmware.com/v1
    kind: PreProvisionedService
    metadata:
        name: shared-postgres
    spec:
        bindingConnectors:
        - name: read-write
          description: Read-write available in all availability targets
          type: postgres
          secretRef:
            name: shared-postgres
```

Now, we could apply those additional resources via `tanzu deploy --from-build ~/build`, but as for any other resources, we can also directly interact with the so-called Tanzu Platform Universal Control Plane (or UCP) via kubectl.
This is possible thanks to the [kcp project](https://github.com/kcp-dev/kcp), a Kubernetes-like control plane, UCP is based on.

We're able to do this because we've pointed out `KUBE_CONFIG` environment variable in this session to the config file managed by the Tanzu CLI for its use to talk to Tanzu Platform. Tanzu Platform's Spaces are _not_ defined in Kubernetes cluster themselves, but they use the Kubernetes resource model (CRDs, objects, etc) to manage deployments to Availability Target clusters which _are_ real Kubernetes clusters. Our platform engineering team can control what resources we can apply to our Space, and we've been allowed to apply Kubernetes-style *Secret* objects.  Let's apply the secret to our space.
```execute
kubectl apply -f ~/inclusion/.tanzu/config/
```

{{< note >}}
The requirement of having to apply a _Secret_ to your space manually will likely change in subsequent releases of the Tanzu Platform for Kubernetes. The intent is to give developers support in the CLI to automate the creation of these externally managed services without having to understand what a Kubernetes Secret is.
{{< /note >}}

Now, let's unbind our application from the small database we provisioned before so that we can bind to the shared database.
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

Great! The platform will restart our application to get it to pick up on the new binding. Let's refresh our application and see that the emoji has changed again for our app.  And as other users use the shared database, you'll start to see more emojis show up. You can go to https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application if you accidentally closed the tab for it. Click on the "Space URL" link at the upper middle of the page.

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