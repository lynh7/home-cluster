# Hybrid Topology

This document defines how the home cluster and cloud VMs should fit together when expanding beyond the LAN.

## Goal

- keep the home cluster as the primary anchor
- add cloud VMs only as deliberate extensions
- preserve simple recovery and rejoin behavior
- avoid mixing provider-specific assumptions into the core home bootstrap flow

## Decided Shape (2026-10-04, not built yet)

| Mode | Nodes | Cost |
|---|---|---|
| always | `master-0` (home Raspberry Pi 4): the single control plane, keeps its NoSchedule taint, no extra control plane for now | power only |
| **half** | + one Oracle Cloud Always Free A1 worker in Singapore, 2 OCPU / 12 GB arm64 (the whole free A1 allowance): Flux, monitoring, stateful apps | $0 |
| **full** | + Vultr Singapore workers (amd64) on demand, tainted `ephemeral=true:NoSchedule`, never storage | hourly, only while up |

- Node-to-node traffic: Talos **KubeSpan** (WireGuard mesh, peers via the discovery service). The home control plane stays behind NAT; only UDP 51820 is open on the cloud side. No public Talos or Kubernetes API.
- Admin access: Tailscale (already on the Pi), not used for node-to-node traffic.
- Terraform (OpenTofu with state encryption, state in its own R2 bucket): `oracle/oci`, `vultr/vultr`, `siderolabs/talos`; `var.mode = "half" | "full"`. Worker configs come from the existing cluster secrets, passed as a sensitive variable, never committed.
- Vultr was chosen for on-demand nodes because `vultr_snapshot_from_url` imports the Talos Image Factory image inside Terraform; Hetzner is cheaper but needs a separate image upload step.
- Single control plane: ship etcd snapshots off the cluster; workers must be rebuildable from zero.
- Mixed arm64/amd64: multi-arch images or arch node selectors.
- Steps and status: home-server TODO (`claude-shared` → `skills/home-server/TODO.md` → Cluster expansion).

## Recommended Shape

### Home site

- keep the home Talos cluster as the stable base
- keep Talos VIP for home LAN control-plane access
- keep the home network as the place where core cluster ownership lives

### Cloud extension

- add OCI, Hetzner, or Vultr VMs as disposable Talos nodes
- start with workers first
- only add control-plane nodes if the private connectivity and recovery story is strong
- treat cloud nodes as capacity or placement expansion, not as the only cluster home

## Connectivity

- use a private access layer between home and cloud
- current state: Tailscale already runs on the Raspberry Pi (home-docker-compose `services/networking-services.yml`), advertising the home LAN route and acting as an exit node
- decided: KubeSpan for node-to-node traffic, Tailscale for admin access (NetBird not needed)
- keep Talos API, Kubernetes API, and admin access on the private path
- do not depend on public internet reachability for node management

## Join Flow

- generate Talos configs reproducibly
- boot the VM
- apply the matching worker or control-plane config
- let the node join automatically
- verify the node can be rebuilt from zero

## Provider Guardrails

### OCI

- Always Free A1 is 2 OCPU / 12 GB in total (also on Pay-As-You-Go), at least 1 OCPU per VM; 200 GB block storage incl. boot disks (47 GB min each); 1 flexible LB (10 Mbps); 10 TB/month egress
- idle reclaim only if CPU, network and memory all stay under 20% for 7 days; A1 capacity in Singapore can be "out of host capacity" (retry)
- track free-tier or paid-tier usage explicitly
- keep instance count, size, and age visible
- watch for quota or idle-reclamation behavior if you rely on free capacity

### Hetzner

- treat Hetzner as a cost-optimized provider with Singapore availability
- track instance count, size, and age
- track resource and cost drift explicitly
- verify smaller instances stay stable under Talos and cluster load

### Vultr

- treat Vultr as the cloud expansion provider, not the cluster home
- track instance count, size, and age
- track resource and cost drift explicitly
- verify smaller instances stay stable under Talos and cluster load

## Capacity Tracking

- track instance count by provider
- track VM shape and age
- track CPU, memory, and network utilization
- track whether any paid IPs or add-ons were introduced
- alert on drift away from the intended cost envelope

## Failure Model

- assume cloud nodes can disappear
- assume home can disappear
- assume the private network can break
- make sure each node type can be rejoined or replaced without special manual steps

## Relationship To Other Docs

- read [infra-foundation.md](./infra-foundation.md) for the baseline platform shape
- read [production-roadmap.md](./production-roadmap.md) for the improvement path
- read this doc when deciding where home ends and cloud begins
