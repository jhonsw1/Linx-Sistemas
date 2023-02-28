CREATE PROCEDURE  dbo.LX_PROCESSAMENTO_RETORNO_NFE_SEFAZ @MENSAGEM TEXT = NULL, @TIPO_MENSAGEM CHAR(1) = '0', @CHAVE_NFE_LINX VARCHAR(44) = NULL
	WITH ENCRYPTION 

/*
-- Modasp10260 - Wesley Batista          - #19# - (21/01/2020) - Efetuado a alteração para salvar a informação do Nota Premiada MS e permitir a impressão da informação no Danfe.
-- DM111305  - Wendel Crespigio          - #18# - (29/10/2018) - Tratamento para Status de erro quando recebido erro no processamento da NFE Tipo Emissao = 4
-- DM99460   - Wendel Crespigio          - #17# - (29/10/2018) - Tratamento para nota autorizada quando recebido no processamento status de  NFe com Tipo Emissao = 4, sem EPEC correspondente.
-- DM83125   - ANDRE.ARTUZO/DIEGO.MORENO - #16# - (06/07/2018) - MELHORIA PARA QUE SEJA POSSIVEL GUARDAR AS NOVAS REJEIÇÕES DA NT 2016.002 Vers. 1.60.
-- DM1372    - EDSON FILENTI             - #13# - (23/02/2016) - REPLICAÇÃO  da demanda ID 1294 Correção para trazer o CNPJ do Destinatário.
-->>Adequação para a versão 3.10
-- DM1466    - WENDEL CRESPIGIO          - #12# - 27/01/2016 - TRATAMENTO PARA EXIBIR A MENSAGEM CORRETA DO RETORNO DO MID.
-- TP8550980 - JORGE.DAMASCO             - #11# - (13/05/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO NA VERIFICAÇÃO DO @STATUS PARA REPROCESSAMENTO DE NOTAS EM EPEC.
-- SEM TP - Diego Moreno                 - #10# - (13/04/2015) - Correção para processamento fora do prazo.
-- TP8238924 - Diego Moreno              - #9# - (02/04/2015) - Melhorias para tratamento de NFEs em EPEC.
-- TP8226401 - JORGE.DAMASCO             - #8# - (01/04/2015) - Replicações de demandas referentes à BANCO ONLINE.
-- 23/05/2015  - DIEGO QUARESMA          - #7# - TP - 7852920 - Adicionado tratameto para contigencia em EPEC. 
-- #7# ALTERADO O TIPO DE DADO DA VARIAVEL @MENSAGEM DE VARCHAR(MAX) PARA TEXT, POIS NÃO SUPORTAVA MAIS DE 8000 CARACTERES NO MODELO DE CONTIGENCIA EPEC.
-- 30/10/2014  - DIEGO QUARESMA          - #6# - TP - 6936566 - Adicionado tratameto para atualização do campo UTC_DATA_AUTORIZACAO_NFE verificando a versão da XML de retorno.
-- 01/10/2014  - RODRIGO SOUZA           - #5# - Adicionado tratameto para atualização do campo UTC_DATA_AUTORIZACAO_NFE.
-- 23/09/2014  - GILVANO SANTOS          - #4# - NOTA TÉCNICA 2013.005 V1.03 
-- 26/09/2014  - GILVANO SANTOS          - TP6585615 - #5# - Inclusão da clausula 'IF' para diferenciar o retorno com UTC (Layout 3.10) e sem UTC (Layout 2.00 ou inferior) 

-->> VERSAO 2.00 IT/SEFAZ/LINX
-- 14/02/2014 - Diego Camargo - TP 5054269 - #3# - Passou a gravar os dados do CLIENTES_VAREJO em caso de LOJA_NOTA_FISCAL
-- 11/09/2013 - DANIEL GONCALVES - TP 4260968 - #2# - ALTERADO TAMANHO DO CAMPO SERIE DE 3 PARA 6.
-- 13/12/2012 - #3# Rafael	 - TRATAMENTO PARA OS STATUS 108/109 - REJEIÇÃO - SERVIÇO PARALISADO
-- 31/10/2012 - #2# Samuel / Padial Alterado em 31/10/2012 por Padial, devido a todas as mensagens que retornem sem a chave
--			 - CASO A CHAVE NÃO EXISTA NO RETORNO DO MID, POR EXEMPLO NO STATUS 9995 PEGA A CHAVE DA LINX PARA GRAVAR O LOG
-- 13/09/2012 - Rafael Pagani - Alteração referente a NT2012-03, add tratamento para os status 150,151
-- 28/08/2012 - Samuel Santos - Alterado conteudo da variavel @MSG_XML_DADOS somente com a tag nfeProc
-- 16/08/2012 - Samuel Santos - Alteração Digitos Nota / Serie
-- 16/08/2012 - Samuel Santos - #1# - TP 2213318 - Tratamento para guardar dados referente a endereço na tabela DADOS_CADASTRO_XML_NFE. 
--							   Dados serão utilizados para imprimir a danfe, caso tenha alteração no endereço do cliente, informação não sair divergente do XML
-- 31/07/2012 - PADIAL/SAMUEL - TRATAMENTO PARA QUE SE OCORRER O STATUS 9995 DO MID, A NOTA POSSA SER REENVIADA
-- 09/03/2012 – PADIAL/DANIEL - TRATAMENTO PARA MUDAR O STATUS CASO A NOTA RETORNO COM: 217 Rejeição: NF-e não consta na base de dados da SEFAZ 
                            -- ESTE STATUS É RETORNADO DA CONSULTA DA SEFAZ OU QDO A NOTA VAI ENTRAR EM DPEC.   
11/09/2010 - INCLUSAO DO PARAMETRO COM O TIPO DE MENSAGEM DO XML
0 - MENSAGEM PADRAO IT (LAYOUT DE DISTRIBUICAO DA SEFAZ)
1 - MENSAGEM PADRAO SOMENTE O PROTOCOLO SEFAZ
2 - MENSAGEM PADRAO SEFAZ COM LAYOUT LINX NO PADRAO NFPROT (LAYOUT DE DISTRIBUICAO COM CABECALHO DA LINX)
3 - MENSAGEM PADRAO SEFAZ COM LAYOUT LINX NO PADRAO protNFe (SOMENTE PROTOCOLO COM CABECALHO DA LINX)

19/10/2011 - PADIAL	- INCLUSÃO DA INTEGRAÇÃO DA ENTRADA NA AUTORIZACAO DA SEFAZ SOMENTE
03/10/2011 - PADIAL	- ALTERACAO DA FAIXA DE ERRO DE "201 AND 600" PARA "201 AND 900" (NT2011.004)
22/03/2011 - PADIAL - SE A NOTA JA ESTA AUTORIZADA TIRA A MENSAGEM DA FILA. COMO NUNCA RECEBEMOS A MSG DA IT DE AUTORIZACAO MAIS DE UMA VEZ,
					  NÃO FIZEMOS ESTE TRATAMENTO. O TRATAMENTO FOI FEITO PARA A SOLUÇÃO NOVA DA LINX.	

25/02/2011 - PADIAL - TRATAMENTO DAS MENSAGENS QUE NÃO SÃO PADRÃO DO RETORNO E DO STATUS 9995
17/02/2011 - PADIAL - TRATAMENTO DO TIPO EMISSO 1 OU 5 NO RETORNO DA SEFAZ COM OU SEM ERRO
16/02/2011 - PADIAL - TRATAMENTO PARA NAO MUDAR O STATUS CASO A NOTA RETORNO COM: 217 Rejeição: NF-e não consta na base de dados da SEFAZ 
15/02/2011 - PADIAL - SE A NOTA DO LINX JA FOI PROCESSADA E AUTORIZADA, IGNORA O SEU PROCESSAMENTO
14/02/2011 - PADIAL - TRATAMENTO DA NOTA NAO ENCONTRADA NO LINX(STATUS 98 LINX). PROBLEMA OCORRIDO NA SOLUCAO LINX COM TESTES DO PAULAO
14/02/2011 - PADIAL - ADEQUACAO DOS STATUS > 9000 PARA NAO MUDAR O STATUS DA NOTA DO LINX COM A SEFAZ

10/02/2011 - PADIAL - STATUS > 9000: ERROS REPORTADOS PELA SOLUÇÃO LINX 
27/01/2011 - PADIAL - TRATAMENTO PARA DPEC

26/01/2011 - PADIAL - INCLUIDO TIPO MENSAGEM 3 PARA TRATAMENTO SOMENTE DO PROTOCOLO NO LAYOUT LINX PARA A CONSULTA SIMPLES
26/01/2011 - PADIAL - INCLUIDO TIPO MENSAGEM 2 PARA TRATAMENTO SOMENTE DA nfProt NO LAYOUT LINX PARA A CONSULTA COM LAYOUT DE DISTRIBUIÇÃO

25/01/2011 - PADIAL - ALTERANDO A PROCEDURE PARA TAMBEM LER O XML PADRAO LINX SOMENTE PARA UMA NOTA RECEBIDA.
			 FOI IDENTIFICADO DOI ERROS QUE NÃO PERMITIRAM QUE O XML FOSSE LIDO NO PADRAO DA SEFAZ E CORRIGIDOS EM 26/01/2011
			 	
21/01/2011 - PADIAL - IMPLEMENTACAO DO RETORNO DA SOLUCAO LINX

17/01/2011 - PADIAL - INCLUSAO DO PARAMETRO DEFAULT NA FUNCAO FX_REPLACE_CARACTER_ESPECIAL_NFE 

22/11/2010 - INCLUINDO O NOVO TRATAMENTO DA VERSAO 2.00 PARA REFERENCIAR TAMBEM O CAMPO CHAVE_NFE COMO SUBSTRING(CHAVE_NFE,1,34) QUANDO SE
 			 TRATAR DA CHAVE COMPLETA
29/10/2010 - TRATAMENTO MAIS DE UM RETORNO DO DPEC 

25/10/2010 - TRATAMENTO DO NOVO RETORNO DE DPEC QUE É FEITO COM UM RETORNO NORMAL DA SEFAZ, MAS COM A DIFERENCA DO NUMERO DE AUTORIZACAO E DATA NO PROTOCOLO
		  - E TAMBEM DA CHAVE ALTERADA E DO TIPO EMISSAO IGUAL A 4(DPEC)

11/09/2010 - INCLUSAO DO PARAMETRO COM O TIPO DE MENSAGEM DO XML
 

*/

-->> VERSAO LINX SEFAZ
-- 22/09/2010 - TRATAMENTO DO TIPO DE MENSAGEM TANTO PARA A SOLUÇÃO SD QUANTO PARA A SOLUÇÃO LINX SEFAZ
-- 11/09/2010 - INCLUSAO DO PARAMETRO COM O XML E COM O TIPO DE MENSAGEM

-->> VERSAO IT
-- 04/08/2010 - GERANDO LOG AO INTEGRAR O FATURAMENTO 
--				E ATUALIZACAO DO TAMANHO DO CAMPO DATAHORA DO RECEBIMENTO CONTEMPLANDO OS MILESIMOS CONFORME PROBLEMA NA SEFAZ DE PERNAMBUCO
--				ESTE PROBLEMA FOI ACOMPANHADO COM O FABIO E O SERGIO QUESADA ONDE A SEFAZ DE PERNAMBUCO ENVIOU O RETORNO FORA DO PADRAO DO MANUAL
-- 01/06/2010 - ALTERAÇÃO DA REGRA PARA GERAÇÃO DO FINANCEIRO EXCLUSÃO DA VARIÁVEL @GERA_FINANCEIRO
-- 11/06/2010 - ATUALIZAÇÃO DA GERAÇÃO DO CONTABIL E FISCAL PARA O FATURAMENTO/ENTRADAS
-- 19/11/2009 - INCLUSÃO DA GERACAO DO FINANCEIRO AO RETORNAR A AUTORIZAÇÃO DA NFE DA SEFAZ
-- 29/10/2009 - INCLUSAO DA PROCEDURE PARA EXECUTAR O CANCELAMENTO DA NOTA DENEGADA. TESTES EFETUADOS EM 30/10/2009
-- 22/10/2009 - TRATAMENTO DO PROTOCOLO DE DENEGACAO. SERA INCLUIDO NO CAMPO PROTOCOLO DE CANCELAMENTO E DATA CANCELAMENTO
-- 21/10/2009 - TRATAMENTO NOVO PARA O DPEC NÃO TROCANDO MAIS O STATUS DA NOTA PARA PODER IMPRIMIR, E SIM, SOMENTE O TIPO EMISSAO DA NFE
-- 05/10/2009 - ALTERACAO DO CAMPO DATA DE REGISTRO DPEC. A PROPRIEDADE NÃO ERA CARACTER, E DAVA ERRO AO RECEBER O DADO TIPO DATA
-- 10/09/2009 - ALTERACAO DA CONSULTA DA CHAVE PARA VERIFICAR OS 34 OU 44 CARACTERES DA CHAVE NA CLAUSULA WHERE
-- 04/09/2009 - ALTERACAO DA CHAVE QUANDO O DOCUMENTO FOR ATUALIZADO POR DPEC
-- 30/08/2009 - INCLUSAO DOS CAMPOS DO DPEC PARA SEREM UTILIZADOS NO NOVO MODELO DE DANFE
-- 30/08/2009 - ALTERACAO DO TRATAMENTO DA DATA E HORA DOS CAMPOS DO XML DE RETORNO
-- 27/08/2009 - ALTERAÇÃO TAMANHO DO PARAMETRO MOTIVO PARA 500 CARACTERES, PQ RECEBEMOS VARIOS ERROS COM MAIS DE 255 CARACTERES
-- 11/08/2009 - INCLUSAO DA DATA DE AUTORIZACAO NO DOCUMENTO AUTORIZADO
-- 15/07/2009 - INCLUSÃO DO TRATAMENTO DO DPEC

AS
SET NOCOUNT OFF
SET ANSI_WARNINGS ON

DECLARE @MSG_XML AS XML, @MSG_XML_DADOS AS XML, @CHAVE_NFE AS VARCHAR(44), @DTH_RECEBIMENTO AS VARCHAR(26), @STATUS AS INT, @MOTIVO AS VARCHAR(500), --#4#
	@ID_MSG AS INT, @MENSAGEM_ERRO AS VARCHAR(1000), @CONTINGENCIA VARCHAR(10), @CHAVE_NFE_DPEC  AS VARCHAR(44), @DHREGDPEC AS VARCHAR(24),
	@NREGDPEC AS VARCHAR(15), 
	@RETORNO INT, @ID_PROCESSO INT, @ITEM_PROCESSO INT, @STATUS_PROCESSO TINYINT, @COD_LAYOUT_NFE AS SMALLINT, @ID_EDI_ARQUIVO AS INT,
	@TIPO_DOC CHAR(2), @CMD VARCHAR(2000), @TABELA_STATUS VARCHAR(30), @FILIAL VARCHAR(25), @NF_SAIDA VARCHAR(15), @SERIE_NF VARCHAR(6), @ID_CAIXA_PGTO INT, --#2#
    @GERA_FINANCEIRO BIT, @ERRMSG VARCHAR(8000), @XMLNAMESPACE AS BIT, @NUMERO_PROTOCOLO VARCHAR(15), @IDDPEC VARCHAR(25), 
    @TIPO_EMISSAO  VARCHAR(2), @DH_CONTINGENCIA VARCHAR(24), @JUSTIFICATIVA VARCHAR(256), @STATUS_LINX INT, @NOME_CLIFOR VARCHAR(25),
    @UTC_DATA_AUTORIZACAO TINYINT, --#5#
	@ERP_DATABASE AS BIT,@VERSAO_NFE VARCHAR(100),@MSG_XMLEPEC AS XML,
	@CHAVE_NFE_LINX_RAIZ VARCHAR(35) = SUBSTRING(@CHAVE_NFE_LINX,1,34) + '%', --#22#
    @MSG_OBS VARCHAR(200), @MSG_OBS_CODIGO VARCHAR(4), @MSG_OBS_UF_EMITENTE VARCHAR(2), @MSG_OBS_ORIGINAL VARCHAR(MAX) --#28#

    SELECT        @MSG_OBS                    = '', --#19# Retorno da Sefaz Nota Premiada MS
				  @MSG_OBS_CODIGO             = '', --#19# Código da Msg Nota Premiada MS
				  @MSG_OBS_UF_EMITENTE        = '', --#19# UF do emissor
				  @MSG_OBS_ORIGINAL           = ''  --#19# Obs existente na Nf (type TEXT não permite concatenação )







--BEGIN TRY

BEGIN 
	SELECT @ERP_DATABASE =  (SELECT top 1 CAST(CASE WHEN EXISTS(select * from SYSOBJECTS WHERE NAME LIKE 'MATERIAIS' AND TYPE = 'U') THEN 1 ELSE 0 END AS BIT))
	--SELECT @UTC_DATA_AUTORIZACAO = 0 --#9#
	SELECT @MSG_XML_DADOS = CONVERT(XML,@MENSAGEM) 
	SELECT @MSG_XML_DADOS = @MSG_XML_DADOS.query('declare namespace ns0="http://www.linx.com.br/nfe";//*:nfeProc')
	IF @ERP_DATABASE = 1 -- #9#
		begin
			SELECT @VERSAO_NFE = RTRIM(LTRIM(DBO.FX_PARAMETRO('VERSAO_LAYOUT_XML_NFE')))
		end	
	-- TRATAMENTO DE MENSAGEM FORA DO PADRAO NFEPROT E PROTNFE COM STATUS 
	IF @MENSAGEM NOT LIKE '%nfeProc%' AND @MENSAGEM NOT LIKE '%protNFe%' AND @MENSAGEM IS NOT NULL
		BEGIN
			--SELECT @STATUS_LINX = 97, @MENSAGEM_ERRO = 'Mensagem de retorno fora do padrão da SEFAZ(nfeProc / protNFe). Impossível processar o retorno da NF-e!' #12#
			
			SELECT @STATUS_LINX = 97, @MENSAGEM_ERRO = @MENSAGEM

			SELECT @MENSAGEM_ERRO = ''''+CHAR(13)+'CHAVE NFE: '+@CHAVE_NFE_LINX+CHAR(13)+'STATUS: '+CAST(@STATUS_LINX AS VARCHAR(5))+CHAR(13)+'MOTIVO: '+@MENSAGEM_ERRO+CHAR(13)+''''
		
			UPDATE EDI_ARQUIVO
				SET LX_STATUS = @STATUS_LINX,
					DATA_HORA_GERACAO = GETDATE()
			WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE_LINX,1,34) OR EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE_LINX)
					
			---------------------------------------------------------
			-- GRAVA O LOG E ATUALIZA NOTA COM RETORNO FORA DO PADRAO
			---------------------------------------------------------
			EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_RECEBIMENTO_PROTOCOLO_NFE_SEFAZ',@MENSAGEM_ERRO 
				SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
				FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
				INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
				ON PA.ID_PROCESSO = PS.ID_PROCESSO 
				WHERE PA.ITEM_PROCESSO = @RETORNO 
				AND PS.NOME_PROCESSO = 'LX_RECEBIMENTO_PROTOCOLO_NFE_SEFAZ'

				SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO  FROM EDI_ARQUIVO (NOLOCK)
					WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE_LINX,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE_LINX)

				---------------------------------------------------------
				-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
				---------------------------------------------------------
				INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
					VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)

				IF @STATUS_PROCESSO <> 1
					BEGIN
						SELECT @TABELA_STATUS = RTRIM(W_NOTAS_NFE.TABELA_STATUS)
							FROM W_NOTAS_NFE
							WHERE (SUBSTRING(CHAVE_NFE,1,34) = SUBSTRING(@CHAVE_NFE_LINX,1,34) OR CHAVE_NFE = @CHAVE_NFE_LINX)
						
						SET @CMD = 'UPDATE '+@TABELA_STATUS+' SET STATUS_NFE = 4, LOG_STATUS_NFE = 99 WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE_LINX,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE_LINX+''''
						EXEC (@CMD)						
					END 	
					-- #9# - INICIO
					--TRATAMENTO NFE EPEC. -- #9# - INICIO
					IF @TABELA_STATUS = 'LOJA_NOTA_FISCAL' and @erp_database = 0 		
					BEGIN
						DECLARE @CODIGO_FILIAL AS CHAR(8)
						SELECT @CODIGO_FILIAL =  CODIGO_FILIAL
						FROM LOJA_NOTA_FISCAL
						WHERE (SUBSTRING(CHAVE_NFE,1,34) = SUBSTRING(@CHAVE_NFE_LINX,1,34) OR CHAVE_NFE = @CHAVE_NFE_LINX)
						
						SELECT @VERSAO_NFE = RTRIM(LTRIM(VALOR_ATUAL)) FROM FN_GETPARAMETER(@CODIGO_FILIAL,NULL,'VERSAO_LAYOUT_XML_NFE')
					END
					
					-- #9# - FIM
				RETURN

		END 
	
	-- TRANSFORMA MSG LINX NO PADRAO DA SEFAZ/IT 	
	IF @TIPO_MENSAGEM = '3'
		BEGIN
			SELECT @MSG_XML = CONVERT(XML,@MENSAGEM) 
			SELECT @MSG_XML = @MSG_XML.query('declare namespace ns0="http://www.linx.com.br/nfe";//*:protNFe')  -- correto a ser tratado pela Linx
			SELECT @MENSAGEM = CONVERT(varchar(max),@MSG_XML) 
			SELECT @TIPO_MENSAGEM = '1'
		END
		
	IF @TIPO_MENSAGEM = '2'
		BEGIN
			SELECT @MSG_XML = CONVERT(XML,@MENSAGEM) 
			SELECT @MSG_XMLEPEC = @MSG_XML.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";//*:retDPEC')  -- correto a ser tratado pela Linx #9#
			SELECT @MSG_XML = @MSG_XML.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";//*:nfeProc')  -- correto a ser tratado pela Linx
			--SELECT @MENSAGEM = CONVERT(varchar(max),@MSG_XML) 
		END		

	IF @TIPO_MENSAGEM = '0'
		DECLARE CUR_RETORNO_MENSAGEM CURSOR LOCAL FOR
			SELECT ID_MSG FROM FILA_MSG (NOLOCK) 
			WHERE STATUS_FILA = 0 
			ORDER BY ID_MSG

	IF @TIPO_MENSAGEM in ('1','2')
		DECLARE CUR_RETORNO_MENSAGEM CURSOR LOCAL FOR
			SELECT 0 AS ID_MSG
			

	OPEN CUR_RETORNO_MENSAGEM
	FETCH NEXT FROM CUR_RETORNO_MENSAGEM INTO @ID_MSG

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @CONTINGENCIA = NULL
		-- VERIFICA SE ESTA RECEBENDO UM RETORNO POR DPEC
		
		IF @TIPO_MENSAGEM = '0'		
		BEGIN 
			SELECT @CONTINGENCIA = 'DPEC' 
				FROM FILA_MSG  (NOLOCK) 
			WHERE ID_MSG = @ID_MSG AND MENSAGEM LIKE '%infDPECReg%' 
			
			SELECT @MSG_XML = CONVERT(XML,MENSAGEM) 
				FROM FILA_MSG  (NOLOCK) 
			WHERE ID_MSG = @ID_MSG
		END	

--#7#		
	IF @TIPO_MENSAGEM in ('1')   --,'2')	-- verificar a necessidade de nao transformar o xml no tipo 2 porque ja esta sendo feito acima.	
		BEGIN 
			SELECT @CONTINGENCIA = 'DPEC' 
			WHERE @MENSAGEM LIKE '%infDPECReg%' 
			
			SELECT @MSG_XML = CONVERT(XML,@MENSAGEM) 

		END
--#7#
		
		IF @CONTINGENCIA IS NULL
			BEGIN 

				SELECT @TIPO_EMISSAO = NULL, @DH_CONTINGENCIA = NULL, @JUSTIFICATIVA = NULL, @CHAVE_NFE = NULL

				-- EXTRAÇÃO DAS INFORMAÇÕES DO XML DE RETORNO COM O NOVO DPEC
				
				IF @TIPO_MENSAGEM in ('0','2')		
				BEGIN 				
					select @CHAVE_NFE			= cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:chNFe)') AS varchar(44))-- as chNFe
					select @DTH_RECEBIMENTO		= cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:dhRecbto)') AS varchar(26))-- as dhRecbto --#4#
					select @STATUS				= cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:cStat)') AS VARCHAR(5)) -- as cStat
					select @MOTIVO				= cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:xMotivo)') AS varchar(500)) -- as xMotivo
					select @NUMERO_PROTOCOLO	= cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:nProt)') AS varchar(15)) -- as xMotivo
					
					select @MSG_OBS             = cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:xMsg)') AS varchar(200)) -- as xMsg    --#19#
	                select @MSG_OBS_CODIGO      = cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:cMsg)') AS varchar(4))   -- as cMsg    --#19#
	                select @MSG_OBS_UF_EMITENTE = cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:emit/ns0:enderEmit/ns0:UF)') AS varchar(2)) --#19#
									   					 
					select @TIPO_EMISSAO		= cast (@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:ide/ns0:tpEmis)') AS varchar(2))  -- as tpEmis
					select @DH_CONTINGENCIA		= cast (@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:ide/ns0:dhCont)') AS varchar(25)) -- as dhCont
					select @JUSTIFICATIVA		= cast (@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:ide/ns0:xJust)') AS varchar(256)) -- as xJust
					
					--#9# - INICIO
					--Ajuste na data contingencia. #9# - INICIO
					SELECT @DH_CONTINGENCIA = REPLACE(@DH_CONTINGENCIA,'T',' ')
					IF LEN( @DH_CONTINGENCIA ) > 19 --#5#
						SELECT @DH_CONTINGENCIA = LTRIM(RTRIM(SUBSTRING(@DH_CONTINGENCIA,1, CHARINDEX('-',@DH_CONTINGENCIA, 10 ) - 1 ))) + '.000' --#4#
					SELECT @DH_CONTINGENCIA = REPLACE(@DH_CONTINGENCIA,'-','')

					if @DH_CONTINGENCIA is not null and isnull(@NUMERO_PROTOCOLO,'') = ''
					begin 
						select @NUMERO_PROTOCOLO = substring(cast(@MSG_XMLEPEC.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:retDPEC/ns0:infDPECReg/ns0:nRegDPEC)') AS varchar(47)),1,15) -- as Protocolo epec
					end 
					--#9# - FIM
					
				END	

				IF @TIPO_MENSAGEM = '1'		
				BEGIN 	
					SELECT @CHAVE_NFE			= cast(@msg_xml.query('data(/*:protNFe/*:infProt/*:chNFe)') AS varchar(44))-- as chNFe
					SELECT @DTH_RECEBIMENTO		= cast(@msg_xml.query('data(/*:protNFe/*:infProt/*:dhRecbto)') AS varchar(26))-- as dhRecbto --#4#
					SELECT @STATUS				= cast(@msg_xml.query('data(/*:protNFe/*:infProt/*:cStat)') AS VARCHAR(5)) -- as cStat
					SELECT @MOTIVO				= cast(@msg_xml.query('data(/*:protNFe/*:infProt/*:xMotivo)') AS varchar(255)) -- as xMotivo
					SELECT @NUMERO_PROTOCOLO	= cast(@msg_xml.query('data(/*:protNFe/*:infProt/*:nProt)') AS varchar(15)) -- as nProt
					
		    --        -- CASO A CHAVE NÃO EXISTA NO RETORNO DO MID, POR EXEMPLO NO STATUS 9995 PEGA A CHAVE DA LINX PARA GRAVAR O LOG
			--              IF @CHAVE_NFE IS NULL OR @CHAVE_NFE = ''
						--SELECT @CHAVE_NFE = @CHAVE_NFE_LINX
				END 

                -- Alterado em 31/10/2012 por Padial, devido a todas as mensagens que retornem sem a chave
                -- CASO A CHAVE NÃO EXISTA NO RETORNO DO MID, POR EXEMPLO NO STATUS 9995 PEGA A CHAVE DA LINX PARA GRAVAR O LOG 
				-- #2#
                IF @CHAVE_NFE IS NULL OR @CHAVE_NFE = ''
                             SELECT @CHAVE_NFE = @CHAVE_NFE_LINX                  
				

				--select * from parametros where parametro = 'VERSAO_LAYOUT_XML_NFE'
				--#6#
			    IF  @VERSAO_NFE='3.10'
					--#5#				
						SELECT @UTC_DATA_AUTORIZACAO=CONVERT(INT,LTRIM(RTRIM(SUBSTRING(@DTH_RECEBIMENTO,CHARINDEX('-',@DTH_RECEBIMENTO, 10 )+1,2 ))) )
					--#5#			
				--#6#

				SELECT @DTH_RECEBIMENTO = REPLACE(@DTH_RECEBIMENTO,'T',' ')
				
				IF LEN( @DTH_RECEBIMENTO ) > 19 --#5#
					SELECT @DTH_RECEBIMENTO = LTRIM(RTRIM(SUBSTRING(@DTH_RECEBIMENTO,1, CHARINDEX('-',@DTH_RECEBIMENTO, 10 ) - 1 ))) + '.000' --#4#
				
				SELECT @DTH_RECEBIMENTO = REPLACE(@DTH_RECEBIMENTO,'-','')
				
				SELECT @MOTIVO = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,@MOTIVO)
	
				SELECT @CMD = NULL, @MENSAGEM_ERRO = '', @STATUS_LINX = 0
				----------------------------------------------------------
				-- FAZ A VERIFICACAO SOBRE QUAL TABELA VAI SER ATUALIZADA
				----------------------------------------------------------
				SELECT @TIPO_DOC = NULL, @FILIAL = NULL, @NF_SAIDA = NULL, @SERIE_NF = NULL, @ID_CAIXA_PGTO = NULL, @NOME_CLIFOR = NULL

				SELECT @TIPO_DOC = 	W_NOTAS_NFE.TIPO_DOC, @TABELA_STATUS = 	RTRIM(W_NOTAS_NFE.TABELA_STATUS),
					@FILIAL = W_NOTAS_NFE.FILIAL, @NF_SAIDA = W_NOTAS_NFE.NF, @SERIE_NF = W_NOTAS_NFE.SERIE_NF,
					@STATUS_LINX = W_NOTAS_NFE.STATUS_NFE, @NOME_CLIFOR = W_NOTAS_NFE.NOME_CLIFOR
					FROM W_NOTAS_NFE
					WHERE (SUBSTRING(CHAVE_NFE,1,34) = SUBSTRING(@CHAVE_NFE,1,34) OR CHAVE_NFE = @CHAVE_NFE)

				-- SE A NOTA DO LINX JA FOI PROCESSADA E AUTORIZADA, IGNORA
				IF @STATUS_LINX = 5 or @STATUS_LINX = 6
					BEGIN
						IF @TIPO_MENSAGEM = '0'	
							BEGIN 
								UPDATE FILA_MSG 
									SET STATUS_FILA = 100
								WHERE ID_MSG = @ID_MSG						
							END	
					
						FETCH NEXT FROM CUR_RETORNO_MENSAGEM INTO @ID_MSG
						CONTINUE 
				    END

				IF @TIPO_DOC IS NULL  -- SE NÃO ENCONTROU A NOTA POR ALGUM MOTIVO
					BEGIN  
						IF @TIPO_MENSAGEM = '0'	
							BEGIN  
								UPDATE FILA_MSG 
									SET STATUS_FILA = 98
								WHERE ID_MSG = @ID_MSG
							
								FETCH NEXT FROM CUR_RETORNO_MENSAGEM INTO @ID_MSG
								CONTINUE 
							END	
						ELSE
							SELECT @STATUS_LINX = 98, @MENSAGEM_ERRO = 'Chave da NF-e não encontrada na base da LINX. '
					END

				
				-- TRATAMENTO PARA NAO LOGAR O STATUR 9998 TODA HORA
				IF @STATUS = 9998
					IF EXISTS(SELECT 1 FROM EDI_ARQUIVO (NOLOCK)
								WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) OR EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)				
								AND LX_STATUS IN (9998))
						BEGIN
							FETCH NEXT FROM CUR_RETORNO_MENSAGEM INTO @ID_MSG
							CONTINUE 			
						END	
						
				-------------------------------------------------------------------------------------------------------------------------------
				-- 201 A 407: ERROS DE REFEIÇÃO / 999: ERRO DE REJEIÇÃO NÃO CATALOGADO / 108 e 109 - REJEIÇÃO - SERVIÇO PARALISADO
				-- 407 A 554: ERROS REFERENTES AO NOVO MANUAL VIGENTE A PARTIR DE 01/04/2010
				-- ACIMA DE 554: ERROS VERSÃO 2.00 (COLOQUEI ATÉ 800 PARA TER UMA MARGEM DE SEGURANÇA, CASO INCLUAM ERROS EM NOTAS TÉCNICAS)
				-- STATUS > 9000: ERROS REPORTADOS PELA SOLUÇÃO LINX:
				--  9999: Rejeição Linx: Erro no schema XML do lote - nota enviada individualmente.
				--	9998: Middleware ainda sem retorno para esta nota.
				--  9995: Nota não localizada no MidNFe
				-------------------------------------------------------------------------------------------------------------------------------
				IF (@STATUS BETWEEN 201 AND 906) --#16#
						OR  @STATUS = 999 OR  @STATUS = 110 OR @STATUS > 9000 OR @STATUS_LINX = 98 OR @STATUS_LINX = 108 OR @STATUS_LINX = 109
					SELECT @MENSAGEM_ERRO = ''''+CHAR(13)+@MENSAGEM_ERRO+CHAR(13)+'CHAVE NFE: '+@CHAVE_NFE+CHAR(13)+'DATA RECEBIMENTO: '+@DTH_RECEBIMENTO+CHAR(13)+'STATUS: '+CAST(@STATUS AS VARCHAR(5))+CHAR(13)+'MOTIVO: '+@MOTIVO+CHAR(13)+''''
				ELSE 
					SELECT @MENSAGEM_ERRO = ''
					
				-----------------------------------------------------------------------------------------------------------------------------
				-- SE STATUS_LINX = 98, SIGNIFICA QUE O RETORNO DA NFE NA SOLUCAO LINX OU SEFAZ, NAO TEM REFERENCIA COM A NOTA CONSULTADA
				-----------------------------------------------------------------------------------------------------------------------------
				IF @STATUS_LINX = 98 AND @TIPO_MENSAGEM in ('1','2')
					SELECT @CHAVE_NFE = @CHAVE_NFE_LINX	

				-----------------------------------------
				-- GRAVA O LOG E ATUALIZA TODAS AS NOTAS
				-----------------------------------------
				IF (@STATUS NOT IN (124) AND (@TIPO_EMISSAO IN (1,5) OR @TIPO_EMISSAO IS NULL)) OR (@STATUS IN (100,150))			 -- PROCESSO NORMAL  
					EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_RECEBIMENTO_PROTOCOLO_NFE_SEFAZ',@MENSAGEM_ERRO 
						SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
						FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
						INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
						ON PA.ID_PROCESSO = PS.ID_PROCESSO 
						WHERE PA.ITEM_PROCESSO = @RETORNO 
						AND PS.NOME_PROCESSO = 'LX_RECEBIMENTO_PROTOCOLO_NFE_SEFAZ'
						
						
				IF (@STATUS = 124 OR @TIPO_EMISSAO = 4) AND (@STATUS NOT IN (100,150))			-- CONTINGENCIA  /Wendel : Ajuste retorno 150*/ -- #10# -- #11# #18#
					EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_RECEBIMENTO_REGISTRO_DPEC_NFE',@MENSAGEM_ERRO 
						SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
						FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
						INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
						ON PA.ID_PROCESSO = PS.ID_PROCESSO 
						WHERE PA.ITEM_PROCESSO = @RETORNO 
						AND PS.NOME_PROCESSO = 'LX_RECEBIMENTO_REGISTRO_DPEC_NFE'					
					

				SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO   
					FROM EDI_ARQUIVO (NOLOCK)
						WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)


				IF @STATUS_PROCESSO <> 1 AND @STATUS <> 217
					UPDATE EDI_ARQUIVO
						SET LX_STATUS = @STATUS,
							DATA_HORA_GERACAO = GETDATE()
					WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)


				---------------------------------------------------------
				-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
				---------------------------------------------------------
				
				INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
					VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)
				
				---------------------------------------------------------
				-- FAZ A ATUALIZACAO DO STATUS DO FATURAMENTO / ENTRADAS
				-- 217 - NOTA NAO CONSTA NA BASE DA SEFAZ
				---------------------------------------------------------
				--IF @STATUS_PROCESSO <> 1 AND @STATUS <> 9998 AND @STATUS NOT IN (110,301,302)
				IF @STATUS_PROCESSO <> 1 AND @STATUS NOT IN (110,301,302,9998) --,217 AND ISNULL(@NUMERO_PROTOCOLO,'') <> ''   -- STATUS 03 - 
					BEGIN
						SET @CMD = 'UPDATE '+@TABELA_STATUS+' SET STATUS_NFE = 4, LOG_STATUS_NFE = 99 WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
						EXEC (@CMD)
					END 
					
				-----------------------------------------------------------
				---- 108 - SERVIÇO PARALISADO MOMENTANEAMENTE (CURTO PRAZO)
				---- 109 - SERVIÇO PARALISADO SEM PREVISÃO 
				-----------------------------------------------------------
				IF @STATUS_PROCESSO <> 1 AND @STATUS IN (108,109)
					BEGIN
						SET @CMD = 'UPDATE '+@TABELA_STATUS+' SET STATUS_NFE = 4, LOG_STATUS_NFE = 99 WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
						EXEC (@CMD)
					END 
											
				-----------------------------------------------------------
				---- FAZ A ATUALIZACAO DO ERRO PARA O DPEC
				-----------------------------------------------------------
				
				--IF @STATUS_PROCESSO <> 1 AND @STATUS NOT IN (110,301,302) AND ISNULL(@NUMERO_PROTOCOLO,'') = '' AND @TIPO_EMISSAO = 4 -- STATUS 03 - 
				--	BEGIN
				--		SET @CMD = 'UPDATE '+@TABELA_STATUS+' SET STATUS_NFE = 4, LOG_STATUS_NFE = 99 WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
				--		EXEC (@CMD)
				--	END 

				----------------------------------------------------------------
				-- TRATAMENTO DO USO DENEGADO
				-- NO LOG APARECE COMO ERRO, MAS NO SISTEMA A NOTA FICA DENEGADA
				----------------------------------------------------------------
				IF @STATUS_PROCESSO <> 1 AND @STATUS IN (110,301,302)   
					BEGIN 	
						--- 'PROTOCOLO_CANCELAMENTO_NFE = '+''''+(select cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:nProt)') AS varchar(15)))+''''+', '+
						SET @CMD = 'UPDATE '+@TABELA_STATUS+ 
								' SET STATUS_NFE = 70, LOG_STATUS_NFE = 0, CHAVE_NFE = '+''''+@CHAVE_NFE+''''+', '+
								'PROTOCOLO_CANCELAMENTO_NFE = '+''''+@NUMERO_PROTOCOLO+''''+', '+
								'DATA_CANCELAMENTO = '+''''+@DTH_Recebimento+'''' +
							' WHERE (SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''+')'
						EXEC (@CMD)

						UPDATE EDI_ARQUIVO
							SET EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE,
								ARQUIVO_EDI = (select cast(@msg_xml.query('//*:protNFe') AS varchar(2000))),
								LX_STATUS = @STATUS
						WHERE ID_EDI_ARQUIVO = @ID_EDI_ARQUIVO

						-- EXECUTA O CANCELAMENTO DENTRO DO LINX	
						EXEC LX_NFE_DENEGADA  @CHAVE_NFE, @MENSAGEM_ERRO

					END 

				IF (@STATUS_PROCESSO = 1 AND @STATUS IN (100,150)) /*Thiago: Ajuste de retorno 150*/ -- #10#
					BEGIN 
						------------------------------
						-- AUTORIZADO O USO DA NF-E
						------------------------------
						--- 'PROTOCOLO_AUTORIZACAO_NFE = '+''''+(select cast(@msg_xml.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:protNFe/ns0:infProt/ns0:nProt)') AS varchar(15)))+''''+', '+

			
                        -- #28# Valores para Nf Premiada MS
                        If @TABELA_STATUS = 'LOJA_NOTA_FISCAL' AND @MSG_OBS_CODIGO = '200' AND @MSG_OBS_UF_EMITENTE = 'MS' -- #28#
						
						BEGIN -- #28#
						      SELECT @MSG_OBS_ORIGINAL = OBS FROM DBO.LOJA_NOTA_FISCAL WHERE CHAVE_NFE like  @CHAVE_NFE_LINX_RAIZ -- #28#
						      SET @MSG_OBS_ORIGINAL = @MSG_OBS_ORIGINAL + ' ' + @MSG_OBS -- #28#
	
                        END -- #28#                                                


						SET @CMD = 'UPDATE '+@TABELA_STATUS+  
									' SET STATUS_NFE = 5, LOG_STATUS_NFE = 0, CHAVE_NFE = '+''''+@CHAVE_NFE+''''+', '+
									'PROTOCOLO_AUTORIZACAO_NFE = '+''''+@NUMERO_PROTOCOLO+''''+', '+
									'DATA_AUTORIZACAO_NFE = '+''''+@DTH_Recebimento+''''+
									CASE WHEN @TABELA_STATUS  = 'LOJA_NOTA_FISCAL' AND @MSG_OBS_CODIGO = '200' AND @MSG_OBS_UF_EMITENTE = 'MS' THEN ', OBS = '+ ''''+ @MSG_OBS_ORIGINAL + '''' else '' end + --#19#
	                                CASE WHEN @TABELA_STATUS  = 'LOJA_NOTA_FISCAL' AND @MSG_OBS_CODIGO = '200' AND @MSG_OBS_UF_EMITENTE = 'MS' THEN ', OBS_INTERESSE_FISCO_MS = '+ ''''+ @MSG_OBS + '''' else '' end + --#19#
									CASE WHEN @VERSAO_NFE = '3.10' and @TABELA_STATUS != 'LOJA_NOTA_FISCAL' then ', UTC_DATA_AUTORIZACAO_NFE='+''''+CONVERT(CHAR(1),@UTC_DATA_AUTORIZACAO)+'''' else '' end+ --#6# - #8#
								' WHERE (SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''+')'
						EXEC (@CMD)	
						--##
	
						UPDATE EDI_ARQUIVO
							SET EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE,
								ARQUIVO_EDI = @MOTIVO,     --(select cast(@msg_xml.query('//*:protNFe') AS varchar(2000))),
								LX_STATUS = @STATUS
						WHERE ID_EDI_ARQUIVO = @ID_EDI_ARQUIVO
						
						--#1#
						DECLARE @RG_IE AS varchar(19), @XML_CEP AS varchar(9), @XML_ENDERECO AS varchar(90), @XML_BAIRRO AS varchar(25), @XML_CIDADE_IBGE AS varchar(10), @XML_CIDADE AS varchar(35),
								@XML_UF AS varchar(2), @XML_NUMERO AS varchar(10), @XML_COMPLEMENTO  AS varchar(60), @XML_RAZAO_SOCIAL AS VARCHAR(90), @XML_ENTREGA_ENDERECO as VARCHAR(90), 
								@XML_ENTREGA_BAIRRO as VARCHAR(25), @XML_ENTREGA_CIDADE as VARCHAR(35), @XML_ENTREGA_UF as CHAR(2), @XML_ENTREGA_COMPLEMENTO as VARCHAR(60), @XML_ENTREGA_COD_MUNICIPIO_IBGE AS VARCHAR(10), @XML_ENTREGA_NUMERO as VARCHAR(10),	
								@CGC_DESTINATARIO AS VARCHAR(19)--#13#

						SELECT @RG_IE = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:IE)') AS varchar(19)) 
						SELECT @XML_CEP = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:CEP)') AS varchar(9)) 
						SELECT @XML_ENDERECO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:xLgr)') AS varchar(90)) 
						SELECT @XML_BAIRRO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:xBairro)') AS varchar(25)) 
						SELECT @XML_CIDADE_IBGE = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:cMun)') AS varchar(10)) 
						SELECT @XML_CIDADE = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:xMun)') AS varchar(35)) 
						SELECT @XML_UF = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:UF)') AS varchar(2)) 
						SELECT @XML_NUMERO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:nro)') AS varchar(10)) 
						SELECT @XML_COMPLEMENTO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:enderDest/ns0:xCpl)') AS varchar(60)) 
						SELECT @XML_RAZAO_SOCIAL = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:dest/ns0:xNome)') AS varchar(90)) 
						SELECT @XML_ENTREGA_ENDERECO  = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:xLgr)') as VARCHAR(90))
						SELECT @XML_ENTREGA_BAIRRO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:xBairro)') as VARCHAR(25))
						SELECT @XML_ENTREGA_CIDADE = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:xMun)') as VARCHAR(35))
						SELECT @XML_ENTREGA_UF = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:UF)') as CHAR(2))
						SELECT @XML_ENTREGA_COMPLEMENTO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:xCpl)') as VARCHAR(60))
						SELECT @XML_ENTREGA_COD_MUNICIPIO_IBGE = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:cMun)') as VARCHAR(10))
						SELECT @XML_ENTREGA_NUMERO = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:nro)') as VARCHAR(10))
						SELECT @CGC_DESTINATARIO  = cast(@MSG_XML_DADOS.query('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";data(ns0:nfeProc/ns0:NFe/ns0:infNFe/ns0:entrega/ns0:CNPJ)') as VARCHAR(19)) --#13#

						SELECT @XML_ENTREGA_ENDERECO  =  case when isnull(@XML_ENTREGA_ENDERECO,'') = '' then null else @XML_ENTREGA_ENDERECO end 
						SELECT @XML_ENTREGA_BAIRRO = case when isnull(@XML_ENTREGA_BAIRRO,'') = '' then null else @XML_ENTREGA_BAIRRO end 
						SELECT @XML_ENTREGA_CIDADE = case when isnull(@XML_ENTREGA_CIDADE,'') = '' then null else @XML_ENTREGA_CIDADE end 
						SELECT @XML_ENTREGA_UF = case when isnull(@XML_ENTREGA_UF,'') = '' then null else @XML_ENTREGA_UF end 
						SELECT @XML_ENTREGA_COMPLEMENTO = case when isnull(@XML_ENTREGA_COMPLEMENTO,'') = '' then null else @XML_ENTREGA_COMPLEMENTO end 
						SELECT @XML_ENTREGA_COD_MUNICIPIO_IBGE = case when isnull(@XML_ENTREGA_COD_MUNICIPIO_IBGE,'') = '' then null else @XML_ENTREGA_COD_MUNICIPIO_IBGE end 
						SELECT @XML_ENTREGA_NUMERO = case when isnull(@XML_ENTREGA_NUMERO,'') = '' then null else @XML_ENTREGA_NUMERO end 
						--#1#
						
						IF @TABELA_STATUS = 'LOJA_NOTA_FISCAL' --#2#
							BEGIN 
							IF NOT EXISTS (	SELECT 1 FROM DADOS_CADASTRO_XML_NFE
											WHERE NF_SAIDA = @NF_SAIDA AND FILIAL = @FILIAL AND SERIE_NF = @SERIE_NF)
											INSERT INTO DADOS_CADASTRO_XML_NFE ( CHAVE_NFE, NF_SAIDA, FILIAL, SERIE_NF, NF_ENTRADA, NOME_CLIFOR, SERIE_NF_ENTRADA, 
														RAZAO_SOCIAL, CEP, ENDERECO, BAIRRO, CIDADE, UF, NUMERO, COMPLEMENTO, RG_IE, COD_MUNICIPIO_IBGE,
														ENTREGA_ENDERECO, ENTREGA_BAIRRO, ENTREGA_CIDADE, ENTREGA_COD_MUNICIPIO_IBGE, ENTREGA_UF, ENTREGA_COMPLEMENTO, ENTREGA_NUMERO, CGC_DESTINATARIO)
											VALUES(	@CHAVE_NFE, @NF_SAIDA, @FILIAL, @SERIE_NF, NULL, NULL, NULL, 
													@XML_RAZAO_SOCIAL, @XML_CEP, @XML_ENDERECO, @XML_BAIRRO, @XML_CIDADE, @XML_UF, @XML_NUMERO, @XML_COMPLEMENTO, @RG_IE, @XML_CIDADE_IBGE,
													@XML_ENTREGA_ENDERECO, @XML_ENTREGA_BAIRRO, @XML_ENTREGA_CIDADE, @XML_ENTREGA_COD_MUNICIPIO_IBGE, @XML_ENTREGA_UF, @XML_ENTREGA_COMPLEMENTO,@XML_ENTREGA_NUMERO, @CGC_DESTINATARIO) --#13#
								
									SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO  FROM EDI_ARQUIVO (NOLOCK)
									WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)

									---------------------------------------------------------
									-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
									---------------------------------------------------------
									INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
									VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)
									
							END --#2#
							
										
								

						IF @TABELA_STATUS = 'FATURAMENTO'
							BEGIN 
								
								--#1#
								IF NOT EXISTS (SELECT 1 FROM DADOS_CADASTRO_XML_NFE
											   WHERE NF_SAIDA = @NF_SAIDA AND FILIAL = @FILIAL AND SERIE_NF = @SERIE_NF)
									INSERT INTO DADOS_CADASTRO_XML_NFE ( CHAVE_NFE, NF_SAIDA, FILIAL, SERIE_NF, NF_ENTRADA, NOME_CLIFOR, SERIE_NF_ENTRADA, 
												RAZAO_SOCIAL, CEP, ENDERECO, BAIRRO, CIDADE, UF, NUMERO, COMPLEMENTO, RG_IE, COD_MUNICIPIO_IBGE,
												ENTREGA_ENDERECO, ENTREGA_BAIRRO, ENTREGA_CIDADE, ENTREGA_COD_MUNICIPIO_IBGE, ENTREGA_UF, ENTREGA_COMPLEMENTO, ENTREGA_NUMERO)
									VALUES(@CHAVE_NFE, @NF_SAIDA, @FILIAL, @SERIE_NF, NULL, NULL, NULL, 
										@XML_RAZAO_SOCIAL, @XML_CEP, @XML_ENDERECO, @XML_BAIRRO, @XML_CIDADE, @XML_UF, @XML_NUMERO, @XML_COMPLEMENTO, @RG_IE, @XML_CIDADE_IBGE,
										@XML_ENTREGA_ENDERECO, @XML_ENTREGA_BAIRRO, @XML_ENTREGA_CIDADE, @XML_ENTREGA_COD_MUNICIPIO_IBGE, @XML_ENTREGA_UF, @XML_ENTREGA_COMPLEMENTO,@XML_ENTREGA_NUMERO )
								--#1#


								SELECT @GERA_FINANCEIRO = 0		
								SELECT @ID_CAIXA_PGTO = F.ID_CAIXA_PGTO, @GERA_FINANCEIRO = CTB_LX_TIPO_OPERACAO.GERA_FINANCEIRO
								FROM FATURAMENTO F (NOLOCK)
								JOIN NATUREZAS_SAIDAS NS (NOLOCK)  
								ON F.NATUREZA_SAIDA = NS.NATUREZA_SAIDA
								JOIN CTB_LX_TIPO_OPERACAO (NOLOCK)
								ON NS.CTB_TIPO_OPERACAO = CTB_LX_TIPO_OPERACAO.CTB_TIPO_OPERACAO  
								WHERE NF_SAIDA = @NF_SAIDA AND FILIAL = @FILIAL AND SERIE_NF = @SERIE_NF

								-- INCLUSÃO DA GERACAO DO FINANCEIRO PARA A NF-e

								IF  (DBO.FX_PARAMETRO_EMPRESA('CONTABILIDADE_ATIVA',0)='.T.')
									AND @ID_CAIXA_PGTO IS NULL  
									BEGIN
										--EXEC LX_CTB_INTEGRAR_FATURAMENTO @FILIAL,@NF_SAIDA,@SERIE_NF
										-----------------------------------------
										-- GRAVA O LOG AO INTEGRAR O FATURAMENTO
										-----------------------------------------
										SELECT @CMD = ''''+RTRIM(@FILIAL)+''','+''''+RTRIM(@NF_SAIDA)+''','+''''+RTRIM(@SERIE_NF)+''''
									
										EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_CTB_INTEGRAR_FATURAMENTO ',@CMD	 
											SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
											FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
											INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
											ON PA.ID_PROCESSO = PS.ID_PROCESSO 
											WHERE PA.ITEM_PROCESSO = @RETORNO 
											AND PS.NOME_PROCESSO = 'LX_CTB_INTEGRAR_FATURAMENTO'

										SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO  FROM EDI_ARQUIVO (NOLOCK)
											WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)

										---------------------------------------------------------
										-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
										---------------------------------------------------------
										INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
											VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)
									
									END 
									
							END -- TABELA STATUS
							
						IF @TABELA_STATUS = 'ENTRADAS'
							BEGIN 

								--#1#
								IF NOT EXISTS (SELECT 1 FROM DADOS_CADASTRO_XML_NFE
										WHERE NF_SAIDA = @NF_SAIDA AND NOME_CLIFOR = @NOME_CLIFOR AND SERIE_NF_ENTRADA = @SERIE_NF)
									INSERT INTO DADOS_CADASTRO_XML_NFE ( CHAVE_NFE, NF_SAIDA, FILIAL, SERIE_NF, NF_ENTRADA, NOME_CLIFOR, SERIE_NF_ENTRADA, 
												RAZAO_SOCIAL, CEP, ENDERECO, BAIRRO, CIDADE, UF, NUMERO, COMPLEMENTO, RG_IE, COD_MUNICIPIO_IBGE,
												ENTREGA_ENDERECO, ENTREGA_BAIRRO, ENTREGA_CIDADE, ENTREGA_COD_MUNICIPIO_IBGE, ENTREGA_UF, ENTREGA_COMPLEMENTO, ENTREGA_NUMERO)
									VALUES(@CHAVE_NFE, NULL, NULL, NULL, @NF_SAIDA, @NOME_CLIFOR, @SERIE_NF, 
										@XML_RAZAO_SOCIAL, @XML_CEP, @XML_ENDERECO, @XML_BAIRRO, @XML_CIDADE, @XML_UF, @XML_NUMERO, @XML_COMPLEMENTO, @RG_IE, @XML_CIDADE_IBGE,
										@XML_ENTREGA_ENDERECO, @XML_ENTREGA_BAIRRO, @XML_ENTREGA_CIDADE, @XML_ENTREGA_COD_MUNICIPIO_IBGE, @XML_ENTREGA_UF, @XML_ENTREGA_COMPLEMENTO, @XML_ENTREGA_NUMERO )
								--#1#

							
								-- INCLUSÃO DA GERACAO DO FINANCEIRO PARA A NF-e
								IF  (DBO.FX_PARAMETRO_EMPRESA('CONTABILIDADE_ATIVA',0)='.T.')

									BEGIN
										-----------------------------------------
										-- GRAVA O LOG AO INTEGRAR A ENTRADA
										-----------------------------------------
										SELECT @CMD = ''''+RTRIM(@NOME_CLIFOR)+''','+''''+RTRIM(@NF_SAIDA)+''','+''''+RTRIM(@SERIE_NF)+''''
									
										EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_CTB_INTEGRAR_ENTRADA  ',@CMD	 
											SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
											FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
											INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
											ON PA.ID_PROCESSO = PS.ID_PROCESSO 
											WHERE PA.ITEM_PROCESSO = @RETORNO 
											AND PS.NOME_PROCESSO = 'LX_CTB_INTEGRAR_ENTRADA'

										SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO  FROM EDI_ARQUIVO (NOLOCK)
											WHERE (SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE)

										---------------------------------------------------------
										-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
										---------------------------------------------------------
										INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
											VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)
									
									END 

							END -- TABELA STATUS

					END -- AUTORIZADO
					

				IF (@STATUS_PROCESSO = 1 AND @STATUS = 124)
					BEGIN 
						------------------------------
						-- DPEC RECEBIDO PELO SISTEMA DE CONTINGÊNCIA ELETRÔNICA
						------------------------------
						SET @CMD = 'UPDATE '+@TABELA_STATUS+  
								   ' SET CHAVE_NFE = '+''''+@CHAVE_NFE+''''+', TIPO_EMISSAO_NFE = 4, '+
								   'JUSTIFICATIVA_CONTINGENCIA = '+''''+@JUSTIFICATIVA+''''+', '+ 
								   'DATA_CONTINGENCIA = '+''''+@DH_CONTINGENCIA+''''+', '+ 
								   'REGISTRO_DPEC = '+''''+@NUMERO_PROTOCOLO+''''+', '+ 
								   'DATA_REGISTRO_DPEC = '+''''+@DTH_RECEBIMENTO+''''+
							       ' WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
						EXEC (@CMD)		
						
						UPDATE EDI_ARQUIVO
							SET EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE,
								LX_STATUS = @STATUS
						WHERE ID_EDI_ARQUIVO = @ID_EDI_ARQUIVO 						
						
					END 
					

		END  -- SE NÃO HOUVER CONTINGENCIA


		IF @CONTINGENCIA = 'DPEC' AND @TIPO_MENSAGEM = '0'
			BEGIN 
				DECLARE @IDOC INT

				--SELECT @CHAVE_NFE_DPEC = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:chNFe)[1]','varchar(44)')
				--SELECT @DHREGDPEC = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:dhRegDPEC)[1]','varchar(24)')
				--SELECT @NREGDPEC = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:nRegDPEC)[1]','varchar(15)')
				--SELECT @CHAVE_NFE = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:envDPEC/ns0:infDPEC/ns0:resNFe/ns0:chNFe)[1]','varchar(44)')

				--SELECT @STATUS = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:cStat)[1]','integer')
				--SELECT @MOTIVO = @MSG_XML.value('declare namespace ns0="http://www.portalfiscal.inf.br/nfe";(/ns0:retDPEC/ns0:infDPECReg/ns0:xMotivo)[1]','varchar(500)')

				-- Novo tratamento DPEC
				EXEC sp_xml_preparedocument @idoc OUTPUT, @msg_xml ,'<root xmlns:ns="http://www.portalfiscal.inf.br/nfe"/>'

				SELECT DISTINCT Id, cStat,xMotivo, dhRegDPEC, nRegDPEC, isnull(chNFe,chNFeErro) as chNFe
						into ##CURDPEC
				FROM OPENXML (@idoc,'/ns:retDPEC/ns:infDPECReg//*')
					WITH (  [Id] varchar(25)				'//@Id',
							[cStat] int						'//ns:cStat',
							[xMotivo] varchar(255)			'//ns:xMotivo',
							[dhRegDPEC] varchar(25)			'//ns:dhRegDPEC',
							[nRegDPEC] varchar(15)			'//ns:nRegDPEC',
							[chNFeErro] varchar(44)			'../ns:chNFe',	

							[chNFe] varchar(44)	'./ns:chNFe'		
							)
				EXEC sp_xml_removedocument @idoc

				DECLARE CUR_RETORNO_DPEC CURSOR LOCAL FOR
					SELECT DISTINCT Id, cStat,xMotivo, dhRegDPEC, nRegDPEC, chNFe
							FROM ##CURDPEC

				OPEN CUR_RETORNO_DPEC
				FETCH NEXT FROM CUR_RETORNO_DPEC INTO @IDDPEC,@STATUS,@MOTIVO,@DHREGDPEC,@NREGDPEC,@CHAVE_NFE_DPEC

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- RECEBENDO UM RETORNO POR DPEC


					IF @STATUS = 124 AND @CHAVE_NFE_DPEC IS NULL
						BEGIN
							FETCH NEXT FROM CUR_RETORNO_DPEC INTO @IDDPEC,@STATUS,@MOTIVO,@DHREGDPEC,@NREGDPEC,@CHAVE_NFE
							CONTINUE 
						END

					SELECT @DHREGDPEC = REPLACE(@DHREGDPEC,'T',' ')
					SELECT @DHREGDPEC = REPLACE(@DHREGDPEC,'-','')

					SELECT @MOTIVO = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT,@MOTIVO)
					----------------------------------------------------------
					-- FAZ A VERIFICACAO SOBRE QUAL TABELA VAI SER ATUALIZADA
					----------------------------------------------------------
					SELECT @TIPO_DOC = NULL
					SELECT @CMD = NULL

					SELECT @TIPO_DOC = 	W_NOTAS_NFE.TIPO_DOC, @TABELA_STATUS = 	RTRIM(W_NOTAS_NFE.TABELA_STATUS)
						FROM W_NOTAS_NFE
						WHERE SUBSTRING(CHAVE_NFE,1,34) = CASE WHEN @CHAVE_NFE_DPEC IS NULL THEN SUBSTRING(@CHAVE_NFE,1,34) ELSE  SUBSTRING(@CHAVE_NFE_DPEC,1,34) END
							OR CHAVE_NFE = CASE WHEN @CHAVE_NFE_DPEC IS NULL THEN @CHAVE_NFE ELSE  @CHAVE_NFE_DPEC END

					IF @TIPO_DOC IS NULL  -- SE NÃO ENCONTROU A NOTA POR ALGUM MOTIVO
						BEGIN  
								UPDATE FILA_MSG 
									SET STATUS_FILA = 99
								WHERE ID_MSG = @ID_MSG

							FETCH NEXT FROM CUR_RETORNO_DPEC INTO @IDDPEC,@STATUS,@MOTIVO,@DHREGDPEC,@NREGDPEC,@CHAVE_NFE
							CONTINUE 
						END
					-------------------------------------------------------------

					IF @STATUS <> 124   -- DPEC COM ALGUM TIPO DE ERRO
						BEGIN 
							SELECT @MENSAGEM_ERRO = ''''+'CHAVE NFE: '+@Chave_NFe_DPEC+char(13)+'  - STATUS: '+CAST(@status AS VARCHAR(5))+char(13)+' - MOTIVO: '+@motivo+char(13)+''''
							SELECT @CHAVE_NFE = @CHAVE_NFE_DPEC
						END 
					ELSE 
						SELECT @MENSAGEM_ERRO = ''

					EXEC @RETORNO = LX_EXECUTE_PROCESS 'LX_RECEBIMENTO_REGISTRO_DPEC_NFE',@MENSAGEM_ERRO 
						SELECT @ID_PROCESSO = PA.ID_PROCESSO, @ITEM_PROCESSO =  PA.ITEM_PROCESSO, @STATUS_PROCESSO = PA.STATUS_PROCESSO 
						FROM PROCESSOS_SISTEMA_ATIVIDADES PA (NOLOCK) 
						INNER JOIN PROCESSOS_SISTEMA PS (NOLOCK) 
						ON PA.ID_PROCESSO = PS.ID_PROCESSO 
						WHERE PA.ITEM_PROCESSO = @RETORNO 
						AND PS.NOME_PROCESSO = 'LX_RECEBIMENTO_REGISTRO_DPEC_NFE'

					SELECT @ID_EDI_ARQUIVO = ID_EDI_ARQUIVO  FROM EDI_ARQUIVO (NOLOCK) 
						WHERE SUBSTRING(EDI_REFERENCIA_ARQUIVO,1,34) = SUBSTRING(@CHAVE_NFE,1,34) or  EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE

					---------------------------------------------------------
					-- FAZ A GRAVAÇÃO DA TABELA DE LIGACAO DO ARQUIVO COM O LOG
					---------------------------------------------------------
					INSERT INTO EDI_ARQUIVO_LOG (ID_EDI_ARQUIVO,ID_PROCESSO,ITEM_PROCESSO) 
						VALUES (@ID_EDI_ARQUIVO,@ID_PROCESSO,@ITEM_PROCESSO)
					
					---------------------------------------------------------
					-- FAZ A ATUALIZACAO DO STATUS DO FATURAMENTO / ENTRADAS
					---------------------------------------------------------
					IF @STATUS_PROCESSO <> 1   -- STATUS 03 - SOLICITACAO ENVIADA PARA A IT GROUP
						BEGIN

							SET @CMD = 'UPDATE '+@TABELA_STATUS+' SET STATUS_NFE = 4, LOG_STATUS_NFE = 99 WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
							EXEC (@CMD)

						END 

					IF @STATUS_PROCESSO = 1 and @STATUS = 124
						BEGIN 	

							SET @CMD = 'UPDATE '+@TABELA_STATUS+  
									' SET CHAVE_NFE = '+''''+@CHAVE_NFE+''''+', TIPO_EMISSAO_NFE = 4, '+
									'REGISTRO_DPEC = '+''''+@NREGDPEC+''''+', '+ 
									'DATA_REGISTRO_DPEC = '+''''+@DHREGDPEC+''''+
								' WHERE SUBSTRING(CHAVE_NFE,1,34) = '+''''+SUBSTRING(@CHAVE_NFE,1,34)+''''+' OR CHAVE_NFE = '+''''+@CHAVE_NFE+''''
							EXEC (@CMD)		

							
							UPDATE EDI_ARQUIVO
								SET EDI_REFERENCIA_ARQUIVO = @CHAVE_NFE,
									LX_STATUS = @STATUS
							WHERE ID_EDI_ARQUIVO = @ID_EDI_ARQUIVO 
						END 
				FETCH NEXT FROM CUR_RETORNO_DPEC INTO @IDDPEC,@STATUS,@MOTIVO,@DHREGDPEC,@NREGDPEC,@CHAVE_NFE
				
			END -- DPEC

			CLOSE CUR_RETORNO_DPEC
			DEALLOCATE CUR_RETORNO_DPEC
			DROP TABLE ##CURDPEC


		END  -- SE FOR CONTINGENCIA DPEC


		UPDATE FILA_MSG 
			SET STATUS_FILA = 1
		WHERE ID_MSG = @ID_MSG

		FETCH NEXT FROM CUR_RETORNO_MENSAGEM INTO @ID_MSG
		
	END
	
	CLOSE CUR_RETORNO_MENSAGEM
	DEALLOCATE CUR_RETORNO_MENSAGEM

END -- SE TIPO MENSAGEM IGUAL 0 OU 1