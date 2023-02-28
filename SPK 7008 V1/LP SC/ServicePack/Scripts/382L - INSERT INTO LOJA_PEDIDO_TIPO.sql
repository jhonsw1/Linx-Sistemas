
IF ((SELECT COUNT(1) FROM LOJA_PEDIDO_TIPO WHERE DESC_TIPO_PEDIDO = 'ENTREGA FUTURA PDV') = 0) BEGIN

	DECLARE @TIPO_PEDIDO SMALLINT = 0
	SET @TIPO_PEDIDO = ISNULL((SELECT MAX(TIPO_PEDIDO) FROM LOJA_PEDIDO_TIPO), 0) + 1
	
	INSERT INTO LOJA_PEDIDO_TIPO
	(
	   TIPO_PEDIDO
	  ,DESC_TIPO_PEDIDO
	  ,DATA_PARA_TRANSFERENCIA
	  ,LX_TIPO_PEDIDO
	  ,LX_STATUS_REGISTRO
	)
	SELECT @TIPO_PEDIDO         AS TIPO_PEDIDO
		  ,'ENTREGA FUTURA PDV' AS DESC_TIPO_PEDIDO
		  ,GETDATE()            AS DATA_PARA_TRANSFERENCIA
		  ,1                    AS LX_TIPO_PEDIDO
		  ,0                    AS LX_STATUS_REGISTRO

END