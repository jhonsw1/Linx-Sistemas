IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME = 'FX_RETORNA_DATAS_FISCAIS_BLOCOX')
	BEGIN
		DROP FUNCTION [DBO].[FX_RETORNA_DATAS_FISCAIS_BLOCOX]
	END