IF NOT EXISTS ( SELECT 1 FROM SYS.OBJECTS WHERE NAME ='XFK14683_LOJA_VENDA_TROCA')
	BEGIN 
		EXEC('
			ALTER TABLE [dbo].[LOJA_VENDA_TROCA]  WITH NOCHECK ADD  CONSTRAINT [XFK14683_LOJA_VENDA_TROCA] FOREIGN KEY([MOTIVO_TROCA])
			REFERENCES [dbo].[HR_LOJA_MOTIVOS_TROCAS] ([MOTIVO_TROCA])
			

			ALTER TABLE [dbo].[LOJA_VENDA_TROCA] CHECK CONSTRAINT [XFK14683_LOJA_VENDA_TROCA]')
	END