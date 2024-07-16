---
title: Deploy our First App
---
![Image showing an App deployed to a Space](../images/deploy-an-app.png)

Now that we have the CLI configured, let's get our first app running on Tanzu Platform.

We'll be using a sample application to go through the workshop.  Let's clone the project into our workshop environment.
```execute
git clone https://github.com/timosalm/emoji-inclusion inclusion
```

Now, we need to add some configuration so that the platform understands the name, and location of the source code of our application.  We'll first change directories to the app we just cloned.
```execute
cd inclusion
```

Next, we'll use the `tanzu app init` command to add the default configuration for our application.
```execute
tanzu app init
```
With no parameters, the `tanzu app init` command prompts us for the key bits of information it needs. 
First, the name of the app, which defaults to the name of the directory we're running the command from, and you can accept the default by pressing enter.
```terminal:execute
description: Accept default application name
command: ""
```

Next, the location of our application's source code, which is in our case the current directory, and the default.
```terminal:execute
description: Confirm default application source directory
command: ""
```

Finally, our platform team has configured Cloud Native Buildpacks as the only build option for our platform, so let's accept that as our build type by pressing enter.
```terminal:execute
description: Confirm Cloud Native Buildpacks as build type
command: ""
```

As the default Java version of our commercial Java Cloud Native Buildpack is 11, but our application requires version 17 as a minimum, let's configure the CNB accordingly. 
```terminal:execute
command: tanzu app config build non-secret-env set BP_JVM_VERSION=17
```

We could have also specified all these values as parameters to the `tanzu app init` call. Look at the help output for the command to see the options you can specify.
```execute
tanzu app init --help
```

We can also add manifests for resources that will be deployed along with our application. Since we want to be able to access our application externally to the cluster it is deployed on, let's create a manifest for a resource that will expose our application to the outside world.

```editor:append-lines-to-file
file: ~/inclusion/.tanzu/config/httproute.yaml
description: Add HTTPRoute resource
text: |
    apiVersion: gateway.networking.k8s.io/v1beta1
    kind: HTTPRoute
    metadata:
      name: inclusion-route
      annotations:
        healthcheck.gslb.tanzu.vmware.com/service: inclusion
        healthcheck.gslb.tanzu.vmware.com/path: /actuator/health
        healthcheck.gslb.tanzu.vmware.com/port: "8080"
    spec:
      parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: default-gateway
        sectionName: http-{{< param  session_name >}}-inclusion
      rules:
      - backendRefs:
        - group: ""
          kind: Service
          name: inclusion
          port: 8080
          weight: 1
        matches:
        - path:
            type: PathPrefix
            value: /
```

{{< note >}}
Adding an external ingress to your application in this way is not the planned future for route management. Eventually, the platform will support CLI commands to create and map routes to applications. This step is necessary until the platform has first-class support for route management.
{{< /note >}}

Now, let's deploy our application.
```execute
tanzu deploy -y
```

The container build will take a couple of minutes, so just wait until the process completes.  Monitor the output of the build process to see if you can see how `tanzu build` is leveraging both Cloud Native Buildpacks and running additional automations to generate configurations specific to our Spring Boot application.  

We can see that the Cloud Native Buildpacks for Java and Spring are being used to create a container image with best practices for our application.  It's first analyzing our application to determine the appropriate buildpacks to apply.  That phase is looking for build files, source code, and other markers to indicate what types of technologies our project is using.  You can see that there are lots of buildpacks in our platform, but only relevant ones are getting applied to our container build.  You can see a buildpack pulling in the Liberica JDK (version 17) to compile our app but a JRE to actually run our application.  You can see `tanzu build` is pulling in a layer to inject best practices for building containers for Spring Boot applications, and a memory calculator to properly size the memory for the application based on it's container settings.  It's also generating a [Software Bill of Materials or SBoM](https://www.cisa.gov/sbom) for your application and storing it with the container image.

After the container image for our app is built, you can see `tanzu build` is going beyond just building the container.  It's also generating Kubernetes manifests to run our application on Kubernetes the way our Platform Engineers and DevOps teams want us to run them.  It's adding specific environment variables to the application manifest to enable Spring Boot actuator capabilities at runtime, and point Kubernetes health and readiness checks at those actuators.  It's bundling up all the manifests as a [Carvel Package](https://carvel.dev/kapp-controller/docs/latest/packaging/#package) that enables application operators to deliver that application consistently across multiple (even disconnected!) environments.  Finally, it's storing the container image and that Carvel Package in the container registry we configured back in the first section of this workshop.

![Image showing a screenshot of the Inclusion app in the Tanzu Platform UI](../images/tanzu-platform-screenshot.png)

{{< note >}}
If you get a "Space not found error when you click the link below, make sure you have the {{< param TANZU_PLATFORM_PROJECT >}} project selected in the dropdown list right next to the "Tanzu Platform" logo in the upper left of the browser window.
{{< /note >}}

Once the deployment is completed, you can navigate to https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see information about your deployed application.  

The *Applications* tab shows a list of all the application services we have deployed to our space. You can click on the name of the "inclusion" application to see some more details about the application. That view will be sparse for now, but we'll look at it again when we work with services later on.  

Explore the *Ingress & Egress* tab and click the chevron next to your application hostname in the *Ingress* list.  You can see some information about the route we currently have mapped to the application.

{{< note >}}
Your application might take a minute to start up, become healthy and for the app DNS record to propagate to your workstation's DNS servers. If the URL for your app that you get from Tanzu Platform below doesn't work immediately, give it a minute and try again.
{{< /note >}}

Notice that "Space URL" value in the upper middle of the Tanzu Platform UI page for your space?  Click on the URL to see your application's UI.  You should see your app page with an emoji in the center similar to the image below.  Your emoji will likely be different, but if it is the same as the image you may want to buy a lottery ticket because you are lucky today!

![Image showing a view of the Inclusion app we just deployed](../images/inclusion-app.png)

Excellent! With minimal fuss and no knowledge of Kubernetes, you were able to deploy a containerized application in just a few minutes.  Now, let's move on to the next section to explore this process in a little more depth.
