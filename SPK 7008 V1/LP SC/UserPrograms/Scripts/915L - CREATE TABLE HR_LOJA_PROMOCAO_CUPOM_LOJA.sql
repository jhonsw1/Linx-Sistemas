if not exists (SELECT
		*
	FROM sys.objects
	WHERE name = 'HR_LOJA_PROMOCAO_CUPOM_LOJA')
CREATE TABLE [dbo].[HR_LOJA_PROMOCAO_CUPOM_LOJA](
	[ID_PROMOCAO] [int] NOT NULL,
	[CODIGO_FILIAL] [varchar](6) NOT NULL,
	[CODIGO] [varchar](30) NOT NULL,
	[DATA] [datetime] NULL,
	[TICKET] [varchar](8),
 CONSTRAINT [XPKHR_LOJA_PROMOCAO_CUPOM_LOJA] PRIMARY KEY CLUSTERED 
(
	[ID_PROMOCAO] ASC,
	[CODIGO_FILIAL] ASC,
	[CODIGO] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]