---
title: Troubleshooting
---
{{< note >}}
Troubleshooting and debugging is an area of the platform undergoing changes and enhancement.  Today, what you can see from the platform about the running application is limited to log viewing, but R&D has plans to add actuator metric viewing from the platform UI, live debugging for running applications, and other troubleshooting features.
{{< /note >}}

If your application is having trouble, you will want to be able to see the logs for your app.  But as a developer, you can see what availability target your app is running in.  However, the specific cluster your app is running on might not be directly accessible to you for security or policy reasons.

That's alright, though!  The Tanzu Platform CLI and UI allow you to view and stream logs for your application instances, no matter what clusters they happen to land on.  Viewing the logs for our application is very simple.

Let's use the `tanzu` CLI to view our application logs.  Click the section below to start the process.
```execute
tanzu app logs --recent
```

The CLI presents a list of all the deployed applications in the space you are currently targeted at.  We only have one application deployed in our space, but if you had many you could filter the list by typing a few characters.  Our "inclusion" application is already selected so just click the section below or press the `Enter` key to select it.
```execute
```

Next, we're presented with a list of instances of our application.  Since we scaled our instance to 2 pods, you should see two instaces in the list.  Notice, the CLI also shows you information about the space replica the pod is running in, and what availability target that replica is on.  Click the section below or press the `Enter` key to select the first instance in the list.

You should see the last 50 lines of the logs for the inclusion app.  But what if we have some issue that we need to replicate to see the error occur live?  Tanzu Platform has agents deployed to all the clusters it is managing that is resposible for communicating with the platform.  One of the functions of the agent is to scrape logs for deployed applications, and stream them back to Tanzu Platform.

We can get a live stream of log entries by leaving the `--recent` parameter off the command.  Let's start that live stream of log entries by clicking the section below.
```execute
tanzu app logs inclusion
```

Select the first instance of our "inclusion" by pressing the `Enter` key to select it.
```execute
```

Now, we'll see a list of recent log entries, as well as new entries that show up.  You can validate this by noting the time of the last log entry, and then refreshing the browser tab for your application. If you closed the tab to your application, you can go to https://www.platform.tanzu.broadcom.com/application-engine/space/details/{{< param  session_name >}}/ingress to see the URL for your application. As you refresh the application page, you should be able to compare the timestamps on the logs to the timestamp you noted earlier to see that new entries are getting added.

Great!  We were able to view the logs for our application without having to have access to the clusters that our application happend to land on.

Let's view a summary of what we've covered in the workshop in the next section.