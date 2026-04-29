using Azure.Identity;
using AzureQuizLab.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace AzureQuizLab
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddRazorPages();

            //builder.Services.AddDbContext<QuizDbContext>(options =>
            //    options.UseSqlServer(
            //        builder.Configuration.GetConnectionString("DefaultConnection"),
            //        sqlOptions => sqlOptions.EnableRetryOnFailure()
            //    ));

            builder.Services.AddDbContext<QuizDbContext>(options =>
            {
                var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

                // Lecture depuis appsettings.Development.json en local
                // ou depuis les variables d'environnement Azure App Service
                var sqlServerName = builder.Configuration["SqlServerName"];
                var sqlDatabaseName = builder.Configuration["SqlDatabaseName"];

                // On part toujours de la DefaultConnection existante
                var sqlConnectionStringBuilder = new SqlConnectionStringBuilder(connectionString);

                // Si SqlServerName est renseigné, on remplace le nom du serveur
                if (!string.IsNullOrWhiteSpace(sqlServerName))
                {
                    sqlConnectionStringBuilder.DataSource = $"{sqlServerName}.database.windows.net";
                }

                // Si SqlDatabaseName est renseigné, on remplace le nom de la base
                if (!string.IsNullOrWhiteSpace(sqlDatabaseName))
                {
                    sqlConnectionStringBuilder.InitialCatalog = sqlDatabaseName;
                }

                options.UseSqlServer(sqlConnectionStringBuilder.ConnectionString);
            });


            builder.Logging.ClearProviders();
            builder.Logging.AddConsole();
            builder.Logging.AddAzureWebAppDiagnostics();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.MapRazorPages();

            app.Run();
        }
    }
}
