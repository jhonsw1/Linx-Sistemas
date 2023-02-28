IF NOT EXISTS (SELECT 1 FROM SYS.COLUMNS WHERE NAME = 'CSTAT' AND OBJECT_ID = OBJECT_ID('LOJA_VENDA_PARCELAS_MFE'))
	BEGIN 
		ALTER TABLE [DBO].[LOJA_VENDA_PARCELAS_MFE] ADD CSTAT CHAR(5) 		
	END;

IF NOT EXISTS (SELECT 1 FROM SYS.COLUMNS WHERE NAME = 'ID_PAGAMENTO_FINAL' AND OBJECT_ID = OBJECT_ID('LOJA_VENDA_PARCELAS_MFE'))
	BEGIN 
		ALTER TABLE [DBO].[LOJA_VENDA_PARCELAS_MFE] ADD ID_PAGAMENTO_FINAL INT DEFAULT(0)		
	END; 

IF NOT EXISTS (SELECT 1 FROM SYS.COLUMNS WHERE NAME = 'PENDENTE' AND OBJECT_ID = OBJECT_ID('LOJA_VENDA_PARCELAS_MFE'))
	BEGIN 
		ALTER TABLE [DBO].[LOJA_VENDA_PARCELAS_MFE] ADD PENDENTE INT DEFAULT(0)		
	END; 

IF NOT EXISTS (SELECT 1 FROM SYS.COLUMNS WHERE NAME = 'ID_REFERENCIA_CLIENT_INICIAL' AND OBJECT_ID = OBJECT_ID('LOJA_VENDA_PARCELAS_MFE'))
	BEGIN 
		ALTER TABLE [DBO].[LOJA_VENDA_PARCELAS_MFE] ADD ID_REFERENCIA_CLIENT_INICIAL INT DEFAULT(0)		
	END; 