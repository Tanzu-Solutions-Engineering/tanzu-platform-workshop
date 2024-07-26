---
title: Prepare for Launch!
---
Before we can deploy any applications, we need to log in to the platform and set our project and space.  Normally, you would just issue a `tanzu login`, let the CLI open a browser window for you, log in to the Cloud Services Platform (CSP), and your browser would redirect you to a local listener that the Tanzu CLI sets up to accept the token generated for your login.  

However, we're running this workshop in Educates, so we are almost acting as if we've SSH'd into a remote machine that doesn't have a browser.  Luckily, the Tanzu CLI Github repo has some [instructions](https://github.com/vmware-tanzu/tanzu-cli/blob/main/docs/quickstart/quickstart.md#interactive-login) on how to deal with this situation.  We're going to follow the procedure for manually copying the token from your browser tab and pasting it into the Educates terminal where we're logging in from.  You can see an example of where the token will appear in your browser when it fails to connect to the local listener port (which is running in a pod on the cluster Educates is running on) in the following image:
![Image showing the login token we need to copy in the URL line of your browser](https://raw.githubusercontent.com/vmware-tanzu/tanzu-cli/6a11ce93cd4e811e213e8439e090e1d73a053fd3/docs/quickstart/images/interactive_login_copy_authcode.png)

Click on the section below to log in.  Your browser will prompt you to log in to the CSP, and then it will show an error page since your machine can't talk directly to the Tanzu CLI running in Educates. Copy the token from the address bar and then come back to Educates.

{{< note >}}
You will see an error page pop up when the `tanzu login` command runs. This is normal in the workshop environment.  Follow the instructions and image right above the `tanzu login` step in the workshop instructions that explains how to copy the `code` value from the error page address bar, and then paste that code value into this terminal session
{{< /note >}}

```execute
tanzu login
```

Now, in the terminal session that we ran the login command in, paste your copied token, and press enter.

![Image showing Project containing Spaces](../images/project-and-spaces.png)

Tanzu Platform has a few different organizational structures that enable developers to focus on the resources for their applications.  First, Tanzu Platform manages the clusters and resources you have access to in top-level *Projects*.  Within a Project, there are logical locations to deploy your application components called *Spaces*.  Before we can do much else, we need to target the Tanzu CLI at the project and space assigned to you for your application work.

You can see all the projects you have access to by listing them with the following command:
```execute
tanzu project list
```

Your platform engineering team has already configured a project for you to use called *{{< param TANZU_PLATFORM_PROJECT >}}*.  Let's target that project with the following command:

```execute
tanzu project use {{< param TANZU_PLATFORM_PROJECT >}}
```

Now, we need to target a space.  You can list out the spaces available with the following command:
```execute
tanzu space list
```

Your platform engineering team has already created a space for you as well.  That space is called *{{< param  session_name >}}*.  Let's target that space:
```execute
tanzu space use {{< param  session_name >}}
```

Finally, we need to set one final configuration to get started.  We need to specify the container registry to be used for storing the application containers and deployment manifests built for you by Tanzu Platform. In our environment, our platform engineers have configured the platform with a build plan stored remotely, in the so-called Universal Control Plane (or UCP). The build plan uses Cloud Native Buildpacks and applies some common conventions for Spring applications.  However our business unit has its own container registry service, so we need to configure the Tanzu CLI to know where that registry is.  Luckily, we already have the location of this registry in an environment variable, and we've already logged into that registry using the Docker CLI. So let's execute the following command to configure the Tanzu CLI to use our registry.

```execute
tanzu build config --build-plan-source="simple.tanzu.vmware.com" --build-plan-source-type=ucp --containerapp-registry $PUBLIC_REGISTRY_HOST/{name}
```
{{< note >}}
`PUBLIC_REGISTRY_HOST` is an environment variable with the hostname for our registry.

`{name}` is a template variable that gets replaced with the name of the app you are building an image for. 
{{< /note >}}

{{< note >}}
Tanzu Platform can be configured in a variety of ways for builds and we're planning to expand those options in the future. For example, your platform team could eventually configure a default registry and server-side builds so that you might not even need to know about container registries in the future.
{{< /note >}}

Excellent!  We've successfully logged into Tanzu Platform, targeted our assigned Project and Space, and configured the Tanzu CLI to store our container images in our business unit's container registry.  Let's move on to get our first app running!