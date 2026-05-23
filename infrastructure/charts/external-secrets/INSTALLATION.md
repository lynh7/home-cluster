kubectl create secret generic infisical-auth \
  --from-literal=clientId="your-infisical-client-id" \
  --from-literal=clientSecret="your-infisical-client-secret" \
  -n <YOUR-NAMESPACE>
---
Store clientId and clientSecret from Infisical → Project Settings → Service Tokens / Machine Identity.