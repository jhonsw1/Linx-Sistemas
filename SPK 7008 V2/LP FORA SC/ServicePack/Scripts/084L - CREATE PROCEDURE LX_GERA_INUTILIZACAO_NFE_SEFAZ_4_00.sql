CREATE PROCEDURE [DBO].[LX_GERA_INUTILIZACAO_NFE_SEFAZ_4_00] @AMBIENTE_NFE CHAR(1), @CHAVE_NFE VARCHAR(44), @MOTIVO_INUTILIZACAO VARCHAR(255),  @VERSAO VARCHAR(5)='4.00', @NF_INICIO VARCHAR(9)=NULL, @NF_FIM VARCHAR(9)=NULL
	WITH ENCRYPTION 
AS
										
-- DM 58430	- Diego Moreno - #1# - (20/09/2017) - Adequacao NFE 4.00. Cria��o da procedure para atender a vers�o 4.00.

DECLARE --@NOTAFISCAL VARCHAR(7), @SERIENOTA VARCHAR(6), @FILIALNOTA VARCHAR(25),  
		@INUTILIZACAO_NFE_XML XML, @INUTILIZACAO_NFE_STRING VARCHAR(MAX),@ID_INUT VARCHAR(44) 

SELECT @MOTIVO_INUTILIZACAO = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,@MOTIVO_INUTILIZACAO)
		
SELECT @ID_INUT = SUBSTRING(@CHAVE_NFE,1,2)		+		-- CUF
					SUBSTRING(@CHAVE_NFE,3,2)	+		-- ANO
					SUBSTRING(@CHAVE_NFE,7,14)	+		-- CNPJ
					SUBSTRING(@CHAVE_NFE,21,2)	+		-- MODELO FISCAL
					RTRIM(SUBSTRING(@CHAVE_NFE,23,3))	-- SERIE
					
IF 	@NF_INICIO IS NULL AND @NF_FIM IS NULL
	BEGIN
		SELECT @ID_INUT = @ID_INUT +
			RTRIM(SUBSTRING(@CHAVE_NFE,26,9))	+		-- NUMERO DOCUMENTO INICIAL
			RTRIM(SUBSTRING(@CHAVE_NFE,26,9))			-- NUMERO DOCUMENTO FINAL
			
		SELECT @NF_INICIO = RTRIM(CONVERT(VARCHAR(9),CONVERT(INTEGER,SUBSTRING(@CHAVE_NFE,26,9))))
		SELECT @NF_FIM	  = RTRIM(CONVERT(VARCHAR(9),CONVERT(INTEGER,SUBSTRING(@CHAVE_NFE,26,9))))	
	END
ELSE
	BEGIN
		SELECT @ID_INUT = @ID_INUT +
			RIGHT('00000000'+RTRIM(@NF_INICIO),9)+		-- NUMERO DOCUMENTO INICIAL
			RIGHT('00000000'+RTRIM(@NF_FIM),9)			-- NUMERO DOCUMENTO FINAL

		SELECT @NF_INICIO = RTRIM(CONVERT(VARCHAR(9),CONVERT(INTEGER,@NF_INICIO)))
		SELECT @NF_FIM	  = RTRIM(CONVERT(VARCHAR(9),CONVERT(INTEGER,@NF_FIM)))	
	END
	
SELECT @INUTILIZACAO_NFE_XML = (

		SELECT RTRIM(@VERSAO)  "@versao",
			'SUBSTITUIR' "@SUBSTITUI1",		
			-- infCanc
			( 
				SELECT 'ID' + RTRIM(@ID_INUT)			"@Id",
					@AMBIENTE_NFE						"tpAmb",	
					'INUTILIZAR'						"xServ",
					SUBSTRING(@CHAVE_NFE,1,2)			"cUF",
					SUBSTRING(@CHAVE_NFE,3,2)			"ano",
					SUBSTRING(@CHAVE_NFE,7,14)			"CNPJ",
					SUBSTRING(@CHAVE_NFE,21,2)			"mod",	
					RTRIM(CONVERT(VARCHAR(3),CONVERT(INTEGER,SUBSTRING(@CHAVE_NFE,23,3))))	"serie",
					RTRIM(@NF_INICIO)					"nNFIni",
					RTRIM(@NF_FIM)						"nNFFin",
					RTRIM(@MOTIVO_INUTILIZACAO)			"xJust"
				FOR XML PATH('infInut'),TYPE  
			)
			FOR XML PATH('inutNFe'),TYPE 
		)	


SELECT @INUTILIZACAO_NFE_STRING = CONVERT(VARCHAR(MAX) ,@INUTILIZACAO_NFE_XML )			
--SELECT @INUTILIZACAO_NFE_STRING =  ('<?'+'xml version="1.0" encoding="UTF-8"?>'+@INUTILIZACAO_NFE_STRING)
SELECT @INUTILIZACAO_NFE_STRING = REPLACE(@INUTILIZACAO_NFE_STRING,'SUBSTITUI1="SUBSTITUIR"','xmlns="http://www.portalfiscal.inf.br/nfe"')

SELECT @INUTILIZACAO_NFE_STRING AS XML_INUT_NFE, RTRIM(@CHAVE_NFE) AS CHAVE_NFE
