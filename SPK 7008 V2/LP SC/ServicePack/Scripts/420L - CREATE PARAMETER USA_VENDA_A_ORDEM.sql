IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'USA_VENDA_A_ORDEM')
  BEGIN
	INSERT INTO PARAMETROS 
	(PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, 
	TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, 
	ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, 
	ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE, DATA_PARA_TRANSFERENCIA)

	VALUES('USA_VENDA_A_ORDEM', getdate(), '.F.', getdate(), '.F.' , 'Habilita emiss�o de NF-e de Venda a Ordem nas franquias.',	
		   'L', '', 0, 'Processo de venda triangular', 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, getdate())

	INSERT INTO PARAMETROS_LOJA
	(PARAMETRO, CODIGO_FILIAL, VALOR_ATUAL, PERMITE_ALTERAR_NA_LOJA, DATA_PARA_TRANSFERENCIA, LX_STATUS_PARAMETRO)

	SELECT 'USA_VENDA_A_ORDEM' AS PARAMETRO, LV.CODIGO_FILIAL, 
		CASE WHEN F.FILIAL_PROPRIA = 1 THEN '.T.' ELSE '.F.' END AS VALOR_ATUAL,
		1 AS PERMITE_ALTERAR_NA_LOJA, GETDATE() AS DATA_PARA_TRANSFERENCIA, 1 AS LX_STATUS_PARAMETRO
	FROM LOJAS_VAREJO LV 
		INNER JOIN FILIAIS F ON F.FILIAL = LV.FILIAL 
		INNER JOIN PARAMETROS P ON P.PARAMETRO = 'USA_VENDA_A_ORDEM' 
			AND LTRIM(RTRIM(P.VALOR_ATUAL)) <> CASE WHEN F.FILIAL_PROPRIA = 1 THEN '.T.' ELSE '.F.' END
  END