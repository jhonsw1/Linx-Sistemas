CREATE PROCEDURE [dbo].[LX_BLOCOX_GERA_XML_ESTOQUE] ( @CODIGO_FILIAL VARCHAR(6) = NULL,     
              @DATA_REFERENCIA DATETIME = NULL,    
              @NUMEROCREDENCIAMENTO VARCHAR(15),    
              @VALIDAR_XSD BIT = 0,    
              @PERMITIR_SEM_MOVIMENTO BIT = 0)     
AS 
--19/06/2019 - MODASP-2788 - #1# - Diego Moreno - Melhoria necessária para quando houver mais de um codigo de barras para o mesmo produto.
BEGIN    
 DECLARE @ESTOQUE_XML XML, @DATA_FINAL CHAR(10), @ESTOQUE_XML_REPLACE VARCHAR(MAX),     
 @FILIAL VARCHAR(25), @LOCALUF CHAR(2), @LOCALSAIDAICMS NUMERIC(8,5),  @CODIGO_TAB_PRECO CHAR(2), @ID_BLOCOX INT, @SITUACAO_BX INT, @COUNT AS INT,     
 @ENCODING VARCHAR(40), @INTSEQBCGX INT, @INTSEQBCX INT, @ERRORMESSAGE NVARCHAR(2048), @ERRORSEVERITY SMALLINT, @ERRORSTATE SMALLINT,    
 @COUNT_AQUISICAO AS INT, @ERRMSG VARCHAR(8000), @RG_IE VARCHAR(19), @DIA_GERA_ARQ_EST_BLOCOX INT, @DATA_PERM_GER AS DATETIME,    
 @DADOS_INCOR AS VARCHAR(10),--#5#    
 @NAO_GERADO AS VARCHAR(10)    

 SET @DADOS_INCOR = '@LXDATAERR ' -- #5#    
 SET @NAO_GERADO =  '@LXNAOGERA'    
     
 IF @DATA_REFERENCIA IS NULL    
  BEGIN    
   SET @ERRMSG = @DADOS_INCOR + ' ' + 'Valor de parâmetro inválido para data de referência !'--#5#    
   GOTO ERROR    
  END    
    
 --Retornar a data no formato aaaa-mm-dd    
 SELECT @DATA_FINAL = SUBSTRING(CONVERT(CHAR(8),@DATA_REFERENCIA,112),1,4) +'-'+ SUBSTRING(CONVERT(CHAR(8),@DATA_REFERENCIA,112),5,2)+'-'+ SUBSTRING(CONVERT(CHAR(8),@DATA_REFERENCIA,112),7,2)    
    
 SET @ENCODING = '<' + CHAR(63) + 'xml version=' + CHAR(34) + '1.0' + CHAR(34) + ' encoding=' + CHAR(34) + 'utf-8' + CHAR(34)  + CHAR(63) + '>'     
    
 SELECT @FILIAL = FILIAL FROM LOJAS_VAREJO WHERE CODIGO_FILIAL = @CODIGO_FILIAL    
    
 IF @FILIAL IS NULL OR @CODIGO_FILIAL IS NULL    
  BEGIN    
   SET @ERRMSG = @DADOS_INCOR + ' ' +  'Filial ou Código da Filial não foi encontrado !' --#5#    
    
   GOTO ERROR    
  END     
    
 SELECT @LOCALUF = CLIFOR.UF, @LOCALSAIDAICMS = UNF.ICMS_SAIDA,      
   @RG_IE = REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(CLIFOR.RG_IE)), '.', ''), '-', ''), '/', ''), '\', '') -- #8#    
 FROM CADASTRO_CLI_FOR CLIFOR     
 LEFT JOIN UNIDADES_FEDERACAO_ICMS UNF     
  ON CLIFOR.UF = UNF.UF AND    
   CLIFOR.UF = UNF.UF_DESTINO    
 WHERE NOME_CLIFOR = @FILIAL     
     
 SELECT @CODIGO_TAB_PRECO = DBO.FX_PARAMETRO_LOJA('CODIGO_TAB_PRECO', @CODIGO_FILIAL)    
    
 IF @CODIGO_TAB_PRECO IS NULL --AND @PERMITIR_SEM_MOVIMENTO = 0--#6#    
  BEGIN    
   SET @ERRMSG =  @DADOS_INCOR + ' ' + 'Tabela de preço não localizada para a filial:' + ISNULL(@CODIGO_FILIAL,'')--#5#    
   GOTO ERROR    
  END     
    
 SELECT @DIA_GERA_ARQ_EST_BLOCOX = ISNULL(DBO.FX_PARAMETRO_LOJA('DIA_GERA_ARQ_EST_BLOCOX', @CODIGO_FILIAL), '1')    
     
 SELECT @DATA_PERM_GER = CAST((SUBSTRING(CONVERT(CHAR(10),DATEADD(MONTH,1,@DATA_REFERENCIA),112),1,6) + RIGHT((REPLICATE('0',2) + RTRIM(CAST(@DIA_GERA_ARQ_EST_BLOCOX AS CHAR(2)))),2)) AS DATETIME)    

--#ESTOQUE SEM PRODUTOS# - INICIO
--INICIO DO TRATAMENTO PARA GERAR ARQUIVO DE ESTOQUE SEM PRODUTOS
DECLARE @QTDE INT, @TAMANHO INT, @GERAR_SEM_PRODUTOS BIT = 0--, @DATA_PARA_GERACAO DATE

SELECT @QTDE = COUNT(*), @TAMANHO = MIN(TAMANHO) FROM 
(SELECT TOP 1 CODIGO_FILIAL, DATA_REFERENCIA, '' AS PRODUTO, '' AS COR_PRODUTO, -1 AS TAMANHO, 0 AS ESTOQUE, 0 AS QUANTIDADE_TOTAL, 0 AS VALOR_TOTAL_AQUISICAO, 0 AS VALOR_TOTAL_ICMS, 0 AS VALOR_BASE_ICMS_ST, 0 AS VALOR_TOTAL_ICMS_ST, 0 AS INATIVO, DATA_PARA_TRANSFERENCIA 
 FROM LJ_BLOCOX_ESTOQUEMENSAL
 WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND 
	   DATA_REFERENCIA = @DATA_FINAL AND 
	   TAMANHO = -1 ) A

IF (@QTDE = 1 AND @TAMANHO = -1)
	BEGIN 
		PRINT 'GERAR SEM PRODUTOS'
		SET @GERAR_SEM_PRODUTOS = 1
	END

   
 IF @PERMITIR_SEM_MOVIMENTO = 0 and @GERAR_SEM_PRODUTOS = 0--#6#    
  BEGIN    
   SELECT @COUNT_AQUISICAO = COUNT(*)     
   FROM DBO.LJ_BLOCOX_ESTOQUEMENSAL AP     
   WHERE AP.DATA_REFERENCIA = @DATA_REFERENCIA    
    
   --Deve gerar apenas se os dados de estoque para o mes ja estiverem no banco de dados da loja.    
   --A data atual for maior ou igual ao conteudo do parametro DIA_GERA_ARQ_EST_BLOCOX do mes seguinte.    
   IF @COUNT_AQUISICAO = 0    
    BEGIN    
     SET @ERRMSG =  @NAO_GERADO + ' ' + 'Não há informações enviadas pela retaguarda para a data de referência ' + Convert(CHAR(12), @DATA_REFERENCIA,113)--#5#    
     GOTO ERROR    
    END     
  END    
  
 
  IF @GERAR_SEM_PRODUTOS = 1  
 BEGIN   
  SELECT @ESTOQUE_XML = (  
 (--Estoque inicio  
  SELECT '1.0' AS "@Versao",  
    (--Mensagem inicio  
     SELECT  
       (-- Estabelecimento  
        SELECT @RG_IE as Ie  
        FOR XML PATH(''),TYPE  
       ) AS Estabelecimento,-- Estabelecimento           
       (-- PafEcf  
        SELECT   
         RTRIM(LTRIM(LEFT(@NUMEROCREDENCIAMENTO,15))) AS NumeroCredenciamento  
        FOR XML PATH(''),TYPE  
       ) AS PafEcf,--PafEcf  
       (--Dados do Estoque inicio  
        SELECT   
         @DATA_FINAL AS DataReferencia,  
         CASE WHEN @COUNT > 0 THEN  
          (--Produtos/Produto inicio  
          SELECT  
           '' AS Descricao,  
           '' AS CodigoGTIN,--#3#  
           '' AS CodigoCEST,--#3#  
           '' AS CodigoNCMSH,--#3#  
           '' AS CodigoProprio,--#3#  
           '' AS Quantidade,  
           '' AS QuantidadeTotalAquisicao,--#3#  
           '' as Unidade,--#3#  
           '' AS ValorUnitario,  
           '' AS ValorTotalAquisicao,--#3#  
           '' AS ValorTotalICMSDebitoFornecedor,--#3#  
           '' AS ValorBaseCalculoICMSST,--#3#  
           '' AS ValorTotalICMSST,--#3#  
           '' AS SituacaoTributaria,  
           '' AS Aliquota,  
           'false' as IsArredondado,  
           '' SituacaoEstoque  
           FOR XML PATH('Produto'), TYPE        
          ) --Produtos/Produto fim  
        ELSE  
         '' --Forcar gerar o nao de produtos vazio.  
        END Produtos  
        FOR XML PATH('DadosEstoque'), TYPE  
       )--Dados do Estoque fim  
     FOR XML PATH('Mensagem'), TYPE  
    )--Mensagem fim   
  FOR XML PATH('Estoque'), TYPE  
 )--Estoque fim  
 )  
   --SELECT CONVERT(XML,@ESTOQUE_XML)   
   --    RETURN   
   goto SalVarXml
END  
--#ESTOQUE SEM PRODUTOS# - Fim
 IF GETDATE() < @DATA_PERM_GER    
  BEGIN    
   SET @ERRMSG =  @DADOS_INCOR + ' ' + 'Data de referência solicitada: ' + Convert(CHAR(12), @DATA_REFERENCIA,113) + 'estará permitida a geração à partir de: ' +  Convert(CHAR(12), @DATA_PERM_GER,113) + '.'--#5#    
   GOTO ERROR    
  END       
    
 DECLARE @PRODUTOS_PAF TABLE  ( PRODUTO     VARCHAR (12) COLLATE DATABASE_DEFAULT ,    
         COR_PRODUTO    VARCHAR (10) COLLATE DATABASE_DEFAULT,    
         TAMANHO     INT,    
         CODIGO_BARRA      VARCHAR (25) COLLATE DATABASE_DEFAULT,    
         TIPO_COD_BAR   smallint,    
         DESC_PROD    VARCHAR (50) COLLATE DATABASE_DEFAULT,     
         UNIDADE     VARCHAR (6)  COLLATE DATABASE_DEFAULT,              
         ESTOQUE     NUMERIC(14,3),    
         QUANTIDADE_TOTAL  INT,    
         VALOR_TOTAL_AQUISICAO   NUMERIC(14,2),     
         VALOR_TOTAL_ICMS  NUMERIC(14,2),     
         VALOR_BASE_ICMS_ST  NUMERIC(14,2),    
         VALOR_TOTAL_ICMS_ST  NUMERIC(14,2),    
         INDICADOR_CFOP   VARCHAR (11) COLLATE DATABASE_DEFAULT,    
         CLASSIF_FISCAL   VARCHAR (10) COLLATE DATABASE_DEFAULT,    
         PONTEIRO_PRECO_TAM  VARCHAR(48) COLLATE DATABASE_DEFAULT,    
         ALIQUOTA    NUMERIC (5,2),    
         ID_IMPOSTO    TINYINT,    
         PRECO1     NUMERIC (14,3),    
         PRECO2     NUMERIC (14,3),    
         PRECO3     NUMERIC (14,3),    
         PRECO4     NUMERIC (14,3),    
         ATUALIZADO    BIT NOT NULL DEFAULT 0,    
         CODIGO_CEST    CHAR(7),    
         CODIGO_NCM    CHAR(10)    
         )    
         
 INSERT INTO @PRODUTOS_PAF ( PRODUTO,        
        COR_PRODUTO,      
        TAMANHO,    
        CODIGO_BARRA,    
        TIPO_COD_BAR,       
        ESTOQUE,       
        QUANTIDADE_TOTAL,    
        VALOR_TOTAL_AQUISICAO,    
        VALOR_TOTAL_ICMS,     
        VALOR_BASE_ICMS_ST,     
        VALOR_TOTAL_ICMS_ST    
        )     
        SELECT EST.PRODUTO,      
          EST.COR_PRODUTO,     
          EST.TAMANHO,    
          MAX(PB.CODIGO_BARRA) AS CODIGO_BARRA,    
          ---MAX(PB.TIPO_COD_BAR) AS TIPO_COD_BAR,    
		  CASE WHEN COUNT(*) > 1 THEN -1 ELSE  MAX(PB.TIPO_COD_BAR) END AS TIPO_COD_BAR, --#1#
          EST.ESTOQUE,     
          EST.QUANTIDADE_TOTAL,    
          EST.VALOR_TOTAL_AQUISICAO,    
          EST.VALOR_TOTAL_ICMS,     
          EST.VALOR_BASE_ICMS_ST,     
          EST.VALOR_TOTAL_ICMS_ST    
        FROM DBO.LJ_BLOCOX_ESTOQUEMENSAL EST    
        INNER JOIN DBO.PRODUTOS_BARRA PB    
         ON EST.PRODUTO = PB.PRODUTO AND    
          EST.COR_PRODUTO = PB.COR_PRODUTO AND    
          EST.TAMANHO = PB.TAMANHO AND     
          PB.INATIVO = 0 AND    
          PB.TIPO_COD_BAR IS NOT NULL    
        WHERE EST.INATIVO = 0 AND     
          EST.CODIGO_FILIAL = @CODIGO_FILIAL AND     
          EST.DATA_REFERENCIA = @DATA_REFERENCIA AND -- #7#    
          LEN(PB.CODIGO_BARRA) > 0     -- #7#    
        GROUP BY EST.PRODUTO, EST.COR_PRODUTO, EST.TAMANHO, EST.ESTOQUE, EST.QUANTIDADE_TOTAL, EST.VALOR_TOTAL_AQUISICAO,    
           EST.VALOR_TOTAL_ICMS, EST.VALOR_BASE_ICMS_ST, EST.VALOR_TOTAL_ICMS_ST    
    
 --Verificar se houve insercao    
 SELECT @COUNT = @@ROWCOUNT    
    
 IF @COUNT = 0 AND @PERMITIR_SEM_MOVIMENTO = 0--#6#    
  BEGIN    
   SET @ERRMSG = @DADOS_INCOR + ' ' + 'Relacionamento DBO.LJ_BLOCOX_ESTOQUEMENSAL X DBO.PRODUTOS_BARRA não retornou dados para geração do XML!'--#5#    
   GOTO ERROR    
  END     
    
	/*#1# - Inicio*/
	
	UPDATE PTEMP SET PTEMP.CODIGO_BARRA = LVP.CODIGO_BARRA
	FROM @PRODUTOS_PAF PTEMP    
	LEFT JOIN DBO.LOJA_VENDA_PRODUTO LVP WITH(NOLOCK)
	ON PTEMP.PRODUTO = LVP.PRODUTO AND
	PTEMP.COR_PRODUTO = LVP.COR_PRODUTO AND 
	PTEMP.TAMANHO = LVP.TAMANHO
	WHERE	PTEMP.TIPO_COD_BAR = -1
	AND		LVP.CODIGO_FILIAL = @CODIGO_FILIAL
	AND		LVP.DATA_VENDA = @DATA_REFERENCIA  

	UPDATE	PTEMP SET PTEMP.TIPO_COD_BAR = PB.TIPO_COD_BAR
	FROM	@PRODUTOS_PAF PTEMP  
	INNER	JOIN PRODUTOS_BARRA PB WITH(NOLOCK)
	ON		PTEMP.CODIGO_BARRA = PB.CODIGO_BARRA

	/*#1# - Fim*/

 -- #5##7#    
 --Update dados dos produtos    
  UPDATE PTEMP SET PTEMP.INDICADOR_CFOP = PD.INDICADOR_CFOP,    
      PTEMP.CLASSIF_FISCAL = PD.CLASSIF_FISCAL,    
      PTEMP.PONTEIRO_PRECO_TAM = PD.PONTEIRO_PRECO_TAM,    
      PTEMP.DESC_PROD = PD.DESC_PRODUTO,    
      PTEMP.UNIDADE = PD.UNIDADE,    
      PTEMP.CODIGO_CEST = ISNULL(CEST.CODIGO_CEST,''),    
      PTEMP.CODIGO_NCM = ISNULL(NCM.CODIGO_NCM,SUBSTRING(REPLACE(PD.CLASSIF_FISCAL,'.',''),1,10))    
      FROM @PRODUTOS_PAF PTEMP    
      INNER JOIN DBO.PRODUTOS PD    
       ON PTEMP.PRODUTO = PD.PRODUTO    
      LEFT JOIN CEST_NCM CN    
       ON PD.ID_CEST_NCM = CN.ID AND CN.INATIVO = 0    
      LEFT JOIN TABELA_LX_CEST CEST    
       ON CEST.ID = CN.ID_CEST    
      LEFT JOIN TABELA_LX_NCM NCM    
       ON NCM.ID = CN.ID_NCM    
     
 --Atualizacao dos dados de aliquota    
 UPDATE PTEMP SET PTEMP.ALIQUOTA = (SELECT DBO.FN_TAXEXCEPTION(PTEMP.CLASSIF_FISCAL, @LOCALUF, @FILIAL, 1, @LOCALSAIDAICMS)),    
      PTEMP.ID_IMPOSTO = ISNULL(( SELECT TOP 1 CFI.ID_IMPOSTO    
            FROM CLASSIF_FISCAL_IMPOSTO CFI     
            INNER JOIN LOJAS_VAREJO LVAR     
             ON CFI.CODIGO_FILIAL = LVAR.CODIGO_FILIAL    
            WHERE CFI.ID_IMPOSTO = 14 AND REPLACE(PTEMP.CLASSIF_FISCAL, '.', '') BETWEEN REPLACE(CFI.CLASSIF_FISCAL_INICIAL, '.', '')     
            AND REPLACE(CFI.CLASSIF_FISCAL_FINAL, '.', '')     
            AND CFI.UF = @LOCALUF AND  LVAR.FILIAL = @FILIAL    
            ORDER BY LEN(CFI.CODIGO_FILIAL) DESC, LEN(CFI.UF) DESC),0)    
 FROM @PRODUTOS_PAF PTEMP    
    
    
 UPDATE PTEMP    
  SET PTEMP.PRECO1 = CASE WHEN ISNULL(PRF.PRECO1,0) <> 0 THEN PRF.PRECO1 END,     
   PTEMP.PRECO2 = CASE WHEN ISNULL(PRF.PRECO2,0) <> 0 THEN PRF.PRECO2 END,       
   PTEMP.PRECO3 = CASE WHEN ISNULL(PRF.PRECO3,0) <> 0 THEN PRF.PRECO3 END,     
   PTEMP.PRECO4 = CASE WHEN ISNULL(PRF.PRECO4,0) <> 0 THEN PRF.PRECO4 END,    
   PTEMP.ATUALIZADO = 1    
  FROM @PRODUTOS_PAF PTEMP    
  INNER JOIN DBO.PRODUTOS_PRECO_FILIAL PRF     
   ON PRF.PRODUTO = PTEMP.PRODUTO      
     AND PRF.COR_PRODUTO = PTEMP.COR_PRODUTO    
  WHERE PTEMP.ATUALIZADO = 0    
    AND PRF.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO    
    AND PRF.FILIAL = @FILIAL    
    
 UPDATE PTEMP    
  SET PTEMP.PRECO1 = CASE WHEN ISNULL(PPC.PRECO1,0) <> 0 THEN PPC.PRECO1 END,     
   PTEMP.PRECO2 = CASE WHEN ISNULL(PPC.PRECO2,0) <> 0 THEN PPC.PRECO2 END,        
   PTEMP.PRECO3 = CASE WHEN ISNULL(PPC.PRECO3,0) <> 0 THEN PPC.PRECO3 END,     
   PTEMP.PRECO4 = CASE WHEN ISNULL(PPC.PRECO4,0) <> 0 THEN PPC.PRECO4 END,    
   PTEMP.ATUALIZADO = 1    
  FROM @PRODUTOS_PAF PTEMP    
  INNER JOIN DBO.PRODUTOS PD     
   ON PTEMP.PRODUTO = PD.PRODUTO     
  INNER JOIN DBO.PRODUTOS_PRECO_COR PPC    
   ON PTEMP.PRODUTO = PPC.PRODUTO     
   AND PTEMP.COR_PRODUTO = PPC.COR_PRODUTO    
   AND PPC.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO    
  WHERE PTEMP.ATUALIZADO = 0     
    AND PD.VARIA_PRECO_COR = 1     
    
 UPDATE PTEMP    
  SET PTEMP.PRECO1 = ISNULL(PP.PRECO1, PTEMP.PRECO1),     
   PTEMP.PRECO2 = ISNULL(PP.PRECO2, PTEMP.PRECO2),        
   PTEMP.PRECO3 = ISNULL(PP.PRECO3, PTEMP.PRECO3),     
   PTEMP.PRECO4 = ISNULL(PP.PRECO4, PTEMP.PRECO4),    
   PTEMP.ATUALIZADO = 1    
  FROM @PRODUTOS_PAF PTEMP    
  INNER JOIN DBO.PRODUTOS_PRECOS PP     
   ON PTEMP.PRODUTO = PP.PRODUTO     
     AND PP.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO    
  WHERE ATUALIZADO = 0    
    
 SELECT @ESTOQUE_XML = (    
        (--Estoque inicio    
         SELECT '1.0' AS "@Versao",    
           (--Mensagem inicio    
            SELECT    
              (-- Estabelecimento    
               SELECT @RG_IE as Ie    
               FOR XML PATH(''),TYPE    
              ) AS Estabelecimento,-- Estabelecimento             
              (-- PafEcf    
               SELECT     
                RTRIM(LTRIM(LEFT(@NUMEROCREDENCIAMENTO,15))) AS NumeroCredenciamento    
               FOR XML PATH(''),TYPE    
              ) AS PafEcf,--PafEcf    
              (--Dados do Estoque inicio    
               SELECT     
                @DATA_FINAL AS DataReferencia,    
                CASE WHEN @COUNT > 0 THEN    
                 (--Produtos/Produto inicio    
                 SELECT    
                  LEFT(LTRIM(RTRIM(DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,EP_ECF.DESC_PROD))),4000) AS Descricao,    
                  CASE WHEN EP_ECF.TIPO_COD_BAR = 1     
                   THEN LEFT(LTRIM(RTRIM(EP_ECF.CODIGO_BARRA)),4000)     
                  ELSE '' END CodigoGTIN,--#3#    
                  LEFT(LTRIM(RTRIM(EP_ECF.CODIGO_CEST)),4000) AS CodigoCEST,--#3#    
                  LEFT(LTRIM(RTRIM(EP_ECF.CODIGO_NCM)),4000) AS CodigoNCMSH,--#3#    
                  LEFT(LTRIM(RTRIM(EP_ECF.CODIGO_BARRA)),4000) AS CodigoProprio,--#3#    
                  REPLACE(ABS(EP_ECF.ESTOQUE),'.',',') AS Quantidade,    
                  REPLACE(CAST(ISNULL(QUANTIDADE_TOTAL,0) AS NUMERIC(14,3)),'.',',') AS QuantidadeTotalAquisicao,--#3#    
                  LEFT(RTRIM(LTRIM(DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,EP_ECF.UNIDADE))),4000) as Unidade,--#3#    
                  REPLACE(ISNULL(CASE SUBSTRING(EP_ECF.PONTEIRO_PRECO_TAM, EP_ECF.TAMANHO, 1)    
                     WHEN 1 THEN EP_ECF.PRECO1     
                     WHEN 2 THEN EP_ECF.PRECO2     
                     WHEN 3 THEN EP_ECF.PRECO3     
                     WHEN 4 THEN EP_ECF.PRECO4 END, 0),'.',',') AS ValorUnitario,    
                  REPLACE(ISNULL(EP_ECF.VALOR_TOTAL_AQUISICAO,0),'.',',') AS ValorTotalAquisicao,--#3#    
                  REPLACE(ISNULL(EP_ECF.VALOR_TOTAL_ICMS,0),'.',',') AS ValorTotalICMSDebitoFornecedor,--#3#    
                  REPLACE(ISNULL(EP_ECF.VALOR_BASE_ICMS_ST,0),'.',',') AS ValorBaseCalculoICMSST,--#3#    
                  REPLACE(ISNULL(EP_ECF.VALOR_TOTAL_ICMS_ST,0),'.',',') AS ValorTotalICMSST,--#3#    
                  CASE EP_ECF.ALIQUOTA    
                   WHEN 0 THEN 'Isento'    
                   WHEN -1 THEN 'Substituicao tributaria'     
                   WHEN -2 THEN 'Nao tributado'     
                  ELSE     
                   CASE EP_ECF.ID_IMPOSTO     
                    WHEN 14 THEN 'Tributado pelo ISSQN'     
                   ELSE 'Tributado pelo ICMS' END    
                  END AS SituacaoTributaria,    
                  CASE EP_ECF.ALIQUOTA     
                   WHEN 0 THEN ''     
                   WHEN -1 THEN ''     
                   WHEN -2 THEN ''     
              ELSE     
                   REPLACE(CONVERT(VARCHAR,EP_ECF.ALIQUOTA),'.',',')    
                  END AS Aliquota,    
                  'false' as IsArredondado,    
                  CASE ISNULL(EP_ECF.INDICADOR_CFOP, 11)     
                   WHEN 10 THEN 'Proprio'     
                  ELSE 'Terceiros' END Ippt,      
                  CASE WHEN EP_ECF.ESTOQUE >= 0 THEN 'Positivo' ELSE 'Negativo' END SituacaoEstoque    
                 FROM @PRODUTOS_PAF EP_ECF    
                  FOR XML PATH('Produto'), TYPE          
                 ) --Produtos/Produto fim    
               ELSE    
                '' --Forcar gerar o nao de produtos vazio.    
               END Produtos    
               FOR XML PATH('DadosEstoque'), TYPE    
              )--Dados do Estoque fim    
            FOR XML PATH('Mensagem'), TYPE    
           )--Mensagem fim     
         FOR XML PATH('Estoque'), TYPE    
        )--Estoque fim    
       )    
   SalVarXml:
  IF @ESTOQUE_XML IS NULL     
   BEGIN     
    SET @ERRMSG = @DADOS_INCOR + ' ' + 'XML não gerado. Informações inexistentes ou nulas!'--#5#    
    GOTO ERROR    
   END    
    
  --Validar campos do XML de acordo com o XSD #9# Inicio    
  IF @VALIDAR_XSD = 1    
   BEGIN    
    DECLARE @OUTPUT VARCHAR(MAX)    
    
    EXEC LX_LJ_VALIDAR_XML @ESTOQUE_XML, 'DBO.XML_XSD_ESTOQUE_BLOCOX', @OUTPUT OUTPUT    
       
    IF @OUTPUT <> ''    
     BEGIN    
      SET @OUTPUT = @DADOS_INCOR + ' ' + @OUTPUT    
      RAISERROR(@OUTPUT, 11, 1)    
      RETURN    
     END    
   END    
  --#9# Fim     
    
  ----Validar campos do XML de acordo com o XSD #4#    
  --IF @VALIDAR_XSD = 1 AND EXISTS (SELECT * FROM SYS.XML_SCHEMA_COLLECTIONS WHERE NAME = N'XML_XSD_ESTOQUE_BLOCOX' AND SCHEMA_ID = SCHEMA_ID(N'DBO'))    
  -- BEGIN    
  --  BEGIN TRY    
  --   DECLARE @TYPED_XML XML(DBO.XML_XSD_ESTOQUE_BLOCOX)    
    
  --   SELECT @TYPED_XML = CONVERT(XML,@ESTOQUE_XML)    
  --  END TRY    
     
  --  BEGIN CATCH    
  --   SELECT @ERRORMESSAGE = ERROR_MESSAGE(), @ERRORSEVERITY = ERROR_SEVERITY(), @ERRORSTATE = ERROR_STATE()    
  --   SET @ERRORMESSAGE = @DADOS_INCOR + ' ' + @ERRORMESSAGE--#5#    
     
  --   RAISERROR (@ERRORMESSAGE, @ERRORSEVERITY, @ERRORSTATE)    
        
  --   RETURN    
  --  END CATCH    
  -- END    
     
  /* Situacao de envio:    
      1.A gerar (a geracao do arquivo esta pendente);    
      2.A transmitir (o arquivo esta gerado, mas ainda nao foi enviado);    
  */    
  SELECT CONVERT(XML,@ESTOQUE_XML)    
    
  SELECT @ID_BLOCOX = MAX(BCX.ID_BLOCOX), @SITUACAO_BX = MAX(BCX.SITUACAO)    
  FROM DBO.LJ_BLOCOX_CONTROLE_GERA_XML BCX     
  WHERE BCX.CODIGO_FILIAL = BCX.CODIGO_FILIAL AND BCX.TIPO_ARQUIVO = 'EM' AND BCX.DATA_MES = @DATA_REFERENCIA--#5#    
    
  --Criar a capa se nao existir    
  IF @ID_BLOCOX IS NULL    
   BEGIN    
    BEGIN TRY--#2#    
     --Procura o proximo sequencial    
     SELECT @INTSEQBCGX = ISNULL(MAX(ID_BLOCOX),0) + 1 FROM DBO.LJ_BLOCOX_CONTROLE_GERA_XML BCGX (NOLOCK) WHERE BCGX.CODIGO_FILIAL = @CODIGO_FILIAL--#2##5#    
    END TRY--#2#    
    
    BEGIN CATCH--#2#    
     SELECT @ERRORMESSAGE = ERROR_MESSAGE(),@ERRORSEVERITY = ERROR_SEVERITY(),@ERRORSTATE = ERROR_STATE()--#2#    
     -- Se for Arithmetic overflow nao grava.    
     RAISERROR (@ERRORMESSAGE, @ERRORSEVERITY,@ERRORSTATE)--#2#    
        
     RETURN--#2#    
    END CATCH--#2#    
    
     
    INSERT INTO DBO.LJ_BLOCOX_CONTROLE_GERA_XML     
    (ID_BLOCOX, CODIGO_FILIAL, TIPO_ARQUIVO, ID_EQUIPAMENTO, CRO, CRZ, DATA_MES, SITUACAO, COD_RET_SEFAZ, MSG_RET_SEFAZ, RECIBO, DATA_PARA_TRANSFERENCIA)    
    VALUES (@INTSEQBCGX, @CODIGO_FILIAL, 'EM', NULL, NULL, NULL,REPLACE(@DATA_REFERENCIA,'-',''), 1, 0, NULL, NULL, GETDATE())--#2##5#    
       
    --Guarda a PK.    
    SELECT @ID_BLOCOX = MAX(BCX.ID_BLOCOX)    
    FROM DBO.LJ_BLOCOX_CONTROLE_GERA_XML BCX     
    WHERE BCX.CODIGO_FILIAL = BCX.CODIGO_FILIAL AND BCX.DATA_MES = @DATA_REFERENCIA--#5#    
   END    
    
  --Criar/Atualizar registro.    
  IF NOT EXISTS(SELECT BX.ID_BLOCOX FROM DBO.LJ_BLOCOX_XML BX WHERE BX.ID_BLOCOX = ISNULL(@ID_BLOCOX,0) AND BX.CODIGO_FILIAL = @CODIGO_FILIAL)--#5#    
   BEGIN    
    --BEGIN TRY--#2#    
    -- SELECT @INTSEQBCX = ISNULL(MAX(ID_XML),0) + 1 FROM DBO.LJ_BLOCOX_XML BCX (NOLOCK) WHERE BCX.CODIGO_FILIAL = @CODIGO_FILIAL--#2#    
    --END TRY--#2#    
    
    --BEGIN CATCH--#2#    
    -- SELECT @ERRORMESSAGE = ERROR_MESSAGE(),@ERRORSEVERITY = ERROR_SEVERITY(),@ERRORSTATE = ERROR_STATE()--#2#    
    -- -- Se for Arithmetic overflow nao grava.    
    -- RAISERROR (@ERRORMESSAGE, @ERRORSEVERITY,@ERRORSTATE)--#2#    
        
    -- RETURN--#2#    
    --END CATCH--#2#    
    
    INSERT INTO DBO.LJ_BLOCOX_XML (ID_BLOCOX, CODIGO_FILIAL, XML_ARQUIVO, DATA_PARA_TRANSFERENCIA)--#5#    
     VALUES (@ID_BLOCOX, @CODIGO_FILIAL, @ENCODING + CONVERT(VARCHAR(MAX),@ESTOQUE_XML), GETDATE())--#2#    
        
    UPDATE DBO.LJ_BLOCOX_CONTROLE_GERA_XML SET SITUACAO = 2, DATA_PARA_TRANSFERENCIA = GETDATE() WHERE ID_BLOCOX = @ID_BLOCOX AND CODIGO_FILIAL = @CODIGO_FILIAL--#4#    
   END    
  ELSE    
   BEGIN    
    IF ISNULL(@SITUACAO_BX,0) = 1    
     BEGIN     
      UPDATE DBO.LJ_BLOCOX_XML SET XML_ARQUIVO = @ENCODING + CONVERT(VARCHAR(MAX),@ESTOQUE_XML), DATA_PARA_TRANSFERENCIA = GETDATE() WHERE ID_BLOCOX = @ID_BLOCOX AND CODIGO_FILIAL = @CODIGO_FILIAL--#5#    
      UPDATE DBO.LJ_BLOCOX_CONTROLE_GERA_XML  SET  SITUACAO = 2, DATA_PARA_TRANSFERENCIA = GETDATE() WHERE ID_BLOCOX = @ID_BLOCOX AND CODIGO_FILIAL = @CODIGO_FILIAL--#5#    
     END    
   END    
END    
 RETURN    
ERROR:    
 RAISERROR(@ERRMSG, 18, 1)



