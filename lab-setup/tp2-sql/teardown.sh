#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Running TEARDOWN script"

# =============================================================================
# Delete Azure SQL Server + SQL Database (idempotent)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../variables.sh"

require_var() {
    local var_name="$1"
    if [ -z "${!var_name:-}" ]; then
        echo "[ERROR] Missing required variable '$var_name' in variables.sh"
        exit 1
    fi
}

# --- Required variables ---
require_var AZ_CMD
require_var RESOURCE_GROUP
require_var SQL_SERVER_NAME
require_var SQL_DATABASE_NAME

echo "=== Azure SQL Teardown ==="
echo "Resource Group:  $RESOURCE_GROUP"
echo "SQL Server:      $SQL_SERVER_NAME"
echo "SQL Database:    $SQL_DATABASE_NAME"
echo "========================"
echo ""

# --- Check Azure login ---
if ! "$AZ_CMD" account show &>/dev/null; then
    echo "[ERROR] Azure CLI is not logged in. Run: az login"
    exit 1
fi

# --- Confirmation (optionnelle) ---
if [ "${SKIP_CONFIRM:-0}" != "1" ]; then
    echo "This will delete the SQL database and server."
    read -p "Are you sure? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# --- Delete SQL Database ---
if "$AZ_CMD" sql db show \
    --name "$SQL_DATABASE_NAME" \
    --server "$SQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" &>/dev/null; then

    echo "[..] Deleting SQL Database '$SQL_DATABASE_NAME'..."
    "$AZ_CMD" sql db delete \
        --name "$SQL_DATABASE_NAME" \
        --server "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --yes \
        --only-show-errors

    echo "[OK] SQL Database deleted."
else
    echo "[--] SQL Database '$SQL_DATABASE_NAME' not found. Skipping."
fi

echo ""

# --- Delete SQL Server ---
if "$AZ_CMD" sql server show \
    --name "$SQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" &>/dev/null; then

    echo "[..] Deleting SQL Server '$SQL_SERVER_NAME'..."
    "$AZ_CMD" sql server delete \
        --name "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --yes \
        --only-show-errors

    echo "[OK] SQL Server deleted."
else
    echo "[--] SQL Server '$SQL_SERVER_NAME' not found. Skipping."
fi

echo ""
echo "=== Teardown complete ==="