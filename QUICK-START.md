# CephFS Quick Start Guide

## 🎯 Goal
Get a working CephFS cluster in ~15 minutes.

## ⚡ Fast Track

### 1. Prerequisites Check (1-2 min)
```bash
cd ceph-test
chmod +x scripts/*.sh
./scripts/00-prerequisites.sh
```
✅ **Success indicator:** "All prerequisites met!"

### 2. Bootstrap Cluster (3-5 min)
```bash
./scripts/01-bootstrap.sh
```
✅ **Success indicator:** Dashboard URL displayed (https://192.168.1.215:8443)

### 3. Deploy Storage (3-5 min)
```bash
./scripts/03-deploy-osds-lvm.sh
```
✅ **Success indicator:** OSD tree shows 3 OSDs up

**⏸️ WAIT:** Check cluster health before proceeding
```bash
sudo cephadm shell -- ceph -s
```
Look for `osd: 3 osds: 3 up, 3 in`

### 4. Create CephFS (1-2 min)
```bash
./scripts/04-setup-cephfs.sh
```
✅ **Success indicator:** Mount instructions displayed

### 5. Test It (Optional)
```bash
sudo apt install ceph-common
sudo mkdir -p /mnt/cephfs
sudo mount -t ceph 192.168.1.215:6789:/ /mnt/cephfs \
  -o name=myfs,secret=AQDzm+9oZwBOChAADcgK7S4gQEq8hpxSa/76DA==
echo "Hello CephFS!" | sudo tee /mnt/cephfs/test.txt
```
✅ **Success indicator:** File created successfully

## 🎉 You're Done!

Access your cluster:
- **Dashboard:** https://192.168.1.215:8443 (admin/admin123)
- **Shell:** `sudo cephadm shell`
- **Status:** `sudo cephadm shell -- ceph -s`

## 🔧 Quick Commands

```bash
# Check everything
sudo cephadm shell -- ceph -s
sudo cephadm shell -- ceph osd tree

# Interactive Ceph shell
sudo cephadm shell

# Access mounted CephFS
cd /mnt/cephfs

# Reset everything
./scripts/cleanup.sh
```

## ❓ Troubleshooting

**Prerequisites fail?**
```bash
# Fix reported issues and re-run
./scripts/00-prerequisites.sh
```

**Cluster not healthy?**
```bash
sudo cephadm shell -- ceph health detail
```
Usually just needs more time - wait 2 minutes and check again.

**Script fails?**
- Check if previous step completed successfully
- Check logs: `sudo journalctl -u 'ceph*' -f`
- Verify SSH works: `ssh localhost echo test`

## 📖 Learn More

See [README.md](README.md) for:
- Detailed explanations
- Architecture diagrams
- Learning exercises
- Advanced topics

---

**Total Time:** ~15 minutes | **Difficulty:** Beginner-friendly | **Setup:** Single-node cephadm
