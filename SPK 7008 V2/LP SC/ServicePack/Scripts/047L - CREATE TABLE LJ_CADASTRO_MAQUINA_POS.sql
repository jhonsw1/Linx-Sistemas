IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LJ_CADASTRO_MAQUINA_POS')
CREATE TABLE [dbo].[LJ_CADASTRO_MAQUINA_POS](
	[CODIGO_FILIAL]			[char](6) NOT NULL,
	[NUMERO_DE_SERIE]		[varchar](18) NOT NULL,
	[DESCRICAO]				[varchar](30) NOT NULL,
	[DATA_PARA_TRANSFERENCIA] [datetime] NULL DEFAULT ('DATA_ATUAL')
 CONSTRAINT [XPKLJ_CADASTRO_MAQUINA_POS] PRIMARY KEY NONCLUSTERED 
(
	[CODIGO_FILIAL] ASC,
	[NUMERO_DE_SERIE] ASC
)
) ON [PRIMARY]
