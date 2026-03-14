
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

TO BE CONTINUED