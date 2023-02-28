IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'LOJA_PEDIDO'
                      AND COLUMN_NAME = 'OBSERVACOES')
  ALTER TABLE [dbo].[LOJA_PEDIDO]
    ADD OBSERVACOES TEXT NULL 
