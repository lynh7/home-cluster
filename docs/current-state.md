# Current State

Verified snapshot of what the repo actually deploys. Last verified: 2026-09-24.
Re-verify against `cicd/charts/fluxcd-custom/templates/**` before relying on it.

## What Flux Reconciles

Source: `GitRepository/flux-system` in `cicd/charts/fluxcd-custom/templates/gitrepository.yaml`
(branch `main`, auth secret `github-pat-auth` created manually).

| Flux object | Kind | Path | Target namespace | dependsOn |
|---|---|---|---|---|
| `rollout-cilium` | Kustomization | `infrastructure/rollout/cilium` | from manifests (`kube-system`) | - |
| `rollout-cert-manager` | Kustomization | `infrastructure/rollout/cert-manager` | from manifests (`cert-manager`) | - |
| `rollout-external-secrets` | Kustomization | `infrastructure/rollout/external-secrets` | from manifests (`monitoring`) | - |
| `rollout-longhorn` | Kustomization | `infrastructure/rollout/longhorn` | from manifests (`longhorn-system`) | - |
| `rollout-grafana-stack` | Kustomization | `infrastructure/rollout/grafana-stack` | from manifests (`monitoring`) | - |
| `rollout-prometheus-stack` | Kustomization | `infrastructure/rollout/prometheus-stack` | from manifests (`monitoring`) | - |
| `rollout-alerting-stack` | Kustomization | `infrastructure/rollout/alerting-stack` | from manifests (`monitoring`) | - |
| `rollout-victoria-logs-single` | Kustomization | `infrastructure/rollout/victoria-logs-single` | `monitoring` | - |
| `rollout-victoria-metrics-single` | Kustomization | `infrastructure/rollout/victoria-metrics-single` | `monitoring` | - |
| `rollout-resource-guardrails` | Kustomization | `infrastructure/rollout/resource-guardrails` | cluster-scoped | - |
| `rollout-grafana-dashboards` | HelmRelease | chart `./infrastructure/charts/grafana-dashboards` (no render step) | `monitoring` | - |
| `rollout-cloudnative-pg` | Kustomization | `applications/rollout/cloudnative-pg` | `stag01` | - |
| `rollout-cnpg-cluster` | Kustomization | `applications/rollout/cnpg-cluster` | `stag01` | `rollout-cloudnative-pg` |
| `rollout-demo-app` | Kustomization | `applications/manifests/demo-app` (hand-written, no chart) | from manifests (`demo-app`) | `rollout-prometheus-stack` (PodMonitor CRD) |

Only `rollout-cnpg-cluster` and `rollout-demo-app` have a `dependsOn`. Ordering between the other stacks
is implicit.

`applications/manifests/<name>/` holds hand-written plain manifests that Flux applies as-is (no chart, no render
workflow). Currently only `demo-app`: a placeholder 3-tier app (`core-ui` → `core-api` → `core-backend`, nginx + exporter
sidecars, busybox `load-generator`) with a PodMonitor per tier. No NetworkPolicies yet.

## Rule: Chart Without Rollout = Not In Use

If a chart exists under `infrastructure/charts/<name>` but there is no matching `infrastructure/rollout/<name>/`,
the chart is **not in use**. Do not treat it as deployed, do not reason about the cluster from it, and do not extend it
without first deciding to bring it back (staging values + rollout + Flux Kustomization).

Only exception: `infrastructure/charts/grafana-dashboards` has no rollout folder but **is** in use. Flux deploys it
directly as the HelmRelease `rollout-grafana-dashboards` (`cicd/charts/fluxcd-custom/templates/helmrelease/`).
Any future exception must be listed here the same way.

Currently not in use under this rule: `infrastructure/charts/cloudnative-pg`, `infrastructure/charts/prometheus-rules`.

## In Repo But Not Deployed By Flux

| Path | State |
|---|---|
| `applications/charts/plane-ce` + `staging/plane-ce` + `rollout/plane-ce` | Rendered for `stag01`, **no Flux Kustomization**. Ingress disabled, no HTTPRoute. |
| `applications/rollout/kyoo-streaming`, `applications/rollout/minecraft-server` | Stale rendered output. Flux Kustomizations are commented out. Retired. |
| `applications/staging/job-aggregator (deprecated)` | Retired. Flux Kustomization commented out. |
| `applications/charts/garage-s3-moved-to-outside-cluster (deprecated)` | Retired. Garage now runs outside the cluster. |
| `infrastructure/charts/cloudnative-pg` | Duplicate of the app-side operator chart. No staging values, no rollout. Unused. |
| `infrastructure/charts/prometheus-rules` | Scaffold chart. No staging values, no rollout. Real rules live in `infrastructure/charts/alerting-stack/prometheus-rules/`. |

## Namespace Ownership

| Namespace | Created by |
|---|---|
| `kube-system` | Talos |
| `cert-manager` | `cert-manager` rollout |
| `monitoring` | `grafana-stack` rollout (other monitoring stacks assume it exists) |
| `stag01` | `applications/charts/cloudnative-pg` rollout (labels from `namespaceLabels` values, currently `privileged`) |
| `demo-app` | `applications/manifests/demo-app/demo-app.yaml` (Flux-labeled, so `protect-namespaces` blocks deleting it) |
| `longhorn-system` | **Manual**: `infrastructure/staging/longhorn/namespace.yaml` applied by hand |
| `flux-system` | `helm upgrade --install ... --create-namespace` at bootstrap |

## Render Pipeline

| Workflow | Trigger | What it renders |
|---|---|---|
| `render-manifest-infra.yml` | push to `infrastructure/staging/**/values.yaml` or `infrastructure/charts/**`, or manual | Charts whose **staging** folder changed. A chart-only change triggers the job but renders nothing, so use manual dispatch with `chart=<name>`. |
| `render-manifest-app.yml` | push to `applications/staging/**` or `applications/charts/**`, or manual | Same detection rule as infra. Supports `chart-source.yaml` (upstream chart pull). Manual "render all" breaks on `(deprecated)` folder names. |
| `render-grafana-dashboards.yml` | push to `infrastructure/charts/grafana-dashboards/**` | Bumps the chart patch version so the HelmRelease picks up changes. |
| `plane-prod-deploy.yml` | manual | Targets `applications/charts/plane` and `applications/staging/plane-prod`, which **do not exist yet**, so it fails at "Verify Plane sources". |

Namespace for `helm template` comes from `<chart>/meta.yaml` (`namespace:`), defaulting to `default`.
Commit uses `git add infrastructure/rollout/*.yaml` / `applications/rollout`; git pathspec globbing
covers the nested `rollout/<chart>/<chart>.yaml` files.

## Networking

- Cilium: kube-proxy replacement (KubePrism `localhost:7445`), Gateway API, BGP control plane, L2 announcements, Hubble relay + UI.
- `enable-policy: default` in rendered config: no default-deny anywhere.
- One shared HTTPS gateway `internal-monitoring-gateway` in `monitoring`, wildcard listener, TLS cert from `cert-manager`.
  Routes admitted from namespaces labeled `shared-gateway-access: "true"`.
- HTTPRoutes (all in `infrastructure/staging/cilium/values.yaml`): Grafana, Grafana Alloy, VictoriaLogs, VictoriaMetrics, Alertmanager, Hubble UI, Longhorn UI.
- LB IPs: `CiliumLoadBalancerIPPool` `default-pool` + `CiliumL2AnnouncementPolicy` `announce-lb`.

## Secrets

- Two `ClusterSecretStore`s: `infisical` and `infisical-r2`, both on plaintext HTTP to the external Infisical host. The HTTPS values are prepared but commented out.
- Chart supports `caBundle` / `caProvider` for the HTTPS move.
- Bootstrap secret `infisical-auth` is created manually (`infrastructure/charts/external-secrets/INSTALLATION.md`).
- Active ExternalSecrets: `discord-webhook`, `alertmanager-config` (monitoring), `plane-ce-doc-store` (stag01),
  and three `job-aggregator-*` secrets in `stag01` that are still enabled although the app is retired.

## Alerting

- `alerting-stack` (vmalert + Alertmanager) routes **everything** to one Discord receiver. No severity routing yet.
- Rules: `infrastructure/charts/alerting-stack/prometheus-rules/critical/{cluster,app}-critical.yaml`
  (node not ready, replica mismatch, PVC pending, job failures, crash loop, restarts, filesystem full, Cilium, Hubble relay, external target down, CNPG).
- Missing: Flux reconciliation failure alerts, runbook/dashboard annotations.

## Metrics Scraping

Alloy (`infrastructure/staging/grafana-stack/values.yaml`) only discovers ServiceMonitors/PodMonitors in listed
namespaces: ServiceMonitors in `monitoring`, `kube-system`, `longhorn-system`; PodMonitors in those plus `demo-app`.
A monitor in any other namespace is silently ignored. cAdvisor and pod logs are cluster-wide.

## Known Drift / Open Questions

- Flux `GitRepository` URL is `github.com/lynh7/home-talos-cluster`; the git remote is `github.com/lynh7/home-cluster`. It works only while GitHub's rename redirect holds.
- `templates/scripts/cluster-shutdown.sh` lists 3 control-plane + 2 worker IPs, `production-roadmap.md` describes a single worker. Confirm the real node count.

## External Dependencies (other repos)

| Dependency | Where | Used by |
|---|---|---|
| Infisical API (plain HTTP, host port 80) | Raspberry Pi 4 (`rasp4-node`), `lynh7/home-docker-compose` → `services/security-services.yml` | Both `ClusterSecretStore`s |
| node-exporter :9100 | same Pi, `services/monitoring-services.yml` | Alloy `external_nodes` scrape (`job=rasp4-node`) + `ExternalMonitoringTargetDown` |
| Tailscale subnet router + exit node for the home LAN | same Pi, `services/networking-services.yml` | Off-LAN admin access (already running; see `docs/hybrid-topology.md`) |
| Separate VictoriaMetrics/vmalert/Alertmanager → Discord | same Pi | Pi-local alerts + daily report. Independent of the cluster alerting-stack |
| Docusaurus sites | `lynh7/my-docusaurus`, served by nginx on the Pi | Not cluster-related |

If the Pi is down, the cluster keeps running, but ExternalSecrets stop refreshing and the `rasp4-node` scrape alerts.
