#!/bin/bash
# Prerequisites Check and Setup for Cephadm
# This script validates and configures all requirements before bootstrap

set -e

echo "========================================="
echo "  Cephadm Prerequisites Check & Setup"
echo "========================================="
echo ""

ERRORS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo "✓ $2"
    else
        echo "✗ $2"
        ERRORS=$((ERRORS + 1))
    fi
}

# 1. Check Docker/Podman
echo "=== Step 1: Container Engine ==="
if command -v podman &> /dev/null; then
    print_status 0 "Podman is installed: $(podman --version)"
elif command -v docker &> /dev/null; then
    print_status 0 "Docker is installed: $(docker --version)"
else
    print_status 1 "Neither Docker nor Podman is installed"
    echo "  Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
fi
echo ""

# 2. Check Python3
echo "=== Step 2: Python3 ==="
if command -v python3 &> /dev/null; then
    print_status 0 "Python3 is installed: $(python3 --version)"
else
    print_status 1 "Python3 is not installed"
    echo "  Installing Python3..."
    sudo apt install -y python3
fi
echo ""

# 3. Check LVM tools
echo "=== Step 3: LVM Tools ==="
if command -v lvcreate &> /dev/null; then
    print_status 0 "LVM tools are installed"
else
    print_status 1 "LVM tools are not installed"
    echo "  Installing LVM2..."
    sudo apt install -y lvm2
fi
echo ""

# 4. Check time synchronization
echo "=== Step 4: Time Synchronization ==="
if systemctl is-active --quiet systemd-timesyncd; then
    print_status 0 "Time synchronization is active"
else
    print_status 1 "Time synchronization is not active"
    echo "  Starting systemd-timesyncd..."
    sudo systemctl start systemd-timesyncd
    sudo systemctl enable systemd-timesyncd
fi
echo ""

# 5. Setup SSH Server
echo "=== Step 5: SSH Server ==="
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    print_status 0 "SSH server is running"
else
    echo "  Installing and starting SSH server..."
    sudo apt install -y openssh-server
    sudo systemctl start ssh
    sudo systemctl enable ssh
    print_status 0 "SSH server installed and started"
fi
echo ""

# 6. Setup SSH Keys and Permissions
echo "=== Step 6: SSH Configuration ==="

# Create .ssh directory with correct permissions
if [ ! -d ~/.ssh ]; then
    echo "  Creating ~/.ssh directory..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    print_status 0 "Created ~/.ssh directory"
else
    chmod 700 ~/.ssh
    print_status 0 "~/.ssh directory exists with correct permissions"
fi

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "  Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -C "ceph-admin"
    print_status 0 "SSH key pair generated"
else
    print_status 0 "SSH key pair already exists"
fi

# Setup authorized_keys
if [ ! -f ~/.ssh/authorized_keys ]; then
    echo "  Creating authorized_keys file..."
    touch ~/.ssh/authorized_keys
fi

# Ensure correct permissions on authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Add public key to authorized_keys if not already there
if ! grep -q "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
    echo "  Adding public key to authorized_keys..."
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    print_status 0 "Public key added to authorized_keys"
else
    print_status 0 "Public key already in authorized_keys"
fi

# Test SSH to localhost
echo "  Testing SSH connection to localhost..."
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes localhost "echo 'SSH test successful'" &>/dev/null; then
    print_status 0 "SSH to localhost works"
else
    print_status 1 "SSH to localhost failed"
    echo "  Attempting to fix..."
    # Add localhost to known_hosts
    ssh-keyscan -H localhost >> ~/.ssh/known_hosts 2>/dev/null
    ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts 2>/dev/null
    
    # Try again
    if ssh -o BatchMode=yes localhost "echo 'SSH test successful'" &>/dev/null; then
        print_status 0 "SSH to localhost now works"
    else
        print_status 1 "SSH to localhost still failing - manual intervention needed"
    fi
fi
echo ""

# 7. Check disk space
echo "=== Step 7: Disk Space ==="
AVAILABLE=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE" -gt 10 ]; then
    print_status 0 "Sufficient disk space: ${AVAILABLE}GB available"
else
    print_status 1 "Low disk space: only ${AVAILABLE}GB available (need 10GB+)"
fi
echo ""

# 8. Check for conflicting Ceph installations
echo "=== Step 8: Conflicting Installations ==="
if systemctl list-units --all | grep -q ceph; then
    print_status 1 "Found existing Ceph services"
    echo "  Run cleanup script first: ./scripts/cleanup.sh"
else
    print_status 0 "No conflicting Ceph installations found"
fi
echo ""

# Summary
echo "========================================="
if [ $ERRORS -eq 0 ]; then
    echo "✓ All prerequisites met!"
    echo ""
    echo "Next step: Run ./scripts/01-bootstrap.sh"
else
    echo "✗ Found $ERRORS issue(s) that need attention"
    echo ""
    echo "Please fix the issues above before proceeding"
    exit 1
fi
echo "========================================="
