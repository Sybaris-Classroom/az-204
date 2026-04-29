using Azure.Storage.Queues;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace AzureQuizLab.Functions;

public class SubmitQuiz
{
    private readonly ILogger<SubmitQuiz> _logger;
    private readonly QueueClient _queueClient;

    public SubmitQuiz(ILogger<SubmitQuiz> logger)
    {
        _logger = logger;
        string connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
        // _queueClient = new QueueClient(connectionString, "quiz-queue");
        _queueClient = new QueueClient(connectionString, "quiz-queue", new QueueClientOptions
        {
            MessageEncoding = QueueMessageEncoding.Base64
        });
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
        _queueClient.SendMessage(message);

        _logger.LogInformation("Quiz soumis");
        return new OkObjectResult("Quiz soumis!");
    }
}