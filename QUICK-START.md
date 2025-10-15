# CephFS Quick Start Guide

## 🎯 Goal
Get a working CephFS cluster in ~15 minutes.

## ⚡ Fast Track

### 1. Start Containers (1 min)
```bash
cd ceph-test
docker compose up -d
docker compose ps  # Verify all 6 containers are running
```

### 2. Bootstrap Cluster (2-3 min)
```bash
chmod +x scripts/*.sh
./scripts/01-bootstrap.sh
```
✅ **Success indicator:** Dashboard URL displayed

### 3. Add Hosts (3-4 min)
```bash
./scripts/02-add-hosts.sh
```
✅ **Success indicator:** All 6 hosts listed

### 4. Deploy Storage (3-5 min)
```bash
./scripts/03-deploy-osds.sh
```
✅ **Success indicator:** OSD tree shows 3 OSDs

**⏸️ WAIT:** Check cluster health before proceeding
```bash
./scripts/status.sh
```
Look for `HEALTH_OK` - if you see warnings, wait 1-2 more minutes.

### 5. Create CephFS (2-3 min)
```bash
./scripts/04-setup-cephfs.sh
```
✅ **Success indicator:** Mount instructions displayed

### 6. Test It (1-2 min)
```bash
./scripts/test-mount.sh
```
✅ **Success indicator:** "Hello from CephFS!" message

## 🎉 You're Done!

Access your cluster:
- **Dashboard:** https://172.20.0.10:8443 (admin/admin123)
- **Shell:** `./scripts/shell.sh`
- **Status:** `./scripts/status.sh`

## 🔧 Quick Commands

```bash
# Check everything
./scripts/status.sh

# Interactive Ceph shell
./scripts/shell.sh

# Access test client
docker exec -it ceph-client bash
cd /mnt/cephfs

# Reset everything
./scripts/cleanup.sh
```

## ❓ Troubleshooting

**Containers won't start?**
```bash
docker compose down
docker compose up -d
```

**Cluster not healthy?**
```bash
./scripts/shell.sh
ceph health detail
```
Usually just needs more time - wait 2 minutes and check again.

**Script fails?**
- Check if previous step completed successfully
- Verify all containers are running: `docker compose ps`
- Check logs: `docker logs ceph-mon1`

## 📖 Learn More

See [README.md](README.md) for:
- Detailed explanations
- Architecture diagrams
- Learning exercises
- Advanced topics

---

**Total Time:** ~15 minutes | **Difficulty:** Beginner-friendly
