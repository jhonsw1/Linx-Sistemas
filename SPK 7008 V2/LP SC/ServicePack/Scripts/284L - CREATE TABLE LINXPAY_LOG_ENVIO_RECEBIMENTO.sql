IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LINXPAY_LOG_ENVIO_RECEBIMENTO]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[LINXPAY_LOG_ENVIO_RECEBIMENTO](
		[CODIGO_FILIAL_ORIGEM] [char](8) NOT NULL,
		[SEQUENCIAL_PRE_VENDA] [char](13) NULL,
		[IDPAGAMENTO] [varchar](100) NOT NULL,
		[LINK_PAGAMENTO] [varchar](500) NULL,
		[EXPIRA_LINK] [datetime] NULL,
		[EMAIL] [varchar](200) NULL,
		[EMAIL_ENVIADO] [bit] NULL,
		[PEDIDO] [int] NOT NULL,
		[ENVIO] [varchar](max) NULL,
		[MERCHANTORDERID] [varchar](20) NULL,
		[PAN] [varchar](30) NULL,
		[AMOUNT] [numeric](15, 2) NULL,
		[INSTALLMENTS] [varchar](10) NULL,
		[CURRENCYB] [varchar](10) NULL,
		[BIN] [varchar](20) NULL,
		[BRAND] [varchar](20) NULL,
		[COUNTRY] [varchar](15) NULL,
		[STATUSP] [varchar](20) NULL,
		[CREATEDAT] [datetime] NULL,
		[SUPPLIERNAME] [varchar](25) NULL,
		[PAYERTRANSACTIONSTATUS] [varchar](30) NULL,
		[NSU] [varchar](30) NULL,
		[AUTHORIZATIONCODE] [varchar](25) NULL,
		[CURRENCYT] [varchar](20) NULL,
		[RETORNO] [varchar](max) NULL,
		[REQUESTID] [varchar](200) NULL,
		[MODE] [int] NULL,
		[TICKET] [char](8) NULL,
		[TERMINAL] [char](3) NULL,
		[DATA_VENDA] [datetime] NULL,
		[SIGNATURE] [varchar](100) NULL,
		[LASTTRANSACTIONSTATUS] [varchar](30) NULL,
		[DATA_PARA_TRANSFERENCIA] [datetime] NULL,
		[MOTIVO_CANCELAMENTO] [varchar](30) null,
	 CONSTRAINT [XPKLINXPAY_LOG_ENVIO_RECEBIMENTO] PRIMARY KEY CLUSTERED 
	(
		[CODIGO_FILIAL_ORIGEM] ASC,
		[PEDIDO] ASC,
		[IDPAGAMENTO] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END