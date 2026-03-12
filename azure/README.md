# Infrastructure Scripts

Azure CLI scripts for provisioning and tearing down the HelloWorld App Service.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Logged in: `az login`
- Access to the resource group (`RESOURCE_GROUP`) defined in `variables.sh`
  ```bash
  # Verify access
  az group show --name <RESOURCE_GROUP> --output table
  ```

## Files

| File | Description |
|------|-------------|
| `variables.sh` | All configurable values (resource names, SKU, region). Edit this to change settings. |
| `create-app-service.sh` | Creates App Service Plan and App Service. Safe to re-run (idempotent). |
| `teardown.sh` | Deletes App Service and App Service Plan. Prompts for confirmation. |

## Usage

```bash
# Create resources
sh infra/create-app-service.sh

# Tear down resources
sh infra/teardown.sh
```

## Post-setup

After creating the App Service, retrieve the publish profile for GitHub Actions deployment:

1. Go to [Azure Portal](https://portal.azure.com) > App Service > `HelloWorld-BelieveIt`
2. Click **Download publish profile**
3. In your GitHub repo, go to **Settings > Secrets and variables > Actions**
4. Create secret `AZURE_WEBAPP_PUBLISH_PROFILE` with the profile contents

## Notes

- The resource group is shared and is **never deleted** by these scripts.
- The App Service Plan uses the **F1 (Free)** tier by default. Change `SKU` in `variables.sh` to upgrade.
