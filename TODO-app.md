# TODO - App

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

## App Docs Cleanup

- [ ] Keep `README.md` high-level only
- [ ] Keep retired workloads out of active guidance
- [ ] Treat any path with `(deprecated)` as historical unless current values prove otherwise
- [ ] Keep retired app names in a short appendix only:
  - `job-aggregator`
  - `kyoo-streaming`
  - `minecraft-server`
