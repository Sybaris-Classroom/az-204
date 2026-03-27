# Infrastructure Scripts

Azure CLI scripts for provisioning and tearing down cloud resources.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Logged in: `az login`
- Access to the resource group (`RESOURCE_GROUP`) defined in `variables.sh`
  ```bash
  # Verify access
  az group show --name <RESOURCE_GROUP> --output table
  ```

## Structure

```
azure/
├── create.sh                 # Interactive: create one or all resources
├── teardown.sh               # Interactive: tear down one or all resources
├── variables.sh              # Shared configuration (resource names, SKU, region)
├── app-service/
│   ├── create.sh             # Creates App Service Plan + App Service (idempotent)
│   └── teardown.sh           # Deletes App Service + App Service Plan
├── sql/
│   ├── create.sh             # Creates SQL Server + SQL Database (idempotent)
│   └── teardown.sh           # Deletes SQL Database + SQL Server
└── README.md
```

## Setup

Before running any script, review and edit `variables.sh`. Key variables to check:

- **`AZ_CMD`** — path to the Azure CLI binary. Default is a Windows path (`C:\Tools\azure-cli\bin\az.cmd`). On macOS/Linux, change it to `az`.
- **`RESOURCE_GROUP`** — the Azure resource group all resources are created in. Make sure it exists and you have access.
- **`SQL_ADMIN_USER`** / **`SQL_ADMIN_PASSWORD`** — credentials for SQL Server authentication. The password is empty by default; set it in the file or pass it as an environment variable.
- **`SQL_FIREWALL_RULES`** — IP whitelist for remote database access. Add your IP here if you need to connect from your local machine (format: `"RuleName:StartIP:EndIP"`).

## Usage

```bash
# Interactive: choose which resource to create (or all)
sh azure/create.sh

# Interactive: choose which resource to tear down (or all)
sh azure/teardown.sh

# Or run individually
sh azure/app-service/create.sh
sh azure/sql/create.sh
sh azure/app-service/teardown.sh
sh azure/sql/teardown.sh
```

## What the create scripts do

### `create.sh` (interactive)

- Lets you create **all** resources or pick one
- When creating all: runs SQL first, then App Service, and **automatically sets `DefaultConnection`** on the App Service
- Prints a **post-setup summary** at the end with:
  - The ADO.NET connection string
  - TODO checklist (connection string, firewall, logging, publish profile)
  - The publish profile XML (ready to copy into GitHub secrets)

### `teardown.sh` (interactive)

- Lets you tear down **all** resources or pick one
- When tearing down all: confirms once, then deletes everything (skips individual confirmations)

## Post-setup (when running scripts individually)

> **When using `create.sh` with **ALL**, most of these are handled automatically.**

When running scripts individually, you'll need to do them manually:

### 1. Set the database connection string

```bash
az webapp config connection-string set \
    --name <APP_SERVICE_NAME> \
    --resource-group <RESOURCE_GROUP> \
    --connection-string-type SQLAzure \
    --settings DefaultConnection="<your-connection-string>"
```

The ADO.NET connection string is printed in the summary after SQL creation.

Also update `DefaultConnection` in your local project's `appsettings.json` (or user secrets) so you can run and debug locally.

### 2. Whitelist your IP for database access

To connect to the SQL Database from your local machine (e.g. for running migrations or debugging), either:

- Add your IP to `SQL_FIREWALL_RULES` in `variables.sh` and re-run `sh azure/sql/create.sh`, or
- Add it manually in the Azure Portal: SQL Server > **Networking** > **Add your client IPv4 address**

### 3. Configure GitHub Actions deployment

Add the publish profile as a GitHub secret:

1. Copy the publish profile XML printed in the summary (or retrieve it from Azure Portal > App Service > **Download publish profile**)
2. In your GitHub repo, go to **Settings > Secrets and variables > Actions**
3. Create secret `AZURE_WEBAPP_PUBLISH_PROFILE` with the profile contents

## Notes

- The resource group is shared and is **never deleted** by these scripts.
- The App Service Plan uses the **F1 (Free)** tier by default. Change `SKU` in `variables.sh` to upgrade.
- `variables.sh` stays at the infra root so it can be shared across resource-type subfolders.
