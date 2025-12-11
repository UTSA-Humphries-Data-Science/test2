# Scripts

**⚠️ NOTE: Most setup is now AUTOMATIC during container build!**

These scripts are primarily for **manual fixes** and **troubleshooting**. The R kernel, PostgreSQL, and packages are automatically configured when the devcontainer builds via `.devcontainer/conda_setup.sh`.

## Manual Override Scripts (Use only if needed)

### R Environment
- `setup_r_kernel.sh` - **Manual** R kernel setup (automatic during build)
- `install_r_packages.sh` - Install additional R packages
- `check_r_kernel_status.sh` - Check R kernel status
- `test_r_kernel.sh` - Test R kernel functionality

### Database Scripts
- `start_postgresql.sh` - Start PostgreSQL service manually
- `autostart_postgresql.sh` - Configure PostgreSQL auto-start
- `setup_student_primary.sh` - Setup student database user
- `fix_database_permissions.sh` - Fix database permissions
- `load_all_sample_databases.sh` - Load sample databases

### Utilities
- `fix_git.sh` - Fix Git configuration issues

## When to Use These Scripts

**You typically DON'T need to run these scripts** because:
- R kernel is set up automatically during container build
- PostgreSQL starts automatically
- ImageMagick and R packages (magick, summarytools) install automatically

**Only run these scripts if:**
- You need to reinstall/fix a broken R kernel
- You need to manually restart PostgreSQL
- You're troubleshooting specific issues
