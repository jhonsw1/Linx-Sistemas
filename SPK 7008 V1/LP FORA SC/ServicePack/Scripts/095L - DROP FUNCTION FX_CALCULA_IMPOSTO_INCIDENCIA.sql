IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME = 'FX_CALCULA_IMPOSTO_INCIDENCIA')
	BEGIN
		DROP FUNCTION dbo.FX_CALCULA_IMPOSTO_INCIDENCIA
	END


