-- POSSP-5157  - Gilvano Santos - (31/03/2021) - Nota T�cnica 2020.006
IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DATA_INI_NT2020_006')
BEGIN
	Insert into parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO,  
	TIPO_DADO,RANGE_VALOR_ATUAL, GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,	PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA, PERMITE_POR_LOJA,
	PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,
	ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DATA_INI_NT2020_006',GETDATE(),'06-04-2021', GETDATE(),'06-04-2021','Habilita os recursos da NT 2020.006 para NFe / NFC-e',	
		'D','',0,'Este parametro permite usuario alterar a data de inicio do conteudo da nota tecnica 2020.006 iss�o da NF-e ou NFC-e. formato da data DD-MM-AAAA',
		0,0,1,1,1,0,1,0	,0,0,0,GETDATE())
END