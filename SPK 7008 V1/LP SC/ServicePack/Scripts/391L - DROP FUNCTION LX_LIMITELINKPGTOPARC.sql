IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'function' AND ROUTINE_NAME = 'LX_LIMITELINKPGTOPARC')
	DROP function [dbo].[LX_LIMITELINKPGTOPARC]