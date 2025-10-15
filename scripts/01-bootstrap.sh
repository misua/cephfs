#!/bin/bash
# Phase 1: Bootstrap the Ceph Cluster
# This script initializes the first monitor and manager

set -e

echo "=== Phase 1: Bootstrapping Ceph Cluster ==="
echo ""

# Check if containers are running
if ! docker ps | grep -q ceph-mon1; then
    echo "Error: Containers are not running. Please run 'docker-compose up -d' first."
    exit 1
fi

echo "Step 1: Installing cephadm in mon1 container..."
docker exec ceph-mon1 bash -c "
    curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
    chmod +x cephadm
    mv cephadm /usr/local/bin/
"

echo ""
echo "Step 2: Bootstrapping the cluster on mon1..."
echo "This will create the initial monitor and manager daemons."
echo ""

docker exec ceph-mon1 cephadm bootstrap \
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
