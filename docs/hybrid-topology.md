# Hybrid Topology

This document defines how the home cluster and cloud VMs should fit together when expanding beyond the LAN.

## Goal

- keep the home cluster as the primary anchor
- add cloud VMs only as deliberate extensions
- preserve simple recovery and rejoin behavior
- avoid mixing provider-specific assumptions into the core home bootstrap flow

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
- pick one of:
  - Tailscale
  - NetBird
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
