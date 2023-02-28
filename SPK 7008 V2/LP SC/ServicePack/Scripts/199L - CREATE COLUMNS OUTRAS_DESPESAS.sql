IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'LOJA_PEDIDO'
                      AND COLUMN_NAME = 'OUTRAS_DESPESAS')
  ALTER TABLE [dbo].[LOJA_PEDIDO]
    ADD OUTRAS_DESPESAS NUMERIC(14,2) NULL 

	
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'LOJA_PEDIDO'
                      AND COLUMN_NAME = 'OUTRAS_DESPESAS_ITENS')
  ALTER TABLE [dbo].[LOJA_PEDIDO]
    ADD OUTRAS_DESPESAS_ITENS NUMERIC(14,2) NULL 	
	
	
IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'LOJA_PEDIDO_PRODUTO'
                      AND COLUMN_NAME = 'OUTRAS_DESPESAS')
  ALTER TABLE [dbo].[LOJA_PEDIDO_PRODUTO]
    ADD OUTRAS_DESPESAS NUMERIC(14,2) NULL 	