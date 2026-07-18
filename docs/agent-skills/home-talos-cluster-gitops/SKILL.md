---
name: home-talos-cluster-gitops
description: Repo-specific GitOps and CI/CD skill for the home-talos-cluster repo. Use when working on FluxCD bootstrap, GitRepository and Kustomization layout, rollout ordering, rendered manifest generation, GitHub Actions render workflows, or deciding whether a change belongs in charts, rollout output, or Flux bootstrap.
---

# Home Talos Cluster GitOps

This repo has 3 GitOps layers:

1. Helm source
   `infrastructure/charts/*`, `applications/charts/*`
2. Environment values
   `infrastructure/staging/*/values.yaml`, `applications/staging/*/values.yaml`
3. Deployed outputs and bootstrap
   `infrastructure/rollout/*`, `applications/rollout/*`, `cicd/charts/fluxcd*`

Treat any path or chart containing `(deprecated)` as retired unless the current staging values or rollout paths prove it is still active.

## Read First

- `README.md`
- `cicd/charts/fluxcd/values.yaml`
- `cicd/charts/fluxcd-custom/templates/gitrepository.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/infra-stacks/*.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/application/*.yaml`
- `.github/workflows/render-manifest-infra.yml`
- `.github/workflows/render-manifest-app.yml`

## Questions To Answer

- Does Flux deploy this stack at all
- Which path Flux reconciles
- Which chart or stack owns namespace creation
- Whether rollout order is explicit with `dependsOn` or implicit
- Whether change requires chart edit, values edit, render workflow fix, or Flux bootstrap fix

## Placement Rules

- Change to desired workload manifest:
  edit chart or staging values
- Change to committed rendered output format:
  fix render workflow or chart template
- Change to reconciliation order, stack selection, or bootstrap:
  edit `cicd/charts/fluxcd-custom`
- Change to Flux controller behavior:
  edit `cicd/charts/fluxcd/values.yaml`

## GitOps Red Flags

- Missing `dependsOn`
- Namespace created by one Kustomization, consumed by another
- Manual namespace YAML outside Flux path
- Workflow triggers only on `values.yaml`, not chart templates
- `git add` pattern missing nested rollout files
- Reading retired `(deprecated)` app paths as current deployment inputs

## Verify Before Answer

1. Confirm stack appears in `fluxcd-custom/templates/kustomization/*`
2. Confirm rollout path exists
3. Confirm namespace source
4. Confirm render workflow would publish change
5. Call out manual bootstrap secrets like Flux Git auth if relevant
