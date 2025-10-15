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
echo "Step 3: Removing LVM volumes..."
# Remove logical volumes
for i in 1 2 3; do
    if sudo lvs ceph-vg-$i/osd-lv-$i &>/dev/null; then
        echo "  Removing LV: ceph-vg-$i/osd-lv-$i"
        sudo lvremove -f ceph-vg-$i/osd-lv-$i
    fi
done

# Remove volume groups
for i in 1 2 3; do
    if sudo vgs ceph-vg-$i &>/dev/null; then
        echo "  Removing VG: ceph-vg-$i"
        sudo vgremove -f ceph-vg-$i
    fi
done

# Remove physical volumes and loop devices
for i in 1 2 3; do
    LOOP_DEV=$(sudo losetup -a | grep "ceph-osd-$i.img" | cut -d: -f1)
    if [ -n "$LOOP_DEV" ]; then
        echo "  Removing PV on $LOOP_DEV"
        sudo pvremove -f $LOOP_DEV 2>/dev/null || true
        echo "  Detaching loop device $LOOP_DEV"
        sudo losetup -d $LOOP_DEV
    fi
done

echo ""
echo "Step 4: Removing OSD image files..."
sudo rm -f /var/lib/ceph-osd-*.img

echo ""
echo "Step 5: Removing ceph directories..."
sudo rm -rf /etc/ceph/*
sudo rm -rf /var/lib/ceph/*

echo ""
echo "Step 6: Removing passwordless sudo configuration..."
if [ -f /etc/sudoers.d/ceph-$USER ]; then
    sudo rm -f /etc/sudoers.d/ceph-$USER
    echo "  Removed /etc/sudoers.d/ceph-$USER"
else
    echo "  No passwordless sudo config found"
fi

echo ""
echo "=== Cleanup Complete! ==="
echo ""
echo "You can now start fresh with:"
echo "  ./scripts/01-bootstrap.sh"
echo ""
