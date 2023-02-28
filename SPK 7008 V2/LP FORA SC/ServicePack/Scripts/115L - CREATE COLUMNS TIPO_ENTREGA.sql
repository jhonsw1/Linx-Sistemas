
/**************************
* LOJA_PEDIDO.TIPO_ENTREGA* 
* 1 = reserve in store    *
* 2 = pick-up in store    *
* 3 = ship from store     *
* 4 = ship to store       *
**************************/

IF NOT EXISTS (SELECT 1
               FROM   INFORMATION_SCHEMA.COLUMNS
               WHERE  TABLE_NAME = 'LOJA_PEDIDO'
                      AND COLUMN_NAME = 'TIPO_ENTREGA')
  ALTER TABLE [dbo].[LOJA_PEDIDO]
    ADD TIPO_ENTREGA TINYINT 
