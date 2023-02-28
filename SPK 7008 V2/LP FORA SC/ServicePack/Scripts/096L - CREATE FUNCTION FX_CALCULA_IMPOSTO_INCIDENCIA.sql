CREATE FUNCTION DBO.FX_CALCULA_IMPOSTO_INCIDENCIA (@NOME_CLIFOR VARCHAR(25), @NF_SAIDA CHAR(15), @SERIE_NF CHAR(6), @FILIAL VARCHAR(25), @ID_IMPOSTO INT, @TIPO INT, @TABELA CHAR(1) )
RETURNS NUMERIC(14, 2)
BEGIN
-- DM 58430	- Diego Moreno - #2# - (20/09/2017) - Adequacao NFE 4.00. Melhoria para atender ao layout 4.0. Remoção da alteração realizada para o tribut ICMS 90.
-- TP8936960 - Victor kajiyama - #1# - (22062015) -  Implementa��o de ICMS Diferido para a NFE 3.10. 

	DECLARE @VALOR NUMERIC(14, 2), @BASE NUMERIC(14, 2)
	IF @ID_IMPOSTO IN (1,51) -- ICMS #1# - Incluindo o ID_IMPOSTO 51 para que seja calculado o imposto de ICMS diferido corretamente. 
		BEGIN
			SELECT 		
				@VALOR = ISNULL(SUM(LOJA_NOTA_FISCAL_IMPOSTO.VALOR_IMPOSTO), 0), 
				@BASE  = ISNULL(SUM(LOJA_NOTA_FISCAL_IMPOSTO.BASE_IMPOSTO), 0)
			FROM LOJA_NOTA_FISCAL_IMPOSTO (NOLOCK)
			LEFT JOIN LOJA_NOTA_FISCAL_ITEM ICMS (NOLOCK)     	
				ON LOJA_NOTA_FISCAL_IMPOSTO.CODIGO_FILIAL = ICMS.CODIGO_FILIAL 
					AND LOJA_NOTA_FISCAL_IMPOSTO.NF_NUMERO = ICMS.NF_NUMERO 
					AND LOJA_NOTA_FISCAL_IMPOSTO.SERIE_NF = ICMS.SERIE_NF 
					AND LOJA_NOTA_FISCAL_IMPOSTO.ITEM_IMPRESSAO = ICMS.ITEM_IMPRESSAO     
					AND LOJA_NOTA_FISCAL_IMPOSTO.SUB_ITEM_TAMANHO = ICMS.SUB_ITEM_TAMANHO    
			WHERE LOJA_NOTA_FISCAL_IMPOSTO.NF_NUMERO = @NF_SAIDA AND LOJA_NOTA_FISCAL_IMPOSTO.SERIE_NF = @SERIE_NF 
				AND LOJA_NOTA_FISCAL_IMPOSTO.CODIGO_FILIAL = @FILIAL AND LOJA_NOTA_FISCAL_IMPOSTO.ID_IMPOSTO = @ID_IMPOSTO
--				AND ICMS.TRIBUT_ICMS NOT IN ('30','40','50','51','60')
				--#2# - INICIO
				--AND ICMS.TRIBUT_ICMS NOT IN ('30','40','41','50','60','90') --#6# 
				--#2# - FIM
		END
	ELSE
		BEGIN
			SELECT 		
				@VALOR = ISNULL(SUM(CASE WHEN LOJA_NOTA_FISCAL_IMPOSTO.INCIDENCIA IN (1, 4, 5) THEN LOJA_NOTA_FISCAL_IMPOSTO.VALOR_IMPOSTO ELSE 0 END), 0), 
				@BASE  = ISNULL(SUM(CASE WHEN LOJA_NOTA_FISCAL_IMPOSTO.INCIDENCIA IN (1, 4, 5) THEN LOJA_NOTA_FISCAL_IMPOSTO.BASE_IMPOSTO ELSE 0 END), 0)
			FROM LOJA_NOTA_FISCAL_IMPOSTO  (NOLOCK)
			WHERE NF_NUMERO = @NF_SAIDA AND SERIE_NF = @SERIE_NF AND CODIGO_FILIAL = @FILIAL AND ID_IMPOSTO = @ID_IMPOSTO
	END
	RETURN CASE WHEN @TIPO = 1 THEN @VALOR ELSE @BASE END
END