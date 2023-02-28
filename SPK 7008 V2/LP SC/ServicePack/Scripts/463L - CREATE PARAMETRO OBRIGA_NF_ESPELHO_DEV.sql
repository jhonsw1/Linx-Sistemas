-- POSSP-5446 - Gilvano Santos - (31/05/2021) - CAPTURA DO VALOR DE ENTRADA DA TRANSFERENCIA/DEVOLU��O
IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'OBRIGA_NF_ESPELHO_DEV')
BEGIN
	Insert into parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO,  
	TIPO_DADO,RANGE_VALOR_ATUAL, GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,	PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA, PERMITE_POR_LOJA,
	PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,
	ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('OBRIGA_NF_ESPELHO_DEV',GETDATE(),'.F.', GETDATE(),'.T.','Habilita a valida��o da existencia do espelho da nota fiscal',	
		'L','',0,'Este parametro permite a valida��o da existencia do espelho da nota fiscal de entrada, caso n�o exista a tela n�o permitir� associar a nota fiscal desejada.',
		0,0,1,1,1,0,1,0	,0,0,0,GETDATE())
END