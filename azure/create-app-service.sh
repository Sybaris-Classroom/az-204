#!/bin/bash
set -e

# =============================================================================
# Create Azure App Service Plan + App Service (idempotent)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/variables.sh"

echo "=== Azure App Service Setup ==="
echo "Resource Group:    $RESOURCE_GROUP"
echo "Location:          $LOCATION"
echo "App Service Plan:  $APP_SERVICE_PLAN (SKU: $SKU)"
echo "App Service:       $APP_SERVICE_NAME"
echo "Runtime:           $RUNTIME"
echo "==============================="
echo ""

# --- App Service Plan ---
if "$AZ_CMD" appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[OK] App Service Plan '$APP_SERVICE_PLAN' already exists. Skipping."
else
    echo "[..] Creating App Service Plan '$APP_SERVICE_PLAN'..."
    "$AZ_CMD" appservice plan create \
        --name "$APP_SERVICE_PLAN" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku "$SKU" \
        --is-linux
    echo "[OK] App Service Plan created."
fi

echo ""

# --- App Service ---
if "$AZ_CMD" webapp show --name "$APP_SERVICE_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "[OK] App Service '$APP_SERVICE_NAME' already exists. Skipping."
else
    echo "[..] Creating App Service '$APP_SERVICE_NAME'..."
    "$AZ_CMD" webapp create \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN" \
        --runtime "$RUNTIME"
    echo "[OK] App Service created."
fi

# --- Run from package mode ---
# Sets WEBSITE_RUN_FROM_PACKAGE=1 so Azure runs the app directly from the deployed zip.
# Without this, after a zip deploy on Linux, the app keeps serving the old code
# until a manual stop/start. This setting makes Azure pick up the new package
# automatically on each deployment, removing the need for a restart.
echo "[..] Enabling run-from-package mode..."
"$AZ_CMD" webapp config appsettings set \
    --name "$APP_SERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings WEBSITE_RUN_FROM_PACKAGE=1 &>/dev/null
echo "[OK] Run-from-package mode enabled."

echo ""

# --- Enable basic auth (required for publish profile download) ---
echo "[..] Enabling basic authentication for publish profile..."
"$AZ_CMD" resource update \
    --resource-group "$RESOURCE_GROUP" \
    --name scm \
    --namespace Microsoft.Web \
    --resource-type basicPublishingCredentialsPolicies \
    --parent "sites/$APP_SERVICE_NAME" \
    --set properties.allow=true &>/dev/null
"$AZ_CMD" resource update \
    --resource-group "$RESOURCE_GROUP" \
    --name ftp \
    --namespace Microsoft.Web \
    --resource-type basicPublishingCredentialsPolicies \
    --parent "sites/$APP_SERVICE_NAME" \
    --set properties.allow=true &>/dev/null
echo "[OK] Basic authentication enabled."

echo ""
echo "=== Done ==="
