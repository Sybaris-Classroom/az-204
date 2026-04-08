#!/bin/bash

# ============================
# PARAMETRES A MODIFIER PAR L'ETUDIANT
# ============================

# Infos générales
STUDENT_ID="99"   # Le N° du ressource group qui vous a été affecté (ex: 01, 02, 03...)
STUDENT_EMAIL="prenom.nom@tondomaine.com" # L'email défini dans azure pour votre compte étudiant

# TP1 App Service
GITHUB_ORGANIZATION="MonOrganisationGitHub"  # L'organisation GitHub à utiliser
GITHUB_REPOSITORY="AzureQuizLab"  # Le dépôt GitHub à utiliser
GITHUB_BRANCH="main"  # La branche GitHub à utiliser
AZURE_WEBAPP_PUBLISH_PROFILE_SECRET="AZURE_WEBAPP_PUBLISH_PROFILE_XXXX" # Le secret GitHub pour le profil de publication Azure

# TP2 SQL
SQL_REUSE_EXISTING_RESOURCES="true"  # Pour des raisons de coût, vous pouvez choisir de réutiliser un serveur SQL et une base de données existants (true) ou d'en créer de nouveaux (false). Si vous choisissez true, assurez-vous que les variables SQL_SERVER_NAME et SQL_DATABASE_NAME correspondent à des ressources existantes que vous pouvez utiliser.
SQL_RESOURCE_GROUP="RG-Student-00"   # RG du serveur/base SQL cible. Laisser vide ou commenter pour utiliser RESOURCE_GROUP.
#SQL_SERVER_NAME="sql-AzureQuiz-${STUDENT_ID}"  # Si SQL_REUSE_EXISTING_RESOURCES, utiliser cette ligne à la place de la ligne suivante (ex: sql-AzureQuiz-00)
SQL_SERVER_NAME="sql-AzureQuiz-00"  # Nom du serveur SQL (doit être unique dans Azure, ex: sql-AzureQuiz-00)
SQL_DATABASE_NAME="AzureQuizLabDB"  # Nom de la base de données SQL

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
SQL_ADMIN_USER="dbserveradmin"
SQL_ADMIN_PASSWORD="P@ssword123!"  # Set via environment variable or pass as argument
SQL_ENTRA_ADMIN_EMAIL="${STUDENT_EMAIL}"

# SQL Database
SQL_SKU="Basic"
SQL_USE_ELASTIC_POOL="false"
SQL_ELASTIC_POOL_NAME=""
SQL_WORKLOAD_ENV="Development"
SQL_BACKUP_REDUNDANCY="Local"

# Seed behavior when target database already exists
# - false: skip seed if DB already exists
# - true: run seed even when DB already exists
SQL_SEED_ON_EXISTING_DATABASE="false"

# SQL Firewall - IP whitelist for remote access
# Format: "RuleName:StartIP:EndIP" (one entry per line)
# For a single IP, use the same value for start and end.
# Examples:
#   "Office:203.0.113.10:203.0.113.10"       - single IP
#   "VPN-Range:10.0.0.1:10.0.0.255"          - IP range
SQL_FIREWALL_RULES=(
     "MyIP:x.x.x.x:x.x.x.x"
)

echo "Etudiant : $STUDENT_ID"
echo "Etudiant email: $STUDENT_EMAIL"
echo "Resource Group : $RESOURCE_GROUP"
echo "WebApp : $APP_SERVICE_NAME"
echo "SQL : $SQL_SERVER_NAME"
