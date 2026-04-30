using System;
using System.Collections.Generic;

namespace AzureQuizLab.Models;

public partial class QuizAttempt
{
    public Guid Id { get; set; }

    public Guid QuizId { get; set; }

    public string UserName { get; set; } = null!;

    public int Score { get; set; }

    public DateTime CompletedAt { get; set; }

    public virtual Quiz Quiz { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();
}
