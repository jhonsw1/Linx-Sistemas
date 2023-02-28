-- ID60592 - CRIA��O DO PAR�METRO DATA_INI_BLOCOX
IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DATA_INI_BLOCOX')
	INSERT INTO PARAMETROS (PARAMETRO, DESC_PARAMETRO, PENULT_ATUALIZACAO, ULT_ATUALIZACAO, TIPO_DADO, VALOR_DEFAULT, VALOR_ATUAL, GLOBAL, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE)
		VALUES ('DATA_INI_BLOCOX',
				'Data de in�cio para gera��o dos arquivo do Bloco X para lojas com CNAE de magazine.',
				'20180226','20180226','D','01/12/2018','01/12/2018',0,1,1,0,0,0,0,0,0)