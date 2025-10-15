#!/bin/bash
# Cleanup script to reset the entire Ceph environment

set -e

echo "=== Cleaning up Ceph Environment ==="
echo ""
echo "WARNING: This will destroy all data and reset the cluster!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Step 1: Getting cluster FSID..."
FSID=$(sudo cephadm ls 2>/dev/null | grep fsid | head -1 | awk '{print $2}' | tr -d '",')

if [ -n "$FSID" ]; then
    echo "Found cluster FSID: $FSID"
    echo ""
    echo "Step 2: Removing Ceph cluster..."
    sudo cephadm rm-cluster --fsid $FSID --force
else
    echo "No cluster found, skipping cluster removal"
fi

echo ""
echo "Step 3: Removing loop devices..."
sudo losetup -a | grep ceph-osd | cut -d: -f1 | xargs -r sudo losetup -d

echo ""
echo "Step 4: Removing OSD image files..."
sudo rm -f /var/lib/ceph-osd-*.img

echo ""
echo "Step 5: Removing ceph directories..."
sudo rm -rf /etc/ceph/*
sudo rm -rf /var/lib/ceph/*

echo ""
echo "=== Cleanup Complete! ==="
echo ""
echo "You can now start fresh with:"
echo "  ./scripts/01-bootstrap.sh"
echo ""
