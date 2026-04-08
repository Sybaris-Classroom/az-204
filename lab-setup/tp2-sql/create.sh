#!/usr/bin/env bash
set -euo pipefail
echo "[INFO] Running CREATE script"

# =============================================================================
# Create Azure SQL Server + SQL Database (idempotent)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../variables.local.sh"
TEMPLATE_FILE="$SCRIPT_DIR/../variables.template.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Missing config file: $CONFIG_FILE"
    echo "[HINT] Create it from template: cp \"$TEMPLATE_FILE\" \"$CONFIG_FILE\""
    exit 1
fi

source "$CONFIG_FILE"

require_var() {
    local var_name="$1"
    if [ -z "${!var_name:-}" ]; then
        echo "[ERROR] Missing required variable '$var_name' in variables.local.sh"
        exit 1
    fi
}

# --- Required variables ---
require_var AZ_CMD
require_var RESOURCE_GROUP
require_var SQL_LOCATION
require_var SQL_SERVER_NAME
require_var SQL_DATABASE_NAME
require_var SQL_ADMIN_USER
require_var SQL_ADMIN_PASSWORD
require_var SQL_ENTRA_ADMIN_EMAIL
require_var SQL_BACKUP_REDUNDANCY

# Optional defaults
SQL_SKU="${SQL_SKU:-Basic}"
SQL_USE_ELASTIC_POOL="${SQL_USE_ELASTIC_POOL:-false}"
SQL_ELASTIC_POOL_NAME="${SQL_ELASTIC_POOL_NAME:-}"
SQL_WORKLOAD_ENV="${SQL_WORKLOAD_ENV:-}"
SQL_FIREWALL_RULES=("${SQL_FIREWALL_RULES[@]:-}")
SQL_REUSE_EXISTING_RESOURCES="${SQL_REUSE_EXISTING_RESOURCES:-false}"
SQL_SEED_ON_EXISTING_DATABASE="${SQL_SEED_ON_EXISTING_DATABASE:-false}"
SQL_RESOURCE_GROUP="${SQL_RESOURCE_GROUP:-$RESOURCE_GROUP}"

echo "=== Azure SQL Setup ==="
echo "User RG:         $RESOURCE_GROUP"
echo "SQL RG:          $SQL_RESOURCE_GROUP"
echo "Location:        $SQL_LOCATION"
echo "SQL Server:      $SQL_SERVER_NAME"
echo "SQL Database:    $SQL_DATABASE_NAME"
if [ "$SQL_USE_ELASTIC_POOL" = "true" ]; then
    echo "Elastic Pool:    true ($SQL_ELASTIC_POOL_NAME)"
else
    echo "SKU:             $SQL_SKU"
fi
echo "Workload Env:    ${SQL_WORKLOAD_ENV:-<none>}"
echo "Backup Red.:     $SQL_BACKUP_REDUNDANCY"
echo "SQL Admin:       $SQL_ADMIN_USER"
echo "Entra Admin:     $SQL_ENTRA_ADMIN_EMAIL"
echo "Reuse SQL:       $SQL_REUSE_EXISTING_RESOURCES"
echo "========================"
echo ""

if [ "$SQL_USE_ELASTIC_POOL" = "true" ] && [ -z "$SQL_ELASTIC_POOL_NAME" ]; then
    echo "[ERROR] SQL_USE_ELASTIC_POOL=true but SQL_ELASTIC_POOL_NAME is empty."
    exit 1
fi

# --- Check Azure login early ---
if ! "$AZ_CMD" account show &>/dev/null; then
    echo "[ERROR] Azure CLI is not logged in. Run: az login"
    exit 1
fi

# --- SQL Server (SQL auth + Entra admin) ---
if "$AZ_CMD" sql server show \
    --name "$SQL_SERVER_NAME" \
    --resource-group "$SQL_RESOURCE_GROUP" &>/dev/null; then
    echo "[OK] SQL Server '$SQL_SERVER_NAME' already exists."
elif [ "$SQL_REUSE_EXISTING_RESOURCES" = "true" ]; then
    echo "[ERROR] SQL_REUSE_EXISTING_RESOURCES=true but server '$SQL_SERVER_NAME' was not found in resource group '$SQL_RESOURCE_GROUP'."
    exit 1
else
    echo "[..] Looking up Entra user '$SQL_ENTRA_ADMIN_EMAIL'..."
    ENTRA_ADMIN_SID=$("$AZ_CMD" ad user list \
        --filter "mail eq '$SQL_ENTRA_ADMIN_EMAIL' or userPrincipalName eq '$SQL_ENTRA_ADMIN_EMAIL'" \
        --query "[0].id" \
        -o tsv)

    if [ -z "$ENTRA_ADMIN_SID" ]; then
        echo "[ERROR] Could not find Entra user '$SQL_ENTRA_ADMIN_EMAIL'."
        exit 1
    fi

    echo "[OK] Found Entra user (id: $ENTRA_ADMIN_SID)"
    echo "[..] Creating SQL Server '$SQL_SERVER_NAME'..."

    if "$AZ_CMD" sql server create \
        --name "$SQL_SERVER_NAME" \
        --resource-group "$SQL_RESOURCE_GROUP" \
        --location "$SQL_LOCATION" \
        --admin-user "$SQL_ADMIN_USER" \
        --admin-password "$SQL_ADMIN_PASSWORD" \
        --external-admin-principal-type User \
        --external-admin-name "$SQL_ENTRA_ADMIN_EMAIL" \
        --external-admin-sid "$ENTRA_ADMIN_SID" \
        --only-show-errors \
        2>"$SCRIPT_DIR/create-server.log"; then
        echo "[OK] SQL Server created (SQL + Entra auth)."
    else
        echo "[ERROR] SQL Server creation failed. See logs: $SCRIPT_DIR/create-server.log"
        tail -20 "$SCRIPT_DIR/create-server.log" || true
        exit 1
    fi
fi

echo ""

# --- Allow Azure services to access the SQL Server ---
echo "[..] Ensuring firewall rule 'AllowAzureServices'..."
"$AZ_CMD" sql server firewall-rule create \
    --server "$SQL_SERVER_NAME" \
    --resource-group "$SQL_RESOURCE_GROUP" \
    --name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --only-show-errors \
    &>/dev/null
echo "[OK] Firewall rule set."

# --- IP whitelist (remote access) ---
if [ ${#SQL_FIREWALL_RULES[@]} -gt 0 ]; then
    echo ""
    echo "[..] Applying IP whitelist firewall rules..."
    for rule in "${SQL_FIREWALL_RULES[@]}"; do
        IFS=':' read -r name start_ip end_ip <<< "$rule"

        if [ -z "$name" ] || [ -z "$start_ip" ] || [ -z "$end_ip" ]; then
            echo "[ERROR] Invalid firewall rule format: '$rule'"
            echo "        Expected: Name:StartIP:EndIP"
            exit 1
        fi

        echo "     $name ($start_ip - $end_ip)"
        "$AZ_CMD" sql server firewall-rule create \
            --server "$SQL_SERVER_NAME" \
            --resource-group "$SQL_RESOURCE_GROUP" \
            --name "$name" \
            --start-ip-address "$start_ip" \
            --end-ip-address "$end_ip" \
            --only-show-errors \
            &>/dev/null
    done
    echo "[OK] IP whitelist applied."
else
    echo "[--] No IP whitelist rules configured. Skipping."
fi

echo ""

# --- SQL Database ---
DATABASE_ALREADY_EXISTS="false"
if "$AZ_CMD" sql db show \
    --name "$SQL_DATABASE_NAME" \
    --server "$SQL_SERVER_NAME" \
    --resource-group "$SQL_RESOURCE_GROUP" &>/dev/null; then
    DATABASE_ALREADY_EXISTS="true"
    echo "[OK] SQL Database '$SQL_DATABASE_NAME' already exists."
elif [ "$SQL_REUSE_EXISTING_RESOURCES" = "true" ]; then
    echo "[ERROR] SQL_REUSE_EXISTING_RESOURCES=true but database '$SQL_DATABASE_NAME' was not found in resource group '$SQL_RESOURCE_GROUP'."
    exit 1
else
    echo "[..] Creating SQL Database '$SQL_DATABASE_NAME'..."

    DB_CREATE_CMD=(
        "$AZ_CMD" sql db create
        --name "$SQL_DATABASE_NAME"
        --server "$SQL_SERVER_NAME"
        --resource-group "$SQL_RESOURCE_GROUP"
        --backup-storage-redundancy "$SQL_BACKUP_REDUNDANCY"
        --only-show-errors
    )

    if [ "$SQL_USE_ELASTIC_POOL" = "true" ]; then
        DB_CREATE_CMD+=(--elastic-pool "$SQL_ELASTIC_POOL_NAME")
    else
        DB_CREATE_CMD+=(--service-objective "$SQL_SKU")
    fi

    if [ -n "$SQL_WORKLOAD_ENV" ]; then
        DB_CREATE_CMD+=(--preferred-enclave-type VBS)
    fi

    "${DB_CREATE_CMD[@]}"
    echo "[OK] SQL Database created."
fi

echo ""
echo "=== Done ==="

# --- Execute seed script ---
if [ "$DATABASE_ALREADY_EXISTS" = "true" ] && [ "$SQL_SEED_ON_EXISTING_DATABASE" != "true" ]; then
    echo ""
    echo "[--] Database already existed. Skipping seed (SQL_SEED_ON_EXISTING_DATABASE=false)."
else
    echo ""
    echo "[..] Executing seed script to populate database..."
    bash "$SCRIPT_DIR/seed.sh"
    echo "[OK] Database seeded successfully."
fi