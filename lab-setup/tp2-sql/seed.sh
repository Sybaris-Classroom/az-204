#!/usr/bin/env bash
set -euo pipefail
echo "[INFO] Running SEED script"

# =============================================================================
# Connect to Azure SQL Database and execute AzureQuizLab.sql via sqlcmd
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../variables.sh"

SQL_FILE="$SCRIPT_DIR/../../TP2/AzureQuizLab.sql"
SQL_HOST="${SQL_SERVER_NAME}.database.windows.net"

echo "=== Azure SQL Seed ==="
echo "Server:    $SQL_HOST"
echo "Database:  $SQL_DATABASE_NAME"
echo "SQL Admin: $SQL_ADMIN_USER"
echo "SQL File:  $SQL_FILE"
echo "======================"
echo ""

if [ ! -f "$SQL_FILE" ]; then
    echo "[ERROR] SQL file not found: $SQL_FILE"
    exit 1
fi

# Resolve sqlcmd: prefer native, fall back to Windows binary in WSL
if command -v sqlcmd &>/dev/null; then
    SQLCMD_CMD="sqlcmd"
elif command -v sqlcmd.exe &>/dev/null; then
    SQLCMD_CMD="sqlcmd.exe"
else
    echo "[ERROR] sqlcmd not found in PATH."
    exit 1
fi

echo "[..] Executing $SQL_FILE ..."
# sqlcmd.exe (Windows binary) needs a Windows-style path when running in WSL
if [[ "$SQLCMD_CMD" == *.exe ]] && command -v wslpath &>/dev/null; then
    SQL_FILE_ARG="$(wslpath -w "$SQL_FILE")"
else
    SQL_FILE_ARG="$SQL_FILE"
fi

"$SQLCMD_CMD" \
    -S "$SQL_HOST" \
    -d "$SQL_DATABASE_NAME" \
    -U "$SQL_ADMIN_USER" \
    -P "$SQL_ADMIN_PASSWORD" \
    -i "$SQL_FILE_ARG"

echo "[OK] SQL script executed successfully."
