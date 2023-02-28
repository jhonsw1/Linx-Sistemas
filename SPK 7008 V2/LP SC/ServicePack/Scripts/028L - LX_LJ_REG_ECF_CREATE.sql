Create Procedure [dbo].[LX_LJ_REG_ECF] 
		( @COD_FILIAL    Varchar(06) ,  @DT_INICIAL    DATETIME    , @DT_FINAL      DATETIME, 
		  @BUILD_BUFFER  Varchar(250),  @TERMINAL      Varchar(03) , @ECF_PrinterID Varchar(03),  
		  @PrinterName   Varchar(20) ,  @ModeloECF     Varchar(20) , @SerialNumber  Varchar(20),
		  @Version_APP   Varchar(10) ,  @Verifica_Reducao char(1)  , @Local_uf varchar(2) )

--30/06/2017 - Wendel Crespigio - #8# - DM 35378   - CORREÇÃO PARA GERAÇÃO DO ARQUIVO R03 PARA CLIENTE DO MARANHÃO.
--01/06/2017 - Eder Silva       - #7# - DM 32381   - Correção na geração do Registro R03 para os estados que exigem o DIEF.
--22/12/2016 - Eder Silva       - #6# - DM 15767   - Tratamento no nome levado para o campo MARCA.  
--13/01/2016 - GERSON.PRADO     - #5# - DM 888     - Correção da data na geração do arquivo, deve utilizar a DATA_FISCAL para considerar vendas após a 00:00 e antes das 02:00
--23/12/2015 - Gerson Prado     - #4# - ID 1354    - Correção no preenchimento da IE do usuário e da IE e IM da desenvolvedora. Tratar o campo DESC_PROD_CUPOM pois os acentos estavam alterando o layout do arquivo gerado.   
--28/08/2015 - Wendel Crespigio - #3# - TP 9577321 - Correção de tratamento de campo is null.
--14/08/2015 - Roberto Beda     - #2# - PAF-ECF    - Correção da indicação de modificação no banco (estava acrescentando '?', quando deveria substituir espaços por '?').
--14/08/2015 - Roberto Beda     - #1# - PAF-ECF    - No registro R02, a coluna MODELO deve ser obtida da tabela LOJA_IMPRESSORAS_FISCAIS
--03/07/2015 - Wendel Crespigio -  -  - PAF-ECF    - Procedure foi reescrita para a geração utilizando novas tabelas PAF 2015.

--@Verifica_Reducao = 1 já reduziu no periodo
--@Verifica_Reducao = 0 não reduziu no periodo

AS
BEGIN

	DECLARE @MFAdicional   CHAR(01)  ,  @TipoECF    CHAR(07)   , @TituloDAV     CHAR   (30),
	        @Versao_PAF varchar(12)  ,  @RS_SH      varchar(60), @CNPJ_SH       varchar(20),
	        @Nome_PAF   varchar(30)  ,  @MD5        varchar(40), @Versao_ER_PAF varchar(12),
	        @IE_SH      varchar(15)  ,  @IM_SH      varchar(15)

	-- #1# (início) Preparação dos dados dos ECFs
	DECLARE @LOJA_IMPRESSORAS_FISCAIS TABLE (
		CODIGO_FILIAL CHAR(6) COLLATE DATABASE_DEFAULT NOT NULL,
		ID_EQUIPAMENTO VARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL,
		MODELO VARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL,
		HASHOK BIT
		PRIMARY KEY CLUSTERED (CODIGO_FILIAL, ID_EQUIPAMENTO)
		)

	INSERT INTO @LOJA_IMPRESSORAS_FISCAIS 
	SELECT A.CODIGO_FILIAL, isnull(A.ID_EQUIPAMENTO,''), MAX(A.MODELO) AS MODELO, --#3#
			MIN(CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.CODIGO_FILIAL + CAST(A.ID_IMPRESSORA AS VARCHAR) + ISNULL(A.ID_EQUIPAMENTO,'')  +	ISNULL(A.MF_ADICIONAL, '')+ A.TIPO_ECF + ISNULL(A.MARCA, '')+	ISNULL(A.MODELO, '')+ISNULL(A.FIRMWARE, '')+CONVERT(VARCHAR, ISNULL(A.DATA_HORA_SB, 0), 126)+	CAST(ISNULL(A.ECF, 0) AS VARCHAR)+ISNULL(A.CNPJ_ESTABELECIMENTO, '')+ISNULL(A.IE_ESTABELECIMENTO, ''))  THEN 1 ELSE 0 END) AS HASHOK
	FROM LOJA_IMPRESSORAS_FISCAIS A
	WHERE CODIGO_FILIAL = @COD_FILIAL 
	GROUP BY A.CODIGO_FILIAL, A.ID_EQUIPAMENTO
	-- #1# (Fim) Preparação dos dados dos ECFs

	SET @MFAdicional = ' '
	SET @TipoECF     = 'ECF-IF '
	SET @TituloDAV   = 'ORCAMENTO'


	IF object_id('TEMPDB..#PAF_ECF_REDUCAO_Z') IS NOT NULL
		DROP TABLE #PAF_ECF_REDUCAO_Z
		
	CREATE TABLE #PAF_ECF_REDUCAO_Z (
			CODIGO_FILIAL  VARCHAR(06)  COLLATE DATABASE_DEFAULT NOT NULL,
			ID_EQUIPAMENTO VARCHAR(20)  COLLATE DATABASE_DEFAULT NOT NULL,
			TERMINAL       VARCHAR(03)  COLLATE DATABASE_DEFAULT NOT NULL,
			CF_INICIAL     INT          NOT NULL, 
			CF_FINAL       INT          NOT NULL, 
			PER_TARIFA     NUMERIC(4,2) NOT NULL, 
			DATA_FISCAL    DATETIME     NOT NULL,	
			ID             INT          NOT NULL
	)
	
	INSERT INTO #PAF_ECF_REDUCAO_Z
	SELECT	A.CODIGO_FILIAL, A.ID_EQUIPAMENTO, A.TERMINAL, 
			A.CF_INICIAL, A.CF_FINAL, B.PER_TARIFA, A.DATA_FISCAL,
			( ROW_NUMBER() over (order by A.ID_EQUIPAMENTO, A.DATA_FISCAL, A.QTDE_REDUCOES_Z ) ) ID
	FROM dbo.LOJA_CONTROLE_FISCAL A
	INNER JOIN dbo.LOJA_CONTROLE_FISCAL_TARIFAS B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL 
		AND A.TERMINAL = B.TERMINAL AND A.ECF = B.ECF AND A.ID_EQUIPAMENTO = B.ID_EQUIPAMENTO 
		AND A.DATA_FISCAL = B.DATA_FISCAL AND A.CF_INICIAL = B.CF_INICIAL AND A.SERIE_NF = B.SERIE_NF
	WHERE B.PER_TARIFA > 0
		AND A.DATA_FISCAL BETWEEN @DT_INICIAL AND @DT_FINAL							 	
		AND ( CASE  WHEN LEN(@SerialNumber) = 0 THEN 1
					WHEN A.ID_EQUIPAMENTO = @SerialNumber AND A.TERMINAL = @TERMINAL THEN 1
			  ELSE 0 END ) = 1;

---------------------------------------------------------------------------------------------------------------------------------------------
SELECT @Versao_PAF    = VERSAO_APLICATIVO , 
       @RS_SH         = SH_RAZAO_SOCIAL   ,  
	   @CNPJ_SH       = SH_CNPJ           ,  
	   @Nome_PAF      = NOME_COMERCIAL    , 
	   @MD5           = MD5_PRINCIPAL_EXE , 
	   @Versao_ER_PAF = VERSAO_ER_PAF_ECF ,
	   @IE_SH         = '116982156119'    , 
	   @IM_SH         = '33582793' 
	   FROM dbo.LJ_ID_PAF_ECF 
	 WHERE VERSAO_APLICATIVO = rtrim(ltrim(@Version_APP)) ;
---------------------------------------------------------------------------------------------------------------------------------------------
--REGISTRO R01
--
Print 'REGISTRO R01'

if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
Begin 
INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL ) 
		SELECT	distinct 20 AS TIPO,
			'R01'+ 
			CONVERT(CHAR(20), ISNULL( A.ID_EQUIPAMENTO,''))      +
			CONVERT(CHAR(1), ISNULL(A.MF_ADICIONAL,''))          +
			CONVERT(CHAR(7), ISNULL(A.TIPO_ECF,''))              +
			ISNULL(CONVERT(CHAR(20), CASE WHEN UPPER(LTRIM(RTRIM(A.MARCA))) = 'DARUMA AUTOMAÇÃO' THEN 'DARUMA' ELSE A.MARCA END),'')                 +  --#6#
			isnull(REPLACE(CONVERT(CHAR(20), ISNULL(A.MODELO,'')), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.CODIGO_FILIAL + CAST(A.ID_IMPRESSORA AS VARCHAR) + ISNULL(A.ID_EQUIPAMENTO,'')  +	ISNULL(A.MF_ADICIONAL, '')+ A.TIPO_ECF + ISNULL(A.MARCA, '')+	ISNULL(A.MODELO, '')+ISNULL(A.FIRMWARE, '')+CONVERT(VARCHAR, ISNULL(A.DATA_HORA_SB, 0), 126)+	CAST(ISNULL(A.ECF, 0) AS VARCHAR)+ISNULL(A.CNPJ_ESTABELECIMENTO, '')+ISNULL(A.IE_ESTABELECIMENTO, ''))  THEN ' ' ELSE '?' END),'0') +	-- #2#
			isnull(CONVERT(CHAR(10), replace(FIRMWARE,'.','')) ,'')                                                                                                            + --#3#
			isnull(CASE WHEN RTRIM(LTRIM(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 112),'-',''))) = '20000101' THEN '00000000' ELSE  RTRIM(LTRIM(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 112),'-',''))) END,'')    +
			isnull(rtrim(ltrim(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 108),':',''))),'')                                                                      +
			right(replicate('0',3) + isnull(convert(varchar,A.ECF),'0'), 3)                                                                                                       +
			RIGHT(REPLICATE('0', 14) + RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(rtrim(ltrim(A.CNPJ_ESTABELECIMENTO)),''), '.', ''), '-', ''), '/', '')), 14)       +
 			--#4# RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(IE_ESTABELECIMENTO,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)   , 14)      + 
 			isnull(LEFT(CONVERT(CHAR(90), UPPER(IE_ESTABELECIMENTO))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		    RIGHT(REPLICATE('0', 14) + RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@CNPJ_SH,''), '.', ''), '-', ''), '/', '')), 14)                   +
		    --#4#RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@IE_SH,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)  , 14)                   +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@IE_SH))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		    --#4#RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@IM_SH,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)  , 14)                   +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@IM_SH))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@RS_SH))      + REPLICATE(' ', 14), 40 ) ,'')                                                  +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@Nome_PAF))   + REPLICATE(' ', 14), 40 ),'')                                                   +
		    isnull(LEFT(CONVERT(CHAR(10), UPPER(@Versao_PAF)) + REPLICATE(' ', 10), 10 ),'')                                                   +
		    isnull(LEFT(CONVERT(CHAR(32), UPPER(@MD5))        + REPLICATE(' ', 32), 32 ),'')                                                   +
		    isnull(RTRIM(REPLACE(CONVERT(CHAR(10), @DT_INICIAL, 112),'/','')),'')                                                            +
		    isnull(RTRIM(REPLACE(CONVERT(CHAR(10), @DT_FINAL, 112)  ,'/','')),'')                                                              +
			isnull(LEFT(CONVERT(VARCHAR, REPLACE(UPPER(@Versao_ER_PAF),'.','')) + REPLICATE(' ', 04), 04 ),'')
			AS REGISTRO,
			310, 
			@TERMINAL
		FROM  dbo.LOJA_IMPRESSORAS_FISCAIS A
		INNER JOIN 	LJ_DOCUMENTO_ECF B
		ON A.ID_EQUIPAMENTO = B.ID_EQUIPAMENTO    
		AND CONVERT(Varchar,(B.DATA_HORA_EMISSAO), 112) Between @DT_INICIAL AND @DT_FINAL
		WHERE A.CODIGO_FILIAL = @COD_FILIAL  
		and  A.ID_EQUIPAMENTO = @SerialNumber
End 
Else 
Begin 
      INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL ) 
					SELECT	distinct 20 AS TIPO,
			'R01'+ 
			CONVERT(CHAR(20), ISNULL( A.ID_EQUIPAMENTO,''))      +
			CONVERT(CHAR(1), ISNULL(A.MF_ADICIONAL,''))          +
			CONVERT(CHAR(7), ISNULL(A.TIPO_ECF,''))              +
			CONVERT(CHAR(20), ISNULL(A.Marca,''))                +
			isnull(REPLACE(CONVERT(CHAR(20), ISNULL(A.MODELO,'')), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.CODIGO_FILIAL + CAST(A.ID_IMPRESSORA AS VARCHAR) + ISNULL(A.ID_EQUIPAMENTO,'')  +	ISNULL(A.MF_ADICIONAL, '')+ A.TIPO_ECF + ISNULL(A.MARCA, '')+	ISNULL(A.MODELO, '')+ISNULL(A.FIRMWARE, '')+CONVERT(VARCHAR, ISNULL(A.DATA_HORA_SB, 0), 126)+	CAST(ISNULL(A.ECF, 0) AS VARCHAR)+ISNULL(A.CNPJ_ESTABELECIMENTO, '')+ISNULL(A.IE_ESTABELECIMENTO, ''))  THEN ' ' ELSE '?' END),'0') +	-- #2#
			isnull(CONVERT(CHAR(10), replace(FIRMWARE,'.','')) ,'')                                                                                                            +
			isnull(CASE WHEN RTRIM(LTRIM(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 112),'-',''))) = '20000101' THEN '00000000' ELSE  RTRIM(LTRIM(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 112),'-',''))) END,'')    +
			isnull(rtrim(ltrim(REPLACE(CONVERT(CHAR(10),A.DATA_HORA_SB, 108),':',''))),'')                                                                      +
			right(replicate('0',3) + isnull(convert(varchar,A.ECF),'0'), 3)                                                                                                       +
			RIGHT(REPLICATE('0', 14) + RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(rtrim(ltrim(A.CNPJ_ESTABELECIMENTO)),''), '.', ''), '-', ''), '/', '')), 14)       +
 			--#4#RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(IE_ESTABELECIMENTO,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)   , 14)      +
 			isnull(LEFT(CONVERT(CHAR(90), UPPER(IE_ESTABELECIMENTO))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		    RIGHT(REPLICATE('0', 14) + RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@CNPJ_SH,''), '.', ''), '-', ''), '/', '')), 14)                   +
		    --#4#RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@IE_SH,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)  , 14)                   +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@IE_SH))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		   --#4# RIGHT(RTRIM(REPLACE(REPLACE(REPLACE(ISNULL(@IM_SH,''), '.', ''), '-', ''), '/', '')) + REPLICATE(' ', 14)  , 14)                   +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@IM_SH))      + REPLICATE(' ', 14), 14 ) ,'')                                                  + --#4#
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@RS_SH))      + REPLICATE(' ', 14), 40 ) ,'')                                                  +
		    isnull(LEFT(CONVERT(CHAR(90), UPPER(@Nome_PAF))   + REPLICATE(' ', 14), 40 ),'')                                                   +
		    isnull(LEFT(CONVERT(CHAR(10), UPPER(@Versao_PAF)) + REPLICATE(' ', 10), 10 ),'')                                                   +
		    isnull(LEFT(CONVERT(CHAR(32), UPPER(@MD5))        + REPLICATE(' ', 32), 32 ),'')                                                   +
		    isnull(RTRIM(REPLACE(CONVERT(CHAR(10), @DT_INICIAL, 112),'/','')),'')                                                            +
		    isnull(RTRIM(REPLACE(CONVERT(CHAR(10), @DT_FINAL, 112)  ,'/','')),'')                                                              +
			isnull(LEFT(CONVERT(VARCHAR, REPLACE(UPPER(@Versao_ER_PAF),'.','')) + REPLICATE(' ', 04), 04 ),'')
			AS REGISTRO,
			310, 
			@TERMINAL
		FROM  dbo.LOJA_IMPRESSORAS_FISCAIS A
		INNER JOIN 	LJ_DOCUMENTO_ECF B
		ON A.ID_EQUIPAMENTO = B.ID_EQUIPAMENTO    
		AND CONVERT(Varchar,(B.DATA_HORA_EMISSAO), 112) Between @DT_INICIAL AND @DT_FINAL
		WHERE A.CODIGO_FILIAL = @COD_FILIAL ;
 End 
  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--'REGISTRO R02'
PRINT 'REGISTRO R02'

-- #1# (início)
if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
Begin 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL ) 
	SELECT	21 AS TIPO,
			'R02'                                            +  
			CONVERT(CHAR(20), ISNULL(C.ID_EQUIPAMENTO,''))     +
			ISNULL(C.MF_ADICIONAL,'')                          + 
			REPLACE(CONVERT(CHAR(20), ISNULL(I.MODELO,'')), ' ',	-- #2#
			CASE WHEN I.HASHOK = 1 AND LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + C.CODIGO_FILIAL + C.TERMINAL + CONVERT(VARCHAR, C.DATA_FISCAL, 126) + C.ID_EQUIPAMENTO + CAST(C.ECF AS VARCHAR) +	CAST(C.CF_INICIAL AS VARCHAR) + C.SERIE_NF + ISNULL(C.MF_ADICIONAL, ' ') + ISNULL(C.MODELO, '') + CAST(ISNULL(C.NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(C.QTDE_REDUCOES_Z, 0) AS VARCHAR) + CAST(ISNULL(C.CF_FINAL, 0) AS VARCHAR) +	CAST(ISNULL(C.CONTADOR_REINICIO_OPERACAO, 0) AS VARCHAR) + CONVERT(VARCHAR, ISNULL(C.DATA_HORA_REDUCAO_Z, GETDATE()), 126) + CAST(ISNULL(C.TOTAL_BRUTO, 0) AS VARCHAR) + ISNULL(C.RATEIA_DESCONTO_ISSQN, '' )) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(C.NUMERO_USUARIO,'1'))),2)            + 
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(C.QTDE_REDUCOES_Z,'0'))),6)           +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(C.CF_FINAL,'0'))),9)                  +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(C.CONTADOR_REINICIO_OPERACAO,0))),6)  +
			RTRIM(REPLACE(CONVERT(CHAR(8), C.DATA_FISCAL, 112),'/',''))                                   +
			(CASE	WHEN YEAR(ISNULL(C.DATA_HORA_REDUCAO_Z, CAST('19000101' AS DATETIME) )) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), C.DATA_HORA_REDUCAO_Z, 112),'/','')) ELSE REPLICATE('0', 08) END )  +
			(CASE	WHEN YEAR(ISNULL(C.DATA_HORA_REDUCAO_Z, CAST('19000101' AS DATETIME) )) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), C.DATA_HORA_REDUCAO_Z, 108),':','')) ELSE REPLICATE('0', 06) END )  + 
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),(C.TOTAL_BRUTO))),'.',''),14)  +	
			ISNULL(C.RATEIA_DESCONTO_ISSQN, '') AS REGISTRO,
			101,
			@TERMINAL	
	FROM dbo.LOJA_CONTROLE_FISCAL C
	INNER JOIN @LOJA_IMPRESSORAS_FISCAIS I
	ON C.CODIGO_FILIAL = I.CODIGO_FILIAL 
	AND C.ID_EQUIPAMENTO = I.ID_EQUIPAMENTO 
	WHERE C.DATA_FISCAL BETWEEN  @DT_INICIAL AND @DT_FINAL 
	and C.CODIGO_FILIAL  = @COD_FILIAL
	and C.ID_EQUIPAMENTO = @SerialNumber ; 
END 

ELSE 

BEGIN 
INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL ) 
	SELECT	21 AS TIPO,
			'R02'                                            +  
			CONVERT(CHAR(20), ISNULL(C.ID_EQUIPAMENTO,''))     +
			ISNULL(C.MF_ADICIONAL,'')                          + 
			REPLACE(CONVERT(CHAR(20), ISNULL(I.MODELO,'')), ' ',	-- #2#
			CASE WHEN (I.HASHOK = 1 OR LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + C.CODIGO_FILIAL + C.TERMINAL + CONVERT(VARCHAR, C.DATA_FISCAL, 126) + C.ID_EQUIPAMENTO + CAST(C.ECF AS VARCHAR) +	CAST(C.CF_INICIAL AS VARCHAR) + C.SERIE_NF + ISNULL(C.MF_ADICIONAL, ' ') + ISNULL(C.MODELO, '') + CAST(ISNULL(C.NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(C.QTDE_REDUCOES_Z, 0) AS VARCHAR) + CAST(ISNULL(C.CF_FINAL, 0) AS VARCHAR) +	CAST(ISNULL(C.CONTADOR_REINICIO_OPERACAO, 0) AS VARCHAR) + CONVERT(VARCHAR, ISNULL(C.DATA_HORA_REDUCAO_Z, GETDATE()), 126) + CAST(ISNULL(C.TOTAL_BRUTO, 0) AS VARCHAR) + ISNULL(C.RATEIA_DESCONTO_ISSQN, '' ))) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(C.NUMERO_USUARIO,'1'))),2)            + 
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), ISNULL(C.QTDE_REDUCOES_Z,'0'))),6)           +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(C.CF_FINAL,'0'))),9)                  +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(C.CONTADOR_REINICIO_OPERACAO,0))),6)  +
			RTRIM(REPLACE(CONVERT(CHAR(10), C.DATA_FISCAL, 112),'/',''))                                   +
			(CASE	WHEN YEAR(ISNULL(C.DATA_HORA_REDUCAO_Z, CAST('19000101' AS DATETIME) )) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), C.DATA_HORA_REDUCAO_Z, 112),'/','')) ELSE REPLICATE('0', 08) END )  +
			(CASE	WHEN YEAR(ISNULL(C.DATA_HORA_REDUCAO_Z, CAST('19000101' AS DATETIME) )) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), C.DATA_HORA_REDUCAO_Z, 108),':','')) ELSE REPLICATE('0', 06) END )  + 
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),(C.TOTAL_BRUTO))),'.',''),14)  +	
			ISNULL(C.RATEIA_DESCONTO_ISSQN, '') AS REGISTRO,
			101,
			@TERMINAL	
	FROM dbo.LOJA_CONTROLE_FISCAL C
	INNER JOIN @LOJA_IMPRESSORAS_FISCAIS I
	ON C.CODIGO_FILIAL = I.CODIGO_FILIAL AND C.ID_EQUIPAMENTO = I.ID_EQUIPAMENTO 
	WHERE C.DATA_FISCAL BETWEEN  @DT_INICIAL AND @DT_FINAL 
	And C.CODIGO_FILIAL =@COD_FILIAL;
END  
-- #1# (fim)


--REGISTRO R03 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRINT 'Registro R03'
DECLARE @CRZ INT 


if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
BEGIN 
--SELECT 	@CRZ = RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(CONTADOR_REINICIO_OPERACAO,0))),6) -- #7#
SELECT	@CRZ = RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(QTDE_REDUCOES_Z,0))),6) -- #7#  
		FROM DBO.LOJA_CONTROLE_FISCAL 
		WHERE DATA_FISCAL BETWEEN  @DT_INICIAL AND @DT_FINAL 
		AND CODIGO_FILIAL = @COD_FILIAL
		AND ID_EQUIPAMENTO = @SERIALNUMBER 

	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL) 
	SELECT 	22 AS TIPO,
		    'R03'                                                                                         +
		    CONVERT(CHAR(20), ISNULL(SERIE_ECF,''))                                                       +
			MF_ADICIONAL                                                                                  +
			REPLACE(CONVERT(CHAR(20), MODELO_ECF), ' ', 	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + SERIE_ECF + CAST(MF_ADICIONAL AS VARCHAR) +  MODELO_ECF + CAST(USUARIO_ECF AS VARCHAR)  + CAST(CRZ AS VARCHAR)  + CAST(TOTALIZADOR_PARCIAL AS VARCHAR)  + CAST(VALOR_ACUMULADO AS VARCHAR) +	ISNULL(CODIGO_FILIAL, '')  + CAST(ISNULL(ID_DOCUMENTO_ECF, 0) AS VARCHAR)) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), USUARIO_ECF)),2)                            +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), CRZ)),6)                                    + 
			LEFT(REPLACE(RTRIM(CONVERT(CHAR(7),TOTALIZADOR_PARCIAL)),'.','') + REPLICATE(' ', 7), 7)      +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(14),VALOR_ACUMULADO)),'.',''),13) REGISTRO,
			73 AS LIMITE,
			@TERMINAL AS TERMINAL
	        FROM DBO.LJ_ECF_RZ_DETALHE 
			WHERE CODIGO_FILIAL = @COD_FILIAL 
			AND SERIE_ECF = @SERIALNUMBER 
			-- #7# - Início
			--AND CRZ = @CRZ ; -- #7# 
			AND CRZ IN ( select QTDE_REDUCOES_Z  -- #8# 
			--SELECT RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(CONTADOR_REINICIO_OPERACAO,0))),6)   --#8# 
						FROM DBO.LOJA_CONTROLE_FISCAL 
						WHERE DATA_FISCAL BETWEEN @DT_INICIAL AND @DT_FINAL 
							  AND CODIGO_FILIAL  = @COD_FILIAL
							  AND ID_EQUIPAMENTO = @SERIALNUMBER);
			-- #7# - Fim

END 
ELSE 
BEGIN 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL) 
	SELECT 	22 AS TIPO,
		    'R03'                                                                                         + 
		    CONVERT(CHAR(20), ISNULL(SERIE_ECF,''))                                                       +
			MF_ADICIONAL                                                                                  +
			REPLACE(CONVERT(CHAR(20), MODELO_ECF), ' ',	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + SERIE_ECF + CAST(MF_ADICIONAL AS VARCHAR) +  MODELO_ECF + CAST(USUARIO_ECF AS VARCHAR)  + CAST(CRZ AS VARCHAR)  + CAST(TOTALIZADOR_PARCIAL AS VARCHAR)   +  CAST(VALOR_ACUMULADO AS VARCHAR) +	ISNULL(CODIGO_FILIAL, '') +	CAST(ISNULL(ID_DOCUMENTO_ECF, 0) AS VARCHAR)) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), USUARIO_ECF)),2)                            +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), CRZ)),6)                                    + 
			LEFT(REPLACE(RTRIM(CONVERT(CHAR(7),TOTALIZADOR_PARCIAL)),'.','') + REPLICATE(' ', 7), 7)      +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(14),VALOR_ACUMULADO)),'.',''),13) REGISTRO,
			73 AS LIMITE,
			@TERMINAL AS TERMINAL
	        From dbo.LJ_ECF_RZ_DETALHE 
			where CODIGO_FILIAL = @COD_FILIAL 
			and CONVERT(Varchar,(DATA_PARA_TRANSFERENCIA), 112) BETWEEN  @DT_INICIAL AND @DT_FINAL ;
END 
	
-- REGISTRO R04 -----------------------------------------------------------------------------------------------------------------------------------------------------------
print 'Registro R04'

if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
BEGIN 
INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL) 
	SELECT	24 AS TIPO,
			'R04'																																													+ 
			left(REPLACE(RTRIM(CONVERT(CHAR(20),  ISNULL(ID_EQUIPAMENTO, ' '))),'.','')+REPLICATE(' ', 20) ,20)																																						+
			MF_ADICIONAL																																											+
			REPLACE(CONVERT(CHAR(20), Isnull(MODELO,'')), ' ',	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL + CAST(ID_DOCUMENTO_ECF AS VARCHAR) + ID_EQUIPAMENTO + MF_ADICIONAL +	ISNULL(MODELO, '') + CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(CCF, 0) AS VARCHAR) +	CAST(ISNULL(COO, 0) AS VARCHAR) + CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126) + CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR) + CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR) + ISNULL(TIPO_DESCONTO_SUBTOTAL, '') +	CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR) + CAST(CANCELADO AS VARCHAR) + CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR) + ISNULL(ORDEM_DESC_ACRESC, '')  + ISNULL(NOME_CLIENTE, '') + ISNULL(CPF_CNPJ_CLIENTE, '') + CAST(ISNULL(GNF, 0) AS VARCHAR) +	CAST(ISNULL(GRG, 0) AS VARCHAR) +CAST(ISNULL(CDC, 0) AS VARCHAR) + DENOMINACAO_DOCUMENTO +	CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126) +ISNULL(CNPJ_CREDENCIADORA, '') +	TIPO_ECF +	ISNULL(MARCA, '') +	CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR) + ISNULL(TITULO, '') +	ISNULL(CNPJ_ARREDONDAR, '')) THEN ' ' ELSE '?' END)  +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(NUMERO_USUARIO,'1'))),2)                                                                                                       + 
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(CCF,'0'))),9)                                                                                                                  +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(COO,'0'))),9)                                                                                                                  +
			--#5# (CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_HORA_EMISSAO, 112),'/','')) ELSE REPLICATE(' ', 08) END )    +
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_FISCAL, 112),'/','')) ELSE REPLICATE(' ', 08) END )    + --#5#
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14), ISNULL(VALOR_SUBTOTAL, 0))),'.',''),14)																						+
			replace(CASE WHEN DESCONTO_SUBTOTAL > 0 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),ISNULL(DESCONTO_SUBTOTAL, 0))),'.',''),13)  ELSE '0000000000000' END ,'-','0')   +
		    'V'                                                                                                                                                                                     +
			replace(CASE WHEN DESCONTO_SUBTOTAL < 0 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),  ISNULL(DESCONTO_SUBTOTAL, 0))),'.',''),13)  ELSE '0000000000000' END,'-','0')	+
		    'V'                                                                                                                                                                                     +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),ISNULL(VALOR_TOTAL_LIQ, 0))),'.',''),14)                                                                                      +
			CASE WHEN ISNULL(CANCELADO,0) = 1 THEN 'S' ELSE 'N' END                                                                                                                                 +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),  ISNULL(CANC_ACRESC_SUBTOTAL, '0'))),'.',''),13)	                                                                            +
			ISNULL(ORDEM_DESC_ACRESC,' ')                                                                                                                                                           +
			RIGHT(REPLACE(RTRIM(CONVERT(CHAR(40),ISNULL(NOME_CLIENTE, ''))),'.','')+ REPLICATE(' ', 40)  ,40)                                                                                       +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),ISNULL(CPF_CNPJ_CLIENTE, ''))),'.',''),14) AS REGISTRO,
			191 AS LIMITE,
			@TERMINAL AS TERMINAL
	    	FROM dbo.LJ_DOCUMENTO_ECF 
		--#5#WHERE CONVERT(Varchar,(DATA_HORA_EMISSAO), 112) Between @DT_INICIAL  AND   @DT_FINAL
		WHERE CONVERT(Varchar,(DATA_FISCAL), 112) Between @DT_INICIAL  AND   @DT_FINAL --#5#
		AND CODIGO_FILIAL   = @COD_FILIAL
		AND ID_EQUIPAMENTO = @SerialNumber 
		and DENOMINACAO_DOCUMENTO = 'CF';
END 
ELSE 
BEGIN 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL) 
	SELECT	24 AS TIPO,
			'R04'																																													+ 
			left(REPLACE(RTRIM(CONVERT(CHAR(20),  ISNULL(ID_EQUIPAMENTO, ' '))),'.','')+REPLICATE(' ', 20) ,20)	                                                                                    +
			MF_ADICIONAL																																											+
			REPLACE(CONVERT(CHAR(20), Isnull(MODELO,'')), ' ',	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL + CAST(ID_DOCUMENTO_ECF AS VARCHAR) + ID_EQUIPAMENTO + MF_ADICIONAL +	ISNULL(MODELO, '') + CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(CCF, 0) AS VARCHAR) +	CAST(ISNULL(COO, 0) AS VARCHAR) + CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126) + CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR) + CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR) + ISNULL(TIPO_DESCONTO_SUBTOTAL, '') +	CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR) + CAST(CANCELADO AS VARCHAR) + CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR) + ISNULL(ORDEM_DESC_ACRESC, '')  + ISNULL(NOME_CLIENTE, '') + ISNULL(CPF_CNPJ_CLIENTE, '') + CAST(ISNULL(GNF, 0) AS VARCHAR) +	CAST(ISNULL(GRG, 0) AS VARCHAR) +CAST(ISNULL(CDC, 0) AS VARCHAR) + DENOMINACAO_DOCUMENTO +	CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126) +ISNULL(CNPJ_CREDENCIADORA, '') +	TIPO_ECF +	ISNULL(MARCA, '') +	CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR) + ISNULL(TITULO, '') +	ISNULL(CNPJ_ARREDONDAR, '')) THEN ' ' ELSE '?' END)  +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(NUMERO_USUARIO,'01'))),2)                                                                                                       + 
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(CCF,'0'))),9)                                                                                                                  +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(06), ISNULL(COO,'0'))),9)                                                                                                                  +
			--#5#(CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_HORA_EMISSAO, 112),'/','')) ELSE REPLICATE(' ', 08) END )    +
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_FISCAL, 112),'/','')) ELSE REPLICATE(' ', 08) END )    + --#5#
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14), ISNULL(VALOR_SUBTOTAL, 0))),'.',''),14)																						+
			replace(CASE WHEN DESCONTO_SUBTOTAL > 0 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),ISNULL(DESCONTO_SUBTOTAL, 0))),'.',''),13)  ELSE '0000000000000' END ,'-','0')   +
		    case when DESCONTO_SUBTOTAL > 0  then 'V' else ' ' end                                                                                                                                  +
			replace(CASE WHEN DESCONTO_SUBTOTAL < 0 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),  ISNULL(DESCONTO_SUBTOTAL, 0))),'.',''),13)  ELSE '0000000000000' END,'-','0')  +
		    CASE WHEN DESCONTO_SUBTOTAL < 0  THEN 'V' ELSE ' ' END                                                                                                                                  +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),ISNULL(VALOR_TOTAL_LIQ, 0))),'.',''),14)                                                                                      +
			CASE WHEN ISNULL(CANCELADO,0) = 1 THEN 'S' ELSE 'N' END                                                                                                                                 +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13),  ISNULL(CANC_ACRESC_SUBTOTAL, '0'))),'.',''),13)	                                                                            +
			ISNULL(ORDEM_DESC_ACRESC,' ')                                                                                                                                                           +
			LEFT(REPLACE(RTRIM(CONVERT(CHAR(40),ISNULL(NOME_CLIENTE, ''))),'.','')+ REPLICATE(' ', 40), 40)                                                                                        +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(CHAR(14),ISNULL(CPF_CNPJ_CLIENTE, ''))),'.',''),14) AS REGISTRO,
			191 AS LIMITE,
			@TERMINAL AS TERMINAL
	    	FROM dbo.LJ_DOCUMENTO_ECF 
		--#5#WHERE CONVERT(Varchar,(DATA_HORA_EMISSAO), 112) Between @DT_INICIAL  AND   @DT_FINAL
		WHERE CONVERT(Varchar,(DATA_FISCAL), 112) Between @DT_INICIAL  AND   @DT_FINAL --#5#
		AND CODIGO_FILIAL =@COD_FILIAL 
		and DENOMINACAO_DOCUMENTO = 'CF' ;
END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
--REGISTRO R05
PRINT 'REGISTRO R05'

if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
BEGIN 
INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT	25 AS TIPO,
			'R05'                                                                                                                                 + 
			CONVERT(CHAR(20), SERIE_ECF )                                                                                                         +
			A.MF_ADICIONAL                                                                                                                          +
			REPLACE(CONVERT(CHAR(20), MODELO_ECF), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + SERIE_ECF + A.MF_ADICIONAL + CAST(USUARIO_ECF AS VARCHAR) + A.COO + CAST(ITEM AS VARCHAR) + MODELO_ECF + CCF_ + COD_PRODUTO_CUPOM + DESC_PROD_CUPOM +	CAST(QTDE AS VARCHAR) +	UNIDADE +	CAST(VALOR_UNIT AS VARCHAR) + CAST(DESCONTO_ITEM AS VARCHAR) + CAST(ACRES_ITEM AS VARCHAR) + CAST(VALOR_TOTAL_LIQ_ITEM AS VARCHAR) + TOTALIZADOR + ITEM_CANCELADO +	CAST(QTDE_CANC AS VARCHAR) + CAST(VALOR_CANC AS VARCHAR) + CAST(CANC_ACRESC_ITEM AS VARCHAR) + IAT + CAST(PRODUCAO_PROPRIA AS VARCHAR) + CAST(DECIMAIS_QTDE AS VARCHAR) + CAST(DECIMAIS_VALOR_UNIT AS VARCHAR) + ISNULL(A.CODIGO_FILIAL, '') + CAST(ISNULL(A.ID_DOCUMENTO_ECF, '0') AS VARCHAR)) THEN ' ' ELSE '?' END)  +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), USUARIO_ECF)),2)                                                                    + 
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.COO)),9)                                                                            +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), CCF_)),9)                                                                           +
			RIGHT(REPLICATE('0', 3) + RTRIM(CONVERT(CHAR(03), ITEM)),3)                                                                           +
			LEFT(LTRIM(CONVERT(CHAR(14), COD_PRODUTO_CUPOM)) + REPLICATE('', 14), 14)                                                             +
			--#4# LEFT(LTRIM(CONVERT(CHAR(100), DESC_PROD_CUPOM))  + REPLICATE('', 100), 100)                                                     +
			LEFT(LTRIM(CONVERT(CHAR(100), DBO.FX_REPLACE_CARACTER_ESPECIAL(DESC_PROD_CUPOM)))  + REPLICATE('', 100), 100)                         + -- #4# Retirar acentuação erro no validor 			
			RIGHT(REPLICATE('0', 07) + REPLACE(RTRIM(CONVERT(CHAR(07),	( CASE WHEN QTDE > 0 THEN QTDE * 100 ELSE '0' END ) )),'.',''),07)        +
			LEFT(LTRIM(CONVERT(CHAR(03), UNIDADE)) + REPLICATE(' ', 03), 03)                                                                      +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,VALOR_UNIT)),'.',''),08)                                                     +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,DESCONTO_ITEM)),'.',''),08)                                                  +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,ACRES_ITEM)),'.',''),08)                                                     +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(VARCHAR,VALOR_TOTAL_LIQ_ITEM)),'.',''),14)                                           +
			RIGHT(REPLICATE('0', 7) + REPLACE(RTRIM(CONVERT(VARCHAR,TOTALIZADOR)),'.',''),7)                                                      +
			ITEM_CANCELADO																														  +
			REPLICATE('0', 7)                                                                                                                     +
			REPLICATE('0', 13)                                                                                                                    +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(VARCHAR,CANC_ACRESC_ITEM)),'.',''),13)                                               +
			CONVERT(VARCHAR,IAT)                                                                                                                  +
			Case When PRODUCAO_PROPRIA = 0 then 'T' else 'P' End                                                                                  +
			convert(varchar,isnull(DECIMAIS_QTDE,'0'))																							  +
			convert(varchar,isnull(DECIMAIS_VALOR_UNIT,'0'))
			 AS REGISTRO,
			268 AS LIMITE,
			@TERMINAL AS TERMINAL
			FROM dbo.LJ_ECF_ITEM A
			--#5#[Inicio]
			-- Where CONVERT(Varchar,(DATA_PARA_TRANSFERENCIA), 112) Between @DT_INICIAL AND @DT_FINAL			
			-- and CODIGO_FILIAL = @COD_FILIAL  and SERIE_ECF = @SerialNumber ;
			INNER JOIN dbo.LJ_DOCUMENTO_ECF B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL
			AND A.SERIE_ECF = B.ID_EQUIPAMENTO AND A.ID_DOCUMENTO_ECF = B.ID_DOCUMENTO_ECF		
		WHERE 
			B.DENOMINACAO_DOCUMENTO = 'CF' AND B.CCF > 0
			AND B.DATA_FISCAL BETWEEN @DT_INICIAL AND @DT_FINAL
			AND B.CODIGO_FILIAL = @Cod_Filial  --#5#
			and SERIE_ECF = @SerialNumber ;
		--#5#[Fim]		
END 
Else
BEGIN 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT	25 AS TIPO,
			'R05'                                                                                                                                 + 
			CONVERT(CHAR(20), SERIE_ECF )                                                                                                         +
			A.MF_ADICIONAL                                                                                                                          +
			REPLACE(CONVERT(CHAR(20), MODELO_ECF), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + SERIE_ECF + A.MF_ADICIONAL + CAST(USUARIO_ECF AS VARCHAR) + A.COO + CAST(ITEM AS VARCHAR) + MODELO_ECF + CCF_ + COD_PRODUTO_CUPOM + DESC_PROD_CUPOM +	CAST(QTDE AS VARCHAR) +	UNIDADE +	CAST(VALOR_UNIT AS VARCHAR) + CAST(DESCONTO_ITEM AS VARCHAR) + CAST(ACRES_ITEM AS VARCHAR) + CAST(VALOR_TOTAL_LIQ_ITEM AS VARCHAR) + TOTALIZADOR + ITEM_CANCELADO +	CAST(QTDE_CANC AS VARCHAR) + CAST(VALOR_CANC AS VARCHAR) + CAST(CANC_ACRESC_ITEM AS VARCHAR) + IAT + CAST(PRODUCAO_PROPRIA AS VARCHAR) + CAST(DECIMAIS_QTDE AS VARCHAR) + CAST(DECIMAIS_VALOR_UNIT AS VARCHAR) + ISNULL(A.CODIGO_FILIAL, '') + CAST(ISNULL(A.ID_DOCUMENTO_ECF, '0') AS VARCHAR)) THEN ' ' ELSE '?' END)  +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), USUARIO_ECF)),2)                                                                    + 
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.COO)),9)                                                                            +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), CCF_)),9)                                                                           +
			RIGHT(REPLICATE('0', 3) + RTRIM(CONVERT(CHAR(03), ITEM)),3)                                                                           +
			LEFT(LTRIM(CONVERT(CHAR(14), COD_PRODUTO_CUPOM)) + REPLICATE('', 14), 14)                                                             +
			-- #4# LEFT(LTRIM(CONVERT(CHAR(100), DESC_PROD_CUPOM))  + REPLICATE('', 100), 100)                                                    +
			LEFT(LTRIM(CONVERT(CHAR(100), DBO.FX_REPLACE_CARACTER_ESPECIAL(DESC_PROD_CUPOM)))  + REPLICATE('', 100), 100)                         + --#4#
			RIGHT(REPLICATE('0', 07) + REPLACE(RTRIM(CONVERT(CHAR(07),	( CASE WHEN QTDE > 0 THEN QTDE * 100 ELSE '0' END ) )),'.',''),07)        +
			LEFT(LTRIM(CONVERT(CHAR(03), UNIDADE)) + REPLICATE(' ', 03), 03)                                                                      +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,VALOR_UNIT)),'.',''),08)                                                     +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,DESCONTO_ITEM)),'.',''),08)                                                  +
			RIGHT(REPLICATE('0', 08) + REPLACE(RTRIM(CONVERT(VARCHAR,ACRES_ITEM)),'.',''),08)                                                     +
			RIGHT(REPLICATE('0', 14) + REPLACE(RTRIM(CONVERT(VARCHAR,VALOR_TOTAL_LIQ_ITEM)),'.',''),14)                                           +
			RIGHT(REPLICATE('0', 7) + REPLACE(RTRIM(CONVERT(VARCHAR,TOTALIZADOR)),'.',''),7)                                                      +
			ITEM_CANCELADO																														  +
			REPLICATE('0', 7)                                                                                                                     +
			REPLICATE('0', 13)                                                                                                                    +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(VARCHAR,CANC_ACRESC_ITEM)),'.',''),13)                                               +
			CONVERT(VARCHAR,IAT)                                                                                                                  +
			Case When PRODUCAO_PROPRIA = 0 then 'T' else 'P' End                                                                                  +
			convert(varchar,isnull(DECIMAIS_QTDE,'0'))																							  +
			convert(varchar,isnull(DECIMAIS_VALOR_UNIT,'0'))
			 AS REGISTRO,
			268 AS LIMITE,
			@TERMINAL AS TERMINAL
			FROM dbo.LJ_ECF_ITEM A
			--#5# [Inicio]
			-- Where CONVERT(Varchar,(DATA_PARA_TRANSFERENCIA), 112) Between @DT_INICIAL AND @DT_FINAL and CODIGO_FILIAL = @COD_FILIAL;
				INNER JOIN dbo.LJ_DOCUMENTO_ECF B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL
			AND A.SERIE_ECF = B.ID_EQUIPAMENTO AND A.ID_DOCUMENTO_ECF = B.ID_DOCUMENTO_ECF		
		WHERE 
			B.DENOMINACAO_DOCUMENTO = 'CF' AND B.CCF > 0
			AND B.DATA_FISCAL BETWEEN @DT_INICIAL AND @DT_FINAL
			AND B.CODIGO_FILIAL = @Cod_Filial
			and SERIE_ECF = @SerialNumber ;			
END 

--REGISTRO R06 --------------------------------------------------------------------------------------------------------------------------------------
Print 'Registro R06'	

 if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
	Begin 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT 	26 AS TIPO,
			'R06'                                                                           +
			CONVERT(CHAR(20), ID_EQUIPAMENTO )                                              +
			MF_Adicional                                                                    +
			REPLACE(CONVERT(CHAR(20), ISNULL(MODELO,'')), ' ',	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER  +	CODIGO_FILIAL +	CAST(ID_DOCUMENTO_ECF AS VARCHAR) +	ID_EQUIPAMENTO + MF_ADICIONAL + ISNULL(MODELO, '') + CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(CCF, 0) AS VARCHAR) +	CAST(ISNULL(COO, 0) AS VARCHAR) + CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126)+	CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR) + CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR) + ISNULL(TIPO_DESCONTO_SUBTOTAL, '') +	CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR) + CAST(CANCELADO AS VARCHAR) + CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR) + ISNULL(ORDEM_DESC_ACRESC,'') + ISNULL(NOME_CLIENTE,'') +	ISNULL(CPF_CNPJ_CLIENTE,'') + CAST(ISNULL(GNF, 0) AS VARCHAR) + CAST(ISNULL(GRG, 0) AS VARCHAR) + CAST(ISNULL(CDC, 0) AS VARCHAR) +	DENOMINACAO_DOCUMENTO +	CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126) +	ISNULL(CNPJ_CREDENCIADORA, '') + TIPO_ECF + ISNULL(MARCA, '') + CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR) + ISNULL(TITULO, '') + ISNULL(CNPJ_ARREDONDAR, '')) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(NUMERO_USUARIO,1))),2) +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), ISNULL(COO,0) )),9)           +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(GNF,0) )),6)           +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(GRG,0) )),6)           +
			RIGHT(REPLICATE('0', 4) + RTRIM(CONVERT(CHAR(04), ISNULL(CDC,0) )),4)           +
			LEFT(CONVERT(CHAR(02), LTRIM(DENOMINACAO_DOCUMENTO)) + REPLICATE(' ', 02), 02)  +
			--#5# [Inicio]
			--(CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_HORA_EMISSAO, 112),'/','')) ELSE REPLICATE(' ', 08) END ) +
			--(CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), DATA_HORA_EMISSAO, 108),':','')) ELSE REPLICATE(' ', 06) END ) AS REGISTRO,
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_FISCAL, 112),'/','')) ELSE REPLICATE(' ', 08) END ) +
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), DATA_FISCAL, 108),':','')) ELSE REPLICATE(' ', 06) END ) AS REGISTRO,
			--#5# [Fim]
			84 AS LIMITE,
			@TERMINAL AS TERMINAL
			from dbo.LJ_DOCUMENTO_ECF
			--Where CONVERT(Varchar,(DATA_HORA_EMISSAO), 112) Between @DT_INICIAL AND @DT_FINAL
			Where CONVERT(Varchar,(DATA_FISCAL), 112) Between @DT_INICIAL AND @DT_FINAL
			and CODIGO_FILIAL = @COD_FILIAL 
			and ID_EQUIPAMENTO = @SerialNumber 
			and DENOMINACAO_DOCUMENTO IN ('RG','CM','RV','CC','CN','NC') ;
	End 
Else
Begin 
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT 	26 AS TIPO,
			'R06'                                                                           +
			CONVERT(CHAR(20), ID_EQUIPAMENTO )                                              +
			MF_Adicional                                                                    +
			REPLACE(CONVERT(CHAR(20), ISNULL(MODELO,'')), ' ',	-- #2#
			CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER  +	CODIGO_FILIAL +	CAST(ID_DOCUMENTO_ECF AS VARCHAR) +	ID_EQUIPAMENTO + MF_ADICIONAL + ISNULL(MODELO, '') + CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR) + CAST(ISNULL(CCF, 0) AS VARCHAR) +	CAST(ISNULL(COO, 0) AS VARCHAR) + CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126)+	CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR) + CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR) + ISNULL(TIPO_DESCONTO_SUBTOTAL, '') +	CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR) + CAST(CANCELADO AS VARCHAR) + CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR) + ISNULL(ORDEM_DESC_ACRESC,'') + ISNULL(NOME_CLIENTE,'') +	ISNULL(CPF_CNPJ_CLIENTE,'') + CAST(ISNULL(GNF, 0) AS VARCHAR) + CAST(ISNULL(GRG, 0) AS VARCHAR) + CAST(ISNULL(CDC, 0) AS VARCHAR) +	DENOMINACAO_DOCUMENTO +	CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126) +	ISNULL(CNPJ_CREDENCIADORA, '') + TIPO_ECF + ISNULL(MARCA, '') + CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR) + ISNULL(TITULO, '') + ISNULL(CNPJ_ARREDONDAR, '')) THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), ISNULL(NUMERO_USUARIO,1))),2) +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), ISNULL(COO,0) )),9)           +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(GNF,0) )),6)           +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), ISNULL(GRG,0) )),6)           +
			RIGHT(REPLICATE('0', 4) + RTRIM(CONVERT(CHAR(04), ISNULL(CDC,0) )),4)           +
			LEFT(CONVERT(CHAR(02), LTRIM(DENOMINACAO_DOCUMENTO)) + REPLICATE(' ', 02), 02)  +
			--#5#(CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_HORA_EMISSAO, 112),'/','')) ELSE REPLICATE(' ', 08) END ) +
			--#5#(CASE WHEN YEAR(ISNULL(DATA_HORA_EMISSAO, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), DATA_HORA_EMISSAO, 108),':','')) ELSE REPLICATE(' ', 06) END ) AS REGISTRO,
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(10), DATA_FISCAL, 112),'/','')) ELSE REPLICATE(' ', 08) END ) +
			(CASE WHEN YEAR(ISNULL(DATA_FISCAL, CAST('19000101' AS DATETIME))) <> 1900 THEN RTRIM(REPLACE(CONVERT(CHAR(08), DATA_FISCAL, 108),':','')) ELSE REPLICATE(' ', 06) END ) AS REGISTRO,			
			84 AS LIMITE,
			@TERMINAL AS TERMINAL
			from dbo.LJ_DOCUMENTO_ECF
			--#5# Where CONVERT(Varchar,(DATA_HORA_EMISSAO), 112) Between @DT_INICIAL AND @DT_FINAL
			Where CONVERT(Varchar,(DATA_FISCAL), 112) Between @DT_INICIAL AND @DT_FINAL --#5#
			and CODIGO_FILIAL = @COD_FILIAL 
			and DENOMINACAO_DOCUMENTO IN ('RG','CM','RV','CC','CN','NC') ; 
end 

-- REGISTRO R07 ------------------------------------------------------------------------------------------------------------------------------------------------
PRINT 'REGISTRO R07'	

 if (@Verifica_Reducao = 1 or @Local_uf in('MA','PI','ES'))
	Begin
	INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT	27 AS TIPO,
			'R07'                                                                                            + 
			CONVERT(CHAR(20), A.SERIE_ECF )                                                                  +
			A.MF_ADICIONAL                                                                                   +
			REPLACE(CONVERT(CHAR(20), A.MODELO_ECF), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER +A.SERIE_ECF + A.MF_ADICIONAL + CAST(A.USUARIO_ECF AS VARCHAR) +	A.COO + PARCELA +	A.MODELO_ECF + A.CCF + A.GNF + A.PAGAMENTO + CAST(A.VALOR_PAGO AS VARCHAR) + A.ESTORNO_PGTO +	CAST(A.VALOR_ESTORNADO AS VARCHAR))  THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), A.USUARIO_ECF)),2)                             +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.COO)),9)                                     +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.CCF)),9)                                     +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.GNF)),6)                                     +
			Case when A.PAGAMENTO = '' THEN '               ' ELSE LEFT(LTRIM(CONVERT(CHAR(15), A.PAGAMENTO)) + REPLICATE(' ', 15), 15) END  +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13), SUM(A.VALOR_PAGO)	)),'.',''),13)     +
			CASE WHEN B.CANCELADO = 1 THEN 'S' ELSE 'N' END                                                +
			CASE WHEN B.CANCELADO = 1 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13), SUM(A.VALOR_PAGO)	)),'.',''),13) ELSE '0' END  AS REGISTRO,
			106 AS LIMITE,
			@TERMINAL AS TERMINAL
		    FROM dbo.LJ_ECF_PAGAMENTO A
			INNER JOIN LJ_DOCUMENTO_ECF B
			ON A.CODIGO_FILIAL     = B.CODIGO_FILIAL 
			AND A.ID_DOCUMENTO_ECF = B.ID_DOCUMENTO_ECF 
			--#5#[Inicio]
			--Where CONVERT(Varchar,(A.DATA_PARA_TRANSFERENCIA), 112) Between @DT_INICIAL AND @DT_FINAL
			Where CONVERT(Varchar,(B.DATA_FISCAL), 112) Between @DT_INICIAL AND @DT_FINAL --#5#
			AND A.CODIGO_FILIAL = @COD_FILIAL 
			and A.SERIE_ECF     = @SerialNumber
			AND ISNULL(A.PAGAMENTO,'') <> ''
			GROUP BY A.ESTORNO_PGTO,B.CANCELADO,A.MF_ADICIONAL,CONVERT(CHAR(20), A.SERIE_ECF ) , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.COO)),6)  , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.CCF)),6) , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.GNF)),6)  , LEFT(LTRIM(CONVERT(CHAR(15), A.PAGAMENTO)) + REPLICATE(' ', 15), 15) , 
    		 RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), A.USUARIO_ECF)),2), CONVERT(CHAR(20), A.MODELO_ECF) ,
			 A.LX_HASH,A.SERIE_ECF,A.COO,A.parcela,A.MODELO_ECF,A.CCF,A.GNF,A.PAGAMENTO,A.VALOR_PAGO,A.VALOR_ESTORNADO,A.USUARIO_ECF
			 ORDER BY A.COO ;
  End 
Else 
  Begin 
  INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL)
	SELECT	27 AS TIPO,
			'R07'                                                                                            + 
			CONVERT(CHAR(20), A.SERIE_ECF )                                                                  +
			A.MF_ADICIONAL                                                                                   +
			REPLACE(CONVERT(CHAR(20), A.MODELO_ECF), ' ',	-- #2#
			CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER +A.SERIE_ECF + A.MF_ADICIONAL + CAST(A.USUARIO_ECF AS VARCHAR) +	A.COO + A.PARCELA +	A.MODELO_ECF + A.CCF + A.GNF + A.PAGAMENTO + CAST(A.VALOR_PAGO AS VARCHAR) + A.ESTORNO_PGTO +	CAST(A.VALOR_ESTORNADO AS VARCHAR))  THEN ' ' ELSE '?' END) +	-- #2#
			RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), A.USUARIO_ECF)),2)                             +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.COO)),9)                                     +
			RIGHT(REPLICATE('0', 9) + RTRIM(CONVERT(CHAR(09), A.CCF)),9)                                     +
			RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.GNF)),6)                                     +
			CASE WHEN A.PAGAMENTO = '' THEN '               ' ELSE LEFT(LTRIM(CONVERT(CHAR(15), UPPER(A.PAGAMENTO))) + REPLICATE(' ', 15), 15) END   +
			RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13), SUM(A.VALOR_PAGO)	)),'.',''),13)    +
			CASE WHEN B.CANCELADO = 1 THEN 'S' ELSE 'N' END                                                   +
			CASE WHEN B.CANCELADO = 1 THEN RIGHT(REPLICATE('0', 13) + REPLACE(RTRIM(CONVERT(CHAR(13), SUM(A.VALOR_PAGO)	)),'.',''),13) ELSE '0000000000000' END  AS REGISTRO,
			106 AS LIMITE,
			@TERMINAL AS TERMINAL
		    FROM dbo.LJ_ECF_PAGAMENTO A
			INNER JOIN LJ_DOCUMENTO_ECF B
			ON A.CODIGO_FILIAL     = B.CODIGO_FILIAL 
			AND A.ID_DOCUMENTO_ECF = B.ID_DOCUMENTO_ECF 
			--#5#[Inicio] 
			--#5#Where CONVERT(Varchar,(A.DATA_PARA_TRANSFERENCIA), 112) Between @DT_INICIAL AND @DT_FINAL
			Where CONVERT(Varchar,(B.DATA_FISCAL), 112) Between @DT_INICIAL AND @DT_FINAL --#5#
			AND A.CODIGO_FILIAL =@COD_FILIAL 
			AND ISNULL(A.PAGAMENTO,'') <> ''
			
			--#5#[Fim] 
			GROUP BY ESTORNO_PGTO,B.CANCELADO,A.MF_ADICIONAL,CONVERT(CHAR(20), A.SERIE_ECF ) , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.COO)),6)  , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.CCF)),6) , RIGHT(REPLICATE('0', 6) + RTRIM(CONVERT(CHAR(06), A.GNF)),6)  , LEFT(LTRIM(CONVERT(CHAR(15), PAGAMENTO)) + REPLICATE(' ', 15), 15) , 
    		 RIGHT(REPLICATE('0', 2) + RTRIM(CONVERT(CHAR(02), USUARIO_ECF)),2), CONVERT(CHAR(20), MODELO_ECF) ,
			 A.LX_HASH,SERIE_ECF,A.COO,A.PARCELA,A.MODELO_ECF,A.CCF,A.GNF,A.PAGAMENTO,A.VALOR_PAGO,A.VALOR_ESTORNADO,A.USUARIO_ECF
			ORDER BY A.COO ;
  End   	
  
	IF object_id('TEMPDB..#PAF_ECF_REDUCAO_Z') IS NOT NULL
	   Begin 	
		 DROP TABLE #PAF_ECF_REDUCAO_Z ;
       End 
  END