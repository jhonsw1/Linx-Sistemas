IF NOT EXISTS ( SELECT 1 FROM PARAMETROS WHERE PARAMETRO ='HR_SOLICITA_MOTIVO_TROCA')
 BEGIN
	EXEC('
		insert into parametros(PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT,ULT_ATUALIZACAO,VALOR_ATUAL,DESC_PARAMETRO,TIPO_DADO,RANGE_VALOR_ATUAL,GLOBAL,ESCOPO,POR_USUARIO_OK,DATA_PARA_TRANSFERENCIA,NOTA_PROGRAMADOR,PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE)  VALUES  (''HR_SOLICITA_MOTIVO_TROCA'',''20200522 00:00:00'','''',''20200522 00:00:00'',''.F.'',''PARAMETRO PARA DEFINIR SE PEDIRA PARA LOJA INFORMAR O MOTIVO DA DEVOLUCAO DAS PECAS'',''L'','''',''0'',''0'',''1'',''20200522 14:39:23'',''PARAMETRO PARA DEFINIR SE PEDIRA PARA LOJA INFORMAR O MOTIVO DA DEVOLUCAO DAS PECAS'',''1'',''1'',''1'',''0'',''0'',''0'',''0'',''0'',''0'')')
	END
	