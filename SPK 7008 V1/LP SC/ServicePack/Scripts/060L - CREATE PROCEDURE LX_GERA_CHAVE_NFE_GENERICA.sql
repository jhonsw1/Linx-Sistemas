CREATE PROCEDURE [DBO].[LX_GERA_CHAVE_NFE_GENERICA] (@NOTAFISCAL VARCHAR(9), 
													 @SERIENOTA VARCHAR(6), --#1#
													 @CNPJ_EMITENTE VARCHAR(14),  
													 @CIDADE_EMITENTE VARCHAR(35),
													 @UF_EMITENTE CHAR(2),
													 @AAMM_EMISSAO CHAR(4),
													 @MODELO CHAR(2),
													 @TIPO_EMISSAO TINYINT,
													 @VERSAO_CHAVE_NFE CHAR(6) = '3.10',
													 @CODIGO_UF_IBGE CHAR(2) = null )

	WITH ENCRYPTION                                                           
AS

/*
-- DM 58430	- Diego Moreno	   - #5# - (20/09/2017) - Adequacao NFE 4.00. Melhoria para atender ao layout 4.0.
--17/05/2016 - Wendel Crespigio  - #4# - DM 2644 - correção para o estado de ji-parana (RO)
*/

DECLARE @ERRNO INT, @ERRMSG VARCHAR(255)

IF (@VERSAO_CHAVE_NFE NOT IN ('1.10', '2.00', '3.10','4.00')) --#2# #5#
BEGIN
      SET @ERRNO = 30002
      
      IF (@VERSAO_CHAVE_NFE Not In ('1.10', '2.00', '3.10','4.00'))--#2# #5#
            SET @ERRMSG = 'O valor "' + RTRIM(@VERSAO_CHAVE_NFE) + '" para a versão do XML da NFe não é válido. Seu valor só pode ser "1.10", "2.00" ou "3.10" OU "4.00".'--#2# #5#
      
      GOTO ERROR
END

BEGIN
      DECLARE @CHAVEACESSO VARCHAR(44), @CODIGONF CHAR(9), @SOMAPONDERACOES AS INT,  @CNT INT, @PESO INT, @RESTODIVISAO INT, 
                  @DIGITOVERIFICADOR CHAR(1)

      -- BUSCA A SÉRIE OFICIAL DA NOTA FISCAL NA COLUNA COD_SERIE_SINTEGRA DA TABELA SERIES_NF PARA COMPOR A CHAVE NF-E
      SELECT @SERIENOTA = RTRIM(CASE WHEN COD_SERIE_SINTEGRA IS NULL OR COD_SERIE_SINTEGRA = '' THEN @SERIENOTA ELSE COD_SERIE_SINTEGRA END) FROM SERIES_NF WHERE SERIE_NF = @SERIENOTA
      SELECT @SERIENOTA = CASE WHEN @SERIENOTA = 'U' OR @SERIENOTA = 'UN' THEN '0' ELSE @SERIENOTA END
      
      -- FIM DA BUSCA DA SÉRIE OFICIAL

      -- BUSCA O CODIGO DO ESTADO DA TABELA DO IBGE
      IF @CODIGO_UF_IBGE IS NULL
                  SELECT @CODIGO_UF_IBGE = (SELECT TOP 1 SUBSTRING(LCF_LX_MUNICIPIO.COD_MUNICIPIO_IBGE,1,2) 
                                                           FROM LCF_LX_MUNICIPIO (NOLOCK) 
                                                                 INNER JOIN LCF_LX_UF U (NOLOCK)
                                                                       ON U.ID_UF = LCF_LX_MUNICIPIO.ID_UF
                                                           WHERE U.UF = @UF_EMITENTE
                                                                       AND DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,DESC_MUNICIPIO) = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,@CIDADE_EMITENTE)) --#4#


      -- @VERSAO_CHAVE_NFE: 1.10   
      -- @VERSAO_CHAVE_NFE: 2.00   (ENTRA EM VIGOR A PARTIR DO DIA

      -- MONTAGEM DA CHAVE DE ACESSO DA NOTA FISCAL E DO CALCULO DO DIGITO VERIFICADOR
      IF RTRIM(@VERSAO_CHAVE_NFE) = '1.10'
            BEGIN
                  SELECT @CODIGONF = RIGHT(STR(RAND(),11,9),9) 

                  SELECT @CHAVEACESSO = @CODIGO_UF_IBGE +
                                                     @AAMM_EMISSAO +
                                                     @CNPJ_EMITENTE +
                                                     @MODELO +
                                                     RIGHT('00'+RTRIM(CASE WHEN @SERIENOTA = 'U' OR @SERIENOTA = 'UN' THEN '0' ELSE @SERIENOTA END),3)+ --#1#
                                                     RIGHT('00000000'+RTRIM(@NOTAFISCAL),9)+
                                                     @CODIGONF
            END

      IF RTRIM(@VERSAO_CHAVE_NFE) in ('2.00','3.10','4.00')--#2# #5#
            BEGIN
                  SELECT @CODIGONF = RIGHT(STR(RAND(),11,9),8) 

                  SELECT @CHAVEACESSO = @CODIGO_UF_IBGE +
                                                     @AAMM_EMISSAO +
                                                     @CNPJ_EMITENTE +
                                                     @MODELO +
                                                     RIGHT('00'+RTRIM(CASE WHEN @SERIENOTA = 'U' OR @SERIENOTA = 'UN' THEN '0' ELSE @SERIENOTA END),3)+ --#1#
                                                     RIGHT('00000000'+RTRIM(@NOTAFISCAL),9)+
                                                     CONVERT(CHAR(1),@TIPO_EMISSAO)+
                                                     @CODIGONF
            END

      -- FAZ A VALIDAÇÃO DA SERIE, SE FOR CARACTER, NAO GERA O DIGITO VERIFICADOR
      IF @SERIENOTA NOT LIKE '%[!-/]%' AND @SERIENOTA NOT LIKE '%[A-Z]%'
      BEGIN
            SELECT  @CNT = 43 , @PESO = 2, @SOMAPONDERACOES = 0
            WHILE @CNT > 0
                  BEGIN
                        IF @PESO > 9
                             SELECT @PESO = 2

                        SELECT @SOMAPONDERACOES = @SOMAPONDERACOES + (CONVERT(INT,SUBSTRING(@CHAVEACESSO,@CNT,1)) * @PESO)

                        SELECT @PESO = @PESO + 1
                        SELECT @CNT  = @CNT - 1
                  END 

            SELECT      @RESTODIVISAO = (@SOMAPONDERACOES - (FLOOR((@SOMAPONDERACOES / 11)) * 11))
            SELECT @DIGITOVERIFICADOR = CASE WHEN @RESTODIVISAO = 1 OR @RESTODIVISAO = 0 THEN '0' ELSE LTRIM(RTRIM(STR(11 - @RESTODIVISAO))) END 
      END

      SELECT RTRIM(@CHAVEACESSO)+RTRIM(@DIGITOVERIFICADOR) AS CHAVE_ACESSO_NFE
      
END 

RETURN

ERROR:
      
      	RAISERROR (@ERRMSG, @ERRNO, 1) 

