using System;
using System.Collections.Generic;

namespace AzureQuizLab.Models;

public partial class Answer
{
    public Guid Id { get; set; }

    public Guid QuestionId { get; set; }

    public string Text { get; set; } = null!;

    public bool IsCorrect { get; set; }

    public virtual Question Question { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();
}
