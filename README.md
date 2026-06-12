## Home Server

This repository is the Kubernetes-side source of truth for the homelab.

It does not describe the full estate alone. The current environment is split across:

- `home-server`: Kubernetes cluster charts, values, and rendered manifests
- `home-docker-compose`: Docker Compose services running on a separate host layer beside the cluster

## High-level Routing

<img width="1912" height="493" alt="image" src="https://github.com/user-attachments/assets/ac085ee2-ab44-4bc9-99b2-3efb3930623d" />

## Physical Infrastructure

Current operational signals from this repo:

- Talos Linux is used for the Kubernetes nodes
- Talos control plane access defaults to `192.168.10.50`
- Cilium Gateway and service exposure use the `192.168.100.x` range
- Cluster-internal monitoring also scrapes devices on the `192.168.10.x` LAN

Known LAN endpoints referenced by current config:

- `192.168.10.50`: Talos control plane endpoint used by helper scripts
- `192.168.10.99`: external Ubuntu-style host exposing node-exporter and Infisical API
- `192.168.10.52`: external node-exporter target
- `192.168.10.51`: external node-exporter target
- `192.168.10.1`: router metrics and HAProxy metrics target
- `192.168.100.1`: Cilium Gateway API shared address
- `192.168.100.2`: Minecraft `LoadBalancer` address

This repo does not yet define the full node inventory, Talos machine configs, firewall, or router configuration. Those details should be documented separately if they become part of version control.

## Cluster Architecture

This repository follows a chart -> values -> rendered manifest flow.

### Source of truth

- `infrastructure/charts/*`: infrastructure Helm chart source
- `applications/charts/*`: application Helm chart source
- `infrastructure/staging/*/values.yaml`: environment values for infrastructure
- `applications/staging/*/values.yaml`: environment values for applications

### Generated output

- `infrastructure/rollout/*`: rendered infrastructure manifests
- `applications/rollout/*`: rendered application manifests

In normal work, edit `charts/*` and `staging/*/values.yaml`. The `rollout/*` directories are generated outputs committed by CI.

## Networking

Cluster networking is centered on Cilium.

Current capabilities from `infrastructure/staging/cilium/values.yaml`:

- kube-proxy replacement enabled
- Gateway API enabled
- BGP control plane enabled
- L2 announcements enabled
- Hubble relay enabled
- Hubble UI enabled
- Prometheus scraping enabled for Cilium components

### Shared Gateway

The current cluster ingress pattern uses a shared Cilium Gateway:

- Gateway: `internal-monitoring-gateway`
- Namespace: `monitoring`
- Address: `192.168.100.1`
- Hostname space: `*.cluster.home.tlta.online`

Current HTTP routes are used for internal monitoring and governance tools such as:

- Grafana
- Grafana Alloy
- Victoria Logs
- Victoria Metrics
- Hubble and related internal services

When adding another internal HTTP service, extending the existing Gateway API pattern is the expected approach unless there is a clear reason not to.

## TLS and Certificates

TLS is managed by cert-manager.

Current cert-manager setup from `infrastructure/staging/cert-manager/values.yaml`:

- CRDs enabled
- ACME issuer backed by Let's Encrypt production
- DNS challenge via Cloudflare
- wildcard certificate generated for cluster domains

Configured domains currently include:

- `*.cluster.tlta.online`
- `cluster.tlta.online`

Note that other parts of the repo also reference `*.cluster.home.tlta.online`. Domain naming should be checked carefully before further ingress changes.

## Namespaces

Current namespace layout:

- `kube-system`: Cilium
- `cert-manager`: cert-manager
- `monitoring`: external-secrets, grafana-stack, prometheus-stack, victoria-logs-single, victoria-metrics-single
- `longhorn-system`: Longhorn
- `stag01`: CloudNativePG operator, CNPG cluster, Kyoo
- `minecraft`: Minecraft server

## Cluster Stacks

### Secrets

Secrets in the cluster are not intended to be hardcoded in application values.

Current pattern:

- External Secrets runs in `monitoring`
- ClusterSecretStore `infisical` is configured
- the backend points to `http://192.168.10.99/`
- project slug: `home-server-83-az`
- environment slug: `staging`

Existing synced secrets include CNPG and Kyoo credentials in `stag01`.

This means the Docker-hosted Infisical instance currently acts as the upstream secret system for cluster workloads.

### Storage

Persistent storage is provided by Longhorn.

Current Longhorn signals:

- namespace `longhorn-system`
- Longhorn UI enabled with one replica
- CSI sidecars intentionally kept at one replica
- default storage replica count set to `3`

Cluster applications that need persistent volumes should assume Longhorn unless a chart explicitly requires something else.

### Monitoring

The monitoring stack is split across several charts:

- `grafana-stack`
- `prometheus-stack`
- `victoria-metrics-single`
- `victoria-logs-single`

Current behavior:

- Grafana uses VictoriaMetrics as the default metrics datasource
- Grafana uses VictoriaLogs as a Loki-compatible log datasource
- Grafana Alloy scrapes cluster ServiceMonitors and PodMonitors
- Grafana Alloy also scrapes external LAN targets:
  - `192.168.10.99:9100`
  - `192.168.10.52:9100`
  - `192.168.10.51:9100`
  - `192.168.10.1:9100`
  - `192.168.10.1:8405/metrics`

The cluster monitoring stack therefore covers both Kubernetes workloads and non-cluster infrastructure on the LAN.

### Database Layer

PostgreSQL inside the cluster is handled by CloudNativePG.

Current layout:

- CloudNativePG operator installed cluster-wide
- CNPG cluster runs in `stag01`
- current database image line targets PostgreSQL `18`
- current cluster values are used for the Kyoo workload

Current secret wiring:

- `kyoo-pg-credentials`
- `kyoo-pg-superuser`

These are synced by External Secrets and then consumed by CNPG/Kyoo.

## Applications

### Kyoo

Kyoo is currently deployed in `stag01`.

Current characteristics:

- uses CNPG service `cnpg-cluster-rw`
- DB secrets come from `kyoo-pg-superuser`
- exposed at `https://kyoo.cluster.home.tlta.online`

### Minecraft

Minecraft is deployed in its own namespace.

Current characteristics:

- namespace `minecraft`
- service type `LoadBalancer`
- fixed `LoadBalancer` IP `192.168.100.2`
- `mc-router` also exposes a `LoadBalancer` service

## Relationship To `home-docker-compose`

This repo only describes the cluster side. Some important supporting services currently live outside Kubernetes in the Docker Compose stack:

- Traefik
- Vaultwarden
- Infisical
- host Postgres
- Immich
- host Redis for Immich
- host node-exporter

That split matters:

- cluster secrets depend on the external Infisical instance
- cluster monitoring scrapes non-cluster hosts
- not every stateful service has been migrated into Kubernetes

## CI/CD

Rendered manifests are produced by GitHub Actions.

### Infrastructure render flow

Workflow:

- `.github/workflows/render-manifest-infra.yml`

Behavior:

1. Detect changed infra charts from `infrastructure/staging/**/values.yaml`
2. Build Helm dependencies
3. Read namespace from `infrastructure/charts/<chart>/meta.yaml` when present
4. Run `helm template`
5. Commit output into `infrastructure/rollout/<chart>/<chart>.yaml`

### Application render flow

Workflow:

- `.github/workflows/render-manifest-app.yml`

Behavior:

1. Detect changed app charts from `applications/staging/**/values.yaml`
2. Build Helm dependencies
3. Read namespace from `applications/charts/<chart>/meta.yaml` when present
4. Run `helm template`
5. Commit output into `applications/rollout/<chart>/<chart>.yaml`

### Flux

The repo also contains Flux-related charts under `cicd/charts/`.

At minimum:

- `cicd/charts/fluxcd`
- `cicd/charts/fluxcd-custom`

Those charts represent the GitOps/bootstrap side of the cluster, while the GitHub Actions workflows handle manifest rendering into committed rollout outputs.

## Useful Helpers

Helper files currently in repo:

- `templates/scripts/cluster-health-check.sh`
- `templates/scripts/cluster-shutdown.sh`
- `templates/helpers/helper-commands.sh`

Operational signals from helpers:

- Talos is the expected node OS interface
- KubePrism is expected at `localhost:7445`
- kubeconfig merging helpers already exist for local workflows

## Practical Editing Rules

If you are changing something in this repo:

- edit `staging/*/values.yaml` for environment configuration
- edit `charts/*` for reusable chart logic
- do not treat `rollout/*` as the primary authoring location
- follow the existing Cilium Gateway API pattern for internal HTTP exposure
- use External Secrets for credentials
- assume Longhorn for persistence unless the workload already uses another pattern
