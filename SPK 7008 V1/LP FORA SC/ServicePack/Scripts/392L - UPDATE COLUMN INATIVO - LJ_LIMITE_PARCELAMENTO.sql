IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LJ_LIMITE_PARCELAMENTO' AND COLUMN_NAME = 'INATIVO')
	AND EXISTS(SELECT TOP 1 1 FROM LJ_LIMITE_PARCELAMENTO WHERE INATIVO IS NULL)
BEGIN
       UPDATE LJ_LIMITE_PARCELAMENTO SET INATIVO = 0
END