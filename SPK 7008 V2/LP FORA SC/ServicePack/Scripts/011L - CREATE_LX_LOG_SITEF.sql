IF NOT EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[LX_LOG_SITEF]') AND TYPE IN (N'U'))
BEGIN
	CREATE TABLE [DBO].[LX_LOG_SITEF](
		[ID_LOG_SITEF] [int] IDENTITY(1,1) NOT NULL,
		[CODIGO_FILIAL]		[CHAR](6) NOT NULL,
		[FILIAL]			[VARCHAR] (25) NULL,
		[TERMINAL]			[CHAR] (3) NULL,
		[VENDEDOR_APELIDO]	[VARCHAR] (25) NULL,
		[TICKET]			[CHAR] (8) NULL,
		[DATA_HORA]			[DATETIME] NOT NULL,
		[RETORNO_SITEF]		[VARCHAR] (200) NULL,
		[MENSAGEM_TEF]		[VARCHAR] (200) NULL,
		[ERRO_SITEF]		[VARCHAR] (200) NULL
		)
END;

-- ADD PK
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'XPKLX_LOG_SITEF' AND type = 'PK')
ALTER TABLE [dbo].[LX_LOG_SITEF] ADD 
   CONSTRAINT [XPKLX_LOG_SITEF] PRIMARY KEY  CLUSTERED  ( [ID_LOG_SITEF] )  ON [PRIMARY] 





