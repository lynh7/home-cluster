# resource-guardrails

Native Kubernetes admission policies (ValidatingAdmissionPolicy) that block deletion of Flux-managed namespaces and labeled secrets.

## Use

Namespaces are protected automatically when Flux manages them (any label key starting with `kustomize.toolkit.fluxcd.io`).

Label a secret (or a resource covered by a custom policy) that you want to protect:

```yaml
metadata:
  labels:
    policy.home-talos-cluster.io/protected: "true"
```

The chart installs two default policy/binding pairs:

- protect namespaces
- protect secrets

Both defaults can be disabled from `values.yaml`, and additional policies can be added by appending to the `policies` list.
The namespace policy evaluates `oldObject` on DELETE and blocks deletion only when the namespace carries a label whose key starts with `kustomize.toolkit.fluxcd.io`; unlabeled namespaces remain deletable. The secret policy still uses the chart's protected label.

## Notes

- Requires Kubernetes v1.30+
- No extra controller pods
- By default, protection only applies to `DELETE` requests on Flux-labeled `Namespace` objects and `policy.home-talos-cluster.io/protected`-labeled `Secret` objects
- To delete a protected namespace on purpose, remove it from Flux first (or disable the namespace policy in values)

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
