# CephFS Cheat Sheet

## 🚀 Setup Commands (Run in Order)

```bash
# 1. Check prerequisites and setup passwordless sudo
./scripts/00-prerequisites.sh

# 2. Bootstrap cluster (creates MON and MGR)
./scripts/01-bootstrap.sh

# 3. Deploy OSDs with LVM (skip 02-add-hosts.sh for single-node)
./scripts/03-deploy-osds-lvm.sh

# 4. Setup CephFS (creates MDS and filesystem)
./scripts/04-setup-cephfs.sh

# 5. Mount on client servers
./scripts/mount-cephfs-client.sh  # Run on remote servers
```

## 📊 Monitoring Commands

```bash
# Quick status check
sudo cephadm shell -- ceph -s

# Enter Ceph shell (interactive)
sudo cephadm shell

# Inside shell - cluster health
ceph -s
ceph health detail

# OSD status
ceph osd tree
ceph osd status
ceph osd df

# Monitor status
ceph mon stat
ceph mon dump

# CephFS status
ceph fs ls
ceph fs status myfs
ceph mds stat

# Pool information
ceph df
ceph osd pool ls detail

# All services
ceph orch ps
ceph orch ls
```

## 🔧 Management Commands

### OSD Operations
```bash
# List OSDs
ceph osd ls

# OSD details
ceph osd dump

# Mark OSD down/out
ceph osd down <osd-id>
ceph osd out <osd-id>

# Mark OSD up/in
ceph osd in <osd-id>

# Remove OSD
ceph osd rm <osd-id>
```

### Pool Operations
```bash
# List pools
ceph osd pool ls

# Create pool
ceph osd pool create <pool-name> <pg-num>

# Delete pool (requires confirmation)
ceph osd pool delete <pool-name> <pool-name> --yes-i-really-really-mean-it

# Set pool size (replication)
ceph osd pool set <pool-name> size 3
ceph osd pool set <pool-name> min_size 2

# Pool stats
ceph osd pool stats
```

### CephFS Operations
```bash
# List filesystems
ceph fs ls

# Filesystem status
ceph fs status <fs-name>

# Get filesystem info
ceph fs get <fs-name>

# Create filesystem
ceph fs volume create <fs-name>

# Remove filesystem
ceph fs volume rm <fs-name> --yes-i-really-mean-it

# MDS status
ceph mds stat
ceph fs dump
```

### User/Auth Operations
```bash
# List users
ceph auth ls

# Get user key
ceph auth get client.admin
ceph auth get-key client.admin

# Create user
ceph auth get-or-create client.<name> mon 'allow r' mds 'allow rw' osd 'allow rw'

# Delete user
ceph auth del client.<name>
```

## 🔧 Cephadm Service Management

```bash
# List all services
sudo cephadm shell -- ceph orch ps
sudo cephadm shell -- ceph orch ls

# View service logs
sudo journalctl -u ceph-*.service -f

# Restart a service
sudo cephadm shell -- ceph orch restart <service-name>

# Stop/start daemon
sudo systemctl stop ceph-<fsid>@<daemon>
sudo systemctl start ceph-<fsid>@<daemon>

# Check systemd services
sudo systemctl list-units 'ceph*'

# View logs for specific daemon
sudo cephadm logs --fsid <fsid> --name <daemon-name>
```

## 🔍 Debugging Commands

```bash
# Check cluster health details
ceph health detail

# Check for slow operations
ceph -w  # Watch cluster in real-time

# Check PG status
ceph pg stat
ceph pg dump

# Check for stuck PGs
ceph pg dump_stuck

# Daemon versions
ceph versions

# Check configuration
ceph config dump
ceph config get mon

# Check logs
sudo journalctl -u 'ceph*' -f
sudo tail -f /var/log/ceph/<fsid>/ceph.log
```

## 📁 CephFS Mount Commands

### Kernel Mount (Linux)
```bash
# Get the secret key
SECRET=$(sudo cephadm shell -- ceph auth get-key client.myfs)

# Mount using client credentials
sudo mount -t ceph 192.168.1.215:6789:/ /mnt/cephfs \
  -o name=myfs,secret=AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA==

# Or using secretfile (more secure)
echo "AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA==" | sudo tee /etc/ceph/myfs.secret
sudo chmod 600 /etc/ceph/myfs.secret
sudo mount -t ceph 192.168.1.215:6789:/ /mnt/cephfs \
  -o name=myfs,secretfile=/etc/ceph/myfs.secret,noatime

# Unmount
sudo umount /mnt/cephfs
```

### FUSE Mount
```bash
# Install ceph-fuse
sudo apt install ceph-fuse

# Mount with ceph-fuse
sudo ceph-fuse /mnt/cephfs --name client.myfs

# Unmount
sudo fusermount -u /mnt/cephfs
```

### Persistent Mount (/etc/fstab)
```bash
# Add to /etc/fstab
192.168.1.215:6789:/  /mnt/cephfs  ceph  name=myfs,secretfile=/etc/ceph/myfs.secret,noatime,_netdev  0  2

# Mount all from fstab
sudo mount -a
```

## 🧪 Testing Commands

```bash
# Write test
dd if=/dev/zero of=/mnt/cephfs/testfile bs=1M count=100

# Read test
dd if=/mnt/cephfs/testfile of=/dev/null bs=1M

# Create many files
for i in {1..100}; do echo "file $i" > /mnt/cephfs/file$i.txt; done

# Check space usage
df -h /mnt/cephfs
ceph df

# Performance test
rados bench -p cephfs.myfs.data 10 write --no-cleanup
rados bench -p cephfs.myfs.data 10 seq
```

## 🔄 Common Workflows

### Check Cluster Health
```bash
./scripts/status.sh
# or
./scripts/shell.sh
ceph -s
```

### Add New OSD
```bash
# Create backing file and LVM volume
sudo dd if=/dev/zero of=/var/lib/ceph-osd-4.img bs=1M count=2048
LOOP_DEV=$(sudo losetup -f)
sudo losetup $LOOP_DEV /var/lib/ceph-osd-4.img
sudo pvcreate $LOOP_DEV
sudo vgcreate ceph-vg-4 $LOOP_DEV
sudo lvcreate -l 100%FREE -n osd-lv-4 ceph-vg-4

# Deploy OSD
sudo cephadm shell -- ceph orch daemon add osd $(hostname):/dev/ceph-vg-4/osd-lv-4
```

### Simulate Failure
```bash
# Stop an OSD service
sudo systemctl stop ceph-<fsid>@osd.0.service

# Watch recovery
watch -n 1 'sudo cephadm shell -- ceph -s'

# Restart OSD
sudo systemctl start ceph-<fsid>@osd.0.service
```

### Reset Everything
```bash
# Complete cleanup (removes cluster, LVM, sudo config)
./scripts/cleanup.sh

# Start fresh
./scripts/00-prerequisites.sh
./scripts/01-bootstrap.sh
./scripts/03-deploy-osds-lvm.sh
./scripts/04-setup-cephfs.sh
```

## 📊 Dashboard Access

- **URL:** https://192.168.1.215:8443 (or https://PanDeMongo:8443)
- **Username:** admin
- **Password:** admin123

**Note:** Accept the self-signed certificate warning in your browser.

## 🆘 Emergency Commands

```bash
# Force cluster to healthy (use with caution!)
ceph osd set noout
ceph osd set norecover
ceph osd set nobackfill

# Unset emergency flags
ceph osd unset noout
ceph osd unset norecover
ceph osd unset nobackfill

# Scrub OSDs
ceph osd deep-scrub <osd-id>

# Repair PG
ceph pg repair <pg-id>
```

## 💡 Pro Tips

1. **Always check status** before and after operations: `sudo cephadm shell -- ceph -s`
2. **Wait for HEALTH_OK** before proceeding to next phase
3. **Use `ceph -w`** to watch cluster in real-time
4. **Check logs** with `sudo journalctl -u 'ceph*' -f`
5. **Be patient** - Ceph operations can take time
6. **LVM volumes** are used for OSDs (not raw loop devices)
7. **Passwordless sudo** is required for cephadm operations
8. **Single-node setup** uses `--single-host-defaults` for testing

## 📚 Quick Reference

### Current Setup
- **Cluster FSID:** 15320132-a9c6-11f0-960a-91f76456ea36
- **Host:** PanDeMongo (192.168.1.215)
- **OSDs:** 3 x 2GB LVM volumes
- **Filesystem:** myfs
- **Client Key:** AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA==

| Component | Port | Purpose |
|-----------|------|---------|
| Monitor | 6789 | Cluster state |
| Manager | 3300 | Management |
| Dashboard | 8443 | Web UI |
| MDS | 6800 | Metadata |

| Status | Meaning |
|--------|---------|
| HEALTH_OK | All good ✅ |
| HEALTH_WARN | Warning ⚠️ |
| HEALTH_ERR | Error ❌ |

---

**Keep this handy while learning CephFS!** 📖
