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

## When To Read Which

- Read `infra-foundation.md` when deciding whether the platform base is complete.
- Read `production-roadmap.md` when deciding what improvement comes next.
- Read both when planning changes that affect bootstrap, GitOps, recovery, or cluster-wide behavior.
