IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'function' AND ROUTINE_NAME = 'LX_LJ_CALCULA_DATA_VENCTO')
	DROP function [dbo].[LX_LJ_CALCULA_DATA_VENCTO]