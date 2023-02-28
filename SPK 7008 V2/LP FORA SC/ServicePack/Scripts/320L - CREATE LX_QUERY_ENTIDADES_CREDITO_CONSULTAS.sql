
CREATE PROCEDURE dbo.LX_QUERY_ENTIDADES_CREDITO_CONSULTAS
	(	@tipo varchar(25),
		@id int =null,
		@documento varchar(19),
		@codigo_cliente varchar(14) =null,
		@resposta int= null) 
		AS 

	/*******************************************************************************
	 Funcao:		PROCEDURE PARA ABRIR O XML DE RETORNO DAS ENTIDADES DE CREDITO, RETORNANDO OS DADOS CONFORME O TIPO DE INFORMACAO - RETAGUARDA
	 Empresa:	MEGASULT - 
	 Autor:		CARLOS MEGASULT - KATUXA
	 Data:		30/01/2018
	 EX:			
	********************************************************************************/

	declare @xml xml  ,@ID_C INT, @MSG_C VARCHAR(800),@ORIGEM_C VARCHAR(150),@TEMPO_C VARCHAR(50)

	SET NOCOUNT ON
	set ansi_warnings on

	if exists(select * from sys.objects where type='U' AND name='ENTIDADES_CREDITO_CONSULTAS')
		begin
			SET @xml = (SELECT * 
								from ENTIDADES_CREDITO_CONSULTAS WITH (NOLOCK) 
								where (id = @id or @id is null) 
								  and (codigo_cliente = @codigo_cliente or @codigo_cliente is null) 
								  and (resposta = @resposta or @resposta is null)  
								  and documento = @documento 
								  and (tipo = @tipo or @tipo is null)
							for XML AUTO)
		end
	
		IF OBJECT_ID('tempdb..##TMP_ENT_QUERY_C') IS NOT NULL 
				DROP TABLE ##TMP_ENT_QUERY_C

		IF OBJECT_ID('tempdb..##TMP_ENT_QUERY_D') IS NOT NULL 
				DROP TABLE ##TMP_ENT_QUERY_D

		IF OBJECT_ID('tempdb..##TMP_ENT_QUERY_Q') IS NOT NULL 
				DROP TABLE ##TMP_ENT_QUERY_Q

		IF OBJECT_ID('tempdb..##TMP_ENT_QUERY_R') IS NOT NULL 
				DROP TABLE ##TMP_ENT_QUERY_R

	--SCPC
	IF @TIPO='SPC'
	BEGIN
		--cabecalho
		IF OBJECT_ID('tempdb..##TMP_SPC_QUERY_C') IS NOT NULL 
			DROP TABLE ##TMP_SPC_QUERY_C

		select  
					C.value('@TIPO', 'varchar(10)') AS TIPO,
					B.FILIAL,
					C.value('@DATA', 'DATETIME') AS DATA,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/spc/resumo/@quantidade-total)[1]', 'int') AS TOTAL_DEBITOS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/spc/resumo/@valor-total)[1]', 'numeric(14,2)') AS VALOR_DEBITOS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CONSULTAS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/resumo/@data-ultima-ocorrencia)[1]', 'date') AS ULTIMA_CONSULTA,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/detalhe-consulta-realizada/@nome-associado)[1]', 'varchar(100)') AS ASSOCIADO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/detalhe-consulta-realizada/@nome-entidade-origem)[1]', 'varchar(100)') AS ENTIDADE,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/@quantidade-dias-consultados)[1]', 'int') AS DIAS_CONSULTADOS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/alerta-documento/resumo/@quantidade-total)[1]', 'int') AS TOTAL_ALERTA_DOCUMENTOS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/alerta-documento/resumo/@data-ultima-ocorrencia)[1]', 'date') AS DATA_ALERTA_DOCUMENTOS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/cheque-lojista/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CHEQUE_LOJISTAS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/cheque-lojista/resumo/@valor-total)[1]', 'numeric(14,2)') AS VALOR_CHEQUE_LOJISTAS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/cheque-lojista/resumo/@data-ultima-ocorrencia)[1]', 'date') AS DATA_CHEQUE_LOJISTAS,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/credito-concedido/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CREDITO_CONCEDIDO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/credito-concedido/resumo/@valor-total)[1]', 'numeric(14,2)') AS VALOR_CREDITO_CONCEDIDO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/ccf/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CCF,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/contra-ordem/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CONTRA_ORDEM,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@nome)[1]', 'varchar(100)') AS NOME,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@idade)[1]', 'int') AS IDADE,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/cpf/@numero)[1]', 'varchar(14)') AS CPF,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@numero-rg)[1]', 'varchar(14)') AS RG,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@numero-titulo-eleitor)[1]', 'varchar(14)') AS TITULO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@data-nascimento)[1]', 'date') AS NASCIMENTO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/@logradouro)[1]', 'varchar(50)') AS LOGRADOURO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/@numero)[1]', 'varchar(14)') AS NUMERO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/@bairro)[1]', 'varchar(14)') AS BAIRRO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/@cep)[1]', 'varchar(8)') AS CEP,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/cidade/@nome)[1]', 'varchar(50)') AS CIDADE,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/endereco/cidade/estado/@sigla-uf)[1]', 'varchar(2)') AS UF,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/telefone-residencial/@numero-ddd)[1]', 'varchar(4)') AS DDD,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/telefone-residencial/@numero)[1]', 'varchar(12)') AS TELEFONE,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@email)[1]', 'varchar(50)') AS EMAIL,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@estado-civil)[1]', 'varchar(14)') AS ESTADO_CIVIL,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@sexo)[1]', 'varchar(14)') AS SEXO,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@nome-mae)[1]', 'varchar(50)') AS MAE,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consumidor/consumidor-pessoa-fisica/@nome-pai)[1]', 'varchar(50)') AS PAI,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/operador/@codigo)[1]', 'varchar(10)') AS OPERADOR,
					C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/operador/@nome)[1]', 'varchar(10)') AS NOME_OPERADOR,
					C.value('@ID', 'INT') AS ID,
					@documento as DOCUMENTO
					INTO ##TMP_SPC_QUERY_C
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS') as T(C)
		LEFT JOIN FILIAIS B ON C.value('@COD_FILIAL', 'varchar(6)') = B.COD_FILIAL


			--resumo
		IF OBJECT_ID('tempdb..##TMP_SPC_QUERY_R') IS NOT NULL 
			DROP TABLE ##TMP_SPC_QUERY_R

		select  
				C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/spc/resumo/@quantidade-total)[1]', 'int') AS TOTAL_DEBITOS,
				C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/spc/resumo/@valor-total)[1]', 'numeric(14,2)') AS VALOR_DEBITOS,
				C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/resumo/@quantidade-total)[1]', 'int') AS TOTAL_CONSULTAS,
				C.value('(RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/resumo/@data-ultima-ocorrencia)[1]', 'date') AS ULTIMA_CONSULTA,
				C.value('@ID', 'INT') AS ID,
				@documento as DOCUMENTO
		INTO ##TMP_SPC_QUERY_R
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS') as T(C)

		--debitos
		IF OBJECT_ID('tempdb..##TMP_SPC_QUERY_D') IS NOT NULL 
			DROP TABLE ##TMP_SPC_QUERY_D

		SELECT 
				T.C.value('@contrato', 'varchar(15)') AS CONTRATO,
				T.C.value('@valor', 'numeric(14,2)') AS VALOR,
				T.C.value('@data-inclusao', 'date') AS DATA,
				T.C.value('@data-vencimento', 'date') AS VENCIMENTO,
				T.C.value('@nome-associado', 'varchar(50)') AS ASSOCIADO,
				T.C.value('@nome-entidade', 'varchar(50)') AS ENTIDADE,
				T.C.value('@comprador-fiador-avalista', 'varchar(10)') AS TIPO,
				@documento as DOCUMENTO,
				T.C.value('../../../../../../@ID', 'INT') AS ID
		INTO ##TMP_SPC_QUERY_D
		FROM   @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SEnvelope/SBody/nsXresultado/spc/detalhe-spc') as T(C) 

		--historico de consultas
		IF OBJECT_ID('tempdb..##TMP_SPC_QUERY_Q') IS NOT NULL 
			DROP TABLE ##TMP_SPC_QUERY_Q
	
		SELECT 
				T.C.value('@data-consulta', 'date') AS DATA,
				T.C.value('@nome-associado', 'varchar(50)') AS ASSOCIADO,
				T.C.value('@nome-entidade-origem', 'varchar(50)') AS ENTIDADE,
				T.C.value('(origem-associado/@nome)[1]', 'varchar(50)') AS CIDADE,
				T.C.value('(origem-associado/estado/@sigla-uf)[1]', 'varchar(2)') AS UF,
				@documento as DOCUMENTO,
				T.C.value('../../../../../../@ID', 'INT') AS ID
		INTO ##TMP_SPC_QUERY_Q
		FROM   @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SEnvelope/SBody/nsXresultado/consulta-realizada/detalhe-consulta-realizada') as T(C) 
		
	END

	--SCPC
	IF @TIPO='SCPC'
	BEGIN
		--cabecalho
		IF OBJECT_ID('tempdb..##TMP_SCPC_QUERY_C') IS NOT NULL 
			DROP TABLE ##TMP_SCPC_QUERY_C

		select  
				C.value('@TIPO', 'varchar(10)') AS TIPO,
			--	C.value('@CODIGO_CLIENTE', 'varchar(14)') AS CODIGO_CLIENTE,
			--	C.value('@COD_FILIAL', 'varchar(6)') AS COD_FILIAL,
				B.FILIAL,
				--D.DOCUMENTO,
				C.value('@DATA', 'DATETIME') AS DATA,
			--	C.value('@STATUS', 'varchar(25)') AS STATUS,
			--	C.value('@RESPOSTA', 'INT') AS RESPOSTA,
			--	C.value('@MENSAGEM', 'VARCHAR(250)') AS MENSAGEM,
				C.value('count(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-122-DADOS/SPC-125-DEBITO)', 'int') AS TOTAL_DEBITOS,
				CAST(0 AS numeric(14,2)) AS VALOR_DEBITOS,
				C.value('count(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-126-CONSULTA/SPC-126-ANTERIORES)', 'int') AS TOTAL_CONSULTAS,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-126-CONSULTA/SPC-126-ANTERIORES/SPC-126-OCORRENCIA)[1]', 'date') AS ULTIMA_CONSULTA,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/NUMERO-RESPOSTA)[1]', 'VARCHAR(20)') AS NUMERO_RESPOSTA,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/ASSOCIADO-SOLICITANTE)[1]', 'VARCHAR(25)') AS ASSOCIADO_SOLICITANTE,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/NOME-CONSULTA)[1]', 'VARCHAR(25)') AS NOME_CONSULTA,
				CAST('' AS varchar(800)) AS OCORRENCIAS,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/IP-SOLICITANTE)[1]', 'VARCHAR(25)') AS IP_SOLICITANTE,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-128-SINTESE/SPC-128-DADOS/SPC-128-NOME)[1]', 'VARCHAR(60)') AS SINTESE_NOME,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-128-SINTESE/SPC-128-DADOS/SPC-128-CPF)[1]', 'VARCHAR(25)') AS SINTESE_CPF,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-128-SINTESE/SPC-128-DADOS/SPC-128-NASCIMENTO)[1]', 'DATE') AS SINTESE_NASCIMENTO,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-128-SINTESE/SPC-128-DADOS/SPC-129-MAE)[1]', 'VARCHAR(60)') AS SINTESE_MAE,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-130-DDD)[1]', 'VARCHAR(4)') AS SINTESE_FON_DDD,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-130-TELEFONE)[1]', 'VARCHAR(12)') AS SINTESE_FON_TELEFONE,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-130-ENDERECO)[1]', 'VARCHAR(60)') AS SINTESE_FON_ENDERECO,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-131-BAIRRO)[1]', 'VARCHAR(60)') AS SINTESE_FON_BAIRRO,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-131-CEP)[1]', 'VARCHAR(8)') AS SINTESE_FON_CEP,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-131-CIDADE)[1]', 'VARCHAR(60)') AS SINTESE_FON_CIDADE,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-FON/FON-130-TELEFONE-V/FON-130-VINCULADO-DOC/FON-131-UF)[1]', 'VARCHAR(2)') AS SINTESE_FON_UF,
				C.value('@ID', 'INT') AS ID,
				@documento as DOCUMENTO
		INTO ##TMP_SCPC_QUERY_C
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS') as T(C)
		LEFT JOIN FILIAIS B ON C.value('@COD_FILIAL', 'varchar(6)') = B.COD_FILIAL
	
		--LEFT JOIN (SELECT TOP 1 ID,ISNULL(MSG,'')+' - ORIGEM: '+ISNULL(ORIGEM,'')+' - TEMPO: '+ISNULL(TEMPO,'') AS MSG FROM (
		--			select  
		--				C.value('../../../../../../@ID', 'INT') AS ID,
		--				C.value('SPC-124-MSG[1]', 'VARCHAR(250)') AS MSG,
		--				C.value('SPC-124-ORIGEM[1]', 'VARCHAR(250)') AS ORIGEM,
		--				C.value('SPC-124-TPMSG[1]', 'VARCHAR(250)') AS TEMPO
		--				from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-122-DADOS/SPC-124-COMPLEMENTAR') as T(C) 
		--				) A ORDER BY LEN(MSG) DESC
		--			) AS OCORRENCIAS ON C.value('@ID', 'INT') = OCORRENCIAS.ID

		--PREENCHER OCORRENCIAS
	
		DECLARE curOcorrencias CURSOR FAST_FORWARD FOR
			SELECT  ID,MSG,ORIGEM,TEMPO FROM (
				SELECT  
				C.value('SPC-124-MSG[1]', 'VARCHAR(250)') AS MSG,
				C.value('SPC-124-ORIGEM[1]', 'VARCHAR(250)') AS ORIGEM,
				C.value('SPC-124-TPMSG[1]', 'VARCHAR(250)') AS TEMPO,
				C.value('../../../../../../@ID', 'INT') AS ID
				from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-122-DADOS/SPC-124-COMPLEMENTAR') as T(C) 
				) A
			OPEN curOcorrencias
			FETCH NEXT FROM curOcorrencias INTO @ID_C,@MSG_C,@ORIGEM_C,@TEMPO_C
			WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE ##TMP_SCPC_QUERY_C 
				SET OCORRENCIAS = ISNULL(OCORRENCIAS,'') + ISNULL(@MSG_C,'')+' - ORIGEM: '+ISNULL(@ORIGEM_C,'')+' - TEMPO: '+ISNULL(@TEMPO_C,'')+CHAR(13) 
				WHERE ID=@ID_C

				FETCH NEXT FROM curOcorrencias INTO @ID_C,@MSG_C,@ORIGEM_C,@TEMPO_C
			END
			CLOSE curOcorrencias;  
			DEALLOCATE curOcorrencias;  
	
		--resumo
		IF OBJECT_ID('tempdb..##TMP_SCPC_QUERY_R') IS NOT NULL 
			DROP TABLE ##TMP_SCPC_QUERY_R

		select  
				C.value('count(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-122-DADOS/SPC-125-DEBITO)', 'int') AS TOTAL_DEBITOS,
				C.value('count(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-126-CONSULTA/SPC-126-ANTERIORES)', 'int') AS TOTAL_CONSULTAS,
				C.value('(RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-126-CONSULTA/SPC-126-ANTERIORES/SPC-126-OCORRENCIA)[1]', 'date') AS ULTIMA_CONSULTA,
				C.value('@ID', 'INT') AS ID,
				@documento as DOCUMENTO
		INTO ##TMP_SCPC_QUERY_R
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS') as T(C)
 
		--debitos
		IF OBJECT_ID('tempdb..##TMP_SCPC_QUERY_D') IS NOT NULL 
			DROP TABLE ##TMP_SCPC_QUERY_D

		select  
				C.value('SPC-125-TPDEBITO[1]', 'VARCHAR(4)') AS TIPO,
				C.value('SPC-125-CONTRATO[1]', 'VARCHAR(25)') AS CONTRATO,
				C.value('SPC-125-OCORRENCIA[1]', 'DATE') AS DATA,
				C.value('SPC-125-DISPONIVEL[1]', 'DATE') AS DISPONIVEL,
				cast(replace(C.value('SPC-125-VALOR[1]', 'VARCHAR(25)'),',','.') as numeric(14,2)) AS VALOR,
				C.value('SPC-125-SITUACAO[1]', 'VARCHAR(8)') AS SITUACAO,
				C.value('SPC-125-INFORMANTE[1]', 'VARCHAR(25)') AS INFORMANTE,
				C.value('SPC-125-CONSULENTE[1]', 'VARCHAR(8)') AS CONSULENTE,
				C.value('SPC-125-CIDADE[1]', 'VARCHAR(25)') AS CIDADE,
				C.value('SPC-125-UF[1]', 'VARCHAR(2)') AS UF,
				C.value('SPC-125-CONDICAO[1]', 'VARCHAR(8)') AS CONDICAO,
				@documento as DOCUMENTO,
				C.value('../../../../../../@ID', 'INT') AS ID
		INTO ##TMP_SCPC_QUERY_D
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-122-DADOS/SPC-125-DEBITO') as T(C)

		--ATUALIZA VALOR TOTAL DEBITOS
		UPDATE A SET A.VALOR_DEBITOS = B.VALOR 
			FROM ##TMP_SCPC_QUERY_C A JOIN (SELECT ID,SUM(VALOR) AS VALOR FROM ##TMP_SCPC_QUERY_D GROUP BY ID) B ON A.ID=B.ID

		--historico de consultas
		IF OBJECT_ID('tempdb..##TMP_SCPC_QUERY_Q') IS NOT NULL 
			DROP TABLE ##TMP_SCPC_QUERY_Q
		
		select  
					C.value('SPC-126-TPCREDITO[1]', 'VARCHAR(4)') AS TIPO,
					C.value('SPC-126-OCORRENCIA[1]', 'DATE') AS DATA,
					C.value('SPC-126-INFORMANTE[1]', 'VARCHAR(60)') AS INFORMANTE,
					@documento as DOCUMENTO,
					C.value('../../../../../../@ID', 'INT') AS ID
		INTO ##TMP_SCPC_QUERY_Q
		from  @xml.nodes('ENTIDADES_CREDITO_CONSULTAS/RETORNO_XML/SPCA-XML/RESPOSTA/REGISTRO-ACSP-SPC/SPC-126-CONSULTA/SPC-126-ANTERIORES') as T(C)

	END

	--RETORNOS
	EXEC ('SELECT * INTO ##TMP_ENT_QUERY_C FROM ##TMP_'+@tipo+'_QUERY_C') 
	EXEC ('SELECT * INTO ##TMP_ENT_QUERY_D FROM ##TMP_'+@tipo+'_QUERY_D') 
	EXEC ('SELECT * INTO ##TMP_ENT_QUERY_Q FROM ##TMP_'+@tipo+'_QUERY_Q') 
	EXEC ('SELECT * INTO ##TMP_ENT_QUERY_R FROM ##TMP_'+@tipo+'_QUERY_R')
	
	select 'OK' AS MENSAGEM


