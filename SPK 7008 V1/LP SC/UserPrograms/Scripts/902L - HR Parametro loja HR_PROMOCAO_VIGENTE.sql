IF NOT EXISTS(SELECT 1 FROM PARAMETROS_LOJA WHERE PARAMETRO = 'HR_PROMOCAO_VIGENTE') 		
BEGIN
INSERT INTO PARAMETROS_LOJA(PARAMETRO,CODIGO_FILIAL,VALOR_ATUAL,PERMITE_ALTERAR_NA_LOJA,DATA_PARA_TRANSFERENCIA)
SELECT TOP 1 'HR_PROMOCAO_VIGENTE',CODIGO_FILIAL,'QUANTO MAIS BASICO MELHOR',1,GETDATE() FROM LOJA_VENDA 
END
