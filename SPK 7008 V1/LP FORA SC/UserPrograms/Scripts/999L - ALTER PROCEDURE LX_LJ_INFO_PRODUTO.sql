ALTER PROCEDURE [dbo].[LX_LJ_INFO_PRODUTO] (@CODIGO_BARRA VARCHAR(25), @CODIGO_TAB_PRECO VARCHAR(2), @FILIAL VARCHAR(25), @PESQUISA_FOTO BIT)    
-- 15/05/2018 - Marcio tratamento do estoque para int para �o gerar problema no mobile
-- 09/04/2018 - Diego Moreno -  #2# - �rvore mercadol�gica do Linx Mobile.
-- 29/11/2013 - Diego Camargo - TP 4598975 - #1# - Adicionado a coluna Montagem Kit para se utilizada ao desmembrar o kit.
-- #2# 05/09/2014 - Victor Kajiyama - TP 5829698 - Incluindo campo para que o valor seja usado em valida��o no Visual FoxPro.  
-- #3# 19/03/2015 - Giedson Silva - TP 8080015 - Incluindo campo FIM_VENDA na segunda query para que o valor seja usado em valida��o no Visual FoxPro.
-- #4# 15/06/2015 - Gerson Prado - TP8279508 - Programa��o do LinxPOS para o PAF-ECF 2015 - Inclus�o do campo ARREDONDA da tabela de produtos
-- #5# 06/07/2015 - Gerson Prado - TP8279508 - Programa��o do LinxPOS para o PAF-ECF 2015 - Otimiza��o da procedure para trazer o produto considerando o GTIN. 
-- #6# 28/04/2016 - Giedson Silva - Sem Demanda - Altera��o para considerar o CEST e NCM no Cupom Fiscal.
-- #7# 03/05/2016 - Giedson Silva - ID2609 - Altera��o no relacionamento entre as tabelas:  CEST_NCM e TABELA_LX_NCM.
-- #8# 04/05/2016 - Giedson Silva - ID2634 - Altera��o CEST/NCM conforme nova documenta��o reformulando v�nculo para busca das informa��es NCM e CEST.
AS    
BEGIN    
 SET NOCOUNT ON    
     
 IF EXISTS(SELECT 1 FROM W_LJ_PRECO_PRODUTO_BARRA_FILIAL WHERE FILIAL = @FILIAL AND CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO AND CODIGO_BARRA = @CODIGO_BARRA)    
  SELECT    
   A.PRODUTO, A.DESC_PROD_NF, A.UNIDADE, A.VARIA_PRECO_COR, A.VARIA_PRECO_TAM, A.PESO, A.INATIVO,     
   A.PONTEIRO_PRECO_TAM, B.COR_PRODUTO, B.DESC_COR_PRODUTO, C.TAMANHO, C.GRADE,     
   D.CLASSIF_FISCAL, D.CLASSIF_REDUZIDA, A.TRIBUT_ICMS, ISNULL(B.TRIBUT_ORIGEM, A.TRIBUT_ORIGEM) AS TRIBUT_ORIGEM,      
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 2, D.IPI, A.PRODUTO) AS IPI,     
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 1, NULL, A.PRODUTO) AS ALIQUOTA,     
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 14, -10, A.PRODUTO) AS ISS,     
   E.PRECO, E.PRECO_LIQUIDO, E.LIMITE_DESCONTO, E.PROMOCAO_DESCONTO, E.INICIO_PROMOCAO, E.FIM_PROMOCAO,
   CASE WHEN B.FIM_VENDAS < GETDATE() THEN convert(bit,1) ELSE convert(bit,0) END AS FIM_VENDA,  -- #2#   
   CASE WHEN @PESQUISA_FOTO = 1 THEN ISNULL(CONTEUDO_FOTO, ISNULL(THUMBNAIL_FOTO, PATH_FOTO)) ELSE CONVERT(VARCHAR(10), '') END AS PATH_FOTO,     
   A.VARIA_CUSTO_TAM,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO1 ELSE A.CUSTO_REPOSICAO1 END AS CUSTO_REPOSICAO1,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO2 ELSE A.CUSTO_REPOSICAO2 END AS CUSTO_REPOSICAO2,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO3 ELSE A.CUSTO_REPOSICAO3 END AS CUSTO_REPOSICAO3,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO4 ELSE A.CUSTO_REPOSICAO4 END AS CUSTO_REPOSICAO4,     
   CONVERT(INT,ISNULL(CASE C.TAMANHO WHEN 1 THEN ES1 WHEN 2 THEN ES2 WHEN 3 THEN ES3 WHEN 4 THEN ES4 WHEN 5 THEN ES5 WHEN 6 THEN ES6 WHEN 7 THEN ES7    
   WHEN 8 THEN ES8 WHEN 9 THEN ES9 WHEN 10 THEN ES10 WHEN 11 THEN ES11 WHEN 12 THEN ES12 WHEN 13 THEN ES13 WHEN 14 THEN ES14 WHEN 15 THEN ES15    
   WHEN 16 THEN ES16 WHEN 17 THEN ES17 WHEN 18 THEN ES18 WHEN 19 THEN ES19 WHEN 20 THEN ES20 WHEN 21 THEN ES21 WHEN 22 THEN ES22 WHEN 23 THEN ES23    
   WHEN 24 THEN ES24 WHEN 25 THEN ES25 WHEN 26 THEN ES26 WHEN 27 THEN ES27 WHEN 28 THEN ES28 WHEN 29 THEN ES29 WHEN 30 THEN ES30 WHEN 31 THEN ES31    
   WHEN 32 THEN ES32 WHEN 33 THEN ES33 WHEN 34 THEN ES34 WHEN 35 THEN ES35 WHEN 36 THEN ES36 WHEN 37 THEN ES37 WHEN 38 THEN ES38 WHEN 39 THEN ES39    
   WHEN 40 THEN ES40 WHEN 41 THEN ES41 WHEN 42 THEN ES42 WHEN 43 THEN ES43 WHEN 44 THEN ES44 WHEN 45 THEN ES45 WHEN 46 THEN ES46 WHEN 47 THEN ES47    
   WHEN 48 THEN ES48 ELSE 0 END, 0)) AS ESTOQUE, ISNULL(I.INDICADOR_CFOP, A.INDICADOR_CFOP) AS INDICADOR_CFOP, H.DESCRICAO AS TRIBUT_ORIGEM_DESCRICAO,     
   D.DESC_CLASSIFICACAO, J.DESCRICAO_INDICADOR_CFOP, A.CONTA_CONTABIL, A.CONTA_CONTABIL_VENDA, A.CONTA_CONTABIL_DEV_VENDA,     
   A.PERMITE_ENTREGA_FUTURA , C.ID_SKU, A.ID_ARTIGO, A.MONTAGEM_KIT, A.ARREDONDA, C.CODIGO_BARRA, C.TIPO_COD_BAR, --#1# #4# #5#  
   CEST.CODIGO_CEST, ISNULL(NCM.CODIGO_NCM,SUBSTRING(REPLACE(A.CLASSIF_FISCAL,'.',''),1,8)) AS CODIGO_NCM,-- #6# #8# 
      A.GRUPO_PRODUTO AS GRUPO_PRODUTO, A.SUBGRUPO_PRODUTO AS SUBGRUPO_PRODUTO, A.COLECAO AS COLECAO--#MOBILIDADE#
  FROM     
   PRODUTOS A     
   INNER JOIN PRODUTO_CORES B ON A.PRODUTO = B.PRODUTO    
   INNER JOIN PRODUTOS_BARRA C ON A.PRODUTO = C.PRODUTO AND B.COR_PRODUTO = C.COR_PRODUTO    
   INNER JOIN CLASSIF_FISCAL D ON A.CLASSIF_FISCAL = D.CLASSIF_FISCAL    
   INNER JOIN W_LJ_PRECO_PRODUTO_BARRA_FILIAL E ON C.CODIGO_BARRA = E.CODIGO_BARRA AND E.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO AND E.FILIAL = @FILIAL     
   LEFT JOIN ESTOQUE_PRODUTOS F ON A.PRODUTO = F.PRODUTO AND B.COR_PRODUTO = F.COR_PRODUTO AND F.FILIAL = E.FILIAL     
   LEFT JOIN (SELECT A.PRODUTO, A.CONTEUDO_FOTO, A.THUMBNAIL_FOTO, A.PATH_FOTO FROM PRODUTOS_FOTO A INNER JOIN (SELECT PRODUTO, MIN(NUMERO_FOTO) AS NUMERO_FOTO FROM PRODUTOS_FOTO GROUP BY PRODUTO) B ON A.PRODUTO = B.PRODUTO AND A.NUMERO_FOTO = B.NUMERO_FOTO) G ON A.PRODUTO = G.PRODUTO     
   INNER JOIN TRIBUT_ORIGEM H ON A.TRIBUT_ORIGEM = H.TRIBUT_ORIGEM     
   LEFT JOIN PRODUTOS_INDICADOR_CFOP I ON A.PRODUTO = I.PRODUTO AND I.FILIAL = @FILIAL     
   LEFT JOIN CTB_LX_INDICADOR_CFOP J ON ISNULL(I.INDICADOR_CFOP, A.INDICADOR_CFOP) = J.INDICADOR_CFOP     
   LEFT JOIN CADASTRO_CLI_FOR K ON K.NOME_CLIFOR = @FILIAL  
   LEFT JOIN CEST_NCM CEST_NCM ON A.ID_CEST_NCM = CEST_NCM.ID --#6#
   LEFT JOIN TABELA_LX_NCM NCM ON NCM.ID = CEST_NCM.ID_NCM --#6# #7#        
   LEFT JOIN TABELA_LX_CEST CEST ON CEST.ID = CEST_NCM.ID_CEST --#6# 
  WHERE     
   C.CODIGO_BARRA = @CODIGO_BARRA
   AND C.INATIVO = 0  -- #5#  
 ELSE    
  SELECT    
   A.PRODUTO, A.DESC_PROD_NF, A.UNIDADE, A.VARIA_PRECO_COR, A.VARIA_PRECO_TAM, A.PESO, A.INATIVO,     
   A.PONTEIRO_PRECO_TAM, B.COR_PRODUTO, B.DESC_COR_PRODUTO, C.TAMANHO, C.GRADE,     
   D.CLASSIF_FISCAL, D.CLASSIF_REDUZIDA, A.TRIBUT_ICMS, ISNULL(B.TRIBUT_ORIGEM, A.TRIBUT_ORIGEM) AS TRIBUT_ORIGEM,     
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 2, D.IPI, A.PRODUTO) AS IPI,     
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 1, NULL, A.PRODUTO) AS ALIQUOTA,     
   dbo.fn_TaxException_2_00(A.CLASSIF_FISCAL, K.UF, @FILIAL, 14, -10, A.PRODUTO) AS ISS,     
   E.PRECO, E.PRECO_LIQUIDO, E.LIMITE_DESCONTO, E.PROMOCAO_DESCONTO, E.INICIO_PROMOCAO, E.FIM_PROMOCAO,     
   CASE WHEN B.FIM_VENDAS < GETDATE() THEN convert(bit,1) ELSE convert(bit,0) END AS FIM_VENDA,  -- #3#      
   CASE WHEN @PESQUISA_FOTO = 1 THEN ISNULL(CONTEUDO_FOTO, ISNULL(THUMBNAIL_FOTO, PATH_FOTO)) ELSE CONVERT(VARCHAR(10), '') END AS PATH_FOTO,     
   A.VARIA_CUSTO_TAM,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO1 ELSE A.CUSTO_REPOSICAO1 END AS CUSTO_REPOSICAO1,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO2 ELSE A.CUSTO_REPOSICAO2 END AS CUSTO_REPOSICAO2,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO3 ELSE A.CUSTO_REPOSICAO3 END AS CUSTO_REPOSICAO3,     
   CASE A.VARIA_CUSTO_COR WHEN 1 THEN B.CUSTO_REPOSICAO4 ELSE A.CUSTO_REPOSICAO4 END AS CUSTO_REPOSICAO4,     
   convert(int,ISNULL(CASE C.TAMANHO WHEN 1 THEN ES1 WHEN 2 THEN ES2 WHEN 3 THEN ES3 WHEN 4 THEN ES4 WHEN 5 THEN ES5 WHEN 6 THEN ES6 WHEN 7 THEN ES7    
   WHEN 8 THEN ES8 WHEN 9 THEN ES9 WHEN 10 THEN ES10 WHEN 11 THEN ES11 WHEN 12 THEN ES12 WHEN 13 THEN ES13 WHEN 14 THEN ES14 WHEN 15 THEN ES15    
   WHEN 16 THEN ES16 WHEN 17 THEN ES17 WHEN 18 THEN ES18 WHEN 19 THEN ES19 WHEN 20 THEN ES20 WHEN 21 THEN ES21 WHEN 22 THEN ES22 WHEN 23 THEN ES23    
   WHEN 24 THEN ES24 WHEN 25 THEN ES25 WHEN 26 THEN ES26 WHEN 27 THEN ES27 WHEN 28 THEN ES28 WHEN 29 THEN ES29 WHEN 30 THEN ES30 WHEN 31 THEN ES31    
   WHEN 32 THEN ES32 WHEN 33 THEN ES33 WHEN 34 THEN ES34 WHEN 35 THEN ES35 WHEN 36 THEN ES36 WHEN 37 THEN ES37 WHEN 38 THEN ES38 WHEN 39 THEN ES39    
   WHEN 40 THEN ES40 WHEN 41 THEN ES41 WHEN 42 THEN ES42 WHEN 43 THEN ES43 WHEN 44 THEN ES44 WHEN 45 THEN ES45 WHEN 46 THEN ES46 WHEN 47 THEN ES47    
   WHEN 48 THEN ES48 ELSE 0 END, 0)) AS ESTOQUE, ISNULL(I.INDICADOR_CFOP, A.INDICADOR_CFOP) AS INDICADOR_CFOP, H.DESCRICAO AS TRIBUT_ORIGEM_DESCRICAO,     
   D.DESC_CLASSIFICACAO, J.DESCRICAO_INDICADOR_CFOP, A.CONTA_CONTABIL, A.CONTA_CONTABIL_VENDA, A.CONTA_CONTABIL_DEV_VENDA,     
   A.PERMITE_ENTREGA_FUTURA, C.ID_SKU, A.ID_ARTIGO, A.MONTAGEM_KIT, A.ARREDONDA, C.CODIGO_BARRA, C.TIPO_COD_BAR, --#1# #4# #5#       
   CEST.CODIGO_CEST,  ISNULL(NCM.CODIGO_NCM,SUBSTRING(REPLACE(A.CLASSIF_FISCAL,'.',''),1,8)) AS CODIGO_NCM,-- #6##8#
   A.GRUPO_PRODUTO AS GRUPO_PRODUTO, A.SUBGRUPO_PRODUTO AS SUBGRUPO_PRODUTO, A.COLECAO AS COLECAO--#MOBILIDADE#
  FROM     
   PRODUTOS A     
   INNER JOIN PRODUTO_CORES B ON A.PRODUTO = B.PRODUTO    
   INNER JOIN PRODUTOS_BARRA C ON A.PRODUTO = C.PRODUTO AND B.COR_PRODUTO = C.COR_PRODUTO    
   INNER JOIN CLASSIF_FISCAL D ON A.CLASSIF_FISCAL = D.CLASSIF_FISCAL    
   LEFT JOIN W_LJ_PRECO_PRODUTO_BARRA E ON C.CODIGO_BARRA = E.CODIGO_BARRA AND E.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO     
   LEFT JOIN ESTOQUE_PRODUTOS F ON A.PRODUTO = F.PRODUTO AND B.COR_PRODUTO = F.COR_PRODUTO AND F.FILIAL = @FILIAL     
   LEFT JOIN (SELECT A.PRODUTO, A.CONTEUDO_FOTO, A.THUMBNAIL_FOTO, A.PATH_FOTO FROM PRODUTOS_FOTO A INNER JOIN (SELECT PRODUTO, MIN(NUMERO_FOTO) AS NUMERO_FOTO FROM PRODUTOS_FOTO GROUP BY PRODUTO) B ON A.PRODUTO = B.PRODUTO AND A.NUMERO_FOTO = B.NUMERO_FOTO) G ON A.PRODUTO = G.PRODUTO     
   INNER JOIN TRIBUT_ORIGEM H ON A.TRIBUT_ORIGEM = H.TRIBUT_ORIGEM     
   LEFT JOIN PRODUTOS_INDICADOR_CFOP I ON A.PRODUTO = I.PRODUTO AND I.FILIAL = @FILIAL     
   LEFT JOIN CTB_LX_INDICADOR_CFOP J ON ISNULL(I.INDICADOR_CFOP, A.INDICADOR_CFOP) = J.INDICADOR_CFOP     
   LEFT JOIN CADASTRO_CLI_FOR K ON K.NOME_CLIFOR = @FILIAL
   LEFT JOIN CEST_NCM CEST_NCM ON A.ID_CEST_NCM = CEST_NCM.ID --#6#
   LEFT JOIN TABELA_LX_NCM NCM ON NCM.ID = CEST_NCM.ID_NCM --#6##7#         
   LEFT JOIN TABELA_LX_CEST CEST	ON CEST.ID = CEST_NCM.ID_CEST --#6#  
  WHERE     
   C.CODIGO_BARRA = @CODIGO_BARRA    
   AND C.INATIVO = 0  -- #5#
 SET NOCOUNT OFF    
END