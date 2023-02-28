IF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'WISHLIST_SENHA')
	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)
	SELECT	'WISHLIST_SENHA'   AS PARAMETRO,
			CAST(0 AS DATETIME)   AS PENULT_ATUALIZACAO,
			''                 AS VALOR_DEFAULT,
			GETDATE()             AS ULT_ATUALIZACAO,
			''                 AS VALOR_ATUAL,
			'Senha para comunicação com APIs do LinxComerce.' AS DESC_PARAMETRO,
			'C'                   AS TIPO_DADO,
			'' AS RANGE_VALOR_ATUAL,
			0                     AS GLOBAL,
			'Senha para comunicação com APIs do LinxComerce.'  AS NOTA_PROGRAMADOR,
			0                     AS ESCOPO,
			0                     AS POR_USUARIO_OK,
			1                     AS PERMITE_POR_EMPRESA,
			1                     AS ENVIA_PARA_LOJA,
			1                     AS PERMITE_POR_LOJA,
			0                     AS PERMITE_POR_TERMINAL,
			1                     AS PERMITE_ALTERAR_NA_LOJA,
			0                     AS PERMITE_ALTERAR_NO_TERMINAL,
			0                     AS ENVIA_PARA_REPRESENTANTE,
			0                     AS PERMITE_POR_REPRESENTANTE,
			0                     AS PERMITE_ALTERAR_NO_REPRESENTANTE