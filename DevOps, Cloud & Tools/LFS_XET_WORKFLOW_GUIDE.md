# GitHub + Hugging Face Spaces: Large File Management Guide

## Overview

This guide documents the workflow for handling large files (models, images) when syncing a GitHub repository with Hugging Face Spaces, specifically dealing with:
- **GitHub's 100MB file size limit**
- **Git LFS** for GitHub storage
- **Xet** for Hugging Face Spaces storage (with chunk-level deduplication)

---

## The Problem

1. **GitHub rejects files >100MB**
   - Example: `yolo26x.pt` is 113.17 MB
   - Error: `remote: error: File models/yolo26x.pt is 113.17 MB; this exceeds GitHub's file size limit of 100.00 MB`

2. **GitHub Actions workflow fails when pushing to HF Spaces**
   - LFS objects not properly pulled before pushing
   - Diverged branches between GitHub and HF Spaces

---

## The Solution

### Architecture
```
GitHub Repository (Git LFS)
        ↓
GitHub Actions Workflow
        ↓
Hugging Face Spaces (Xet Storage)
```

- **GitHub**: Uses Git LFS to store files >100MB
- **HF Spaces**: Uses Xet for efficient storage with chunk-level deduplication
- **GitHub Actions**: Pulls LFS objects, installs Xet, pushes to HF

---

## Step-by-Step Setup

### 1. Track Large Files with Git LFS

```bash
# Initialize LFS tracking for common ML file formats
git lfs track "*.pt"
git lfs track "*.pth"
git lfs track "*.bin"
git lfs track "*.safetensors"
git lfs track "*.ckpt"
git lfs track "*.onnx"
git lfs track "*.h5"

# Also track images if needed
git lfs track "*.jpg"
git lfs track "*.jpeg"
git lfs track "*.png"
git lfs track "*.gif"

# Commit the .gitattributes file
git add .gitattributes
git commit -m "Configure Git LFS for large files"
```

### 2. Configure .gitattributes

Create/Edit `.gitattributes`:
```gitattributes
# Model files - Use Git LFS for GitHub
*.pt filter=lfs diff=lfs merge=lfs -text
*.pth filter=lfs diff=lfs merge=lfs -text
*.bin filter=lfs diff=lfs merge=lfs -text
*.safetensors filter=lfs diff=lfs merge=lfs -text
*.ckpt filter=lfs diff=lfs merge=lfs -text
*.onnx filter=lfs diff=lfs merge=lfs -text
*.h5 filter=lfs diff=lfs merge=lfs -text

# Image formats
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
*.bmp filter=lfs diff=lfs merge=lfs -text
*.tiff filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text
*.svg filter=lfs diff=lfs merge=lfs -text
*.ico filter=lfs diff=lfs merge=lfs -text
```

**Important**: Use `filter=lfs` NOT `filter=xet` for GitHub compatibility!

### 3. Add Large Files to Repository

```bash
# If files were already tracked as regular files, re-track them with LFS:
git rm --cached models/*.pt
git add models/*.pt
git commit -m "Track model files with Git LFS"
```

### 4. Push to GitHub

```bash
# Increase buffer size for large pushes
git config http.postBuffer 524288000

# Push (may take time for large files)
git push origin main
```

**Note**: LFS uploads can be slow. The command may appear to hang - this is normal.

---

## GitHub Actions Workflow

Create `.github/workflows/sync.yml`:

```yaml
name: Sync to Hugging Face Hub
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  sync-to-hub:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          lfs: true  # CRITICAL: Enable LFS checkout
      
      - name: Pull LFS objects
        run: git lfs pull  # CRITICAL: Download actual files, not pointers
      
      - name: Install Git Xet
        run: |
          curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/huggingface/xet-core/refs/heads/main/git_xet/install.sh | sh
          git xet install
      
      - name: Push to hub
        env:
          HF_TOKEN: ${{ secrets.HF_TOKEN }}
        # Use --force to handle diverged branches
        run: git push --force https://USERNAME:$HF_TOKEN@huggingface.co/spaces/USERNAME/SPACE_NAME main
```

**Critical Components:**
1. `lfs: true` - Checks out LFS pointers
2. `git lfs pull` - Downloads actual file content
3. `--force` - Handles diverged branches between GitHub and HF

---

## Common Errors & Solutions

### Error 1: File exceeds GitHub's 100MB limit
```
remote: error: File models/yolo26x.pt is 113.17 MB; this exceeds GitHub's file size limit of 100.00 MB
```

**Solution**: Use Git LFS migration
```bash
# Migrate existing commits to use LFS
git lfs migrate import --include="*.pt" --include-ref=main

# Force push the rewritten history
git push origin main --force
```

### Error 2: LFS objects missing in GitHub Actions
```
Git LFS upload failed:
  (missing) models/yolo26x.pt (hash...)
```

**Solution**: Add `git lfs pull` to workflow
```yaml
- name: Pull LFS objects
  run: git lfs pull
```

### Error 3: Rejected push to HF Spaces
```
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://huggingface.co/spaces/...'
hint: Updates were rejected because the remote contains work that you do not have locally
```

**Solution**: Use force push in workflow
```bash
git push --force https://... main
```

### Error 4: Wrong remote configured
```bash
# Check remotes
git remote -v

# If wrong, remove and re-add
git remote remove space
git remote add space https://huggingface.co/spaces/USERNAME/SPACE_NAME
```

---

## Workflow Summary

### When Adding New Large Files:

1. **Track the file extension** (if new type):
   ```bash
   git lfs track "*.newextension"
   git add .gitattributes
   git commit -m "Track .newextension files with LFS"
   ```

2. **Add the files**:
   ```bash
   git add path/to/large/file.newextension
   git commit -m "Add new model/dataset"
   ```

3. **Push to GitHub**:
   ```bash
   git push origin main
   ```

4. **GitHub Actions automatically**:
   - Pulls LFS objects
   - Installs Git Xet
   - Pushes to HF Spaces with Xet storage

### Verification:

- Check LFS tracked files:
  ```bash
  git lfs ls-files
  ```

- Check LFS status:
  ```bash
  git lfs status
  ```

- Verify GitHub Actions on GitHub repo → Actions tab

- Verify HF Space at: `https://huggingface.co/spaces/USERNAME/SPACE_NAME`

---

## Key Takeaways

1. **GitHub** uses **Git LFS** for files >100MB
2. **HF Spaces** uses **Xet** (automatic conversion during push)
3. **Always** include `lfs: true` and `git lfs pull` in GitHub Actions
4. Use `--force` for HF Spaces push to avoid diverged branch issues
5. Verify with `git lfs ls-files` before pushing
6. Large LFS uploads can be slow - be patient!

---

## Resources

- [Git LFS Documentation](https://git-lfs.github.com/)
- [Hugging Face Xet Documentation](https://huggingface.co/docs/hub/xet)
- [HF Spaces GitHub Actions Guide](https://huggingface.co/docs/hub/spaces-github-actions)
