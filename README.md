## Home Server

This repository is the Kubernetes-side source of truth for the homelab.

It does not represent the whole estate by itself. The platform is split across:

- `home-cluster` (this repo, formerly `home-talos-cluster`): Kubernetes cluster charts, values, and rendered manifests
- `home-docker-compose`: supporting services on the Raspberry Pi host (Infisical, Tailscale, Vaultwarden, Immich, Pi-local monitoring, GitHub runner)
- `my-docusaurus`: static Docusaurus sites served from the Pi (not cluster-related)

## Current Shape

- Talos runs the Kubernetes nodes
- Cilium handles cluster networking, Gateway API, BGP, and L2 announcements
- cert-manager handles TLS
- Longhorn handles persistent storage
- External Secrets syncs cluster secrets from the external Infisical dependency
- CloudNativePG handles PostgreSQL inside the cluster
- Grafana, Prometheus, VictoriaMetrics, and VictoriaLogs provide observability

## Repo Layout

- `infrastructure/charts/*`: infrastructure Helm charts
- `applications/charts/*`: application Helm charts
- `infrastructure/staging/*/values.yaml`: infrastructure environment values
- `applications/staging/*/values.yaml`: application environment values
- `infrastructure/rollout/*`: rendered infrastructure manifests
- `applications/rollout/*`: rendered application manifests
- `cicd/charts/fluxcd*`: Flux bootstrap and deployment wiring

## Networking

The cluster uses a shared Cilium Gateway for internal HTTP services.

Current exposed services are routed through Cilium and cert-manager-managed TLS.
The address ranges in use are documented in the cluster values and rollout manifests.

## Operational Notes

- Secrets are not meant to be hardcoded in app values
- Some services still live outside Kubernetes and must be treated as external dependencies
- The repository tracks the cluster state, not the full physical network or Talos machine inventory
- Any path or chart marked `(deprecated)` should be treated as retired unless the current values say otherwise
- A chart under `infrastructure/charts/<name>` without a matching `infrastructure/rollout/<name>/` is not in use (exception: `grafana-dashboards`, deployed as a Flux HelmRelease)
- Not every chart in the repo is deployed: check `cicd/charts/fluxcd-custom/templates/**` (for example, `plane-ce` is rendered but not wired into Flux yet)
- The `longhorn-system` namespace and the `infisical-auth` / `github-pat-auth` bootstrap secrets are created manually

## Roadmap

- [Current State](./docs/current-state.md): verified list of what Flux actually deploys
- [Read Me First](./docs/read-me-first.md)
- [Hybrid Topology](./docs/hybrid-topology.md)
- [Phase 1 hardening checklist](./docs/phase-1-hardening-checklist.md)
