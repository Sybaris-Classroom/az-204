
# TP2 --- Azure SQL, Configuration et Logs

## 🎯 Objectifs

À la fin de ce TP, vous serez capable de :

-   Créer un Azure SQL Logical Server
-   Créer une base Azure SQL
-   Configurer le firewall
-   Exécuter un script SQL
-   Configurer une connection string dans Azure App Service
-   Utiliser une variable d'environnement
-   Activer et consulter les logs

## Prérequis
- Avoir fait le TP1
- Avoir SSMS (Sql Management Studio) pour se connecter à la base de données

------------------------------------------------------------------------

# 🟢 Partie 1 --- Configuration via Feature Flag (MaintenanceMode)

## 🎯 Objectifs

L'idée est de rajouter un feature flag afin de pouvoir afficher si le site est en maintenance ou pas.\
L'objectif pédagogique est : 
- Externaliser une configuration dans Azure
- Utiliser une variable d’environnement dans votre application
- Modifier le comportement de l’application sans redéployer

## Étape 1 --- Ajouter une variable d'environnement

Dans Azure Portal :

1.  Ouvrir votre **App Service**
2.  Aller dans **Settings → Environment variables**
3.  Cliquer sur **Add**

Ajouter :
``` csharp
Name: MaintenanceMode
Value: false
```

Cliquer sur **Save**

------------------------------------------------------------------------

## Étape 2 --- Lire la variable dans le code

Dans `Index.cshtml.cs` :

``` csharp
        public bool MaintenanceMode { get; set; }

        public void OnGet()
        {
            MaintenanceMode = _configuration.GetValue<bool>("MaintenanceMode", false);
        }
```

------------------------------------------------------------------------

## Étape 3 --- Adapter la vue Razor

Dans `Index.cshtml` :

``` csharp
    @if (Model.MaintenanceMode)
    {
        <p class="alert alert-warning">🚧 Le site est actuellement en maintenance. Veuillez réessayer plus tard.</p>
    }
    else
    {
        <p class="alert alert-success">✅ Le site est opérationnel. Bienvenue !</p>
    }
```

Commit → Push → Vérifiez que le déploiement s'effectue correctement.

------------------------------------------------------------------------

## Étape 4 --- Tester le changement de valeur

1. Vérifiez que le site affiche :
``` csharp
  ✅ Le site est opérationnel. Bienvenue !
```
2. Retournez dans Azure Portal
3. Modifiez la variable :
``` csharp
  MaintenanceMode = true
```
4. Cliquez sur Save
5. Attendez quelques secondes
6. Rafraîchissez la page 👉 Le message doit maintenant afficher :
``` csharp
🚧 Le site est actuellement en maintenance.
```

------------------------------------------------------------------------

# 🟢 Partie 2 --- Création Azure SQL

## 🎯 Objectifs

Dans cette partie, vous allez :
- Créer un Azure SQL Logical Server
- Créer une Azure SQL Database
- Comprendre la différence entre serveur logique et base
- Configurer l’accès réseau (firewall)

Dans Azure :
- Le Logical Server représente l’instance logique SQL
- La Database contient vos tables et données
- Un Logical Server peut contenir plusieurs bases.
- Cela correspond au modèle PaaS (Platform as a Service).

## Étape 1 --- Créer une Azure SQL Database

Dans Azure Portal chercher :

1.  **Azure SQL Database**
2.  **Create → SQL Database** 

![Create SQL Database](images/Image1.jpg)

3.  Renseigner :
- Resource group : le resource group qui vous a été assigné
- Database name : AzureQuizLabDB
- Workload environment :  Development
- Backup storage redundancy : Locally-redundant backup storage

![Create SQL Database data](images/Image2.jpg)

4. Pour **Server** cliquer sur **Create new**
5. Renseigner :
- Server name : sql-quizlab-xx (doit être unique)
- Location : France Central
- Authentication method : Use both SQL and Microsoft Entra authentication
- Admin login : dbserveradmin
- Password : mot de passe fort (notez le...)

![Create SQL Logical server](images/Image3.jpg)

6. Cliquer sur **OK** pour valider les informations
7. Sur **Compute + storage ** cliquer sur le lien **Configure database**

![Configure Database](images/Image4.jpg)

8. Sélectioner :
- Service tier Basic (For less demanding worloads)

![SQL Database pricing](images/Image5.jpg)

9. Cliquer sur **Apply**
10. Cliquer sur **Review + Create** suivi de **Create** pour procéder à la création à la fois du serveur logique et de la database
11. Attendre le déploiement


------------------------------------------------------------------------

# 🟢 Partie 3 --- Configuration du Firewall

1.  Ouvrir votre **SQL Server**
2.  Aller dans **Networking**
3.  Cliquer sur **Add your client IPv4 address**
4.  Cocher **Allow Azure services**
5.  Cliquer sur **Save**

------------------------------------------------------------------------

# 🟢 Partie 4 --- Exécuter le script SQL

1.  Ouvrir votre **SQL Database**
2.  Aller dans **Query Editor**
3.  Se connecter avec :
    -   Login : quizadmin
    -   Password : celui choisi
4.  Coller le script SQL fourni par le formateur
5.  Cliquer sur **Run**

Vérifier que les tables sont créées :

``` sql
SELECT * FROM Quiz;
SELECT COUNT(*) FROM Question;
```

------------------------------------------------------------------------

# 🟢 Partie 5 --- Connection String

## Étape 6 --- Récupérer la connection string

SQL Database → **Connection strings**

Choisir : **ADO.NET**

------------------------------------------------------------------------

## Étape 7 --- Ajouter la connection string dans Azure

1.  Ouvrir votre **App Service**
2.  Aller dans **Settings → Environment variables**
3.  Cliquer sur **Add**

Ajouter :

Name: ConnectionStrings\_\_DefaultConnection\
Value: `<votre connection string complète>`{=html}

⚠ Remplacer le mot de passe par celui que vous avez défini.

Cliquer sur **Save**

------------------------------------------------------------------------

# 🟢 Partie 6 --- Configurer l'accès SQL dans l'application

Dans `Program.cs` :

``` csharp
builder.Services.AddDbContext<QuizDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions => sqlOptions.EnableRetryOnFailure()
    ));
```

------------------------------------------------------------------------

# 🟢 Partie 7 --- Tester l'application

1.  Commit → Push
2.  Attendre le déploiement GitHub Actions
3.  Ouvrir l'URL de votre WebApp
4.  Vérifier que le quiz se charge depuis la base

------------------------------------------------------------------------

# 🟢 Partie 8 --- Activer les logs

## Étape 8 --- Activer App Service Logs

1.  Ouvrir votre **App Service**
2.  Aller dans **Monitoring → App Service logs**
3.  Activer :
    -   Application Logging
    -   Log Stream

Cliquer sur **Save**

------------------------------------------------------------------------

## Étape 9 --- Ajouter un log manuel

Dans votre code :

``` csharp
_logger.LogInformation("Quiz loaded at {Time}", DateTime.UtcNow);
```

Déployer et observer le résultat via **Log Stream**.

------------------------------------------------------------------------

# ✅ Résultat attendu

Architecture obtenue :

Azure App Service\
↓\
Azure SQL Database

------------------------------------------------------------------------

# 🎓 Concepts AZ-204 couverts

-   Azure SQL Logical Server
-   Configuration Firewall
-   Connection Strings
-   Configuration via App Settings
-   Gestion des transient faults
-   Monitoring & Logs
