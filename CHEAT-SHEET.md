# CephFS Cheat Sheet

## 🚀 Setup Commands (Run in Order)

```bash
# 1. Start containers
docker-compose up -d

# 2. Bootstrap cluster
./scripts/01-bootstrap.sh

# 3. Add hosts
./scripts/02-add-hosts.sh

# 4. Deploy OSDs
./scripts/03-deploy-osds.sh

# 5. Setup CephFS
./scripts/04-setup-cephfs.sh

# 6. Test mount
./scripts/test-mount.sh
```

## 📊 Monitoring Commands

```bash
# Quick status check
./scripts/status.sh

# Enter Ceph shell
./scripts/shell.sh

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

## 🐳 Docker Commands

```bash
# View running containers
docker-compose ps

# View logs
docker logs ceph-mon1
docker logs ceph-osd1 -f  # Follow logs

# Execute command in container
docker exec ceph-mon1 <command>

# Interactive shell in container
docker exec -it ceph-mon1 bash

# Restart container
docker restart ceph-mon1

# Stop all containers
docker-compose down

# Start all containers
docker-compose up -d

# Remove everything
docker-compose down -v
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

# Check logs in container
docker exec ceph-mon1 tail -f /var/log/ceph/ceph.log
```

## 📁 CephFS Mount Commands

### Kernel Mount (Linux)
```bash
# Get the secret key
SECRET=$(docker exec ceph-mon1 cephadm shell -- ceph auth get-key client.admin)

# Mount
sudo mount -t ceph 172.20.0.10:6789:/ /mnt/cephfs -o name=admin,secret=$SECRET

# Or using keyring file
sudo mount -t ceph 172.20.0.10:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/admin.secret

# Unmount
sudo umount /mnt/cephfs
```

### FUSE Mount
```bash
# Mount with ceph-fuse
ceph-fuse -m 172.20.0.10:6789 /mnt/cephfs

# Unmount
fusermount -u /mnt/cephfs
```

### In Test Client Container
```bash
# Access client
docker exec -it ceph-client bash

# CephFS is already mounted at
cd /mnt/cephfs

# Test operations
echo "test" > /mnt/cephfs/file.txt
ls -la /mnt/cephfs/
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
# Create storage device in container
docker exec osd1 dd if=/dev/zero of=/var/lib/ceph/new-osd.img bs=1M count=10240
docker exec osd1 losetup -f /var/lib/ceph/new-osd.img

# Deploy OSD
docker exec ceph-mon1 cephadm shell -- ceph orch daemon add osd osd1:/dev/loop1
```

### Simulate Failure
```bash
# Stop an OSD
docker stop ceph-osd1

# Watch recovery
watch -n 1 './scripts/status.sh'

# Restart OSD
docker start ceph-osd1
```

### Reset Everything
```bash
./scripts/cleanup.sh
docker-compose up -d
./scripts/01-bootstrap.sh
# Continue with other scripts...
```

## 📊 Dashboard Access

- **URL:** https://172.20.0.10:8443
- **Username:** admin
- **Password:** admin123

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

1. **Always check status** before and after operations
2. **Wait for HEALTH_OK** before proceeding to next phase
3. **Use `ceph -w`** to watch cluster in real-time
4. **Check logs** when things go wrong
5. **Be patient** - Ceph operations can take time

## 📚 Quick Reference

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
