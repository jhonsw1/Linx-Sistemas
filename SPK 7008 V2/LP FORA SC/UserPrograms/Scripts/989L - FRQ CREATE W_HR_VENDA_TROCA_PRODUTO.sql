
IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'W_HR_VENDA_TROCA_PRODUTO')
 BEGIN
  EXEC ('CREATE VIEW [dbo].[W_HR_VENDA_TROCA_PRODUTO] AS 
  SELECT LVP.CODIGO_FILIAL, LVP.TICKET, LVP.DATA_VENDA, LVP.PRODUTO, LVP.COR_PRODUTO, LVP.QTDE, LVP.PRECO_LIQUIDO,(LVP.PRECO_LIQUIDO+LVP.DESCONTO_ITEM) AS PRECO_BRUTO, LPV.PEDIDO, LV.CODIGO_CLIENTE  
  FROM dbo.LOJA_VENDA_PRODUTO (NOLOCK) LVP 
   INNER JOIN LOJA_VENDA (NOLOCK) LV ON LV.CODIGO_FILIAL = LVP.CODIGO_FILIAL AND LV.DATA_VENDA = LVP.DATA_VENDA AND LV.TICKET = LVP.TICKET
   LEFT JOIN LOJA_PEDIDO_VENDA (NOLOCK) LPV ON LVP.CODIGO_FILIAL = LPV.CODIGO_FILIAL AND LVP.TICKET = LPV.TICKET AND LVP.DATA_VENDA = LPV.DATA_VENDA AND LVP.ITEM = LPV.ITEM_VENDA   
  
  UNION ALL     
   SELECT LVT.CODIGO_FILIAL, LVT.TICKET, LVT.DATA_VENDA, LVT.PRODUTO, LVT.COR_PRODUTO, (LVT.QTDE * -1) AS QTDE, LVT.PRECO_LIQUIDO, (LVT.PRECO_LIQUIDO+LVT.DESCONTO_ITEM) AS PRECO_BRUTO, CONVERT(INT,NULL) AS PEDIDO, LV.CODIGO_CLIENTE      
   FROM dbo.LOJA_VENDA_TROCA (NOLOCK) LVT
    INNER JOIN LOJA_VENDA (NOLOCK) LV ON LV.CODIGO_FILIAL = LVT.CODIGO_FILIAL AND LV.DATA_VENDA = LVT.DATA_VENDA AND LV.TICKET = LVT.TICKET  
  
  UNION ALL  
   SELECT     
     LP.CODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL,    
     CONVERT(VARCHAR(8),LPV.TICKET) AS TICKET,     
     CONVERT(DATE,LP.DATA) AS DATA_VENDA,    
     LPP.PRODUTO,    
     LPP.COR_PRODUTO,    
     LPP.QTDE,    
     LPP.PRECO_LIQUIDO,
  	 (LPP.PRECO_LIQUIDO+LPP.DESCONTO_ITEM) AS PRECO_BRUTO,  
     LP.PEDIDO,
  	 LP.CODIGO_CLIENTE  
    FROM LOJA_PEDIDO (NOLOCK) LP     
    INNER JOIN LOJA_PEDIDO_PRODUTO (NOLOCK) LPP ON LP.CODIGO_FILIAL_ORIGEM =LPP.CODIGO_FILIAL_ORIGEM AND  LP.PEDIDO =LPP.PEDIDO AND LP.CANCELADO=0 AND LPP.CANCELADO=0    
    LEFT JOIN LOJA_PEDIDO_VENDA (NOLOCK) LPV ON LP.CODIGO_FILIAL_ORIGEM = LPV.CODIGO_FILIAL_ORIGEM  AND LP.PEDIDO = LPV.PEDIDO  AND LPP.ITEM = LPV.ITEM     
    WHERE (LPV.TICKET IS NULL or LPP.INDICA_ENTREGA_FUTURA =1)')
 END