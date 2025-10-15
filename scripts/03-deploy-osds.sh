#!/bin/bash
# Phase 2: Deploy OSDs
# This script creates storage devices and deploys OSDs using cephadm

set -e

echo "=== Phase 2: Deploying OSDs ==="
echo ""

echo "Step 1: Creating loop devices for OSD storage..."
echo "Creating 3 x 2GB loop devices..."
echo ""

# Create loop devices on the host
for i in 1 2 3; do
    echo "Creating loop device $i..."
    sudo dd if=/dev/zero of=/var/lib/ceph-osd-$i.img bs=1M count=2048 status=progress
    sudo losetup -f /var/lib/ceph-osd-$i.img
done

echo ""
echo "Step 2: Listing loop devices..."
sudo losetup -a | grep ceph-osd

echo ""
echo "Step 3: Listing available devices..."
sudo cephadm shell -- ceph orch device ls

echo ""
echo "Step 4: Deploying OSDs manually on loop devices..."
echo "Note: This may take a few minutes..."

# Get the loop devices
LOOP_DEVICES=$(losetup -a | grep ceph-osd | awk -F: '{print $1}')

# Deploy OSDs manually on each loop device
for DEVICE in $LOOP_DEVICES; do
    echo "Creating OSD on $DEVICE..."
    sudo cephadm shell -- ceph orch daemon add osd $(hostname):$DEVICE
done

echo ""
echo "Step 5: Waiting for OSDs to be deployed (this may take 2-3 minutes)..."
sleep 30

# Check OSD status
sudo cephadm shell -- ceph osd tree

echo ""
echo "=== OSD Deployment Initiated! ==="
echo ""
echo "Monitor the deployment with:"
echo "  sudo cephadm shell -- ceph -s"
echo "  sudo cephadm shell -- ceph osd tree"
echo ""
echo "Once all OSDs are up, run: ./scripts/04-setup-cephfs.sh"
echo ""
