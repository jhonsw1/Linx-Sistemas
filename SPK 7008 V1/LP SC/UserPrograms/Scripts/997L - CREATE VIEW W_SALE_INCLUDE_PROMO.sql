IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'W_SALE_INCLUDE_PROMO')
  BEGIN
	EXEC('CREATE VIEW W_SALE_INCLUDE_PROMO  
	  AS  
	   SELECT   
	    A.CODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL,  
	    A.PEDIDO,  
	    CONVERT(VARCHAR(8),NULL) AS TICKET,   
	    CONVERT(DATE,A.DATA) AS DATA_VENDA,  
	    A.CODIGO_CLIENTE,  
	    A.QTDE_TOTAL,  
	    A.VALOR_TOTAL,  
	    A.DESCONTO,  
	    B.CODIGO_BARRA,  
	    B.PRODUTO,  
	    B.COR_PRODUTO,  
	    B.TAMANHO,  
	    B.QTDE,  
	    B.PRECO_LIQUIDO,  
	    B.DESCONTO_ITEM  
	   FROM LOJA_PEDIDO A   
	    INNER JOIN LOJA_PEDIDO_PRODUTO B ON A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM AND A.PEDIDO = B.PEDIDO AND A.CANCELADO =0 AND B.CANCELADO =0  
	    LEFT JOIN LOJA_PEDIDO_VENDA C ON A.CODIGO_FILIAL_ORIGEM =C.CODIGO_FILIAL_ORIGEM AND A.PEDIDO = C.PEDIDO AND B.ITEM = C.ITEM   
	   WHERE (C.TICKET IS NULL OR INDICA_ENTREGA_FUTURA =1)  
	  UNION ALL  
	   SELECT   
	    A.CODIGO_FILIAL AS CODIGO_FILIAL,  
	    CONVERT(INT,NULL) AS PEDIDO,  
	    A.TICKET AS TICKET,   
	    A.DATA_VENDA AS DATA_VENDA,  
	    A.CODIGO_CLIENTE,  
	    A.QTDE_TOTAL,  
	    A.VALOR_PAGO AS VALOR_TOTAL,  
	    A.DESCONTO,  
	    B.CODIGO_BARRA,  
	    B.PRODUTO,  
	    B.COR_PRODUTO,  
	    B.TAMANHO,  
	    B.QTDE,  
	    B.PRECO_LIQUIDO,  
	    B.DESCONTO_ITEM  
	   FROM LOJA_VENDA A   
	    INNER JOIN SalesAllItems B ON A.CODIGO_FILIAL =B.CODIGO_FILIAL AND A.DATA_VENDA =B.DATA_VENDA AND A.TICKET =B.TICKET   
	   WHERE DATA_HORA_CANCELAMENTO IS NULL')
  END