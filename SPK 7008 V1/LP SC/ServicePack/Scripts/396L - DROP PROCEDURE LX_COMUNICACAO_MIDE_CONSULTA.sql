IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'LX_COMUNICACAO_MIDE_CONSULTA') BEGIN
	DROP PROCEDURE [dbo].[LX_COMUNICACAO_MIDE_CONSULTA]
END