CREATE FUNCTION [DBO].[FX_RETORNA_DATAS_FISCAIS_BLOCOX]  (@CODIGO_FILIAL CHAR(6))
	----------------------------------------------------------
	--    TABELA QUE SERÁ RETORNADA NO FINAL DO PROCESSO    --  
	----------------------------------------------------------
	RETURNS @DATAS TABLE
	(
		DATA_INICIO				DATETIME,
		UF						CHAR(2)
	)

	AS
	-- 28/06/2019 - #1# - Diego Moreno - Criação da function.
	BEGIN 
		----------------------------------------------------------
		-- VARIAVEIS PARA AS POSSIVEIS DATAS A SEREM UTILIZADAS --  
		----------------------------------------------------------
		DECLARE @DATA_LEGAL_PREVISTA	DATETIME
		DECLARE @DATA_INI_BLOCOX		DATETIME 
		DECLARE @DATA_PADRAO_UF			DATETIME
		DECLARE @DATA_ABERTURA			DATETIME
		DECLARE @DATA_INICIO_BLOCOX		DATETIME
		DECLARE @DATA_FISCAL			DATETIME
		DECLARE @UF						CHAR(2)

		
		----------------------------------------------------------
		--		PREENCHIMENTO DAS VARIAVEIS DECLARADAS			--  
		----------------------------------------------------------
		SELECT	@DATA_PADRAO_UF   =  DATA_INICIO FROM LX_CONFIG_BLOCOX

		SELECT	@DATA_INI_BLOCOX	=	ISNULL(CONVERT(DATETIME, VALOR_ATUAL), @DATA_PADRAO_UF) FROM PARAMETROS WHERE PARAMETRO = 'DATA_INI_BLOCOX'

		SELECT  @DATA_ABERTURA		=	DATA_ABERTURA ,
			    @UF					=	CC.UF
			   							FROM	DBO.FILIAIS F INNER JOIN 
										DBO.CADASTRO_CLI_FOR CC 
										ON F.MATRIZ_FISCAL = CC.NOME_CLIFOR 
										WHERE CC.CLIFOR = @CODIGO_FILIAL
		
		--------------------------------------------------------------------------------------------------------------------------
		--		VALIDAÇÕES ENTRE DATAS PARA DECIDIR QUAL A CORRETA PARA DETERMINAR O ENVIO DOS DADOS DE ESTOQUE DO BLOCOX		--  
		--------------------------------------------------------------------------------------------------------------------------
		SET @DATA_LEGAL_PREVISTA  = CASE WHEN @DATA_INI_BLOCOX < @DATA_PADRAO_UF THEN @DATA_INI_BLOCOX ELSE @DATA_PADRAO_UF END 
		SET @DATA_FISCAL		  = CASE WHEN ISNULL(@DATA_ABERTURA, @DATA_LEGAL_PREVISTA) > @DATA_LEGAL_PREVISTA THEN @DATA_ABERTURA ELSE @DATA_LEGAL_PREVISTA END 
		SET @DATA_INICIO_BLOCOX	  = DATEADD(month, ((YEAR(@DATA_FISCAL) - 1900) * 12) + MONTH(@DATA_FISCAL), -1)
		INSERT INTO @DATAS
		VALUES(@DATA_INICIO_BLOCOX, @UF)
	RETURN 
END