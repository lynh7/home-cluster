# Read Me First

Use this document to choose the right doc before making changes.

## `production-roadmap.md`

- Purpose: define the path from the current home-server state toward a more production-like platform.
- Scope: maturity, hardening, observability, policy, DR, operational readiness.
- Tone: what should we improve next?

## `infra-foundation.md`

- Purpose: define the minimum infrastructure base that should exist regardless of roadmap stage.
- Scope: bootstrap, networking, storage, secrets, GitOps, recovery, capacity, docs.
- Tone: what must exist for the platform to be a solid foundation?

## `hybrid-topology.md`

- Purpose: define the home-plus-cloud deployment shape when adding Hetzner, Vultr or OCI nodes.
- Scope: node roles, private connectivity, join flow, provider guardrails, and capacity tracking.
- Tone: how should home and cloud pieces fit together?

## `plane-cd.md`

- Purpose: define the Plane-only CD flow for `plane-dev` and `plane-prod`.
- Scope: workflow split, approval behavior, render targets, and secret flow.
- Tone: how should Plane deploy differently in dev and prod?

## When To Read Which

- Read `infra-foundation.md` when deciding whether the platform base is complete.
- Read `hybrid-topology.md` when adding cloud VMs or defining how home and cloud nodes relate.
- Read `plane-cd.md` when implementing Plane deployment workflows.
- Read `production-roadmap.md` when deciding what improvement comes next.
- Read both when planning changes that affect bootstrap, GitOps, recovery, or cluster-wide behavior.
