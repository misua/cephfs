# Storage Requirements Breakdown

## 📊 Actual Space Usage

### Standard Configuration (Current)
- **OSD Storage**: 3 OSDs × 2GB = 6GB (LVM volumes)
- **Container Images**: ~1.5GB (Ceph v17 Quincy image)
- **Metadata & Logs**: ~500MB
- **Total**: ~8GB actual usage

### Minimal Configuration (Optional)
If you want to go even smaller:
- **OSD Storage**: 3 OSDs × 1GB = 3GB
- **Total**: ~5GB actual usage

## 🔧 How to Make It Even Smaller

### Option 1: Reduce to 1GB per OSD
Edit `scripts/03-deploy-osds-lvm.sh` line 17:
```bash
# Change from:
sudo dd if=/dev/zero of=/var/lib/ceph-osd-$i.img bs=1M count=2048

# To:
sudo dd if=/dev/zero of=/var/lib/ceph-osd-$i.img bs=1M count=1024
```

### Option 2: Use Only 2 OSDs
Edit `scripts/03-deploy-osds-lvm.sh`, change the loop:
```bash
# Change from:
for i in 1 2 3; do

# To:
for i in 1 2; do
```

**Result**: ~5GB total usage

### Option 3: Ultra-Minimal (Not Recommended)
- Single monitor/manager (already the case)
- 2 OSDs with 512MB each
- **Result**: ~3GB total usage
- **Warning**: Too small for realistic testing

## 💡 Why 2GB per OSD?

- **Minimum viable**: Ceph needs some space for metadata and BlueStore
- **Room to experiment**: Write test files, create snapshots, etc.
- **Realistic behavior**: Too small and you'll hit edge cases not seen in production

## 🎯 Recommended: Stick with 2GB per OSD

This gives you:
- ✅ Enough space to test real workloads
- ✅ Room for multiple CephFS files
- ✅ Ability to test replication and recovery
- ✅ Won't fill up during normal learning

## 📈 Space Usage Over Time

```
Initial setup:        ~2GB
After bootstrap:      ~3GB
After OSD deploy:     ~8GB
During testing:       ~8-9GB (depends on your test data)
```

## 🧹 Cleanup

To reclaim all space:
```bash
./scripts/cleanup.sh

# Optional: Remove Ceph container images
sudo podman system prune -a
# or
sudo docker system prune -a
```

---

**Bottom line**: 10GB is plenty for learning CephFS! 🎉
