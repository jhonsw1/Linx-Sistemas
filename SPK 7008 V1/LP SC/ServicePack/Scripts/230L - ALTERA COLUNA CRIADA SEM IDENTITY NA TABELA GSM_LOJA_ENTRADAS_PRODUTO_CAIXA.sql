IF (select count (*) from GSM_LOJA_ENTRADAS_PRODUTO_CAIXA) = 0
 BEGIN
		drop table GSM_LOJA_ENTRADAS_PRODUTO_CAIXA
 END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='GSM_LOJA_ENTRADAS_PRODUTO_CAIXA') 
BEGIN
CREATE TABLE DBO.GSM_LOJA_ENTRADAS_PRODUTO_CAIXA(
	ID_SEQ	                int identity     (1,1),   
	FILIAL_ORIGEM	        varchar	(25)  NOT NULL,
	FILIAL_DESTINO	        varchar	(25)  NOT NULL,
	EMISSAO	                datetime      NOT NULL,	
	ROMANEIO_PRODUTO	char	(15)  NOT NULL,
	PRODUTO	                char	(12)  NOT NULL,
	COR_PRODUTO	        char	(10)  NOT NULL,
	CODIGO_BARRA		varchar	(25)  NOT NULL,
	QTDE	                int	      NOT NULL,
	VALOR			numeric	(9,2) NOT NULL,
	CAIXA			Varchar	(100) NOT NULL,
	NUMERO_NF_TRANSFERENCIA	varchar	(20)  NOT NULL,
	SERIE_NF	        varchar	(3)   NOT NULL,
	PROCESSADO	        bit	      NOT NULL,
	DATA_PARA_TRANSFERENCIA	datetime      NOT NULL,
	TIPO_MOVIMENTO	        varchar	(2)   NULL
	 CONSTRAINT [XPKGSM_LOJA_ENTRADAS_PRODUTO_CAIXA] PRIMARY KEY CLUSTERED 
	(
		FILIAL_DESTINO ASC,
		CODIGO_BARRA  ASC,
		CAIXA ASC,
		NUMERO_NF_TRANSFERENCIA ASC,
		SERIE_NF ASC)
	)
END