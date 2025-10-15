# Container Engine Installation Guide

## 🐳 Install Podman or Docker for Cephadm

**Note:** Cephadm requires either Podman or Docker to manage Ceph containers. This guide covers both options.

### Option 1: Install Podman (Recommended for Cephadm)

```bash
# 1. Update package index
sudo apt update

# 2. Install Podman
sudo apt install -y podman

# 3. Verify installation
podman --version

# 4. Test Podman
podman run hello-world
```

**Why Podman?**
- Daemonless (more secure)
- Rootless containers supported
- Drop-in replacement for Docker
- Preferred by cephadm

### Option 2: Install Docker (Alternative)

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

## 🔧 Cephadm Container Engine Requirements

**What cephadm needs:**
- Container engine (Podman or Docker)
- Ability to pull images from quay.io
- Sufficient privileges to create containers

**Cephadm will:**
- Automatically detect Podman or Docker
- Pull Ceph container images
- Create and manage Ceph daemon containers
- Handle container lifecycle

## 🚀 After Installation

Once Podman/Docker is installed, run the prerequisites script:

```bash
cd /home/sab/Desktop/DEVOPS-INTERVIEWS-SITUATIONALS/ceph-test
./scripts/00-prerequisites.sh
```

This will verify your container engine is working correctly.

## 🐛 Troubleshooting

### Podman Permission Issues
```bash
# Podman runs rootless by default, no special permissions needed
# If issues occur, try:
podman system reset
```

### Docker Permission Denied
```bash
# If using Docker and get "permission denied":
sudo usermod -aG docker $USER
newgrp docker
```

### Container Engine Not Found
```bash
# Verify installation
which podman || which docker

# Check version
podman --version
# or
docker --version
```

## 📝 Quick Reference

### Podman Commands
| Command | Purpose |
|---------|---------|  
| `podman --version` | Check Podman version |
| `podman ps` | List running containers |
| `podman images` | List downloaded images |
| `podman system prune -a` | Clean up unused images |

### Docker Commands
| Command | Purpose |
|---------|---------|
| `docker --version` | Check Docker version |
| `docker compose version` | Check Compose version |
| `sudo systemctl status docker` | Check Docker service |
| `docker ps` | List running containers |
| `docker images` | List downloaded images |

---

**Next Step**: After Podman/Docker is installed, run `./scripts/00-prerequisites.sh` to verify everything is ready
