#!/usr/bin/env bash
set -e

# --- Sécurité : forcer bash ---
if [ -z "$BASH_VERSION" ]; then
  echo "Please run this script with bash"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RESOURCES=(
    "login:Login Azure"
    "tp1-app-service:TP1 - App Service (Plan + Web App)"
    "tp2-sql:TP2 - SQL Server + Database"
)

echo "=== Teardown Azure Resources ==="
echo ""

# --- Menu ---
for i in "${!RESOURCES[@]}"; do
    IFS=':' read -r folder label <<< "${RESOURCES[$i]}"
    echo "  $i) $label"
done
echo "  ${#RESOURCES[@]}) ALL"

echo ""
read -p "Choose [0-${#RESOURCES[@]}]: " choice

# --- Login Azure ---
ensure_login() {
    if ! az account show &>/dev/null; then
        echo ""
        echo "[INFO] You are not logged in to Azure."
        az login --scope https://management.azure.com/.default
    else
        echo ""
        echo "[OK] Already logged in to Azure."
    fi
}

# --- Exécution ---
run_script() {
    local folder="$1"

    if [ "$folder" = "login" ]; then
        ensure_login
        return
    fi

    echo ""
    echo ">>> Running $folder/teardown.sh ..."
    bash "$SCRIPT_DIR/$folder/teardown.sh"
    echo ">>> $folder done."
}

# --- ALL ---
if [ "$choice" = "${#RESOURCES[@]}" ]; then
    echo ""
    echo "This will tear down ALL resources:"
    for entry in "${RESOURCES[@]}"; do
        IFS=':' read -r folder label <<< "$entry"
        echo "  - $label"
    done

    echo ""
    read -p "Are you sure? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi

    export SKIP_CONFIRM=1

    for entry in "${RESOURCES[@]}"; do
        IFS=':' read -r folder label <<< "$entry"
        run_script "$folder"
    done

    echo ""
    echo "=== All resources torn down ==="

# --- Choix individuel ---
elif [ "$choice" -ge 0 ] 2>/dev/null && [ "$choice" -lt "${#RESOURCES[@]}" ]; then
    IFS=':' read -r folder label <<< "${RESOURCES[$choice]}"
    run_script "$folder"

else
    echo "Invalid choice."
    exit 1
fi