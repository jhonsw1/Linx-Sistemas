IF NOT EXISTS(	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_MOTIVOS_DESCONTO' AND COLUMN_NAME = 'INATIVO')
	ALTER TABLE DBO.LOJA_MOTIVOS_DESCONTO	ADD INATIVO BIT