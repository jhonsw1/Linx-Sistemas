CREATE FUNCTION [DBO].[FX_OMS_PEDIDO_CREDITO](@CODIGO_FILIAL CHAR(6), @PEDIDO INT)  

-- 07/06/2021 - ANDR� ARTUZO - POSSP-5648 - AJUSTE PARA UTILIZAR PRODUTO + Separador + COR + GRADE
-- 08/05/2020 - ANDR� ARTUZO - POSSP-2948 - AJUSTE PARA UTILIZAR PRODUTO + Separador + COR + TAMANHO
-- 21/11/2019 - ANDR� ARTUZO - MODASP-8231 - AJUSTE PARA UTILIZAR PRODUTO + COR + GRADE E MELHORIA NO DESEMPENHO.
-- 14/08/2019 - ANDR� ARTUZO - CORRE��O PARA TRATAR OS PARAMETROS OMS_SHW_SEPARADOR_SKU E OMS_SHW_SEPARADOR_SKU_COR PARA MONTAR O SKU.
-- 01/07/2019 - ANDR� ARTUZO -  MODASP-3379 - #8# - MELHORIA PARA PODER ENVIAR O EAN COMO SKU E AJUSTE PARA ENVIAR OS NOVOS TIPOS DE PAGAMENTO.  
-- 27/02/2018 - MAYDSON HEDLUND -   "LINX OMS" - #7# - MELHORIA PARA CONSULTAR VALOR DE CR�DITO DO CLIENTE REFERENTE A TROCA DO PEDIDO DO TIPO PICK-UP.  
-- 26/10/2017 - MAYDSON HEDLUND -   "LINX OMS" - #6# - COMENTADO #4# - PARA N�O RATEAR NOS ITENS O DESCONTO DO SUBTOTAL DO PEDIDO.  
-- 26/10/2017 - MAYDSON HEDLUND -   "LINX OMS" - #5# - TRATAMENTO PARA UTILIZAR ITEM DA TROCA PICK-UP COMO PARTE DO PAGAMENTO DE ITEM ADICIONAL DE VENDA PARA CALCULAR VALOR DO CR�DITO.  
-- 23/10/2017 - MAYDSON HEDLUND E ROBERTO BEDA - "LINX OMS" - #4# - TRATAMENTO DO DESCONTO NO SUBTOTAL DO PEDIDO.  
-- 11/10/2017 - MAYDSON HEDLUND - "LINX OMS" - #3# - ALTERA��O PARA INDICAR O TIPO DE PAGAMENTO UTILIZADO AO SER GERADO O CR�DITO.  
-- 06/10/2017 - MAYDSON HEDLUND - "LINX OMS" - #2# - ALTERA��O NO C�LCULO DA QUANTIDADE DE TROCA/DEVOLU��O.  
-- 05/10/2017 - MAYDSON HEDLUND - "LINX OMS" - #1# - ALTERA��O PARA CONTEMPLAR ITENS DE TROCA E VALOR DE CR�DITO PARA PEDIDOS RESERVE E PICK-UP  
  
RETURNS @CREDITO TABLE(     
                        PEDIDO               INT,           -- #1#    
                        CODIGO_FILIAL_ORIGEM VARCHAR(6),    -- #1#    
                        ID_PEDIDO_ORIGEM     VARCHAR(20),   -- #1#    
                        ID_ENTREGA_ORIGEM    VARCHAR(20),   -- #1#    
                        TIPO_ENTREGA         INT,           -- #1#    
                        VALOR_CREDITO        NUMERIC(14,2), -- #1#    
                        SKU                  VARCHAR(50),   -- #1#    
                        QTDE                 INT,           -- #1#    
                        GERA_CREDITO_OMS     INT    
                       )    
    
BEGIN    

	  DECLARE @PARAMETROS TABLE(
								PARAMETRO  VARCHAR(25),
								VALOR_ATUAL VARCHAR(100)
								)

	  INSERT INTO @PARAMETROS
			SELECT LTRIM(RTRIM(PARAMETRO)) , UPPER(LTRIM(RTRIM(ISNULL(VALOR_ATUAL,'')))) 
			FROM PARAMETROS
			WHERE PARAMETRO IN ('OMS_CONSULTA_SKU','OMS_SHW_SEPARADOR_SKU','OMS_SHW_SEPARADOR_SKU_COR','OMS_SKU_COMPOSICAO')
      
 INSERT INTO @CREDITO    
 SELECT LOJA_PEDIDO.PEDIDO,    
     LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM,    
     LOJA_PEDIDO.ID_PEDIDO_ORIGEM,    
     LOJA_PEDIDO.ID_ENTREGA_ORIGEM,    
     LOJA_PEDIDO.TIPO_ENTREGA,    
     SUM(ABS(LOJA_VENDA_PARCELAS.VALOR)) AS VALOR_CREDITO,    
  CASE       
          WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_CONSULTA_SKU') ='.F.'    --#8#  
    THEN   MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.CODIGO_BARRA))))  
		 WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU') <> '' AND (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU_COR') = '+'
	THEN
	MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +  (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(REPLACE(PRODUTOS_BARRA.COR_PRODUTO,' ', '+'))))) +     (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.TAMANHO))))
	WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU') <> '' AND (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SKU_COMPOSICAO') ='1'
	THEN
	MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +  (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.COR_PRODUTO)))) +     (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.TAMANHO))))
	WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU') <> '' AND (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SKU_COMPOSICAO') ='2'
	THEN
	MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +  (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.COR_PRODUTO)))) +     (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.GRADE))))
	WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU') <> '' AND (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SKU_COMPOSICAO') ='3'
	THEN
	MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +  (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.COR_PRODUTO)))) +
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.TAMANHO))))
	WHEN (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU') <> '' AND (SELECT VALOR_ATUAL FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SKU_COMPOSICAO') ='4'
	THEN
	MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +  (SELECT LTRIM(RTRIM(VALOR_ATUAL)) FROM @PARAMETROS WHERE PARAMETRO = 'OMS_SHW_SEPARADOR_SKU')  + 
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.COR_PRODUTO)))) +  
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.GRADE))))
	ELSE    
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.PRODUTO)))) +     
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.COR_PRODUTO)))) +     
    MAX(CONVERT(VARCHAR(MAX),LTRIM(RTRIM(PRODUTOS_BARRA.TAMANHO))))   
    END AS SKU,    
     SUM(LOJA_VENDA_TROCA.QTDE),    
     1 AS GERA_CREDITO_OMS    
   FROM LOJA_PEDIDO LOJA_PEDIDO (NOLOCK)    
  INNER JOIN (SELECT TICKET, CODIGO_FILIAL, DATA_VENDA, CODIGO_FILIAL_ORIGEM, PEDIDO    
       FROM LOJA_PEDIDO_VENDA LOJA_PEDIDO_VENDA (NOLOCK)    
      GROUP BY TICKET, CODIGO_FILIAL, DATA_VENDA, CODIGO_FILIAL_ORIGEM, PEDIDO    
    ) AS LOJA_PEDIDO_VENDA    
  ON LOJA_PEDIDO_VENDA.PEDIDO = LOJA_PEDIDO.PEDIDO    
    AND LOJA_PEDIDO_VENDA.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM    
  INNER JOIN LOJA_VENDA LOJA_VENDA (NOLOCK)    
  ON LOJA_VENDA.DATA_VENDA = LOJA_PEDIDO_VENDA.DATA_VENDA    
    AND LOJA_VENDA.CODIGO_FILIAL = LOJA_PEDIDO_VENDA.CODIGO_FILIAL    
    AND LOJA_VENDA.TICKET = LOJA_PEDIDO_VENDA.TICKET    
  INNER JOIN LOJA_VENDA_PARCELAS LOJA_VENDA_PARCELAS (NOLOCK)    
  ON LOJA_VENDA_PARCELAS.TERMINAL  = LOJA_VENDA.TERMINAL    
    AND LOJA_VENDA_PARCELAS.LANCAMENTO_CAIXA = LOJA_VENDA.LANCAMENTO_CAIXA    
    AND LOJA_VENDA_PARCELAS.CODIGO_FILIAL = LOJA_VENDA.CODIGO_FILIAL        
  INNER JOIN LOJA_VENDA_TROCA LOJA_VENDA_TROCA (NOLOCK)    
  ON LOJA_VENDA_TROCA.TICKET = LOJA_VENDA.TICKET    
    AND LOJA_VENDA_TROCA.CODIGO_FILIAL = LOJA_VENDA.CODIGO_FILIAL    
    AND LOJA_VENDA_TROCA.DATA_VENDA = LOJA_VENDA.DATA_VENDA    
  INNER JOIN PRODUTOS_BARRA PRODUTOS_BARRA (NOLOCK)    
  ON PRODUTOS_BARRA.CODIGO_BARRA = LOJA_VENDA_TROCA.CODIGO_BARRA    
  WHERE LOJA_PEDIDO.PEDIDO = @PEDIDO    
    AND LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL    
    AND LOJA_VENDA_TROCA.QTDE_CANCELADA = 0    
    AND ISNULL(LOJA_VENDA_TROCA.ORIGEM_OMS,0) = 1    
    AND LOJA_VENDA_PARCELAS.TIPO_PGTO IN('Y','W')  --#8#  
    AND SIGN(VALOR) = -1    
 GROUP BY LOJA_PEDIDO.PEDIDO,LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM,    
     LOJA_PEDIDO.ID_PEDIDO_ORIGEM,    
     LOJA_PEDIDO.ID_ENTREGA_ORIGEM,    
     LOJA_PEDIDO.TIPO_ENTREGA    
  
    
 RETURN    
END