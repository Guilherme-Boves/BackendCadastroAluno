CREATE DATABASE ALUNO
GO
USE ALUNO
CREATE TABLE ALU_ALUNO(
ALU_IN_CODIGO INT NOT NULL IDENTITY CONSTRAINT ALU_PK_ALUNO PRIMARY KEY,
ALU_IN_MATRICULA INT NOT NULL CONSTRAINT ALU_UK_ALU_MATRICULA UNIQUE, 
ALU_ST_NOME VARCHAR(50) NOT NULL,
ALU_ST_CURSO VARCHAR(50) NOT NULL,
ALU_ST_GENERO VARCHAR(25) NULL,
ALU_DT_NASCIMENTO DATE NOT NULL, 
ALU_CH_RG CHAR(12) NOT NULL CONSTRAINT ALU_UK_ALU_RG UNIQUE CONSTRAINT ALU_CK_ALU_RG CHECK (ALU_CH_RG LIKE '[0-9][0-9][.][0-9][0-9][0-9][.][0-9][0-9][0-9][-][0-9]'),
ALU_ST_EMAIL VARCHAR(50) NULL,
ALU_CH_CELULAR VARCHAR(15) NULL,
ALU_DT_MATRICULA DATE NOT NULL CONSTRAINT ALU_DF_ALU_MATRICULA DEFAULT GETDATE()
)

SELECT * FROM ALU_ALUNO

INSERT INTO ALU_ALUNO(ALU_IN_MATRICULA, ALU_ST_NOME, ALU_ST_CURSO, ALU_DT_NASCIMENTO, ALU_CH_RG, ALU_ST_EMAIL, ALU_CH_CELULAR)
VALUES(123456, 'Rodrigo', 'Desenvolvimento', '2000-05-21', '35.444.123-1', 'teste@teste.com', '15-99471-5213')

INSERT INTO ALU_ALUNO(ALU_IN_MATRICULA, ALU_ST_NOME, ALU_ST_CURSO, ALU_DT_NASCIMENTO, ALU_CH_RG, ALU_ST_EMAIL, ALU_CH_CELULAR)
VALUES(1234567, 'Juliana', 'Desenvolvimento', '2001-12-24', '35.444.123-1', 'teste@teste.com', '15-99471-5213')

/* PROCEDURES */

/***** Consulta para todos os registros *****/
CREATE PROCEDURE SP_S_ALU_ALUNO AS

SELECT
	ALU_IN_CODIGO AS 'Código',
	ALU_IN_MATRICULA AS 'Número da matrícula',
	ALU_ST_NOME AS 'Nome',
	ALU_ST_CURSO AS 'Curso',
	ALU_ST_GENERO AS 'Gênero',
	ALU_DT_NASCIMENTO AS 'Data de Nascimento',
	ALU_CH_RG AS 'RG',
	ALU_ST_EMAIL AS 'Email',
	ALU_CH_CELULAR AS 'Celular',
	CONVERT(CHAR(10), ALU_DT_MATRICULA,103) AS 'Data de inscrição'
FROM 
	ALU_ALUNO
ORDER BY
	ALU_IN_MATRICULA
GO

SP_S_ALU_ALUNO

/***** Consulta para apenas um registro (matricula) *****/
CREATE PROCEDURE SP_S_ALU_ALUNO_MATRICULA
@MATRICULA INT
AS
SELECT
	ALU_IN_CODIGO AS 'Código',
	ALU_IN_MATRICULA AS 'Número da matrícula',
	ALU_ST_NOME AS 'Nome',
	ALU_ST_CURSO AS 'Curso',
	ALU_ST_GENERO AS 'Gênero',
	ALU_DT_NASCIMENTO AS 'Data de Nascimento',
	ALU_CH_RG AS 'RG',
	ALU_ST_EMAIL AS 'Email',
	ALU_CH_CELULAR AS 'Celular',
	CONVERT(CHAR(10), ALU_DT_MATRICULA,103) AS 'Data de inscrição'
FROM
ALU_ALUNO
WHERE
ALU_IN_MATRICULA = @MATRICULA
ORDER BY
ALU_IN_MATRICULA 

SP_S_ALU_ALUNO_MATRICULA 12345



/***** Inclusão *****/
ALTER PROCEDURE SP_I_ALU_ALUNO
@MATRICULA INT, @NOME VARCHAR(50), @CURSO VARCHAR(50), @GENERO VARCHAR(25), @NASCIMENTO DATE, @RG CHAR(12), @EMAIL VARCHAR(50), @CELULAR VARCHAR(15), @CODIGOGERADO INT=0 OUT AS
SET NOCOUNT ON --DESLIGA AS LINHAS AFETADAS
DECLARE @NR_MATRICULA INT
DECLARE @NR_EMAIL INT
DECLARE @NR_CELULAR INT

--EFETURANDO O SELECT QUE IRÁ CONTAR A MATRICULA E ATRIBUINDO NA VARIÁVEL @NR_MATRICULA
SELECT @NR_MATRICULA = COUNT (ALU_IN_MATRICULA)
FROM ALU_ALUNO
WHERE ALU_IN_MATRICULA = @MATRICULA

--EFETURANDO O SELECT QUE IRÁ CONTAR O EMAIL E ATRIBUINDO NA VARIÁVEL @NR_EMAIL
SELECT @NR_EMAIL = COUNT (ALU_ST_EMAIL)
FROM ALU_ALUNO
WHERE ALU_ST_EMAIL = @EMAIL

--EFETURANDO O SELECT QUE IRÁ CONTAR O CELULAR E ATRIBUINDO NA VARIÁVEL @NR_CELULAR
SELECT @NR_CELULAR = COUNT (ALU_CH_CELULAR)
FROM ALU_ALUNO
WHERE ALU_CH_CELULAR = @CELULAR

--COMPARANDO SE O TOTAL DE MATRÍCULA É MAIOR QUE ZERO (OU SEJA, SE JÁ EXISTE NO BD)
IF @NR_MATRICULA > 0
BEGIN
	RAISERROR('O número de matrícula informado já existe em outro cadastro!',15,1)
	RETURN
END
--Verificando se o número da matrícula é negativo
IF @MATRICULA < 0
BEGIN
	RAISERROR('O número da matrícula não pode ser negativo',15,1)
	RETURN
END
--Verificando se já possui um email existente
IF @NR_EMAIL > 0
BEGIN
	RAISERROR('O email informado já existe em outro cadastro!',15,1)
	RETURN
END
--Verificando se já possui um celular existente
IF @NR_CELULAR > 0
BEGIN
	RAISERROR('O número de celular informado já existe em outro cadastro!',15,1)
	RETURN
END
--COMPARANDO O TAMANHO DA STRING DOS CAMPOS NOME, CURSO, NASCIMENTO, RG, EMAIL
IF (LEN(TRIM(@NOME)) = 0) OR (LEN(TRIM(@CURSO)) = 0) OR (LEN(@NASCIMENTO) = 0) OR (LEN(TRIM(@RG)) = 0) OR (LEN(TRIM(@EMAIL)) = 0)
BEGIN
	RAISERROR('O nome, curso, data de nascimento, rg e email são obrigatórios!',15,1)
	RETURN
END

INSERT INTO ALU_ALUNO(ALU_IN_MATRICULA, ALU_ST_NOME, ALU_ST_CURSO, ALU_ST_GENERO, ALU_DT_NASCIMENTO, ALU_CH_RG, ALU_ST_EMAIL, ALU_CH_CELULAR)
VALUES (@MATRICULA, @NOME, UPPER(@CURSO), @GENERO, @NASCIMENTO, @RG, @EMAIL, @CELULAR)

SET @CODIGOGERADO = SCOPE_IDENTITY() /* RETORNA O VALOR DO IDENTITY ATUAL */
PRINT @CODIGOGERADO -- NÃO É NECESSÁRIO PARA O PROJETO FINAL
RETURN @CODIGOGERADO
GO

EXEC SP_I_ALU_ALUNO 123414,'Leticia','Gestão de TI','Feminino','2000-02-15','23.456.789-1','teste@teste','15-99241-1447' 

SP_S_ALU_ALUNO

EXEC SP_I_ALU_ALUNO 12345679,'Jamilly','Medicina','Feminino','','23.456.789-1','teste@teste','15-99241-1448' 



/***** Alteração *****/ 
CREATE PROCEDURE SP_U_ALU_ALUNO
@MATRICULA INT, @NOME VARCHAR(50), @CURSO VARCHAR(50), @GENERO VARCHAR(25), @NASCIMENTO DATE, @RG CHAR(12), @EMAIL VARCHAR(50), @CELULAR VARCHAR(15) 
AS
SET NOCOUNT ON --DESLIGA AS LINHAS AFETADAS
DECLARE @NR_MATRICULA INT
--EFETURANDO O SELECT QUE IRÁ CONTAR A MATRICULA E ATRIBUINDO NA VARIÁVEL @NR_MATRICULA
SELECT @NR_MATRICULA = COUNT (ALU_IN_MATRICULA)
FROM ALU_ALUNO
WHERE ALU_IN_MATRICULA = @MATRICULA

--COMPARANDO SE O TOTAL DE MATRÍCULA É MAIOR QUE ZERO (OU SEJA, SE JÁ EXISTE NO BD)
IF @NR_MATRICULA = 0
BEGIN
	RAISERROR('Não foi possível efetuar a alteração! A matrícula informada não existe!.',15,1)
	RETURN
END
--Verificando se o número da matrícula é negativo
IF @MATRICULA < 0
BEGIN
	RAISERROR('O número da matrícula não pode ser negativo',15,1)
	RETURN
END

--COMPARANDO O TAMANHO DA STRING DOS CAMPOS NOME, CURSO, NASCIMENTO, RG, EMAIL
IF (LEN(TRIM(@NOME)) = 0) OR (LEN(TRIM(@CURSO)) = 0) OR (LEN(@NASCIMENTO) = 0) OR (LEN(TRIM(@RG)) = 0) OR (LEN(TRIM(@EMAIL)) = 0)
BEGIN
	RAISERROR('O nome, curso, data de nascimento, rg e email são obrigatórios!',15,1)
	RETURN
END

UPDATE ALU_ALUNO
	SET ALU_IN_MATRICULA = @MATRICULA,
	ALU_ST_NOME = @NOME,
	ALU_ST_CURSO = UPPER(@CURSO),
	ALU_ST_GENERO = @GENERO,
	ALU_DT_NASCIMENTO = @NASCIMENTO,
	ALU_CH_RG = @RG,
	ALU_ST_EMAIL = @EMAIL,
	ALU_CH_CELULAR = @CELULAR
WHERE ALU_IN_MATRICULA = @MATRICULA
GO

EXEC SP_U_ALU_ALUNO 123456,'Roberta','Gestão de TI','Feminino','2000-06-21','23.456.789-2','teste1@teste','15-99321-4892'

SP_S_ALU_ALUNO



/***** Deleção ******/
CREATE PROCEDURE SP_D_ALU_ALUNO
@MATRICULA INT AS
SET NOCOUNT ON
DECLARE @NR_MATRICULA INT
SELECT @NR_MATRICULA = COUNT (ALU_IN_MATRICULA) FROM ALU_ALUNO
WHERE ALU_IN_MATRICULA = @MATRICULA

IF @NR_MATRICULA = 0
BEGIN
	RAISERROR('Não é possível efetuar a exclusão. A matrícula informada não existe',15,1)
	RETURN
END

DELETE FROM ALU_ALUNO WHERE ALU_IN_MATRICULA = @MATRICULA
RETURN
GO

EXEC SP_D_ALU_ALUNO '123468'

SP_S_ALU_ALUNO


/***** Função *****/

/*
    Retorna a quantidade de Alunos com a idade que o usuário informar
*/
CREATE FUNCTION FN_IDADE
(@IDADE INT)
RETURNS INT AS
BEGIN
-- Declarando as variáveis
DECLARE @idade_pessoa INT

--Encontrando a idade

SELECT @idade_pessoa = COUT(*)
FROM ALU_ALUNO 
WHERE @IDADE = YEAR(GETDATE())  - YEAR(ALU_DT_NASCIMENTO)
GROUP BY YEAR(ALU_DT_NASCIMENTO)
RETURN @idade_pessoa 

END

SELECT dbo.FN_IDADE(19) AS Total -- Retorna a quantidade de pessoas com 19 anos (1)
SELECT dbo.FN_IDADE(21) AS Total -- Retorna a quantidade de pessoas com 21 anos (2)
SELECT dbo.FN_IDADE(20) AS Total
SELECT dbo.FN_IDADE(22) AS Total