## Home Server

This repository is the Kubernetes-side source of truth for the homelab.

It does not represent the whole estate by itself. The platform is split across:

- `home-talos-cluster`: Kubernetes cluster charts, values, and rendered manifests
- `home-docker-compose`: supporting services that still run on a separate host layer

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

## Roadmap

- [Production-like roadmap](./docs/production-roadmap.md)
- [Phase 1 hardening checklist](./docs/phase-1-hardening-checklist.md)
