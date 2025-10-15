# Storage Requirements Breakdown

## 📊 Actual Space Usage

### Standard Configuration (Current)
- **OSD Storage**: 3 OSDs × 2GB = 6GB
- **Container Images**: ~1.5GB (Ceph v18 image)
- **Metadata & Logs**: ~500MB
- **Total**: ~8GB actual usage

### Minimal Configuration (Optional)
If you want to go even smaller:
- **OSD Storage**: 3 OSDs × 1GB = 3GB
- **Total**: ~5GB actual usage

## 🔧 How to Make It Even Smaller

### Option 1: Reduce to 1GB per OSD
Edit `scripts/03-deploy-osds.sh` line 16:
```bash
# Change from:
dd if=/dev/zero of=/var/lib/ceph/osd-device.img bs=1M count=2048

# To:
dd if=/dev/zero of=/var/lib/ceph/osd-device.img bs=1M count=1024
```

### Option 2: Use Only 2 OSDs
Edit `docker-compose.yml` - comment out or remove the `osd3` service.

Then in `scripts/02-add-hosts.sh`, remove the line:
```bash
add_host "osd3" "172.20.0.22"
```

**Result**: ~5GB total usage

### Option 3: Ultra-Minimal (Not Recommended)
- 2 monitors instead of 3
- 2 OSDs with 512MB each
- **Result**: ~3GB total usage
- **Warning**: Less realistic for learning Ceph's distributed nature

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
docker system prune -a  # Remove unused images too
```

---

**Bottom line**: 10GB is plenty for learning CephFS! 🎉
