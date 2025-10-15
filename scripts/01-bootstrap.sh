#!/bin/bash
# Phase 1: Bootstrap the Ceph Cluster
# Run 00-prerequisites.sh first!

set -e

echo "========================================="
echo "  Phase 1: Bootstrapping Ceph Cluster"
echo "========================================="
echo ""

# Check if prerequisites script was run
if ! ssh -o BatchMode=yes localhost "echo test" &>/dev/null; then
    echo "ERROR: SSH to localhost is not configured!"
    echo "Please run: ./scripts/00-prerequisites.sh first"
    exit 1
fi

# Install cephadm if not present
if ! command -v cephadm &> /dev/null; then
    echo "Installing cephadm..."
    curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
    chmod +x cephadm
    sudo mv cephadm /usr/local/bin/
    echo "✓ cephadm installed"
else
    echo "✓ cephadm already installed"
fi

echo ""
echo "Starting bootstrap process..."
echo "This will take 3-5 minutes..."
echo ""

# Get the host's primary IP address
HOST_IP=$(hostname -I | awk '{print $1}')
echo "Using host IP: $HOST_IP"
echo ""

# Bootstrap the cluster
sudo cephadm bootstrap \
    --mon-ip $HOST_IP \
    --initial-dashboard-user admin \
    --initial-dashboard-password admin123 \
    --allow-fqdn-hostname \
    --skip-monitoring-stack \
    --single-host-defaults \
    --ssh-user $USER

echo ""
echo "=== Bootstrap Complete! ==="
echo ""
echo "Dashboard URL: https://$HOST_IP:8443"
echo "Username: admin"
echo "Password: admin123"
echo ""
echo "Access the Ceph CLI:"
echo "  sudo cephadm shell"
echo ""
echo "Check cluster status:"
echo "  sudo cephadm shell -- ceph -s"
echo ""
echo "Next steps:"
echo "  1. Add more hosts (if you have multiple machines)"
echo "  2. Add OSDs: sudo cephadm shell -- ceph orch apply osd --all-available-devices"
echo "  3. Create CephFS: Run ./scripts/04-setup-cephfs.sh"
echo ""
