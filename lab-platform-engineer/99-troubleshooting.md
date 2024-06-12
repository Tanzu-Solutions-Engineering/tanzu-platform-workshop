# Troubleshooting tips

The location where the kube context is stored has changed for the Tanzu CLI v1.3.0+. It is now:
```
~/.config/tanzu/kube/config
```
So you need to use that `KUBECONFIG` when accessing all the UCP contexts. One way to do this is creating an alias for all kubecl access to UCP contexts:
```
alias tk='KUBECONFIG=~/.config/tanzu/kube/config kubectl'
```


