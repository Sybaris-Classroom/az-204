using Google.Protobuf;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using System;

namespace AzureQuizLab.Functions;

public class CleanupQuizData
{
    private readonly ILogger _logger;

    public CleanupQuizData(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<CleanupQuizData>();
    }

    [Function("CleanupQuizData")]
    public void Run([TimerTrigger("0 */5 * * * *")] TimerInfo myTimer) // pour 10 secondes : "*/10 * * * * *"
    {
        _logger.LogInformation("C# Timer trigger function executed at: {executionTime}", DateTime.Now);

        var connectionString = Environment.GetEnvironmentVariable("SqlConnectionString");

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();

            var cmd = new SqlCommand("INSERT INTO Logs (Message, LogDate) VALUES (@msg, GETDATE())", conn);

            cmd.Parameters.AddWithValue("@msg", "C# Timer trigger function executed");
            cmd.ExecuteNonQuery();
        }

        _logger.LogInformation("Ecriture en base effectuée");
    }
}