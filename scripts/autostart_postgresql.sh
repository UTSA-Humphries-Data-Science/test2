#!/bin/bash
# Auto-start PostgreSQL script (apt-installed)
# This should be run every time the container starts

echo "🔄 Checking PostgreSQL status..."

# Set environment variables - student user (no password)
export PGUSER=student
export PGDATABASE=postgres
export PGHOST=localhost
export PGPORT=5432

# Check if PostgreSQL is running
if sudo -n service postgresql status >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
elif psql -U student -h localhost -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
else
    echo "🚀 Starting PostgreSQL..."
    sudo service postgresql start
    echo "✅ PostgreSQL started"
fi

# Verify connection as student
if psql -U student -h localhost -c "SELECT current_user, current_database();" >/dev/null 2>&1; then
    echo "✅ Database connection verified (student user)"
else
    echo "⚠️ Database connection as student failed"
fi
