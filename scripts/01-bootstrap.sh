#!/bin/bash
# Phase 1: Bootstrap the Ceph Cluster
# This script runs cephadm on the HOST to bootstrap the cluster

set -e

echo "=== Phase 1: Bootstrapping Ceph Cluster ==="
echo ""

# Check if cephadm is installed on host
if ! command -v cephadm &> /dev/null; then
    echo "Step 1: Installing cephadm on HOST..."
    curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
    chmod +x cephadm
    sudo mv cephadm /usr/local/bin/
    echo "cephadm installed successfully!"
else
    echo "Step 1: cephadm already installed on HOST"
fi

echo ""
echo "Step 2: Bootstrapping the cluster..."
echo "This will create the initial monitor and manager daemons."
echo "Note: This runs on the HOST and will create new containers managed by cephadm."
echo ""

# Bootstrap on the host - cephadm will create its own containers
sudo cephadm bootstrap \
    --mon-ip 172.20.0.10 \
    --initial-dashboard-user admin \
    --initial-dashboard-password admin123 \
    --allow-fqdn-hostname \
    --skip-monitoring-stack \
    --single-host-defaults

echo ""
echo "=== Bootstrap Complete! ==="
echo ""
echo "Dashboard URL: https://172.20.0.10:8443"
echo "Username: admin"
echo "Password: admin123"
echo ""
echo "Next steps:"
echo "  1. Wait for the cluster to stabilize (30-60 seconds)"
echo "  2. Run: ./scripts/02-add-hosts.sh"
echo ""
