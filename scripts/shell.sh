#!/bin/bash
# Quick access to cephadm shell

if ! docker ps | grep -q ceph-mon1; then
    echo "Error: ceph-mon1 container is not running."
    exit 1
fi

echo "Entering cephadm shell on mon1..."
echo "Type 'exit' to return to your host shell."
echo ""

docker exec -it ceph-mon1 cephadm shell
