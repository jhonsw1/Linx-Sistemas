IF NOT EXISTS(SELECT 1 FROM PARAMETROS WHERE PARAMETRO = 'HR_NDIAS_IMPACTACLIENTE') 		
BEGIN
INSERT INTO PARAMETROS(PARAMETRO,DESC_PARAMETRO,VALOR_ATUAL,TIPO_DADO,
			GLOBAL,ESCOPO,POR_USUARIO_OK,PERMITE_POR_EMPRESA,
			ENVIA_PARA_LOJA,PERMITE_POR_LOJA,PERMITE_POR_TERMINAL,
			PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,
			ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,
			PERMITE_ALTERAR_NO_REPRESENTANTE,PENULT_ATUALIZACAO,
			ULT_ATUALIZACAO,DATA_PARA_TRANSFERENCIA)
VALUES('HR_NDIAS_IMPACTACLIENTE','LIBERA PESQUISA PINPAD','15','N',
  	   0,0,0,0,1,1,0,0,0,0,0,0,GETDATE(),GETDATE(),GETDATE())
END  	   

