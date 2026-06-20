---
name: home-talos-cluster-networking
description: Repo-specific networking skill for the home-talos-cluster repo. Use when working on Cilium, Gateway API, Hubble, BGP, L2 announcements, LoadBalancer IP pools, ingress routing, service exposure, LAN access, or dynamic network policy placement.
---

# Home Talos Cluster Networking

Cilium is network platform in this repo. Networking answers must start from Cilium values, custom templates, and Flux deployment path.

## Read First

- `README.md`
- `infrastructure/staging/cilium/values.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/48-cilium-gateway.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/49-cilium-l2-policy-announcement.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/50-cilium-loadbalancer-ippool.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/51-cilium-http-route.yaml`
- `infrastructure/charts/cilium/templates/cilium-customizations/52-cilium-reference-grant-template.yaml`
- `infrastructure/rollout/cilium/cilium.yaml`
- `cicd/charts/fluxcd-custom/templates/kustomization/infra-stacks/cilium.yaml`

## Current Model

- Cilium provides kube-proxy replacement
- Gateway API enabled
- BGP control plane enabled
- L2 announcements enabled
- Hubble relay and UI enabled
- Shared gateway pattern used for internal HTTP tools
- LoadBalancer IPs come from Cilium pool, not cloud controller

## Use This Skill For

- Where to place new ingress or HTTPRoute
- Whether service should use Gateway API or direct LoadBalancer
- How shared gateway namespaces are granted access
- How to model dynamic `CiliumNetworkPolicy`
- Which traffic is cluster-internal vs LAN-facing
- How monitoring or external-secret traffic crosses namespaces or leaves cluster

## Placement Rules

- Shared gateway, routes, LB pools, L2 policy:
  `infrastructure/charts/cilium/templates/cilium-customizations/*`
- Cilium feature flags and cluster-wide networking config:
  `infrastructure/staging/cilium/values.yaml`
- App-specific labels/selectors for policy:
  app chart templates or values

## Policy Guidance

- Check `enable-policy` in rendered Cilium config before claiming cluster is default-deny
- Prefer centralized dynamic policy model over ad hoc policy per rollout file
- Use stable labels:
  `app.kubernetes.io/name`
  `app.kubernetes.io/instance`
  `app.kubernetes.io/component`
- Check namespace labels such as `shared-gateway-access`

## Red Flags

- Assuming cloud LB controller exists
- Assuming ingress-nginx pattern
- Mixing Gateway API and ad hoc ingress without reason
- Recommending policy in `rollout/*`
- Forgetting external LAN dependencies on `192.168.10.x`
