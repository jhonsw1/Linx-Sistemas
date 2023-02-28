EXEC('
IF EXISTS( SELECT 1 FROM SYS.triggers WHERE NAME =  ''TRIU_LJ_ETL_TIPO_COMPONENTE'')
BEGIN
	DROP TRIGGER TRIU_LJ_ETL_TIPO_COMPONENTE
END')

EXEC('
IF EXISTS( SELECT 1 FROM SYS.triggers WHERE NAME =  ''TRIU_LJ_LX_ETL_TIPO'')
BEGIN
	DROP TRIGGER TRIU_LJ_LX_ETL_TIPO
END')

EXEC('
CREATE TRIGGER [dbo].[TRIU_LJ_ETL_TIPO_COMPONENTE]
ON [dbo].[LJ_ETL_TIPO_COMPONENTE]
INSTEAD OF UPDATE
AS
	UPDATE [LJ_ETL_TIPO_COMPONENTE]
	SET INATIVO = 0
	FROM INSERTED 
	INNER JOIN [LJ_ETL_TIPO_COMPONENTE] ON INSERTED.ID_ETL_TIPO = LJ_ETL_TIPO_COMPONENTE.ID_ETL_TIPO 
	WHERE INSERTED.ID_ETL_TIPO >= 9000
')

EXEC('CREATE TRIGGER [dbo].[TRIU_LJ_LX_ETL_TIPO]
ON [dbo].[LJ_LX_ETL_TIPO]
INSTEAD OF UPDATE
AS
	UPDATE [LJ_LX_ETL_TIPO]
	SET INATIVO = 0
	FROM INSERTED 
	INNER JOIN [LJ_LX_ETL_TIPO] ON INSERTED.ID_ETL_TIPO = [LJ_LX_ETL_TIPO].ID_ETL_TIPO 
	WHERE INSERTED.ID_ETL_TIPO >= 9000
')	 
 