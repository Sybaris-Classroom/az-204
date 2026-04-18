using AzureQuizLab.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace AzureQuizLab.Pages
{
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
            
            _logger.LogInformation("Chargement de la page d'accueil à {Time}", DateTime.UtcNow);

            _logger.LogInformation("Nombre de quiz : {QuizCount}", QuizCount);
            _logger.LogInformation("Nombre de questions : {QuestionCount}", QuestionCount);
        }
    }
}
