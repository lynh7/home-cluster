#!/bin/bash
set -e

# Node IPs match home-talos-configuration/tks-cluster/*.yaml (1 control plane + 2 workers).
MASTER_NODE_0="${MASTER_NODE_0:-192.168.10.50}"
WORKER_NODE_0="${WORKER_NODE_0:-10.10.0.30}"
WORKER_NODE_1="${WORKER_NODE_1:-10.20.0.30}"

function shutdown_log() {
  echo -e "\033[1;33m[SHUTDOWN]\033[0m $1"
}

# talosctl shutdown cordons and drains the node before powering it off.
function shutdown_node() {
  local name="$1" ip="$2"
  shutdown_log "   Checking $name ($ip) connectivity..."
  if talosctl --nodes "$ip" version &> /dev/null; then
    shutdown_log "   Shutting down $name..."
    talosctl shutdown --nodes "$ip" || {
      shutdown_log "$name shutdown failed"
    }
  else
    shutdown_log "   $name is already stopped or unreachable, skipping..."
  fi
}

function shutdown_cluster() {
  clear
  shutdown_log "Shutting down cluster (VMs only)..."

  shutdown_log "1️⃣  Workers..."
  shutdown_node "worker-1" "$WORKER_NODE_1"
  shutdown_node "worker-0" "$WORKER_NODE_0"

  shutdown_log "2️⃣  Waiting 20 seconds to allow workers to stop gracefully..."
  sleep 20

  shutdown_log "3️⃣  Control plane..."
  shutdown_node "master-0" "$MASTER_NODE_0"

  shutdown_log "✅ All Talos nodes shutdown sequence completed."
  shutdown_log "ℹ️  You can monitor shutdown status in Proxmox or using 'talosctl dmesg --nodes <ip>'."
  echo ""
}

# Main execution
shutdown_cluster
