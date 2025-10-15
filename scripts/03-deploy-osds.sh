#!/bin/bash
# Phase 2 (continued): Deploy OSDs
# This script creates storage devices and deploys OSDs

set -e

echo "=== Phase 2: Deploying OSDs ==="
echo ""

echo "Step 1: Creating loop devices for OSD storage..."

# Create loop devices on each OSD node
for i in 1 2 3; do
    echo "Creating storage on osd$i..."
    docker exec ceph-osd$i bash -c "
        # Create a 10GB file for the OSD
        dd if=/dev/zero of=/var/lib/ceph/osd-device.img bs=1M count=10240 2>/dev/null
        
        # Create loop device
        losetup -f /var/lib/ceph/osd-device.img || true
        
        # Get the loop device name
        LOOP_DEV=\$(losetup -j /var/lib/ceph/osd-device.img | cut -d: -f1)
        echo \"Loop device created: \$LOOP_DEV\"
    "
done

echo ""
echo "Step 2: Listing available devices..."
docker exec ceph-mon1 cephadm shell -- ceph orch device ls

echo ""
echo "Step 3: Deploying OSDs on available devices..."
echo "Note: This may take a few minutes..."

# Deploy OSDs using the OSD service specification
docker exec ceph-mon1 cephadm shell -- ceph orch apply osd --all-available-devices

echo ""
echo "Step 4: Waiting for OSDs to be deployed (this may take 2-3 minutes)..."
sleep 30

# Check OSD status
docker exec ceph-mon1 cephadm shell -- ceph osd tree

echo ""
echo "=== OSD Deployment Initiated! ==="
echo ""
echo "Monitor the deployment with:"
echo "  docker exec ceph-mon1 cephadm shell -- ceph -s"
echo "  docker exec ceph-mon1 cephadm shell -- ceph osd tree"
echo ""
echo "Once all OSDs are up, run: ./scripts/04-setup-cephfs.sh"
echo ""
