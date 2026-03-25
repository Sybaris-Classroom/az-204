using System;
using System.Collections.Generic;

namespace AzureQuizLab.Models;

public partial class Question
{
    public Guid Id { get; set; }

    public Guid QuizId { get; set; }

    public string Text { get; set; } = null!;

    public int OrderNumber { get; set; }

    public virtual ICollection<Answer> Answers { get; set; } = new List<Answer>();

    public virtual Quiz Quiz { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();
}
