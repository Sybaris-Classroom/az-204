#!/bin/bash

# =============================================================================
# Azure CLI command (use "az.cmd" on Windows/MSYS, "az" on Linux/macOS)
# =============================================================================
AZ_CMD="C:\Tools\azure-cli\bin\az.cmd"

# =============================================================================
# Azure resource configuration
# =============================================================================

# Shared resource group
RESOURCE_GROUP="RG-Student-04"

# Region
LOCATION="westeurope"

# App Service Plan
APP_SERVICE_PLAN="HelloWorld-BelieveIt-Plan"
SKU="F1"

# App Service
APP_SERVICE_NAME="HelloWorld-BelieveIt"
RUNTIME="DOTNETCORE:10.0"
