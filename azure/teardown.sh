#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RESOURCES=(
    "app-service:App Service (Plan + Web App)"
    "sql:SQL Server + Database"
)

echo "=== Teardown Azure Resources ==="
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
    echo ">>> Running $folder/teardown.sh ..."
    sh "$SCRIPT_DIR/$folder/teardown.sh"
    echo ">>> $folder done."
}

if [ "$choice" = "0" ]; then
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
elif [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "${#RESOURCES[@]}" ]; then
    IFS=':' read -r folder label <<< "${RESOURCES[$((choice - 1))]}"
    run_script "$folder"
else
    echo "Invalid choice."
    exit 1
fi
