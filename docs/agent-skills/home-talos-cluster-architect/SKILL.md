---
name: home-talos-cluster-architect
description: Repo-specific cluster architecture skill for the home-talos-cluster GitOps repo. Use when asked how this cluster is structured, how Flux deploys stacks, where Cilium, Gateway API, Longhorn, or External Secrets fit, how namespaces and rollout ownership work, or where to place new infrastructure such as network policy, ingress, storage, or observability changes.
---

# Home Talos Cluster Architect

Understand repo before proposing cluster changes. This skill maps repo files to deployed architecture, ownership boundaries, and rollout order.

## When to Use

- User asks how cluster is organized
- User asks where to add new infra or app changes
- User asks about Flux, GitOps, rollout order, or namespace ownership
- User asks about Cilium, Gateway API, network policy, ingress, or service exposure
- User asks about storage, observability, secrets, or app-to-app traffic in this repo
- User asks for architecture review, hardening plan, or cluster design recommendation

## Core Rule

Always separate 3 layers:

1. Authoring layer
   `infrastructure/charts/*`, `applications/charts/*`, `*/staging/*/values.yaml`
2. Generated layer
   `infrastructure/rollout/*`, `applications/rollout/*`
3. Bootstrap / deploy layer
   `cicd/charts/fluxcd`, `cicd/charts/fluxcd-custom`

Do not treat `rollout/*` as primary source for intended changes unless question is about rendered or applied state.

## Fast Path

Read these first for most architecture questions:

- `README.md`
- `cicd/charts/fluxcd-custom/templates/gitrepository.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/infra-stacks/*.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/application/*.yaml`
- `infrastructure/staging/cilium/values.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/*`

Then branch by topic below.

## Topic Map

### Flux / GitOps

Read:

- `cicd/charts/fluxcd/values.yaml`
- `cicd/charts/fluxcd-custom/templates/gitrepository.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/infra-stacks/*.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/application/*.yaml`
- `.github/workflows/render-manifest-infra.yml`
- `.github/workflows/render-manifest-app.yml`

Answer:

- Which stacks Flux deploys
- Which stacks are missing or manual
- Whether deploy order is explicit or accidental
- Whether a change belongs in Flux bootstrap, rendered manifests, or chart source

### Networking / Cilium / Gateway / Policy

Read:

- `infrastructure/staging/cilium/values.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/48-cilium-gateway.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/49-cilium-l2-policy-announcement.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/50-cilium-loadbalancer-ippool.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/51-cilium-http-route.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/52-cilium-reference-grant-template.yaml`
- `infrastructure/rollout/cilium/cilium.yaml`

Answer:

- How ingress and shared gateway work
- Which IP ranges are used for LB and gateway exposure
- Whether policy is default-open or default-deny in practice
- Best home for dynamic network policy

### Namespaces / Ownership

Read:

- `*/charts/*/meta.yaml`
- any `templates/namespace.yaml`
- `infrastructure/staging/longhorn/namespace.yaml`

Check:

- Which chart owns namespace creation
- Which workloads assume namespace already exists
- Which namespaces are manual or out-of-band

### Secrets / Storage / Monitoring

Read:

- `infrastructure/staging/external-secrets/values.yaml`
- `infrastructure/staging/longhorn/values.yaml`
- `infrastructure/staging/grafana-stack/values.yaml`
- `infrastructure/staging/prometheus-stack/values.yaml`
- `infrastructure/staging/victoria-logs-single/values.yaml`
- `infrastructure/staging/victoria-metrics-single/values.yaml`

Answer:

- Secret source of truth and dependency chain
- Storage class and persistence assumptions
- Monitoring stack split and external LAN scrape behavior

## Repo Mental Model

- Talos cluster repo, not full estate
- Cilium is network platform
- Flux deploys rendered outputs from this same repo
- GitHub Actions render charts into committed `rollout/*`
- Some infra still lives outside cluster and must be treated as dependency, not managed state

## Architecture Heuristics

### When recommending where change should live

- Platform-wide networking or security behavior:
  prefer `infrastructure/charts/cilium` or separate infra chart
- Shared observability, secrets, or storage behavior:
  prefer `infrastructure/charts/*`
- App-specific behavior:
  prefer app chart or app values
- Deployment orchestration or order:
  prefer `cicd/charts/fluxcd-custom`
- Render pipeline fixes:
  prefer `.github/workflows/*`

### When answering "current setup"

Prefer authoring plus rollout together:

- authoring files show intended source of truth
- rollout files show what Flux likely applies
- flux templates show whether object is actually deployed

### When answering "why is this brittle?"

Check for:

- missing Flux `dependsOn`
- namespace created by one stack, consumed by another
- manual namespace files outside Flux path
- chart or template changes not triggering render workflow
- generated manifests committed in nested paths but workflow `git add` missing them

## Hard Boundaries

Surface these when relevant:

- Talos machine configs not in repo
- Router and firewall not in repo
- Some supporting services run outside Kubernetes
- `rollout/*` is generated, not hand-authored

## Red Flags

Do not:

- infer live cluster behavior from one values file alone
- recommend editing `rollout/*` as normal authoring path
- assume Flux deploys every chart in repo
- assume namespace ownership is obvious
- assume network policy is already centrally modeled

## Verification

Before answering, confirm:

- Which layer question targets: authoring, generated, or bootstrap
- Which namespace owns resource
- Whether Flux actually deploys that path
- Whether dependency is in-cluster, manual, or external
- Whether recommendation matches current repo pattern

## Good Output Shape

1. State current pattern
2. State weak point or risk
3. Recommend exact repo location for change
4. Name key files that support conclusion
