#!/bin/bash
# postStartCommand — runs every time the codespace starts/resumes.
# Only starts services; everything else is baked into the Docker image.

echo "🔄 Starting services..."
source ~/.bashrc 2>/dev/null || true

# Start PostgreSQL
if ! sudo -n service postgresql status >/dev/null 2>&1; then
    sudo service postgresql start
    sleep 2
fi
echo "✅ PostgreSQL running"

# Ensure student user exists (idempotent)
sudo -u postgres psql -c "CREATE USER student WITH SUPERUSER CREATEDB;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE postgres TO student;" 2>/dev/null || true

# Load sample databases if they exist and haven't been loaded
if [ -d "/workspaces/test2/databases" ]; then
    for sql_file in /workspaces/test2/databases/*.sql; do
        [ -f "$sql_file" ] || continue
        db_name=$(basename "$sql_file" .sql)
        psql -U student -h localhost -d postgres -f "$sql_file" 2>/dev/null || true
    done
fi

# Ensure R kernel is registered and refresh Jupyter
# Re-register kernel on every start to ensure VS Code detects it
R --quiet --no-save -e "IRkernel::installspec(user=FALSE)" 2>/dev/null || true

# Force Jupyter to recognize all kernels (helps VS Code pickup)
jupyter kernelspec list > /dev/null 2>&1

# Touch kernel files to update timestamps (helps VS Code detect changes)
touch /opt/conda/share/jupyter/kernels/ir/kernel.json 2>/dev/null || true
touch ~/.local/share/jupyter/kernels/*/kernel.json 2>/dev/null || true

# Small delay to let VS Code Jupyter extension pick up kernels
sleep 1

# Ensure Git config
git config --global commit.gpgsign false 2>/dev/null || true
git config --global tag.gpgsign false 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════"
echo "✅ Environment ready for data science work!"
echo "════════════════════════════════════════════"
