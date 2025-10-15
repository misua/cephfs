#!/bin/bash
# Check the status of the Ceph cluster

echo "=== Ceph Cluster Status ==="
echo ""

if ! command -v cephadm &> /dev/null; then
    echo "Error: cephadm is not installed."
    echo "Run: ./scripts/01-bootstrap.sh"
    exit 1
fi

echo "--- Overall Cluster Health ---"
sudo cephadm shell -- ceph -s 2>/dev/null || echo "Cluster not bootstrapped yet"

echo ""
echo "--- OSD Status ---"
sudo cephadm shell -- ceph osd tree 2>/dev/null || echo "No OSDs deployed yet"

echo ""
echo "--- Monitor Status ---"
sudo cephadm shell -- ceph mon stat 2>/dev/null || echo "Monitors not configured yet"

echo ""
echo "--- CephFS Status ---"
sudo cephadm shell -- ceph fs ls 2>/dev/null || echo "No CephFS filesystems yet"

echo ""
echo "--- Cephadm Containers ---"
sudo cephadm ls 2>/dev/null || echo "No cephadm containers yet"

echo ""
