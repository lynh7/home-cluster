# TODO

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
