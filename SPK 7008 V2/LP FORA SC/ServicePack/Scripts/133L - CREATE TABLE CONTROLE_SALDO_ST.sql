
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CONTROLE_SALDO_ST]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CONTROLE_SALDO_ST](
	[ID] [int] NOT NULL,
	[FILIAL] [varchar](25) NOT NULL,
	[ITEM] [char](12) NOT NULL,
	[COR_ITEM] [char](10) NOT NULL,
	[TAMANHO] [varchar](8) NOT NULL,
	[ID_IMPOSTO] [tinyint] NOT NULL,
	[QTDE_TOTAL] [int] NOT NULL,
	[BASE_IMPOSTO] [numeric](14, 2) NOT NULL,
	[MEDIA_BASE_IMPOSTO] [numeric](14, 2) NOT NULL,
	[DATA_FECHAMENTO] [datetime] NULL,
	[DATA_REPROCESSADO] [datetime] NULL,
	[COD_TABELA_FILHA] [char](1) NOT NULL,
	[AJUSTE_MANUAL] [bit] NOT NULL,
	[BASE_IMPOSTO_ULT_NOTA] [numeric](14, 2) NULL,
	[DATA_PARA_TRANSFERENCIA] [datetime] NULL
 CONSTRAINT [XPKCONTROLE_SALDO_ST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
) ON [PRIMARY]
END


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[XFK10001_CONTROLE_SALDO_ST]') AND parent_object_id = OBJECT_ID(N'[dbo].[CONTROLE_SALDO_ST]'))
ALTER TABLE [dbo].[CONTROLE_SALDO_ST]  WITH NOCHECK ADD  CONSTRAINT [XFK10001_CONTROLE_SALDO_ST] FOREIGN KEY([FILIAL])
REFERENCES [dbo].[FILIAIS] ([FILIAL])


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[XFK10001_CONTROLE_SALDO_ST]') AND parent_object_id = OBJECT_ID(N'[dbo].[CONTROLE_SALDO_ST]'))
ALTER TABLE [dbo].[CONTROLE_SALDO_ST] CHECK CONSTRAINT [XFK10001_CONTROLE_SALDO_ST]


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[XFK10002_CONTROLE_SALDO_ST]') AND parent_object_id = OBJECT_ID(N'[dbo].[CONTROLE_SALDO_ST]'))
ALTER TABLE [dbo].[CONTROLE_SALDO_ST] CHECK CONSTRAINT [XFK10002_CONTROLE_SALDO_ST]



