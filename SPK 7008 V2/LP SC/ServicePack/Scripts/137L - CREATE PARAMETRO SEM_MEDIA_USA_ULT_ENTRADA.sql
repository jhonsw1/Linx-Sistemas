IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'SEM_MEDIA_USA_ULT_ENTRADA')
INSERT INTO PARAMETROS(PARAMETRO, DESC_PARAMETRO, PENULT_ATUALIZACAO, ULT_ATUALIZACAO, TIPO_DADO, 
VALOR_DEFAULT, VALOR_ATUAL, GLOBAL, ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, 
PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, NOTA_PROGRAMADOR)
VALUES('SEM_MEDIA_USA_ULT_ENTRADA','PARA CALCULO DE ST QUANDO NÃO USAR A MÉDIA DAS ENTRADAS UTILIZARÁ A ULT. ENTRADA.',
	   '20180216',
	   '20180216',
	   'L',
	   '.F.',
	   '.F.',
	   0,
	   1,
	   1,
	   0,
	   0,
	   0,
	   'PARA CALCULO DE ST QUANDO NÃO USAR A MÉDIA DAS ENTRADAS UTILIZARÁ O SALDO DA ULTIMA ENTRADA PARA COMPOR A BASE DE CALCULO DE ST.')