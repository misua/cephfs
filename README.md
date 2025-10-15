# CephFS Learning Environment

A complete cephadm-based setup for learning CephFS with a single-node Ceph cluster.

## 📋 Overview

This environment provides:
- **Single-node Ceph cluster** (all components on one host)
- **1 Monitor + 1 Manager** (MON/MGR daemons)
- **3 OSDs** using LVM volumes (2GB each)
- **Automated setup scripts** for easy deployment
- **CephFS filesystem** ready for testing
- **No Docker Compose** - uses cephadm orchestration

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│         Single Host (PanDeMongo)                 │
│         IP: 192.168.1.215                        │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────────┐  ┌─────────────┐              │
│  │   MON       │  │   MGR       │              │
│  │  (Monitor)  │  │  (Manager)  │              │
│  └─────────────┘  └─────────────┘              │
│                                                  │
│  ┌──────┐  ┌──────┐  ┌──────┐                  │
│  │ OSD.0│  │ OSD.1│  │ OSD.2│                  │
│  │ 2GB  │  │ 2GB  │  │ 2GB  │                  │
│  │ LVM  │  │ LVM  │  │ LVM  │                  │
│  └──────┘  └──────┘  └──────┘                  │
│                                                  │
│  ┌──────────────────────────────┐              │
│  │  MDS (Metadata Servers)      │              │
│  │  CephFS: myfs                │              │
│  └──────────────────────────────┘              │
└──────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04+ (or similar Linux distribution)
- At least 4GB RAM available
- 10GB free disk space (actual usage ~6GB)
- Podman or Docker installed
- Python3 installed
- LVM tools installed

### Prerequisites Check

Run the automated prerequisites check:

```bash
cd ceph-test
chmod +x scripts/*.sh
./scripts/00-prerequisites.sh
```

This will:
- Check/install required packages
- Configure SSH for localhost
- Set up passwordless sudo
- Verify all requirements

### Step-by-Step Setup

#### 1. Bootstrap the Cluster

This initializes the monitor and manager:

```bash
./scripts/01-bootstrap.sh
```

**What this does:**
- Installs `cephadm` on your host
- Creates the initial monitor daemon
- Creates the initial manager daemon
- Sets up the Ceph dashboard (accessible at https://192.168.1.215:8443)

**Expected output:** Bootstrap completion message with dashboard credentials

**Wait time:** ~3-5 minutes

#### 2. Deploy OSDs (Storage)

```bash
./scripts/03-deploy-osds-lvm.sh
```

**What this does:**
- Creates 3 x 2GB LVM volumes
- Deploys OSD daemons on the LVM volumes
- Initializes the storage layer

**Expected output:** OSD tree showing 3 deployed OSDs

**Wait time:** ~3-5 minutes

**Verify OSDs are up:**
```bash
sudo cephadm shell -- ceph -s
```

Look for `osd: 3 osds: 3 up, 3 in` status.

#### 3. Setup CephFS

```bash
./scripts/04-setup-cephfs.sh
```

**What this does:**
- Creates MDS (Metadata Server) daemons
- Creates the CephFS filesystem named 'myfs'
- Creates client authentication keys
- Displays mount information

**Expected output:** CephFS status and mount instructions

**Wait time:** ~1-2 minutes

#### 4. Mount CephFS (Optional)

On your local machine or remote servers:

```bash
# Install ceph-common
sudo apt install ceph-common

# Mount CephFS
sudo mkdir -p /mnt/cephfs
sudo mount -t ceph 192.168.1.215:6789:/ /mnt/cephfs \
  -o name=myfs,secret=AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA==

# Test it
echo "Hello CephFS!" | sudo tee /mnt/cephfs/test.txt
```

## 🛠️ Helper Commands

### Check Cluster Status
```bash
sudo cephadm shell -- ceph -s
sudo cephadm shell -- ceph osd tree
```
Shows overall health, OSD status, and cluster state.

### Access Cephadm Shell
```bash
sudo cephadm shell
```
Opens an interactive shell with full Ceph CLI access.

### Cleanup Everything
```bash
./scripts/cleanup.sh
```
**Warning:** Destroys all data, removes LVM volumes, and resets the environment.

## 📊 Monitoring & Management

### Ceph Dashboard

Access the web dashboard at: **https://192.168.1.215:8443**

- **Username:** admin
- **Password:** admin123

(Accept the self-signed certificate warning)

### Common Commands

Inside the cephadm shell (`sudo cephadm shell`):

```bash
# Check cluster health
ceph -s

# View OSD status
ceph osd tree
ceph osd status

# View monitor status
ceph mon stat

# View CephFS status
ceph fs ls
ceph fs status myfs

# View MDS status
ceph mds stat

# Check cluster capacity
ceph df

# View all running daemons
ceph orch ps

# List systemd services
sudo systemctl list-units 'ceph*'
```

## 🔍 Understanding the Components

### Monitors (MON)
- Maintain cluster membership and state
- Provide consensus for distributed decision-making
- Store cluster maps (monitor, OSD, PG, CRUSH maps)

### Managers (MGR)
- Provide additional monitoring and interfaces
- Run the dashboard and other modules
- Handle metrics and telemetry

### OSDs (Object Storage Daemons)
- Store actual data
- Handle data replication
- Perform recovery and rebalancing
- Each OSD manages one storage device

### MDS (Metadata Servers)
- Manage CephFS metadata
- Handle directory structures and file attributes
- Enable POSIX filesystem semantics

## 🧪 Learning Exercises

### Exercise 1: Explore the Cluster
```bash
./scripts/shell.sh
ceph -s
ceph osd tree
ceph fs status myfs
```

### Exercise 2: Test Failover
Stop one OSD and watch recovery:
```bash
# Get the FSID
FSID=$(sudo cephadm ls | grep fsid | head -1 | awk '{print $2}' | tr -d '",')  

# Stop an OSD
sudo systemctl stop ceph-$FSID@osd.0.service

# Watch recovery
watch -n 1 'sudo cephadm shell -- ceph -s'

# Restart OSD
sudo systemctl start ceph-$FSID@osd.0.service
```

### Exercise 3: Write Data to CephFS
```bash
# Mount CephFS first (see step 4 above)
cd /mnt/cephfs
sudo mkdir test-directory
echo "Learning CephFS" | sudo tee test-directory/file.txt
ls -lR
```

### Exercise 4: Monitor Performance
```bash
sudo cephadm shell
ceph osd perf
ceph osd pool stats
```

## 📚 Key Concepts

### Pools
CephFS uses two pools:
- **Metadata pool** (`cephfs.myfs.meta`): Stores file metadata
- **Data pool** (`cephfs.myfs.data`): Stores file contents

### Placement Groups (PGs)
- Logical groupings of objects
- Enable distributed data placement
- Default: automatically calculated

### CRUSH Map
- Algorithm for data placement
- Defines failure domains
- Controls replication rules

## 🐛 Troubleshooting

### Cluster Not Healthy

Check specific issues:
```bash
./scripts/shell.sh
ceph health detail
```

### OSDs Not Coming Up

Check OSD logs:
```bash
sudo journalctl -u 'ceph*osd*' -f
```

### CephFS Mount Fails

Verify MDS is active:
```bash
sudo cephadm shell -- ceph mds stat

# Install ceph-common if needed
sudo apt install ceph-common
```

### Dashboard Not Accessible

Check manager status:
```bash
sudo cephadm shell -- ceph mgr services
```

## 🔄 Reset and Restart

To completely reset the environment:

```bash
./scripts/cleanup.sh
./scripts/00-prerequisites.sh
./scripts/01-bootstrap.sh
./scripts/03-deploy-osds-lvm.sh
./scripts/04-setup-cephfs.sh
```

## 📖 Additional Resources

- [Ceph Documentation](https://docs.ceph.com/)
- [CephFS Documentation](https://docs.ceph.com/en/latest/cephfs/)
- [Cephadm Documentation](https://docs.ceph.com/en/latest/cephadm/)

## 💡 Tips

1. **Be Patient:** Ceph operations can take time, especially initial bootstrap and OSD deployment
2. **Check Status Frequently:** Use `./scripts/status.sh` to monitor progress
3. **Read Logs:** Container logs provide valuable debugging information
4. **Experiment Safely:** This is a learning environment - break things and rebuild!
5. **Save Your Work:** Document your experiments and findings

## 🎯 Next Steps

After completing the basic setup:

1. **Learn about pools:** Create custom pools with different replication settings
2. **Explore CRUSH rules:** Modify data placement strategies
3. **Test snapshots:** CephFS supports filesystem snapshots
4. **Try quotas:** Set directory quotas on CephFS
5. **Multi-client access:** Mount CephFS from multiple clients simultaneously
6. **Performance tuning:** Experiment with different configurations

## ⚠️ Important Notes

- This is a **learning environment**, not production-ready
- Uses LVM volumes backed by loop devices instead of real disks
- Single-host deployment (all daemons on one machine)
- Uses `--single-host-defaults` for simplified configuration
- Simplified security (passwordless sudo, test credentials)
- No persistent storage across cleanup operations

---

**Happy Learning! 🚀**

For questions or issues, check the logs and status outputs first. Most problems are timing-related - give operations time to complete.
