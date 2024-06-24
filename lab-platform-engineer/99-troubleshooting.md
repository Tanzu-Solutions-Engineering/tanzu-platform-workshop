# Troubleshooting tips

## UCP Contexts
The location where the kube context is stored has changed for the Tanzu CLI v1.3.0+. It is now:
```
~/.config/tanzu/kube/config
```
So you need to use that `KUBECONFIG` when accessing all the UCP contexts. One way to do this is creating an alias for all kubecl access to UCP contexts:
```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
```

## Missing DNS Records?
If there are missing DNS records in Route53 after Space is scheduled and app deployed it could be a number of things
1. ELB Quota is exhausted.
    - Symptom: the Istio Gateway is not Programmed and its services is Pending (no ELB CNAME assigned)
        ```
        NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
        service/default-gateway-istio   LoadBalancer   10.100.80.171   <pending>     15021:30885/TCP,80:32211/TCP   18m
        service/spring-smoketest        ClusterIP      10.100.29.135   <none>        8080/TCP                       18m

        NAME                                                CLASS   ADDRESS   PROGRAMMED   AGE
        gateway.gateway.networking.k8s.io/default-gateway   istio             False        18m
        ```
    - Solution:
        Clean unused ELBs in the AWS region in the Account and/or increase Quota

## Missing k8s Services and Network Topology in the Space view
If there are missing k8s Services and Network Topology info after Space is scheduled and app deployed it could be that one of the target clusters is not correctly onboarded in the Platform. To confirm this go to the GUI: `Setup & Configuration > Kubernetes Management > Cluster Onboarding` and verify the `Collector Status` for the clusters used in this Space


