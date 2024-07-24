curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0-beta.9/vcluster-linux-amd64" && chmod +x vcluster && mv vcluster $HOME/bin/
cat <<EOF >> vcluster.yaml
controlPlane:
  proxy:
    extraSANs: 
    - vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN
EOF

vcluster create vcluster-$SESSION_NAMESPACE  --update-current=false --switch-context=false --create-namespace=false --background-proxy=false --connect=false -n $SESSION_NAMESPACE  -f vcluster.yaml

cat <<EOF | kubectl apply -f -
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: vcluster-$SESSION_NAME
spec:
  virtualhost:
    fqdn: vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN
    tls:
      passthrough: true
  tcpproxy:
    services:
    - name: vcluster-$SESSION_NAME
      port: 443
EOF

vcluster connect vcluster-$SESSION_NAMESPACE -n $SESSION_NAMESPACE --print --silent --server=https://vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN  > vcluster-kubeconfig.yaml
