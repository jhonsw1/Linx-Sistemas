



CREATE PROCEDURE [DBO].[LX_LJ_FIN_VENDA] @CODIGO_FILIAL CHAR(6), 
                                           @TERMINAL CHAR(3),
										   @DATA_VENDA    DATETIME                                           
AS 
  BEGIN 
      SET NOCOUNT ON 

      SELECT @DATA_VENDA = CONVERT(DATETIME, @DATA_VENDA, 103) 

      CREATE TABLE #VENDAS_NAO_FIN 
        ( 
           CODIGO_FILIAL		CHAR(6)  COLLATE DATABASE_DEFAULT, 
           DATA_VENDA			DATETIME, 
           TERMINAL				CHAR(3)  COLLATE DATABASE_DEFAULT, 
		   TICKET               CHAR(8) COLLATE DATABASE_DEFAULT, 
           LANCAMENTO_CAIXA     CHAR(7)  COLLATE DATABASE_DEFAULT, 
		   NUMERO_FISCAL_VENDA	CHAR(15) COLLATE DATABASE_DEFAULT NULL,
		   SERIE_NF_SAIDA		CHAR(6)  COLLATE DATABASE_DEFAULT NULL,
		   CF_NUMERO			NUMERIC(9, 0) NULL,
		   COO					CHAR(9)  NULL,
		    CONSTRAINT [PK_VENDAS_NAO_FIN] PRIMARY KEY CLUSTERED 
(
	[CODIGO_FILIAL] ASC,
	[DATA_VENDA] ASC,
	[TERMINAL] ASC,
	[LANCAMENTO_CAIXA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
        

      INSERT INTO #VENDAS_NAO_FIN 
      

				SELECT		LV.CODIGO_FILIAL, LV.DATA_VENDA, LV.TERMINAL, LV.TICKET, LV.LANCAMENTO_CAIXA, NF_VENDA.NF_NUMERO AS NUMERO_FISCAL_VENDA, NF_VENDA.SERIE_NF AS SERIE_NF_SAIDA, CF_SAT.CF_NUMERO, CUPOM.COO 
				FROM	LOJA_VENDA LV 
				JOIN	LOJA_VENDA_PGTO LV_PGTO
				ON		LV.CODIGO_FILIAL = LV_PGTO.CODIGO_FILIAL
				AND		LV.TERMINAL = LV_PGTO.TERMINAL
				AND		LV.LANCAMENTO_CAIXA = LV_PGTO.LANCAMENTO_CAIXA
				AND		LV.DATA_VENDA = LV_PGTO.DATA
				JOIN	LOJA_VENDA_PARCELAS LV_PARCELA
				ON		LV.CODIGO_FILIAL = LV_PARCELA.CODIGO_FILIAL
				AND		LV.TERMINAL = LV_PARCELA.TERMINAL
				AND		LV.LANCAMENTO_CAIXA = LV_PARCELA.LANCAMENTO_CAIXA
				LEFT JOIN	LOJA_VENDA_PRODUTO LV_PROD
				ON		LV.CODIGO_FILIAL = LV_PROD.CODIGO_FILIAL
				AND		LV.DATA_VENDA = LV_PROD.DATA_VENDA
				AND		LV.TICKET =	LV_PROD.TICKET
				LEFT JOIN	LOJA_VENDA_TROCA LV_TROCA
				ON		LV.CODIGO_FILIAL = LV_TROCA.CODIGO_FILIAL
				AND		LV.DATA_VENDA = LV_TROCA.DATA_VENDA
				AND		LV.TICKET =	LV_TROCA.TICKET
				LEFT JOIN	LOJA_NOTA_FISCAL NF_VENDA
				ON		LV_PGTO.NUMERO_FISCAL_VENDA = NF_VENDA.NF_NUMERO
				AND		LV_PGTO.SERIE_NF_SAIDA = NF_VENDA.SERIE_NF
				LEFT JOIN	LOJA_CF_SAT CF_SAT
				ON		LV_PGTO.CODIGO_FILIAL	=	CF_SAT.CODIGO_FILIAL
				AND		LV_PGTO.LANCAMENTO_CAIXA	= CF_SAT.LANCAMENTO_CAIXA
				AND		LV_PGTO.TERMINAL	=	CF_SAT.TERMINAL
				LEFT JOIN	LJ_DOCUMENTO_ECF CUPOM
				ON LV_PGTO.ID_EQUIPAMENTO = CUPOM.ID_EQUIPAMENTO 
				AND LV_PGTO.NUMERO_CUPOM_FISCAL = CUPOM.COO 
				AND LV_PGTO.CODIGO_FILIAL = CUPOM.CODIGO_FILIAL 
				WHERE	LV.DATA_VENDA = @DATA_VENDA
				AND		LV.CODIGO_FILIAL = @CODIGO_FILIAL
				AND		LV.TERMINAL = @TERMINAL	
				AND		LV_PGTO.VENDA_FINALIZADA = 0
				AND		( ( (NF_VENDA.NF_NUMERO IS NOT NULL AND  NF_VENDA.SERIE_NF IS NOT NULL)) OR (CF_SAT.CF_NUMERO IS NOT NULL) OR CUPOM.COO IS NOT NULL)
				GROUP BY LV.CODIGO_FILIAL, LV.DATA_VENDA, LV.TERMINAL, LV.TICKET, LV.LANCAMENTO_CAIXA, NF_VENDA.NF_NUMERO, NF_VENDA.SERIE_NF, CF_SAT.CF_NUMERO , CUPOM.COO			
				HAVING (ABS(MAX(LV.VALOR_TIKET) - MAX(LV_PGTO.TOTAL_VENDA) + MAX(LV_PGTO.DESCONTO_PGTO) ) +  
				ABS(MAX(LV.VALOR_CANCELADO) - MAX(LV_PGTO.VALOR_CANCELADO) ) +
				ABS(ISNULL(SUM(LV_PROD.PRECO_LIQUIDO * LV_PROD.QTDE),0) - ISNULL(MAX(LV.VALOR_VENDA_BRUTA),0) ) +  
				ABS(ISNULL(SUM(LV_PROD.PRECO_LIQUIDO * LV_PROD.QTDE_CANCELADA),0) - ISNULL(MAX(LV.VALOR_CANCELADO),0)  ) +
				ABS(ISNULL(SUM(LV_PROD.QTDE),0) - ISNULL(MAX(LV.QTDE_TOTAL),0) )+
				ABS(ISNULL(SUM(LV_PROD.QTDE_CANCELADA),0) - ISNULL(MAX(LV.TOTAL_QTDE_CANCELADA),0) ) +
				ABS(ISNULL(SUM(LV_TROCA.PRECO_LIQUIDO * LV_TROCA.QTDE),0) - ISNULL(MAX(LV.VALOR_TROCA),0) ) +
				ABS(ISNULL(SUM(LV_TROCA.QTDE),0) - ISNULL(MAX(LV.QTDE_TROCA_TOTAL),0) )+
				ABS(SUM(ISNULL(LV_PARCELA.VALOR,0)) - SUM(LV_PGTO.TOTAL_VENDA) )) = 0

				UPDATE VENDA_PGTO SET VENDA_FINALIZADA = '1' FROM LOJA_VENDA_PGTO VENDA_PGTO JOIN
				#VENDAS_NAO_FIN VENDAS_NAO_FIN 
				ON VENDA_PGTO.CODIGO_FILIAL = VENDAS_NAO_FIN.CODIGO_FILIAL
				AND VENDA_PGTO.TERMINAL = VENDAS_NAO_FIN.TERMINAL
				AND VENDA_PGTO.LANCAMENTO_CAIXA = VENDAS_NAO_FIN.LANCAMENTO_CAIXA
				AND VENDA_PGTO.DATA = VENDAS_NAO_FIN.DATA_VENDA
				WHERE VENDA_PGTO.CODIGO_FILIAL = @CODIGO_FILIAL
				AND VENDA_PGTO.TERMINAL = @TERMINAL
				AND VENDA_PGTO.DATA = @DATA_VENDA

				SELECT TICKET FROM #VENDAS_NAO_FIN

				DROP TABLE #VENDAS_NAO_FIN
  END 