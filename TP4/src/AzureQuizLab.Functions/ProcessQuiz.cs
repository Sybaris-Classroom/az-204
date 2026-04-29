using Azure.Storage.Queues.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace AzureQuizLab.Functions;

public class ProcessQuiz
{
    private readonly ILogger<ProcessQuiz> _logger;

    public ProcessQuiz(ILogger<ProcessQuiz> logger)
    {
        _logger = logger;
    }

    [Function(nameof(ProcessQuiz))]
    public void Run([QueueTrigger("quiz-queue", Connection = "AzureWebJobsStorage")] QueueMessage message)
    {
        _logger.LogInformation("C# Queue trigger function processed: {messageText}", message.MessageText);
        //throw  new Exception("Simulated error to test retry and poison queue handling.");

        var connectionString = Environment.GetEnvironmentVariable("SqlConnectionString");

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();

            var cmd = new SqlCommand("INSERT INTO Logs (Message, LogDate) VALUES (@msg, GETDATE())", conn);

            cmd.Parameters.AddWithValue("@msg", message.MessageText);
            cmd.ExecuteNonQuery();
        }

        _logger.LogInformation("Ecriture en base effectuée");
    }
}