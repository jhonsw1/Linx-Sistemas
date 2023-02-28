CREATE FUNCTION [DBO].[FN_INFORMACAO_PAGAMENTO]  (@NOTAFISCAL CHAR(15), @SERIENOTA CHAR(6), @CODIGO_FILIAL CHAR(6))

-- PRODSHOP-7305 - Eder Silva	- #20# - 03/08/2021 - Alterada a regra para exibi��o do troco na NF-e quando tiver item do Vitrine na venda.
-- 04/06/2021 - Eder Silva    - #PRODSHOP-6546# - Tratamento para nota de venda � ordem (Vitrine).
-- 18/08/2020 - Fillipi Ramos - #SUSTSP-1013#   - Corre��o para n�o deixar de gerar a DetPag quando for uma nf-e de devolu��o de venda.
-- 08/06/2018 - Diego Moreno  - DM 77455 - #52# - Cria��o da function para melhoria de performance.

RETURNS @LOJA_VENDA_ORIGEM TABLE
(
	TIPO_NOTA			char(1),
	FILIAL				varchar(25),
	NF					char(15),
	SERIE_NF			char(6),
	PARCELA				int,
	INFO_PGTO			char(2),
	VALOR				numeric(9,2),
	CNPJ_CREDENCIADORA	varchar(14),
	TIPO_INTEGRA		int,
	BANDEIRA			char(2), 
	AUTORIZACAO			varchar(35),
	TROCO				numeric(9,2)
)

AS

BEGIN 
	DECLARE @CODIGO_FILIAL_VINCULADA CHAR(6),@TERMINAL_VINCULADA CHAR(3), @LANCAMENTO_CAIXA_VINCULADA CHAR(7),
			@NUMERO_CUPOM_FISCAL_VINCULADA VARCHAR(9), @NUMERO_FISCAL_VENDA CHAR(15)

	SELECT	@CODIGO_FILIAL_VINCULADA = CODIGO_FILIAL,
			@LANCAMENTO_CAIXA_VINCULADA = LANCAMENTO_CAIXA,
			@TERMINAL_VINCULADA = TERMINAL,
			@NUMERO_CUPOM_FISCAL_VINCULADA = NUMERO_CUPOM_FISCAL,
			@NUMERO_FISCAL_VENDA = NUMERO_FISCAL_VENDA
	FROM	LOJA_VENDA_PGTO 
	WHERE	CODIGO_FILIAL = @CODIGO_FILIAL AND
			NUMERO_FISCAL_VINCULADA = @NOTAFISCAL AND
			SERIE_NF_VINCULADA = @SERIENOTA 
			
	DECLARE @CODIGO_FILIAL_VENDA CHAR(6),@TERMINAL_VENDA CHAR(3), @LANCAMENTO_CAIXA_VENDA CHAR(7),
			@NUMERO_CUPOM_FISCAL_VENDA VARCHAR(9), @ID_EQUIPAMENTO VARCHAR(20)
	SELECT	@CODIGO_FILIAL_VENDA = CODIGO_FILIAL,
			@LANCAMENTO_CAIXA_VENDA = LANCAMENTO_CAIXA,
			@TERMINAL_VENDA = TERMINAL,
			@NUMERO_CUPOM_FISCAL_VENDA = NUMERO_CUPOM_FISCAL,
			@ID_EQUIPAMENTO = ID_EQUIPAMENTO
	FROM	LOJA_VENDA_PGTO 
	WHERE	CODIGO_FILIAL = @CODIGO_FILIAL AND
			NUMERO_FISCAL_VENDA = @NOTAFISCAL AND
			SERIE_NF_SAIDA = @SERIENOTA

    --PRODSHOP-6546 - In�cio       
	DECLARE @CODIGO_FILIAL_VENDA_ORDEM CHAR(6), @TERMINAL_VENDA_ORDEM CHAR(3), @LANCAMENTO_CAIXA_VENDA_ORDEM CHAR(7)			
	SELECT	@CODIGO_FILIAL_VENDA_ORDEM = CODIGO_FILIAL,
			@TERMINAL_VENDA_ORDEM = TERMINAL,
            @LANCAMENTO_CAIXA_VENDA_ORDEM = LANCAMENTO_CAIXA			
	FROM	LOJA_VENDA_PGTO 
	WHERE	CODIGO_FILIAL = @CODIGO_FILIAL AND
			NUMERO_NF_ORDEM = @NOTAFISCAL AND
			SERIE_NF_ORDEM = @SERIENOTA
    --PRODSHOP-6546 - Fim
    
INSERT INTO @LOJA_VENDA_ORIGEM(TIPO_NOTA, FILIAL, NF,SERIE_NF, PARCELA,INFO_PGTO, VALOR, CNPJ_CREDENCIADORA	,TIPO_INTEGRA ,BANDEIRA ,AUTORIZACAO,TROCO)
	/********************************************* NOTA FISCAL DE VENDA VINCULADA*****************************************************/    
SELECT   
 'V' AS TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VINCULADA AS NF, PGTO.SERIE_NF_VINCULADA AS SERIE_NF, PARCELA.PARCELA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,  
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR,  --#8#     
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,       
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
 END) BANDEIRA,      
  -- #13# - Fim    
    (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
    ISNULL((PARCELA.TROCO ),0) +   
  CASE WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0 THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0                 THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    ELSE 0   
  END AS TROCO  --#8# #10# #11#    
FROM LOJA_VENDA_PGTO PGTO  with (nolock)  --#15#  
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA   with (nolock)   --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
                       PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
                       PGTO.TERMINAL = PARCELA.TERMINAL      
  INNER JOIN LOJAS_VAREJO LOJA  with (nolock) --#15#      
                    ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#   
                    ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D with (nolock)  --#15#
                    ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA      
  INNER JOIN LOJA_NOTA_FISCAL NOTA   with (nolock) --#15#
                    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
                       NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VINCULADA AND  
                       NOTA.SERIE_NF = PGTO.SERIE_NF_VINCULADA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock) -- #13#  #15#
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
          /*#2#*/  
WHERE	  PGTO.NUMERO_CUPOM_FISCAL =		@NUMERO_CUPOM_FISCAL_VINCULADA AND PGTO.NUMERO_FISCAL_VENDA IS NULL AND 
		  PGTO.NUMERO_FISCAL_VINCULADA =	@NOTAFISCAL AND
		  PGTO.SERIE_NF_VINCULADA =			@SERIENOTA AND
		  PGTO.CODIGO_FILIAL =				@CODIGO_FILIAL AND
		  PGTO.LANCAMENTO_CAIXA =			@LANCAMENTO_CAIXA_VINCULADA AND 
		  PGTO.TERMINAL =					@TERMINAL_VINCULADA AND
		  ISNULL(PGTO.ID_EQUIPAMENTO , '') = '' 
/***********************************************************************************************************************************************************************************/
UNION ALL
SELECT   
 'V' AS TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VINCULADA AS NF, PGTO.SERIE_NF_VINCULADA AS SERIE_NF, PARCELA.PARCELA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,  
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR,  --#8#     
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,       
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
 END) BANDEIRA,      
  -- #13# - Fim    
    (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
    ISNULL((PARCELA.TROCO ),0) +   
  CASE WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0 THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0                 THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    ELSE 0   
  END AS TROCO  --#8# #10# #11#    
FROM LOJA_VENDA_PGTO PGTO  with (nolock)  --#15#  
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA   with (nolock)   --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
                       PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
                       PGTO.TERMINAL = PARCELA.TERMINAL      
  INNER JOIN LOJAS_VAREJO LOJA  with (nolock) --#15#      
                    ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#   
                    ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D with (nolock)  --#15#
                    ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA      
  INNER JOIN LOJA_NOTA_FISCAL NOTA   with (nolock) --#15#
                    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
                       NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VINCULADA AND  
                       NOTA.SERIE_NF = PGTO.SERIE_NF_VINCULADA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock) -- #13#  #15#
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
          /*#2#*/  
WHERE  	  PGTO.NUMERO_FISCAL_VENDA =		@NUMERO_FISCAL_VENDA AND
		  PGTO.NUMERO_FISCAL_VINCULADA =	@NOTAFISCAL AND
		  PGTO.SERIE_NF_VINCULADA =			@SERIENOTA AND
		  PGTO.CODIGO_FILIAL =				@CODIGO_FILIAL AND 
		  PGTO.NUMERO_CUPOM_FISCAL			IS NULL AND   
          ISNULL(PGTO.ID_EQUIPAMENTO , '') = ''

--/***********************************************************************************************************************************************************************************/
union all 
SELECT   
 'V' AS TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VINCULADA AS NF, PGTO.SERIE_NF_VINCULADA AS SERIE_NF, PARCELA.PARCELA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,  
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR,  --#8#     
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,       
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
 END) BANDEIRA,      
  -- #13# - Fim    
    (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
    ISNULL((PARCELA.TROCO ),0) +   
  CASE WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0 THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0                 THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    ELSE 0   
  END AS TROCO  --#8# #10# #11#    
FROM LOJA_VENDA_PGTO PGTO  with (nolock)  --#15#  
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA   with (nolock)   --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
                       PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
                       PGTO.TERMINAL = PARCELA.TERMINAL      
  INNER JOIN LOJAS_VAREJO LOJA  with (nolock) --#15#      
                    ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#   
                    ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D with (nolock)  --#15#
                    ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA      
  INNER JOIN LOJA_NOTA_FISCAL NOTA   with (nolock) --#15#
                    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
                       NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VINCULADA AND  
                       NOTA.SERIE_NF = PGTO.SERIE_NF_VINCULADA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock) -- #13#  #15#
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
where	  PGTO.NUMERO_FISCAL_VENDA = @NUMERO_FISCAL_VENDA AND 
		  PGTO.NUMERO_CUPOM_FISCAL = @NUMERO_CUPOM_FISCAL_VINCULADA AND --#3#  
          PGTO.NUMERO_FISCAL_VINCULADA = @NOTAFISCAL AND
		  PGTO.SERIE_NF_VINCULADA = @SERIENOTA AND
		  PGTO.CODIGO_FILIAL = @CODIGO_FILIAL AND 
		  ISNULL(PGTO.ID_EQUIPAMENTO , '') = ''
		  

--/********************************************* NOTA FISCAL DE VENDA VINCULADA*****************************************************/    
UNION  ALL 
  
SELECT   
 'V' as TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VENDA AS NF, PGTO.SERIE_NF_SAIDA AS SERIE_NF, PARCELA.PARCELA, -- #15#     
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,       
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR, --#8#          
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,  
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
   END) BANDEIRA,      
  -- #13# - Fim  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
 ISNULL((PARCELA.TROCO ),0) +   
  CASE WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0 THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0     THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    ELSE 0   
  END AS TROCO --#8#  #10# #11#    
FROM LOJA_VENDA_PGTO PGTO   with (nolock)  --#15# 
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA  with (nolock)  --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
     PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
     PGTO.TERMINAL = PARCELA.TERMINAL      
  INNER JOIN LOJAS_VAREJO LOJA with (nolock)     --#15#
     ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#
     ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D   with (nolock) --#15#
     ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA       
  INNER JOIN LOJA_NOTA_FISCAL NOTA  with (nolock)  --#15#
                    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
     NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VENDA AND  
     NOTA.SERIE_NF = PGTO.SERIE_NF_SAIDA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock)-- #13#  
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
    /*#2#*/  
WHERE	  PGTO.ID_EQUIPAMENTO			= @ID_EQUIPAMENTO AND 
		  PGTO.NUMERO_FISCAL_VENDA		= @NOTAFISCAL AND  
		  PGTO.SERIE_NF_SAIDA			= @SERIENOTA AND
          PGTO.NUMERO_CUPOM_FISCAL		= @NUMERO_CUPOM_FISCAL_VENDA 

/***********************************************************************************************************************************************************************************/	
union all
  
SELECT   
 'V' as TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VENDA AS NF, PGTO.SERIE_NF_SAIDA AS SERIE_NF, PARCELA.PARCELA, -- #15#     
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,       
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR, --#8#          
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,  
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
   END) BANDEIRA,      
  -- #13# - Fim  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
 ISNULL((PARCELA.TROCO ),0) +   
  CASE WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0 THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0     THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    ELSE 0   
  END AS TROCO --#8#  #10# #11#    
FROM LOJA_VENDA_PGTO PGTO   with (nolock)  --#15# 
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA  with (nolock)  --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
     PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
     PGTO.TERMINAL = PARCELA.TERMINAL      
  INNER JOIN LOJAS_VAREJO LOJA with (nolock)     --#15#
     ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#
     ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D   with (nolock) --#15#
     ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA       
  INNER JOIN LOJA_NOTA_FISCAL NOTA  with (nolock)  --#15#
                    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
     NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VENDA AND  
     NOTA.SERIE_NF = PGTO.SERIE_NF_SAIDA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock)-- #13#  
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
WHERE	  PGTO.NUMERO_FISCAL_VENDA = @NOTAFISCAL AND 
		  PGTO.SERIE_NF_SAIDA = @SERIENOTA AND 
		  PGTO.CODIGO_FILIAL = @CODIGO_FILIAL AND
		  PGTO.LANCAMENTO_CAIXA = @LANCAMENTO_CAIXA_VENDA AND 
		  PGTO.NUMERO_FISCAL_VINCULADA IS NULL AND 
		  ISNULL(PGTO.ID_EQUIPAMENTO , '') = ''  AND
		  --#20# - In�cio
		  PARCELA.LANCAMENTO_CAIXA NOT IN (	SELECT	LVP.LANCAMENTO_CAIXA 
											FROM	LOJA_VENDA_PARCELAS LVP WITH (NOLOCK)
											WHERE	PARCELA.CODIGO_FILIAL = LVP.CODIGO_FILIAL AND 	
													PARCELA.TERMINAL = LVP.TERMINAL AND 
													PARCELA.LANCAMENTO_CAIXA = LVP.LANCAMENTO_CAIXA AND 																								
													TIPO_PGTO = '\')
		  --#20# - Fim

/***********************************************************************************************************************************************************************************/		  

UNION ALL  
     
SELECT     
 'O'    AS TIPO_NOTA,  /*#4#*/   
 B.FILIAL,       
 A.NF_NUMERO  AS NF,       
 A.SERIE_NF, 1 AS PARCELA,      
 '90'   AS INFO_PGTO,      
 A.VALOR_TOTAL AS VALOR,      
 ''    AS CNPJ_CREDENCIADORA,      
 '2'    AS TIPO_INTEGRA,       
 '99'   AS BANDEIRA,      
 ''    AS AUTORIZACAO,      
 0    AS TROCO        
FROM LOJA_NOTA_FISCAL A with (nolock)     --#15#
  INNER JOIN LOJAS_VAREJO B with (nolock)     --#15#
     ON A.CODIGO_FILIAL = B.CODIGO_FILIAL      
  LEFT JOIN LOJA_VENDA_PGTO  C  with (nolock)   --#15# 
     ON A.CODIGO_FILIAL = C.CODIGO_FILIAL AND    
     (A.NF_NUMERO = C.NUMERO_FISCAL_VENDA OR A.NF_NUMERO = C.NUMERO_FISCAL_VINCULADA ) AND  
     ( A.SERIE_NF = C.SERIE_NF_VINCULADA OR A.SERIE_NF = C.SERIE_NF_SAIDA) AND A.NATUREZA_OPERACAO_CODIGO <> '5929'--#14###SUSTSP-1013## 
WHERE C.NUMERO_FISCAL_VINCULADA IS NULL AND    
  C.NUMERO_FISCAL_VENDA     IS NULL AND 
  A.TIPO_ORIGEM <> 1 AND 
  A.NF_NUMERO = @NOTAFISCAL AND
  A.SERIE_NF = @SERIENOTA AND 
  A.CODIGO_FILIAL = @CODIGO_FILIAL



/***********************************************************************************************************************************************************************************/		    
UNION ALL -- TRATAMENTO PARA FAZER O VALOR DA TROCA COM DINHEIRO COM TIPO OUTROS #9#  
  
SELECT     
 'V'     AS TIPO_NOTA,  /*#4#*/   
 B.FILIAL,       
 A.NF_NUMERO   AS NF,       
 A.SERIE_NF,  
 PARCELA.PARCELA +1 AS PARCELA,  
 '99'    AS INFO_PGTO,      
 D.VALOR_TROCA  AS VALOR ,      
 NULL    AS CNPJ_CREDENCIADORA,      
 NULL    AS TIPO_INTEGRA,       
 NULL    AS BANDEIRA,      
 NULL    AS AUTORIZACAO,      
 0     AS TROCO        
FROM LOJA_NOTA_FISCAL A  with (nolock)   --#15# 
  INNER JOIN LOJAS_VAREJO B  with (nolock) --#15#     
     ON A.CODIGO_FILIAL = B.CODIGO_FILIAL      
  LEFT JOIN LOJA_VENDA_PGTO  C with (nolock)   --#15#  
     ON A.CODIGO_FILIAL = C.CODIGO_FILIAL AND    
     (A.NF_NUMERO = C.NUMERO_FISCAL_VENDA OR A.NF_NUMERO = C.NUMERO_FISCAL_VINCULADA)  AND  
     ( A.SERIE_NF = C.SERIE_NF_VINCULADA OR A.SERIE_NF = C.SERIE_NF_SAIDA) --#14#  
  INNER JOIN LOJA_VENDA D   with (nolock) --#15#
     ON A.CODIGO_FILIAL = D.CODIGO_FILIAL AND   
     C.LANCAMENTO_CAIXA = D.LANCAMENTO_CAIXA AND   
     C.TERMINAL = D.TERMINAL  
  INNER JOIN (SELECT MAX(PARCELA) AS PARCELA ,CODIGO_FILIAL,LANCAMENTO_CAIXA,TERMINAL   
      FROM LOJA_VENDA_PARCELAS with (nolock) /*#12#  #15#  */ 
	  GROUP BY CODIGO_FILIAL,TERMINAL,LANCAMENTO_CAIXA ) AS PARCELA  
     ON D.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL   AND     
     D.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
     D.TERMINAL = PARCELA.TERMINAL   
WHERE D.VALOR_TROCA > 0  
AND 
  A.NF_NUMERO = @NOTAFISCAL AND
  A.SERIE_NF = @SERIENOTA AND 
  A.CODIGO_FILIAL = @CODIGO_FILIAL


/***********************************************************************************************************************************************************************************/	
--PRODSHOP-6546 - In�cio  
/*** NOTA DE VENDA � ORDEM ***/

UNION ALL

SELECT   
    'V' AS TIPO_NOTA,  /*#4#*/  
    LOJA.FILIAL, PGTO.NUMERO_NF_ORDEM AS NF, PGTO.SERIE_NF_ORDEM AS SERIE_NF, PARCELA.PARCELA,
    CASE 
        WHEN PARCELA.TIPO_PGTO IN ('D','M')     THEN '01'      
        WHEN PARCELA.TIPO_PGTO IN ('C','P')     THEN '02'      
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
        WHEN PARCELA.TIPO_PGTO IN ('E','K')     THEN '04'      
        WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
        WHEN PARCELA.TIPO_PGTO = '&'            THEN '12'      
        WHEN PARCELA.TIPO_PGTO = 'J'            THEN '14'      
        WHEN PARCELA.TIPO_PGTO = 'T'            THEN '90'      
           ELSE '99'       
    END AS INFO_PGTO,       
    CASE 
        WHEN PARCELA.VALOR > 0                  THEN PARCELA.VALOR 
        ELSE 0 
    END AS VALOR,
    D.CNPJ_CREDENCIADORA AS CNPJ_CREDENCIADORA,      
    CASE 
        WHEN PARCELA.TIPO_PGTO IN ('K','I')     THEN 1       
        WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
        ELSE NULL   
    END AS TIPO_INTEGRA,  
    CASE 
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'               THEN '01'      
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'         THEN '02'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%'   THEN '03'      
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'           THEN '04'      
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'             THEN '05'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'                THEN '06'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'          THEN '07'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'               THEN '08'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'              THEN '09'       
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')                                                     THEN '99'       
        ELSE NULL   
    END AS BANDEIRA,        
    CASE 
        WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO 
        ELSE NULL 
    END AS AUTORIZACAO,      
    ISNULL(PARCELA.TROCO, 0) +   
        CASE 
            WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0     THEN ABS(PARCELA.VALOR)     
            WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0                     THEN ABS(PARCELA.VALOR)
            ELSE 0   
        END AS TROCO
FROM 
    LOJA_VENDA_PGTO PGTO                    WITH (NOLOCK)
    INNER JOIN LOJA_VENDA_PARCELAS PARCELA  WITH (NOLOCK)
        ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL AND     
        PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
        PGTO.TERMINAL = PARCELA.TERMINAL      
    INNER JOIN LOJAS_VAREJO LOJA            WITH (NOLOCK) 
        ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
    LEFT JOIN ADMINISTRADORAS_CARTAO C      WITH (NOLOCK) 
        ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
    LEFT JOIN CREDENCIADORA_CARTAO D        WITH (NOLOCK) 
        ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA       
    INNER JOIN LOJA_NOTA_FISCAL NOTA        WITH (NOLOCK)  
	    ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
        NOTA.NF_NUMERO = PGTO.NUMERO_NF_ORDEM AND  
        NOTA.SERIE_NF = PGTO.SERIE_NF_ORDEM 
    LEFT JOIN LX_ADMINISTRADORAS_CARTAO E   WITH (NOLOCK)
        ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))
WHERE	  
    PGTO.NUMERO_NF_ORDEM    = @NOTAFISCAL AND 
    PGTO.SERIE_NF_ORDEM     = @SERIENOTA AND 
    PGTO.CODIGO_FILIAL      = @CODIGO_FILIAL AND
    PGTO.LANCAMENTO_CAIXA   = @LANCAMENTO_CAIXA_VENDA_ORDEM AND 		  
    ISNULL(PGTO.ID_EQUIPAMENTO , '') = ''  
--PRODSHOP-6546 - Fim
																																														 

--***********************************************************************************************************************************************************************************		  
--** Venda mista com VITRINE ********************************************************************************************************************************************************
--***********************************************************************************************************************************************************************************	
--#20# - In�cio
UNION ALL
  
SELECT   
 'V' as TIPO_NOTA,  /*#4#*/  
 LOJA.FILIAL,PGTO.NUMERO_FISCAL_VENDA AS NF, PGTO.SERIE_NF_SAIDA AS SERIE_NF, PARCELA.PARCELA, -- #15#     
 (CASE WHEN PARCELA.TIPO_PGTO IN ('D','M')  THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('C','P')  THEN '02'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I') THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('E','K')  THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('#','@','N') THEN '05'      
   WHEN PARCELA.TIPO_PGTO = '&'   THEN '12'      
   WHEN PARCELA.TIPO_PGTO = 'J'   THEN '14'      
   WHEN PARCELA.TIPO_PGTO = 'T'   THEN '90'      
   ELSE '99'       
 END) AS INFO_PGTO,       
 CASE WHEN PARCELA.VALOR > 0 THEN PARCELA.VALOR ELSE 0 END AS VALOR, --#8#          
 (D.CNPJ_CREDENCIADORA) AS CNPJ_CREDENCIADORA,      
 (CASE WHEN PARCELA.TIPO_PGTO IN ('K','I')  THEN 1       
   WHEN PARCELA.TIPO_PGTO IN ('E','B','A') THEN 2       
   ELSE NULL   
 END) AS TIPO_INTEGRA,  
  -- #13# - In�cio  
  -- Passou a validar o nome da Administradora da tabela 'LX_ADMINISTRADORAS_CARTAO'  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%VISA%'     THEN '01'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%MASTERCARD%'    THEN '02'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AMERICAN EXPRESS%' THEN '03'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%SOROCRED%'    THEN '04'      
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%DINERS%'     THEN '05'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%ELO%'     THEN '06'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%HIPERCARD%'    THEN '07'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%AURA%'     THEN '08'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') AND E.LX_ADMINISTRADORA LIKE '%CABAL%'     THEN '09'       
   WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K')               THEN '99'       
   ELSE NULL   
   END) BANDEIRA,      
  -- #13# - Fim  
 (CASE WHEN PARCELA.TIPO_PGTO IN ('A','B','I','E','K') THEN PARCELA.NUMERO_APROVACAO_CARTAO ELSE NULL END) AS AUTORIZACAO,      
 ISNULL((PARCELA.TROCO ),0) +   
  CASE 
	WHEN PARCELA.TIPO_PGTO IN ('^','&','@','R','V') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0	THEN ABS(PARCELA.VALOR)     
    WHEN PARCELA.TIPO_PGTO IN ('D') AND PARCELA.VALOR < 0 AND PARCELA.TROCO = 0					THEN ABS(PARCELA.VALOR) -- AND PARCELA.VALOR = > 0 AND PARCELA.TROCO = 0  
    WHEN ISNULL(F.VALOR, 0) > 0 AND F.PARCELA = PARCELA.PARCELA									THEN ABS(F.TROCO)
  END AS TROCO --#8#  #10# #11# 
  

FROM LOJA_VENDA_PGTO PGTO   with (nolock)  --#15# 
  INNER JOIN LOJA_VENDA_PARCELAS PARCELA  with (nolock)  --#15#
     ON PGTO.CODIGO_FILIAL = PARCELA.CODIGO_FILIAL  AND     
     PGTO.LANCAMENTO_CAIXA = PARCELA.LANCAMENTO_CAIXA AND   
     PGTO.TERMINAL = PARCELA.TERMINAL AND
	 PARCELA.TIPO_PGTO <> '\'
  INNER JOIN LOJAS_VAREJO LOJA with (nolock)     --#15#
     ON PARCELA.CODIGO_FILIAL = LOJA.CODIGO_FILIAL      
  LEFT JOIN ADMINISTRADORAS_CARTAO C  with (nolock) --#15#
     ON C.CODIGO_ADMINISTRADORA = PARCELA.CODIGO_ADMINISTRADORA      
  LEFT JOIN CREDENCIADORA_CARTAO D   with (nolock) --#15#
     ON D.COD_CREDENCIADORA = PARCELA.COD_CREDENCIADORA       
  INNER JOIN LOJA_NOTA_FISCAL NOTA  with (nolock)  --#15#
	 ON NOTA.CODIGO_FILIAL = PGTO.CODIGO_FILIAL AND  
     NOTA.NF_NUMERO = PGTO.NUMERO_FISCAL_VENDA AND  
     NOTA.SERIE_NF = PGTO.SERIE_NF_SAIDA  
  LEFT JOIN LX_ADMINISTRADORAS_CARTAO E  with (nolock)-- #13#  
     ON LTRIM(RTRIM(C.LX_COD_ADMINISTRADORA)) = LTRIM(RTRIM(E.LX_COD_ADMINISTRADORA))  -- #13#  
  INNER JOIN	LOJA_VENDA_PARCELAS_ECOMMERCE F  WITH (NOLOCK)
	 ON	PARCELA.CODIGO_FILIAL = F.CODIGO_FILIAL AND
	    PARCELA.TERMINAL = F.TERMINAL AND
		PARCELA.LANCAMENTO_CAIXA = F.LANCAMENTO_CAIXA AND								
		PARCELA.PARCELA = F.PARCELA
WHERE	  PGTO.NUMERO_FISCAL_VENDA = @NOTAFISCAL AND 
		  PGTO.SERIE_NF_SAIDA = @SERIENOTA AND 
		  PGTO.CODIGO_FILIAL = @CODIGO_FILIAL AND
		  PGTO.LANCAMENTO_CAIXA = @LANCAMENTO_CAIXA_VENDA AND 
		  PGTO.NUMERO_FISCAL_VINCULADA IS NULL AND 
		  ISNULL(PGTO.ID_EQUIPAMENTO , '') = ''
--#20# - Fim
return 
end