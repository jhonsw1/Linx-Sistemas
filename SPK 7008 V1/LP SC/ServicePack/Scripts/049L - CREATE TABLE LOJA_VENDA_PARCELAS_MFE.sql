DECLARE @CRIAR_TABELA AS BIT
SET @CRIAR_TABELA = 0

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LOJA_VENDA_PARCELAS_MFE')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM LOJA_VENDA_PARCELAS_MFE)
			BEGIN
				DROP TABLE LOJA_VENDA_PARCELAS_MFE
				SET @CRIAR_TABELA = 1
			END
	END
ELSE
	BEGIN
		SET @CRIAR_TABELA = 1
	END


IF @CRIAR_TABELA = 1
	BEGIN
		CREATE TABLE [DBO].[LOJA_VENDA_PARCELAS_MFE]
		(
			[TERMINAL]                 [CHAR](3)		NOT NULL				,
			[LANCAMENTO_CAIXA]         [CHAR](7)		NOT NULL				,
			[CODIGO_FILIAL]            [CHAR](6)		NOT NULL				,
			[PARCELA]                  [CHAR](2)		NOT NULL				,
			[ID_PAGAMENTO]             [INT]			NULL		DEFAULT(0)	,
			[ID_FILA]				   [INT]			NULL		DEFAULT(0)	,
			[ID_REFERENCIA_CLIENT]	   [INT]			NULL		DEFAULT(0)	,
			[RETORNO]				   [VARCHAR](250)	NULL					,
			[INDICA_CARTAO_CONCILIADO] [INT]			NULL		DEFAULT(0)	,
			[CSTAT] 				   [CHAR](5)		NULL					,
			[ID_PAGAMENTO_FINAL]       [INT]			NULL		DEFAULT(0)	,
			[PENDENTE]                 [INT]			NULL		DEFAULT(0)	,
			[ID_REFERENCIA_CLIENT_INICIAL] [INT]		NULL		DEFAULT(0)	,
			[DATA_PARA_TRANSFERENCIA] [DATETIME]		NULL		DEFAULT(GETDATE())
		CONSTRAINT [XPKLOJA_VENDA_PARCELAS_MFE] PRIMARY KEY CLUSTERED 
		(
			[TERMINAL] ASC,
			[LANCAMENTO_CAIXA] ASC,
			[CODIGO_FILIAL] ASC,
			[PARCELA] ASC
		)
		) ON [PRIMARY]
	END