# DevContainer Configuration Summary

## Overview

This is a **Data Science Classroom** dev container designed for MS3313 coursework at UTSA. It provides a complete R and Python data science environment with PostgreSQL database support, running on GitHub Codespaces (2-core, 16GB RAM).

**Base Image:** `quay.io/jupyter/datascience-notebook:latest`

---

## Container Architecture

### Files in `.devcontainer/`

| File                  | Purpose                                                              |
| --------------------- | -------------------------------------------------------------------- |
| `devcontainer.json`   | Main configuration - extensions, settings, ports, lifecycle commands |
| `Dockerfile`          | Custom image with system packages (PostgreSQL, libnlopt-dev, cmake)  |
| `conda_setup.sh`      | Runs once at container creation (`postCreateCommand`)                |
| `conda_post_start.sh` | Runs every time container starts/resumes (`postStartCommand`)        |

---

## Key Configuration Decisions

### 1. User: `jovyan` (not root)
- The base Jupyter image uses `jovyan` as the default user
- Passwordless sudo configured via: `echo 'jovyan ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jovyan`
- All scripts run as `jovyan` with sudo when needed for system operations

### 2. PostgreSQL: `student` User (No Password)
- PostgreSQL installed via apt (not conda) for reliability
- Primary user is `student` with SUPERUSER privileges
- **Trust authentication** configured in `pg_hba.conf` - no passwords required
- Connection command: `psql -U student -h localhost postgres` or just `psql`
- Environment variables set in `.bashrc`:
  ```bash
  export PGUSER=student
  export PGDATABASE=postgres
  export PGHOST=localhost
  export PGPORT=5432
  ```

### 3. R Kernel for Jupyter
- IRkernel installed and registered automatically
- User library at `~/R/library`
- Package installation uses 2 parallel cores (`Ncpus = 2`)

### 4. Git Configuration (Classroom-Friendly)
- **GPG signing disabled** to avoid commit failures:
  ```bash
  git config --global commit.gpgsign false
  git config --global tag.gpgsign false
  ```
- Default branch set to `main`
- Default user: "Data Science Student" / "student@example.com" (overrideable)

---

## VS Code Extensions

| Extension                                   | Purpose                    |
| ------------------------------------------- | -------------------------- |
| `ms-python.python`                          | Python support             |
| `ms-toolsai.jupyter`                        | Jupyter notebook support   |
| `reditorsupport.r`                          | R language support         |
| `ckolkman.vscode-postgres`                  | PostgreSQL browser         |
| `mtxr.sqltools` + `mtxr.sqltools-driver-pg` | SQL query editor           |
| `mechatroner.rainbow-csv`                   | CSV highlighting           |
| `janisdd.vscode-edit-csv`                   | CSV editing                |
| `github.copilot` + `github.copilot-chat`    | AI assistance (restricted) |
| `eamodio.gitlens`                           | Git visualization          |

---

## Copilot Restrictions (Anti-Cheating)

The following settings **restrict** advanced Copilot features for classroom integrity:

```json
"chat.agent.enabled": false,
"github.copilot.editor.enableCodeActions": false,
"github.copilot.nextEditSuggestions.enabled": false,
"github.copilot.renameSuggestions.triggerAutomatically": false,
"github.copilot.chat.agent.runTasks": false,
"github.copilot.chat.codesearch.enabled": false
```

Basic inline completions remain enabled. To fully disable Copilot, uncomment:
```json
"github.copilot.enable": false
```

---

## R Packages Installed

### Core Packages (Priority)
- `IRkernel`, `repr`, `IRdisplay`, `pbdZMQ`, `uuid`, `digest` - Jupyter kernel
- `languageserver` - VS Code R support
- `tidyverse`, `dplyr`, `ggplot2`, `readr`, `tibble` - Data manipulation
- `Hmisc`, `pastecs`, `psych`, `e1071`, `caret` - Statistics
- `fastDummies`, `reshape2` - Data transformation

### Additional Packages
- **ML:** `MASS`, `class`, `randomForest`, `nnet`
- **Visualization:** `corrplot`, `ggcorrplot`, `GGally`, `gridExtra`, `ggdendro`, `ggrepel`
- **Clustering:** `factoextra`, `FactoMineR`, `cluster`, `pls`
- **ANOVA:** `car`, `effectsize`, `rstatix`, `multcomp`, `ggpubr`
- **Factor Analysis:** `GPArotation`, `nFactors`, `lavaan`
- **Database:** `DBI`, `RPostgreSQL`, `dbplyr`
- **Other:** `broom`, `scales`

### GitHub Packages
- `mlba` from `gedeck/mlba/mlba` - Required for course assignments
- `DiscriMiner` from `gastonstat/DiscriMiner` - Discriminant analysis

---

## Conda Packages Installed

```
psycopg2, sqlalchemy, plotly, bokeh, lxml, beautifulsoup4, 
nodejs, gh, imagemagick, r-devtools, r-remotes
```

---

## Port Forwarding

| Port | Label                  | Behavior    |
| ---- | ---------------------- | ----------- |
| 8888 | Jupyter Lab            | notify      |
| 5432 | PostgreSQL             | silent      |
| 3000 | Development Server     | openPreview |
| 8000 | Python Web Server      | openPreview |
| 8080 | Alternative Web Server | openPreview |

---

## Lifecycle Scripts

### `postCreateCommand` (conda_setup.sh) - Runs Once
1. Install mamba (faster package manager)
2. Install conda packages
3. Configure Jupyter (no token/password)
4. Configure git (disable GPG, set defaults)
5. Set up PostgreSQL with trust authentication
6. Create `student` user with SUPERUSER privileges
7. Install all R packages
8. Install `mlba` and `DiscriMiner` from GitHub
9. Register R kernel with Jupyter

### `postStartCommand` (conda_post_start.sh) - Runs Every Start
1. Start PostgreSQL service if not running
2. Verify `student` user exists
3. Run `setup_student_primary.sh` if exists
4. Load sample databases if script exists
5. Verify R kernel is registered
6. Verify `mlba` package is available
7. Configure git (GPG signing off, defaults)
8. Print status and quick commands

---

## Helper Scripts in `/scripts/`

| Script                         | Purpose                              |
| ------------------------------ | ------------------------------------ |
| `check_environment.sh`         | Full environment verification        |
| `start_postgresql.sh`          | Start PostgreSQL service             |
| `autostart_postgresql.sh`      | Auto-start PostgreSQL                |
| `setup_student_primary.sh`     | Configure student as primary DB user |
| `load_all_sample_databases.sh` | Load sample databases                |
| `setup_r_kernel.sh`            | Register R kernel                    |
| `install_r_packages.sh`        | Install R packages                   |
| `fix_database_permissions.sh`  | Fix DB permission issues             |
| `fix_git.sh`                   | Fix git configuration                |

---

## Aliases Available

```bash
pg_start      # Start PostgreSQL
pg_stop       # Stop PostgreSQL
pg_status     # Check PostgreSQL status
pg_restart    # Restart PostgreSQL
db            # Connect to database (psql -U student -h localhost postgres)
check_status  # Run full environment check
```

---

## Directory Structure

```
/workspaces/test2/
├── .devcontainer/          # Container configuration
├── Lecture/                # Jupyter notebooks for modules 1-5
├── Homework/               # Student assignments
├── data/                   # CSV datasets organized by module
│   ├── module_1/           # Basic stats data
│   ├── module_2/           # ANOVA/MANOVA data
│   ├── module_3/           # PCA/MDS data
│   ├── module_4/           # Factor analysis data
│   ├── module_5/           # Clustering data
│   └── module_6/           # (empty)
├── databases/              # Database backups
└── scripts/                # Helper shell scripts
```

---

## Known Issues & Fixes

### Issue: GPG signing errors on git commit
**Fix:** Already configured to disable GPG signing globally and locally.

### Issue: PostgreSQL not starting
**Fix:** Run `sudo service postgresql start` or use `pg_start` alias.

### Issue: R kernel not appearing in Jupyter
**Fix:** Run `R -e "IRkernel::installspec(user = TRUE)"`

### Issue: mlba package missing
**Fix:** Run `devtools::install_github('gedeck/mlba/mlba')` in R

### Issue: Settings Sync overriding devcontainer settings
**Fix:** `"settingsSync.enable": false` is set in devcontainer.json

---

## Changes from Base Template

1. **Added Copilot restrictions** for classroom integrity
2. **Disabled GPG signing** for git commits (classroom-friendly)
3. **Configured PostgreSQL with trust authentication** (no passwords)
4. **Added `student` as primary database user** with SUPERUSER
5. **Added extensions auto-update** setting
6. **Disabled Settings Sync** to preserve classroom settings
7. **Added GitLens extension** for git visualization
8. **Added upstream remote** pointing to `humphrjk-utsa/MS3313_base_template.git`

---

## Template Synchronization

The repository has two remotes:
- `origin`: https://github.com/UTSA-Humphries-Data-Science/test2 (student fork)
- `upstream`: https://github.com/humphrjk-utsa/MS3313_base_template.git (base template)

To pull updates from the base template:
```bash
git fetch upstream
git merge upstream/main
```

---

## Testing the Environment

After container rebuild, verify:
```bash
# Check PostgreSQL
psql -c "SELECT version();"

# Check R kernel
jupyter kernelspec list | grep ir

# Check R packages
R -e "library(mlba); library(tidyverse)"

# Check git
git status
git log --oneline -3

# Full check
check_status
```

---

*Last Updated: February 6, 2026*
