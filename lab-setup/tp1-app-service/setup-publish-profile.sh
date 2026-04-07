#!/usr/bin/env bash
set -euo pipefail
echo "[INFO] Running SETUP-PUBLISH-PROFILE script"

# =============================================================================
# Download Azure App Service Publish Profile and upload to GitHub Secret
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

echo "=== GitHub Publish Profile Setup ==="
echo "App Service:  $APP_SERVICE_NAME"
echo "Source:       $DEPLOYMENT_SOURCE"
echo "Org:          $GITHUB_ORGANIZATION"
echo "Repository:   $GITHUB_REPOSITORY"
echo "Branch:       $GITHUB_BRANCH"
echo "GitHub Repo:  $GITHUB_REPO"
echo "Secret Name:  $AZURE_WEBAPP_PUBLISH_PROFILE_SECRET"
echo "===================================="
echo ""

# --- Configure Deployment Center source (GitHub) ---
if [ "${DEPLOYMENT_SOURCE:-GitHub}" = "GitHub" ]; then

    REPO_URL="https://github.com/${GITHUB_ORGANIZATION}/${GITHUB_REPOSITORY}.git"

    "$AZ_CMD" webapp deployment source config \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --repo-url "$REPO_URL" \
        --branch "$GITHUB_BRANCH" \
        #--only-show-errors &>/dev/null

    echo "[OK] Deployment Center source configured: GitHub ($REPO_URL, branch: $GITHUB_BRANCH)."
    echo ""
fi

# --- Download and upload publish profile to GitHub ---
echo "[..] Retrieving publish profile..."
# Resolve GitHub CLI command for Linux/macOS and WSL/Windows setups.
if command -v gh &>/dev/null; then
    GH_CMD="gh"
elif command -v gh.exe &>/dev/null; then
    GH_CMD="gh.exe"
else
    GH_CMD=""
fi

if [ -n "$GH_CMD" ]; then
    PUBLISH_PROFILE=$("$AZ_CMD" webapp deployment list-publishing-profiles \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --xml 2>/dev/null) || true
    
    if [ -n "$PUBLISH_PROFILE" ]; then
        echo "[OK] Publish profile retrieved."
        echo "[..] Uploading to GitHub secret '$AZURE_WEBAPP_PUBLISH_PROFILE_SECRET'..."
        
        if GH_SECRET_OUTPUT=$(printf '%s' "$PUBLISH_PROFILE" | "$GH_CMD" secret set "$AZURE_WEBAPP_PUBLISH_PROFILE_SECRET" -R "$GITHUB_REPO" 2>&1); then
            echo "[OK] GitHub secret '$AZURE_WEBAPP_PUBLISH_PROFILE_SECRET' updated successfully."
        else
            echo "[ERROR] Failed to update GitHub secret."
            echo "[ERROR] gh output:"
            echo "$GH_SECRET_OUTPUT"
            echo ""
            echo "[..] GitHub authentication status:"
            GH_AUTH_STATUS=$("$GH_CMD" auth status 2>&1 || true)
            echo "$GH_AUTH_STATUS"
            echo ""
            echo "[HINT] Verify authentication with: $GH_CMD auth login"
            echo "[HINT] Verify repository access to: $GITHUB_REPO"
            echo "[HINT] Verify your token has permission to manage Actions secrets"
            exit 1
        fi
    else
        echo "[ERROR] Could not retrieve publish profile."
        exit 1
    fi
else
    echo "[ERROR] gh CLI not found in PATH. Install GitHub CLI to proceed."
    echo "        Visit: https://cli.github.com/"
    exit 1
fi

echo ""
echo "=== Done ==="
