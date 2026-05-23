kind get kubeconfig > /tmp/kind-config && \
KUBECONFIG=$HOME/.kube/config:/tmp/kind-config kubectl config view --flatten > /tmp/config && \
mv /tmp/config $HOME/.kube/config