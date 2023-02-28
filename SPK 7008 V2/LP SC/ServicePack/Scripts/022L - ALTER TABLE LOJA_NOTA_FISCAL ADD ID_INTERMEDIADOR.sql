-- POSSP-5157  - Gilvano Santos - (31/03/2021) - Nota Técnica 2020.006
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_NOTA_FISCAL' AND COLUMN_NAME = 'ID_INTERMEDIADOR')
BEGIN
       ALTER TABLE LOJA_NOTA_FISCAL ADD ID_INTERMEDIADOR int NULL
END

IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_NOTA_FISCAL' AND COLUMN_NAME = 'PGTO_INTERMEDIADOR')
BEGIN
       ALTER TABLE LOJA_NOTA_FISCAL ADD PGTO_INTERMEDIADOR BIT DEFAULT(0)
END