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
echo "Step 1: Stopping and removing containers..."
docker compose down -v

echo ""
echo "Step 2: Removing data directories..."
sudo rm -rf data/mon1/* data/mon2/* data/mon3/* data/osd1/* data/osd2/* data/osd3/*

echo ""
echo "Step 3: Removing config files..."
rm -rf config/*

echo ""
echo "Step 4: Removing test client (if exists)..."
docker stop ceph-client 2>/dev/null || true
docker rm ceph-client 2>/dev/null || true

echo ""
echo "=== Cleanup Complete! ==="
echo ""
echo "You can now start fresh with:"
echo "  docker compose up -d"
echo "  ./scripts/01-bootstrap.sh"
echo ""
