#!/bin/bash
set -e

# =============================================================================
# Create Azure SQL Server + SQL Database (idempotent)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../variables.sh"

if [ -z "$SQL_ADMIN_PASSWORD" ]; then
    read -sp "Enter SQL admin password: " SQL_ADMIN_PASSWORD
    echo ""
fi

if [ -z "$SQL_ENTRA_ADMIN_EMAIL" ]; then
    read -p "Enter Entra admin email: " SQL_ENTRA_ADMIN_EMAIL
fi

echo "=== Azure SQL Setup ==="
echo "Resource Group:  $RESOURCE_GROUP"
echo "Location:        $SQL_LOCATION"
echo "SQL Server:      $SQL_SERVER_NAME"
echo "SQL Database:    $SQL_DATABASE_NAME (SKU: $SQL_SKU)"
echo "Elastic Pool:    $SQL_USE_ELASTIC_POOL ($SQL_ELASTIC_POOL_NAME)"
echo "Workload Env:    $SQL_WORKLOAD_ENV"
echo "Backup Red.:     $SQL_BACKUP_REDUNDANCY"
echo "SQL Admin:       $SQL_ADMIN_USER"
echo "Entra Admin:     $SQL_ENTRA_ADMIN_EMAIL"
echo "========================"
echo ""

# --- SQL Server (SQL auth + Entra admin) ---
if "$AZ_CMD" sql server show --name "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[OK] SQL Server '$SQL_SERVER_NAME' already exists. Skipping."
else
    echo "[..] Looking up Entra user '$SQL_ENTRA_ADMIN_EMAIL'..."
    ENTRA_ADMIN_SID=$("$AZ_CMD" ad user list \
        --filter "mail eq '$SQL_ENTRA_ADMIN_EMAIL' or userPrincipalName eq '$SQL_ENTRA_ADMIN_EMAIL'" \
        --query "[0].id" -o tsv)
    if [ -z "$ENTRA_ADMIN_SID" ]; then
        echo "[ERROR] Could not find Entra user '$SQL_ENTRA_ADMIN_EMAIL'."
        exit 1
    fi
    echo "[OK] Found Entra user (id: $ENTRA_ADMIN_SID)"

    echo "[..] Creating SQL Server '$SQL_SERVER_NAME'..."
    if "$AZ_CMD" sql server create \
        --name "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$SQL_LOCATION" \
        --admin-user "$SQL_ADMIN_USER" \
        --admin-password "$SQL_ADMIN_PASSWORD" \
        --external-admin-principal-type User \
        --external-admin-name "$SQL_ENTRA_ADMIN_EMAIL" \
        --external-admin-sid "$ENTRA_ADMIN_SID" \
        --debug 2>"$SCRIPT_DIR/create-server.log"; then
        echo "[OK] SQL Server created (SQL + Entra auth)."
    else
        echo "[ERROR] SQL Server creation failed. See logs: $SCRIPT_DIR/create-server.log"
        tail -20 "$SCRIPT_DIR/create-server.log"
        exit 1
    fi
fi

echo ""

# --- Allow Azure services to access the SQL Server ---
echo "[..] Allowing Azure services to access SQL Server..."
"$AZ_CMD" sql server firewall-rule create \
    --server "$SQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --name "AllowAzureServices" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 &>/dev/null
echo "[OK] Firewall rule set."

# --- IP whitelist (remote access) ---
if [ ${#SQL_FIREWALL_RULES[@]} -gt 0 ]; then
    echo ""
    echo "[..] Applying IP whitelist firewall rules..."
    for rule in "${SQL_FIREWALL_RULES[@]}"; do
        IFS=':' read -r name start_ip end_ip <<< "$rule"
        echo "     $name ($start_ip - $end_ip)"
        "$AZ_CMD" sql server firewall-rule create \
            --server "$SQL_SERVER_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --name "$name" \
            --start-ip-address "$start_ip" \
            --end-ip-address "$end_ip" &>/dev/null
    done
    echo "[OK] IP whitelist applied."
else
    echo "[--] No IP whitelist rules configured. Skipping."
fi

echo ""

# --- SQL Database ---
if "$AZ_CMD" sql db show --name "$SQL_DATABASE_NAME" --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[OK] SQL Database '$SQL_DATABASE_NAME' already exists. Skipping."
else
    echo "[..] Creating SQL Database '$SQL_DATABASE_NAME'..."
    DB_CREATE_CMD=("$AZ_CMD" sql db create \
        --name "$SQL_DATABASE_NAME" \
        --server "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --backup-storage-redundancy "$SQL_BACKUP_REDUNDANCY")

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
