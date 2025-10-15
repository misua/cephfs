#!/bin/bash
# Phase 3: Configure CephFS
# This script creates the CephFS filesystem

set -e

echo "=== Phase 3: Setting up CephFS ==="
echo ""

echo "Step 1: Checking cluster health..."
sudo cephadm shell -- ceph -s

echo ""
echo "Step 2: Creating CephFS filesystem 'myfs'..."
echo "This will automatically create MDS daemons..."
sudo cephadm shell -- ceph fs volume create myfs

echo ""
echo "Waiting for filesystem to be created (30 seconds)..."
sleep 30

echo ""
echo "Step 3: Verifying CephFS status..."
sudo cephadm shell -- ceph fs ls
sudo cephadm shell -- ceph fs status myfs

echo ""
echo "Step 4: Creating a client user for mounting CephFS..."
sudo cephadm shell -- ceph auth get-or-create client.myfs mon 'allow r' mds 'allow rw' osd 'allow rw pool=cephfs.myfs.meta, allow rw pool=cephfs.myfs.data'

echo ""
echo "Step 5: Getting mount information..."
HOST_IP=$(hostname -I | awk '{print $1}')
SECRET=$(sudo cephadm shell -- ceph auth get-key client.myfs)

echo ""
echo "=== CephFS Setup Complete! ==="
echo ""
echo "Filesystem Name: myfs"
echo "Monitor Address: $HOST_IP:6789"
echo "Client Key: $SECRET"
echo ""
echo "To mount CephFS locally:"
echo "  sudo mkdir -p /mnt/cephfs"
echo "  sudo mount -t ceph $HOST_IP:6789:/ /mnt/cephfs -o name=myfs,secret=$SECRET"
echo ""
echo "Or use the admin key:"
echo "  sudo ceph-fuse /mnt/cephfs"
echo ""
