IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRG_INSERT_PARAMETRO]'))
DROP TRIGGER [dbo].[TRG_INSERT_PARAMETRO]