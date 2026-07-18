# Production-Like Roadmap

This roadmap is tuned for the current homelab shape:

- Talos Linux cluster
- Proxmox host
- worker running on `i5-8250U`, `32GB RAM`, `512GB SSD`
- current platform already uses Cilium, cert-manager, External Secrets, Longhorn, CloudNativePG, Grafana, VictoriaMetrics, and VictoriaLogs

The goal is not fake enterprise complexity. The goal is:

1. reliable enough for daily use
2. secure enough to trust with real workloads
3. observable enough to keep running with low stress
4. cheap enough that hosted workloads offset power cost

## Current Assessment

| Aspect | Current | Target | Notes |
|---|---:|---:|---|
| Architecture maturity | 79 | 86 | good structure already, needs clearer trust zones and service placement discipline |
| Security baseline | 63 | 82 | strong components, weak policy enforcement and secret transport |
| Zero-trust posture | 52 | 78 | needs default-deny, stronger identity boundaries, runtime detection |
| Networking | 84 | 89 | Cilium stack already strong |
| Observability | 81 | 92 | good metrics/logs, missing runtime security, tracing, blackbox, operator views |
| Secrets management | 74 | 88 | good model, currently held back by plaintext Infisical path |
| Storage / data safety | 70 | 82 | needs recurring backups and restore drills |
| Reliability / HA | 41 | 62 | single host and single worker remain hard limits |
| Disaster recovery | 46 | 80 | backup/restore process must be proven |
| Operational discipline | 78 | 90 | repo structure good, needs runbooks, alerts, and review gates |
| Production-likeness | 66 | 82 | achievable without pretending this is true HA |
| Business usefulness | 55 | 85 | cluster should host fewer but more valuable workloads |

## Hard Limits

The cluster can become much more production-like, but some limits remain until hardware changes:

- one physical Proxmox host is a single failure domain
- one worker limits scheduling resilience
- one SSD limits storage fault tolerance
- power/network issues on the host affect everything at once

These limits do not block meaningful progress. They only cap the maximum achievable resilience score.

## Principles

### Prefer useful over impressive

Do not add tools just because they are popular.

Every component should improve at least one of:

- service reliability
- security posture
- debugging speed
- backup confidence
- direct savings or workflow value

### Treat stateful services seriously

The following should be treated as real infrastructure, not playground apps:

- Infisical
- Longhorn
- CloudNativePG
- Grafana / Victoria stack

### Keep the stack small where possible

The current stack is already rich. The next gains come mostly from:

- better policy
- better alerting
- better backup discipline
- better dashboards

Not from adding ten more platforms.

## Phased Roadmap

## Phase 1: Baseline Hardening

Target outcomes:

- secrets are never fetched over plaintext HTTP
- namespaces have a real default security baseline
- east-west traffic is intentionally allowed instead of implicitly trusted
- app service accounts are scoped tightly

### 1.1 Secure External Secrets to Infisical

Current state:

- External Secrets uses `http://192.168.10.99/`

Target state:

- move Infisical API access to HTTPS
- use trusted internal CA or cert-manager issued certificate
- restrict traffic so only External Secrets can reach Infisical on the required port
- document certificate ownership and renewal path

Expected impact:

- security baseline +8
- zero-trust +6
- secrets management +8

### 1.2 Enforce Pod Security Admission

Target state:

- label app namespaces for Pod Security Admission
- default to `restricted`
- explicitly document any namespaces requiring elevated privileges

Start with:

- the current application namespace(s)
- future app namespaces

Be cautious with:

- `kube-system`
- `longhorn-system`
- `cert-manager`
- `monitoring`

### 1.3 Add policy enforcement with Kyverno

Recommended baseline policies:

- require `runAsNonRoot`
- require resource requests and limits
- disallow privileged mode by default
- disallow `hostPath`, `hostPID`, `hostIPC`, `hostNetwork` unless exempted
- require liveness/readiness probes for app workloads
- restrict image registries to approved sources
- require standard labels such as owner, environment, purpose

### 1.4 Move namespaces to default-deny networking

Start with application namespaces first.

Recommended order:

1. current application namespace(s)
2. new application namespaces
3. selective restrictions in `monitoring`

Minimum explicit allow rules:

- DNS
- ingress gateway -> app
- app -> CNPG
- app -> external APIs required by the workload
- monitoring scrape paths where necessary

### 1.5 Review RBAC and service accounts

Target state:

- one service account per app where practical
- `automountServiceAccountToken: false` by default
- remove unnecessary ClusterRoleBindings
- narrow namespace scope where possible

## Phase 2: Observability That Reduces Stress

Target outcomes:

- operator can identify failures in under five minutes
- service health is visible from the outside, not only from pod status
- data safety is visible continuously

### 2.1 Create five operator views

#### A. Cluster Health

Questions answered:

- Is the cluster healthy right now?
- Is the issue node, network, storage, or control plane?

Suggested panels:

- node readiness
- CPU and memory pressure
- pod restart rate
- pending pods
- Cilium health
- Longhorn health
- API server health if available
- cert expiry summary

#### B. Service Availability

Questions answered:

- Which important service is down or degraded?
- Is ingress failing or the app itself?

Suggested checks:

- Grafana
- Infisical
- CNPG endpoint
- Gateway API public/internal endpoints
- any current customer-facing or daily-use service

#### C. Data Safety

Questions answered:

- Are backups fresh?
- Are volumes healthy?
- What would be lost if the host dies today?

Suggested panels:

- Longhorn volume health
- PVC usage growth
- backup job success rate
- latest backup age
- CNPG backup status when added

#### D. Security View

Questions answered:

- Did anything drift?
- Did anything suspicious run?

Suggested data sources:

- Kyverno policy violations
- Trivy findings
- Tetragon runtime events
- unexpected privileged pods

#### E. Value / Cost View

Questions answered:

- Which workloads justify the cluster?
- Which workloads consume resources without daily value?

Suggested panels:

- CPU and RAM by namespace
- storage by PVC
- requests or active users for major services
- workload last-use / request trends where available
- estimated cloud or SaaS cost avoided

### 2.2 Add blackbox monitoring

Blackbox checks should cover:

- `grafana.cluster...`
- Infisical API
- CNPG reachable endpoint where safe
- DNS resolution
- TLS expiry
- gateway address `192.168.100.1`
- internet egress health

This catches failures that pod-level health checks miss.

### 2.3 Add traces with OpenTelemetry Collector

Suggested approach:

- deploy OpenTelemetry Collector in cluster
- start with traces only
- instrument one high-value service path first
- add Tempo later only if traces become useful enough to justify it

Good first candidate:

- one current production-like app request path and database latency correlation

## Phase 3: Runtime Security and Compliance

Target outcomes:

- runtime activity inside pods is visible
- suspicious behavior is alertable
- vulnerability drift is tracked continuously

### 3.1 Add Tetragon

Recommended rollout:

- start in observe-only mode
- begin with selected namespaces
- alert on:
  - shell execution in app pods
  - unexpected binaries
  - privilege changes
  - sensitive file access
  - anomalous network behavior

Move to enforcement only after several weeks of clean signal review.

### 3.2 Add Trivy Operator

Use it for:

- vulnerability reports
- config audit reports
- RBAC assessment
- secret scan findings
- compliance trend tracking

### 3.3 Add Cilium service mesh selectively later

Only add this when there is a real need for:

- richer east-west L7 control
- service-to-service identity
- traffic shifting or canary behavior
- better service-level observability than current Hubble/Gateway API coverage

Do not start by meshing the entire cluster.

Good starting scope:

- one current application namespace
- one future internal app namespace

Avoid first rollout in:

- `kube-system`
- `longhorn-system`
- `cert-manager`

## CI/CD Baseline

This repository can stay render-to-git without adding a promotion gate, but the render path should still be deterministic and validated.

Target outcomes:

- rendered manifests stay reproducible
- chart changes cannot bypass validation
- the render-to-git flow remains simple enough for one operator
- rollout diffs are easy to review and debug

Recommended checks:

- `helm lint`
- `helm template`
- manifest validation against the cluster schema
- basic policy or schema checks where practical

Render workflows should react to both:

- `*/charts/*`
- `*/staging/*/values.yaml`

This avoids a drift where template edits do not regenerate rollout output.

Avoid downloading CI helpers from floating `latest` URLs.

Prefer pinned versions for:

- Helm setup actions
- `yq`
- any validation binaries used in render jobs

Keep the render commit, but make it clearly machine-generated and easy to inspect.

Good signals:

- a short diff summary in CI
- deterministic file paths
- explicit failure when render output is empty or malformed

After render or apply, verify the expected service shape exists.

Useful checks:

- namespace exists
- expected workload objects were rendered
- ingress or gateway objects reference the intended hostnames
- basic HTTP or readiness smoke check for exposed apps

## Phase 4: Backup, Restore, and Recovery Confidence

Target outcomes:

- every important stateful workload has recurring backups
- restores are tested, not assumed
- failure recovery steps are documented

### 4.1 Longhorn backup target

Required:

- S3-compatible backup target
- recurring snapshots
- recurring off-node backups
- alerts on backup failures

### 4.2 CNPG backup plan

Required:

- regular backups for CNPG
- retention policy
- restore test into temporary namespace or test cluster

### 4.3 Monthly restore drills

At least monthly:

- restore one Longhorn-backed PVC into a temporary namespace
- restore one CNPG backup
- confirm the restored workload can start or the data can be queried

### 4.4 Recovery documents

Create explicit docs for:

- cluster bootstrap path
- node replacement
- Longhorn restore
- CNPG restore
- Infisical / secret recovery
- DNS / certificate recovery
- Proxmox host failure response

## Phase 5: Make It Pay For Itself

Target outcomes:

- the cluster runs a short list of high-value workloads
- low-value apps are removed or deprioritized
- resource usage maps to real savings or productivity

## Workload Selection Rule

Any workload promoted from playground to serious use should score itself on:

| Question | Max |
|---|---:|
| used at least 3 times per week | 20 |
| replaces paid SaaS or cloud cost | 20 |
| saves real time | 20 |
| reliable enough to trust | 20 |
| easy to monitor and support | 20 |

Interpretation:

- `<60`: playground only
- `60-79`: useful but not critical
- `80+`: deserves production treatment

## High-value workload classes

Good candidates for serious hosting:

- password and secret workflows
- personal/work file and media systems already in active use
- private dashboards and monitoring for services or side projects
- lightweight internal CI runners or automation jobs
- documentation, search, or knowledge tools used weekly
- backup/archive services

Low-value candidates:

- novelty apps with no weekly use
- apps with heavy operational burden but little payoff
- overlapping tools that duplicate existing workflows

## Suggested 30 / 60 / 90 Day Plan

## Next 30 days

1. move Infisical path to HTTPS
2. add Pod Security Admission labels
3. add Kyverno baseline policies
4. add default-deny policy for the active application namespace
5. add blackbox monitoring
6. create top-level cluster health dashboard
7. configure Longhorn backup target

Expected result:

- overall maturity moves from roughly `71` to `78`

## Next 60 days

1. add Tetragon in observe-only mode
2. add Trivy Operator
3. create restore drill process for Longhorn and CNPG
4. build service availability dashboard
5. build data safety dashboard
6. build security dashboard

Expected result:

- overall maturity moves from roughly `78` to `83`

## Next 90 days

1. choose one high-value daily-use workload and treat it as production
2. optionally trial Cilium mesh in one namespace
3. tune alerts to reduce noise
4. build capacity dashboard
5. build cost/value dashboard
6. write runbooks for the top five likely incidents

Expected result:

- overall maturity moves from roughly `83` to `86`

## Hardware Phase

When budget allows, best next hardware move is not more tools. It is another failure domain.

Priority order:

1. second physical host
2. off-host backup target
3. broader node spread for stateful services
4. optional control-plane resilience improvement if not already present elsewhere

This phase raises reliability more than any software-only addition.

## Current vs Retired

Current platform primitives:

- Cilium
- cert-manager
- External Secrets
- Longhorn
- CloudNativePG
- Grafana / Victoria stack

Retired or historical app names in this repo:

- `job-aggregator`
- `kyoo-streaming`
- `minecraft-server`

Treat retired names as historical only unless current staging values and rollout output bring them back.

## Concrete Next Artifacts To Add In Repo

Recommended future additions under this repo:

- `docs/runbooks/` for incident procedures
- `docs/recovery/` for restore instructions
- `infrastructure/charts/kyverno/`
- `infrastructure/charts/tetragon/`
- `infrastructure/charts/trivy-operator/`
- `infrastructure/charts/blackbox-exporter/` or equivalent monitoring integration
- `infrastructure/charts/opentelemetry-collector/`

## Success Criteria

The cluster is moving in the right direction when all of the following become true:

- daily-use services are trusted enough to depend on
- alerts are actionable and low-noise
- major outages can be diagnosed quickly
- backups are tested regularly
- risky workloads are isolated from critical ones
- total workload set is small, intentional, and useful
