if exists (SELECT * FROM sysindexes WHERE name='IX1003_LOJA_VENDA_PARCELAS' AND id = object_id('LOJA_VENDA_PARCELAS'))
	DROP INDEX IX1003_LOJA_VENDA_PARCELAS ON [dbo].[LOJA_VENDA_PARCELAS]
