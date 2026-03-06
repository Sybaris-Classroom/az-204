
# TP1 — Déployer une Web App .NET sur Azure avec CI/CD GitHub

## Objectif

Dans ce TP vous allez :

- Créer un repository GitHub
- Créer une application ASP.NET Core
- Déployer une Web App sur Azure App Service
- Mettre en place un déploiement automatique avec GitHub Actions

## Prérequis

- Compte github
- Accès au tenant Azure fourni (fourni par le formateur)
- Visual Studio
- .Net 8.0 Sdk

## Prérequis formateur
- Inviter l'étudiant dans **Entra ID** en guest via son adresse mail
- Créer un resource group par étudiant
- Donner les droits suivants : 
  - Resource Group → Contributor  
  - Subscription → Reader

---

# Étape 1 — Créer un repository GitHub

Créer un repository nommé **AzureQuizLab**.

![Création repository](images/image1.png)

---

# Étape 2 — Cloner le repository + Créer l'application Web + Commit et Push

- Cloner le repository sur votre machine (ex : Visual Studio).
- Créer une application avec Visual Studio
  - ASP.NET Core Web App (Razor Pages)  
  - Framework : **.NET 8**
- Ajouter les fichiers au repository.

```
git add .
git commit -m "Initial project"
git push
```
---

# Étape 3 — Ouvrir App Services

Dans Azure Portal, sélectionner :**App Services**

![Portail Azure - App Services](images/image2.png)

---

# Étape 4 — Créer une Web App

Cliquer sur : **Create → Web App**

![Create web App](images/image3.png)

Resource Group : **RG-Student-XX**  
Name : **AzureQuizLab**  
Runtime : **.NET 8**  
OS : **Linux**  
Region : **West Europe**  
Pricing Plan : **Free**
Cliquer sur : **Review + Create**

![Wizard Create web App](images/image4.png)

Cliquer sur : **Create**

![Wizard Create web App End](images/image5.png)

Cliquer sur **Go to resource**.

![Go to resource](images/image6.png)

---

# Étape 5 — Configurer la Web App

Cliquer sur : **Settings → Configuration**
Cocher : **SCM Basic Auth Publishing Credentials**
Cliquer sur : **Apply**

![Configurer la web app](images/image7.png)


---

# Étape 6 — Configurer le CI/CD depuis Azure

Ouvrir **Deployment Center**.
Choisir comme source : **GitHub**
Cliquer sur : **Authorize**

![Deployment Center](images/image8.png)

Sélectionner :
- Organization
- Repository
- Branch
- Add a workflow
- Authentication Type → **Basic authentication**
Cliquer sur : **Save**

![Deployment Center configuration github](images/image9.png)

---

# Étape 7 — Vérifier le workflow / github action

Vérifier que le workflow (github action) a bien été créé sur votre repository github

![Github action](images/image10.png)

Vérifier que le workflow (github action) a bien été exécuté

![Deployment center](images/image11.png)

---

# Étape 8 — Vérifiez votre site

Depuis l’overview de la WebApp cliquer sur l'url

![Web app Url](images/image12.png)

Vérifier que votre web app se lance

![Web app execution](images/image13.png)

---

# Étape 9 — Tester le CI/CD

Modifier ensuite la page d’accueil de votre application et ajouter le texte **v1.0**
Commit → Push → attendre le déploiement → Rafraichir le site

![Redéploiement](images/image14.png)


