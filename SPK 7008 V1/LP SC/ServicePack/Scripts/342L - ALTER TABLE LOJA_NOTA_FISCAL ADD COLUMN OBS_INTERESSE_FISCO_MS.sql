IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_NOTA_FISCAL' AND COLUMN_NAME = 'OBS_INTERESSE_FISCO_MS'  )
	ALTER TABLE LOJA_NOTA_FISCAL ADD OBS_INTERESSE_FISCO_MS varchar(200) NULL



	