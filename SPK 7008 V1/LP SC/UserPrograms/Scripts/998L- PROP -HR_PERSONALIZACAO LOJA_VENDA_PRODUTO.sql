IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='LOJA_VENDA_PRODUTO' AND COLUMN_NAME='HR_PERSONALIZACAO')
ALTER TABLE LOJA_VENDA_PRODUTO ADD HR_PERSONALIZACAO VARCHAR(30)