#!/bin/bash
# Phase 2: Add additional hosts to the cluster
# This script adds mon2, mon3, and OSD nodes

set -e

echo "=== Phase 2: Adding Hosts to Cluster ==="
echo ""

# Function to add a host
add_host() {
    local hostname=$1
    local ip=$2
    
    echo "Adding host: $hostname ($ip)..."
    
    # Copy SSH key to the host
    docker exec ceph-mon1 cephadm shell -- ceph cephadm get-pub-key > /tmp/ceph.pub
    
    docker exec $hostname bash -c "
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
    "
    
    docker cp /tmp/ceph.pub $hostname:/root/.ssh/authorized_keys
    
    docker exec $hostname bash -c "
        chmod 600 /root/.ssh/authorized_keys
        
        # Install SSH server if not present
        if ! command -v sshd &> /dev/null; then
            apt-get update -qq
            apt-get install -y -qq openssh-server
            mkdir -p /run/sshd
            /usr/sbin/sshd
        fi
    "
    
    # Add host to cluster
    docker exec ceph-mon1 cephadm shell -- ceph orch host add $hostname $ip
    
    echo "Host $hostname added successfully!"
    echo ""
}

echo "Step 1: Installing SSH on all nodes..."
for container in ceph-mon1 ceph-mon2 ceph-mon3 ceph-osd1 ceph-osd2 ceph-osd3; do
    docker exec $container bash -c "
        apt-get update -qq 2>/dev/null
        apt-get install -y -qq openssh-server 2>/dev/null
        mkdir -p /run/sshd
        /usr/sbin/sshd 2>/dev/null || true
    " &
done
wait

echo ""
echo "Step 2: Adding monitor/manager hosts..."
add_host "mon2" "172.20.0.11"
add_host "mon3" "172.20.0.12"

echo "Step 3: Adding OSD hosts..."
add_host "osd1" "172.20.0.20"
add_host "osd2" "172.20.0.21"
add_host "osd3" "172.20.0.22"

echo ""
echo "Step 4: Labeling hosts..."
docker exec ceph-mon1 cephadm shell -- ceph orch host label add mon1 mon
docker exec ceph-mon1 cephadm shell -- ceph orch host label add mon2 mon
docker exec ceph-mon1 cephadm shell -- ceph orch host label add mon3 mon
docker exec ceph-mon1 cephadm shell -- ceph orch host label add osd1 osd
docker exec ceph-mon1 cephadm shell -- ceph orch host label add osd2 osd
docker exec ceph-mon1 cephadm shell -- ceph orch host label add osd3 osd

echo ""
echo "=== Hosts Added Successfully! ==="
echo ""
echo "Next steps:"
echo "  1. Wait for hosts to be fully integrated (check with: docker exec ceph-mon1 cephadm shell -- ceph orch host ls)"
echo "  2. Run: ./scripts/03-deploy-osds.sh"
echo ""
