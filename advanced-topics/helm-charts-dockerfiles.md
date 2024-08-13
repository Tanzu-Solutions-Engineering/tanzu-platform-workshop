# Deploying Helm Charts and Dockerfiles to Tanzu Platform for Kubernetes

## Overview

In this section we deploy an application using Helm Charts.  This is accomplished by using a Tanzu Platform space that is configured with the FluxCD Helm profile.  We are also using our my-custom-networking profile and creating an additonal profile that has the k8sgateway.tanzu.vmware.com capability to provide ingress for our application.

## Update Repo

To make sure you have captured any changes since your last pull it is recommened to update your repo

```
cd tanzu-platform-workshop
git pull origin main
```

If you are doing this workshop for the first time clone the Tanzu Platform Workshop repo

```
git clone https://github.com/Tanzu-Solutions-Engineering/tanzu-platform-workshop.git
```

All file for this module are located under the advanced-topics folder

```
cd advanced-topics
find .
./podinfo
./podinfo/helmrepository.yaml
./podinfo/helmrelease.yaml
./podinfo/podinfo-values.yaml
./podinfo/route.yaml
./helm-charts-dockerfiles.md
./templates
./templates/space.yaml
./templates/flux-helm-profile.yaml
./templates/psa-mutating-policy.yaml
```
## Log in to Tanzu Platform for Kubernetes UI

Open your browser to the Tanzu Platform for K8s URL you were given at the begining of the workshop. Log into the Cloud Service Portal with your username and password.  

Once logged in select the Organize supplied for your training using the pull-down under your name in the upper right corner.  Under My Service select Launch Service on the VMware Tanzu Platform tile.

![My Services](../images/myservices.png)

Finally select the project your were instructed to use for the workshop from the pull-down in the upper left. **Note: your workshop may use a different project than displayed in the example image**

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

[Official documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-run-cluster-group.html#add-packages)

We are going to use the Tanzu CLI to install the cluster group capabilities although these can also be done using the UI (`Application Spaces -> Capabilities`).

We will be reusing the cluster group you used on previous modules, so most of the needed capabilities for our helm application are already installed.  If for some reason you are starting with a fresh cluster group please also install the capabilities listed  [here](/lab-platform-engineer/01-full-lab.md#add-capabilities-to-cluster-group)

```
# Capabilities Required by Helm Application

# Already installed from Previous Modules
- egress.tanzu.vmware.com
- certificates.tanzu.vmware.com
- multicloud-ingress.tanzu.vmware.com
- k8sgateway.tanzu.vmware.com

# Newly installed below
- fluxcd-helm-controller.tanzu.vmware.com
- fluxcd-source-controller.tanzu.vmware.com
```

```
tanzu package install fluxcd-helm-controller.tanzu.vmware.com -p fluxcd-helm-controller.tanzu.vmware.com -v '>0.0.0'
tanzu package install fluxcd-source-controller.tanzu.vmware.com -p fluxcd-source-controller.tanzu.vmware.com -v '>0.0.0'
```

We can verify the packages corretly installed using the CLI and aliased tk command
```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
tk get pkgi

NAME                                        PACKAGE NAME                                PACKAGE VERSION   DESCRIPTION   AGE
k8sgateway.tanzu.vmware.com                 k8sgateway.tanzu.vmware.com                                                 8m39s
tcs.tanzu.vmware.com                        tcs.tanzu.vmware.com                                                        8m33s
cert-manager.tanzu.vmware.com               cert-manager.tanzu.vmware.com                                               8m48s
observability.tanzu.vmware.com              observability.tanzu.vmware.com                                              8m25s
mtls.tanzu.vmware.com                       mtls.tanzu.vmware.com                                                       7m42s
container-apps.tanzu.vmware.com             container-apps.tanzu.vmware.com                                             7m20s
bitnami.services.tanzu.vmware.com           bitnami.services.tanzu.vmware.com                                           7m27s
crossplane.tanzu.vmware.com                 crossplane.tanzu.vmware.com                                                 7m35s
servicebinding.tanzu.vmware.com             servicebinding.tanzu.vmware.com                                             7m13s
tanzu-servicebinding.tanzu.vmware.com       tanzu-servicebinding.tanzu.vmware.com                                       7m4s
spring-cloud-gateway.tanzu.vmware.com       spring-cloud-gateway.tanzu.vmware.com                                       6m55s
fluxcd-helm-controller.tanzu.vmware.com     fluxcd-helm-controller.tanzu.vmware.com                                     2m28s
fluxcd-source-controller.tanzu.vmware.com   fluxcd-source-controller.tanzu.vmware.com                                   2m17s                
```

We could also check using the Tanzu Platform for Kubernetes UI (`Application Spaces -> Capabilities -> Installed -> Select your cluster group`).  You will see something like this:

![Cluster Group Capabilities](../images/capabilities.png)

## Create Mutation Webhook Policy

[Official Documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-mutation-policy.html)

For TKGs clusters we ship with Pod Security Admission mode set to enforce [Visit this page for more information](https://kubernetes.io/docs/concepts/security/pod-security-admission/).  This means security violations cause a pod to be rejected. The test application we are using breaks the policy and won't be scheduled unless we label the application namespace PSA standard level accordingly.  Since Tanzu Platform for Kubernetes dynamically creates namespaces based on the Space concept, we need a way to automatically label these namespaces to allow our pods to run.

1. Verify that your clustergroup is still selected in your context

```
tanzu context current
# Cluster Group: {your cluster group} should be one of the variables in the output
  Name:             sa-tanzu-platform
  Type:             tanzu
  Organization:     sa-tanzu-platform (77aee......)
  Project:          workshop01 (3b65b......)
  Cluster Group:    bauerbo-cg1     <-------
  Kube Config:      /home/ubuntu/.config/tanzu/kube/config
  Kube Context:     tanzu-cli-sa-tanzu-platform:workshop01:bauerbo-cg-01

```
2. Edit the templates/psa-mutating-policy.yaml file in this repo and replace `{your clustergroup name}` with the  name of the cluster group you are using.  Note: This is an intentionally broad policy (all clusters in the group and all new namespaces)

```
vi templates/psa-mutating-policy.yaml or vi templates/psa-mutating-policy-filtered.yaml

fullName:
  clusterGroupName: {your clustergroup name}  <---- Replace with your cluster group name
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
tanzu operations policy create -s clustergroup -f psa-mutating-policy.yaml
```

4. You can verify the policy was created using

```
tanzu operations policy list
tanzu operations policy get psa-mutation-policy -n {clustergroup name} -s clustergroup
```

## Flex-Helm Profile

We will be reusing profiles created in the earlier modules (`sping-dev-simple-sa.tanzu.vmware.com`) and your custom network profile (`networking.mydomain.com or yourname-customer-networking`).  We will be using an additional profile to add the fluxcd source and fluxcd helm capabilities to our space.  This demonstrates the additive abilty of reusing profiles grouped around an application type or requirement.

We can use the **Tanzu Provided** `fluxcd-helm.tanzu.vmware.com` profile as it provides the required capabilities fluxcd-helm.tanzu.vmware.com, fluxcd-source.tanzu.vmware.com and traits fluxcd-helmrelease-installer.tanzu.vmware.com to deploy a helm application.

Alternatively you can create your own profile by applying the templates/flux-helm-profile.yaml using the Tanzu CLI or you could even make your own via the UI.

CLI Instructions **(Optional)**

1. Select project (setting this will reset the space or clustergroup in your context).  Commands run from the CLI need to be created in the correct context or you will either get errors or items created in an unexpected place.  It is good practice to alway verify your context before CLI commands.

```
tanzu project use
# follow the interactive menu to select the project you've been assigned to

tanzu context current
  Name:            sa-tanzu-platform
  Type:            tanzu
  Organization:    sa-tanzu-platform (8406......)
  Project:         workshop01 (66cf1......)
  Kube Config:     /home/ubuntu/.config/tanzu/kube/config
  Kube Context:    tanzu-cli-sa-tanzu-platform:workshop01

# Note there is no Space or Clustergroup specificed
```
2. Apply flux-helm-profile.yaml  from templates folder

```
tanzu deploy --only templates/flux-helm-profile.yaml

Target cluster 'https://api.tanzu.cloud.vmware.com/org/8406e52e-.............'

Changes

Namespace  Name               Kind     Age  Op      Op st.  Wait to  Rs  Ri
default    flux-helm-profile  Profile  12h  update  -       -        ok  -

Op:      0 create, 0 delete, 1 update, 0 noop, 0 exists
Wait to: 0 reconcile, 0 delete, 1 noop

Continue? [yN]: y

5:00:36PM: ---- applying 1 changes [0/1 done] ----
5:00:36PM: update profile/flux-helm-profile (spaces.tanzu.vmware.com/v1alpha1) namespace: default
5:00:36PM: ---- waiting on 1 changes [0/1 done] ----
5:00:36PM: ok: noop profile/flux-helm-profile (spaces.tanzu.vmware.com/v1alpha1) namespace: default
5:00:36PM: ---- applying complete [1/1 done] ----
5:00:36PM: ---- waiting complete [1/1 done] ----
```
3. Verify Profile was created and Ready is True

```
tanzu profile list
Listing profiles from Tanzu Platform for sa-tanzu-platform
  NAME                                   READY  TRAITS RESOLVED  AGE
  bauerbo-custom-networking              True   3/3              40d
  flux-helm-profile                      True   1/1              12h
  fluxcd-helm.tanzu.vmware.com           True   1/1              42d
  gateway-api                            True   0/0              18d
  k8s-containerapp                       True   1/1              7d19h
  networking.tanzu.vmware.com            True   3/3              42d
  spring-dev-simple-sa.tanzu.vmware.com  True   2/2              3h11m
  spring-dev.tanzu.vmware.com            True   3/3              42d
  spring-prod.tanzu.vmware.com           True   3/3              42d
```
## Create Helm App Space

Access the Tanzu Platform GUI: `Application Spaces -> Spaces -> Create Space -> Step by Step`

1. Space Name
    - Choose a unique name and something different than you've used for other spaces in this workshop.  Example: `yourname-helm-app`
2. Select Profiles
    - Select your `custom networking profile` you created in previous module
    - Select the `spring-dev-simple-sa.tanzu.vmware.com` profile
    - Select the `fluxcd-helm.tanzu.vmware.com` (or custom flux profile you create)
3. Availability Targets
    - Add the availabilty target which contains the clustergroup you've installed the capabilities on in previous modules and above in this module (example bauerbo-at-tkgs)
    - Set Replicas to 1

![Helm App Space](../images/space.png)

4. Click `Create Space`
5. View your Space in the Space page.  It will take some time for the Space to become ready.  Use the Refesh in upper right to refresh the view

![Space Ready](../images/helm-space-tile.png)

6. Expand your space by clicking on `View Details -> Space Configuration` You should see the 3 Profiles you added in Step 2 of Space Creation

![Space Configuration](../images/helm-space-configuration.png)

## Install Helm charts in a Space

[Official Documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-helm-charts-in-spaces.html)

In the `podinfo`folder there are 4 yaml files used to deploy a simple application using helm

```
find .
.
./helmrepository.yaml
./helmrelease.yaml
./podinfo-values.yaml
./route.yaml
```

helmrepository.yaml
- Defines Helm repository location for Flux

helmrelease.yaml
- Defines Helm chart to install (fetched from referenced repository) and provide configuration values

podinfo-values.yaml
- Secret used to provided additional values for Helm Release

route.yaml
- Configuration to expose Podinfo application using `HTTPRoute API`

We do not need to modify any of these files.  We can simply select our space we want to deploy the application to and use `tanzu deploy` to apply the YAML files to UCP.

### Deploy Helm Application

1. You may need to edit the podinfo/route.yaml depending on how your configured your Ingress and GSLB settings in the [lab-platform-engineer module](/lab-platform-engineer/01-full-lab.md#configure-ingress-and-gslb)

```
cd podinfo
vi route.yaml
```
Look at the spec.parentRefs name. This is the name of the Gateway object the route will use.
```
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: default-gateway   <-----
```
This needs to match what you configured for the `mutlicloud-ingress.tanzu.vmware.com` name in your custom networking profiles.  
- You can verify this by going to (`Application Spaces -> Profiles -> {your custom networking profile}`) and then click the 3 elipses and choose`Edit Profile` (or action edit if you are in View Details)
- Click Next of the Basic Information section
- In the Traits section click on the > next to `Configure multicloud-ingress.tanzu.vmware.com` to expand details
- Scroll down to the Name field.  This needs to match what is in route.yaml.  If the supplied route.yaml .spec.parentRef.name doesn't match the Name field in your mutlicloud-ingress - updated the route.yaml

![Gateway Name](../images/ingressname.png)

2. Set your Space to the helm-app space you created

```
tanzu space list
tanzu space use
# follow the interactive menu to select the space you created

# Optional view your context to see you have the correct project and space selected
tanzu context current
  Name:            sa-tanzu-platform
  Type:            tanzu
  Organization:    sa-tanzu-platform (8406e5......)
  Project:         workshop01 (66cf1f......)     <--------
  Space:           bauerbo-helm-app     <--------
  Kube Config:     /home/ubuntu/.config/tanzu/kube/config
  Kube Context:    tanzu-cli-sa-tanzu-platform:workshop01:bauerbo-helm-app
```
3. Deploy Helm Resources

```
tanzu deploy --only podinfo/.
Target cluster 'https://api.tanzu.cloud.vmware.com/org/8406e52e-6e36-445a-be7b-9dab6903341e/project/66cf1fd9-0ff9-42d6-9be0-022dd473e1dc/space/bauerbo-helm-app'

Changes

Namespace  Name            Kind            Age  Op      Op st.  Wait to  Rs  Ri
default    podinfo         HelmRelease     -    create  -       -        -   -
^          podinfo         HelmRepository  -    create  -       -        -   -
^          podinfo-main    HTTPRoute       -    create  -       -        -   -
^          podinfo-values  Secret          -    create  -       -        -   -

Op:      4 create, 0 delete, 0 update, 0 noop, 0 exists
Wait to: 0 reconcile, 0 delete, 4 noop

Continue? [yN]: y

6:05:13PM: ---- applying 1 changes [0/4 done] ----
6:05:13PM: create secret/podinfo-values (v1) namespace: default
6:05:13PM: ---- waiting on 1 changes [0/4 done] ----
6:05:13PM: ok: noop secret/podinfo-values (v1) namespace: default
6:05:13PM: ---- applying 3 changes [1/4 done] ----
6:05:13PM: create helmrepository/podinfo (source.toolkit.fluxcd.io/v1) namespace: default
6:05:13PM: create helmrelease/podinfo (helm.toolkit.fluxcd.io/v2) namespace: default
6:05:13PM: create httproute/podinfo-main (gateway.networking.k8s.io/v1beta1) namespace: default
6:05:13PM: ---- waiting on 3 changes [1/4 done] ----
6:05:13PM: ok: noop httproute/podinfo-main (gateway.networking.k8s.io/v1beta1) namespace: default
6:05:13PM: ok: noop helmrepository/podinfo (source.toolkit.fluxcd.io/v1) namespace: default
6:05:13PM: ok: noop helmrelease/podinfo (helm.toolkit.fluxcd.io/v2) namespace: default
6:05:13PM: ---- applying complete [4/4 done] ----
6:05:13PM: ---- waiting complete [4/4 done] ----
```
4. View status of Helm Repository from UCP

```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
tk get srs -l "resource-name=podinfo,kind=HelmRepository" -oyaml
```
```
Look For:
              .status:
                conditions:
                - lastTransitionTime: "2024-06-25T19:33:35Z"
                  message: 'stored artifact: revision ''sha256:3dfe15d87f81dedc8ddaf116c7302892e54a0d8f269e35f65aaff9ac4d1b179c'''
                  observedGeneration: 2
                  reason: Succeeded
                  status: "True"
                  type: Ready
```
5. View staus of Helm Release from UCP

```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
tk get srs -l "resource-name=podinfo,kind=HelmRelease" -oyaml
```
```
              .status:
                conditions:
                - lastTransitionTime: "2024-06-25T19:33:44Z"
                  message: Helm install succeeded for release bauerbo-helm-app-fdf9b444d-vj92s/podinfo.v1
                    with chart podinfo@6.5.4
                  observedGeneration: 1
                  reason: InstallSucceeded
                  status: "True"
                  type: Ready
```
6. Verify using the UI

Navigate to your Space in Tanzu Platform UI (`Application Space -> Spaces -> Your helm-app space`) and click View Details

On the Space you will see a `Space URL: podinfo.fqdn.com` This is where you application is publically available via HTTPRoute.  You can also see this same information undeer Ingress & Egress.  Open this link in your web browser to visit the Podinfo site.

![Helm Space URL](../images/helm-space-url.png)

### OPTIONAL - Create Containerapp to track application deployed via Helm

You can optionally create a containerapp object to track the helm application we just deployed.  This will allow you to use the `tanzu app list` and `tanzu app get` commands for the PodInfo application.  I will also populuate the application tab of your space with some basic information.

1. Verify you have the container-apps.tanzu.vmware.com capability installed on your cluster group.  This should already be there from your day 1 package install.  You can use the UI by navigating to Application Spaces -> Capabilities -> Installed and selecting your clustergroup.  To verify using the CLI complete the following.
```
tanzu operations clustergroup use {yourclustergroup}
tanzu package installed list
```

If you don't see the container-apps.tanzu.vmware.com capability do the following to install using the CLI
```
tanzu operations clustergroup use {yourclustergroup}
tanzu package install container-apps.tanzu.vmware.com -p container-apps.tanzu.vmware.com -v '>0.0.0'
tanzu package installed list
```
2. Create containerapp manifest or use the one located in /templates/containerapp.yaml
```
# containerapp.yaml
apiVersion: apps.tanzu.vmware.com/v1
kind: ContainerApp
metadata:
  name: podinfo
  annotations:
    containerapp.apps.tanzu.vmware.com/class: "kubernetes"
spec:
  description: Podinfo application from Helm
  contact:
    slack: "#my-helm-apps"
  image: ghcr.io/stefanprodan/podinfo
  relatedRefs:
    - for: kubernetes.list-replicas
      kind: Pod
      labelSelector: app.kubernetes.io/name=podinfo
```
3. Select your space
```
tanzu space use   #pick your space from the list
```
4. Test output of Tanzu app command.  You can also view the Applications section TPK8s UI for your space.  It should show no information.
```
tanzu app list
# Output should be blank
```
5. Deploy containerapp.yaml to your space
```
tanzu deploy --only containerapp.yaml
```
6. Retest Tanzu app command and Applications UI in your space
```
tanzu app list

  NAME     CONTENT  INSTANCES(RUNNING/REQUESTED)  CPU  MEM  BINDINGS  STATUS
  podinfo           3/3                                               Running
```

UI should now show the Application listed
![Space Application UI](../images/application-helm-ui.png)

**Note** You cannot use most of the tanzu app cli commands like scale because the helm deployment owns the application.  The containerapp component is mainly to bring additional visisblity to the application.