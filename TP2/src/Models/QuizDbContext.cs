using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace AzureQuizLab.Models;

public partial class QuizDbContext : DbContext
{
    public QuizDbContext(DbContextOptions<QuizDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Answer> Answers { get; set; }

    public virtual DbSet<Question> Questions { get; set; }

    public virtual DbSet<Quiz> Quizzes { get; set; }

    public virtual DbSet<QuizAttempt> QuizAttempts { get; set; }

    public virtual DbSet<QuizAttemptAnswer> QuizAttemptAnswers { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Answer>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Answer__3214EC07C189FE0F");

            entity.ToTable("Answer");

            entity.HasIndex(e => e.QuestionId, "IX_Answer_QuestionId");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.Text).HasMaxLength(500);

            entity.HasOne(d => d.Question).WithMany(p => p.Answers)
                .HasForeignKey(d => d.QuestionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Answer_Question");
        });

        modelBuilder.Entity<Question>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Question__3214EC0777789576");

            entity.ToTable("Question");

            entity.HasIndex(e => e.QuizId, "IX_Question_QuizId");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.Text).HasMaxLength(1000);

            entity.HasOne(d => d.Quiz).WithMany(p => p.Questions)
                .HasForeignKey(d => d.QuizId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Question_Quiz");
        });

        modelBuilder.Entity<Quiz>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Quiz__3214EC075CB602EE");

            entity.ToTable("Quiz");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Title).HasMaxLength(200);
        });

        modelBuilder.Entity<QuizAttempt>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__QuizAtte__3214EC07E517782B");

            entity.ToTable("QuizAttempt");

            entity.HasIndex(e => e.QuizId, "IX_QuizAttempt_QuizId");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CompletedAt).HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.UserName).HasMaxLength(100);

            entity.HasOne(d => d.Quiz).WithMany(p => p.QuizAttempts)
                .HasForeignKey(d => d.QuizId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_QuizAttempt_Quiz");
        });

        modelBuilder.Entity<QuizAttemptAnswer>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__QuizAtte__3214EC0738BCEB02");

            entity.ToTable("QuizAttemptAnswer");

            entity.Property(e => e.Id).ValueGeneratedNever();

            entity.HasOne(d => d.Question).WithMany(p => p.QuizAttemptAnswers)
                .HasForeignKey(d => d.QuestionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_QAA_Question");

            entity.HasOne(d => d.QuizAttempt).WithMany(p => p.QuizAttemptAnswers)
                .HasForeignKey(d => d.QuizAttemptId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_QAA_Attempt");

            entity.HasOne(d => d.SelectedAnswer).WithMany(p => p.QuizAttemptAnswers)
                .HasForeignKey(d => d.SelectedAnswerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_QAA_Answer");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
