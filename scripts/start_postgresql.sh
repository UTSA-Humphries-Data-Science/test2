#!/bin/bash
# Quick PostgreSQL starter script for apt-installed PostgreSQL
# Run this if PostgreSQL is not running

echo "🔄 Starting PostgreSQL..."

# Set environment variables - student user (no password)
export PGUSER=student
export PGDATABASE=postgres
export PGHOST=localhost
export PGPORT=5432

# Check if PostgreSQL is already running
if sudo -n service postgresql status >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
elif psql -U student -h localhost -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
else
    echo "🚀 Starting PostgreSQL service..."
    sudo service postgresql start
    sleep 2
    echo "✅ PostgreSQL started"
fi

# Test connection as student user
echo "🔍 Testing student user connection..."
if psql -U student -h localhost -c "SELECT current_user, current_database();" 2>/dev/null; then
    echo "✅ Student user connection working (no password)"
else
    echo "⚠️ Student user connection failed"
    echo "   Try: sudo -u postgres psql -c \"CREATE USER student WITH SUPERUSER CREATEDB;\""
fi
