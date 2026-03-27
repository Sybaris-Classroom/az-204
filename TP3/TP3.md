
# 🧪 TP 3 --- Azure Functions (AzureQuizLab)

## 🎯 Objectifs

À la fin de ce TP, vous serez capable de :

- Créer et configurer une **Azure Function**
- Comprendre les **triggers (HTTP, Queue, Timer)**
- Mettre en place une **architecture asynchrone avec Queue**
- Utiliser **ILogger** pour les logs
- Configurer et utiliser un **Storage Account**
- Accéder à une **base Azure SQL** depuis une Function

---

## 🧩 Scénario

Dans l’application **AzureQuizLab**, lorsqu’un utilisateur soumet un quiz :

1. Une requête HTTP est envoyée à une Azure Function
2. Un message est placé dans une queue
3. Une autre Azure Function traite ce message de manière asynchrone. L'idée est qu'un traitement long (par exemple génération d'un pptx depuis une quiz)
4. Un log est enregistré en base de données

---

## Prérequis

- Visual Studio avec le workload Azure
- Installer "Azure functions Core Tools" https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local    
- Avoir réalisé les précédents TP

---

# 🟢 Partie 1 — Création du projet

## Étape 1 — Création du projet

Sous Visual Studio, dans votre solution **AzureQuizLab** créer un projet **Azure Functions**.

Nommer le nouveau projet **AzureQuizLab.Functions**

![Azure Function VS](images/Image1.jpg)

![Projet AzureQuizLab.Functions](images/Image2.jpg)

## Étape 2 — Configuration

Choisir :

- Functions workers : .NET 10.0 Isolated
- Function : HTTP Trigger
- Cocher : Use Azurite

![Azure Function Setup](images/Image3.jpg)

---

# 🌐 Partie 2 — HTTP Function (SubmitQuiz)

## Étape 3 — Renommer la Function

Renommer la function en :

```csharp
public class SubmitQuiz
...
[Function("SubmitQuiz")]
```

## Étape 4 — Ajouter un log

Remplacer le code de la fonction par celui ci

```csharp
        _logger.LogInformation("Quiz soumis");
        return new OkObjectResult("Quiz soumis!");
```

## Étape 5 — Test

Lancer le projet et appeler l’URL fournie dans le navigateur.

![Récupérer l'url](images/Image4.jpg)

![Test url](images/Image5.jpg)

## Étape 6 — Envoyer un message dans une Queue

Dans cette étape on va implémenter l'envoi d'un message dans une queue. Le code va être implémenté ici, et nous créons la Queue dans la Partie 4.

Rajouter le package nuget suivant : 

```bash
dotnet add package Azure.Storage.Queues
```

Et remplacer le code par celui ci qui envoie un message dans la queue

```csharp
public class SubmitQuiz
{
    private readonly ILogger<SubmitQuiz> _logger;
    private readonly QueueClient _queueClient;

    public SubmitQuiz(ILogger<SubmitQuiz> logger)
    {
        _logger = logger;
        string connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
        _queueClient = new QueueClient(connectionString, "quiz-queue");

        _queueClient.CreateIfNotExists();
    }

    [Function("SubmitQuiz")]
    public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
    {
        _logger.LogInformation("SubmitQuiz function triggered");

        // Création d’un objet quiz simulé
        var quiz = new
        {
            userId = "123",
            quizId = "456",
            score = 80,
            submittedAt = DateTime.UtcNow
        };

        // Sérialisation JSON
        string message = JsonSerializer.Serialize(quiz);

        _logger.LogInformation("Quiz soumis");
        return new OkObjectResult("Quiz soumis!");
    }
}
```

---

# 📦 Partie 3 — Storage Account

## 📦 Pourquoi créer un Storage Account ?

Une Azure Function nécessite **obligatoirement** un Storage Account pour fonctionner.

Même si vous ne manipulez pas directement de fichiers ou de données, Azure utilise ce stockage en arrière-plan pour :

- gérer les **triggers** (comme les queues ou timers)  
- stocker des **logs techniques**  
- assurer le **suivi des exécutions**  
- permettre le **scaling automatique**  

👉 Dans ce TP, le Storage Account servira également à héberger la **queue (`quiz-queue`)**, qui permettra de découpler le traitement du quiz.

💡 À retenir :  
> Une Azure Function = du code + un Storage Account (indispensable)

## Étape 7 — Création

Dans Azure Portal, créer un **Storage Account** :

- Type : Standard
- Région : identique à la Function App

## Étape 8 — Vérification

S’assurer que le Storage Account est bien créé.

## Étape 9 — Connection string

Récupérer la **connection string du Storage Account**.

---

# 📩 Partie 4 — Mise en place de la Queue

## Étape 10 — Configuration locale

Vérifier dans `local.settings.json` :

```json
"AzureWebJobsStorage": "UseDevelopmentStorage=true"
```

## Étape 11 — Création du QueueClient

```csharp
var queueClient = new QueueClient(connectionString, "quiz-queue");
await queueClient.CreateIfNotExistsAsync();
```

## Étape 12 — Envoi du message

```csharp
await queueClient.SendMessageAsync(message);
```

---

# 🔍 Partie 5 — Visualisation avec Storage Browser

## Étape 13 — Accès

Azure Portal → Storage Account → Queues

## Étape 14 — Création de la queue

Créer `quiz-queue` si elle n’existe pas.

## Étape 15 — Observation

- Avant appel → vide
- Après appel → message visible

---

# ⚡ Partie 6 — Queue Function (ProcessQuiz)

## Étape 16 — Création

Ajouter une Function avec **Queue Trigger**

## Étape 17 — Nom

```csharp
[Function("ProcessQuiz")]
```

## Étape 18 — Configuration

```csharp
[QueueTrigger("quiz-queue")]
```

## Étape 19 — Log

```csharp
log.LogInformation($"Message reçu : {message}");
```

## Étape 20 — Test

Appeler la HTTP Function et observer le déclenchement automatique.

---

# 🗄️ Partie 7 — Accès Azure SQL

## Étape 21 — Connection string

Ajouter la connection string Azure SQL.

## Étape 22 — Création de la table

```sql
CREATE TABLE Logs (
    Id INT IDENTITY PRIMARY KEY,
    Message NVARCHAR(MAX),
    CreatedAt DATETIME
);
```

## Étape 23 — Code SQL

```csharp
using (SqlConnection conn = new SqlConnection(connectionString))
{
    conn.Open();
    var cmd = new SqlCommand(
        "INSERT INTO Logs (Message, CreatedAt) VALUES (@msg, GETDATE())", conn);

    cmd.Parameters.AddWithValue("@msg", message);
    cmd.ExecuteNonQuery();
}
```

## Étape 24 — Test

Vérifier que les données sont insérées.

---

# ⏰ Partie 8 — Timer Function (Azure Portal)

## Étape 25 — Création Function App

Créer une Function App Azure.

## Étape 26 — Déploiement

Publier depuis Visual Studio.

## Étape 27 — Ajouter Function

Dans Azure → Add Function → Timer Trigger

## Étape 28 — Nom

CleanupQuizData

## Étape 29 — CRON

```
0 */5 * * * *
```

## Étape 30 — Log

Ajouter un log simple.

## Étape 31 — Vérification

Consulter les logs dans Azure.

---

# 🔵 Partie 9 — Tests finaux

## Étape 32

Appeler SubmitQuiz

## Étape 33

Vérifier :

- message dans la queue
- déclenchement ProcessQuiz
- insertion SQL

## Étape 34

Observer logs et Timer

---

# 🧠 À retenir

- Azure Functions nécessite un **Storage Account**
- HTTP → entrée utilisateur
- Queue → découplage
- Queue Function → traitement
- Timer → automatisation
