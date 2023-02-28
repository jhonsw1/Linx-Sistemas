IF not exists ( select 1 from sys.tables where name ='HR_LOJA_MOTIVOS_TROCAS')
	begin
		exec('

			CREATE TABLE [dbo].[HR_LOJA_MOTIVOS_TROCAS](
				[MOTIVO_TROCA] [smallint] NOT NULL,
				[DESC_MOTIVO] [varchar](50) NOT NULL,
				[DATA_PARA_TRANSFERENCIA] [datetime] NULL,
				[INATIVO] [bit] NULL,
			 CONSTRAINT [XPKHR_LOJA_MOTIVOS_TROCAS] PRIMARY KEY NONCLUSTERED 
			(
				[MOTIVO_TROCA] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]
			')
	end
