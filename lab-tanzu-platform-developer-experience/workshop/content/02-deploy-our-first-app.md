---
title: Deploy our First App
---
Now that we have the CLI configured, let's get our first app running on Tanzu Platform.

We'll be using a sample application to go through the workshop.  Let's clone the project into our workshop environment.
```execute
git clone https://github.com/timosalm/emoji-inclusion inclusion
```

Now, we need to add in some information so that the platform understands the name of our application and where the source code is.  We'll first change directories to the app we just cloned.
```execute
cd inclusion
```

Next, we'll use the `tanzu app init` command to add in some basic info about our application.
```execute
tanzu app init
```

With no parameters, the `tanzu app init` command prompts us for the key bits of info it needs.  The first thing it needs is the name of the app.  It defaults to the name of the directory we're running the command from, and you can accept the default by pressing enter.
```terminal:execute
description: Confirm default application name
command: ""
```

The command next needs to know where the source code for our application is.  Since we're in the directory for our application source code, we can just hit enter to accept the default of the current directory.
```terminal:execute
description: Confirm default application source directory
command: ""
```

Finally, our platform team has configured Cloud Native Buildpacks as the only build option for our platform, so let's accept that as our build type by pressing enter.
```terminal:execute
description: Confirm Cloud Native Buildpacks as build type
command: ""
```

We could have also specified all these values as parameters to the `tanzu app init` call.  Look at the help output for the command to see the options you can specify.
```execute
tanzu app init --help
```

We can also add manifests for objects that will be deployed along with our application.  Since we want to be able to access our application externally to the cluster it is deployed on, let's define a manifest that will expose our application to the outside world.

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
Adding an external ingress to your application in this way is not the planned future for route management.  Eventually, the platform will support CLI commands to create and map routes to applications.  This step is necessary until the platform has first class support for route management.
{{< /note >}}

Now, let's deploy our application.
```execute
tanzu deploy -y
```

We can see that the Cloud Native Buildpacks for Java and Spring are being used to create a container image for our application, and manifests are getting generated for our application using the best practices from our Platform Engineering and DevOps teams.  The build will take a couple minutes, so just wait until the process completes.

{{< note >}}
Your application might take a minute to start up, become healthy and for the app DNS record to propigate to your workstation's DNS servers.  If the URL for your app belwo doesn't work immediately, give it a minute and try again.
{{< /note >}}

Once the deploy is completed, you can navigate to https://www.mgmt.cloud.vmware.com/hub/application-engine/space/details/{{< param  session_name >}}/topology to see the URL for your application under the "Space URL" section of the upper middle of the page.  Click on the URL to see your application's UI.  After you see the app page with an emoji in the center, go back to the Tanzu Platform tab for your space and explore the different tabs for your application.  The *Applications* tab shows a list of all the application services we have deployed to our space.  You can click on the name of the "inclusion" application to see some more details about the application.  That view will be sparse for now, but we'll look at it again when we work with services later on.  Explore the *Ingress & Egress* tab and click the chevron next to your application host name in the *Ingress* list.  You can see some information about the route we currently have mapped to the application.

Excellent!  With minimal fuss and no knowledge of Kubernetes, you were able to deploy a containerized application in just a few minutes.  Now, let's move on to the next section to explore this process in a little more depth.