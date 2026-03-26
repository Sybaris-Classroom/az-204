
# 🧪 TP2 --- Azure SQL, Configuration et Logs

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

![Variable d'environnement](images/Image0a.jpg)

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

![Site opérationnel](images/Image0b.jpg)

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

![Site en maintenance](images/Image0c.jpg)

------------------------------------------------------------------------

## Étape 5 --- Explication sur les sources de configuration en ASP.NET Core

ASP.NET Core charge la configuration depuis plusieurs sources :

1. **appsettings.json**
2. **appsettings.{Environment}.json**
3. **User Secrets** (uniquement en Development)
4. **Variables d’environnement** (Azure App Settings)
5. **Arguments de ligne de commande**

👉 **La dernière source a priorité.**

ASP.NET Core utilise une variable d’environnement :
``` csharp
ASPNETCORE_ENVIRONMENT
```
Les valeurs les plus courantes sont :
``` csharp
Development
Staging
Production
``` 

Cette variable est définie :
- En local (Visual Studio) dans *Properties/launchSettings.json*
- Azure défini automatiquement ASPNETCORE_ENVIRONMENT=Production, sauf en cas de changement dans Configuration → App Settings

Les User Secrets permettent de stocker des secrets hors du projet.
Pour les utiliser dans son projet il faut exécuter la ligne de commande suivante, ce qui rajoutera une section avec un id dans votre csproj : 
``` csharp
dotnet user-secrets init
```

Les secrets sont ensuite stockés dans votre profil Windows :
``` csharp
C:\Users\<user>\AppData\Roaming\Microsoft\UserSecrets\<id>\secrets.json
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

## Étape 1 --- Vérifier que sans configuration du firewall la connexion est en échec

1.  Ouvrir votre **SQL Database**
2.  Cliquer sur **Open in SQL Server Management Studio** - Le server name et la databasename sont affichés
3.  Cliquer sur **Open in SSMS**
4.  Cliquer sur **Oui** pour confirmer la connexion
5.  S'**authentifier**
6.  **Vérifier** que sans configuration préalable du firewall, la **connexion est en échec**

![SQL Database](images/Image6.jpg)

![Open in SSMS](images/Image7.jpg)

![Open in SSMS](images/Image8.jpg)

![Confirm in SSMS](images/Image9.jpg)

![authenticate in SSMS](images/Image10.jpg)

![authenticate failed in SSMS](images/Image11.jpg)

## Étape 2 --- Configuration du firewall
1. Ouvrir **Azure SQL**
2. Cliquer sur **SQL Logical servers**
3. Cliquer sur votre **Logical server**

![Sélectionner votre logical server](images/Image12.jpg)

4. Sélectionner dans le menu **Networking**
5. Cliquer sur **Selected Network**
6. Cliquer sur **Add you client IPv4 address**. Cela permettra à votre SSMS de se connecter.
7. Cliquer sur **Allow Azure services and resources to access this server** dans la section Exception. Cela permettra à votre Web App de se connecter.

![Configurer firewall](images/Image13.jpg)

7. Et enfin, **connectez vous** en suivant l'étape N°1 de la partie 3

![Connecté](images/Image14.jpg)

------------------------------------------------------------------------

# 🟢 Partie 4 --- Exécuter le script SQL

1.  Ouvrir votre **SQL Database**, une fois connecté avec SSMS
2.  Aller dans **Query Editor**
3.  Utiliser le script suivant :

![Script SQL](AzureQuizLab.sql)

4.  **Exécutez le**

Vérifier que les tables sont créées :

``` sql
SELECT * FROM Quiz;
SELECT COUNT(*) FROM Question;
```

------------------------------------------------------------------------

# 🟢 Partie 5 --- Connection String

## Étape 1 --- Récupérer la connection string

1. SQL Database → **Connection strings**
2. Cliquer sur **Show database connection strings**

![Connection string](images/Image15.jpg)

2. Choisir : **ADO.NET**

![Connection string ADO.NET](images/Image16.jpg)

------------------------------------------------------------------------

## Étape 2 --- Ajouter la connection string dans Azure

1.  Ouvrir votre **App Service**
2.  Aller dans **Settings → Environment variables**

![Connection string ADO.NET](images/Image17.jpg)

3.  Cliquer sur **Add**

Ajouter :

``` csharp
Name: DefaultConnection
Value: `<votre connection string complète>`
Type : SQLAzure
```

⚠ Remplacer le mot de passe par celui que vous avez défini.

Cliquer sur **Apply** 2 fois
![Connection string ADO.NET](images/Image18.jpg)

------------------------------------------------------------------------

# 🟢 Partie 6 --- Configurer l'accès SQL dans l'application

## 🎯 Objectif

Dans cette partie, vous allez :

- Ajouter Entity Framework Core
- Configurer la connection string pour le debug local
- Générer les classes correspondant aux tables
- Créer le `DbContext`
- Lire des données depuis Azure SQL

---

## Étape 1 — Configurer la connection string pour le debug local

Ouvrir :

`appsettings.Development.json`

Ajouter :

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=sql-quizlab-xx.database.windows.net;Database=AzureQuizLabDB;User Id=dbserveradmin;Password=VOTRE_MOT_DE_PASSE;TrustServerCertificate=True;"
  }
}
```

⚠️ Remplacez `VOTRE_MOT_DE_PASSE` par le mot de passe choisi.
⚠️ Remplacez `sql-quizlab-xx` par votre nom de serveur

⚠️ Ce fichier ne doit jamais contenir de mot de passe en production.

---

## Étape 2 — Installer les packages NuGet

Dans le terminal du projet :

```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet tool install --global dotnet-ef
dotnet ef dbcontext scaffold "Name=ConnectionStrings:DefaultConnection" Microsoft.EntityFrameworkCore.SqlServer -o Models --context QuizDbContext --no-onconfiguring
```

Description des commandes : 
- 'Microsoft.EntityFrameworkCore.SqlServer' ajoute le provider EF Core pour SQL Server / Azure SQL.
- 'Microsoft.EntityFrameworkCore.Tools' ajoute les outils EF nécessaires aux commandes de génération.
- 'dotnet tool install --global dotnet-ef' installe la commande CLI dotnet ef sur la machine.
- 'dotnet ef dbcontext scaffold' génère automatiquement les classes C# et le DbContext à partir de la base de données (approche Database First).

---

## Étape 3 — Enregistrer le DbContext dans Program.cs

```csharp
builder.Services.AddDbContext<QuizDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions => sqlOptions.EnableRetryOnFailure()
    ));
```

---

## Étape 4 — Lire les données depuis la base

Dans `Index.cshtml.cs` :

```csharp
    public class IndexModel : PageModel
    {
        private readonly QuizDbContext _context;
        private readonly ILogger<IndexModel> _logger;
        private readonly IConfiguration _configuration;

        public bool MaintenanceMode { get; set; }
        public int QuizCount { get; set; }
        public int QuestionCount { get; set; }

        public IndexModel(QuizDbContext context, ILogger<IndexModel> logger, IConfiguration configuration)
        {
            _context = context;
            _logger = logger;
            _configuration = configuration;
        }

        public void OnGet()
        {
            MaintenanceMode = _configuration.GetValue<bool>("MaintenanceMode", false);

            QuizCount = _context.Quizzes.Count();
            QuestionCount = _context.Questions.Count();
        }
    }
```

---

## Étape 5 — Afficher les informations dans la vue

Dans `Index.cshtml` :

```csharp
@if (!Model.MaintenanceMode)
{
    <div class="alert alert-info mt-3">
        📊 Base de données :
        <br />
        Nombre de quiz : <strong>@Model.QuizCount</strong>
        <br />
        Nombre de questions : <strong>@Model.QuestionCount</strong>
    </div>
}
```
---

## Étape 6 - Tester l'application
🧪 Test attendu

1. Lancer l’application en local
2. Vérifier que le nombre de quiz et de questions s’affiche
3. Commit → Push
4. Attendre le déploiement GitHub Actions
5. Ouvrir l'URL de votre WebApp
6. Vérifier que le quiz se charge depuis la base et que cela fonctionne également en Azure

![Application Test](images/Image19.jpg)

------------------------------------------------------------------------

# 🟢 Partie 7 — Explorer l’App Service avec Kudu (Linux)

## 🎯 Objectif

Dans cette partie, vous allez :

- Accéder à l’environnement d’exécution réel de votre application
- Vérifier les variables d’environnement injectées par Azure
- Explorer les fichiers réellement déployés
- Comprendre comment diagnostiquer un problème en production

---

## Étape 1 — Accéder à Kudu

1. Ouvrir votre **App Service**
2. Aller dans : **Development Tools → Advanced Tools**
3. Cliquer sur **Go**

Vous arrivez sur l’interface Kudu.

![Advanced Tools](images/Image20.jpg)

---

## Étape 2 — Vérifier les variables d'environnement

1. Ouvrir **Environment** sur le menu de gauche
2. Chercher la variable **MaintenanceMode** et vérifier sa valeur
3. Chercher la **connection string**
4. Ouvrir **File Manager** sur le menu de gauche
5. Vérifier que vous voyez les fichiers déployés

Le seul objectif ici c'est de vous montrer que vous avez accès à ces informations.

![Application Test](images/Image21.jpg)

---

## Étape 3 — Se connecter au conteneur de l’application et explorer les fichiers déployés

1. Ouvrir **_SSH** sur le menu de gauche
2. Ouvrir **SSH to Application** puis cliquer sur le boutton **Start Connection**

Pour info : 
- **SSH to Application** → conteneur réel de votre application  
- **SSH to Kudu** → conteneur d’administration interne  

Dans la console SSH, exécuter :

```bash
cd /home/site/wwwroot
ls
```

Vous devez voir :

- Vos fichiers Razor
- Vos DLL compilées
- Vos fichiers de configuration

Cela correspond exactement à ce qui a été déployé via GitHub Actions.

---

## Étape 4 — Vérifier les variables d’environnement en ligne de commande

Dans la console SSH, exécuter :

```bash
printenv
```

Rechercher :

- `MaintenanceMode`
- `ConnectionStrings__DefaultConnection`

Vous pouvez filtrer :

```bash
printenv | grep Maintenance
```

---

### 🎓 Ce que cela démontre

- Les variables configurées dans Azure sont injectées dans le conteneur
- La configuration Azure écrase celle du fichier `appsettings.json`
- L’application lit réellement les variables d’environnement système

---

## Étape 5 — Diagnostic simple

Si votre application génère une erreur :

1. Retourner dans Kudu
2. Naviguer vers :

```bash
cd /home/LogFiles
ls
```

Vous pourrez consulter les fichiers de logs.

---

## 🧠 À retenir

App Service Linux fonctionne sur un modèle basé sur des conteneurs managés.

Vous ne gérez pas l’OS, mais vous pouvez inspecter :

- Les fichiers déployés
- Les variables d’environnement
- Les logs

C’est un outil clé pour diagnostiquer un problème en production.

------------------------------------------------------------------------

# 🟢 Partie 8 — Implémenter les logs Azure (App Service Linux)

## 🎯 Objectif

Dans cette partie, vous allez :

- Configurer le logging dans l’application ASP.NET Core
- Activer l’envoi des logs vers Azure App Service
- Visualiser les logs en temps réel
- Comprendre le fonctionnement du diagnostic en production

---

## Étape 1 — Ajouter le logging Azure dans Program.cs

Ouvrir `Program.cs`.

Ajouter la configuration suivante AVANT `builder.Build()` :

```csharp
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddAzureWebAppDiagnostics();

// Rajouter le using & le package du même nom Microsoft.Extensions.Logging.AzureAppServices;
```

Cela permet :

- D’activer le logging console
- D’envoyer les logs vers le système de diagnostic Azure

---

## Étape 2 — Injecter un ILogger

Dans `Index.cshtml.cs` :

```csharp
private readonly ILogger<IndexModel> _logger;

public IndexModel(
    QuizDbContext context,
    IConfiguration configuration,
    ILogger<IndexModel> logger)
{
    _context = context;
    _configuration = configuration;
    _logger = logger;
}
```

---

## Étape 3 — Ajouter des logs dans le code

Dans la méthode `OnGet()` :

```csharp
_logger.LogInformation("Chargement de la page d'accueil à {Time}", DateTime.UtcNow);

_logger.LogInformation("Nombre de quiz : {QuizCount}", QuizCount);
_logger.LogInformation("Nombre de questions : {QuestionCount}", QuestionCount);
```

---

## Étape 4 — Commit et déployer

```bash
git add .
git commit -m "Ajout logging Azure"
git push
```

Attendre la fin du déploiement.

---

## Étape 5 — Configuration côté Azure (Linux) :Activer les logs App Service

1. Ouvrir votre **App Service**
2. Aller dans :  **Monitoring → App Service logs**
3. Activer :

- Application logging → File System
- Level → Information

4. Cliquer sur **Save**

⚠️ L’application redémarre automatiquement.

![App Service log](images/Image23.jpg)

---

## Étape 6 — Visualiser les logs en temps réel

Dans l’App Service :

1. Aller dans :  **Log stream**
2. Rafraîchir votre site

![Log stream](images/Image22.jpg)

Vous devez voir apparaître les logs :

Chargement de la page d'accueil à ...
Nombre de quiz : 1
Nombre de questions : 7

---

## Étape 7 — Vérifier via SSH (optionnel)

Dans Kudu → **SSH to Application** :

```bash
cd /home/LogFiles
ls
```

Les fichiers de logs sont stockés ici.

---

# 🧾 Conclusion

Dans ce TP, vous avez mis en œuvre plusieurs concepts fondamentaux d’Azure et d’ASP.NET Core :

- Vous avez externalisé la configuration de votre application grâce aux **variables d’environnement**
- Vous avez compris le fonctionnement des **sources de configuration ASP.NET Core** et leur priorité
- Vous avez créé et sécurisé une **Azure SQL Database**
- Vous avez connecté votre application à Azure SQL via **Entity Framework Core**
- Vous avez exploré l’environnement d’exécution réel grâce à **Kudu (SSH)**
- Vous avez mis en place un système de **logs applicatifs dans Azure**

---

## 🎯 Compétences clés pour l’AZ-204

- Gestion de la configuration (App Settings / Environment variables)
- Connexion à une base Azure SQL
- Diagnostic d’une application (logs + Kudu)
- Compréhension du modèle PaaS (App Service + Azure SQL)

---

## 💡 À retenir

- La configuration Azure **écrase toujours** celle du code
- Azure SQL est sécurisé par défaut (firewall obligatoire)
- Kudu permet d’accéder au **runtime réel**
