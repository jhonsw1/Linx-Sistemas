IF NOT EXISTS(	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME = 'CTB_EXCECAO_IMPOSTO_ITEM' AND COLUMN_NAME = 'SUB_ITEM_SPED' )
	ALTER TABLE CTB_EXCECAO_IMPOSTO_ITEM ADD SUB_ITEM_SPED VARCHAR(10) NULL