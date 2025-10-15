#!/bin/bash
# Check the status of the Ceph cluster

echo "=== Ceph Cluster Status ==="
echo ""

if ! docker ps | grep -q ceph-mon1; then
    echo "Error: Ceph containers are not running."
    echo "Start them with: docker-compose up -d"
    exit 1
fi

echo "--- Overall Cluster Health ---"
docker exec ceph-mon1 cephadm shell -- ceph -s 2>/dev/null || echo "Cluster not bootstrapped yet"

echo ""
echo "--- OSD Status ---"
docker exec ceph-mon1 cephadm shell -- ceph osd tree 2>/dev/null || echo "No OSDs deployed yet"

echo ""
echo "--- Monitor Status ---"
docker exec ceph-mon1 cephadm shell -- ceph mon stat 2>/dev/null || echo "Monitors not configured yet"

echo ""
echo "--- CephFS Status ---"
docker exec ceph-mon1 cephadm shell -- ceph fs ls 2>/dev/null || echo "No CephFS filesystems yet"

echo ""
echo "--- Host List ---"
docker exec ceph-mon1 cephadm shell -- ceph orch host ls 2>/dev/null || echo "No hosts added yet"

echo ""
