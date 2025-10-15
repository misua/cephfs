# CephFS Setup Guide - Complete Workflow

## 🎯 Goal
Set up a working CephFS filesystem using cephadm on a single host for learning purposes.

## ⚠️ Important Notes

- **This uses cephadm** which runs on your HOST machine (not in containers)
- **docker-compose.yml is NOT used** - it's kept for reference only
- **Single host setup** - all components run on one machine
- **Cephadm manages containers** - it will create its own containers automatically

## 📋 Complete Workflow

### Step 0: Clean Up (If Retrying)

If you've attempted this before and hit errors:

```bash
./scripts/cleanup.sh
```

### Step 1: Prerequisites Check ✓

This validates and configures everything needed:

```bash
./scripts/00-prerequisites.sh
```

**What it does:**
- ✓ Checks Docker/Podman is installed
- ✓ Checks Python3 is installed
- ✓ Checks LVM tools are installed
- ✓ Verifies time synchronization
- ✓ Installs and starts SSH server
- ✓ Creates ~/.ssh directory with correct permissions (700)
- ✓ Generates SSH key pair if needed
- ✓ Configures SSH for passwordless localhost access
- ✓ Tests SSH connection
- ✓ Checks disk space (need 10GB+)
- ✓ Checks for conflicting Ceph installations

**Expected output:** "✓ All prerequisites met!"

**If it fails:** Fix the reported issues before proceeding.

---

### Step 2: Bootstrap Cluster 🚀

This initializes the Ceph cluster:

```bash
./scripts/01-bootstrap.sh
```

**What it does:**
- Installs cephadm on your host
- Bootstraps the cluster with monitor and manager
- Creates containers managed by cephadm
- Sets up the Ceph dashboard

**Duration:** 3-5 minutes

**Expected output:**
```
Dashboard URL: https://YOUR_IP:8443
Username: admin
Password: admin123
```

**Containers created:** You'll see new containers like:
- `ceph-{fsid}-mon.{hostname}`
- `ceph-{fsid}-mgr.{hostname}`

---

### Step 3: Deploy OSDs (Storage) 💾

This creates storage devices and deploys OSDs:

```bash
./scripts/03-deploy-osds.sh
```

**What it does:**
- Creates 3 x 2GB loop devices on your host
- Tells cephadm to deploy OSDs on these devices
- Waits for OSDs to come online

**Duration:** 3-5 minutes

**Check status:**
```bash
./scripts/status.sh
```

Look for `HEALTH_OK` before proceeding.

---

### Step 4: Create CephFS 📁

This creates the CephFS filesystem:

```bash
./scripts/04-setup-cephfs.sh
```

**What it does:**
- Creates CephFS filesystem named 'myfs'
- Deploys MDS (Metadata Server) daemons automatically
- Creates client authentication keys
- Provides mount instructions

**Duration:** 1-2 minutes

**Expected output:** Mount instructions with your host IP and secret key

---

### Step 5: Mount and Test 🎉

Mount CephFS on your local machine:

```bash
# Create mount point
sudo mkdir -p /mnt/cephfs

# Get the secret (from step 4 output, or run this):
SECRET=$(sudo cephadm shell -- ceph auth get-key client.admin)

# Mount CephFS
HOST_IP=$(hostname -I | awk '{print $1}')
sudo mount -t ceph $HOST_IP:6789:/ /mnt/cephfs -o name=admin,secret=$SECRET

# Test it
echo "Hello CephFS!" | sudo tee /mnt/cephfs/test.txt
cat /mnt/cephfs/test.txt
```

---

## 🔍 Monitoring & Management

### Check Cluster Status
```bash
./scripts/status.sh
```

### Access Ceph CLI
```bash
./scripts/shell.sh
# or directly:
sudo cephadm shell
```

### View Dashboard
Open in browser: `https://YOUR_IP:8443`
- Username: `admin`
- Password: `admin123`

### Common Commands
```bash
# Cluster health
sudo cephadm shell -- ceph -s

# OSD status
sudo cephadm shell -- ceph osd tree

# CephFS status
sudo cephadm shell -- ceph fs status myfs

# List containers
sudo cephadm ls
```

---

## 🐛 Troubleshooting

### Prerequisites fail
- Read the error messages carefully
- Fix each issue one at a time
- Re-run `./scripts/00-prerequisites.sh`

### Bootstrap fails
- Ensure prerequisites passed
- Check SSH works: `ssh localhost "echo test"`
- Clean up and retry: `./scripts/cleanup.sh` then start over

### OSDs won't deploy
- Check cluster health: `sudo cephadm shell -- ceph -s`
- Wait a few minutes - OSD deployment takes time
- Check logs: `sudo cephadm shell -- ceph -W cephadm`

### CephFS mount fails
- Ensure OSDs are up: `./scripts/status.sh`
- Check MDS is active: `sudo cephadm shell -- ceph mds stat`
- Install ceph-common: `sudo apt install ceph-common`

---

## 🔄 Reset Everything

To start completely fresh:

```bash
./scripts/cleanup.sh
```

This removes:
- All Ceph containers
- Loop devices
- Configuration files
- Data directories

Then start from Step 1 again.

---

## 📚 Learning Path

After completing the setup:

1. **Explore the dashboard** - Visual monitoring of your cluster
2. **Practice Ceph commands** - Use `./scripts/shell.sh`
3. **Test failure scenarios** - Stop an OSD, watch recovery
4. **Create snapshots** - CephFS supports snapshots
5. **Try quotas** - Set directory quotas
6. **Multi-client access** - Mount from multiple locations

---

## ✅ Success Checklist

- [ ] Prerequisites script passes all checks
- [ ] Bootstrap completes without errors
- [ ] Dashboard is accessible
- [ ] 3 OSDs are deployed and up
- [ ] Cluster shows HEALTH_OK
- [ ] CephFS filesystem is created
- [ ] MDS daemons are active
- [ ] CephFS mounts successfully
- [ ] Can read/write files

---

## 💡 Key Concepts

- **cephadm**: Orchestrator that manages Ceph containers
- **MON**: Monitor - maintains cluster state
- **MGR**: Manager - provides dashboard and APIs
- **OSD**: Object Storage Daemon - stores data
- **MDS**: Metadata Server - manages CephFS metadata
- **FSID**: Unique cluster identifier

---

**Need help?** Check the detailed README.md or CHEAT-SHEET.md
