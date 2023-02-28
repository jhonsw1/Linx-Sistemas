
Create Function [dbo].[fn_InvoiceTaxException] (@OperationType int, @DestinationCode char(14), @IndicadorCFOP int, @TaxFlag char(1), @StoreName varchar(25), @DocumentDate datetime, @TributOrigem char(3), @CFOP char(4), @ItemCode varchar(40), @DestinationName varchar(25), @ItemType char(1), @FiscalOperation varchar(15), @StoreCode char(6), @sat bit =0 ) 
RETURNS INT
AS

-- 06/05/2021 - Wendel Crespigio - Feito um tratamento para carregar uma proxima excecao de imposto caso a primeira selecionada for inativada para evitar problemas com o SAT.
-- 29/07/2020 - Wendel Crespigio - Desfeita a altera��o anterior MODASP-4539- efeito colateral em cliente que usam simples nacional.
-- 09/09/2019 - Wesley Batista   - MODASP-4539 #03# - Blindagem para que evide cliente utilizar exce��o de imposto que n�o seja de acordo com o regime tributario da Loja.
-- 02/01/2019 - Eder Silva       - DM 105492 - #2# - Corre��o para considerar UF_FILIAL quando houver na exce��o.
-- 14/05/2018 - Wendel Crespigio - DM 72780  - #1# - Tratamento da demanda 72780 permitIr que as exce��es trabalhem 
--                                           - #1# - (Sem data inicio e sem datafim) , (com data inicio e sem data fim) , (com data fim e sem data inicio) , (Com data inicio e com data fim)
BEGIN
      DECLARE @Return int
      
      SELECT @FiscalOperation = RTRIM(@FiscalOperation), @ItemCode = RTRIM(@ItemCode)

      SELECT 
            @Return = A.ID_EXCECAO_IMPOSTO    
      FROM 
            (SELECT
                  TOP 1 A.ID_EXCECAO_IMPOSTO, PONTOS = 
                  CASE WHEN A.INDICADOR_CFOP = @IndicadorCFOP THEN 1 ELSE 0 END + 
                  CASE WHEN A.UF = C.UF THEN 1 ELSE 0 END + 
                  CASE WHEN A.UF = D.UF THEN 1 ELSE 0 END + 
				  CASE WHEN A.UF_FILIAL IS NOT NULL THEN 1 ELSE 0 END + --#2#
                  CASE WHEN (C.INDICADOR_FISCAL_TERCEIRO IS NOT NULL AND A.INDICADOR_FISCAL_TERCEIRO = C.INDICADOR_FISCAL_TERCEIRO) OR A.INDICADOR_FISCAL_TERCEIRO = ISNULL(F.INDICADOR_FISCAL_TERCEIRO, 8) THEN 1 ELSE 0 END +
                  CASE WHEN A.CTB_TIPO_OPERACAO = @OperationType THEN 1 ELSE 0 END + 
                  CASE WHEN A.CODIGO_FISCAL_OPERACAO = @Cfop THEN 1 ELSE 0 END + 
                  CASE WHEN A.NOME_CLIFOR = @DestinationName THEN 10 ELSE 0 END + 
                  CASE WHEN A.NATUREZA_ENTRADA = @FiscalOperation AND @TaxFlag = 'E' THEN 15 ELSE 0 END + 
                  CASE WHEN A.NATUREZA_SAIDA = @FiscalOperation AND @TaxFlag = 'S' THEN 15 ELSE 0 END + 
                  CASE WHEN A.PRODUTO = @ItemCode AND @ItemType = 'P' THEN 15 ELSE 0 END + 
				  CASE WHEN E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM  THEN 10 ELSE 0 END +  
				  CASE WHEN G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM THEN 10 ELSE 0 END +
                  CASE WHEN A.TRIBUT_ORIGEM = @TributOrigem THEN 1 ELSE 0 END + 
                  CASE WHEN A.ID_EXCECAO_GRUPO = C.ID_EXCECAO_GRUPO THEN 10 ELSE 0 END + 
                  CASE WHEN A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO AND @ItemType = 'P' THEN 10 ELSE 0 END + 
                  CASE WHEN A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO AND @ItemType = 'C' THEN 10 ELSE 0 END + 
                  CASE WHEN (H.COD_FILIAL IS NOT NULL AND A.COD_FILIAL = H.COD_FILIAL) THEN 20 ELSE 0 END
            FROM 
                  CTB_EXCECAO_IMPOSTO A
                  INNER JOIN CADASTRO_CLI_FOR B ON B.NOME_CLIFOR = @StoreName AND ISNULL(A.UF_FILIAL, B.UF) = B.UF
                  LEFT JOIN CADASTRO_CLI_FOR C ON C.COD_CLIFOR = @DestinationCode 
                  LEFT JOIN CLIENTES_VAREJO D ON D.CODIGO_CLIENTE = @DestinationCode 
                  LEFT JOIN PRODUTOS E ON E.PRODUTO = @ItemCode AND @ItemType = 'P' -- AND A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO
                  LEFT JOIN CLIENTE_VAR_TIPOS F ON D.TIPO_VAREJO = F.TIPO_VAREJO
                  LEFT JOIN CADASTRO_ITEM_FISCAL G ON G.CODIGO_ITEM = @ItemCode AND @ItemType = 'C' -- AND A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO
                  LEFT JOIN FILIAIS H ON B.NOME_CLIFOR = H.FILIAL 
                  LEFT JOIN LOJAS_VAREJO I ON H.FILIAL = I.FILIAL
            WHERE
                  (isnull(A.DT_INICIO_VIGENCIA,'') = '' OR A.DT_INICIO_VIGENCIA <= @DocumentDate) AND --#1#
				  (isnull(A.DT_FIM_VIGENCIA,'') = '' OR A.DT_FIM_VIGENCIA >= @DocumentDate)       AND --#1# 
				  (A.INATIVO = 0 OR A.INATIVO IS NULL)
                  AND (A.NOME_CLIFOR = @DestinationName OR A.NOME_CLIFOR IS NULL)
                  AND (A.INDICADOR_FISCAL_TERCEIRO IS NULL OR (C.INDICADOR_FISCAL_TERCEIRO IS NOT NULL AND A.INDICADOR_FISCAL_TERCEIRO = C.INDICADOR_FISCAL_TERCEIRO) OR A.INDICADOR_FISCAL_TERCEIRO = ISNULL(F.INDICADOR_FISCAL_TERCEIRO, 8))
                  AND ((@ItemType = 'P' AND A.PRODUTO = @ItemCode) OR A.PRODUTO IS NULL)
                  AND (A.EXCLUSIVO_CADASTRO = 0 OR A.EXCLUSIVO_CADASTRO IS NULL)
                  AND (A.CTB_TIPO_OPERACAO = @OperationType OR A.CTB_TIPO_OPERACAO IS NULL)
                  AND (A.INDICADOR_CFOP = @IndicadorCFOP OR A.INDICADOR_CFOP IS NULL)
                  AND (A.TRIBUT_ORIGEM = @TributOrigem OR A.TRIBUT_ORIGEM IS NULL)
                  AND (A.CODIGO_FISCAL_OPERACAO = @CFOP OR A.CODIGO_FISCAL_OPERACAO IS NULL)
                  AND ((@TaxFlag = 'E' AND A.APLICA_ENTRADA = 1) OR (@TaxFlag = 'S' AND A.APLICA_SAIDA = 1))
                  AND ((@TaxFlag = 'E' AND (A.NATUREZA_ENTRADA = @FiscalOperation OR A.NATUREZA_ENTRADA IS NULL)) OR (@TaxFlag = 'S' AND (A.NATUREZA_SAIDA = @FiscalOperation OR A.NATUREZA_SAIDA IS NULL)))
                  AND (A.ID_EXCECAO_GRUPO = C.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO IS NULL)
                  AND (I.CODIGO_FILIAL = @StoreCode OR I.CODIGO_FILIAL IS NULL)
                  AND (A.UF = ISNULL(C.UF, D.UF) OR A.UF IS NULL)
                  AND (A.COD_FILIAL = H.COD_FILIAL OR A.COD_FILIAL IS NULL)
                  AND ( 
						(E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM ) OR 
						(G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM) OR 
						A.CLASSIF_FISCAL_INI IS NULL OR A.CLASSIF_FISCAL_FIM IS NULL)
            ORDER BY 
                  2 DESC) A

				  if @Return is null and @sat =1
				  begin 

				   SELECT 
					  @Return = A.ID_EXCECAO_IMPOSTO    
						 FROM 
					 (SELECT
					     TOP 1 A.ID_EXCECAO_IMPOSTO, PONTOS = 
					    CASE WHEN A.INDICADOR_CFOP = @IndicadorCFOP THEN 1 ELSE 0 END + 
					    CASE WHEN A.UF = C.UF THEN 1 ELSE 0 END + 
					    CASE WHEN A.UF = D.UF THEN 1 ELSE 0 END + 
						CASE WHEN A.UF_FILIAL IS NOT NULL THEN 1 ELSE 0 END + --#2#
					    CASE WHEN (C.INDICADOR_FISCAL_TERCEIRO IS NOT NULL AND A.INDICADOR_FISCAL_TERCEIRO = C.INDICADOR_FISCAL_TERCEIRO) OR A.INDICADOR_FISCAL_TERCEIRO = ISNULL(F.INDICADOR_FISCAL_TERCEIRO, 8) THEN 1 ELSE 0 END +
						CASE WHEN A.CTB_TIPO_OPERACAO = @OperationType THEN 1 ELSE 0 END + 
					    CASE WHEN A.CODIGO_FISCAL_OPERACAO = @Cfop THEN 1 ELSE 0 END + 
                        CASE WHEN A.NOME_CLIFOR = @DestinationName THEN 10 ELSE 0 END + 
                        CASE WHEN A.NATUREZA_ENTRADA = @FiscalOperation AND @TaxFlag = 'E' THEN 15 ELSE 0 END + 
                        CASE WHEN A.NATUREZA_SAIDA = @FiscalOperation AND @TaxFlag = 'S' THEN 15 ELSE 0 END + 
                        CASE WHEN A.PRODUTO = @ItemCode AND @ItemType = 'P' THEN 15 ELSE 0 END + 
				        CASE WHEN E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM  THEN 10 ELSE 0 END +  
				        CASE WHEN G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM THEN 10 ELSE 0 END +
                        CASE WHEN A.TRIBUT_ORIGEM = @TributOrigem THEN 1 ELSE 0 END + 
                        CASE WHEN A.ID_EXCECAO_GRUPO = C.ID_EXCECAO_GRUPO THEN 10 ELSE 0 END + 
                        CASE WHEN A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO AND @ItemType = 'P' THEN 10 ELSE 0 END + 
                        CASE WHEN A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO AND @ItemType = 'C' THEN 10 ELSE 0 END + 
                        CASE WHEN (H.COD_FILIAL IS NOT NULL AND A.COD_FILIAL = H.COD_FILIAL) THEN 20 ELSE 0 END
            FROM 
                  CTB_EXCECAO_IMPOSTO A
                  INNER JOIN CADASTRO_CLI_FOR B ON B.NOME_CLIFOR = @StoreName AND ISNULL(A.UF_FILIAL, B.UF) = B.UF
                  LEFT JOIN CADASTRO_CLI_FOR C ON C.COD_CLIFOR = @DestinationCode 
                  LEFT JOIN CLIENTES_VAREJO D ON D.CODIGO_CLIENTE = @DestinationCode 
                  LEFT JOIN PRODUTOS E ON E.PRODUTO = @ItemCode AND @ItemType = 'P' -- AND A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO
                  LEFT JOIN CLIENTE_VAR_TIPOS F ON D.TIPO_VAREJO = F.TIPO_VAREJO
                  LEFT JOIN CADASTRO_ITEM_FISCAL G ON G.CODIGO_ITEM = @ItemCode AND @ItemType = 'C' -- AND A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO
                  LEFT JOIN FILIAIS H ON B.NOME_CLIFOR = H.FILIAL 
                  LEFT JOIN LOJAS_VAREJO I ON H.FILIAL = I.FILIAL
            WHERE
                  (isnull(A.DT_INICIO_VIGENCIA,'') = '' OR A.DT_INICIO_VIGENCIA <= @DocumentDate) AND --#1#
				  (isnull(A.DT_FIM_VIGENCIA,'') = '' OR A.DT_FIM_VIGENCIA >= @DocumentDate)       AND --#1# 
				  (A.INATIVO = 0 OR A.INATIVO IS NULL)
                  AND (A.NOME_CLIFOR = @DestinationName OR A.NOME_CLIFOR IS NULL)
                  AND (A.INDICADOR_FISCAL_TERCEIRO IS NULL OR (C.INDICADOR_FISCAL_TERCEIRO IS NOT NULL AND A.INDICADOR_FISCAL_TERCEIRO = C.INDICADOR_FISCAL_TERCEIRO) OR A.INDICADOR_FISCAL_TERCEIRO = ISNULL(F.INDICADOR_FISCAL_TERCEIRO, 8))
                  AND ((@ItemType = 'P' AND A.PRODUTO = @ItemCode) OR A.PRODUTO IS NULL)
                  AND (A.EXCLUSIVO_CADASTRO = 0 OR A.EXCLUSIVO_CADASTRO IS NULL)
                  AND (A.CTB_TIPO_OPERACAO = @OperationType OR A.CTB_TIPO_OPERACAO IS NULL)
                  AND (A.INDICADOR_CFOP = @IndicadorCFOP OR A.INDICADOR_CFOP IS NULL)
                  AND (A.TRIBUT_ORIGEM = @TributOrigem OR A.TRIBUT_ORIGEM IS NULL)
                  AND (A.CODIGO_FISCAL_OPERACAO = @CFOP OR A.CODIGO_FISCAL_OPERACAO IS NULL)
                  AND ((@TaxFlag = 'E' AND A.APLICA_ENTRADA = 1) OR (@TaxFlag = 'S' AND A.APLICA_SAIDA = 1))
                  AND ((@TaxFlag = 'E' AND (A.NATUREZA_ENTRADA = @FiscalOperation OR A.NATUREZA_ENTRADA IS NULL)) OR (@TaxFlag = 'S' AND (A.NATUREZA_SAIDA = @FiscalOperation OR A.NATUREZA_SAIDA IS NULL)))
                  AND (A.ID_EXCECAO_GRUPO = C.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO IS NULL)
                  AND (I.CODIGO_FILIAL = @StoreCode OR I.CODIGO_FILIAL IS NULL)
                  AND (A.UF = ISNULL(C.UF, D.UF) OR A.UF IS NULL)
              
                  AND ( 
						(E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM ) OR 
						(G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM) OR 
						A.CLASSIF_FISCAL_INI IS NULL OR A.CLASSIF_FISCAL_FIM IS NULL)
            ORDER BY 
                  2 DESC) A

				  end
     
      RETURN @Return
END

