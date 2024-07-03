curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0-beta.9/vcluster-linux-amd64" && chmod +x vcluster && mv vcluster $HOME/bin/
cat <<EOF >> vcluster.yaml
controlPlane:
  distro:
    eks: 
      enabled: true 
  proxy:
    extraSANs: 
    - vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN
sync:
  fromHost:
    nodes:
      enabled: true
      selector:
        all: true
EOF
vcluster create vcluster-$SESSION_NAME --update-current=false --switch-context=false --create-namespace=false --background-proxy=false --skip-wait -n $SESSION_NAMESPACE -f vcluster.yaml &
KUBECTL_PID=$!

( tail -f /dev/null & ) | {
    while read -r line; do
        echo "$line"
        if [[ "$line" == *"Forwarding from"* ]]; then
            echo "Desired output detected. Stopping command."
            kill "$KUBECTL_PID"
            exit 0
        fi
    done
}

vcluster connect vcluster-$SESSION_NAME -n $SESSION_NAMESPACE --print --server=https://vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN > vcluster-kubeconfig.yaml

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

