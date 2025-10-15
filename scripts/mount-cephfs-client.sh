#!/bin/bash
# Script to mount CephFS on a remote client server

set -e

echo "=== CephFS Client Mount Script ==="
echo ""

# Configuration
MON_ADDR="192.168.1.215:6789"
CLIENT_NAME="myfs"
CLIENT_KEY="AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA=="
MOUNT_POINT="/mnt/cephfs"

echo "Step 1: Installing ceph-common..."
sudo apt update
sudo apt install -y ceph-common

echo ""
echo "Step 2: Creating mount point..."
sudo mkdir -p $MOUNT_POINT

echo ""
echo "Step 3: Creating secret file..."
sudo mkdir -p /etc/ceph
echo "$CLIENT_KEY" | sudo tee /etc/ceph/myfs.secret > /dev/null
sudo chmod 600 /etc/ceph/myfs.secret

echo ""
echo "Step 4: Mounting CephFS..."
sudo mount -t ceph $MON_ADDR:/ $MOUNT_POINT \
  -o name=$CLIENT_NAME,secretfile=/etc/ceph/myfs.secret,noatime

echo ""
echo "Step 5: Verifying mount..."
df -h $MOUNT_POINT

echo ""
echo "Step 6: Testing write access..."
echo "Test file created at $(date)" | sudo tee $MOUNT_POINT/test-$(hostname).txt
sudo ls -la $MOUNT_POINT/

echo ""
echo "=== CephFS Mounted Successfully! ==="
echo ""
echo "Mount point: $MOUNT_POINT"
echo "To make it persistent, add this to /etc/fstab:"
echo ""
echo "$MON_ADDR:/  $MOUNT_POINT  ceph  name=$CLIENT_NAME,secretfile=/etc/ceph/myfs.secret,noatime,_netdev  0  2"
echo ""
echo "To unmount: sudo umount $MOUNT_POINT"
echo ""
