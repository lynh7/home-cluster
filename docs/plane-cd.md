# Plane CD Design

This document defines the CD flow for Plane only.

## Goal

- `plane-dev` deploys automatically
- `plane-prod` deploys only after an explicit click in GitHub Actions or a GitHub Environment approval
- keep one Plane chart, two env values, two rollout outputs
- keep secrets externalized through External Secrets
- keep the render-to-git model, but make the deployment path explicit per environment

## Repo Layout

```text
applications/
  charts/
    plane/
  staging/
    plane-dev/
      values.yaml
      chart-source.yaml
    plane-prod/
      values.yaml
      chart-source.yaml
  rollout/
    plane-dev/
      plane-dev.yaml
    plane-prod/
      plane-prod.yaml
```

## Environment Split

### `plane-dev`

- automatic deploy
- 4 GB RAM limit
- unstable by design
- used for configuration, testing, and upgrades
- can accept experimental values and frequent changes

### `plane-prod`

- manual deploy only
- 6 GB RAM limit
- stable by default
- used for the customer-facing or daily-use instance
- no automatic rollout from a plain git push

## Trigger Matrix

| Event | plane-dev | plane-prod |
|---|---|---|
| push to `main` touching `applications/charts/plane/**` | render and commit automatically | no action |
| push to `main` touching `applications/staging/plane-dev/**` | render and commit automatically | no action |
| push to `main` touching `applications/staging/plane-prod/**` | no action | no action |
| manual `workflow_dispatch` for `plane-dev` | allowed | no action |
| manual `workflow_dispatch` for `plane-prod` | no action | allowed |
| GitHub Environment approval | optional | required |

## Workflow Shape

### Shared validation

Run for both envs:

- `helm lint`
- `helm template`
- lightweight manifest validation
- diff summary before commit

### `plane-dev` workflow

- trigger automatically on merge to `main`
- render the dev env
- validate the rendered manifests
- print a diff summary
- commit `applications/rollout/plane-dev/plane-dev.yaml`
- Flux applies the new state

### `plane-prod` workflow

- trigger manually from GitHub Actions
- require a GitHub Environment approval gate
- render the prod env
- validate the rendered manifests
- print a diff summary
- commit `applications/rollout/plane-prod/plane-prod.yaml`
- Flux applies after the approved commit lands

## Secret Flow

- app values only reference secret names
- External Secrets holds the actual secret material
- keep separate names for dev and prod
  - `plane-dev-*`
  - `plane-prod-*`
- do not let dev deploys touch prod secrets

## Operational Rules

- do not share namespaces
- do not share databases or database users
- do not share object storage credentials
- do not share runtime credentials
- keep dev and prod as separate releases, not just separate values

## Suggested GitHub Setup

- use one workflow file or two workflow files, either is acceptable
- use GitHub Environments for `plane-prod`
- require reviewers or a manual approval click for the prod environment
- keep `plane-dev` unblocked for fast iteration

## Relationship To Other Docs

- read [read-me-first.md](./read-me-first.md) for doc routing
- read [infra-foundation.md](./infra-foundation.md) for the platform baseline
- read [hybrid-topology.md](./hybrid-topology.md) for cloud extension shape
