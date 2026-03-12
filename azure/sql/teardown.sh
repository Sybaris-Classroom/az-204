#!/bin/bash
set -e

# =============================================================================
# Teardown Azure SQL Database + SQL Server
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../variables.sh"

echo "=== Azure SQL Teardown ==="
echo "This will delete the following resources:"
echo "  - SQL Database:  $SQL_DATABASE_NAME"
echo "  - SQL Server:    $SQL_SERVER_NAME"
echo "  - Resource Group: $RESOURCE_GROUP (NOT deleted — shared)"
echo "==========================="
echo ""

if [ "$SKIP_CONFIRM" != "1" ]; then
    read -p "Are you sure? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""

# --- SQL Database ---
if "$AZ_CMD" sql db show --name "$SQL_DATABASE_NAME" --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[..] Deleting SQL Database '$SQL_DATABASE_NAME'..."
    "$AZ_CMD" sql db delete \
        --name "$SQL_DATABASE_NAME" \
        --server "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --yes
    echo "[OK] SQL Database deleted."
else
    echo "[--] SQL Database '$SQL_DATABASE_NAME' not found. Skipping."
fi

echo ""

# --- SQL Server ---
if "$AZ_CMD" sql server show --name "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[..] Deleting SQL Server '$SQL_SERVER_NAME'..."
    "$AZ_CMD" sql server delete \
        --name "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --yes
    echo "[OK] SQL Server deleted."
else
    echo "[--] SQL Server '$SQL_SERVER_NAME' not found. Skipping."
fi

echo ""
echo "=== Teardown complete ==="
