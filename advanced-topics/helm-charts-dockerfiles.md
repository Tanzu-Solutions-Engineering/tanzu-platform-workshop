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
tanzu project use
# follow the interactive menu to select the project you've been assigned to
```
3. Select your cluster group

For this module we will reuse the same clusterg roup you used in your previous sections.  So please select that cluster group using the command below.

```
tanzu operations clustergroup list
tanzu operations clustergroup use
# follow the interactive menu to select the cluster group you previously created
```

## Install Helm Capabilites on your Cluster group

We are going to use the Tanzu CLI to install the cluster group capabilities although these can also be done using the UI (`Application Spaces -> Capabilities`).

Since we are reusing the previous cluster group, most of the needed capabilities for helm apps are already installed, so we will just add the two new flux capabilies provided by the following packages.

```
tanzu package install fluxcd-helm-controller.tanzu.vmware.com -p fluxcd-helm-controller.tanzu.vmware.com -v '>0.0.0'
tanzu package install fluxcd-source-controller.tanzu.vmware.com -p fluxcd-source-controller.tanzu.vmware.com -v '>0.0.0'
```

We can verify the packages corretly installed using the CLI and the previously aliased tk command
```
tk get pkgi
```
or
```
tanzu package installed list
```

We could also check using the Tanzu Platform for Kubernetes UI (`Application Spaces -> Capabilities -> Installed -> Select your cluster group`).  You will see something like this:
![placeholder]{../images/foo.png}

## Create Mutation Webhook Policy

For TKGs clusters we ship with Pod Security Admission mode set to enforce [Visit this page for more information](https://kubernetes.io/docs/concepts/security/pod-security-admission/).  This means security violations cause a pod to be rejected. The test application we are using breaks the policy and won't be scheduled unless we label the application namespace PSA standard level accordingly.  Since Tanzu Platform for Kubernetes dynamically creates namespaces based on the Space concept, we need a way to automatically label these namespaces to allow our pods to run.

1. Verify you are in the correct cluster group

```
tanzu context current
# Cluster Group: {your cluster group} should be one of the variables in the output
```
2. Edit the advanced-topics/templates/psa-mutating-policy.yaml file in this repo and replace `{your clustergroup name}` with the  name of the cluster group you are using.  Note: This is an intentionally broad policy (all clusters in the group and all new namespaces)

```
fullName:
  clusterGroupName: {your clustergroup name}
  name: psa-mutation-policy
meta:
spec:
  input:
    label:
      key: pod-security.kubernetes.io/enforce
........
  ```
3. Create the Mutation Policy

```
tanzu operations policy create -s clustergroup -f templates/psa-mutating-policy.yaml
```

4. You can verify the policy was created using

```
tanzu operations policy list
tanzu operations policy get psa-mutation-policy -n {clustergroup name} -s clustergroup
```

## Create Flex-Helm Profile

We can use the Tanzu Provided fluxcd-helm.tanzu.vmware.com profile as it provides the required capabilities `fluxcd-helm.tanzu.vmware.com, fluxcd-source.tanzu.vmware.com` and traits `fluxcd-helmrelease-installer.tanzu.vmware.com`

Alternatively you can create your own profile by applying the templates/flux-helm-profile.yaml using the Tanzu CLI or you could even make your own via the UI.

CLI Instructions

1. Make sure your project is selected

```
tanzu context current
```
2. Apply flux-helm-profile.yaml  from templates folder

```
tanzu profile create -f flux-helm-profile.yaml
🔎 Creating profile:
      1 + |---
      2 + |apiVersion: spaces.tanzu.vmware.com/v1alpha1
      3 + |kind: Profile
      4 + |metadata:
      5 + |  name: flux-helm-profile
      6 + |  namespace: default
      7 + |spec:
      8 + |  description: Provides capabilities to deploy helm charts using fluxcd
      9 + |  requiredCapabilities:
     10 + |  - name: fluxcd-helm.tanzu.vmware.com
     11 + |  - name: fluxcd-source.tanzu.vmware.com
     12 + |  traits:
     13 + |  - alias: fluxcd-helmrelease-installer
     14 + |    name: fluxcd-helmrelease-installer.tanzu.vmware.com
     15 + |    values:
     16 + |      inline: null
Create profile flux-helm-profile from flux-helm-profile.yaml? [yN]: y
✓ Successfully created profile flux-helm-profile
```
3. Verify Policy was created and Ready is True

```
tanzu profile list
Listing profiles from Tanzu Platform for Org
  NAME                          READY  TRAITS RESOLVED  AGE
  flux-helm-profile             True   1/1              5s
  fluxcd-helm.tanzu.vmware.com  True   1/1              41d
  gateway-api                   True   0/0              18d
  k8s-containerapp              True   1/1              7d6h
  networking.tanzu.vmware.com   True   3/3              41d
  spring-dev.tanzu.vmware.com   True   3/3              41d
  spring-prod.tanzu.vmware.com  True   3/3              41d
```

## Create Helm Space

3. Expand your space by clicking on view details then select Space Configuration.  Examine the Profiles to verify you see **at least** the following Profiles `fluxcd-helm.tanzu.vmware.com my-custom-networking gateway-api`

![Space Configuration](../images/helm-space-configuration.png)

![Space Ready](../images/helm-space-tile.png)

## Create Helm Objects

Instructions Here



