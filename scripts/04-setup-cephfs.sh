#!/bin/bash
# Phase 3: Configure CephFS
# This script creates the CephFS filesystem

set -e

echo "=== Phase 3: Setting up CephFS ==="
echo ""

echo "Step 1: Checking cluster health..."
docker exec ceph-mon1 cephadm shell -- ceph -s

echo ""
echo "Step 2: Creating MDS (Metadata Server) service..."
docker exec ceph-mon1 cephadm shell -- ceph orch apply mds myfs --placement="3"

echo ""
echo "Waiting for MDS daemons to start (30 seconds)..."
sleep 30

echo ""
echo "Step 3: Creating CephFS filesystem 'myfs'..."
docker exec ceph-mon1 cephadm shell -- ceph fs volume create myfs

echo ""
echo "Waiting for filesystem to be created (20 seconds)..."
sleep 20

echo ""
echo "Step 4: Verifying CephFS status..."
docker exec ceph-mon1 cephadm shell -- ceph fs ls
docker exec ceph-mon1 cephadm shell -- ceph fs status myfs

echo ""
echo "Step 5: Creating a client user for mounting CephFS..."
docker exec ceph-mon1 cephadm shell -- ceph auth get-or-create client.myfs mon 'allow r' mds 'allow rw' osd 'allow rw pool=cephfs.myfs.meta, allow rw pool=cephfs.myfs.data'

echo ""
echo "Step 6: Getting mount information..."
MONITOR_IP=$(docker exec ceph-mon1 cephadm shell -- ceph mon dump | grep mon.mon1 | awk '{print $2}' | cut -d: -f1)
SECRET=$(docker exec ceph-mon1 cephadm shell -- ceph auth get-key client.myfs)

echo ""
echo "=== CephFS Setup Complete! ==="
echo ""
echo "Filesystem Name: myfs"
echo "Monitor Address: $MONITOR_IP:6789"
echo "Client Key: $SECRET"
echo ""
echo "To mount CephFS on a client:"
echo "  sudo mount -t ceph $MONITOR_IP:6789:/ /mnt/cephfs -o name=myfs,secret=$SECRET"
echo ""
echo "Or create a test mount inside a container:"
echo "  ./scripts/test-mount.sh"
echo ""
