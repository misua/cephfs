# CephFS Learning Environment

A complete Docker-based setup for learning CephFS with a multi-node Ceph cluster.

## 📋 Overview

This environment provides:
- **3 Monitor/Manager nodes** (mon1, mon2, mon3)
- **3 OSD (Object Storage Daemon) nodes** (osd1, osd2, osd3)
- **Automated setup scripts** for easy deployment
- **CephFS filesystem** ready for testing

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Ceph Cluster                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Monitors/Managers:          OSDs (Storage):           │
│  ┌──────┐ ┌──────┐ ┌──────┐  ┌──────┐ ┌──────┐ ┌──────┐│
│  │ mon1 │ │ mon2 │ │ mon3 │  │ osd1 │ │ osd2 │ │ osd3 ││
│  └──────┘ └──────┘ └──────┘  └──────┘ └──────┘ └──────┘│
│  172.20  172.20  172.20     172.20  172.20  172.20    │
│    .10     .11     .12        .20     .21     .22      │
│                                                         │
│                    CephFS Layer                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Metadata Servers (MDS) + Data Pools            │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- At least 4GB RAM available
- 10GB free disk space (actual usage ~8GB)

### Install Docker (Ubuntu 24.04)

If Docker isn't installed:

```bash
# Install Docker and Compose
sudo apt update
sudo apt install -y docker.io docker-compose-v2

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose version
```

### Step-by-Step Setup

#### 1. Start the Containers

```bash
cd ceph-test
docker compose up -d
```

Wait for all containers to be running:
```bash
docker compose ps
```

#### 2. Bootstrap the Cluster (Phase 1)

This initializes the first monitor and manager:

```bash
chmod +x scripts/*.sh
./scripts/01-bootstrap.sh
```

**What this does:**
- Installs `cephadm` on mon1
- Creates the initial monitor daemon
- Creates the initial manager daemon
- Sets up the Ceph dashboard (accessible at https://172.20.0.10:8443)

**Expected output:** Bootstrap completion message with dashboard credentials

**Wait time:** ~2 minutes

#### 3. Add Hosts to Cluster (Phase 2a)

```bash
./scripts/02-add-hosts.sh
```

**What this does:**
- Installs SSH on all nodes
- Configures SSH keys for cephadm
- Adds mon2, mon3, osd1, osd2, osd3 to the cluster
- Labels hosts appropriately

**Expected output:** Confirmation that all hosts are added

**Wait time:** ~3 minutes

#### 4. Deploy OSDs (Phase 2b)

```bash
./scripts/03-deploy-osds.sh
```

**What this does:**
- Creates loop devices (virtual disks) on each OSD node
- Deploys OSD daemons on available devices
- Initializes the storage layer

**Expected output:** OSD tree showing deployed OSDs

**Wait time:** ~3-5 minutes

**Verify OSDs are up:**
```bash
./scripts/status.sh
```

Look for `HEALTH_OK` status and all OSDs showing as `up`.

#### 5. Setup CephFS (Phase 3)

```bash
./scripts/04-setup-cephfs.sh
```

**What this does:**
- Creates MDS (Metadata Server) daemons
- Creates the CephFS filesystem named 'myfs'
- Creates client authentication keys
- Displays mount information

**Expected output:** CephFS status and mount instructions

**Wait time:** ~2 minutes

#### 6. Test CephFS Mount

```bash
./scripts/test-mount.sh
```

**What this does:**
- Creates a test client container
- Mounts CephFS
- Performs read/write tests

## 🛠️ Helper Scripts

### Check Cluster Status
```bash
./scripts/status.sh
```
Shows overall health, OSD status, monitors, and CephFS status.

### Access Cephadm Shell
```bash
./scripts/shell.sh
```
Opens an interactive shell with full Ceph CLI access.

### Cleanup Everything
```bash
./scripts/cleanup.sh
```
**Warning:** Destroys all data and resets the environment.

## 📊 Monitoring & Management

### Ceph Dashboard

Access the web dashboard at: **https://172.20.0.10:8443**

- **Username:** admin
- **Password:** admin123

(Accept the self-signed certificate warning)

### Common Commands

Inside the cephadm shell (`./scripts/shell.sh`):

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

# View host list
ceph orch host ls
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
docker stop ceph-osd1
./scripts/status.sh
# Wait and observe
docker start ceph-osd1
```

### Exercise 3: Write Data to CephFS
```bash
docker exec -it ceph-client bash
cd /mnt/cephfs
mkdir test-directory
echo "Learning CephFS" > test-directory/file.txt
ls -lR
```

### Exercise 4: Monitor Performance
```bash
./scripts/shell.sh
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
docker logs ceph-osd1
```

### CephFS Mount Fails

Verify MDS is active:
```bash
./scripts/shell.sh
ceph mds stat
```

### Dashboard Not Accessible

Check manager status:
```bash
docker exec ceph-mon1 cephadm shell -- ceph mgr services
```

## 🔄 Reset and Restart

To completely reset the environment:

```bash
./scripts/cleanup.sh
docker compose up -d
./scripts/01-bootstrap.sh
# ... continue with other scripts
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
- Uses loop devices instead of real disks
- Single-host deployment (all containers on one machine)
- Simplified networking and security
- No persistent storage across cleanup operations

---

**Happy Learning! 🚀**

For questions or issues, check the logs and status outputs first. Most problems are timing-related - give operations time to complete.
