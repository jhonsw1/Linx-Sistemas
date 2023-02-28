
	create PROCEDURE DBO.LX_CALL_LJ_CREDIARIO_AUTORIZACAO 
		(	@ID					INT =NULL,
			@TIPO					VARCHAR(50) = NULL,
			@CODIGO_CLIENTE	VARCHAR(14) = NULL,
			@CODIGO_FILIAL			VARCHAR(6) = NULL,
			@TERMINAL			CHAR(3)=NULL,
			@OPERADOR			CHAR(4)=NULL,
			@DATA					DATETIME = NULL,
			@VALOR				NUMERIC(14,2)=NULL,
			@OBS_LOJA			VARCHAR(250)=NULL) 
		AS 
	
		/*******************************************************************************
		FUNCAO:		PROCEDURE PARA CHAMAR A EXECUCAO DO WEBSERVICE E GRAVAR AUTORIZACAO - LOJA
		EMPRESA:		MEGASULT - 
		AUTOR:		CARLOS MEGASULT - KATUXA
		DATA:			??/??/??
		EX:			EXEC 
		********************************************************************************/

		DECLARE @XML XML  ,@AUX VARCHAR(MAX),@RETORNOXML XML,@COD_FILIAL VARCHAR(6)
		SET ANSI_WARNINGS ON

   	    SELECT @COD_FILIAL = A.COD_FILIAL FROM FILIAIS A JOIN LOJAS_VAREJO B ON A.FILIAL = B.FILIAL WHERE B.CODIGO_FILIAL=@CODIGO_FILIAL
        SET @COD_FILIAL = isnull(@COD_FILIAL,@CODIGO_FILIAL)

		SET ANSI_WARNINGS ON
		SET @AUX = '<Support>'+(SELECT * 
											FROM (SELECT	CASE WHEN @ID = 0 THEN NULL ELSE @ID END AS ID,
																@TIPO AS TIPO,
																@CODIGO_CLIENTE AS CODIGO_CLIENTE,
																@COD_FILIAL AS COD_FILIAL,
																@TERMINAL AS TERMINAL,
																@OPERADOR AS OPERADOR,
																@DATA AS DATA,
																@VALOR AS VALOR,
																@OBS_LOJA AS OBS_LOJA ) LJ_CREDIARIO_AUTORIZACAO FOR XML AUTO,ELEMENTS)+'</Support>'

		EXEC LX_WS_USP @COD_FILIAL,'Support',@AUX,@RETORNOXML = @RETORNOXML OUTPUT

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
			SELECT  
						C.value('@ID', 'INT') AS ID,
						C.value('@TIPO', 'VARCHAR(50)') AS TIPO,
						C.value('@CODIGO_CLIENTE', 'VARCHAR(14)') AS CODIGO_CLIENTE,
						C.value('@COD_FILIAL', 'VARCHAR(6)') AS COD_FILIAL,
						C.value('@TERMINAL', 'VARCHAR(3)') AS TERMINAL,
						C.value('@OPERADOR', 'VARCHAR(4)') AS OPERADOR,
						C.value('@DATA', 'DATETIME') AS DATA,
						C.value('@VALOR', 'NUMERIC(14,2)') AS VALOR,
						C.value('@OBS_LOJA', 'VARCHAR(250)') AS OBS_LOJA,
						C.value('@STATUS', 'INT') AS STATUS,	--0 = PENDENTE, 1 = AUTORIZADO, 3 = NAO AUTORIZADO, 9 = ENCERRADO
						C.value('@DATA_STATUS', 'DATETIME') AS DATA_STATUS,
						C.value('@RESPONSAVEL', 'VARCHAR(25)') AS RESPONSAVEL,
						C.value('@MENSAGEM', 'VARCHAR(250)') AS MENSAGEM,
						C.value('@ID_CREDITO_CLIENTE', 'INT') AS ID_CREDITO_CLIENTE,
						CASE WHEN C.value('@STATUS', 'INT') = 1 THEN 'ESTA SOLICITAÇÃO SERÁ ENCERRADA NA PRÓXIMA VENDA' ELSE '' END AS AVISO
			FROM  @RETORNOXML.nodes('Support/Retorno/row') AS T(C)
			WHERE C.value('@ID', 'INT') IS NOT NULL

			RETURN
		 END
		 ELSE
			SELECT 'RETORNOU NULO' AS MENSAGEM
			GOTO RETORNO

		RETORNO:
			BEGIN
				RETURN
			END
	
