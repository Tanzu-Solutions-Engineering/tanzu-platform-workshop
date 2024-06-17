---
title: Diving Deeper on Apps
---
7. `tanzu app init --help` to see that these could be specified on the command line.

10. Open browser tab to take user to their space to see the deployed app info, and Space URL.  Have user click on URL to see their app running.
11. Explore the Space UI a bit to show off some of the info provided.
12. Show the `tanzu.yaml` file and how it is a pointer to another directory `.tanzu/config`.
```editor:open-file
file: ~/tanzu.yml
```
13. Open `.tanzu/config/inclusion.yaml` to see the settings we specified with `tanzu app init`.
```editor:open-file
file: ~/.tanzu/config/inclusion.yaml
```
14. `tanzu app config` to see configurable options.  Explain some of the common items:
    1.  `tanzu app config build path set` to change the path to the source code (but don't run this)
    2.  `tanzu app config build path set non-secret-env BP_JVM_VERSION=21` to add environment variables that impact CNB operations.  Show link to Packeto buildpack for Java configuration option https://paketo.io/docs/howto/java/#install-a-specific-jvm-version.  Notice the `emoji-inclusion.yaml` file got updated.  `tanzu app build --output-dir /tmp/build` to see the buildpack output change to JDK 21.  Mention this didn't update the running app, but we'll cover that capability more in a later step.
    3.  `tanzu app config non-secret-env LOGGING_COM_EXAMPLE_EMOJIINCLUSION=DEBUG` to set a 
    4.  `tanzu app contact set <field>=<value>` and explain how this lets you add arbitrary contact info about the app.  `tanzu app contact set email=me@here.com`, `tanzu app contact set team slack` and have it prompt you for the "team" and "slack" values.  Go to the `emoji-inclusion.yaml` and see how that updates the yaml.  `kubectl explain containerapp.spec.contact` to show this is an arbitrary map of whatever you want today, but mention some keys might eventually be used by the Tanzu Platform UI.
    5.  Mention there are other options here we'll explore in subsequent sections.
15. `tanzu app list` to see your running app.
```execute
tanzu app list
```
16. Have the user _manually_ type `tanzu app get` and then hit `<TAB>` to show autocompletion in the CLI.  Hit Enter after it autocompletes and you can see some info about your currently deployed app.  Point out in the `tanzu app get` output the "source image" reference.  Refer back to the `tanzu build config` command we executed way back and how that image path was generated from the build config.
17. Remind the user when we executed the `tanzu app config build path set non-secret-env` earlier and point out the environment variables show from the `tanzu app get` command.  Notice the variable we set for the build isn't shown yet because we haven't deployed.  This could be a spot where we introduce the concept of the "at-rest" version of the app config files vs. the "applied" version of the app config in Tanzu Platform.
18. Now, let's get our local build synced to the platform with `tanzu deploy --from-build /tmp/build` and notice that it uses the already built image we did earlier so it's faster.
> **_NOTE:_**  It might be nice to have the inclusion app show the JDK version somewhere so it's easy to see if this change was applied or not.
