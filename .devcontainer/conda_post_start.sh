#!/bin/bash
# Optimized post-start script - runs every time the codespace starts/resumes
# Uses apt-installed PostgreSQL with student user (no password)
# NOTE: This script runs after postCreateCommand has set up passwordless sudo

echo "🔄 Post-start: Verifying environment..."

# Source environment
source ~/.bashrc 2>/dev/null || true
cd /workspaces/test2 2>/dev/null || true

# Set PostgreSQL environment - student user (no password)
export PGUSER=student
export PGDATABASE=postgres
export PGHOST=localhost
export PGPORT=5432

# ============================================
# Check 1: Start PostgreSQL service if not running
# ============================================
# Try with sudo (should be passwordless after postCreateCommand)
if sudo -n service postgresql status >/dev/null 2>&1; then
    echo "✅ PostgreSQL running"
elif sudo -n true 2>/dev/null; then
    echo "🚀 Starting PostgreSQL service..."
    sudo service postgresql start
    sleep 2
    echo "✅ PostgreSQL started"
else
    # No sudo available, try psql directly to see if it works
    if psql -U student -h localhost -c "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ PostgreSQL running (connected as student)"
    else
        echo "⚠️ PostgreSQL status unknown - may need manual start"
    fi
fi

# ============================================
# Check 2: Ensure student user exists (if we have sudo)
# ============================================
if sudo -n true 2>/dev/null; then
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='student'" 2>/dev/null | grep -q 1; then
        echo "👤 Creating student user..."
        sudo -u postgres psql -c "CREATE USER student WITH SUPERUSER CREATEDB;" 2>/dev/null
    fi
fi
echo "✅ Student user configured"

# ============================================
# Check 3: Configure student user for database
# ============================================
if [ -f "/workspaces/test2/scripts/setup_student_primary.sh" ]; then
    bash /workspaces/test2/scripts/setup_student_primary.sh 2>/dev/null
fi

# Load sample databases if script exists
if [ -f "/workspaces/test2/scripts/load_all_sample_databases.sh" ]; then
    bash /workspaces/test2/scripts/load_all_sample_databases.sh 2>/dev/null
fi

# ============================================
# Check 4: Verify R kernel
# ============================================
if ! jupyter kernelspec list 2>/dev/null | grep -q "ir"; then
    echo "⚠️ R kernel missing, registering..."
    R --quiet --no-save -e "IRkernel::installspec(user = TRUE)" 2>/dev/null
fi
echo "✅ R kernel available"

# ============================================
# Check 5: Verify mlba package
# ============================================
R --quiet --no-save << 'EOF' 2>/dev/null
if (!requireNamespace("mlba", quietly = TRUE)) {
    cat("⚠️ mlba package missing, installing from GitHub...\n")
    if (requireNamespace("devtools", quietly = TRUE)) {
        tryCatch({
            devtools::install_github("gedeck/mlba/mlba", quiet = TRUE, upgrade = "never")
            cat("✅ mlba package installed\n")
        }, error = function(e) {
            cat("⚠️ mlba installation failed - students should run:\n")
            cat("   devtools::install_github('gedeck/mlba/mlba')\n")
        })
    }
} else {
    cat("✅ mlba package available\n")
}
EOF

# ============================================
# Ensure Git is configured for commits
# ============================================
git config --global commit.gpgsign false 2>/dev/null || true
git config --global tag.gpgsign false 2>/dev/null || true
git config --local commit.gpgsign false 2>/dev/null || true

# ============================================
# Final status
# ============================================
echo ""
echo "════════════════════════════════════════════"
echo "✅ Environment ready for data science work!"
echo "════════════════════════════════════════════"
echo ""
echo "💡 Quick commands:"
echo "   📊 Open notebooks in the Lecture/ folder"
echo "   🗄️ psql - Connect to database as student (no password)"
echo "   📈 sudo service postgresql status - Check PostgreSQL"
echo "   🔍 check_status - Full environment check"
echo ""
