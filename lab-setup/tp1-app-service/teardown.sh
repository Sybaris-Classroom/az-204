#!/bin/bash
set -e
echo "[INFO] Running TEARDOWN script"

# =============================================================================
# Teardown Azure App Service Plan + App Service
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../variables.sh"

echo "=== Azure App Service Teardown ==="
echo "This will delete the following resources:"
echo "  - App Service:      $APP_SERVICE_NAME"
echo "  - App Service Plan: $APP_SERVICE_PLAN"
echo "  - Resource Group:   $RESOURCE_GROUP (NOT deleted — shared)"
echo "==================================="
echo ""

if [ "$SKIP_CONFIRM" != "1" ]; then
    read -p "Are you sure? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""

# --- App Service ---
if "$AZ_CMD" webapp show --name "$APP_SERVICE_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[..] Deleting App Service '$APP_SERVICE_NAME'..."
    "$AZ_CMD" webapp delete \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP"
    echo "[OK] App Service deleted."
else
    echo "[--] App Service '$APP_SERVICE_NAME' not found. Skipping."
fi

echo ""

# --- App Service Plan ---
if "$AZ_CMD" appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[..] Deleting App Service Plan '$APP_SERVICE_PLAN'..."
    "$AZ_CMD" appservice plan delete \
        --name "$APP_SERVICE_PLAN" \
        --resource-group "$RESOURCE_GROUP" \
        --yes
    echo "[OK] App Service Plan deleted."
else
    echo "[--] App Service Plan '$APP_SERVICE_PLAN' not found. Skipping."
fi

echo ""
echo "=== Teardown complete ==="
