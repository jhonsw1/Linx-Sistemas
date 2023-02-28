IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'ID_INTERMEDIADOR_PADRAO')
BEGIN
	Insert into parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO,  
	TIPO_DADO,RANGE_VALOR_ATUAL, GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,	PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA, PERMITE_POR_LOJA,
	PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,
	ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('ID_INTERMEDIADOR_PADRAO',GETDATE(),'', GETDATE(),'','Utiliza o intermediador padr�o nas vendas',	
		'N','',0,'Este parametro permite usuario cadastrar o ID do Intermediador na emiss�o da NF-e ou NFC-e referente a vendas.',
		0,0,1,1,1,0,1,0	,0,0,0,GETDATE())
END