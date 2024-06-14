---
title: Workshop Instructions
---
> **_TODO:_**  Should split these into separate workshop modules

> **_PREREQUISITES:_**  
> - Project already provisioned
> - Workshop attendee granted access to existing Tanzu Platform org and project
> - Space provisioned by educates workshop session setup script with simple spring-dev profile (no SCG)

1. `tanzu login`, attendee copies link (since browser can't be launched in Educates) and enters credentials in new browser tab
```terminal:execute
command: tanzu login
cascade: true
```
```terminal:execute
command: kubectl config set-context --current --namespace=default
hidden: true
```

2. `tanzu project use <pre-provisioned-project>`.  Quickly review what projects are, and maybe show `tanzu project list` to see all the projects you could access.
```execute
tanzu project list
```
```terminal:input
text: "tanzu project use "
endl: false
```

3. `tanzu space use <generated-space>`.  Quickly review spaces and `tanzu space list` to see your spaces.
```execute
tanzu space list
```
```section:begin
title: (Optional) Create Space in Tanzu Hub
```

Instructions on how to setup a new space in Tanzu Hub.

```section:end
```
```terminal:input
text: "tanzu space use "
endl: false
```
4. `tanzu build config --build-plan-source-type=ucp --containerapp-registry <registry-host>/apps/{name}`
```execute
tanzu build config --build-plan-source-type=ucp --containerapp-registry $PUBLIC_REGISTRY_HOST/inclusion
```
> **_NOTE:_**  Need a container registry.  Do we provision one as part of the workshop or use a cloud one?  Also might want to mention here that this might be specified by the platform engineering team in the future so that developers wouldn't even need to know this.

5. `git clone https://github.com/timosalm/emoji-inclusion`
> **_NOTE:_**  Should we make a different version with no Backstage or TAP manifests?
```execute
git clone https://github.com/timosalm/emoji-inclusion inclusion
```

6. `tanzu app init` and user enters info.
```execute
tanzu app init
```
```terminal:input
text: inclusion
```
```terminal:input
text: inclusion
```
**Press Enter to confirm buildpack selection**
7. `tanzu app init --help` to see that these could be specified on the command line.

9. `tanzu build` to build container image and generate YAML
```execute
tanzu build -o deployment
```

8. User adds HttpRoute object file at .tanzu/config/httproute.yaml.
> **_NOTE:_**  Default to HTTP since HTTPS is limited at the moment, and also potentially allows us to go into more detail about that in a later step?

```editor:append-lines-to-file
file: ~/deployment/apps.tanzu.vmware.com.ContainerApp/inclusion/kubernetes-carvel-package/output/httproute.yaml
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
        sectionName: {{ session_namespace }}-inclusion
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
9. `tanzu app deploy` and user monitors deployment.
```execute
tanzu deploy --from-build deployment
```
10. Open browser tab to take user to their space to see the deployed app info, and Space URL.  Have user click on URL to see their app running.
11. Explore the Space UI a bit to show off some of the info provided.
12. Show the `tanzu.yaml` file and how it is a pointer to another directory `.tanzu/config`.
13. Open `.tanzu/config/emoji-inclusion.yaml` to see the settings we specified with `tanzu app init`.
14. `tanzu app config` to see configurable options.  Explain some of the common items:
    1.  `tanzu app config build path set` to change the path to the source code (but don't run this)
    2.  `tanzu app config build path set non-secret-env BP_JVM_VERSION=21` to add environment variables that impact CNB operations.  Show link to Packeto buildpack for Java configuration option https://paketo.io/docs/howto/java/#install-a-specific-jvm-version.  Notice the `emoji-inclusion.yaml` file got updated.  `tanzu app build --output-dir /tmp/build` to see the buildpack output change to JDK 21.  Mention this didn't update the running app, but we'll cover that capability more in a later step.
    3.  `tanzu app config non-secret-env LOGGING_COM_EXAMPLE_EMOJIINCLUSION=DEBUG` to set a 
    4.  `tanzu app contact set <field>=<value>` and explain how this lets you add arbitrary contact info about the app.  `tanzu app contact set email=me@here.com`, `tanzu app contact set team slack` and have it prompt you for the "team" and "slack" values.  Go to the `emoji-inclusion.yaml` and see how that updates the yaml.  `kubectl explain containerapp.spec.contact` to show this is an arbitrary map of whatever you want today, but mention some keys might eventually be used by the Tanzu Platform UI.
    5.  Mention there are other options here we'll explore in subsequent sections.
15. `tanzu app list` to see your running app.
16. Have the user _manually_ type `tanzu app get` and then hit `<TAB>` to show autocompletion in the CLI.  Hit Enter after it autocompletes and you can see some info about your currently deployed app.  Point out in the `tanzu app get` output the "source image" reference.  Refer back to the `tanzu build config` command we executed way back and how that image path was generated from the build config.
17. Remind the user when we executed the `tanzu app config build path set non-secret-env` earlier and point out the environment variables show from the `tanzu app get` command.  Notice the variable we set for the build isn't shown yet because we haven't deployed.  This could be a spot where we introduce the concept of the "at-rest" version of the app config files vs. the "applied" version of the app config in Tanzu Platform.
18. Now, let's get our local build synced to the platform with `tanzu deploy --from-build /tmp/build` and notice that it uses the already built image we did earlier so it's faster.
> **_NOTE:_**  It might be nice to have the inclusion app show the JDK version somewhere so it's easy to see if this change was applied or not.
19.  Introduce services.  `tanzu service` command to show things we can do with services.
20.  `tanzu service type list` to show available catalog of services.  Mention platform team can control this catalog and could potentially expose other types of services in the future (cloud provider, custom services, etc).
21.  `tanzu service create PostgreSQLInstance/my-db` to create a new service instance.
22.  `tanzu service list` to see created services.
23.  `tanzu service get PostgreSQLInstance/my-db` to get some details about our service.  Highlight the "type spec" and mention these are configurable items the platform team allows for these service types (like storageGB).  Mention we can specify those values using the `tanzu service create PostgreSQLInstance/my-db --parameter storageGB=??` format, but don't execute that.
24.  `tanzu service bind PostgreSQLInstance/my-db ContainerApp/emoji-inclusion --as db`
25.  Refesh app tab and notice the service is now bound and the change to the emoji view.
26.  Explain how this service is only available for apps in this space to use directly.  We're going to switch to a "shared" database instance that has been pre-provisioned for us by rebinding our app to a secret.
    1.  Add a secret to the UCP with the shared DB credentials and coordinates called `shared-db`.
    2.  `tanzu service unbind PostgreSQLInstance/my-db ContainerApp/emoji-inclusion` to remove the binding.
    3.  `tanzu service bind Secret/shared-db ContainerApp/emoji-inclusion --as db` to bind to the shared instance.
    4.  Refresh the app and notice all the different emojis that start to show up.
27.  `tanzu service delete PostgreSQLInstance/my-db` to clean up the unneeded DB now.
28. `tanzu app config servicebinding set db=postgresql` to add metadata to ContainerApp about needed service bindings.  Open up `emoji-inclusion.yaml` to show how the "alias" is set to "db" and the allowable types is set only to "postgresql".  `tanzu service type list` again to show where that "postgresql" binding type is coming from.
29. Review spaces and scheduling to explain replicas and how they are different from individual deployment scale.
30. `tanzu app scale set cpu=400 memory=678` for vertical scale.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
31. `tanzu app scale set replicas=2` to scale horizontally in _each_ availability target.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
32. Viewing logs requires access to the availability target cluster today, so `kubectl logs...` against the workload cluster to show the logs.  Mention that features are coming soon to surface the logs and add more debugging capabilities are planned for the future.