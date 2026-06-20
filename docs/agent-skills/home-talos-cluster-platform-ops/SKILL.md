---
name: home-talos-cluster-platform-ops
description: Repo-specific platform operations skill for the home-talos-cluster repo. Use when working on storage, secrets, observability, external dependencies, cert-manager, Longhorn, monitoring, or day-2 operational changes across the homelab platform.
---

# Home Talos Cluster Platform Ops

This repo manages cluster platform, but not whole estate. Many operational answers depend on in-cluster plus external services together.

## Read First

- `README.md`
- `infrastructure/staging/external-secrets/values.yaml`
- `infrastructure/staging/longhorn/values.yaml`
- `infrastructure/staging/cert-manager/values.yaml`
- `infrastructure/staging/grafana-stack/values.yaml`
- `infrastructure/staging/prometheus-stack/values.yaml`
- `infrastructure/staging/victoria-logs-single/values.yaml`
- `infrastructure/staging/victoria-metrics-single/values.yaml`

## Operating Model

- Secrets sync from external Infisical dependency
- Storage assumes Longhorn
- TLS handled by cert-manager
- Monitoring split across Grafana, Prometheus stack, VictoriaMetrics, VictoriaLogs
- Cluster also scrapes non-cluster LAN targets

## Use This Skill For

- Secret dependency mapping
- Whether workload can rely on Longhorn
- Monitoring architecture and scrape ownership
- External dependency blast radius
- Hardening platform stacks before app rollout
- Day-2 changes: scaling, observability, storage, namespace operations

## External / Cloud Angle

Even though this is homelab, external systems still matter:

- Cloudflare DNS challenge for cert-manager
- GitHub as GitOps source
- External Infisical host
- External LAN scrape targets

Treat these as operational dependencies. Call them out when recommending changes.

## Placement Rules

- Secret sync behavior:
  `infrastructure/charts/external-secrets` and staging values
- Storage behavior:
  `infrastructure/charts/longhorn` and staging values
- Monitoring behavior:
  monitoring chart values first, then rollout only for applied-state inspection
- Certificate and DNS behavior:
  `infrastructure/staging/cert-manager/values.yaml`

## Red Flags

- Assuming all secrets live in cluster
- Assuming all monitored targets are Kubernetes services
- Assuming namespace exists because chart targets it
- Ignoring manual Longhorn namespace setup if still present
- Recommending destructive storage or secret changes without dependency review
