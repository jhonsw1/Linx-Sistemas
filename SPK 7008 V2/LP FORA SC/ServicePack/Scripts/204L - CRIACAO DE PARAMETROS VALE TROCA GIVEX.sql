-- Insere parâmetros do Vale OmniIF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_URL')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_URL' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,			'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'' AS VALOR_ATUAL,			'URL DO SERVICE HUB.' AS DESC_PARAMETRO,			'C' AS TIPO_DADO,			'' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'URL DO SERVICE HUB.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTEIF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_CHAVE_INT')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_CHAVE_INT' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,			'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'' AS VALOR_ATUAL,			'CHAVE INTEGRAÇÃO CRIADA NO SERVICE HUB.' AS DESC_PARAMETRO,			'C' AS TIPO_DADO,			'' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'CHAVE INTEGRAÇÃO CRIADA NO SERVICE HUB.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTEIF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_COD_LOJA')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_COD_LOJA' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,			'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'' AS VALOR_ATUAL,			'CÓDIGO DA LOJA CRIADO NO SERVICE HUB.' AS DESC_PARAMETRO,			'C' AS TIPO_DADO,			'' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'CÓDIGO DA LOJA CRIADO NO SERVICE HUB.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTEIF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_USA_GIFTCARD')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_USA_GIFTCARD' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,			'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'.F.' AS VALOR_ATUAL,			'HABILITA O SERVIÇO DE GIFTCARD.' AS DESC_PARAMETRO,			'L' AS TIPO_DADO,			'.F.' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'HABILITA O SERVIÇO DE GIFTCARD.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTE			IF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_USA_FIDELIDADE')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_USA_FIDELIDADE' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,			'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'.F.' AS VALOR_ATUAL,			'HABILITA O SERVIÇO DE FIDELIDADE.' AS DESC_PARAMETRO,			'L' AS TIPO_DADO,			'.F.' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'HABILITA O SERVIÇO DE FIDELIDADE.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTE			IF NOT EXISTS(SELECT TOP 1 1 FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_USA_VL_TROCA')	INSERT INTO PARAMETROS (PARAMETRO, PENULT_ATUALIZACAO, VALOR_DEFAULT, ULT_ATUALIZACAO, VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR, ESCOPO, POR_USUARIO_OK, PERMITE_POR_EMPRESA, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)	SELECT	'SERV_HUB_USA_VL_TROCA' AS PARAMETRO,			CAST(0 AS DATETIME) PENULT_ATUALIZACAO,'' AS VALOR_DEFAULT,			GETDATE() AS ULT_ATUALIZACAO,			'.F.' AS VALOR_ATUAL,			'HABILITA O SERVIÇO DE VALE TROCA.' AS DESC_PARAMETRO,			'L' AS TIPO_DADO,			'.F.' AS RANGE_VALOR_ATUAL,			0 AS GLOBAL,'HABILITA O SERVIÇO DE VALE TROCA.' AS NOTA_PROGRAMADOR,			0 AS ESCOPO,			0 AS POR_USUARIO_OK,			0 AS PERMITE_POR_EMPRESA,			1 AS ENVIA_PARA_LOJA,			1 AS PERMITE_POR_LOJA,			0 AS PERMITE_POR_TERMINAL,			0 AS PERMITE_ALTERAR_NA_LOJA,			0 AS PERMITE_ALTERAR_NO_TERMINAL,			0 AS ENVIA_PARA_REPRESENTANTE,			0 AS PERMITE_POR_REPRESENTANTE,			0 AS PERMITE_ALTERAR_NO_REPRESENTANTE