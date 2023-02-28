IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'SERV_HUB_SIMP_VL_TROCA')
BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('SERV_HUB_SIMP_VL_TROCA','20200622','.F.','20200622','.F.','Habilita a gera��o simplificada do vale troca',	
		'L','',0,'Habilita a gera��o simplificada do vale troca especifico para Givex',0,0,0,1,1,0,0,0,0,0,0,'20200622')
END
