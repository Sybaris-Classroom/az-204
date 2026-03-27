#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/variables.sh"

RESOURCES=(
    "sql:SQL Server + Database"
    "app-service:App Service (Plan + Web App)"
)

echo "=== Create Azure Resources ==="
echo ""
echo "  0) ALL"
for i in "${!RESOURCES[@]}"; do
    IFS=':' read -r folder label <<< "${RESOURCES[$i]}"
    echo "  $((i + 1))) $label"
done
echo ""
read -p "Choose [0-${#RESOURCES[@]}]: " choice

run_script() {
    local folder="$1"
    echo ""
    echo ">>> Running $folder/create.sh ..."
    sh "$SCRIPT_DIR/$folder/create.sh"
    echo ">>> $folder done."
}

CREATED_SQL=false
CREATED_APP=false
CREATED_ALL=false

# Prompt for SQL password upfront if empty (needed for connection string)
if [ -z "$SQL_ADMIN_PASSWORD" ]; then
    read -sp "Enter SQL admin password: " SQL_ADMIN_PASSWORD
    echo ""
    export SQL_ADMIN_PASSWORD
fi

CONNECTION_STRING="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Initial Catalog=${SQL_DATABASE_NAME};Persist Security Info=False;User ID=${SQL_ADMIN_USER};Password=${SQL_ADMIN_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

if [ "$choice" = "0" ]; then
    for entry in "${RESOURCES[@]}"; do
        IFS=':' read -r folder label <<< "$entry"
        run_script "$folder"
    done
    CREATED_SQL=true
    CREATED_APP=true
    CREATED_ALL=true

    # --- Auto-set DefaultConnection on App Service ---
    echo ""
    echo "[..] Setting DefaultConnection on App Service '$APP_SERVICE_NAME'..."
    "$AZ_CMD" webapp config connection-string set \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --connection-string-type SQLAzure \
        --settings DefaultConnection="$CONNECTION_STRING" &>/dev/null
    echo "[OK] DefaultConnection set."

    echo ""
    echo "=== All resources created ==="
elif [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "${#RESOURCES[@]}" ]; then
    IFS=':' read -r folder label <<< "${RESOURCES[$((choice - 1))]}"
    run_script "$folder"
    [ "$folder" = "sql" ] && CREATED_SQL=true
    [ "$folder" = "app-service" ] && CREATED_APP=true
else
    echo "Invalid choice."
    exit 1
fi

echo ""
echo "========================================"
echo "  POST-SETUP SUMMARY"
echo "========================================"

# --- Connection string ---
if [ "$CREATED_SQL" = "true" ]; then
    echo ""
    echo "-- ADO.NET Connection String --"
    echo ""
    echo "$CONNECTION_STRING"
fi

# --- TODO list ---
echo ""
echo "-- TODO --"
echo ""

if [ "$CREATED_ALL" = "true" ]; then
    echo "[x] DefaultConnection — automatically added to App Service"
else
    if [ "$CREATED_SQL" = "true" ]; then
        echo "[ ] DefaultConnection — add it manually to your App Service:"
        echo "    az webapp config connection-string set \\"
        echo "      --name <APP_SERVICE_NAME> --resource-group <RESOURCE_GROUP> \\"
        echo "      --connection-string-type SQLAzure \\"
        echo "      --settings DefaultConnection=\"<connection-string>\""
    fi
    if [ "$CREATED_APP" = "true" ]; then
        echo "[ ] DefaultConnection — create SQL resources first, then set the connection string"
    fi
fi

if [ "$CREATED_SQL" = "true" ]; then
    if [ ${#SQL_FIREWALL_RULES[@]} -gt 0 ]; then
        echo "[x] SQL Firewall — IP whitelist rules applied"
    else
        echo "[ ] SQL Firewall — no IP whitelist configured"
        echo "    Add your IP to SQL_FIREWALL_RULES in variables.sh"
        echo "    or via Azure Portal > SQL Server > Networking"
    fi
fi

if [ "$CREATED_APP" = "true" ]; then
    if [ "$APP_LOG_ENABLED" = "true" ]; then
        echo "[x] Application logging — enabled (filesystem, $APP_LOG_LEVEL)"
    else
        echo "[ ] Application logging — disabled"
        echo "    Set APP_LOG_ENABLED=true in variables.sh to enable"
    fi
fi

if [ "$CREATED_APP" = "true" ]; then
    echo "[ ] GitHub Actions — add publish profile as AZURE_WEBAPP_PUBLISH_PROFILE secret"
    echo ""
    echo "-- Publish Profile --"
    echo ""
    PUBLISH_PROFILE=$("$AZ_CMD" webapp deployment list-publishing-profiles \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --xml 2>/dev/null) || true
    if [ -n "$PUBLISH_PROFILE" ]; then
        echo "$PUBLISH_PROFILE"
    else
        echo "[WARN] Could not retrieve publish profile."
    fi
fi

echo ""
echo "========================================"
