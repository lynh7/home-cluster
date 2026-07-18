# Infra Foundation

This document defines the baseline infrastructure shape that should exist regardless of roadmap stage.

## 1. Cluster Bootstrap

- make Talos bootstrap reproducible
- keep machine config generation or storage explicit
- define how a new control-plane or worker node joins from zero
- document recovery if a node is lost and rebuilt

## 2. Network Foundation

- keep Cilium as the networking layer
- keep Gateway API as the ingress path
- keep one shared gateway pattern unless a service has a strong reason to diverge
- decide how remote access works:
  - Talos VIP for home LAN control-plane access
  - Tailscale or NetBird for off-LAN admin access
- document what is LAN-only and what is VPN-accessible

## 3. Storage Foundation

- keep Longhorn as the storage baseline
- define default storage class behavior intentionally
- set replica policy intentionally
- plan backup target early
- prove restore, not just backup creation

## 4. Secrets Foundation

- keep External Secrets as the source of runtime secret sync
- move all secret transport to HTTPS
- keep secret values out of app values
- document secret ownership and trust path

## 5. GitOps Foundation

- keep chart source, values, and rendered output clearly separated
- make render-to-git deterministic
- validate before render commit
- pin CI tooling versions
- make workflow outputs easy to inspect and diff
- add explicit Flux dependency ordering where needed

## 6. Observability Foundation

- keep metrics, logs, and alerting as first-class infra
- define a cluster health view
- define a data-safety view
- define a service-availability view
- add blackbox checks for the cluster edge
- add runbook links for important alerts

## 7. Policy Foundation

- add Pod Security Admission labels
- add default-deny networking by namespace when ready
- add service account and RBAC tightening
- add Cilium policy in a centralized way, not scattered per app

## 8. Recovery Foundation

- document:
  - node replacement
  - cluster bootstrap
  - secret recovery
  - storage restore
  - DNS/cert recovery
  - host failure response
- run restore drills on a schedule
- treat DR as a real capability, not a note

## 9. Capacity / Expansion Foundation

- track node and provider usage
- if cloud VMs are added, define the join process first
- make nodes disposable and rejoinable
- keep free-tier or cost guardrails visible

## 10. Documentation Foundation

- keep `README.md` high-level
- keep TODOs split by concern
- keep retired things clearly labeled as retired
- maintain one infra roadmap that reflects current state only
