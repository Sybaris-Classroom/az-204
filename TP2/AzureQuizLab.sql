/* ============================================================
   AzureQuizLab - Script initial avec 7 questions
   ============================================================ */

-- Nettoyage
IF OBJECT_ID('QuizAttemptAnswer', 'U') IS NOT NULL DROP TABLE QuizAttemptAnswer;
IF OBJECT_ID('QuizAttempt', 'U') IS NOT NULL DROP TABLE QuizAttempt;
IF OBJECT_ID('Answer', 'U') IS NOT NULL DROP TABLE Answer;
IF OBJECT_ID('Question', 'U') IS NOT NULL DROP TABLE Question;
IF OBJECT_ID('Quiz', 'U') IS NOT NULL DROP TABLE Quiz;

---------------------------------------------------------------
-- 1️⃣ Quiz
---------------------------------------------------------------

CREATE TABLE Quiz (
    Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

---------------------------------------------------------------
-- 2️⃣ Question
---------------------------------------------------------------

CREATE TABLE Question (
    Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    QuizId UNIQUEIDENTIFIER NOT NULL,
    Text NVARCHAR(1000) NOT NULL,
    OrderNumber INT NOT NULL,
    CONSTRAINT FK_Question_Quiz 
        FOREIGN KEY (QuizId) REFERENCES Quiz(Id)
);

---------------------------------------------------------------
-- 3️⃣ Answer
---------------------------------------------------------------

CREATE TABLE Answer (
    Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    QuestionId UNIQUEIDENTIFIER NOT NULL,
    Text NVARCHAR(500) NOT NULL,
    IsCorrect BIT NOT NULL,
    CONSTRAINT FK_Answer_Question 
        FOREIGN KEY (QuestionId) REFERENCES Question(Id)
);

---------------------------------------------------------------
-- 4️⃣ QuizAttempt
---------------------------------------------------------------

CREATE TABLE QuizAttempt (
    Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    QuizId UNIQUEIDENTIFIER NOT NULL,
    UserName NVARCHAR(100) NOT NULL,
    Score INT NOT NULL,
    CompletedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_QuizAttempt_Quiz 
        FOREIGN KEY (QuizId) REFERENCES Quiz(Id)
);

---------------------------------------------------------------
-- 5️⃣ QuizAttemptAnswer
---------------------------------------------------------------

CREATE TABLE QuizAttemptAnswer (
    Id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    QuizAttemptId UNIQUEIDENTIFIER NOT NULL,
    QuestionId UNIQUEIDENTIFIER NOT NULL,
    SelectedAnswerId UNIQUEIDENTIFIER NOT NULL,
    IsCorrect BIT NOT NULL,
    CONSTRAINT FK_QAA_Attempt 
        FOREIGN KEY (QuizAttemptId) REFERENCES QuizAttempt(Id),
    CONSTRAINT FK_QAA_Question 
        FOREIGN KEY (QuestionId) REFERENCES Question(Id),
    CONSTRAINT FK_QAA_Answer 
        FOREIGN KEY (SelectedAnswerId) REFERENCES Answer(Id)
);

---------------------------------------------------------------
-- Index
---------------------------------------------------------------

CREATE INDEX IX_Question_QuizId ON Question(QuizId);
CREATE INDEX IX_Answer_QuestionId ON Answer(QuestionId);
CREATE INDEX IX_QuizAttempt_QuizId ON QuizAttempt(QuizId);

---------------------------------------------------------------
-- Données
---------------------------------------------------------------

DECLARE @QuizId UNIQUEIDENTIFIER = NEWID();

INSERT INTO Quiz (Id, Title, Description, IsActive)
VALUES (
    @QuizId,
    'Cloud Fundamentals - IaaS / PaaS / SaaS',
    'Quiz sur les modèles de service cloud',
    1
);

---------------------------------------------------------------
-- Questions
---------------------------------------------------------------

DECLARE @Q1 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q2 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q3 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q4 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q5 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q6 UNIQUEIDENTIFIER = NEWID();
DECLARE @Q7 UNIQUEIDENTIFIER = NEWID();

INSERT INTO Question (Id, QuizId, Text, OrderNumber) VALUES
(@Q1, @QuizId, 'Quelle est la principale différence entre IaaS, PaaS et SaaS ?', 1),
(@Q2, @QuizId, 'Dans quel modèle le client est responsable du système d’exploitation ?', 2),
(@Q3, @QuizId, 'Dans quel modèle le fournisseur cloud gère le système d’exploitation et le runtime ?', 3),
(@Q4, @QuizId, 'Dans quel modèle le client ne gère absolument rien de technique ?', 4),
(@Q5, @QuizId, 'Vous devez installer une application métier legacy nécessitant un accès complet au serveur. Quel modèle est le plus adapté ?', 5),
(@Q6, @QuizId, 'Quelle solution est la plus proche du modèle On-premise ?', 6),
(@Q7, @QuizId, 'Une équipe utilise Azure App Service pour héberger une application web. Quel modèle cloud est utilisé ?', 7);

---------------------------------------------------------------
-- Réponses
---------------------------------------------------------------

-- Q1
INSERT INTO Answer VALUES
(NEWID(), @Q1, 'Le prix', 0),
(NEWID(), @Q1, 'La localisation des serveurs', 0),
(NEWID(), @Q1, 'Le niveau de responsabilité du client', 1),
(NEWID(), @Q1, 'La vitesse de déploiement', 0);

-- Q2
INSERT INTO Answer VALUES
(NEWID(), @Q2, 'Aucun', 0),
(NEWID(), @Q2, 'SaaS', 0),
(NEWID(), @Q2, 'PaaS', 0),
(NEWID(), @Q2, 'IaaS', 1);

-- Q3
INSERT INTO Answer VALUES
(NEWID(), @Q3, 'On-premise', 0),
(NEWID(), @Q3, 'SaaS', 0),
(NEWID(), @Q3, 'PaaS', 1),
(NEWID(), @Q3, 'IaaS', 0);

-- Q4
INSERT INTO Answer VALUES
(NEWID(), @Q4, 'SaaS', 1),
(NEWID(), @Q4, 'PaaS', 0),
(NEWID(), @Q4, 'IaaS', 0),
(NEWID(), @Q4, 'On-premise', 0);

-- Q5
INSERT INTO Answer VALUES
(NEWID(), @Q5, 'SaaS', 0),
(NEWID(), @Q5, 'PaaS', 0),
(NEWID(), @Q5, 'IaaS', 1),
(NEWID(), @Q5, 'Serverless', 0);

-- Q6
INSERT INTO Answer VALUES
(NEWID(), @Q6, 'SaaS', 0),
(NEWID(), @Q6, 'PaaS', 0),
(NEWID(), @Q6, 'IaaS', 1),
(NEWID(), @Q6, 'Serverless', 0);

-- Q7
INSERT INTO Answer VALUES
(NEWID(), @Q7, 'On-premise', 0),
(NEWID(), @Q7, 'IaaS', 0),
(NEWID(), @Q7, 'PaaS', 1),
(NEWID(), @Q7, 'SaaS', 0);

PRINT 'AzureQuizLab initialized with 7 questions.';