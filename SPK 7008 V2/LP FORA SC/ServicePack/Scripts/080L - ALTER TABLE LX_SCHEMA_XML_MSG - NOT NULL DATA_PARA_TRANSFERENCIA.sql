IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LX_SCHEMA_XML_MSG' AND COLUMN_NAME = 'DATA_PARA_TRANSFERENCIA')
	IF (SELECT COUNT(*) FROM LX_SCHEMA_XML_MSG) > 0 
		BEGIN
			SELECT * INTO #LX_SCHEMA_XML_MSG_TEMP FROM LX_SCHEMA_XML_MSG
			DELETE FROM LX_SCHEMA_XML_MSG
			UPDATE #LX_SCHEMA_XML_MSG_TEMP SET DATA_PARA_TRANSFERENCIA = GETDATE()
			ALTER TABLE LX_SCHEMA_XML_MSG ALTER COLUMN DATA_PARA_TRANSFERENCIA DATETIME NOT NULL
			INSERT INTO LX_SCHEMA_XML_MSG SELECT * FROM #LX_SCHEMA_XML_MSG_TEMP
			DROP TABLE #LX_SCHEMA_XML_MSG_TEMP
		END
	ELSE
		BEGIN
			ALTER TABLE LX_SCHEMA_XML_MSG ALTER COLUMN DATA_PARA_TRANSFERENCIA DATETIME NOT NULL
		END
	