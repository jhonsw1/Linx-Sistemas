IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_HABILITA')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_HABILITA','20200801','.F.',getdate(),'.F.','Habilita opera��es de venda ao consumidor final para entrega',	
		'L','',0,'	Quando o par�metro for igual a .T., o sistema ir� habilitar as funcionalidades de entrega',0,0,1,1,1,0,1,0,0,0,0,getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_INDPRES_NFE')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_INDPRES_NFE','20200801','3',getdate(),'3','Indicador de presen�a padr�o em venda delivery',	
		'I','',0,'Indicador de presen�a padr�o em venda delivery com NF-e ou NFC-e',0,0,1,1,1,0,1,0,0,0,0,getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_ALT_INDPRES_NFE')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_ALT_INDPRES_NFE','20200801','.F.',getdate(),'.F.','Permite o usu�rio alterar o indicador de presen�a na tela Delivery',	
		'L','',0,'Permite o usu�rio alterar o indicador de presen�a na tela Delivery',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_FRETE_MINIMO')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_FRETE_MINIMO','20200801','0',getdate(),'0','Permite valor m�nimo do frete nas opera��es de Venda Delivery',	
		'N','',0,'Permite valor m�nimo do frete nas opera��es de Venda Delivery. Quando o valor for igual a 0, admite frete gr�tis.',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_TRANSPORTADORA')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_TRANSPORTADORA','20200801','',getdate(),'','Transportadora padr�o em venda delivery (para NF-e e NFC-e).',	
		'C','',0,'Transportadora padr�o em venda delivery (para NF-e e NFC-e). O conte�do deve corresponder a TRANSPORTADORAS.TRANSPORTADORA da transportadora desejada, que deve estar ativa.',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END


IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_ALT_TRANSPORTA')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_ALT_TRANSPORTA','20200801','.T.',getdate(),'.T.','Habilita altera��o da transportadora padr�o na loja.',	
		'L','',0,'Habilita altera��o da transportadora padr�o na loja quando o valor padr�o � igual .T., o usu�rio poder� escolher uma transportadora diferente do parametro DELIVERY_TRANSPORTADORA.',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_NFE')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_NFE','20200801','.T.',getdate(),'.F.','Habilita emiss�o da NF-e para venda delivery',	
		'L','',0,'Habilita emiss�o da NF-e para venda delivery',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END

IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'DELIVERY_VIAS_RELATORIO')
	BEGIN
	Insert into Parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO, TIPO_DADO,RANGE_VALOR_ATUAL,
	GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,
	PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('DELIVERY_VIAS_RELATORIO','20200801','0',getdate(),'0','Controla a quantidade de vias do relat�rio de entrega.',	
		'I','',0,'Controla a quantidade de vias do relat�rio de entrega',0,0,1,1,1,0,1,0,0,0,0, getdate())
	END