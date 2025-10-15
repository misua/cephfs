#!/bin/bash
# Phase 2: Deploy OSDs using LVM
# This script creates LVM volumes and deploys OSDs

set -e

echo "=== Phase 2: Deploying OSDs with LVM ==="
echo ""

echo "Step 1: Creating LVM volumes for OSD storage..."
echo "Creating 3 x 2GB LVM volumes..."
echo ""

# Create loop devices and set them up as physical volumes
for i in 1 2 3; do
    echo "Creating backing file and loop device $i..."
    sudo dd if=/dev/zero of=/var/lib/ceph-osd-$i.img bs=1M count=2048 status=progress
    LOOP_DEV=$(sudo losetup -f)
    sudo losetup $LOOP_DEV /var/lib/ceph-osd-$i.img
    
    echo "Creating PV and VG on $LOOP_DEV..."
    sudo pvcreate $LOOP_DEV
    sudo vgcreate ceph-vg-$i $LOOP_DEV
    sudo lvcreate -l 100%FREE -n osd-lv-$i ceph-vg-$i
    
    echo "Created LV: /dev/ceph-vg-$i/osd-lv-$i"
done

echo ""
echo "Step 2: Listing LVM volumes..."
sudo lvs | grep ceph

echo ""
echo "Step 3: Deploying OSDs on LVM volumes..."
echo "Note: This may take a few minutes..."

# Deploy OSDs manually on each LVM volume
for i in 1 2 3; do
    echo "Creating OSD on /dev/ceph-vg-$i/osd-lv-$i..."
    sudo cephadm shell -- ceph orch daemon add osd $(hostname):/dev/ceph-vg-$i/osd-lv-$i
done

echo ""
echo "Step 4: Waiting for OSDs to be deployed (this may take 2-3 minutes)..."
sleep 45

# Check OSD status
echo ""
echo "Checking OSD status..."
sudo cephadm shell -- ceph osd tree

echo ""
echo "Checking cluster status..."
sudo cephadm shell -- ceph -s

echo ""
echo "=== OSD Deployment Complete! ==="
echo ""
echo "Monitor the cluster with:"
echo "  sudo cephadm shell -- ceph -s"
echo "  sudo cephadm shell -- ceph osd tree"
echo ""
echo "Once all OSDs are up, run: ./scripts/04-setup-cephfs.sh"
echo ""
