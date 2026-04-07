# Scripts Azure (AZ-204)

Scripts Azure CLI pour **créer** et **supprimer** les ressources necessaires pour les TPs.

------------------------------------------------------------------------

## 🎯 Objectif

-   Accélérer la mise en place les TPs
-   Éviter les erreurs manuelles
-   Scripts **idempotents**

------------------------------------------------------------------------

## ⚙️ Prérequis

- [SSMS](https://learn.microsoft.com/fr-fr/ssms/install/install) installé (inclut `sqlcmd`)
- [Azure CLI](https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli?view=azure-cli-latest) installé
- [GitHub CLI](https://cli.github.com/) installé
- Connexion pour azure CLI : `az login`

``` bash
az login
```

- Connexion pour GitHub CLI : `gh auth login`

``` bash
gh auth login
```
------------------------------------------------------------------------
## Structure

```
azure/
├── create.sh                 # Interactive: create one or all resources
├── teardown.sh               # Interactive: tear down one or all resources
├── variables.template.sh     # Template de configuration versionne
├── variables.local.sh        # Configuration locale (non versionnee)
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

1. Créer votre fichier local à partir du template :

```bash
cp lab-setup/variables.template.sh lab-setup/variables.local.sh
```

2. Modifier uniquement `lab-setup/variables.local.sh`.

3. Ne pas modifier `variables.template.sh` avec des données personnelles.

Modifier dans `variables.local.sh` :
- **`STUDENT_ID`** — Le numéro de ressource group qui vous est affecté sur 2 chiffres
- **`STUDENT_EMAIL`** — Votre email tel que connu sur Azure

### Réutiliser un SQL Server / une base existants (TP2)

Pour réduire les coûts, vous pouvez réutiliser des ressources SQL déjà créées en configurant :

- **`SQL_REUSE_EXISTING_RESOURCES="true"`** — utilise le serveur et la base définis par `SQL_SERVER_NAME` / `SQL_DATABASE_NAME` (erreur si l'un des deux n'existe pas)
- **`SQL_SEED_ON_EXISTING_DATABASE="false"`** — évite de rejouer le seed sur une base déjà existante

Les variables `SQL_SERVER_NAME` et `SQL_DATABASE_NAME` sont dans la section « paramètres à modifier par l'étudiant » de `variables.local.sh` pour faciliter la réutilisation d'une ressource partagée.

Effet en teardown TP2 :
- si `SQL_REUSE_EXISTING_RESOURCES="true"`, le serveur et la base ne sont pas supprimés

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
- Le fichier `variables.local.sh` est lu par tous les scripts et est ignore par Git.
