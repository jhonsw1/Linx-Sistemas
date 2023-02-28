
CREATE PROCEDURE DBO.LX_CALL_CLIENTES_VAREJO_DOCUMENTO 
	(	@CODIGO_CLIENTE VARCHAR(14), 
		@CODIGO_FILIAL VARCHAR(6)) 
	AS 
	/*******************************************************************************
	 FUNCAO:		LX_CALL_CLIENTES_VAREJO_DOCUMENTO - LOJA
	 EMPRESA:	MEGASULT - 
	 AUTOR:		CARLOS MEGASULT - KATUXA
	 DATA:		??/??/??
	 EX:			EXEC LX_CALL_CLIENTES_VAREJO_DOCUMENTO '00000899585',
	********************************************************************************/

	--CARLOS MEGASULT 30/01/2018 - PROCEDURE PARA CHAMAR ENVIAR DOCUMENTOS PARA RETAGUARDA VIA WEBSERVICE (OBS: A IMAGEM NAO � ENVIADA, ELA VAI VIA DATASYNC OU ETL)
	DECLARE @XML XML  ,@AUX VARCHAR(MAX),@RETORNOXML XML
	SET ANSI_WARNINGS ON

	SET @AUX = '<Support>'+ (	SELECT * FROM (SELECT A.ID,A.CODIGO_CLIENTE,CLIENTE_VAREJO,A.CODIGO_FILIAL,A.LEGENDA,A.RESPONSAVEL,A.ID_DOC_TIPO,LTRIM(RTRIM(A.PATH_ARQUIVO)) AS PATH_ARQUIVO,A.INATIVO,A.DATA_PARA_TRANSFERENCIA 
											FROM CLIENTES_VAREJO_DOCUMENTO A JOIN CLIENTES_VAREJO B ON A.CODIGO_CLIENTE = B.CODIGO_CLIENTE
											WHERE A.CODIGO_CLIENTE=@CODIGO_CLIENTE ) CLIENTES_VAREJO_DOCUMENTO FOR XML AUTO, ELEMENTS)+'</Support>'

    SELECT @CODIGO_FILIAL = A.COD_FILIAL FROM FILIAIS A JOIN LOJAS_VAREJO B ON A.FILIAL = B.FILIAL WHERE B.CODIGO_FILIAL=@CODIGO_FILIAL

	EXEC LX_WS_USP @CODIGO_FILIAL,'Support',@AUX,@RETORNOXML = @RETORNOXML OUTPUT

    if charindex('Support',substring(cast(@retornoxml as varchar(max)),1,100)) = 0 
         begin
             SELECT substring(cast(@retornoxml as varchar(max)),1,100)  AS MENSAGEM
			GOTO RETORNO
         end

	IF EXISTS (SELECT STATUS FROM (SELECT @RETORNOXML.value('/Support[1]/@status','INT') STATUS ) A WHERE STATUS > 0 )
	BEGIN
		SELECT @RETORNOXML.value('/Support[1]/@message','VARCHAR(250)')  AS MENSAGEM
		GOTO RETORNO
	END

	IF @RETORNOXML IS NOT NULL
	BEGIN
		SELECT 'OK' AS MENSAGEM
		GOTO RETORNO
	 END
	 ELSE
		SELECT 'RETORNOU NULO' AS MENSAGEM
		GOTO RETORNO


	RETORNO:
		BEGIN
			RETURN
		END
	




