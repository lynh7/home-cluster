# TODO

## Plane Self-Hosting Follow-up

### Current Direction

- Use one Kubernetes cluster with two Plane environments:
  - `plane-dev` for testing, configuration, and unstable changes
  - `plane-prod` for stable day-to-day use
- Keep render-to-git for now, but make the pipeline deterministic and validation-heavy
- Do not add a promotion gate for this setup
- Treat uptime measurement as an external Docker Compose concern, not a cluster concern
- Keep secret material in External Secrets, not in app values

### Repo Layout For Plane

- [ ] Create `applications/charts/plane/`
- [ ] Create `applications/staging/plane-dev/values.yaml`
- [ ] Create `applications/staging/plane-prod/values.yaml`
- [ ] Add `chart-source.yaml` only if Plane comes from an upstream chart source
- [ ] Keep rollout output separated by env:
  - `applications/rollout/plane-dev/`
  - `applications/rollout/plane-prod/`
- [ ] Keep the Plane app chart secret-aware by reference only

### Secret Flow

- [ ] Keep DB passwords, admin tokens, object storage credentials, SMTP creds, and webhooks in External Secrets
- [ ] Use stable env-specific secret names:
  - `plane-dev-db-credentials`
  - `plane-prod-db-credentials`
  - `plane-dev-object-storage`
  - `plane-prod-object-storage`
- [ ] Keep app values limited to secret names, not secret values
- [ ] Add the actual secret sync entries to `infrastructure/staging/external-secrets/values.yaml`

### Environment Isolation

- [ ] Use separate namespaces:
  - `plane-dev`
  - `plane-prod`
- [ ] Use separate hostnames:
  - `plane-dev.<domain>`
  - `plane.<domain>`
- [ ] Use separate databases or at minimum separate DBs/users
- [ ] Use separate object storage prefixes or buckets
- [ ] Avoid sharing runtime credentials across envs

### CI/CD Improvements

- [ ] Validate before render:
  - `helm lint`
  - `helm template`
  - schema or manifest validation
  - basic policy checks where practical
- [ ] Trigger renders from both chart changes and values changes
- [ ] Pin CI tooling versions
  - no floating `latest` downloads
  - pin `yq`
  - pin Helm setup action versions
- [ ] Make generated output obvious and machine-owned
- [ ] Add lightweight post-render checks
  - namespace exists
  - expected workload objects were rendered
  - ingress or gateway objects point at the intended hostnames
  - basic readiness or HTTP smoke checks

### Tomorrow's First Pass

- [ ] Draft Plane folder structure in the repo style
- [ ] Map Plane secrets into External Secrets
- [ ] Decide whether Plane should use CNPG or an external DB pattern
- [ ] Decide how to keep dev/prod config separate without copying too much
- [ ] Update the Plane-specific docs before implementation

## Discord And Alerting

### Goal

Provide useful daily status and actionable alerts in Discord without coupling this work to AI or broad ChatOps.

### Decisions

- Do not include AI in this track.
- Keep ChatOps as optional follow-up, not part of initial implementation.
- Treat Discord notifications and network policy as separate workstreams.

### Phase 1: Alerting Foundation

- [ ] Review current `Alertmanager` path in `alerting-stack` and `prometheus-stack`
- [ ] Add Discord webhook receiver for real-time alerts
- [ ] Define severity routing model for `info`, `warning`, `critical`
- [ ] Standardize alert annotations:
  - `summary`
  - `description`
  - `impact`
  - `investigate`
  - `dashboard_url`
  - `runbook_url`
- [ ] Review existing alert rules and remove low-value noise
- [ ] Add missing alerts for:
  - node readiness
  - pod crash loops
  - failed jobs
  - PVC/storage pressure
  - Flux reconciliation failures
  - Cilium / gateway health
  - external dependency failures where detectable

### Phase 2: Daily Discord Status

- [ ] Add one small daily digest service or CronJob
- [ ] Post one daily cluster summary to Discord
- [ ] Include at minimum:
  - node health
  - not-ready workloads
  - restart spikes
  - failed jobs in last 24h
  - storage/PVC pressure
  - recent alert count by severity
  - Flux health
  - ingress/gateway exposure health
- [ ] Link digest items to dashboards where possible
- [ ] Keep summary human-readable, short, and actionable

### Phase 3: Runbooks And Detail Quality

- [ ] Add runbook links for important alerts
- [ ] Ensure each high-severity alert has:
  - user impact
  - likely cause
  - first checks to run
  - dashboard link
- [ ] Validate that daily summary still makes sense when viewed without Grafana open

### Optional Follow-up: ChatOps

- [ ] Re-evaluate whether Discord ChatOps is worth adding
- [ ] If yes, start read-only only
- [ ] Prefer fixed commands over free-form command execution
- [ ] Prefer Flux-oriented operations over raw mutable cluster actions
- [ ] Require explicit RBAC scope and audit trail before any write actions

## Network Policies

### Goal

Add centralized north/south and east/west policy management with Cilium, separate from Discord/alerting work.

### Design

- [ ] Create dedicated network policy workstream
- [ ] Decide whether to use:
  - separate `infrastructure/charts/network-policies`
  - or extend `infrastructure/charts/cilium`
- [ ] Prefer centralized `CiliumNetworkPolicy` / `CiliumClusterwideNetworkPolicy`
- [ ] Avoid scattering policy logic across app rollout output

### Phase 1: Baseline And Discovery

- [ ] Inventory traffic flows by namespace:
  - `monitoring`
  - `stag01`
  - `minecraft`
  - `longhorn-system`
  - `kube-system`
- [ ] Use Hubble to observe current east/west and north/south flows
- [ ] Document required external egress:
  - Infisical host
  - DNS
  - Kubernetes API
  - LAN scrape targets
  - any package or image endpoints if relevant

### Phase 2: Baseline Policies

- [ ] Add namespace baseline policies for `stag01`
- [ ] Add namespace baseline policies for `monitoring`
- [ ] Add namespace baseline policies for `minecraft`
- [ ] Decide whether `longhorn-system` should be delayed or modeled early
- [ ] Add explicit DNS and kube-apiserver access rules

### Phase 3: North/South Controls

- [ ] Restrict ingress to gateway-managed services where applicable
- [ ] Restrict direct `LoadBalancer` exposure to approved services only
- [ ] Add explicit egress policies for LAN and external dependencies
- [ ] Review shared gateway namespace access model

### Phase 4: East/West Controls

- [ ] Default deny internal traffic by namespace where safe
- [ ] Add app-to-app allow rules for Kyoo and CNPG
- [ ] Add monitoring scrape allowances only where needed
- [ ] Review storage and control-plane exceptions carefully

### Phase 5: Rollout Safety

- [ ] Add policy deployment order in Flux
- [ ] Ensure Cilium and namespace owners reconcile before policy layer
- [ ] Roll out namespace by namespace
- [ ] Validate denied flows before tightening further
- [ ] Revisit stronger Cilium policy enforcement after stable allowlists exist

## GitOps Follow-up

These are important because both Discord/alerting and policy work depend on reliable rollout behavior.

- [ ] Add explicit Flux `dependsOn` where stacks depend on namespace or operator readiness
- [ ] Review manual namespace ownership, especially `longhorn-system`
- [ ] Review whether all intended stacks are actually deployed by Flux
- [ ] Fix render workflow scope so chart/template changes regenerate rollout output
- [ ] Verify workflow commit paths cover nested `rollout/*/<chart>.yaml` files
