# Deploying Helm Charts and Dockerfiles to Tanzu Platform for Kubernetes

## Overview

In this section we deploy an application using Helm Charts.  This is accomplished by using a Tanzu Platform space that is configured with the FluxCD Helm profile.  We are also using our my-custom-networking profile and creating an additonal profile that has the k8sgateway.tanzu.vmware.com capability to provide ingress for our application.

## Log in to Tanzu Platform for Kubernetes UI

Open your browser to the Tanzu Platform for K8s URL you were given at the begining of the workshop. Log into the Cloud Service Portal with your username and password.  

Once logged in select the Organize supplied for your training using the pull-down under your name in the upper right corner.  Under My Service select Launch Service on the VMware Tanzu Platform tile.

![My Services](../images/myservices.png)

Finally select the project your were instructed to use for the workshop from the pull-down in the upper left.

![Project](../images/project.png)

## Log into Tanzu Platform using the CLI

We will also leverage the Tanzu CLI to work on our spaces and deploy helm charts so we will also log in to the CLI.

1. Set your Organization ID enviornment variable 
```
export TANZU_CLI_CLOUD_SERVICES_ORGANIZATION_ID={org ID provided for workshop}
tanzu login
```
2. Alias kubectl commands to use UCP kubeconfig
```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
```
3. Select the Project you have been using during your workshop
```
tanzu project list
# follow the interactive menu to select the project you've been assigned to
```
3. Select your cluster group

For this module we will reuse the same clusterg roup you used in your previous sections.  So please select that cluster group using the command below.

```
tanzu operations clustergroup use
# follow the interactive menu to select the cluster group you previously created
```

## Install Helm Capabilites on your Clustergroup

We are going to use the Tanzu CLI to install the cluster group capabilities although these can also be done using the UI (`Application Spaces -> Capabilities`).

Since we are reusing the previous cluster group, most of the needed capabilities for helm apps are already installed, so we will just add the two new flux capabilies provided by the following packages.

```
tanzu package install fluxcd-helm.tanzu.vmware.com -p fluxcd-helm-controller.tanzu.vmware.com -v '>0.0.0'
tanzu package install fluxcd-source.tanzu.vmware.com -p fluxcd-source.tanzu.vmware.com -v '>0.0.0'
```

We can verify the packages corretly installed using the CLI and the previously aliased tk command
```
tk get pkgi
```

We could also check using the Tanzu Platform for Kubernetes UI (`Application Spaces -> Capabilities -> Installed -> Select your cluster group`).  You will see something like this:
![placeholder]{../images/foo.png}

## Create Mutation Webhook Policy

For TKGs clusters we ship with Pod Security Admission mode set to enforce [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/).  This means security violations cause a pod to be rejected. The test application we are using breaks the policy and won't be scheduled unless we label the application namespace PSA standard level accordingly.  Since Tanzu Platform for Kubernetes dynamically creates namespaces based on the Space concept, we need a way to automatically label these namespaces to allow our pods to run.



![Space Ready](../images/helm-space-tile.png)

3. Expand your space by clicking on view details then select Space Configuration.  Examine the Profiles to verify you see **at least** the following Profiles `fluxcd-helm.tanzu.vmware.com my-custom-networking gateway-api`

![Space Configuration](../images/helm-space-configuration.png)

Bob's clustergroup mutation webhook policy https://chat.google.com/room/AAAA7-TLcC0/qtEJEIWujdU/QZVuuRDL-PE?cls=10
