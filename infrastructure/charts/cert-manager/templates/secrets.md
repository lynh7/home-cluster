Deploying with kubectl command as below:
kubectl apply -f secret.yaml --set stringData.apiToken=$CF_DNS_API_TOKEN