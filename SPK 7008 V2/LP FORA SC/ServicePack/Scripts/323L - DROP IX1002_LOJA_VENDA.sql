if exists (SELECT * FROM sysindexes WHERE name='IX1002_LOJA_VENDA' AND id = object_id('LOJA_VENDA'))
	DROP INDEX IX1002_LOJA_VENDA ON [dbo].[LOJA_VENDA]

