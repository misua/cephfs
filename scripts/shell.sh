#!/bin/bash
# Quick access to cephadm shell

if ! command -v cephadm &> /dev/null; then
    echo "Error: cephadm is not installed."
    echo "Run: ./scripts/01-bootstrap.sh"
    exit 1
fi

echo "Entering cephadm shell..."
echo "Type 'exit' to return to your host shell."
echo ""

sudo cephadm shell
