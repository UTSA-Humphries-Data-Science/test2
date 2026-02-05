#!/bin/bash
# Optimized conda-based setup for GitHub Codespaces (2-core, 16GB)
# Uses mamba for faster installs and parallel R package installation

set -e  # Exit on error
trap 'echo "❌ Setup failed at line $LINENO. Check logs above."' ERR

echo "🚀 Setting up data science environment (optimized for Codespaces)..."
echo "📋 User: $(whoami) | Cores: $(nproc) | Memory: $(free -h | awk '/^Mem:/{print $2}')"
START_TIME=$(date +%s)

# Initialize conda for bash if not already done
if ! grep -q "conda initialize" ~/.bashrc 2>/dev/null; then
    echo "🔧 Initializing conda for bash..."
    conda init bash
fi
source ~/.bashrc 2>/dev/null || true

# ============================================
# STEP 1: Install mamba for faster package management
# ============================================
echo ""
echo "📦 Step 1/5: Installing mamba (faster package manager)..."
if ! command -v mamba &> /dev/null; then
    conda install -n base -c conda-forge mamba -y --quiet 2>&1 | tail -3
    echo "✅ Mamba installed"
else
    echo "✅ Mamba already available"
fi

# ============================================
# STEP 2: Install conda packages (using mamba for speed)
# ============================================
echo ""
echo "📦 Step 2/5: Installing conda packages..."

# Essential packages - PostgreSQL is installed via apt in postCreateCommand
mamba install -c conda-forge -y --quiet \
    psycopg2 \
    sqlalchemy \
    plotly \
    bokeh \
    lxml \
    beautifulsoup4 \
    nodejs \
    gh \
    imagemagick \
    r-devtools \
    r-remotes 2>&1 | tail -5

echo "✅ Conda packages installed"

# ============================================
# STEP 3: Configure environment
# ============================================
echo ""
echo "⚙️ Step 3/5: Configuring environment..."

# Jupyter configuration
mkdir -p ~/.jupyter
cat > ~/.jupyter/jupyter_server_config.py << 'EOF'
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
EOF

# Git configuration (disable GPG for classroom use)
git config --global init.defaultBranch main
git config --global commit.gpgsign false
git config --global tag.gpgsign false
git config --global user.name "Data Science Student" 2>/dev/null || true
git config --global user.email "student@example.com" 2>/dev/null || true

# PostgreSQL environment variables (check if already added)
if ! grep -q "PGUSER=" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'BASHRC_EOF'

# PostgreSQL environment - student user (no password)
export PGUSER=student
export PGDATABASE=postgres
export PGHOST=localhost
export PGPORT=5432

# Aliases for database operations (apt-installed PostgreSQL)
alias pg_start='sudo service postgresql start'
alias pg_stop='sudo service postgresql stop'
alias pg_status='sudo service postgresql status'
alias pg_restart='sudo service postgresql restart'

# Quick database connection
alias db='psql -U student -h localhost postgres'

# Quick status check
alias check_status='/workspaces/test2/scripts/check_environment.sh'
BASHRC_EOF
fi

source ~/.bashrc 2>/dev/null || true
echo "✅ Environment configured"

# ============================================
# STEP 4: Set up PostgreSQL (apt-installed)
# ============================================
echo ""
echo "🗄️ Step 4/5: Setting up PostgreSQL..."

# PostgreSQL is installed via apt in postCreateCommand
# Configure pg_hba.conf for trust authentication (no password)
if [ -f /etc/postgresql/*/main/pg_hba.conf ]; then
    echo "🔐 Configuring PostgreSQL for trust authentication..."
    sudo bash -c 'cat > /etc/postgresql/*/main/pg_hba.conf << EOF
# Trust authentication for classroom use (no passwords)
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
EOF'
    
    # Restart PostgreSQL to apply changes
    sudo service postgresql restart
    sleep 2
fi

# Create student user and databases (student is the PRIMARY user)
echo "👤 Setting up student as primary PostgreSQL user (no password)..."
sudo -u postgres psql -c "CREATE USER student WITH SUPERUSER CREATEDB;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE student OWNER student;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE postgres TO student;" 2>/dev/null || true

echo "✅ PostgreSQL configured with student as primary user"

# ============================================
# STEP 5: Set up R environment and packages
# ============================================
echo ""
echo "📊 Step 5/5: Setting up R packages (this takes a few minutes)..."

# Create R profile first
cat > ~/.Rprofile << 'RPROFILE'
# User library setup
user_lib <- "~/R/library"
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(Ncpus = 2)  # Parallel package installation
RPROFILE

# Install R packages
R --no-save --no-restore --quiet << 'RSCRIPT'
# Setup
user_lib <- "~/R/library"
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org/"))

cat("📦 Installing R packages with parallel compilation...\n")

# Core packages needed for assignments (prioritized)
core_packages <- c(
    # IRkernel (must be first)
    "IRkernel", "repr", "IRdisplay", "pbdZMQ", "uuid", "digest",
    # R language server for VS Code
    "languageserver",
    # Tidyverse essentials
    "tidyverse", "dplyr", "ggplot2", "readr", "tibble",
    # Statistics packages used in assignments
    "Hmisc", "pastecs", "psych", "e1071", "caret",
    # Data manipulation
    "fastDummies", "reshape2"
)

# Additional packages (can be installed in background if needed)
additional_packages <- c(
    # Machine learning
    "MASS", "class", "randomForest", "nnet",
    # Visualization
    "corrplot", "ggcorrplot", "GGally", "gridExtra", "ggdendro", "ggrepel",
    # Clustering and dimensionality reduction
    "factoextra", "FactoMineR", "cluster", "pls",
    # ANOVA/MANOVA
    "car", "effectsize", "rstatix", "multcomp", "ggpubr",
    # Factor analysis
    "GPArotation", "nFactors", "lavaan",
    # Other
    "DBI", "RPostgreSQL", "dbplyr", "broom", "scales"
)

# Install function with progress
install_pkg <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        tryCatch({
            install.packages(pkg, lib = user_lib, quiet = TRUE, Ncpus = 2)
            if (requireNamespace(pkg, quietly = TRUE)) {
                return(TRUE)
            }
        }, error = function(e) NULL)
        return(FALSE)
    }
    return(TRUE)
}

# Install core packages first
cat("Installing core packages...\n")
for (pkg in core_packages) {
    result <- install_pkg(pkg)
    status <- if(result) "✓" else "✗"
    cat(sprintf("  %s %s\n", status, pkg))
}

# Install additional packages
cat("Installing additional packages...\n")
for (pkg in additional_packages) {
    result <- install_pkg(pkg)
    status <- if(result) "✓" else "✗"
    cat(sprintf("  %s %s\n", status, pkg))
}

# Install mlba from GitHub (required for assignments)
cat("\n📦 Installing mlba package from GitHub...\n")
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", lib = user_lib, quiet = TRUE)
}
tryCatch({
    devtools::install_github("gedeck/mlba/mlba", lib = user_lib, quiet = TRUE, upgrade = "never")
    if (requireNamespace("mlba", quietly = TRUE)) {
        cat("✅ mlba package installed from GitHub\n")
    } else {
        cat("⚠️ mlba package installation needs verification\n")
    }
}, error = function(e) {
    cat("⚠️ mlba installation warning:", conditionMessage(e), "\n")
    cat("   Students can install manually: devtools::install_github('gedeck/mlba/mlba')\n")
})

# Install DiscriMiner from GitHub
cat("📦 Installing DiscriMiner from GitHub...\n")
tryCatch({
    devtools::install_github("gastonstat/DiscriMiner", lib = user_lib, quiet = TRUE, upgrade = "never")
    cat("✅ DiscriMiner installed\n")
}, error = function(e) {
    cat("⚠️ DiscriMiner installation skipped\n")
})

# Register R kernel with Jupyter
cat("\n🔧 Registering R kernel with Jupyter...\n")
if (requireNamespace("IRkernel", quietly = TRUE)) {
    IRkernel::installspec(user = TRUE)
    cat("✅ R kernel registered\n")
} else {
    cat("⚠️ IRkernel not available\n")
}

# Summary
installed <- installed.packages(lib.loc = user_lib)[,1]
cat(sprintf("\n📊 Summary: %d packages in user library\n", length(installed)))
RSCRIPT

echo "✅ R packages setup complete"

# ============================================
# FINISH
# ============================================
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "════════════════════════════════════════════"
echo "✅ Setup complete in ${MINUTES}m ${SECONDS}s"
echo "════════════════════════════════════════════"
echo ""
echo "🎓 Environment ready:"
echo "   • R $(R --version 2>&1 | head -1 | cut -d' ' -f3) with Jupyter kernel"
echo "   • PostgreSQL $(postgres --version 2>/dev/null | cut -d' ' -f3 || echo 'installed')"
echo "   • Python $(python --version 2>&1 | cut -d' ' -f2)"
echo ""
echo "💡 Quick commands:"
echo "   check_status  - Check environment status"
echo "   pg_start      - Start PostgreSQL"
echo "   psql          - Connect to database"
