
-- 06/05/2022 - FERNANDO MARINHO - PRODSHOP-12405 

CREATE VIEW [dbo].[SaleProducts] AS
SELECT 
	A.CODIGO_FILIAL, A.TERMINAL, A.LANCAMENTO_CAIXA, A.DATA, A.PERIODO_FECHAMENTO, A.NUMERO_CUPOM_FISCAL, 
	A.CAIXA_VENDEDOR, D.VENDEDOR_APELIDO, A.TOTAL_VENDA, B.QTDE_TOTAL, B.QTDE_TROCA_TOTAL, B.VENDEDOR, B.TICKET, 
	F.VENDEDOR_APELIDO AS NOME_VENDEDOR, C.ITEM, C.PRODUTO, C.COR_PRODUTO, C.TAMANHO, ISNULL(C.QTDE, 0) AS QTDE, 
	ISNULL(C.PRECO_LIQUIDO, 0) AS PRECO_LIQUIDO, E.DESC_PROD_NF, C.ITEM_EXCLUIDO, A.VENDA_FINALIZADA
FROM 
	LOJA_VENDA_PGTO A 
	INNER JOIN LOJA_VENDA B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL_PGTO AND A.TERMINAL = B.TERMINAL_PGTO AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA 
	LEFT JOIN LOJA_VENDA_PRODUTO C ON B.CODIGO_FILIAL = C.CODIGO_FILIAL AND B.TICKET = C.TICKET AND B.DATA_VENDA = C.DATA_VENDA 
	INNER JOIN LOJA_VENDEDORES D ON A.CAIXA_VENDEDOR = D.VENDEDOR 
	LEFT JOIN PRODUTOS E ON C.PRODUTO = E.PRODUTO 
	INNER JOIN LOJA_VENDEDORES F ON B.VENDEDOR = F.VENDEDOR
WHERE
	A.VALOR_CANCELADO = 0 AND B.TOTAL_QTDE_CANCELADA = 0 AND B.VALOR_CANCELADO = 0 AND B.DATA_HORA_CANCELAMENTO IS NULL


