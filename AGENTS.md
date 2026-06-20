# Home Talos Cluster

Use repo-local skills first when working in this repository.

## Primary Repo Skills

- `docs/agent-skills/home-talos-cluster-architect/SKILL.md`
  Use for cluster layout, ownership, namespace mapping, rollout paths, and where changes belong.
- `docs/agent-skills/home-talos-cluster-gitops/SKILL.md`
  Use for Flux, GitHub Actions render flow, rollout ordering, reconciliation, and GitOps bootstrap.
- `docs/agent-skills/home-talos-cluster-networking/SKILL.md`
  Use for Cilium, Gateway API, LoadBalancer IPs, L2 announcements, ingress, service exposure, and network policy.
- `docs/agent-skills/home-talos-cluster-platform-ops/SKILL.md`
  Use for storage, secrets, observability, external dependencies, and day-2 platform operations.

## General Skills To Combine

Combine repo skills with these general skills when relevant:

- `context-engineering`
- `ci-cd-and-automation`
- `security-and-hardening`
- `observability-and-instrumentation`
- `shipping-and-launch`
- `source-driven-development`

## Working Rules

1. Read `README.md` first for architecture questions.
2. Treat `charts/*` and `staging/*/values.yaml` as source of truth.
3. Treat `rollout/*` as generated output that Flux applies.
4. Check `cicd/charts/fluxcd-custom/templates/*` before assuming Flux deploys a stack.
5. Surface manual or external dependencies explicitly.
6. For networking or policy work, inspect Cilium values and templates before proposing structure.
7. For GitOps changes, inspect both Flux Kustomizations and render workflows.

## Repo Boundaries

- Talos machine configs not stored here
- Router and firewall not stored here
- Some supporting services run outside Kubernetes
- Not every chart in repo is necessarily deployed by Flux
