---
title: Diving Deeper on Apps
---
In the last section, we called `tanzu app init` and it generated some configuration files for us. Let's take a look at those generated files.

First, in whatever directory you call `tanzu app init` from, a file will be generated in that directory called `tanzu.yml`. This file is a top-level configuration file that points to all the microservices you want to deploy for your application. 
In our case, we just have one application, but in the case of a monorepo with a lot of microservices, the `tanzu.yml` file can be created at the top of the monorepo, and then you can deploy from that top-level directory, without having to manually descend into each microservice subfolder.  

Let's open up the `tanzu.yml` file to explore how that configuration file is structured.
```editor:open-file
file: ~/inclusion/tanzu.yml
```

Notice the `configuration` section.
```editor:select-matching-text
file: ~/inclusion/tanzu.yml
text: "configuration"
before: 0
after: 3
```
You can see this section contains an array of paths, but has just one entry in it. And that path entry corresponds to the application configuration for the "inclusion" app we cloned.  
You could have multiple entries under the path section, each pointing to a different microservice.  Also, you could have multiple application configuration files at the path we have in our `tanzu.yml` file.

Now let's have a look at the configuration for our inclusion application, which is under the path specified in the `tanzu.yml` file.
```editor:open-file
file: ~/inclusion/.tanzu/config/inclusion.yml
```
Notice anything familiar in this file? 
It contains the name of the application, buildpack build type, and the path to our application's source code (relative to the inclusion.yaml file) that we specified on the `tanzu app init` command in the last section. 
It also contains some other information about the port the application is listening on. The platform assumes a default port of 8080, but you can change that port if your application listens on a different one by default.

This file looks like some kind of Kubernetes object manifest, but you don't have to edit it by hand. We can use the Tanzu CLI to change the configuration.
We can call `tanzu app config --help` to see some of the configurable options.
```execute
tanzu app config --help
```
For example, we could call (don't do this for real, please!) `tanzu app config build path set` to change the path to our source code, if we didn't have the right setting when we initialized the application earlier. 
We can also use the Tanzu CLI to set environment variables for the Cloud Native Buildpacks, and the application container when it runs.  

The default buildpack for Java applications in Tanzu Platform is the [Paketo](https://paketo.io/) Java Buildpack. That buildpack contains a builder that handles installing a JVM. We can have a look at the [documentation](https://paketo.io/docs/howto/java/#install-a-specific-jvm-version) to see that we need to set an environment variable for the build phase called `BP_JVM_VERSION` to the value of the Java Virtual Machine version we want to use in the container.  If we don't specify anything, the default Java Virtual Machine version is 17 and that is the version that will be installed for us.

 Let's set that to version 21 so we can take advantage of lower memory utilization and save some money!
```execute
tanzu app config build non-secret-env set BP_JVM_VERSION=21
```

If we have a look back at the `inclusion.yaml` file, we can see it was updated for us by the CLI with the value of 21 for the `BP_JVM_VERSION` build environment variable.
```editor:select-matching-text
file: ~/inclusion/.tanzu/config/inclusion.yml
text: "name: BP_JVM_VERSION"
before: 0
after: 1
```

We can also use `tanzu app config` to set environment variables that would be applied to the running application once it is deployed.  Let's turn up the logging for our application based on Spring Boot by specifying an application configuration property for logging via an environment variable.
```execute
tanzu app config non-secret-env set LOGGING_LEVEL_COM_EXAMPLE_EMOJIINCLUSION=DEBUG
```
Again, this change won't take effect until we deploy again, but you can see the configuration update in our application's manifest.
```editor:select-matching-text
file: ~/inclusion/.tanzu/config/inclusion.yml
text: "name: LOGGING_LEVEL_COM_EXAMPLE_EMOJIINCLUSION"
before: 0
after: 1
```

Remember, all we have done at this point is just update our on-disk configuration files.  We could make these changes take effect by building and deploying a new container for our application with the `tanzu deploy` command like we did at the begining of the workshop.

We can also break up that flow into **two separate steps** if we wish.  We can call a `tanzu build` and then deploy the built application with `tanzu deploy` without building it again. This can be extremely useful if we want to integrate this build process into our own CI pipeline tools.

Let's kick off just the build for our container in our second terminal window.
```terminal:execute
command: |
  cd inclusion
  tanzu build --output-dir ~/build
session: 2
```

You can see that `tanzu build` is invoking the Cloud Native Buildpacks, and you should be able to see in the output that version 21 of the Java Virtual Machine was installed instead of version 17.  The line in the output you are looking for contains the text `BellSoft Liberica JDK 21.0.3`.

We can also specify contact information about your application that is included with your deployment.  This information currently isn't used by the platform, but some of this information may be surfaced in the future.  It's a great way to communicate to application operators how to get in contact with the development team if they have questions or issues when deploying.

Adding contact information can be done with the `tanzu app contact set` command. The command allows you to specify arbitrary NAME=VALUE pairs to add whatever contact info you want that will travel along with your application as it is promoted through its lifecycle.  Let's add an email address contact record for our application.
```execute
tanzu app config contact set email=me@here.com
```

We can also add multiple entries and have the CLI prompt us for the information. Let's add *team* and *slack* entries to our contact info.  
You can enter arbitrary strings for each key.
```execute
tanzu app config contact set team slack
```

Let's have a peek back at our application configuration file to see how it has been modified with these additional values.
```editor:select-matching-text
file: ~/inclusion/.tanzu/config/inclusion.yml
text: "contact:"
before: 0
after: 3
```

We had a look at the Tanzu Platform UI earlier to get some details about our application. Let's use the CLI to do the same.  

First, let's get a list of the applications (just one, really!) running in our space.
```execute
tanzu app list
```
You can see in the output our `inclusion` application is deployed in our space. 

Let's get more details about our application. The Tanzu CLI supports **tab completion** for commands, and resource names. Let's use it to get details for our application without having to type the whole name.  Type the command below (or click the command), then **select to top terminal session, and press the TAB key**.  Once you see the name of your app autocompleted, then you can press **Enter**. 
```terminal:input
text: "tanzu app get "
endl: false
```

Notice in the output there is a "Source Image" listed. This is a container image that was built for our application by `tanzu build` and then pushed to the registry we specified back in the first section automatically. 

Also, notice that we see an environment variable set for our app, but we don't see the environment variable named `LOGGING_LEVEL_COM_EXAMPLE_EMOJIINCLUSION` that we set for logging earlier in this section.

Although we have built a new version of our application with those values set, we haven't deployed it to the platform yet.  We've only modified the configuration for the application locally. We can apply the updated container image and manifests now using a modified form of the `tanzu deploy` command.
```execute
tanzu deploy --from-build ~/build -y
```

Notice anything different about this flow?  We already had a built container image, so we didn't need to run that step again. We simply need to update the configurations in our space, and the platform will roll out our updates to our cluster. If we look at the details for our application again, we should see all the changes we had made are now applied to our running application.
```execute
tanzu app get inclusion
```

Fantastic!  We explored in more detail how the CLI manages on-disk configurations for our application, allows us to split up the build and deploy steps if desired, allows us to configure the way the container image is built, and allows us to set environment variables for the running application container.

An application is rarely solely made up of just your custom code.  Applications often need access to pre-built services like messaging servers, and databases.  In the next section, we'll explore how Tanzu Platform for Kubernetes makes it easy for you to use these types of services and others that your platform team and service providers have curated for you.