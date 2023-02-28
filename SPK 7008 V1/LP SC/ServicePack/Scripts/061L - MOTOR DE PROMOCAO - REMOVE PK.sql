if object_id('XPKLOJA_VENDA_PROMOCAO') is not null 
	AND NOT EXISTS ( Select 1 from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE where constraint_name = 'XPKLOJA_VENDA_PROMOCAO' AND COLUMN_NAME = 'ITEM')
BEGIN
	ALTER TABLE [dbo].[LOJA_VENDA_PROMOCAO] DROP CONSTRAINT [XPKLOJA_VENDA_PROMOCAO] 
END;

if object_id('XPKLOJA_VENDA_PROMOCAO_CUPOM') is not null
	AND NOT EXISTS ( Select 1 from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE where constraint_name = 'XPKLOJA_VENDA_PROMOCAO_CUPOM' AND COLUMN_NAME = 'DATA_VENDA')
BEGIN
	ALTER TABLE [dbo].[LOJA_VENDA_PROMOCAO_CUPOM] DROP CONSTRAINT [XPKLOJA_VENDA_PROMOCAO_CUPOM] 
END;