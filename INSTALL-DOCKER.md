# Docker Installation Guide

## 🐳 Install Docker on Ubuntu 24.04

You have `docker-compose-plugin` but not Docker Engine itself. Here's how to fix it:

### Quick Install (Recommended)

```bash
# 1. Update package index
sudo apt update

# 2. Install Docker Engine and related packages
sudo apt install -y docker.io docker-compose-v2

# 3. Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# 4. Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# 5. Apply group changes (or logout/login)
newgrp docker

# 6. Verify installation
docker --version
docker compose version
```

### Alternative: Official Docker Repository Method

If you prefer the latest version from Docker's official repo:

```bash
# 1. Remove old versions (if any)
sudo apt remove docker docker-engine docker.io containerd runc

# 2. Install prerequisites
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# 3. Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# 7. Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# 8. Verify
docker --version
docker compose version
```

## ✅ Verify Installation

```bash
# Check Docker is running
sudo systemctl status docker

# Test Docker
docker run hello-world

# Test Docker Compose
docker compose version
```

## 🔧 Docker Compose v1 vs v2

You're encountering the v2 syntax issue:

### V1 (Old - Standalone Binary)
```bash
docker-compose up -d    # Hyphenated command
```

### V2 (New - Docker Plugin)
```bash
docker compose up -d    # Space, not hyphen
```

**Our setup uses V2 syntax** (`docker compose`), which is the modern standard.

## 🚀 After Installation

Once Docker is installed, navigate to the ceph-test directory and start:

```bash
cd /home/sab/Desktop/DEVOPS-INTERVIEWS-SITUATIONALS/ceph-test
docker compose up -d
```

## 🐛 Troubleshooting

### Permission Denied Error
```bash
# If you get "permission denied" errors:
sudo usermod -aG docker $USER
newgrp docker

# Or logout and login again
```

### Docker Service Not Running
```bash
sudo systemctl start docker
sudo systemctl status docker
```

### Check Docker Group
```bash
groups $USER
# Should show: ... docker ...
```

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `docker --version` | Check Docker version |
| `docker compose version` | Check Compose version |
| `sudo systemctl status docker` | Check Docker service |
| `docker ps` | List running containers |
| `docker images` | List downloaded images |

---

**Next Step**: After Docker is installed, return to the main README and start with `docker compose up -d`
