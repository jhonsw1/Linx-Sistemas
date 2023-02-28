
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_PEDIDO_ENTREGA' AND COLUMN_NAME = 'VALOR_TOTAL')
BEGIN
       ALTER TABLE LOJA_PEDIDO_ENTREGA ADD VALOR_TOTAL NUMERIC(14, 2) NULL
       
END
