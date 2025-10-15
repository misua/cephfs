#!/bin/bash
# Test mounting CephFS in a client container

set -e

echo "=== Testing CephFS Mount ==="
echo ""

echo "Step 1: Creating a test client container..."
docker run -d \
    --name ceph-client \
    --network ceph-test_ceph-network \
    --privileged \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    ubuntu:22.04 sleep infinity

echo ""
echo "Step 2: Installing ceph-common in client..."
docker exec ceph-client bash -c "
    apt-get update -qq
    apt-get install -y -qq ceph-common
"

echo ""
echo "Step 3: Copying Ceph configuration..."
docker cp ceph-mon1:/etc/ceph/ceph.conf /tmp/ceph.conf
docker cp ceph-mon1:/etc/ceph/ceph.client.admin.keyring /tmp/ceph.client.admin.keyring

docker exec ceph-client mkdir -p /etc/ceph
docker cp /tmp/ceph.conf ceph-client:/etc/ceph/
docker cp /tmp/ceph.client.admin.keyring ceph-client:/etc/ceph/

echo ""
echo "Step 4: Creating mount point and mounting CephFS..."
docker exec ceph-client bash -c "
    mkdir -p /mnt/cephfs
    mount -t ceph 172.20.0.10:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/ceph.client.admin.keyring
"

echo ""
echo "Step 5: Testing write operations..."
docker exec ceph-client bash -c "
    echo 'Hello from CephFS!' > /mnt/cephfs/test.txt
    cat /mnt/cephfs/test.txt
    ls -lh /mnt/cephfs/
"

echo ""
echo "=== CephFS Mount Test Successful! ==="
echo ""
echo "You can access the client container with:"
echo "  docker exec -it ceph-client bash"
echo ""
echo "CephFS is mounted at: /mnt/cephfs"
echo ""
echo "To cleanup the test client:"
echo "  docker stop ceph-client && docker rm ceph-client"
echo ""
