# Home Cluster

Kubernetes side of the home server (Talos, Flux GitOps). Agent guidance for this repo.

## Start Here

- `docs/current-state.md`: verified facts on what Flux actually reconciles, namespace owners, render behavior, external dependencies, and drift.
  Update it whenever you change Flux wiring, workflows, or retire/add a stack.
- `README.md` for the high-level shape; `docs/read-me-first.md` to route to roadmap / foundation / hybrid / Plane docs.

Workflow guidance and the single home-server TODO list live in the `home-server` skill of the private `claude-shared` repo
(`skills/home-server/`). Repo-level TODO files and `docs/agent-skills/` were retired in favor of it.

## Working Rules

1. Read `README.md` first for architecture questions.
2. Treat `charts/*` and `staging/*/values.yaml` as source of truth.
3. Treat `rollout/*` as generated output that Flux applies.
4. Check `cicd/charts/fluxcd-custom/templates/*` before assuming Flux deploys a stack.
   A chart under `infrastructure/charts/<name>` with no `infrastructure/rollout/<name>/` is **not in use**
   (only exception: `grafana-dashboards`, deployed as a Flux HelmRelease; see `docs/current-state.md`).
5. Surface manual or external dependencies explicitly.
6. For networking or policy work, inspect Cilium values and templates before proposing structure.
7. For GitOps changes, inspect both Flux Kustomizations and render workflows.

## Repo Boundaries

- Talos machine configs not stored here
- Router and firewall not stored here
- Some supporting services run outside Kubernetes
- Not every chart in repo is necessarily deployed by Flux
- Chart under `infrastructure/charts/<name>` without `infrastructure/rollout/<name>/` is not in use (exception: `grafana-dashboards`, a Flux HelmRelease)
