using System;
using System.Collections.Generic;

namespace AzureQuizLab.Models;

public partial class QuizAttemptAnswer
{
    public Guid Id { get; set; }

    public Guid QuizAttemptId { get; set; }

    public Guid QuestionId { get; set; }

    public Guid SelectedAnswerId { get; set; }

    public bool IsCorrect { get; set; }

    public virtual Question Question { get; set; } = null!;

    public virtual QuizAttempt QuizAttempt { get; set; } = null!;

    public virtual Answer SelectedAnswer { get; set; } = null!;
}
