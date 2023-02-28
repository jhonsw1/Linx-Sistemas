-- POSSP-5095 - Gilvano Santos - (10/12/2021) - Tratamento referenciar Troca
IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'ASSOCIA_TROCA_FISCAL')
BEGIN
	Insert into parametros (PARAMETRO,PENULT_ATUALIZACAO,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO,  
	TIPO_DADO,RANGE_VALOR_ATUAL, GLOBAL,NOTA_PROGRAMADOR,ESCOPO,POR_USUARIO_OK,	PERMITE_POR_EMPRESA,ENVIA_PARA_LOJA, PERMITE_POR_LOJA,
	PERMITE_POR_TERMINAL,PERMITE_ALTERAR_NA_LOJA,PERMITE_ALTERAR_NO_TERMINAL,
	ENVIA_PARA_REPRESENTANTE,PERMITE_POR_REPRESENTANTE,PERMITE_ALTERAR_NO_REPRESENTANTE,DATA_PARA_TRANSFERENCIA) 
	values('ASSOCIA_TROCA_FISCAL',GETDATE(),'.F.', GETDATE(),'.F.','Obriga digitar o documento fiscal de venda em operações de troca.',	
		'L','',0,'Este parametro obriga digitar o documento fiscal eletronico da venda (NF-e, NFC-e ou CF-e Sat), quando o LinxPOS não conseguiu associar automaticamente o item de troca ao item de venda. O parametro permitirá digitar documentos independente do cnpj emissor quando o parametro possuir o valor .T. (Verdadeiro), caso contrario o LinxPOS vai utilizar o recurso do associar troca origem.',
		0,0,1,1,1,0,0,0	,0,0,0,GETDATE())
END