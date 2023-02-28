CREATE PROCEDURE dbo.LX_WS_USP (
	@COD_FILIAL VARCHAR(6),
	@FUNCAO VARCHAR(255),
	@CORPOXML VARCHAR(8000),
	@retornoXml XML OUTPUT)


	as
	/*******************************************************************************
	 Funcao:		PROCEDURE PARA COMUNICACAO COM WEBSERVICE USP DO CREDIARIO - POS
	 Empresa:	MEGASULT - 
	 Autor:		CARLOS MEGASULT - KATUXA
	 Data:		01/07/2018
     ATUALIZACAO 09/12/2019
     EX:			
	********************************************************************************/
    
	set nocount on
	DECLARE	@obj int,
				@url VarChar(MAX),
				@server varchar(255),
				@endereco varchar(255),
				@porta int,
				@retorno VarChar(max),
				@requestBody VarChar(MAX),
				@len int,
				@hr int,
				@action varchar(255),
				@mensagem varchar(255),
				@resposta int,
				@status int,
				@statusText varchar(255),
				@source varchar(255)

			set @resposta=0

			IF OBJECT_ID('tempdb..#wsuspxml') IS NOT NULL DROP TABLE #scpcxml
			CREATE TABLE #wsuspxml ( retxml XML )



        --VERIFICA DIREITOS
        exec LX_WS_OLE_VALID @mensagem OUTPUT
        IF @mensagem <> 'OK' 
        BEGIN
            set @resposta = 99
        END

		--VERIFICA FILIAL
		if @resposta = 0
		begin
			IF not exists (SELECT * FROM FILIAIS WHERE COD_FILIAL= @cod_filial)
				BEGIN
						set @resposta = 99
						set @mensagem='Filial nao cadastrada na Retaguarda'
				END
		end
	
		--verifica parametros
		if @resposta = 0
		begin
			select @endereco = dbo.fx_parametro_loja('WSCRLX_ADDRESS',@COD_FILIAL)
			select @porta = dbo.fx_parametro_loja('WSCRLX_PORT',@COD_FILIAL)
			select @server = dbo.fx_parametro_loja('WSCRLX_SERVER',@COD_FILIAL)

			if isnull(@endereco,'') = '' or ISNULL(@porta,0) = 0 or ISNULL(@server,'') = ''
			begin
				set @resposta = 99
				set @mensagem='Verifique os parametros WSCRLX_SERVER, WSCRLX_ADDRESS, WSCRLX_PORT'
			end
		end
	
		if @resposta = 0
		begin
			set @url = 'http://'+ltrim(rtrim(@server))+':'+LTRIM(rtrim(str(@porta)))+'/'+ltrim(rtrim(@endereco))
			set @url = REPLACE(@url,'?wsdl','')
			print @url
			
		end

		if @resposta = 0
		begin
			if ISNULL(@funcao,'') = ''
			begin
				set @resposta = 99
				set @mensagem='Parametro FUNCAO nao definido'
			end
			else
				set @action = '"http://tempuri.org/IService1/'+ltrim(rtrim(@funcao))+'"'		
		
		end

	
		--valida CORPOXML
		if @resposta=0
		begin
			if ISNULL(@CORPOXML,'')=''
			begin
				set @resposta = 99
				set @mensagem='Parametro CORPOXML nao informado'
			end
			--verifica se foi incluido namespace
			--IF CHARINDEX('xmlns="http://tempuri.org/"',@CORPOXML) = 0
			--	SET @CORPOXML = REPLACE(@CORPOXML,'<'+LTRIM(RTRIM(@FUNCAO))+'>','<'+LTRIM(RTRIM(@FUNCAO))+' xmlns="http://tempuri.org/">')
		end


		--monta e valida body xml
		IF @resposta=0
		BEGIN
			SET @requestBody = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
										<SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
										<SOAP-ENV:Body>
										<{action} xmlns="http://tempuri.org/">
										<{actionP} xmlns:SOAPSDK4="http://tempuri.org/">
										{params}
										</{actionP}>
										</{action}>
										</SOAP-ENV:Body>
										</SOAP-ENV:Envelope>'
			
			set @requestBody = replace(@requestBody, '{action}', ltrim(rtrim(@FUNCAO)))
			set @requestBody = replace(@requestBody, '{actionP}', 'sXml'+ltrim(rtrim(@FUNCAO)))

			--Incluir quotes
			set @CORPOXML = REPLACE (@CORPOXML,'<','&lt;')
			set @CORPOXML = REPLACE (@CORPOXML,'>','&gt;')

			set @requestBody = replace(@requestBody, '{params}', ltrim(rtrim(@CORPOXML)))

			if @requestBody is null
			begin
					set @resposta = 99
					set @mensagem='Corpo do XML invalido'
			end
			set @len = LEN(@requestBody)
		END
	
		--print @requestBody
	
		IF @resposta = 0
		BEGIN
			print 'Iniciando comunicacao com WS USP...'
			BEGIN TRY
				EXEC @hr = sp_OACreate 'MSXML2.ServerXMLHttp.3.0', @obj OUT
				EXEC @hr = sp_OAMethod @obj, 'Open', NULL, 'POST', @url, false
				IF @hr <> 0  
				BEGIN  
						EXEC sp_OAGetErrorInfo @obj, @source OUT, @mensagem OUT;  
						set @resposta=99
						set @mensagem = isnull(@source,'')+' - '+isnull(@mensagem,'')
				END
				if @resposta = 0
				begin
					EXEC @hr = sp_OAMethod @obj, 'setRequestHeader', NULL, 'Content-Type', 'text/xml; charset="UTF-8"'
					EXEC @hr = sp_OAMethod @obj, 'setRequestHeader', NULL, 'SOAPAction', @action
					EXEC @hr =  sp_OAMethod @obj, 'setRequestHeader', NULL, 'Content-Length', @len
					EXEC @hr =  sp_OAMethod @obj, 'send', NULL, @requestBody
					IF @hr <> 0  
					BEGIN  
							EXEC sp_OAGetErrorInfo @obj, @source OUT, @mensagem OUT;  
							set @resposta=99
							set @mensagem = isnull(@source,'')+' - '+isnull(@mensagem,'')
					END
					if @resposta = 0
					begin
						Exec @hr =  sp_OAMethod @obj, 'status', @status OUTPUT
						exec @hr =  sp_OAMethod @obj, 'statusText', @statusText OUTPUT
						EXEC @hr =  sp_OAGetProperty @obj, 'responseText', @retorno OUTPUT

						if @retorno is null --somente caso nao retornou com texto
						begin
							INSERT #wsuspxml ( retxml )
							EXEC sp_OAGetProperty @obj, 'responseXML.xml'
							select top 1  @retorno = CAST(retxml as varchar(max)) from #wsuspxml
						end

						print 'Status Text: '+@statusText
						if @status <> 200
						begin
							set @resposta=99
							set @mensagem = 'Resposta '+@url +' - '+ @statusText
						end

						--remove cabecalhos soap
						set @retorno = REPLACE(@retorno,'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body>','')
						set @retorno = REPLACE(@retorno,'</s:Body></s:Envelope>','')

						--remover cabecalhos do ws usp
						set @retorno = REPLACE(@retorno,'<SupportResponse xmlns="http://tempuri.org/">','')
						set @retorno = REPLACE(@retorno,'</SupportResponse>','')
						set @retorno = REPLACE(@retorno,'<SupportResult>','')
						set @retorno = REPLACE(@retorno,'</SupportResult>','')

						--remover quotes
						 set @retorno = REPLACE (@retorno,'&lt;','<')
						set @retorno = REPLACE (@retorno,'&gt;','>')
						print @retorno

						set @retornoXml =  cast(@retorno  as xml)
					
					end
				end
			
			END TRY
			BEGIN CATCH
				PRINT 'Erro no try sp_OAMethod'
				set @resposta=99
				SET @mensagem = SUBSTRING(ERROR_MESSAGE(),1,250)
				print @mensagem
			END CATCH

			EXEC sp_OADestroy @obj
		END
	
		--retorno
		if @resposta <> 0
		begin
			print @mensagem
			-- Gera o xml com as informações        
			set @retornoXml = '<'+ltrim(rtrim(@FUNCAO))+' status="'+ltrim(rtrim(str(@resposta)))+'" message="'+ltrim(rtrim(@mensagem))+'"><Retorno>' + isnull(cast(@retornoXml as varchar(max)),'')+'</Retorno></'+ltrim(rtrim(@FUNCAO))+'>'
			return 
		end
		else
			BEGIN
				return 
			END



	