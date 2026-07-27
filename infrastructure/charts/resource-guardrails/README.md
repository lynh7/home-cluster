# resource-guardrails

Native Kubernetes admission policies for protecting labeled namespaces and secrets from deletion.

## Use

Label a resource you want to protect:

```yaml
metadata:
  labels:
    policy.home-talos-cluster.io/protected: "true"
```

The chart installs two default policy/binding pairs:

- protect namespaces
- protect secrets

Both defaults can be disabled from `values.yaml`, and additional policies can be added by appending to the `policies` list.
The namespace policy blocks deletion when the namespace carries any label whose key starts with `kustomize.toolkit.fluxcd.io`; the secret policy still uses the chart's protected label.

## Notes

- Requires Kubernetes v1.30+
- No extra controller pods
- Protection only applies to `DELETE` requests on labeled `Namespace` and `Secret` objects by default

## Example custom policy

```yaml
policies:
  - name: protect-configmaps
    enabled: true
    policy:
      metadata:
        annotations:
          kubernetes.io/description: Protect labeled ConfigMaps from deletion.
      spec:
        failurePolicy: Fail
        matchConstraints:
          resourceRules:
            - apiGroups: [""]
              apiVersions: ["v1"]
              operations: ["DELETE"]
              resources: ["configmaps"]
              scope: Namespaced
        objectSelector:
          matchLabels:
            policy.home-talos-cluster.io/protected: "true"
        validations:
          - expression: "false"
            message: Protected configmaps cannot be deleted.
    binding:
      spec:
        validationActions: ["Deny"]
```
