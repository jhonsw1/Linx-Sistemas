IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DESABILITA_RECARGA_GIFT')
INSERT INTO PARAMETROS(PARAMETRO, DESC_PARAMETRO, PENULT_ATUALIZACAO, ULT_ATUALIZACAO, TIPO_DADO, VALOR_DEFAULT, 
		VALOR_ATUAL, GLOBAL, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, NOTA_PROGRAMADOR)
VALUES('DESABILITA_RECARGA_GIFT','DESABILITA A OP��O DE RECARGA DO GIFT CARD.','20180213','20180213','L','.F.','.F.',0,1,1,0,0,0,'PAR�METRO PARA DESABILITAR A OP��O DE EFETUAR RECARGA NO GIFT CARD.')


