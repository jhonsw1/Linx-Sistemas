IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'KEY_AI')
INSERT INTO PARAMETROS(PARAMETRO, DESC_PARAMETRO, PENULT_ATUALIZACAO, ULT_ATUALIZACAO, TIPO_DADO, VALOR_DEFAULT, 
		VALOR_ATUAL, GLOBAL, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, NOTA_PROGRAMADOR)
VALUES('KEY_AI','KEY UTILIZADA PARA O ENVIO DAS EXCE��ES PARA O APPLICATION INSIGHTS.','20180212','20180212','C','','',0,1,1,0,0,0,'KEY UTILIZADA PARA O ENVIO DAS EXCE��ES PARA O APPLICATION INSIGHTS.')

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'LOG_EXCEPTION_ONLINE')
INSERT INTO PARAMETROS(PARAMETRO, DESC_PARAMETRO, PENULT_ATUALIZACAO, ULT_ATUALIZACAO, TIPO_DADO, VALOR_DEFAULT, 
		VALOR_ATUAL, GLOBAL, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, NOTA_PROGRAMADOR)
VALUES('LOG_EXCEPTION_ONLINE','PAR�METRO UTILIZADO PARA ATIVAR O ENVIO DAS EXCE��ES PARA O APPLICATION INSIGHTS.','20180212','20180212','L','.F.','.F.',0,1,1,0,0,0,'PAR�METRO UTILIZADO PARA ATIVAR O ENVIO DAS EXCE��ES PARA O APPLICATION INSIGHTS.')