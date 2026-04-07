# Scripts Azure (AZ-204)

Scripts Azure CLI pour **créer** et **supprimer** les ressources necessaires pour les TPs.

------------------------------------------------------------------------

## 🎯 Objectif

-   Accélérer la mise en place les TPs
-   Éviter les erreurs manuelles
-   Scripts **idempotents**

------------------------------------------------------------------------

## ⚙️ Prérequis

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installé
- Connexion: `az login`

``` bash
az login
```

------------------------------------------------------------------------
## Structure

```
azure/
├── create.sh                 # Interactive: create one or all resources
├── teardown.sh               # Interactive: tear down one or all resources
├── variables.sh              # Fichier de configuration
├── tp1-app-service/
│   ├── create.sh             # Creates App Service Plan + App Service
│   └── teardown.sh           # Deletes App Service + App Service Plan
├── tp2-sql/
│   ├── create.sh             # Creates SQL Server + SQL Database
│   └── teardown.sh           # Deletes SQL Database + SQL Server
└── README.md
```

------------------------------------------------------------------------
## 🛠️ Configuration

Modifier dans `variables.sh` :
- **`STUDENT_ID`** — Le numéro de ressource group qui vous est affecté sur 2 chiffres
- **`STUDENT_EMAIL`** — Votre email tel que connu sur Azure

------------------------------------------------------------------------
## 🚀 Utilisation

### Mode interactif

``` bash
sh azure/create.sh
sh azure/teardown.sh
```

### Mode direct

``` bash
sh azure/sql/create.sh
sh azure/app-service/create.sh
```

------------------------------------------------------------------------
## Ce que font les scripts

### `create.sh` 

- Créé les resources

### `teardown.sh` 

- Supprime les resources

------------------------------------------------------------------------
## Actions manuelles

### TP2 - Ajouter le publish profile comme secret GitHub :

1. Copier le XML du publish profile affiché dans le résumé (ou le récupérer depuis Azure Portal > App Service > **Download publish profile**)
2. Dans votre dépôt GitHub, aller dans **Settings > Secrets and variables > Actions**
3. Modifier le secret commencant par `AZURE_WEBAPP_PUBLISH_PROFILE` avec le contenu du profil

## Notes

- Le Resource Group est partagé et n’est **jamais supprimé** par ces scripts.
- Le fichier `variables.sh` est placé à la racine de l’infra afin d’être mutualisé entre les différents sous-dossiers de ressources.
