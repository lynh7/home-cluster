# Phase 1 Hardening Checklist

This document turns the roadmap into the first concrete implementation pass.

## Current blockers confirmed in repo

- `stag01` namespace is currently labeled `pod-security.kubernetes.io/*=privileged`
- `minecraft` namespace is currently labeled `pod-security.kubernetes.io/*=privileged`
- External Secrets currently points to Infisical over `http://192.168.10.99/`
- no enforced app-focused default-deny policy is enabled yet for `stag01` or `minecraft`
- an opt-in default-deny scaffold now exists for `stag01` in the Kyoo chart

## Safe sequence

1. Add configuration knobs first
2. Test app workloads against `baseline` or `restricted` in a non-critical window
3. Introduce default-deny policy in one namespace only
4. Add only the minimum allow rules required for DNS, ingress, DB, and monitoring
5. Move Infisical to HTTPS before treating cluster secrets as trustworthy for real workloads

## New repo capabilities added

### Configurable Pod Security labels

The following charts no longer hardcode namespace Pod Security labels in templates:

- `applications/charts/cloudnative-pg`
- `applications/charts/minecraft-server`

This allows staged rollout from `privileged` to `baseline` or `restricted` without template rewrites.

### Opt-in default-deny scaffold for `stag01`

The Kyoo chart now includes an opt-in `NetworkPolicy` scaffold controlled by:

- `securityBaseline.networkPolicy.enabled`
- `securityBaseline.networkPolicy.defaultDeny.ingress`
- `securityBaseline.networkPolicy.defaultDeny.egress`

It is intentionally disabled by default so allow rules can be added before enforcement.

### Infisical TLS-ready ClusterSecretStore

The External Secrets customization now supports:

- `clusterSecretStore.infisical.caBundle`
- `clusterSecretStore.infisical.caProvider`

This is the path to move the current plaintext Infisical API configuration to HTTPS with explicit trust.

## Recommended first changes

### Step 1: tighten app namespaces

Start by changing only audit and warn levels first.

For `stag01` and `minecraft`:

- keep `enforce: privileged` initially
- set `audit: restricted`
- set `warn: restricted`

Then review what breaks before switching `enforce`.

### Step 2: move Infisical to HTTPS

Required inputs:

- final Infisical HTTPS host name
- trusted CA source as ConfigMap or Secret
- network path that only External Secrets needs

Then update `infrastructure/staging/external-secrets/values.yaml` to use:

- `hostAPI: https://...`
- `caProvider` or `caBundle`

### Step 3: add app namespace default-deny

First target namespace: `stag01`

Required allow rules to expect:

- DNS to kube-dns or node-local DNS
- ingress from shared gateway components
- egress to CNPG services
- egress to required external APIs such as TMDB/TVDB if Kyoo needs them
- optional monitoring scrape paths

### Step 4: lock service accounts down

Review charts and overrides for:

- `automountServiceAccountToken`
- per-workload service accounts
- unnecessary cluster-scoped RBAC

## Suggested target values

### `stag01` transitional state

```yaml
namespaceLabels:
  podSecurity:
    enforce: privileged
    audit: restricted
    warn: restricted
  sharedGatewayAccess: "true"
```

### `minecraft` transitional state

```yaml
namespaceLabels:
  podSecurity:
    enforce: privileged
    audit: baseline
    warn: baseline
```

## Exit criteria for Phase 1

Phase 1 is meaningfully complete when:

- Infisical uses HTTPS with explicit CA trust
- `stag01` and `minecraft` no longer rely on hardcoded privileged namespace labels
- at least one app namespace runs with default-deny plus explicit allow rules
- app service accounts are reviewed and token automount is reduced
