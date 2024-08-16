# Platform Engineer Lab Prerequisites

## Workshop Owner pre-requisites
- vSphere environment(s) with vCenter v8.0.2c (8.0.2.00300) or newer.
    - Workload Management enabled with AVI
    - Supervisor cluster v1.27.5+vmware.1-fips.1 or newer.
    - ContentLibrary synced with TKr 1.28.8 available (1.29.4 or 1.30.1 should work too)
    - Compute capacity for one TKG clusters with 1 CP node and 3 worker nodes with 4VCPU & 16GBRAM per VM per attendee
    - At least 4 VM IPs available for all those k8s nodes per attendee
    - At least 3 AVI VIPs available per attendee: 1 VIP for the cluster CP, 2 VIP for ingress per cluster
    - Supervisor Namespace created with Storage Policy and VM Classes associated to it
- AWS Setup
    - Domain registered/delegated to Route53 zone
    - If you haven't created a VPC for EKS yet, follow the instructions here: https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html - use the instructions for public and private subnets
- Tanzu Platform for Kubernetes Org + Group + Project
    - AWS Account, EKS Lifecycle Management Credential and Route 53 GSLB Credential configured
    - AWS EKS Overflow Cluster(s) (labeled with `workshop-overflow: true`)
      - Recommended cluster node pool size is 5 t3.xlarge
      - The cluster must have public and private endpoint access (Network Advanced Settings in TPK8S). CIDR 0.0.0.0/0
        will work.  
      - The cluster must have a default storage class for eduk8s. To verify or change this, access the EKS cluster using the kubeconfig file obtained from Tanzu Platform. If no default storage class is set, then execute this command (changing the storageclass name as appropriate) `kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}`
    - AT for Overflow Clusters
- Onboard all attendees on designated Tanzu Platform for k8s CSP org and project

## Workshop Attendee pre-requisites
- kubectl CLI v1.28.8 installed in workstation - [kubectl CLI install guide](https://v1-28.docs.kubernetes.io/releases/download/)
- tanzu CLI v1.4.0 installed in workstation - [tanzu CLI installation guide](https://docs.vmware.com/en/VMware-Tanzu-CLI/1.4/tanzu-cli/index.html)
- tanzu CLI plugins for platform engineer installaed - [tanzu CLI PE plugins installation guide](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/getting-started-create-app-envmt.html#before-you-begin-0)
```
tanzu plugin install --group vmware-tanzu/platform-engineer
```
