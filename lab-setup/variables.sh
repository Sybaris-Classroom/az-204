#!/bin/bash

# ============================
# PARAMÈTRE A MODIFIER PAR L'ÉTUDIANT
# ============================

STUDENT_ID="00"   # <-- A MODIFIER PAR L'ÉTUDIANT
#STUDENT_EMAIL="prenom.nom@tondomaine.com" # <-- A MODIFIER PAR L'ÉTUDIANT
STUDENT_EMAIL="vitina.pugliesi@gmail.com" # <-- A MODIFIER PAR L'ÉTUDIANT
GITHUB_ORGANIZATION="BinaryCodeNebula"  # <-- A MODIFIER PAR L'ÉTUDIANT
GITHUB_REPOSITORY="AzureQuizLab"  # <-- A MODIFIER PAR L'ÉTUDIANT
GITHUB_BRANCH="main"  # <-- A MODIFIER PAR L'ÉTUDIANT
AZURE_WEBAPP_PUBLISH_PROFILE_SECRET="AZUREAPPSERVICE_PUBLISHPROFILE_BBEDA64A2AEF42808A554C5287906F41" # <-- A MODIFIER PAR L'ÉTUDIANT 

# =============================================================================
# Azure CLI command (use "az.cmd" on Windows/MSYS, "az" on Linux/macOS)
# =============================================================================
AZ_CMD="az"

# =============================================================================
# GITHUB (for deploy automation)
# =============================================================================
DEPLOYMENT_SOURCE="GitHub"  # Deployment Center source
GITHUB_REPO="${GITHUB_ORGANIZATION}/${GITHUB_REPOSITORY}"  # Used by gh secret set

# ============================
# RESOURCE GROUP
# ============================

RESOURCE_GROUP="RG-Student-${STUDENT_ID}"

# ============================
# LOCALISATION
# ============================
APP_SERVICE_LOCATION="westeurope"
SQL_LOCATION="francecentral"

# ============================
# APP SERVICE
# ============================
APP_SERVICE_PLAN="AzureQuizLabWebApp_Plan-${STUDENT_ID}"
APP_SERVICE_NAME="AzureQuizLabWebApp-${STUDENT_ID}"

SKU="F1"
RUNTIME="DOTNETCORE:10.0"

# Activate application logging and set log level (optional)
APP_LOG_ENABLED="true"
APP_LOG_LEVEL="information"  # verbose, information, warning, error

# ============================
# SQL SERVER
# ============================
SQL_SERVER_NAME="sql-AzureQuiz-${STUDENT_ID}"
SQL_ADMIN_USER="dbserveradmin"
SQL_ADMIN_PASSWORD="P@ssword123!"  # Set via environment variable or pass as argument
SQL_ENTRA_ADMIN_EMAIL="${STUDENT_EMAIL}"

# SQL Database
SQL_DATABASE_NAME="AzureQuizLabDB"
SQL_SKU="Basic"
SQL_USE_ELASTIC_POOL="false"
SQL_ELASTIC_POOL_NAME=""
SQL_WORKLOAD_ENV="Development"
SQL_BACKUP_REDUNDANCY="Local"

# SQL Firewall — IP whitelist for remote access
# Format: "RuleName:StartIP:EndIP" (one entry per line)
# For a single IP, use the same value for start and end.
# Examples:
#   "Office:203.0.113.10:203.0.113.10"       — single IP
#   "VPN-Range:10.0.0.1:10.0.0.255"          — IP range
    # "MyIP:x.x.x.x:x.x.x.x"
SQL_FIREWALL_RULES=(
     "MyIP1:88.123.45.121:88.123.45.121"
)

echo "Étudiant : $STUDENT_ID"
echo "Étudiant email: $STUDENT_EMAIL"
echo "Resource Group : $RESOURCE_GROUP"
echo "WebApp : $APP_SERVICE_NAME"
echo "SQL : $SQL_SERVER_NAME"