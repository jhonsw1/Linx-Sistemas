*** ------------------ >---------->> ATENCAO <<-------------< --------------- ***
*	Para o Bom funcionamento destas procedures e funções 
*	Deixar Ativo as Procedures do LinxPOS
*	Que são Chamadas algumas Vezes Durante os Processos (Ex: SQLSELECT,SQLEXECURE)
*** ------------------------------------------------------------------------- ***
*** --- Marcio - 28/08/2017  inclusão dos processo 28 e 29 para gerar nota de demosntracao e devouloção

* HrConexaoERP
* HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
* HrSqlExecRetaguarda
* HrNfGetStatus
* HrNfPermiteAlterar
* HrNfAtualizaStatusLoja
* HrNfCarregarDados
* HrNfEnviarDados
* HrNfEnviarCancelamento
* HrNfRetornaParaAutorizada		&& Utilizado quando houve critica no cancelamento e deseja-se voltar ao status de autorizada

*-- Processo Inverso
* HrNfGerarProcessoInverso
* HrNfGerarProcessoInversoVenda
* HrNfGerarProcessoInversoSaida
* HrNfGerarProcessoInversoConcerto - Desenvolver
* HrNfGerarProcessoInversoReforma
* InsertSqlNotaInversa
* LoadCursorCopyNota
* LoadCursorCopyNotaFotografia

*-- Loja_Saidas e Loja_Entradas
* GetHrSapLjProcessoEntradaSaida
* GetEntradaSaidaHrSapLjProcesso && Busca TIPO_ENTRADA_SAIDA com base no HR_SAP_LJ_PROCESSO
* GetLetraHrSapLjProcesso
* HrMergeLojaSaidas
* HrMergeLojaEntradas
* HrRelacionaNfSaida
* HrRelacionaNfEntrada
* HrRelacionaNfRemessaReserva 
* HrRelacionaNfRetornoReserva 
*--

*-- Processo Cancelamento
* HrCancelaTabelaOrigemBancoDados
* HrRetiraVinculoNotaVenda
* HrRetiraVinculoNotaTroca
* HrRetiraVinculoNotaCancelamento
* HrCancelaSaidaBancoDados
* HrCancelaEntradaBancoDados 
* HrCancelaConcerto

*** Status
#DEFINE _CRIADO_LINXPOS 				0
#DEFINE _CRIADO_VISUAL_LINX				1
#DEFINE _ENVIADO_SAP					2
#DEFINE _CRIADO_SAP						3
#DEFINE _CRITICA_CRIACAO_SAP			4
#DEFINE _CRIADO_ESTORNO_LINX			5
#DEFINE _ENVIADO_ESTORNO_SAP			6
#DEFINE _CRIADO_ESTORNO_SAP				7
#DEFINE _CRITICA_CRIACAO_ESTORNO_SAP	8
#DEFINE _ESTORNO_CRIADO_SOMENTE_LINX	9
#DEFINE _NFE_AGUARDANDO_VALIDACAO_SEFAZ	10


* Cod.	Processo
#DEFINE _HR_LJ_PROCESSO_VENDA_CUPOM						1
#DEFINE _HR_LJ_PROCESSO_RETORNO_CUPOM					2
#DEFINE _HR_LJ_PROCESSO_TROCA_CUPOM						3
#DEFINE _HR_LJ_PROCESSO_TROCAS_DIA						4
#DEFINE _HR_LJ_PROCESSO_CANCELAMENTOS_CUPOM				5
#DEFINE _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_ENTRADA		6
#DEFINE _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_SAIDA			7
#DEFINE _HR_LJ_PROCESSO_REMESSA_CONSERTO				8
#DEFINE _HR_LJ_PROCESSO_RETORNO_CLIENTE_CONSERTO		9  
#DEFINE _HR_LJ_PROCESSO_BONIFICACAO						10
#DEFINE _HR_LJ_PROCESSO_RETORNO_BONIFICACAO				11
#DEFINE _HR_LJ_PROCESSO_BRINDE							12
#DEFINE _HR_LJ_PROCESSO_RETORNO_BRINDE					13
#DEFINE _HR_LJ_PROCESSO_OUTRAS_ENTRADAS					14
#DEFINE _HR_LJ_PROCESSO_OUTRAS_SAIDAS					15
#DEFINE _HR_LJ_PROCESSO_REMESSA_VENDA_FORA_ESTAB		16
#DEFINE _HR_LJ_PROCESSO_RETORNO_VENDA_FORA_ESTAB		17
#DEFINE _HR_LJ_PROCESSO_COMPLEMENTO_VALOR_IMPOSTO		18
#DEFINE _HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO		19
#DEFINE _HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO	20
#DEFINE _HR_LJ_PROCESSO_SAIDA_ESTOQUE_AJUSTE			21
#DEFINE _HR_LJ_PROCESSO_ENTRADA_ESTOQUE_AJUSTE			22  
#DEFINE _HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA				23
#DEFINE _HR_LJ_PROCESSO_RETORNO_FOTOGRAFIA				24
#DEFINE _HR_LJ_PROCESSO_REMESSA_LOJA_REFORMA			25
#DEFINE _HR_LJ_PROCESSO_RETORNO_LOJA_REFORMA			26
#DEFINE _HR_LJ_PROCESSO_SAIDA_UNIFORME					27
#DEFINE _HR_LJ_PROCESSO_REMESSA_DEMOSNTRACAO			28
#DEFINE _HR_LJ_PROCESSO_RETORNO_DEMOSNTRACAO			29	
#DEFINE _HR_LJ_PROCESSO_NOTA_VENDA 						30
#DEFINE _HR_LJ_PROCESSO_NOTA_VENDA_OMNI 				31
#DEFINE _HR_LJ_PROCESSO_TROCA_CUPOM_OMNI				33
#DEFINE _HR_LJ_PROCESSO_TRANSFERENCIA_NORMAL			100
#DEFINE _HR_LJ_PROCESSO_TRANSFERENCIA_CONCERTO			101
#DEFINE _HR_LJ_PROCESSO_DEVOLUCAO_FABRICAS				103
*** 

Function HrConexaoERP
	LParameters bNaoMostrarMensagemErro as Boolean

	#Define SQL_NEVERPROMPT 3
	#Define SQL_PROMPTCOMPLETE 1

	Local nTentativaLogin as Number,nMaxTentativaLogin as Number,idConexao as Integer,nRetorno as Number

	idConexao = -1
	nTentativaLogin  = 0
	nMaxTentativaLogin = 2
	
	SQLSetprop(0,"DispLogin", SQL_NEVERPROMPT)
	SQLSetprop(0,"BatchMode", .T.)
	SQLSetprop(0,"Asynchronous", .F.)
	SQLSetprop(0,"QueryTimeout",15)
	
	Try
		Do While idConexao <= 0 And nTentativaLogin < nMaxTentativaLogin 
			idConexao = Sqlstringconnect("Driver={SQL Server}"+;
				";Server=" + main.p_HR_RETAGUARDA_SERVIDOR + ;
				";Database=" + main.p_HR_RETAGUARDA_BANCO_DADO + ;
				";UID=" + main.p_HR_RETAGUARDA_USUARIO + ;
				";PWD=" + main.p_HR_RETAGUARDA_SENHA +;
				";APP=" + Alltrim("Integracao NFs Lojas Proprias")+" ("+Alltrim(main.p_codigo_filial)+")" + ;
				";WSID="+ Sys(0))
			nTentativaLogin = nTentativaLogin + 1
		Enddo

		If idConexao <=0
			MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para envio da Saída.\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
				"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarMensagemErro)
		Endif
	Catch
		MsgBoxLocalMsg("Ocorreu um erro na tentativa de conexão com a Retaguarda.\nDetalhes: "+Message(),16,"Erro",bNaoMostrarMensagemErro)
	Finally
	Endtry

	Return idConexao
Endfunc

Function HrSqlDisconnect
	Lparameters idConexao As Integer,bConexaoLocal as Boolean
	If .Not. bConexaoLocal && Fecha apenas ao conexoes que foram abertas pelo metodo que chamou este
		Return .T.
	Endif
	Try
		=SQLDisconnect(idConexao)
	Catch
	Finally
	Endtry
Endfunc

Function HrSqlExecRetaguarda
	Lparameters idConexao As Integer,strCommando As String,strCursorDestino As String,nTentativas as Integer

	Local nTentativaComando As Integer,bComandoRetorno As Integer,nMaxTentativaComando as Integer
	If Pcount()==4
		nMaxTentativaComando = nTentativas
	Else
		nMaxTentativaComando = 3
	Endif

	nTentativaComando = 0
	bComandoRetorno = -1
	Do While nTentativaComando < nMaxTentativaComando And bComandoRetorno < 0
		If Pcount()>=3
			bComandoRetorno = SQLExec(idConexao,strCommando ,strCursorDestino )
		Else
			bComandoRetorno = SQLExec(idConexao,strCommando)
		Endif
		nTentativaComando = nTentativaComando + 1
	Enddo

	Return (bComandoRetorno > 0)

Endfunc

Function HrNfGetStatus as Boolean
	Parameters strChaveOrigem as String,idConexao as Integer,bNaoMostrarCriticas as Boolean
	
	Local bConexaoLocal as Integer,nStatus as Integer,nOldAlias as Integer
	nOldAlias = Select()
*!*		bConexaoLocal = (Pcount()<=1) .Or. idConexao<=0
	
	
****marcio retirado para pegar local

*!*		If bConexaoLocal
*!*			idConexao = HrConexaoERP(bNaoMostrarCriticas)
*!*			If idConexao <=0
*!*				Return .F.
*!*			Endif
*!*		Else
*!*			If idConexao <=0
*!*				MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para consulta da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
*!*					"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarCriticas)
*!*				Return -1
*!*			Endif
*!*		Endif

	TEXT TO strSelectStatusNF NOSHOW 
	Select CODIGO_LINX,A.STATUS,A.RETORNOU_LOJA,A.HR_LJ_NF_PROCESSO,NF_NUMERO,EMISSAO_NF,SERIE_NF,SOLICITA_CANCELAMENTO,CHAVE_NFE,PROTOCOLO_AUTORIZACAO_NFE,DATA_AUTORIZACAO_NFE
	from HR_SAP_LOJA_NOTA A(nolock)  
	WHERE CHAVE_ORIGEM =?strChaveOrigem
	ENDTEXT 
	

	If .Not. SQLselect(strSelectStatusNF,"CurStatusJaExiste")
		MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para envio de Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
			"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarCriticas)
		nStatus = -1
	Else
		If Reccount("CurStatusJaExiste")>0

			bExiste = .T.
			bSolicitaCancelamento = CurStatusJaExiste.SOLICITA_CANCELAMENTO
			nStatus = CurStatusJaExiste.STATUS
			bRetornouLoja = CurStatusJaExiste.RETORNOU_LOJA
			
			IF .Not. bRetornouLoja 
				Local bErroRetornoLoja as Boolean,strCommandCancelaSaida as String
				bErroRetornoLoja = .f.
				TEXT TO strComandoAtualizacao textmerge noshow
					UPDATE HR_SAP_LOJA_NOTA 
					SET STATUS=<<nStatus>>
						,NF_NUMERO=?CurStatusJaExiste.NF_NUMERO
						,EMISSAO_NF=?CurStatusJaExiste.EMISSAO_NF
						,SERIE_NF= ?CurStatusJaExiste.SERIE_NF
						,CODIGO_LINX = ISNULL(HR_SAP_LOJA_NOTA.CODIGO_LINX,?CurStatusJaExiste.CODIGO_LINX)
						,SOLICITA_CANCELAMENTO = ?CurStatusJaExiste.SOLICITA_CANCELAMENTO 
						,CHAVE_NFE = ?CurStatusJaExiste.CHAVE_NFE
						,PROTOCOLO_AUTORIZACAO_NFE = ?CurStatusJaExiste.PROTOCOLO_AUTORIZACAO_NFE 
						,DATA_AUTORIZACAO_NFE = ?CurStatusJaExiste.DATA_AUTORIZACAO_NFE 
					WHERE CHAVE_ORIGEM =?strChaveOrigem
				ENDTEXT
				
				IF .Not. SQLExecuteLocalMsg(strComandoAtualizacao ,"Erro ao informações da nota fiscal.",bNaoMostrarCriticas)
					bErroRetornoLoja = .t.
				Endif
				
				*** Marca o RETORNOU_LOJA
				IF .Not. bErroRetornoLoja 
					bRetornouLoja  = .T.
					If Inlist(nStatus,_CRIADO_ESTORNO_SAP,_ESTORNO_CRIADO_SOMENTE_LINX)
						If .Not. HrCancelaTabelaOrigemBancoDados(strChaveOrigem,CurStatusJaExiste.HR_LJ_NF_PROCESSO,bNaoMostrarCriticas)
							bRetornouLoja = .F.
						Endif
					Endif
				
					If Inlist(nStatus,_CRIADO_SAP)
						*
						Do Case
							CASE INLIST(CurStatusJaExiste.HR_LJ_NF_PROCESSO, _HR_LJ_PROCESSO_TROCA_CUPOM_OMNI)
								IF .Not. HrRelacionaShipFromTroca(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								ENDIF
							
							
							Case Inlist(CurStatusJaExiste.HR_LJ_NF_PROCESSO,;
									_HR_LJ_PROCESSO_BONIFICACAO,;
									_HR_LJ_PROCESSO_BRINDE,;
									_HR_LJ_PROCESSO_SAIDA_ESTOQUE_AJUSTE,;
									_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,;
									_HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA,;
									_HR_LJ_PROCESSO_SAIDA_UNIFORME,;
									_HR_LJ_PROCESSO_RETORNO_CLIENTE_CONSERTO,;
									_HR_LJ_PROCESSO_TRANSFERENCIA_NORMAL,;
									_HR_LJ_PROCESSO_DEVOLUCAO_FABRICAS)
								If .Not. HrRelacionaNfSaida(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								Endif
							Case Inlist(CurStatusJaExiste.HR_LJ_NF_PROCESSO,;
									_HR_LJ_PROCESSO_RETORNO_FOTOGRAFIA,;
									_HR_LJ_PROCESSO_ENTRADA_ESTOQUE_AJUSTE,;
									_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO,;
									_HR_LJ_PROCESSO_RETORNO_BRINDE,;
									_HR_LJ_PROCESSO_RETORNO_BONIFICACAO)
								If .Not. HrRelacionaNfEntrada(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								ENDIF
						
							Case CurStatusJaExiste.HR_LJ_NF_PROCESSO=29
								If .Not. HrRelacionaNfRetornoReserva(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								ENDIF
								
							Case CurStatusJaExiste.HR_LJ_NF_PROCESSO=28
								If .Not. HrRelacionaNfRemessaReserva(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								ENDIF
								
							CASE CurStatusJaExiste.HR_LJ_NF_PROCESSO = _HR_LJ_PROCESSO_NOTA_VENDA_OMNI 
								IF .Not. HrRelacionaPedidoShipFrom(strChaveOrigem,CurStatusJaExiste.SERIE_NF,CurStatusJaExiste.NF_NUMERO,CurStatusJaExiste.EMISSAO_NF,bNaoMostrarCriticas)
									bRetornouLoja = .F.
								ENDIF

																
							Otherwise

						Endcase
					Endif
					
					*-- Retira vinculo do ticket com a nota de venda quando ocorre a autorizacao da nota de retorno do cupom
					*!* Este processo esta sendo feito no momento da criacao da nota, por isso esta desabilitado aqui 
					*!* Para habilitar este processo no momento da autorizacao da ntoa de retorno, devera ser retirado 
					*!* este comando no metodo "HrNfGerarProcessoInversoVenda"
*!*						If Inlist(nStatus,_HR_LJ_PROCESSO_RETORNO_CUPOM)
*!*							strLetraProcessoVenda = GetLetraHrSapLjProcesso(_HR_LJ_PROCESSO_VENDA_CUPOM)
*!*							If Empty(Nvl(strLetraProcessoVenda,""))
*!*								bRetornouLoja = .F.
*!*							Else
*!*								If .Not. HrRetiraVinculoNotaVenda(strLetraProcessoVenda +Substr(strChaveOrigem,2))
*!*									bRetornouLoja = .F.
*!*								Endif
*!*							Endif
*!*						Endif
					*-- Fim - Retira vinculo do ticket com a nota de venda quando ocorre a autorizacao da nota de retorno do cupom

**--- marcio retirou
*!*						IF bRetornouLoja 
*!*							HrSqlExecRetaguarda(idConexao,"UPDATE HR_SAP_LOJA_NOTA SET RETORNOU_LOJA = 1 WHERE CHAVE_ORIGEM =?strChaveOrigem AND STATUS = ?CurStatusJaExiste.STATUS")
*!*						Endif
				Endif
			Endif
		Else
			nStatus = 0
			strDescStatus = "Não enviado para a Retaguarda"
		Endif
	Endif
	
**--- marcio retirou
**--- Disconecta da retaguarda
*!*		If bConexaoLocal
*!*			HrSqlDisconnect(idConexao,bConexaoLocal)
*!*		Endif
		
	Use In Select("CurStatusJaExiste")
	
	Select(nOldAlias)
	
	Return nStatus
Endfunc 


Function HrNfPermiteAlterar as Boolean
	Parameters strChaveOrigem as String,idConexao as Integer
	

	Local nStatus As Number
	If Pcount()<2
		nStatus = HrNfGetStatus(strChaveOrigem)
	Else
		nStatus = HrNfGetStatus(strChaveOrigem,idConexao)
	Endif
	
	Do Case
		Case nStatus < 0
			Return .F. && Erro ja e chamado no metodo getStatus
		Case nStatus == _CRIADO_LINXPOS && 0
			Return .T. && Não enviado para retaguarda
		Case Inlist(nStatus,_CRIADO_VISUAL_LINX,_ENVIADO_SAP, _NFE_AGUARDANDO_VALIDACAO_SEFAZ) && 1,2
			MsgBox("Não é permitida a alteração desta movimentação porque a solicitação de nota fiscal está em andamento",48,"Atenção")
			Return .F.
		Case Inlist(nStatus,_CRIADO_SAP) && 3
			MsgBox("Não é permitida a alteração desta movimentação porque a nota fiscal já foi emitida",48,"Atenção")
			Return .F.
		Case Inlist(nStatus,_CRITICA_CRIACAO_SAP) && 4
			MsgBox("Foi permitido a alteração deste movimento devido as criticas que ocorreram na solicitação de nota fiscal, verifique o que gerou as criticas para que não ocorra novamente",64,"Informação")
			Return .T.
		Case Inlist(nStatus,_CRIADO_ESTORNO_LINX,_ENVIADO_ESTORNO_SAP) && 5,6
			MsgBox("Não é permitida a alteração desta movimentação porque foi solicitado o cancelamento da mesma",48,"Atenção")
			Return .F.
		Case Inlist(nStatus,_CRIADO_ESTORNO_SAP,_ESTORNO_CRIADO_SOMENTE_LINX) && 7,9
			MsgBox("Não é permitida a alteração porque este movimento está cancelado",48,"Atenção")
			Return .F.
		Case Inlist(nStatus,_CRITICA_CRIACAO_ESTORNO_SAP) && 8
			MsgBox("Não é permitida a alteração desta movimentação porque foi solicitado o cancelamento\nOcorreram críticas na solicitação de cancelamento. Verifique!",48,"Atenção")
			Return .F.
		Otherwise
			MsgBox("Status não previsto, impossível alterar desta forma",16,"Erro")
			Return .F.
	Endcase

		
	Return .f.
Endfunc 

Function HrNfAtualizaStatusLoja
	LParameters idConexao as Integer,bNaoMostrarCriticas as Boolean,bNaoMostrarErroConexao as Boolean
	
	Local bConexaoLocal As Integer,nStatus As Integer,nOldAlias As Integer,bRetorno as Boolean
	nOldAlias = Select()
	bConexaoLocal = (Pcount()<1) .Or. idConexao<=0
	bRetorno = .t.

*!*		*!* Verifica conexao
*!*		If bConexaoLocal && Mensagem dentro da funcao
*!*			idConexao = HrConexaoERP(bNaoMostrarErroConexao)
*!*			If idConexao <=0
*!*				Return .f.
*!*			Endif
*!*		Else
*!*			If idConexao <=0
*!*				MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para envio da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
*!*					"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarErroConexao )
*!*				Return .F.
*!*			Endif
*!*		Endif
	*!* Fim - Verifica conexao

	strCodigoFilial = main.p_codigo_filial
	TEXT TO strSelectStatusNF NOSHOW 
	Select A.CHAVE_ORIGEM
	from HR_SAP_LOJA_NOTA A
	WHERE A.RETORNOU_LOJA = 0 AND A.CODIGO_FILIAL = ?strCodigoFilial
	ENDTEXT 
	
	ShowProgressLocalMsg("Atualizando Status de Notas Fiscais",bNaoMostrarCriticas)

	If .Not. SQLSelect(strSelectStatusNF,"CurNotasBuscarStatus")
		MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para consulta de status de notas fiscais\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
			"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarCriticas)
		bRetorno = .f.
	Else
		If Reccount("CurNotasBuscarStatus")>0
			Select CurNotasBuscarStatus
			Go Top
			Scan
				ShowProgressLocalMsg("Atualizando Status de Notas Fiscais",Reccount("CurNotasBuscarStatus"),bNaoMostrarCriticas)
				If HrNfGetStatus(CurNotasBuscarStatus.Chave_origem,idConexao,bNaoMostrarCriticas) < 1 && Erro de conexao ou nao encontrado retorna como erro
					bRetorno = .F.
				Endif
				Select CurNotasBuscarStatus
			Endscan
		Endif
	Endif
	
	*!* Disconecta da retaguarda
	If bConexaoLocal
		HrSqlDisconnect(idConexao,bConexaoLocal)
	Endif
	*!* Fecha cursor para liberar memoria
	
	Use In Select("CurNotasBuscarStatus")

	Select(nOldAlias)

	Return bRetorno
ENDFUNC

FUNCTION EnviaConfirmacaoEntrada as Boolean
	PARAMETERS strFilial, strRomaneioProduto

	TEXT TO strBuscaEntrada Noshow
		SELECT A.FILIAL,
			   A.FILIAL_ORIGEM,
			   A.NUMERO_NF_TRANSFERENCIA AS NF_NUMERO,
			   A.SERIE_NF_ENTRADA AS SERIE_NF,
			   A.EMISSAO AS DATA_RECEBIMENTO,
		   	   0 AS STATUS
		FROM LOJA_ENTRADAS A
		WHERE A.FILIAL = ?strFilial
			AND A.ROMANEIO_PRODUTO = ?strRomaneioProduto
		
	ENDTEXT

	IF !SqlSelectLocalMsg(strBuscaEntrada, [curHrLoja_Entradas], [Erro inesperado ao realizar pesquisa da entrada encerrada.\n A informação de entrada será enviada através de pacote.])
		RETURN .F.
	ENDIF

	SELECT curHrLoja_Entradas
	GO TOP

	IF EMPTY(curHrLoja_Entradas.SERIE_NF)
		MsgBoxLocalMsg("O campo de série da nota fiscal de entrada está vazio.\n Nota fiscal de entrada não será enviada ao SAP!",16,"Erro")
		RETURN .F.	
	ENDIF

*!*		idConexao = HrConexaoERP()


*!*		if(idConexao  <= 0) THEN
*!*			MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para envio da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
*!*							"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",.F.)
*!*			Return .F.
*!*		ENDIF

	 
	 
	 
	TEXT TO strInsereConfirmacaoRetaguarda NOSHOW
		IF NOT EXISTS( SELECT 1
					   FROM HR_SAP_CONFIRMACAO_ENTRADA
					   WHERE FILIAL = ?curHrLoja_Entradas.filial
					   	AND FILIAL_ORIGEM = ?curHrLoja_Entradas.Filial_origem
					   	AND NF_NUMERO = ?curHrLoja_Entradas.nf_numero
					   	AND SERIE_NF = ?curHrLoja_Entradas.serie_nf )
        BEGIN					   		
			 INSERT INTO HR_SAP_CONFIRMACAO_ENTRADA
			 (
			 	 FILIAL,
				 FILIAL_ORIGEM,
				 NF_NUMERO,
				 SERIE_NF,
				 DATA_RECEBIMENTO,
				 STATUS
			 )                        
			 VALUES(
			 	?curHrLoja_Entradas.filial, 
			 	?curHrLoja_Entradas.Filial_origem, 
			 	?curHrLoja_Entradas.nf_numero, 
			 	?curHrLoja_Entradas.serie_nf, 
			 	?curHrLoja_Entradas.data_recebimento,
			 	?curHrLoja_Entradas.status
			 )
		END	 	
	ENDTEXT
	


*!*		IF .Not. HrSqlExecRetaguarda(idConexao, strInsereConfirmacaoRetaguarda ,"",1) 
*!*			strMensagem = Message()
*!*			HrSqlDisconnect(idConexao,.T.) && Disconecta da retaguarda
*!*			MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informação do cliente.\nDetalhes:"+strMensagem,16,"Erro",.F.)
*!*			Return .f.
*!*		Endif

*!*		HrSqlDisconnect(idConexao,.T.)
ENDFUNC

Function HrNfEnviarDados As Boolean
	Parameters strChaveOrigem As String,idConexao As Integer,bCancelamento as Boolean,bNaoMostrarCriticas as Boolean

	*!* Busca dados 
	TEXT TO strSelectCabecalho NOSHOW
	Select CODIGO_LINX,CHAVE_ORIGEM,HR_SAP_LJ_PROCESSO.HR_LJ_NF_PROCESSO,STATUS,SOLICITA_CANCELAMENTO,
		NF_NUMERO,SERIE_NF,CODIGO_FILIAL,CLIFOR_DESTINO,INDICA_CLIENTE_OCASIONAL,DEPOSITO_DESTINO,
		CODIGO_CLIENTE,TRANSPORTADORA,INDICA_TRANSPORTE_PROPRIO,OBS_NF,TIPO_FRETE_LINX,QTDE_TOTAL,FINALIDADE_NF,
		NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,HR_SAP_LJ_PROCESSO.MOVIMENTA_ESTOQUE,NUMERO_VOLUME,PLACA_TRANSPORTADORA,PESO_CAIXA_TOTAL
		,CHAVE_ORIGEM_REFERENCIA,CENTRO_CUSTO,OBS_NF_AUTOMATICA
		,CUPOM_ECF
		,CUPOM_DATA
		,CUPOM_NUM
		,CUPOM_CHAVE
		,VALOR_FRETE
	from dbo.HR_SAP_LOJA_NOTA
	left join HR_SAP_LJ_PROCESSO on HR_SAP_LJ_PROCESSO.HR_LJ_NF_PROCESSO = HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO
	
	where CHAVE_ORIGEM = ?strChaveOrigem
	ENDTEXT 

	TEXT TO strSelectItem NOSHOW
	Select ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO
			,ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE
			,REF_PRODUTO,REF_COR_PRODUTO,REF_TAMANHO,INFO_CUPOM
	from dbo.HR_SAP_LOJA_NOTA_ITEM
	where CHAVE_ORIGEM = ?strChaveOrigem
	ENDTEXT 
	
	TEXT TO strSelectClienteOcasional NOSHOW
		SELECT 
			CNPJ
			,CPF
			,PF_PJ
			,NOME_CLIENTE 
			,ENDERECO
			,LOGRADOURO
			,COMPLEMENTO 
			,NUMERO
			,BAIRRO
			,CIDADE 
			,UF 
			,CEP
			,DDD_TELEFONE
			,TELEFONE
			,DDD_CELULAR
			,CELULAR
			,EMAIL_NFE
			,IE
		FROM dbo.W_HR_SAP_CLIENTES_VAREJO
		where W_HR_SAP_CLIENTES_VAREJO.codigo_cliente = ?CurHR_SAP_LOJA_NOTA.codigo_cliente
	ENDTEXT 
	
	TEXT TO strSeleClienteOCasionalOmni NOSHOW
		SELECT 
			CNPJ
			,CPF
			,PF_PJ
			,NOME_CLIENTE 
			,ENDERECO
			,LOGRADOURO
			,COMPLEMENTO 
			,NUMERO
			,BAIRRO
			,CIDADE 
			,UF 
			,CEP
			,DDD_TELEFONE
			,TELEFONE
			,DDD_CELULAR
			,CELULAR
			,EMAIL_NFE
			,IE
		FROM dbo.FX_HR_SAP_OMNI_CLIENTE_VAR_ENDERECOS(?CurHR_SAP_LOJA_NOTA.codigo_cliente, ?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM)
	ENDTEXT
	
	
	TEXT TO strSelectPagamento Noshow
		SELECT  CHAVE_ORIGEM,
				PARCELA,
				CODIGO_ADMINISTRADORA,
				TIPO_PGTO,
				VALOR,
				VENCIMENTO,
				NUMERO_TITULO,
				PARCELAS_CARTAO,
				NUMERO_APROVACAO_CARTAO
		 FROM HR_SAP_LOJA_NOTA_PAGAMENTo
		 WHERE CHAVE_ORIGEM  = ?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM
	ENDTEXT  
	
	Local bClienteOcasional as Boolean
	
	*-- Busca cabecalho
	If .Not. SqlSelectLocalMsg(strSelectCabecalho,"CurHR_SAP_LOJA_NOTA","Erro pesquisando informações do cabeçalho da nota ao enviar informações para a Matriz",bNaoMostrarCriticas)
		Return .F.
	Endif
	
	IF Reccount("CurHR_SAP_LOJA_NOTA")==0
		MsgBoxLocalMsg("Não foi possível enviar informações da solicitação de nota para a matriz porque não foi encontrado informações no banco de dados",16,"Erro",bNaoMostrarCriticas)
		Return .f.
	Endif
	
	IF Reccount("CurHR_SAP_LOJA_NOTA")>1
		MsgBoxLocalMsg("Não foi possível enviar informações da solicitação de nota para a matriz porque as informações estão inconsistentes. Avise o Suporte!"+;
				"\nEncontrado mais de uma solicitação com esta chave primária",16,"Erro",bNaoMostrarCriticas)
		Return .f.
	Endif
	*-- Fim - Busca cabecalho
	

	IF bCancelamento
		*-- Preenche dados para cancelamento
		IF nvl(CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX,-1) <0
			replace CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX WITH 9 && Outros
		Endif
		*-- Fim - Preenche dados para cancelamento
	Endif
	
	*-- Busca item
	If .Not. SqlSelectLocalMsg(strSelectItem,"CurHR_SAP_LOJA_NOTA_ITEM","Erro pesquisando informações dos itens da solitação de nota ao enviar informações para a Matriz",bNaoMostrarCriticas)
		Return .F.
	Endif
	
	IF .Not. bCancelamento
		IF Reccount("CurHR_SAP_LOJA_NOTA_ITEM")==0
			MsgBoxLocalMsg("Não foi possível enviar informações sobre a solicitação de notas a matriz porque não foi encontrado itens na solicitação",16,"Erro",bNaoMostrarCriticas)
			Return .f.
		Endif
	Endif
	*-- Fim - Busca item
	

	Select CurHR_SAP_LOJA_NOTA
	Go Top
	bClienteOcasional = .Not.Empty(Nvl(CurHR_SAP_LOJA_NOTA.codigo_cliente,""))
	If bClienteOcasional
		If .Not. SqlSelectLocalMsg(IIF(INLIST(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,_HR_LJ_PROCESSO_NOTA_VENDA_OMNI, _HR_LJ_PROCESSO_TROCA_CUPOM_OMNI ), strSeleClienteOCasionalOmni ,strSelectClienteOcasional),"CurHR_SAP_LOJA_NOTA_CLIENTE","Erro pesquisando informações do cliente da solitação de nota para enviar informações para a Matriz",bNaoMostrarCriticas)
			Return .F.
		Endif
		
		IF .Not. bCancelamento
			If Reccount("CurHR_SAP_LOJA_NOTA_CLIENTE")==0
				MsgBoxLocalMsg("Não foi possível enviar informações da solicitação de nota para a matriz porque não foi encontrado informações do cliente no banco de dados",16,"Erro",bNaoMostrarCriticas)
				Return .F.
			Endif
		Endif
	Endif
	*!* Fim - Busca dados
	
	If .Not. SqlSelectLocalMsg(strSelectPagamento ,"CurHR_SAP_LOJA_NOTA_PAGAMENTO","Erro pesquisando informaçõesdde pagamento da solitação de nota ao enviar informações para a Matriz",bNaoMostrarCriticas)
		Return .F.
	Endif
	
	
	*!* Valida dados
	Local strMensagemAviso As String
	strMensagemAviso = ""
	
	*!* Valida Referencia de Cupom
	IF .Not. bCancelamento 
		IF Inlist(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,3,4,5) 
			Local bAlertaChave as Boolean 
			bAlertaChave = .F.
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA.CUPOM_CHAVE,'')) 
				
				If Empty(Nvl(CurHR_SAP_LOJA_NOTA.CUPOM_NUM,''))
					strMensagemAviso = strMensagemAviso+"Para este processo existe a necessidade de informar o número do cupom fiscal de origem.\n"
					bAlertaChave = .T.
				ENDIF
				
				If Empty(Nvl(CurHR_SAP_LOJA_NOTA.CUPOM_ECF,''))
					strMensagemAviso = strMensagemAviso+"Para este processo existe a necessidade de informar o número da ECF de origem do cupom fiscal.\n"			
					bAlertaChave = .T.
				ENDIF
				
				If Empty(Nvl(CurHR_SAP_LOJA_NOTA.CUPOM_DATA,''))
					strMensagemAviso= strMensagemAviso+"Para este processo existe a necessidade de informar a data do cupom fiscal de origem.\n"
					bAlertaChave = .T.
				Endif		
				
				IF bAlertaChave And inlist(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,3,4) 
				strMensagemAviso = strMensagemAviso + " ->Caso a venda da refêrencia seja uma NFC-e/SAT informe a chave de referência.\n"
				ENDIF
				
			ENDIF	
		Endif
		*!* Fim - Valida Referencia de Cupom
		
		If bClienteOcasional && Valida Cliente Ocasional
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.NOME_CLIENTE,""))
				strMensagemAviso = strMensagemAviso + "Nome do cliente não informado\n"
			Endif

			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.CNPJ,"")) .And. Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.CPF,""))
				strMensagemAviso = strMensagemAviso + "Cpf ou CNPJ não informado, um dos dois campos deve ser preenchido\n"
			Endif

			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.ENDERECO ,""))
				strMensagemAviso = strMensagemAviso + "Endereço não informado\n"
			Endif
			
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.BAIRRO ,""))
				strMensagemAviso = strMensagemAviso + "Bairro não informado\n"
			Endif
			
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.CIDADE,""))
				strMensagemAviso = strMensagemAviso + "Cidade não informada\n"
			Endif

			If Empty(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.UF,""))
				strMensagemAviso = strMensagemAviso + "Unidade de Federação (UF) não informada\n"
			ENDIF
			
			TEXT TO strUFCliente Noshow
				SELECT 1 FROM LCF_LX_UF WHERE UF = RTRIM(?CurHR_SAP_LOJA_NOTA_CLIENTE.UF)
			ENDTEXT
			
			IF !SQLSELECT(strUFCliente, [curExisteUF]) or RECCOUNT("curExisteUF") = 0 THEN
				strMensagemAviso = strMensagemAviso + "Unidade de Federação (UF) inexistente \n"
			ENDIF

			If LEN(ALLTRIM(Nvl(CurHR_SAP_LOJA_NOTA_CLIENTE.CEP,""))) < 8
				strMensagemAviso = strMensagemAviso + "Informação Codigo de Endereçamento Postal (CEP) incorreta, o campo deve possuir 8 dígitos\n"
			Endif

			If .Not. Empty(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_TELEFONE)) .And. Len(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_TELEFONE))>3
				strMensagemAviso = strMensagemAviso + "Informação de DDD do Telefone incorreta, o DDD deve possuir no máximo 3 digitos, exemplo: 047\n"
			Endif

			If .Not. Empty(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_CELULAR)) .And. Len(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_CELULAR))>3
				strMensagemAviso = strMensagemAviso + "Informação de DDD do Celular incorreta, o DDD deve possuir no máximo 3 digitos, exemplo: 047\n"
			Endif

			If .Not. Empty(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.TELEFONE )) .And. Len(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.TELEFONE))>12
				strMensagemAviso = strMensagemAviso + "Informação do Telefone incorreta existem mais digitos que o permitido, exemplo de telefone correto: 33213529 (a informação do DDD deve ser informado no campo correspondente)\n"
			Endif

			If .Not. Empty(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.CELULAR)) .And. Len(Alltrim(CurHR_SAP_LOJA_NOTA_CLIENTE.CELULAR))>12
				strMensagemAviso = strMensagemAviso + "Informação do Celuar incorreta existem mais digitos que o permitido, exemplo de telefone correto: 33213529 (a informação do DDD deve ser informado no campo correspondente)\n"
			Endif

		Endif && Fim - Valida Cliente Ocasional	
		*!* Fim - Valida dados
	
		*!* Verifica Centro de Custo
		IF .Not. sqlSelectLocalMsg("select INFORMA_CENTRO_CUSTO from HR_SAP_LJ_PROCESSO where HR_LJ_NF_PROCESSO = ?CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO ",;
					"CurInformaCC","Erro ao pesquisar informções do tipo de nota",bNaoMostrarCriticas)
			return .f.
		Endif
		
		Select CurInformaCC
		Go Top
		Local bINFORMA_CENTRO_CUSTO As Boolean
		bINFORMA_CENTRO_CUSTO = CurInformaCC.INFORMA_CENTRO_CUSTO
		Use In Select("CurInformaCC")
		Select CurHR_SAP_LOJA_NOTA
		If bINFORMA_CENTRO_CUSTO
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA.CENTRO_CUSTO,""))
				strMensagemAviso = strMensagemAviso + "Informar Centro de Custo.\n"
			Endif
		Endif
		*!* Fim - Verifica Centro de Custo

		If Nvl(CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX,-1) = -1
			strMensagemAviso = strMensagemAviso + "Tipo de frete não foi informado.\n"
		Endif

		If Isnull(CurHR_SAP_LOJA_NOTA.INDICA_TRANSPORTE_PROPRIO)
			strMensagemAviso = strMensagemAviso + "Informar se transporte será ou não feito pelo Destinatário.\n"
		Endif

		If Empty(Nvl(CurHR_SAP_LOJA_NOTA.TRANSPORTADORA,"")) .And. ;
				.Not. Nvl(CurHR_SAP_LOJA_NOTA.INDICA_TRANSPORTE_PROPRIO,.T.) .And. ; && Diferente de transporte proprio
			Nvl(CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX,-1) <> 9 && Diferente de Sem Frete
			strMensagemAviso = strMensagemAviso + "Transportador não informado ou sem código SAP.\n"
		Endif

		If Nvl(CurHR_SAP_LOJA_NOTA.NUMERO_VOLUME,0)>300 Or Nvl(CurHR_SAP_LOJA_NOTA.NUMERO_VOLUME,0)<=0
			If Nvl(CurHR_SAP_LOJA_NOTA.NUMERO_VOLUME,0)=0
				strMensagemAviso = strMensagemAviso + "Número de Volumes não informado.\n"
			Else
				strMensagemAviso = strMensagemAviso + "Número de Volumes inválido.\n"
			Endif
		Endif


		If Nvl(CurHR_SAP_LOJA_NOTA.FINALIDADE_NF,0)<=0 Or Nvl(CurHR_SAP_LOJA_NOTA.FINALIDADE_NF,0)>3
			strMensagemAviso = strMensagemAviso + "Finalidade da Nota fiscal não foi informada.\n"
		Endif

		If Inlist(Substr(CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM,1,1),"B","P","Y","E","S") && Brinde e Bonificacao e Remessa p/ fotografia && Saida p/ uniforme | Outras entradas | Outras saidas && Thisform.p_edita_cliente
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA.codigo_cliente,"")) .And. Empty(Nvl(CurHR_SAP_LOJA_NOTA.clifor_destino,""))
				strMensagemAviso = strMensagemAviso + "Não foi informado o Cliente (aba destinatário).\n"
			Endif
		Endif

		If Inlist(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO, 17)
			If Empty(Nvl(CurHR_SAP_LOJA_NOTA.NFE_REFERENCIADA,""))
				strMensagemAviso = strMensagemAviso + "Nota fiscal referenciada deve ser informada.\n"
			Endif

			If Empty(Nvl(CurHR_SAP_LOJA_NOTA.SERIE_NF_REFERENCIADA,""))
				strMensagemAviso = strMensagemAviso + "Série da Nota fiscal referenciada deve ser informada.\n"
			Endif
		Endif


		*!* Validacoes para transferencias entre lojas
		If Inlist(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO, 100, 101)
			If Nvl(CurHR_SAP_LOJA_NOTA.PESO_CAIXA_TOTAL,0.00)<=0
				strMensagemAviso = strMensagemAviso + "Peso das caixas (volumes) não informado ou inválido.\n"
			Endif
		Endif

		If Reccount("CurHR_SAP_LOJA_NOTA_ITEM")==0
			strMensagemAviso = strMensagemAviso + "Nenhum Item informado (Página Itens).\n"
		Endif

	Endif

	If .Not. Empty(nvl(strMensagemAviso,""))
		MsgBoxLocalMsg("Existem críticas nas informações da solicitação de NF. Verifique os dados.\n"+strMensagemAviso ,48,"Verifique",bNaoMostrarCriticas)
		Return .F.
	Endif

*!*		*!* Verifica conexao
*!*		Local bConexaoLocal as Integer
*!*		bConexaoLocal = (Pcount()<2) .Or. idConexao<=0
*!*		If bConexaoLocal 
*!*			idConexao = HrConexaoERP()
*!*			If idConexao <=0
*!*				Return .f.
*!*			Endif
*!*		Else
*!*			If idConexao <=0
*!*				MsgBoxLocalMsg("Não foi possível estabelecer conexão com a Retaguarda para envio da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
*!*					"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção",bNaoMostrarCriticas)
*!*				Return .F.
*!*			Endif
*!*		Endif
*!*		*!* Fim - Verifica conexao
*!*			
*!*		*!* Envia para Retaguarda
	Local nStatus as Number
	nStatus = HrNfGetStatus(strChaveOrigem,idConexao)
	IF .Not. Inlist(nStatus,_CRIADO_LINXPOS,_CRITICA_CRIACAO_SAP) .And. .Not. bCancelamento
		MsgBoxLocalMsg("O Status atual da solicitação, não permite o envio dos dados. Verifique no monitor!",48,"Atenção",bNaoMostrarCriticas)
		Return .f.
	Endif
*!*		
*!*		IF .Not. HrSqlExecRetaguarda(idConexao, "begin tran" ,"",3) && Três tentativas
*!*			strMensagem = Message()
*!*			HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*			HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*			MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando de inicio da transação.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*			Return .f.
*!*		Endif
*!*		
*!*		IF nStatus == _CRITICA_CRIACAO_SAP && Update
*!*			*!* Deleta Filhas
*!*			TEXT TO strDeleteFilhas NOSHOW 
*!*			DELETE FROM HR_SAP_LOJA_NOTA_ITEM where CHAVE_ORIGEM = ?strChaveOrigem 
*!*			DELETE FROM HR_SAP_LOJA_NOTA_CLIENTE where CHAVE_ORIGEM = ?strChaveOrigem 
*!*			DELETE FROM HR_SAP_LOJA_NOTA_PAGAMENTO where CHAVE_ORIGEM = ?strChaveOrigem 
*!*			
*!*			ENDTEXT 
*!*			
*!*			IF .Not. HrSqlExecRetaguarda(idConexao, strDeleteFilhas ,"",3) 
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para limpar informações antigas.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .f.
*!*			Endif
*!*			*!* Fim - Filhas
*!*			

*!*	*		If SqlSelect("select MOVIMENTA_ESTOQUE from HR_SAP_LJ_PROCESSO where HR_LJ_NF_PROCESSO = " + CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,"CurMovimentaEstoque","Erro pesquisando informações de Movimentação de Estoque")
*!*	*			Select CurMovimentaEstoque
*!*	*			Go Top
*!*	*			lMovimentaEstoque = CurMovimentaEstoque.MOVIMENTA_ESTOQUE 
*!*	*		ENDIF
*!*			
*!*			Select CurHR_SAP_LOJA_NOTA

*!*			
*!*			*!* Update Cabecalho
*!*			TEXT TO strUpdateSolicitacao TEXTMERGE NOSHOW
*!*			UPDATE dbo.HR_SAP_LOJA_NOTA 
*!*				SET HR_LJ_NF_PROCESSO = ?CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO
*!*					,STATUS = 1
*!*					,SOLICITA_CANCELAMENTO = <<IIF(bCancelamento,1,"?CurHR_SAP_LOJA_NOTA.SOLICITA_CANCELAMENTO")>>
*!*					,RETORNOU_LOJA = 1
*!*					,NF_NUMERO = ?CurHR_SAP_LOJA_NOTA.NF_NUMERO
*!*					,SERIE_NF = ?CurHR_SAP_LOJA_NOTA.SERIE_NF
*!*					,CODIGO_FILIAL = ?CurHR_SAP_LOJA_NOTA.CODIGO_FILIAL
*!*					,CLIFOR_DESTINO = ?CurHR_SAP_LOJA_NOTA.CLIFOR_DESTINO
*!*					,INDICA_CLIENTE_OCASIONAL = ?CurHR_SAP_LOJA_NOTA.INDICA_CLIENTE_OCASIONAL
*!*					,CODIGO_CLIENTE = ?CurHR_SAP_LOJA_NOTA.CODIGO_CLIENTE
*!*					,DEPOSITO_DESTINO = ?CurHR_SAP_LOJA_NOTA.DEPOSITO_DESTINO 
*!*					,TRANSPORTADORA = ?CurHR_SAP_LOJA_NOTA.TRANSPORTADORA
*!*					,CODIGO_TRANSPORTADOR_SAP = NULL
*!*					,INDICA_TRANSPORTE_PROPRIO = ?CurHR_SAP_LOJA_NOTA.INDICA_TRANSPORTE_PROPRIO
*!*					,OBS_NF = ?CurHR_SAP_LOJA_NOTA.OBS_NF
*!*					,OBS_NF_AUTOMATICA = ?CurHR_SAP_LOJA_NOTA.OBS_NF_AUTOMATICA
*!*					,TIPO_FRETE_LINX = ?CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX
*!*					,QTDE_TOTAL = ?CurHR_SAP_LOJA_NOTA.QTDE_TOTAL 
*!*					,FINALIDADE_NF = ?CurHR_SAP_LOJA_NOTA.FINALIDADE_NF
*!*					,NFE_REFERENCIADA = ?CurHR_SAP_LOJA_NOTA.NFE_REFERENCIADA
*!*					,SERIE_NF_REFERENCIADA = ?CurHR_SAP_LOJA_NOTA.SERIE_NF_REFERENCIADA
*!*					,MOVIMENTA_ESTOQUE = ?CurHR_SAP_LOJA_NOTA.MOVIMENTA_ESTOQUE
*!*					,NUMERO_VOLUME = ?CurHR_SAP_LOJA_NOTA.NUMERO_VOLUME
*!*					,PLACA_TRANSPORTADORA = ?CurHR_SAP_LOJA_NOTA.PLACA_TRANSPORTADORA
*!*					,PESO_CAIXA_TOTAL = ?CurHR_SAP_LOJA_NOTA.PESO_CAIXA_TOTAL
*!*					,CENTRO_CUSTO = ?CurHR_SAP_LOJA_NOTA.CENTRO_CUSTO
*!*					,CHAVE_ORIGEM_REFERENCIA = ?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM_REFERENCIA
*!*					,CUPOM_ECF = ?CurHR_SAP_LOJA_NOTA.CUPOM_ECF 
*!*					,CUPOM_DATA = ?CurHR_SAP_LOJA_NOTA.CUPOM_DATA 
*!*					,CUPOM_NUM = ?CurHR_SAP_LOJA_NOTA.CUPOM_NUM
*!*					,CUPOM_CHAVE= ?CurHR_SAP_LOJA_NOTA.CUPOM_CHAVE
*!*					,VALOR_FRETE = ?CurHR_SAP_LOJA_NOTA.VALOR_FRETE
*!*			where CODIGO_LINX = ?CurHR_SAP_LOJA_NOTA.CODIGO_LINX AND STATUS =<<nStatus>>
*!*			SELECT @@rowcount as RegistrosAfetados
*!*			ENDTEXT 
*!*			* 
*!*			
*!*			IF .Not. HrSqlExecRetaguarda(idConexao, strUpdateSolicitacao,"curRegistrosAfetados",3) 
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para alteração das informações do cabeçalho.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .f.
*!*			Endif
*!*			
*!*			Select curRegistrosAfetados
*!*			Go Top
*!*			If Reccount()<>1 Or curRegistrosAfetados.RegistrosAfetados <> 1
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nInconsistencia nos dados alterados.\nRegistros afetados: "+NVL(transf(curRegistrosAfetados.RegistrosAfetados),"{Nulo}"),"Erro",bNaoMostrarCriticas)
*!*				Return .F.
*!*			Endif
*!*			*!* Fim - Update Cabecalho		
*!*			
*!*		Else && Insert Cabecalho
*!*		
*!*	*		If SqlSelect("select MOVIMENTA_ESTOQUE from HR_SAP_LJ_PROCESSO where HR_LJ_NF_PROCESSO = " + CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,"CurMovimentaEstoque","Erro pesquisando informações de Movimentação de Estoque")
*!*	*			Select CurMovimentaEstoque
*!*	*			Go Top
*!*	*			lMovimentaEstoque = CurMovimentaEstoque.MOVIMENTA_ESTOQUE 
*!*	*		ENDIF
*!*			
*!*			Select CurHR_SAP_LOJA_NOTA	
*!*		
*!*			TEXT TO strInsertSolicitacao TEXTMERGE NOSHOW
*!*			INSERT INTO dbo.HR_SAP_LOJA_NOTA (
*!*			CODIGO_LINX,CHAVE_ORIGEM,HR_LJ_NF_PROCESSO,STATUS,
*!*			SOLICITA_CANCELAMENTO,RETORNOU_LOJA,
*!*			CODIGO_FILIAL,CLIFOR_DESTINO,
*!*			INDICA_CLIENTE_OCASIONAL,CODIGO_CLIENTE,DEPOSITO_DESTINO,TRANSPORTADORA,
*!*			INDICA_TRANSPORTE_PROPRIO,OBS_NF,TIPO_FRETE_LINX,QTDE_TOTAL,
*!*			FINALIDADE_NF,NFE_REFERENCIADA,		
*!*			SERIE_NF_REFERENCIADA,		
*!*			MOVIMENTA_ESTOQUE,NUMERO_VOLUME,PLACA_TRANSPORTADORA,PESO_CAIXA_TOTAL,
*!*			CENTRO_CUSTO,CHAVE_ORIGEM_REFERENCIA,OBS_NF_AUTOMATICA
*!*			,CUPOM_ECF
*!*			,CUPOM_DATA
*!*			,CUPOM_NUM
*!*			,CUPOM_CHAVE
*!*			,VALOR_FRETE
*!*			)
*!*			values (
*!*			?CurSequencialSolicitaNf.Sequencia,?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM,?CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,1,
*!*			<<IIF(bCancelamento,1,0)>>,1,?CurHR_SAP_LOJA_NOTA.CODIGO_FILIAL,?CurHR_SAP_LOJA_NOTA.CLIFOR_DESTINO,
*!*			?CurHR_SAP_LOJA_NOTA.INDICA_CLIENTE_OCASIONAL,?CurHR_SAP_LOJA_NOTA.CODIGO_CLIENTE,?CurHR_SAP_LOJA_NOTA.DEPOSITO_DESTINO,?CurHR_SAP_LOJA_NOTA.TRANSPORTADORA,
*!*			?CurHR_SAP_LOJA_NOTA.INDICA_TRANSPORTE_PROPRIO,?CurHR_SAP_LOJA_NOTA.OBS_NF,?CurHR_SAP_LOJA_NOTA.TIPO_FRETE_LINX,?CurHR_SAP_LOJA_NOTA.QTDE_TOTAL,
*!*			?CurHR_SAP_LOJA_NOTA.FINALIDADE_NF,?CurHR_SAP_LOJA_NOTA.NFE_REFERENCIADA,		
*!*			
*!*			(SELECT top 1 S.SERIE_NF FROM SERIES_NF S
*!*				WHERE S.COD_SERIE_SINTEGRA = ?CurHR_SAP_LOJA_NOTA.SERIE_NF_REFERENCIADA or 
*!*					S.SERIE_NF = ?CurHR_SAP_LOJA_NOTA.SERIE_NF_REFERENCIADA),		
*!*			
*!*			?CurHR_SAP_LOJA_NOTA.MOVIMENTA_ESTOQUE,?CurHR_SAP_LOJA_NOTA.NUMERO_VOLUME,?CurHR_SAP_LOJA_NOTA.PLACA_TRANSPORTADORA,?CurHR_SAP_LOJA_NOTA.PESO_CAIXA_TOTAL,	
*!*			?CurHR_SAP_LOJA_NOTA.CENTRO_CUSTO,?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM_REFERENCIA,?CurHR_SAP_LOJA_NOTA.OBS_NF_AUTOMATICA
*!*			,?CurHR_SAP_LOJA_NOTA.CUPOM_ECF, ?CurHR_SAP_LOJA_NOTA.CUPOM_DATA, ?CurHR_SAP_LOJA_NOTA.CUPOM_NUM, ?CurHR_SAP_LOJA_NOTA.CUPOM_CHAVE, ?CurHR_SAP_LOJA_NOTA.VALOR_FRETE
*!*			)
*!*			ENDTEXT 
*!*			* 
*!*			IF .Not. HrSqlExecRetaguarda(idConexao, "Execute dbo.SP_HR_SAP_LOJA_NOTA_SEQUENCIAL","CurSequencialSolicitaNf",3)
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informações do cabeçalho.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .f.
*!*			Endif
*!*			
*!*			
*!*			IF .Not. HrSqlExecRetaguarda(idConexao, strInsertSolicitacao,"",3) 
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informações do cabeçalho.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .f.
*!*			Endif
*!*			
*!*			*!* Tenta atualizar codigo da retaguarda na base da loja / Nao para o processo porque tenta depois
*!*			SQLExecuteLocalMsg("Update DBO.HR_SAP_LOJA_NOTA SET CODIGO_LINX = ?CurSequencialSolicitaNf.Sequencia where CHAVE_ORIGEM = ?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM",bNaoMostrarCriticas)
*!*			
*!*		Endif

*!*		*!* Inseri Filhas
*!*		TEXT TO strInsertItem NOSHOW
*!*		insert into dbo.HR_SAP_LOJA_NOTA_ITEM
*!*		(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
*!*		ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE,
*!*		INFO_CUPOM,REF_PRODUTO,REF_COR_PRODUTO,REF_TAMANHO
*!*		)
*!*		values (?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM,?CurHR_SAP_LOJA_NOTA_ITEM.ITEM,?CurHR_SAP_LOJA_NOTA_ITEM.INDICA_PRODUTO,?CurHR_SAP_LOJA_NOTA_ITEM.PRODUTO,?CurHR_SAP_LOJA_NOTA_ITEM.COR_PRODUTO,?CurHR_SAP_LOJA_NOTA_ITEM.TAMANHO,
*!*			?CurHR_SAP_LOJA_NOTA_ITEM.ITEM_FISCAL,?CurHR_SAP_LOJA_NOTA_ITEM.QTDE,?CurHR_SAP_LOJA_NOTA_ITEM.VALOR_LIQUIDO,?CurHR_SAP_LOJA_NOTA_ITEM.OBS_ITEM_NF,?CurHR_SAP_LOJA_NOTA_ITEM.CATEGORIA_ESTOQUE,
*!*			?CurHR_SAP_LOJA_NOTA_ITEM.INFO_CUPOM,?CurHR_SAP_LOJA_NOTA_ITEM.REF_PRODUTO,?CurHR_SAP_LOJA_NOTA_ITEM.REF_COR_PRODUTO,?CurHR_SAP_LOJA_NOTA_ITEM.REF_TAMANHO
*!*			)
*!*		ENDTEXT 
*!*		
*!*		Select CurHR_SAP_LOJA_NOTA_ITEM
*!*		Go Top
*!*		Scan
*!*			If .Not. HrSqlExecRetaguarda(idConexao, strInsertItem,"",3)
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir os itens.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .F.
*!*			Endif
*!*			Select CurHR_SAP_LOJA_NOTA_ITEM
*!*		Endscan
*!*		
*!*		If bClienteOcasional
*!*			Select CurHR_SAP_LOJA_NOTA_CLIENTE
*!*			Go Top
*!*			TEXT TO strInsertCliente NOSHOW
*!*				insert into dbo.HR_SAP_LOJA_NOTA_CLIENTE
*!*				(CHAVE_ORIGEM,CNPJ,CPF,PF_PJ
*!*				,NOME_CLIENTE,ENDERECO,LOGRADOURO
*!*				,COMPLEMENTO,NUMERO,BAIRRO,CIDADE,UF,CEP
*!*				,DDD_TELEFONE,TELEFONE,DDD_CELULAR,CELULAR
*!*				,EMAIL_NFE,IE )
*!*				values
*!*				(?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM,?CurHR_SAP_LOJA_NOTA_CLIENTE.CNPJ,?CurHR_SAP_LOJA_NOTA_CLIENTE.CPF,?CurHR_SAP_LOJA_NOTA_CLIENTE.PF_PJ
*!*				,?CurHR_SAP_LOJA_NOTA_CLIENTE.NOME_CLIENTE,?CurHR_SAP_LOJA_NOTA_CLIENTE.ENDERECO,?CurHR_SAP_LOJA_NOTA_CLIENTE.LOGRADOURO
*!*				,?CurHR_SAP_LOJA_NOTA_CLIENTE.COMPLEMENTO,?CurHR_SAP_LOJA_NOTA_CLIENTE.NUMERO,?CurHR_SAP_LOJA_NOTA_CLIENTE.BAIRRO,?CurHR_SAP_LOJA_NOTA_CLIENTE.CIDADE,?CurHR_SAP_LOJA_NOTA_CLIENTE.UF,?CurHR_SAP_LOJA_NOTA_CLIENTE.CEP
*!*				,?CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_TELEFONE,?CurHR_SAP_LOJA_NOTA_CLIENTE.TELEFONE,?CurHR_SAP_LOJA_NOTA_CLIENTE.DDD_CELULAR,?CurHR_SAP_LOJA_NOTA_CLIENTE.CELULAR
*!*				,?CurHR_SAP_LOJA_NOTA_CLIENTE.EMAIL_NFE,?CurHR_SAP_LOJA_NOTA_CLIENTE.IE )
*!*			ENDTEXT

*!*			If .Not. HrSqlExecRetaguarda(idConexao, strInsertCliente,"",3)
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informação do cliente.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .F.
*!*			Endif
*!*		ENDIF
*!*		
*!*		TEXT TO strInserePagamento Noshow
*!*			INSERT INTO HR_SAP_LOJA_NOTA_PAGAMENTO(	
*!*					CHAVE_ORIGEM,
*!*					PARCELA,
*!*					CODIGO_ADMINISTRADORA,
*!*					TIPO_PGTO,
*!*					VALOR,
*!*					VENCIMENTO,
*!*					NUMERO_TITULO,
*!*					PARCELAS_CARTAO,
*!*					NUMERO_APROVACAO_CARTAO
*!*			)
*!*			VALUES(	?CurHR_SAP_LOJA_NOTA.CHAVE_ORIGEM,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.PARCELA,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.CODIGO_ADMINISTRADORA,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.TIPO_PGTO,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.VALOR,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.VENCIMENTO,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.NUMERO_TITULO,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.PARCELAS_CARTAO,
*!*					?CurHR_SAP_LOJA_NOTA_PAGAMENTO.NUMERO_APROVACAO_CARTAO)		
*!*		ENDTEXT
*!*		
*!*		
*!*		SELECT CURHR_SAP_LOJA_NOTA_PAGAMENTO
*!*		GO TOP 
*!*		SCAN
*!*			If .Not. HrSqlExecRetaguarda(idConexao, strInserePagamento ,"",3)
*!*				strMensagem = Message()
*!*				HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*				HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*				MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informação do pagamento.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*				Return .F.
*!*			Endif		
*!*		ENDSCAN
*!*		
*!*		
*!*		
*!*		*!* Fim - Inseri Filhas
*!*		
*!*		IF .Not. HrSqlExecRetaguarda(idConexao, "Commit","",1) 
*!*			strMensagem = Message()
*!*			HrSqlExecRetaguarda(idConexao, "rollback" ,"",3)
*!*			HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
*!*			MsgBoxLocalMsg("Erro ao enviar informações para matriz.\nErro no comando para inserir informação do cliente.\nDetalhes:"+strMensagem,16,"Erro",bNaoMostrarCriticas)
*!*			Return .f.
*!*		Endif
*!*		*!* Fim - Envia para Retaguarda
	
	SQLExecuteLocalMsg("UPDATE DBO.HR_SAP_LOJA_NOTA SET STATUS = 1 WHERE CHAVE_ORIGEM = ?strChaveOrigem AND STATUS in(0,4)","Erro atualizando status na loja, nota será enviada mesmo assim.",bNaoMostrarCriticas)
	
	IF Inlist(CurHR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,_HR_LJ_PROCESSO_TROCA_CUPOM_OMNI)  THEN
		AtualizaStatusPedidoShipTroca(strChaveOrigem)	
	ENDIF
	
	
	*!* Desconecta no Fim do Processo
*!*		HrSqlDisconnect(idConexao,bConexaoLocal ) && Disconecta da retaguarda
	
Endfunc

Function HrNfEnviarCancelamento
	Parameters strCodigoLinx As String,idConexao As Integer, bAutomatico as Boolean	
	
	*!* Nao conectar mais no banco de retaguarda
	Return SqlExecute("UPDATE HR_SAP_LOJA_NOTA SET SOLICITA_CANCELAMENTO = 1 WHERE CHAVE_ORIGEM= ?strCodigoLinx",;
						"Erro ao marcar processo como cancelamento solicitado")
	
*!*		ShowProgress("Enviando cancelamento da solicitação de nota fiscal...")

*!*		Local nTentativaComando As Number,bRetorno As Boolean,bEstornoSolicitado As Boolean,bConexaoLocal As Integer
*!*		bEstornoSolicitado =.F.
*!*		bConexaoLocal = (Pcount()<2 or idConexao = 0) 
*!*		If bConexaoLocal
*!*			idConexao = HrConexaoERP()
*!*			If idConexao <=0
*!*				Return .F.
*!*			Endif
*!*		Else
*!*			If idConexao <=0
*!*				MsgBox("Não foi possível estabelecer conexão com a Retaguarda para envio da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
*!*					"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção")
*!*				Return .F.
*!*			Endif
*!*		Endif

*!*		bRetorno = .T.

*!*		Try
*!*			Local nStatusNf As Integer

*!*			Public bExiste As Boolean,bEstornar As Boolean,nStatus As Integer,strDescStatus As String,;
*!*				strNfNumero As String,strEmissaoNf As String,bRetornouLoja As Boolean

*!*			nStatusNf = HrNfGetStatus(strCodigoLinx,idConexao)

*!*			If nStatusNf<0 && Ja existe mensagem alertando o problema
*!*				bRetorno = .F.
*!*				Exit
*!*			Endif
*!*			ShowProgress()
*!*			IF nStatusNf==0
*!*				IF .Not. SqlSelect("select status from HR_SAP_LOJA_NOTA WHERE CHAVE_ORIGEM = ?strCodigoLinx ","CurExisteSolicitacao","Erro verificando se solicitação da nota fiscal já havia sido realizada")
*!*					bRetorno = .F.
*!*					Return .f.
*!*				Endif
*!*				
*!*				IF Reccount("CurExisteSolicitacao")==0
*!*					MsgBox("Não foi solicitado a emissão da nota fiscal para esta movimentação. Salve a movimentação já cancelada!",16,"Erro")
*!*					bRetorno = .F.
*!*					exit
*!*				Endif
*!*				
*!*				use in select("CurExisteSolicitacao")
*!*				
*!*				*!* Envia todos os dados para a retaguarda && ja com a opcao de cancelamento marcada
*!*				IF .Not. HrNfEnviarDados(strCodigoLinx,idConexao, .T.)
*!*					bRetorno = .F.
*!*					exit
*!*				Endif
*!*				
*!*				bEstornoSolicitado=.t.
*!*				
*!*			ELSE
*!*				IF !bAutomatico THEN 
*!*					If .Not. Inlist(nStatusNf,3,4)
*!*						If MsgBox("A nota fiscal não está com status concluído. Você deseja realmente agendar o cancelamento do processo?",4+48+256,"Atenção")==7
*!*							bRetorno = .F.
*!*							Exit
*!*						Endif
*!*					Else
*!*						If MsgBox("Deseja realmente solicitar o cancelamento desta Nota Fiscal?",4+48+256,"Atenção")==7
*!*							bRetorno = .F.
*!*							Exit
*!*						Endif
*!*					ENDIF
*!*				ENDIF

*!*				If .Not. HrSqlExecRetaguarda(idConexao,"EXECUTE DBO.SP_HR_SAP_LOJA_NOTA_ESTORNAR @CHAVE_ORIGEM =?strCodigoLinx","")
*!*					MsgBox("Não foi possível solicitar o cancelamento\nA nota fiscal não será cancelada."+;
*!*						"\nDetalhes: "+Message(),48,"Atenção")
*!*					bRetorno = .F.
*!*					Exit
*!*				Endif
*!*				bEstornoSolicitado = .T.
*!*			Endif

*!*			ShowProgress()
*!*			IF !bAutomatico Then
*!*				MsgBox("Solicitação de cancelamento da nota fiscal enviada para a Matriz.\nAcompanhe o status do processo.",64,"Informação")
*!*			ENDIF
*!*			
*!*		Catch to oExcept
*!*			ShowProgress()
*!*			MsgBox("Ocorreu um erro na verificação de status da nota fiscal.\nLinha: "+Str(oExcept.Lineno)+" - Menagem: "+oExcept.Message,48,"Atenção")
*!*			bRetorno = .F.
*!*		Finally
*!*			If bConexaoLocal
*!*				If idConexao >0
*!*					=SQLDisconnect(idConexao)
*!*				Endif
*!*			Endif
*!*			ShowProgress()
*!*		Endtry

*!*		If bEstornoSolicitado
*!*			SqlExecute("UPDATE HR_SAP_LOJA_NOTA SET SOLICITA_CANCELAMENTO = 1 WHERE CHAVE_ORIGEM= ?strCodigoLinx",;
*!*							"Erro ao marcar processo como cancelamento solicitado")
*!*		Endif

*!*		Return bRetorno

Endfunc

Function HrNfRetornaParaAutorizada as Boolean
	Parameters strCodigoLinx As String,idConexao As Integer

	Local nTentativaComando As Number,bRetorno As Boolean,bConexaoLocal As Integer
	bEstornoSolicitado =.F.
	bConexaoLocal = (Pcount()<2)
	bRetorno = .t.
	
	If bConexaoLocal
		idConexao = HrConexaoERP()
		If idConexao <=0
			Return .F.
		Endif
	Else
		If idConexao <=0
			MsgBox("Não foi possível estabelecer conexão com a Retaguarda para envio da Nota Fiscal\nVerifique sua conexão com a internet, entre em contato com o suporte "+;
				"ou tente novamente mais tarde.\nDetalhes: "+Message(),48,"Atenção")
			Return .F.
		Endif
	Endif
	
	Local nStatusNf As Integer
	Try
		nStatusNf = HrNfGetStatus(strCodigoLinx,idConexao)

		If nStatusNf<0 && Ja existe mensagem alertando o problema
			bRetorno = .F.
			Exit
		Endif
		
		*!* Validacao - Deve estar com status de critica na criacao de estorno
		IF nStatusNf <> _CRITICA_CRIACAO_ESTORNO_SAP
			MsgBox("O status da nota deve ser critica no estorno para utilizar para utilizar este recurso",16,"Erro")
			bRetorno = .F.
			Exit
		Endif
		
		*!* Executa na retaguarda procedure para voltar status para autorizado
		If .Not. HrSqlExecRetaguarda(idConexao,"EXECUTE DBO.SP_HR_SAP_LOJA_NOTA_RETORNA_AUTORIZADA @CHAVE_ORIGEM =?strCodigoLinx","")
			MsgBox("Não foi possível voltar o status para autorizada\n"+;
				"\nDetalhes: "+Message(),48,"Atenção")
			bRetorno = .F.
			Exit
		Endif
		
		TEXT TO strUpdateStatus TEXTMERGE noshow
		UPDATE HR_SAP_LOJA_NOTA 
		SET STATUS = <<_CRIADO_SAP>> 
		WHERE CHAVE_ORIGEM= ?strCodigoLinx
		ENDTEXT 

		*!* Nao exibe mensagem porque o status foi atualizado corretamente na retaguarda
		SqlExecute(strUpdateStatus)
		
	Catch to oExcept
		ShowProgress()
		MsgBox("Ocorreu um erro na verificação de status da nota fiscal.\nLinha: "+Str(oExcept.Lineno)+" - Menagem: "+oExcept.Message,48,"Atenção")
		bRetorno = .F.
	Finally
		If bConexaoLocal
			If idConexao >0
				=SQLDisconnect(idConexao)
			Endif
		Endif
		ShowProgress()
	Endtry
	
	Return bRetorno
	
Endfunc 

********---------------------------									-------------------------------********
***********************************************************************************************************
* Metodos de "Merge" que buscam informações das tabelas no Linx para gerar a solicitação de notas fiscais *
***********************************************************************************************************
********---------------------------									-------------------------------********

*!* Retorna o HR_SAP_LJ_PROCESSO para LOJA_SAIDAS e LOJA_ENTRADAS com base na coluna "TIPO_ENTRADA_SAIDA"
*!* Tipo	Nome							EntradaSaida	HR_SAP_LJ_PROCESSO 
*!*	TS		TRANSFERÊNCIA DE SAÍDA				S				100
*!*	BN		Bonificação							S				10
*!*	RB		Retorno Bonificação					E				11
*!*	BR		Brinde								S				12
*!*	RR		Retorno Brinde						E				13
*!*	SK		Saída para Transformação Kilo		S				19
*!*	EK		Entrada para Transformação Kilo		E				20
*!*	AS		Saída Estoque Ajuste				S				21
*!*	AE		Entrada Estoque Ajuste				E				22
*!*	FS		Remessa para Fotografia				S				23
*!*	FE		Retorno de Remessa para Fotografia	E				24
*!* UN		Saída para Uniforme					S				27
*!* TD		Devolução fABRICAS 		S				103
Function GetHrSapLjProcessoEntradaSaida && Busca HR_SAP_LJ_PROCESSO com base no TIPO_ENTRADA_SAIDA
	Lparameters strTipoEntradaSaida
	Do Case
		Case strTipoEntradaSaida=="CS"
			Return 9
		Case strTipoEntradaSaida=="BN"
			Return 10
		Case strTipoEntradaSaida=="RB"
			Return 11
		Case strTipoEntradaSaida=="BR"
			Return 12
		Case strTipoEntradaSaida=="RR"
			Return 13
		CASE strTipoEntradaSaida=="TM"
			Return 100
		Case strTipoEntradaSaida=="SK"
			Return 19
		Case strTipoEntradaSaida=="EK"
			Return 20
		Case strTipoEntradaSaida=="AS"
			Return 21
		Case strTipoEntradaSaida=="AE"
			Return 22
		Case strTipoEntradaSaida=="FS"
			Return 23
		Case strTipoEntradaSaida=="FE"
			Return 24
		Case strTipoEntradaSaida=="UN"
			Return 27
		Case strTipoEntradaSaida=="TS"
			Return 100			
		Case strTipoEntradaSaida=="TK"
			Return 100			
		Case strTipoEntradaSaida=="RS"
			Return 28
		Case strTipoEntradaSaida=="RE"
			Return 29
		Case strTipoEntradaSaida=="TD"
			Return 103	
		Otherwise
			Return Null
	Endcase
Endfunc

Function GetEntradaSaidaHrSapLjProcesso && Busca TIPO_ENTRADA_SAIDA com base no HR_SAP_LJ_PROCESSO
	Lparameters iHrSapLjProcesso as Integer
	Do Case
		Case iHrSapLjProcesso==9 && CONCERTO - Devolução para Cliente
			Return "CS"			
		Case iHrSapLjProcesso==10 && Bonificação
			Return "BN"
		Case iHrSapLjProcesso==11 && Retorno Bonificação
			Return "RB"
		Case iHrSapLjProcesso==12 && Brinde
			Return "BR"
		Case iHrSapLjProcesso==13 && Retorno Brinde
			Return "RR"
		Case iHrSapLjProcesso==19 && Saída para Transformação Kilo
			Return "SK"
		Case iHrSapLjProcesso==20 && Entrada para Transformação Kilo
			Return "EK"
		Case iHrSapLjProcesso==21 && Saída Estoque Ajuste
			Return "AS"
		Case iHrSapLjProcesso==22 && Entrada Estoque Ajuste
			Return "AE"
		Case iHrSapLjProcesso==23 && Remessa para Fotografia
			Return "FS"
		Case iHrSapLjProcesso==24 && Retorno de Remessa para Fotografia
			Return "FE"
		Case iHrSapLjProcesso==27 && Retorno de Remessa para Fotografia
			Return "UN"
		Case iHrSapLjProcesso==100 && Transferencia Normal
			Return "TS"
		Case iHrSapLjProcesso==28 && Remessa para demonstração Saida
			Return "RS"
		Case iHrSapLjProcesso==29 && Retorno para demonstração entrada
			Return "RE"
		Case iHrSapLjProcesso==103 && Devolução total para fechamento de loja
			Return "TD"
			
		Otherwise
			Return Null
	Endcase
Endfunc

*!* HR_SAP_LJ_PROCESSO.	Letra Linx
*--	1						V
*--	2						H
*--	3						T
*--	4						T
*--	5						C
*--	6						Z
*--	7						W
*--	8						R
*--	9						U
*--	10						B
*--	11						X
*--	12						B
*--	13						X
*--	14						E
*--	15						S
*--	16						F
*--	17						G
*--	18						I
*--	19						Q
*--	20						K
*--	21						J
*--	22						N
*--	23						P
*--	24						O
*-- 25						M
*-- 26						L
*-- 27						Y
*-- 28						S
*-- 29						E
*--	100						A

Function GetLetraHrSapLjProcesso
	Lparameters iHrSapLjProcesso
	Do Case
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_VENDA_CUPOM
			Return "V"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_CUPOM
			Return "H"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_TROCA_CUPOM
			Return "T"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_TROCAS_DIA
			Return "T"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_CANCELAMENTOS_CUPOM
			Return "C"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_ENTRADA
			Return "Z"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_SAIDA
			Return "W"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_REMESSA_CONSERTO
			Return "R"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_CLIENTE_CONSERTO
			Return "U"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_BONIFICACAO
			Return "B"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_BONIFICACAO
			Return "X"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_BRINDE
			Return "B"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_BRINDE
			Return "X"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_OUTRAS_ENTRADAS
			Return "E"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_OUTRAS_SAIDAS
			Return "S"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_REMESSA_VENDA_FORA_ESTAB
			Return "F"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_VENDA_FORA_ESTAB
			Return "G"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_COMPLEMENTO_VALOR_IMPOSTO
			Return "I"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO
			Return "Q"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO
			Return "K"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_SAIDA_ESTOQUE_AJUSTE
			Return "J"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_ENTRADA_ESTOQUE_AJUSTE
			Return "N"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA
			Return "P"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_FOTOGRAFIA
			Return "O"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_REMESSA_LOJA_REFORMA
			Return "M"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_LOJA_REFORMA
			Return "L"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_SAIDA_UNIFORME
			Return "Y"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_TRANSFERENCIA_NORMAL
			Return "A"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_TRANSFERENCIA_CONCERTO
			Return "D"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_REMESSA_DEMOSNTRACAO
			Return "S"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_RETORNO_DEMOSNTRACAO
			Return "E"			
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_NOTA_VENDA 
			Return "V"
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_NOTA_VENDA_OMNI
			Return "V"	
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_TROCA_CUPOM_OMNI
			Return "T"	
		Case iHrSapLjProcesso == _HR_LJ_PROCESSO_DEVOLUCAO_FABRICAS
			Return "D"	
			
		Otherwise
			Return Null
	Endcase
Endfunc


Function HrMergeLojaSaidas As String && Retorna chave origem em caso de sucesso, em caso de erro retorna em branco
	parameters strFilial As String,strCodigoFilial As String,strRomaneioProduto As String,bJaValidouAlteracao as Boolean
	
	Public strChaveOrigemSaida As String

	*!* Busca Dados && Regra Quando for nota de ajuste (AS) a nota sai contra a propria loja
	TEXT TO strSelectLojaSaidasProduto noshow
	Select a.FILIAL_DESTINO
		,a.FORNECEDOR_DEVOLUCAO
		,a.TIPO_ENTRADA_SAIDA
		,a.SAIDA_CANCELADA
		,CLIFOR_DESTINO = B.CLIFOR
		,INDICA_CLIENTE_OCASIONAL = CONVERT(BIT,CASE WHEN a.TIPO_ENTRADA_SAIDA IN ('BN','FS','BR') THEN 1 ELSE 0 END)
		,a.QTDE_TOTAL
		,A.HR_DEPOSITO_DESTINO
	from LOJA_SAIDAS a
	inner join CADASTRO_CLI_FOR b on b.NOME_CLIFOR =
				CASE WHEN A.TIPO_ENTRADA_SAIDA IN('AS','UN') THEN A.FILIAL ELSE ISNULL(a.FILIAL_DESTINO,a.FORNECEDOR_DEVOLUCAO) END 
	where A.ROMANEIO_PRODUTO = ?strRomaneioProduto and A.FILIAL = ?strFilial
	ENDTEXT

	IF .Not. SqlSelect(strSelectLojaSaidasProduto ,"CurIntegraLojaSaidas","Erro ao consultar cabecalho da saida")
		Return ""
	Endif
	
	TEXT TO strSelectLojaSaidasProduto noshow
	select A.ROMANEIO_PRODUTO,A.FILIAL,A.PRODUTO,A.COR_PRODUTO,A.QTDE_SAIDA,
		A.PRECO1,A.PRECO2,A.PRECO3,A.PRECO4,A.VALOR,
		A.EN1,A.EN2,A.EN3,A.EN4,A.EN5,A.EN6,A.EN7,A.EN8,A.EN9,A.EN10,
		A.EN11,A.EN12,A.EN13,A.EN14,A.EN15,A.EN16,A.EN17,A.EN18,A.EN19,A.EN20,
		A.EN21,A.EN22,A.EN23,A.EN24,A.EN25,A.EN26,A.EN27,A.EN28,A.EN29,A.EN30,
		A.EN31,A.EN32,A.EN33,A.EN34,A.EN35,A.EN36,A.EN37,A.EN38,A.EN39,A.EN40,
		A.EN41,A.EN42,A.EN43,A.EN44,A.EN45,A.EN46,A.EN47,A.EN48,
		B.GRADE,B.PONTEIRO_PRECO_TAM,B.VARIA_PRECO_TAM
	from LOJA_SAIDAS_PRODUTO A
	join PRODUTOS B ON A.PRODUTO = B.PRODUTO 	 
	where a.romaneio_produto = ?strRomaneioProduto and a.filial = ?strFilial
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectLojaSaidasProduto ,"CurIntegraLojaSaidasProduto","Erro ao consultar produtos da saida")
		Return ""
	Endif
	
	TEXT TO strSelectProdutosTamanhos noshow
	select a.GRADE,a.NUMERO_TAMANHOS,
		a.TAMANHO_1,a.TAMANHO_2,a.TAMANHO_3,a.TAMANHO_4,a.TAMANHO_5,a.TAMANHO_6,
		a.TAMANHO_7,a.TAMANHO_8,a.TAMANHO_9,a.TAMANHO_10,a.TAMANHO_11,a.TAMANHO_12,
		a.TAMANHO_13,a.TAMANHO_14,a.TAMANHO_15,a.TAMANHO_16,a.TAMANHO_17,a.TAMANHO_18,
		a.TAMANHO_19,a.TAMANHO_20,a.TAMANHO_21,a.TAMANHO_22,a.TAMANHO_23,a.TAMANHO_24,
		a.TAMANHO_25,a.TAMANHO_26,a.TAMANHO_27,a.TAMANHO_28,a.TAMANHO_29,a.TAMANHO_30,
		a.TAMANHO_31,a.TAMANHO_32,a.TAMANHO_33,a.TAMANHO_34,a.TAMANHO_35,a.TAMANHO_36,
		a.TAMANHO_37,a.TAMANHO_38,a.TAMANHO_39,a.TAMANHO_40,a.TAMANHO_41,a.TAMANHO_42,
		a.TAMANHO_43,a.TAMANHO_44,a.TAMANHO_45,a.TAMANHO_46,a.TAMANHO_47,a.TAMANHO_48
	from produtos_tamanhos a	
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectProdutosTamanhos,"CurIntegraProdutosTamanhos","Erro ao consultar produtos da saida")
		Return ""
	Endif
	*!* Fim - Busca Dados
	
	*!* Validacoes
	If Reccount("CurIntegraLojaSaidas")==0
		MsgBox("Erro ao gerar solicitação de nota. Saída não encontrada na base de dados",16,"Erro")
		Return ""
	Endif
	If Reccount("CurIntegraLojaSaidasProduto")==0
		MsgBox("Erro ao gerar solicitação de nota. Não foram encontrados os itens da saída na base de dados",16,"Erro")
		Return ""
	Endif
	
	Local strLetra As String,iHrSapLjProcesso As Integer
	iHrSapLjProcesso = GetHrSapLjProcessoEntradaSaida(Upper(Alltrim(CurIntegraLojaSaidas.tipo_entrada_saida)))
	strLetra = GetLetraHrSapLjProcesso(iHrSapLjProcesso)
	If Empty(Nvl(strLetra,""))
		MsgBox("Erro ao gerar solicitação de nota. Não foi possível definir tipo de nota, pelo tipo de saída: "+Nvl(CurIntegraLojaSaidas.tipo_entrada_saida,"(Nulo)"),16,"Erro")
		Return ""
	Endif
	strChaveOrigemSaida = strLetra + Padl(strCodigoFilial,6,"0")+strRomaneioProduto
	
	IF .Not. bJaValidouAlteracao
		If .Not. HrNfPermiteAlterar(strChaveOrigemSaida)
			Return ""
		Endif
	Endif
	*!* Fim - Validacoes

	*!* Envia dados para tabela de notas fiscais && Existem tratamentos para cliente ocasional
	TEXT TO strInsertCabecalho TEXTMERGE NOSHOW 
		DECLARE @cliente_ocasional bit,@CLIFOR_DESTINO char(6)
		SET @cliente_ocasional = ?CurIntegraLojaSaidas.INDICA_CLIENTE_OCASIONAL
		SET @CLIFOR_DESTINO = case when @cliente_ocasional = 0 then ?CurIntegraLojaSaidas.CLIFOR_DESTINO end
		
		IF exists(select TOP 1 1 from DBO.HR_SAP_LOJA_NOTA WHERE CHAVE_ORIGEM = ?strChaveOrigemSaida)
		 UPDATE dbo.HR_SAP_LOJA_NOTA
		  SET CLIFOR_DESTINO = @CLIFOR_DESTINO
			,INDICA_CLIENTE_OCASIONAL=@cliente_ocasional
			,FINALIDADE_NF=1
			,MOVIMENTA_ESTOQUE=1
			,STATUS = 0
			,SOLICITA_CANCELAMENTO = CASE WHEN ISNULL(SOLICITA_CANCELAMENTO,0)=1 THEN 1 ELSE ?CurIntegraLojaSaidas.SAIDA_CANCELADA END
			,QTDE_TOTAL = ?CurIntegraLojaSaidas.QTDE_TOTAL
			,DEPOSITO_DESTINO = ?CurIntegraLojaSaidas.HR_DEPOSITO_DESTINO 
		 WHERE CHAVE_ORIGEM = ?strChaveOrigemSaida
		ELSE
		 Insert Into dbo.HR_SAP_LOJA_NOTA
			(CHAVE_ORIGEM,HR_LJ_NF_PROCESSO,Status,SOLICITA_CANCELAMENTO
			,NF_NUMERO,SERIE_NF,CODIGO_FILIAL,CLIFOR_DESTINO
			,INDICA_CLIENTE_OCASIONAL,CODIGO_CLIENTE,TRANSPORTADORA,INDICA_TRANSPORTE_PROPRIO,OBS_NF
			,TIPO_FRETE_LINX,FINALIDADE_NF,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,MOVIMENTA_ESTOQUE,NUMERO_VOLUME,QTDE_TOTAL,DEPOSITO_DESTINO,OBS_NF_AUTOMATICA)
		 Values (?strChaveOrigemSaida,<<iHrSapLjProcesso>>,0,?CurIntegraLojaSaidas.SAIDA_CANCELADA
			,Null,Null,?strCodigoFilial,@CLIFOR_DESTINO
			,@cliente_ocasional,null,Null,0,Null
			,Null,1,Null,Null,1,0,?CurIntegraLojaSaidas.QTDE_TOTAL,?CurIntegraLojaSaidas.HR_DEPOSITO_DESTINO, Null)	
	ENDTEXT
		
	TEXT TO strDeleteItem TEXTMERGE NOSHOW 
		DELETE FROM dbo.HR_SAP_LOJA_NOTA_ITEM WHERE CHAVE_ORIGEM = ?strChaveOrigemSaida
	ENDTEXT
	
	IF INLIST(iHrSapLjProcesso,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO)
		*!* Insert para notas de Transformacao de produto.	
		TEXT TO strInsertItem TEXTMERGE NOSHOW 
			Insert Into dbo.HR_SAP_LOJA_NOTA_ITEM
			(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
			ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE, 
			REF_PRODUTO, REF_COR_PRODUTO, REF_TAMANHO )
			Values (?strChaveOrigemSaida,?nItem,1,?CurIntegraLojaSaidasProduto.PRODUTO,?CurIntegraLojaSaidasProduto.COR_PRODUTO,?strTamanho,
			NULL,?nQtdeItem,?nValorItem,NULL,NULL,
			?CurIntegraProdutosTransformacao.PRODUTO,?CurIntegraProdutosTransformacao.COR_PRODUTO,?CurIntegraProdutosTransformacao.GRADE)
		ENDTEXT
	ELSE 
		TEXT TO strInsertItem TEXTMERGE NOSHOW 
			Insert Into dbo.HR_SAP_LOJA_NOTA_ITEM
			(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
			ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE )
			Values (?strChaveOrigemSaida,?nItem,1,?CurIntegraLojaSaidasProduto.PRODUTO,?CurIntegraLojaSaidasProduto.COR_PRODUTO,?strTamanho,
			NULL,?nQtdeItem,?nValorItem,NULL,NULL)
		ENDTEXT
	ENDIF 
	
	Local bRetornoOK as Boolean
	bRetornoOK = .f.
	main.data.BeginTransaction()
	Try
		If sqlExecute(strInsertCabecalho,"Erro inserindo informações do cabeçalho") .And.;
			sqlExecute(strDeleteItem,"Erro limpando informações anteriores")
			
			*!* Inseri itens
			Local bErroItens As Boolean
			bErroItens = .F.
			nItem=1

			IF INLIST(iHrSapLjProcesso,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO)
				*!* Monta itens para notas de Transformacao de produto.	
				TEXT TO sqlSelecionaProdutoTransformacao TEXTMERGE NOSHOW 
					SELECT 
						TIPO_MOV,NUMERO_ROMANEIO,FILIAL,PRODUTO,COR_PRODUTO,TAMANHO,
						GRADE,GRADE_PRO,CODIGO_BARRA,QTDE,LIGA 
					FROM 
						HR_SAP_CONVERSAO_KILO 
					WHERE 
						HR_SAP_CONVERSAO_KILO.NUMERO_ROMANEIO = ?strRomaneioProduto 
						AND HR_SAP_CONVERSAO_KILO.FILIAL =  ?strFilial
				ENDTEXT

				IF .Not. SqlSelect(sqlSelecionaProdutoTransformacao,"CurIntegraProdutosTransformacao","Erro ao consultar produtos da entrada")
					Return .F.
				ENDIF

				IF .Not. SqlSelect(sqlSelecionaProdutoTransformacao,"CurIntegraProdutosTransformacaoAux","Erro ao consultar produtos da entrada")
					Return .F.
				ENDIF


				Select CurIntegraLojaSaidasProduto
				Go TOP 
				SCAN
					SELECT CurIntegraProdutosTransformacao
					GO TOP 
					LOCATE FOR CurIntegraProdutosTransformacao.PRODUTO = CurIntegraLojaSaidasProduto.PRODUTO AND CurIntegraProdutosTransformacao.COR_PRODUTO = CurIntegraLojaSaidasProduto.COR_PRODUTO AND CurIntegraProdutosTransformacao.TIPO_MOV = 'SAIDA'
					IF  FOUND()
						_Liga = CurIntegraProdutosTransformacao.liga 
						nQtdeItem = CurIntegraLojaSaidasProduto.QTDE_SAIDA
						strTamanho = CurIntegraProdutosTransformacao.GRADE
						SELECT CurIntegraProdutosTransformacao
						GO TOP 
						LOCATE FOR CurIntegraProdutosTransformacao.TIPO_MOV = 'ENTRADA' AND CurIntegraProdutosTransformacao.LIGA = _Liga

						Select CurIntegraProdutosTamanhos
						Go Top
						Locate For Alltrim(CurIntegraLojaSaidasProduto.grade) == Alltrim(CurIntegraProdutosTamanhos.grade)
						Select CurIntegraLojaSaidasProduto
						For _k = 1 To CurIntegraProdutosTamanhos.numero_tamanhos
							__k = Transf(_k)
							If CurIntegraLojaSaidasProduto.EN&__k. > 0
								nQtdeItem = CurIntegraLojaSaidasProduto.EN&__k.
								strTamanho = CurIntegraProdutosTamanhos.Tamanho_&__k.
								
								IF CurIntegraLojaSaidasProduto.QTDE_SAIDA == 0
									MsgBox("Inconsistencia em informação de itens da saida. Produto "+CurIntegraLojaSaidasProduto.Produto+ " cor "+CurIntegraLojaSaidasProduto.cor_produto+;
											"\nQuantidade do item da saída não pode ser zero!",16,"Erro")
									Exit 
								Endif
								nValorItem = round(CurIntegraLojaSaidasProduto.VALOR/QTDE_SAIDA * nQtdeItem,2)
								If .Not. sqlExecute(strInsertItem,"Erro inserindo informações dos itens")
									bErroItens = .T.
									Exit 
								Endif
								nItem=nItem+1
							Endif
						Endfor
						
						IF bErroItens 
							Exit
						Endif


					ELSE 
						msgbox("Inconsistencia ao obter informação Produto de referencia!",16,"Erro")
						EXIT 
					ENDIF
					nItem=nItem+1
				ENDSCAN
				
				SELECT CurIntegraProdutosTransformacao
				SCAN
					IF CurIntegraProdutosTransformacao.tipo_mov = 'SAIDA'
						_Liga = CurIntegraProdutosTransformacao.liga
						SELECT CurIntegraProdutosTransformacaoAux
						LOCATE FOR CurIntegraProdutosTransformacaoAux.liga = _Liga AND CurIntegraProdutosTransformacaoAux.tipo_mov = 'ENTRADA'
						IF FOUND()

							TEXT TO sqlAlteraLojaNotaItem TEXTMERGE NOSHOW 
								UPDATE HR_SAP_LOJA_NOTA_ITEM SET 
									ref_produto = ?CurIntegraProdutosTransformacaoAux.PRODUTO, 
									ref_cor_produto = ?CurIntegraProdutosTransformacaoAux.COR_PRODUTO, 
									ref_tamanho = ?CurIntegraProdutosTransformacaoAux.GRADE
								WHERE
									chave_origem = ?strChaveOrigemSaida AND 
									produto = ?CurIntegraProdutosTransformacao.PRODUTO AND 
									cor_produto = ?CurIntegraProdutosTransformacao.COR_PRODUTO AND 
									tamanho = ?CurIntegraProdutosTransformacao.GRADE
							ENDTEXT
							
							If .Not. sqlExecute(sqlAlteraLojaNotaItem,"Erro alterando informações de referencia dos itens")
								bErroItens = .T.
								Exit 
							Endif							
						ENDIF 					
					ENDIF 					
				ENDSCAN 				
				
			ELSE 			
			
				Select CurIntegraLojaSaidasProduto
				Go Top
				Scan
					Select CurIntegraProdutosTamanhos
					Go Top
					Locate For Alltrim(CurIntegraLojaSaidasProduto.grade) == Alltrim(CurIntegraProdutosTamanhos.grade)
					Select CurIntegraLojaSaidasProduto
					For _k = 1 To CurIntegraProdutosTamanhos.numero_tamanhos
						__k = Transf(_k)
						If CurIntegraLojaSaidasProduto.EN&__k. > 0
							nQtdeItem = CurIntegraLojaSaidasProduto.EN&__k.
							strTamanho = CurIntegraProdutosTamanhos.Tamanho_&__k.
							IF CurIntegraLojaSaidasProduto.QTDE_SAIDA == 0
								MsgBox("Inconsistencia em informação de itens da saida. Produto "+CurIntegraLojaSaidasProduto.Produto+ " cor "+CurIntegraLojaSaidasProduto.cor_produto+;
										"\nQuantidade do item da saída não pode ser zero!",16,"Erro")
								Exit 
							Endif
							nValorItem = round(CurIntegraLojaSaidasProduto.VALOR/QTDE_SAIDA * nQtdeItem,2)
							If .Not. sqlExecute(strInsertItem,"Erro inserindo informações dos itens")
								bErroItens = .T.
								Exit 
							Endif
							nItem=nItem+1
						Endif
					Endfor
					
					IF bErroItens 
						Exit
					Endif
					Select CurIntegraLojaSaidasProduto
				ENDSCAN
			ENDIF 
					
			If bErroItens
				Main.Data.RollbackTransaction()
			Else
				*!* Fim - Vincula informacao da solicitacao de nota a venda

				*!* Commit e marca para chamar tela auxiliar
				IF .Not. bErroItens
					Main.Data.CommitTransaction()
					bRetornoOK = .t.
				Endif
			Endif
			*!* Fim - Inseri itens
		Else
			Main.Data.RollbackTransaction()
		Endif
	Catch To oException
		Main.Data.RollbackTransaction()
		MsgBox("Erro ao Criar solicitação de nota fiscal de saída.\nDetalhes: Linha: "+ Transf(oException.Lineno)+"  "+;
			"Mensagem: "+oException.Message+;
			"\nConteudo da Linha: "+Nvl(oException.LineContents,"{Nulo}"),16,"Erro grave")
	Finally
	Endtry
	
	If bRetornoOK
		Return strChaveOrigemSaida
	Endif

	Return ""
	
Endfunc

Function HrMergeLojaEntradas As Boolean
	parameters strFilial As String,strCodigoFilial As String,strRomaneioProduto As String,bJaValidouAlteracao as Boolean

	Public strChaveOrigemEntrada As String

	*!* Busca Dados	
	TEXT TO strSelectLojaEntradasProduto noshow
	Select 
		A.filial_origem
		,A.fornecedor
		,A.tipo_entrada_saida
		,B.CLIFOR AS CLIFOR_DESTINO
		,A.QTDE_TOTAL
	from loja_entradas a
	inner join cadastro_cli_for b on ISNULL(a.filial_origem,a.fornecedor) = b.nome_clifor
	where a.romaneio_produto = ?strRomaneioProduto and a.filial = ?strFilial
	endtext

	IF .Not. SqlSelect(strSelectLojaEntradasProduto ,"CurIntegraLojaEntradas","Erro ao consultar cabecalho da entradas")
		Return ""
	Endif
	
	TEXT TO strSelectLojaEntradasProduto noshow
	select A.ROMANEIO_PRODUTO,A.FILIAL,A.PRODUTO,A.COR_PRODUTO,A.QTDE_ENTRADA,
		A.PRECO1,A.PRECO2,A.PRECO3,A.PRECO4,A.VALOR,
		A.EN1,A.EN2,A.EN3,A.EN4,A.EN5,A.EN6,A.EN7,A.EN8,A.EN9,A.EN10,
		A.EN11,A.EN12,A.EN13,A.EN14,A.EN15,A.EN16,A.EN17,A.EN18,A.EN19,A.EN20,
		A.EN21,A.EN22,A.EN23,A.EN24,A.EN25,A.EN26,A.EN27,A.EN28,A.EN29,A.EN30,
		A.EN31,A.EN32,A.EN33,A.EN34,A.EN35,A.EN36,A.EN37,A.EN38,A.EN39,A.EN40,
		A.EN41,A.EN42,A.EN43,A.EN44,A.EN45,A.EN46,A.EN47,A.EN48,
		B.GRADE,B.PONTEIRO_PRECO_TAM,B.VARIA_PRECO_TAM
	from LOJA_ENTRADAS_PRODUTO A
	join PRODUTOS B ON A.PRODUTO = B.PRODUTO 	 
	where a.romaneio_produto = ?strRomaneioProduto and a.filial = ?strFilial
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectLojaEntradasProduto ,"CurIntegraLojaEntradasProduto","Erro ao consultar produtos da entrada")
		Return ""
	Endif
	
	TEXT TO strSelectProdutosTamanhos noshow
	select a.GRADE,a.NUMERO_TAMANHOS,
		a.TAMANHO_1,a.TAMANHO_2,a.TAMANHO_3,a.TAMANHO_4,a.TAMANHO_5,a.TAMANHO_6,
		a.TAMANHO_7,a.TAMANHO_8,a.TAMANHO_9,a.TAMANHO_10,a.TAMANHO_11,a.TAMANHO_12,
		a.TAMANHO_13,a.TAMANHO_14,a.TAMANHO_15,a.TAMANHO_16,a.TAMANHO_17,a.TAMANHO_18,
		a.TAMANHO_19,a.TAMANHO_20,a.TAMANHO_21,a.TAMANHO_22,a.TAMANHO_23,a.TAMANHO_24,
		a.TAMANHO_25,a.TAMANHO_26,a.TAMANHO_27,a.TAMANHO_28,a.TAMANHO_29,a.TAMANHO_30,
		a.TAMANHO_31,a.TAMANHO_32,a.TAMANHO_33,a.TAMANHO_34,a.TAMANHO_35,a.TAMANHO_36,
		a.TAMANHO_37,a.TAMANHO_38,a.TAMANHO_39,a.TAMANHO_40,a.TAMANHO_41,a.TAMANHO_42,
		a.TAMANHO_43,a.TAMANHO_44,a.TAMANHO_45,a.TAMANHO_46,a.TAMANHO_47,a.TAMANHO_48
	from produtos_tamanhos a	
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectProdutosTamanhos,"CurIntegraProdutosTamanhos","Erro ao consultar produtos da entrada")
		Return ""
	Endif
	*!* Fim - Busca Dados
	
	*!* Validacoes
	If Reccount("CurIntegraLojaEntradas")==0
		MsgBox("Erro ao gerar solicitação de nota. Entrada não encontrada na base de dados",16,"Erro")
		Return ""
	Endif
	If Reccount("CurIntegraLojaEntradasProduto")==0
		MsgBox("Erro ao gerar solicitação de nota. Não foram encontrados os itens da entrada na base de dados",16,"Erro")
		Return ""
	Endif
	
	Local strLetra As String,iHrSapLjProcesso As Integer
	iHrSapLjProcesso = GetHrSapLjProcessoEntradaSaida(Upper(Alltrim(CurIntegraLojaEntradas.tipo_entrada_saida)))
	strLetra = GetLetraHrSapLjProcesso(iHrSapLjProcesso)
	If Empty(Nvl(strLetra,""))
		MsgBox("Erro ao gerar solicitação de nota. Não foi possível definir tipo de nota, pelo tipo de entrada: "+Nvl(CurIntegraLojaEntradas.tipo_entrada_saida,"(Nulo)"),16,"Erro")
		Return ""
	ENDIF
	
	strChaveOrigemEntrada = strLetra + Padl(strCodigoFilial,6,"0")+strRomaneioProduto
	strChaveOrigemReferenciada = Null
	IF iHrSapLjProcesso == _HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO
		strChaveOrigemReferenciada  = GetLetraHrSapLjProcesso(_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO) + Padl(strCodigoFilial,6,"0")+strRomaneioProduto
	ENDIF 
	
	IF .Not. bJaValidouAlteracao
		If .Not. HrNfPermiteAlterar(strChaveOrigemEntrada )
			Return ""
		Endif
	Endif
	*!* Fim - Validacoes

	*!* Envia dados para tabela de notas fiscais
	TEXT TO strInsertCabecalho TEXTMERGE NOSHOW 
		IF exists(select TOP 1 1 from DBO.HR_SAP_LOJA_NOTA WHERE CHAVE_ORIGEM = ?strChaveOrigemEntrada)
			UPDATE dbo.HR_SAP_LOJA_NOTA
			SET CLIFOR_DESTINO = ?CurIntegraLojaEntradas.CLIFOR_DESTINO
				,INDICA_CLIENTE_OCASIONAL=0
				,CODIGO_CLIENTE=null
				,FINALIDADE_NF=1
				,MOVIMENTA_ESTOQUE=1
				,STATUS = 0
				,QTDE_TOTAL = ?CurIntegraLojaEntradas.QTDE_TOTAL
			WHERE CHAVE_ORIGEM = ?strChaveOrigemEntrada
		ELSE
			Insert Into dbo.HR_SAP_LOJA_NOTA
				(CHAVE_ORIGEM,HR_LJ_NF_PROCESSO,Status,SOLICITA_CANCELAMENTO,NF_NUMERO,SERIE_NF,CODIGO_FILIAL,CLIFOR_DESTINO
				,INDICA_CLIENTE_OCASIONAL,CODIGO_CLIENTE,TRANSPORTADORA,INDICA_TRANSPORTE_PROPRIO,OBS_NF,OBS_NF_AUTOMATICA 
				,TIPO_FRETE_LINX,FINALIDADE_NF,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,MOVIMENTA_ESTOQUE,NUMERO_VOLUME,QTDE_TOTAL,CHAVE_ORIGEM_REFERENCIA)
			Values (?strChaveOrigemEntrada,<<iHrSapLjProcesso>>,0,0,Null,Null,?strCodigoFilial,?CurIntegraLojaEntradas.CLIFOR_DESTINO
				,0,Null,Null,0,Null,Null
				,Null,1,Null,Null,1,0,?CurIntegraLojaEntradas.QTDE_TOTAL,?strChaveOrigemReferenciada)	
	ENDTEXT
		
	TEXT TO strDeleteItem TEXTMERGE NOSHOW 
		DELETE FROM dbo.HR_SAP_LOJA_NOTA_ITEM WHERE CHAVE_ORIGEM = ?strChaveOrigemEntrada
	ENDTEXT

	IF INLIST(iHrSapLjProcesso,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO)
		*!* Insert para notas de Transformacao de produto.	
		TEXT TO strInsertItem TEXTMERGE NOSHOW 
			Insert Into dbo.HR_SAP_LOJA_NOTA_ITEM
			(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
			ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE, 
			REF_PRODUTO, REF_COR_PRODUTO, REF_TAMANHO )
			Values (?strChaveOrigemEntrada,?nItem,1,?CurIntegraLojaEntradasProduto.PRODUTO,?CurIntegraLojaEntradasProduto.COR_PRODUTO,?strTamanho,
			NULL,?nQtdeItem,?nValorItem,NULL,NULL,
			?CurIntegraProdutosTransformacao.PRODUTO,?CurIntegraProdutosTransformacao.COR_PRODUTO,?CurIntegraProdutosTransformacao.Grade)
		ENDTEXT
	ELSE 
		*!* Insert para demais notas 
		TEXT TO strInsertItem TEXTMERGE NOSHOW 
			Insert Into dbo.HR_SAP_LOJA_NOTA_ITEM
			(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
			ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE )
			Values (?strChaveOrigemEntrada,?nItem,1,?CurIntegraLojaEntradasProduto.PRODUTO,?CurIntegraLojaEntradasProduto.COR_PRODUTO,?strTamanho,
			NULL,?nQtdeItem,?nValorItem,NULL,NULL)
		ENDTEXT
	ENDIF

	Local bRetornoOK as Boolean
	bRetornoOK = .f.
	main.data.BeginTransaction()
	Try
		If sqlExecute(strInsertCabecalho,"Erro inserindo informações do cabeçalho") .And.;
			sqlExecute(strDeleteItem,"Erro limpando informações anteriores")
			
			*!* Inseri itens
			Local bErroItens As Boolean
			bErroItens = .F.
			nItem=1

			IF INLIST(iHrSapLjProcesso,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO)
				*!* Monta itens para notas de Transformacao de produto.	
				TEXT TO sqlSelecionaProdutoTransformacao TEXTMERGE NOSHOW 
					SELECT 
						TIPO_MOV,NUMERO_ROMANEIO,FILIAL,PRODUTO,COR_PRODUTO,TAMANHO,
						GRADE,GRADE_PRO,CODIGO_BARRA,QTDE,LIGA 
					FROM 
						HR_SAP_CONVERSAO_KILO 
					WHERE 
						HR_SAP_CONVERSAO_KILO.NUMERO_ROMANEIO = ?strRomaneioProduto 
						AND HR_SAP_CONVERSAO_KILO.FILIAL =  ?strFilial
				ENDTEXT

				IF .Not. SqlSelect(sqlSelecionaProdutoTransformacao,"CurIntegraProdutosTransformacao","Erro ao consultar produtos da entrada")
					Return .F.
				ENDIF

				IF .Not. SqlSelect(sqlSelecionaProdutoTransformacao,"CurIntegraProdutosTransformacaoAux","Erro ao consultar produtos da entrada")
					Return .F.
				ENDIF

				Select CurIntegraLojaEntradasProduto
				Go TOP 
				SCAN
					
					SELECT CurIntegraProdutosTransformacao
					GO TOP 
					LOCATE FOR CurIntegraProdutosTransformacao.PRODUTO = CurIntegraLojaEntradasProduto.PRODUTO AND CurIntegraProdutosTransformacao.COR_PRODUTO = CurIntegraLojaEntradasProduto.COR_PRODUTO AND CurIntegraProdutosTransformacao.TIPO_MOV = 'ENTRADA'
					IF  FOUND()
						_Liga = CurIntegraProdutosTransformacao.liga 
						nQtdeItem = CurIntegraLojaEntradasProduto.QTDE_ENTRADA
						strTamanho = CurIntegraProdutosTransformacao.GRADE
					
						SELECT CurIntegraProdutosTransformacao
						GO TOP 
						LOCATE FOR CurIntegraProdutosTransformacao.TIPO_MOV = 'SAIDA' AND CurIntegraProdutosTransformacao.LIGA = _Liga
						Select CurIntegraProdutosTamanhos
						Go Top
						Locate For Alltrim(CurIntegraLojaEntradasProduto.grade) == Alltrim(CurIntegraProdutosTamanhos.grade)
						Select CurIntegraLojaEntradasProduto
						For _k = 1 To CurIntegraProdutosTamanhos.numero_tamanhos
							__k = Transf(_k)
							If CurIntegraLojaEntradasProduto.EN&__k. > 0
								nQtdeItem = CurIntegraLojaEntradasProduto.EN&__k.
								strTamanho = CurIntegraProdutosTamanhos.Tamanho_&__k.
								IF CurIntegraLojaEntradasProduto.QTDE_ENTRADA == 0
									MsgBox("Inconsistencia em informação de itens da saida. Produto "+CurIntegraLojaEntradasProduto.Produto+ " cor "+CurIntegraLojaEntradasProduto.cor_produto+;
											"\nQuantidade do item da saída não pode ser zero!",16,"Erro")
									Exit 
								Endif
								nValorItem = round(CurIntegraLojaEntradasProduto.VALOR/QTDE_ENTRADA * nQtdeItem,2)
								If .Not. sqlExecute(strInsertItem,"Erro inserindo informações dos itens")
									bErroItens = .T.
									Exit 
								Endif
								nItem=nItem+1
							Endif
						Endfor
						
						IF bErroItens 
							Exit
						Endif
					ELSE 
						msgbox("Inconsistencia ao obter informação Produto de referencia!",16,"Erro")
						EXIT 
					ENDIF
					nItem=nItem+1
				ENDSCAN 

				SELECT CurIntegraProdutosTransformacao
				SCAN
					IF CurIntegraProdutosTransformacao.tipo_mov = 'ENTRADA'
						_Liga = CurIntegraProdutosTransformacao.liga
						SELECT CurIntegraProdutosTransformacaoAux
						LOCATE FOR CurIntegraProdutosTransformacaoAux.liga = _Liga AND CurIntegraProdutosTransformacaoAux.tipo_mov = 'SAIDA'
						IF FOUND()

							TEXT TO sqlAlteraLojaNotaItem TEXTMERGE NOSHOW 
								UPDATE HR_SAP_LOJA_NOTA_ITEM SET 
									ref_produto = ?CurIntegraProdutosTransformacaoAux.PRODUTO, 
									ref_cor_produto = ?CurIntegraProdutosTransformacaoAux.COR_PRODUTO, 
									ref_tamanho = ?CurIntegraProdutosTransformacaoAux.GRADE
								WHERE
									chave_origem = ?strChaveOrigemEntrada AND 
									produto = ?CurIntegraProdutosTransformacao.PRODUTO AND 
									cor_produto = ?CurIntegraProdutosTransformacao.COR_PRODUTO AND 
									tamanho = ?CurIntegraProdutosTransformacao.GRADE
							ENDTEXT
							
							If .Not. sqlExecute(sqlAlteraLojaNotaItem,"Erro alterando informações de referencia dos itens")
								bErroItens = .T.
								Exit 
							Endif							
						ENDIF 					
					ENDIF 					
				ENDSCAN 
				
			ELSE 
				Select CurIntegraLojaEntradasProduto
				Go Top
				Scan
					Select CurIntegraProdutosTamanhos
					Go Top
					Locate For Alltrim(CurIntegraLojaEntradasProduto.grade) == Alltrim(CurIntegraProdutosTamanhos.grade)
					Select CurIntegraLojaEntradasProduto
					For _k = 1 To CurIntegraProdutosTamanhos.numero_tamanhos
						__k = Transf(_k)
						If CurIntegraLojaEntradasProduto.EN&__k. > 0
							nQtdeItem = CurIntegraLojaEntradasProduto.EN&__k.
							strTamanho = CurIntegraProdutosTamanhos.Tamanho_&__k.
							IF CurIntegraLojaEntradasProduto.QTDE_ENTRADA == 0
								MsgBox("Inconsistencia em informação de itens da entrada. Produto "+CurIntegraLojaEntradasProduto.Produto+ " cor "+CurIntegraLojaEntradasProduto.cor_produto+;
										"\nQuantidade do item da entrada não pode ser zero!",16,"Erro")
								Exit 
							Endif
							nValorItem = round(CurIntegraLojaEntradasProduto.VALOR/QTDE_ENTRADA * nQtdeItem,2)
							If .Not. sqlExecute(strInsertItem,"Erro inserindo informações dos itens")
								bErroItens = .T.
								Exit 
							Endif
							nItem=nItem+1
						Endif
					Endfor
					
					IF bErroItens 
						Exit
					Endif
					Select CurIntegraLojaEntradasProduto
				Endscan
			ENDIF 		
			If bErroItens
				Main.Data.RollbackTransaction()
			Else
				*!* Fim - Vincula informacao da solicitacao de nota a venda

				*!* Commit e marca para chamar tela auxiliar
				IF .Not. bErroItens
					Main.Data.CommitTransaction()
					bRetornoOK = .t.
				Endif
			Endif
			*!* Fim - Inseri itens
		Else
			Main.Data.RollbackTransaction()
		Endif
	Catch To oException
		Main.Data.RollbackTransaction()
		MsgBox("Erro ao Criar solicitação de nota fiscal de entrada.\nDetalhes: Linha: "+ Transf(oException.Lineno)+"  "+;
			"Mensagem: "+oException.Message+;
			"\nConteudo da Linha: "+Nvl(oException.LineContents,"{Nulo}"),16,"Erro grave")
	Finally
	Endtry
	
	If bRetornoOK
		Return strChaveOrigemEntrada
	Endif

	Return ""
	
Endfunc

Function HrNfGerarProcessoInverso as Boolean
	parameters strChaveOrigem As Integer,intHrLjProcesso As Integer
	
	Local strMsgJaExiste As String,iOldAlias as Integer,bRetorno as Boolean
	iOldAlias = Select()
	strMsgJaExiste = ""
	bRetorno = .f.
	
	IF .Not. SqlSelect("Select top 1 nf_numero,serie_nf from HR_SAP_LOJA_NOTA WHERE CHAVE_ORIGEM_REFERENCIA=?strChaveOrigem","CurExisteOrigem","Erro verificando se chave origem ja foi referencia da em outra nota")
		Return .f.
	Endif
	
	If Reccount("CurExisteOrigem")>0
		Select CurExisteOrigem
		Go Top
		If Empty(Nvl(CurExisteOrigem.nf_numero,""))
			strMsgJaExiste = "Esta nota fiscal já foi usada para um processo inverso anteriormente."
		Else
			strMsgJaExiste = "Esta nota fiscal já foi usada para um processo inverso anteriormente. Nf "+Nvl(CurExisteOrigem.nf_numero,"")+" Serie "+Nvl(CurExisteOrigem.serie_nf,"")
		Endif
	Endif
	
	* Fecha cursor
	Use in Select ("CurExisteOrigem")
	
	If .Not. Empty(strMsgJaExiste )
		MsgBox(strMsgJaExiste ,64,"Atenção")
		Select(iOldAlias)
		Return .F.
	Endif
	
	Do Case
		Case Inlist(intHrLjProcesso,_HR_LJ_PROCESSO_VENDA_CUPOM)
			bRetorno = HrNfGerarProcessoInversoVenda(strChaveOrigem,intHrLjProcesso )

		Case Inlist(intHrLjProcesso,_HR_LJ_PROCESSO_BRINDE,_HR_LJ_PROCESSO_BONIFICACAO,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO,_HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA,_HR_LJ_PROCESSO_TRANSFERENCIA_NORMAL)
			bRetorno = HrNfGerarProcessoInversoSaida(strChaveOrigem,intHrLjProcesso)

		Case Inlist(intHrLjProcesso,_HR_LJ_PROCESSO_REMESSA_LOJA_REFORMA)
			bRetorno = HrNfGerarProcessoInversoReforma(strChaveOrigem,intHrLjProcesso)
		Otherwise
			MsgBox("Este tipo de processo não possui um processo inverso automático",16,"Erro")
			bRetorno = .f.
	Endcase
	
	Select(iOldAlias)
	Return bRetorno 

Endfunc

Function HrNfGerarProcessoInversoVenda
	parameters strChaveOrigem As Integer,intHrLjProcesso As Integer
	
	Local strPesquisaCabecalho As String,strPesquisaItem As String,strPesquisaCliente As String,;
			strInsertCabecalho as String,strInsertItem as String,strLetraInverso as String
			
	public strChaveOrigemInverso as String,intHrLjNfProcessoInverso as Integer

	*!* Defini tipo do processo inverso
	intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_RETORNO_CUPOM
	*!* Fim - Defini tipo do processo inverso
	
	*!* Monta chave inversa
	strLetraInverso = GetLetraHrSapLjProcesso(intHrLjNfProcessoInverso)
	
	*!* se nao conseguir formar a chave inversa, cancela e mostra mensagem de erro
	If Empty(Nvl(strLetraInverso,""))
		MsgBox("Erro ao definir codigo do processo inverso (letra não encontrada). Processo %v",16,"Erro",intHrLjNfProcessoInverso)
		Return .F.
	Endif
	
	*!* Gera chave inversa com a primeira letra do processo inverso e copia o restante da cahve origem referenciada 
	strChaveOrigemInverso = strLetraInverso  + Substr(strChaveOrigem ,2)
	*!* Fim - Monta chave inversa
	
	*!* Carrega Cursores das Notas
	IF .Not. LoadCursorCopyNotaFotografia(strChaveOrigem)
		Return .f.
	Endif
	*!* Fim - Carrega Cursores das Notas
	
	Local bErro As Boolean
	bErro = .F.
	Select CurNotaCopy
	Go Top

	Main.Data.BeginTransaction()

	IF .Not. InsertSqlNotaInversa(strChaveOrigemInverso,intHrLjNfProcessoInverso,strChaveOrigem)
		Main.Data.LastError = Message()
		Main.Data.RollbackTransaction() && Rollback antes da mensagem de erro
		MsgBox("Erro ao inserir infromações da nota Inversa.\n\n%v",48,"Atenção",Main.Data.LastError) && mostra erro sql
		bErro = .t.
	Endif
	
	*!* Se nao ocorreram erros executa comando para retirar relacao entre a venda e a solicitacao de notas fiscais
	if .Not. HrRetiraVinculoNotaVenda(strChaveOrigem)
		bErro = .t.
	Endif
	
	If .Not. bErro && caso nao ocorram erros comita a transacao
		Main.Data.CommitTransaction()
	Endif
	
	If .Not. bErro
		ShowProgress("Enviando informações para a Retaguarda...")
		If HrNfEnviarDados(strChaveOrigemInverso)
			MsgBox("Gerado com sucesso e enviado para a retaguarda!",64,"Informação")
		Else
			MsgBox("Gerado com sucesso porém não foi possível enviar para a retaguarda, verifique!",64,"Informação")
		Endif
	Endif

	Release strChaveOrigemInverso , intHrLjNfProcessoInverso
	
	Return (.Not.bErro)
Endfunc

Function HrNfGerarProcessoInversoSaida
	parameters strChaveOrigem As Integer,intHrLjProcesso As Integer

	public strRomaneioProdutoSaida as String,strCodigoFilialSaida as String,;
			strRomaneioProdutoEntrada as String,strTipoEntradaSaidaInverso as String;
			strChaveOrigemInverso as String,intHrLjNfProcessoInverso as Integer

	strCodigoFilialSaida = transf(Cast(Substr(strChaveOrigem,2,6) as int))
	strRomaneioProdutoSaida = Substr(strChaveOrigem,8)
	strRomaneioProdutoEntrada = "X"+Substr(strRomaneioProdutoSaida,2) && Gera romaneio da entrada com base no romaneio da saida
	
	Local strPesquisaCabecalho As String,strPesquisaItem  As String,strSelectSaida As String,strSelectSaidaItens As String , ;
		strInsertCabecalho As String,strInsertItem As String,strInsertLojaEntradas As String,strInsertLojaEntradasProduto As String

	*!* Defini tipo do processo inverso
	Do Case
		Case intHrLjProcesso == _HR_LJ_PROCESSO_BRINDE
			intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_RETORNO_BRINDE
		Case intHrLjProcesso == _HR_LJ_PROCESSO_BONIFICACAO
			intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_RETORNO_BONIFICACAO
		Case intHrLjProcesso == _HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA
			intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_RETORNO_FOTOGRAFIA
		Case intHrLjProcesso == _HR_LJ_PROCESSO_SAIDA_UNIFORME
			intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_OUTRAS_ENTRADAS
		Otherwise
			MsgBox("Esta Saída não possuí processo inverso automático.\n\nDeverá ser feito o processo inverso manualmente",48,"Atenção")
			Return .F.
	Endcase
	*!* Fim - Defini tipo do processo inverso
	
	*!* Monta chave inversa
	strLetraInverso = GetLetraHrSapLjProcesso(intHrLjNfProcessoInverso )
	*!* se nao conseguir formar a chave inversa, cancela e mostra mensagem de erro
	If Empty(Nvl(strLetraInverso,""))
		MsgBox("Erro ao definir codigo do processo inverso (letra não encontrada). Processo %v",16,"Erro",intHrLjNfProcessoInverso)
		Return .F.
	Endif
	*!* Gera chave inversa com a primeira letra do processo inverso e copia o restante da cahve origem referenciada 
	
	strChaveOrigemInverso = strLetraInverso  + Substr( strChaveOrigem ,2)
	*!* Fim - Monta chave inversa
		
	*!* Busca configuracao do tipo entrada e saida para o processo inverso
	strTipoEntradaSaidaInverso = GetEntradaSaidaHrSapLjProcesso(intHrLjNfProcessoInverso)
	*!* se nao conseguir formar a chave inversa, cancela e mostra mensagem de erro
	If Empty(Nvl(strTipoEntradaSaidaInverso ,""))
		MsgBox("Não existe um TIPO_ENTRADA_SAIDA configurado para este tipo de processo inverso. Processo %v",16,"Erro",intHrLjNfProcessoInverso)
		Return .F.
	Endif
	*!* Gera chave inversa com a primeira letra do processo inverso e copia o restante da cahve origem referenciada 
	*!* Fim - Busca configuracao do tipo entrada e saida para o processo inverso
	
	TEXT TO strSelectSaida NOSHOW TEXTMERGE
	select LOJA_SAIDAS.ROMANEIO_PRODUTO
		,LOJA_SAIDAS.FILIAL
		,LOJA_SAIDAS.CODIGO_TAB_PRECO
		,LOJA_SAIDAS.TIPO_ENTRADA_SAIDA
		,LOJA_SAIDAS.FILIAL_DESTINO
		,LOJA_SAIDAS.RESPONSAVEL
		,LOJA_SAIDAS.INDICA_DEVOLUCAO
		,LOJA_SAIDAS.FORNECEDOR_DEVOLUCAO
		,LOJA_SAIDAS.EMISSAO
		,LOJA_SAIDAS.OBS
		,LOJA_SAIDAS.QTDE_TOTAL
		,LOJA_SAIDAS.VALOR_TOTAL
		,LOJA_SAIDAS.FATOR_PRECO
		,LOJA_SAIDAS.SAIDA_ENCERRADA
		,LOJA_SAIDAS.SAIDA_CANCELADA
	from LOJA_SAIDAS
		JOIN LOJAS_VAREJO
			ON LOJA_SAIDAS.FILIAL = LOJAS_VAREJO.FILIAL
	where LOJA_SAIDAS.ROMANEIO_PRODUTO = ?strRomaneioProdutoSaida
		and LOJAS_VAREJO.CODIGO_FILIAL = ?strCodigoFilialSaida 
	ENDTEXT
	
	TEXT TO SstrSelectSaidaItens  NOSHOW TEXTMERGE
	SELECT LOJA_SAIDAS_PRODUTO.ROMANEIO_PRODUTO
			,LOJA_SAIDAS_PRODUTO.FILIAL
			,LOJA_SAIDAS_PRODUTO.PRODUTO
			,LOJA_SAIDAS_PRODUTO.COR_PRODUTO
			,LOJA_SAIDAS_PRODUTO.QTDE_SAIDA
			,LOJA_SAIDAS_PRODUTO.PRECO1,LOJA_SAIDAS_PRODUTO.PRECO2,LOJA_SAIDAS_PRODUTO.PRECO3,LOJA_SAIDAS_PRODUTO.PRECO4
			,LOJA_SAIDAS_PRODUTO.VALOR
			,LOJA_SAIDAS_PRODUTO.EN1,LOJA_SAIDAS_PRODUTO.EN2,LOJA_SAIDAS_PRODUTO.EN3,LOJA_SAIDAS_PRODUTO.EN4
			,LOJA_SAIDAS_PRODUTO.EN5,LOJA_SAIDAS_PRODUTO.EN6,LOJA_SAIDAS_PRODUTO.EN7,LOJA_SAIDAS_PRODUTO.EN8
			,LOJA_SAIDAS_PRODUTO.EN9,LOJA_SAIDAS_PRODUTO.EN10,LOJA_SAIDAS_PRODUTO.EN11,LOJA_SAIDAS_PRODUTO.EN12
			,LOJA_SAIDAS_PRODUTO.EN13,LOJA_SAIDAS_PRODUTO.EN14,LOJA_SAIDAS_PRODUTO.EN15,LOJA_SAIDAS_PRODUTO.EN16
			,LOJA_SAIDAS_PRODUTO.EN17,LOJA_SAIDAS_PRODUTO.EN18,LOJA_SAIDAS_PRODUTO.EN19,LOJA_SAIDAS_PRODUTO.EN20
			,LOJA_SAIDAS_PRODUTO.EN21,LOJA_SAIDAS_PRODUTO.EN22,LOJA_SAIDAS_PRODUTO.EN23,LOJA_SAIDAS_PRODUTO.EN24
			,LOJA_SAIDAS_PRODUTO.EN25,LOJA_SAIDAS_PRODUTO.EN26,LOJA_SAIDAS_PRODUTO.EN27,LOJA_SAIDAS_PRODUTO.EN28
			,LOJA_SAIDAS_PRODUTO.EN29,LOJA_SAIDAS_PRODUTO.EN30,LOJA_SAIDAS_PRODUTO.EN31,LOJA_SAIDAS_PRODUTO.EN32
			,LOJA_SAIDAS_PRODUTO.EN33,LOJA_SAIDAS_PRODUTO.EN34,LOJA_SAIDAS_PRODUTO.EN35,LOJA_SAIDAS_PRODUTO.EN36
			,LOJA_SAIDAS_PRODUTO.EN37,LOJA_SAIDAS_PRODUTO.EN38,LOJA_SAIDAS_PRODUTO.EN39,LOJA_SAIDAS_PRODUTO.EN40
			,LOJA_SAIDAS_PRODUTO.EN41,LOJA_SAIDAS_PRODUTO.EN42,LOJA_SAIDAS_PRODUTO.EN43,LOJA_SAIDAS_PRODUTO.EN44
			,LOJA_SAIDAS_PRODUTO.EN45,LOJA_SAIDAS_PRODUTO.EN46,LOJA_SAIDAS_PRODUTO.EN47,LOJA_SAIDAS_PRODUTO.EN48
	from LOJA_SAIDAS_PRODUTO
		JOIN LOJAS_VAREJO
			ON LOJA_SAIDAS_PRODUTO.FILIAL = LOJAS_VAREJO.FILIAL
	where LOJA_SAIDAS_PRODUTO.ROMANEIO_PRODUTO = ?strRomaneioProdutoSaida
		and LOJAS_VAREJO.CODIGO_FILIAL = ?strCodigoFilialSaida 
	ENDTEXT 
		
	If .Not. sqlSelect(strSelectSaida ,"CurSaidaCopy","Erro pesquisando informações da saída para geração da nota fiscal inversa")
		Return .F.
	Endif
	If .Not. sqlSelect(SstrSelectSaidaItens  ,"CurSaidaItemCopy","Erro pesquisando informações dos itens da Saída para geração da nota fiscal inversa")
		Return .F.
	Endif	
	
	*!* Verifica se encontrou informacoes
	If Reccount("CurSaidaCopy")==0
		MsgBox("Não foram encontradas informações da saída para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif
	If Reccount("CurSaidaCopy")==0
		MsgBox("Não foram encontradas informações dos itens da saída para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif
	*!* Fim - Verifica se encontrou informacoes
		
	TEXT TO strInsertLojaEntradas NOSHOW TEXTMERGE
		INSERT INTO LOJA_ENTRADAS 
			(ROMANEIO_PRODUTO,FILIAL,CODIGO_TAB_PRECO,TIPO_ENTRADA_SAIDA
			,FILIAL_ORIGEM,NUMERO_NF_TRANSFERENCIA,ROMANEIO_NF_SAIDA,FORNECEDOR
			,RESPONSAVEL,EMISSAO,DATA_SAIDA,DESC_TIPO_ENTRADA_SAIDA
			,OBS,ENTRADA_CONFERIDA,ENTRADA_SEM_PRODUTOS,QTDE_TOTAL
			,VALOR_TOTAL,FATOR_PRECO,STATUS_TRANSITO,QTDE_NAO_CONFERIDA,VALOR_NAO_CONFERIDO
			,ENTRADA_POR,CGC_FORNECEDOR,PEDIDO_STATUS_LOJA,DATA_BAIXA_PEDIDO
			,ENTRADA_ENCERRADA,DATA_PARA_TRANSFERENCIA,SERIE_NF_ENTRADA,ENTRADA_CANCELADA
			)
		values 
			(?strRomaneioProdutoEntrada,?CurSaidaCopy.FILIAL_DESTINO,?CurSaidaCopy.CODIGO_TAB_PRECO,?strTipoEntradaSaidaInverso
			,?CurSaidaCopy.FILIAL,'',?CurSaidaCopy.NUMERO_NF_TRANSFERENCIA,null
			,?CurSaidaCopy.RESPONSAVEL,?CurSaidaCopy.EMISSAO,?main.Date,''
			,'Entrada gerada pelo processo inverso de um saída',1,0,?CurSaidaCopy.QTDE_TOTAL
			,?CurSaidaCopy.VALOR_TOTAL,1,3,0,0
			,1,NULL,NULL,NULL
			,1,getdate(),?CurSaidaCopy.SERIE_NF,0
			)			
	ENDTEXT
	
	TEXT TO strInsertLojaEntradasProduto NOSHOW TEXTMERGE
		INSERT INTO dbo.LOJA_ENTRADAS_PRODUTO
			(FILIAL,ROMANEIO_PRODUTO,PRODUTO,COR_PRODUTO
			,EN1,EN2,EN3,EN4,EN5,EN6,EN7,EN8,EN9,EN10
			,EN11,EN12,EN13,EN14,EN15,EN16,EN17,EN18,EN19,EN20
			,EN21,EN22,EN23,EN24,EN25,EN26,EN27,EN28,EN29,EN30
			,EN31,EN32,EN33,EN34,EN35,EN36,EN37,EN38,EN39,EN40
			,EN41,EN42,EN43,EN44,EN45,EN46,EN47,EN48
			,VALOR,PRECO1,PRECO2,PRECO3,PRECO4
			,QTDE_ENTRADA,DATA_PARA_TRANSFERENCIA)
		VALUES 
			(?CurSaidaCopy.FILIAL_DESTINO,?strRomaneioProdutoEntrada,?CurSaidaItemCopy.PRODUTO,?CurSaidaItemCopy.COR_PRODUTO
			,?CurSaidaItemCopy.EN1,?CurSaidaItemCopy.EN2,?CurSaidaItemCopy.EN3,?CurSaidaItemCopy.EN4
			,?CurSaidaItemCopy.EN5,?CurSaidaItemCopy.EN6,?CurSaidaItemCopy.EN7,?CurSaidaItemCopy.EN8
			,?CurSaidaItemCopy.EN9,?CurSaidaItemCopy.EN10,?CurSaidaItemCopy.EN11,?CurSaidaItemCopy.EN12
			,?CurSaidaItemCopy.EN13,?CurSaidaItemCopy.EN14,?CurSaidaItemCopy.EN15,?CurSaidaItemCopy.EN16
			,?CurSaidaItemCopy.EN17,?CurSaidaItemCopy.EN18,?CurSaidaItemCopy.EN19,?CurSaidaItemCopy.EN20
			,?CurSaidaItemCopy.EN21,?CurSaidaItemCopy.EN22,?CurSaidaItemCopy.EN23,?CurSaidaItemCopy.EN24
			,?CurSaidaItemCopy.EN25,?CurSaidaItemCopy.EN26,?CurSaidaItemCopy.EN27,?CurSaidaItemCopy.EN28
			,?CurSaidaItemCopy.EN29,?CurSaidaItemCopy.EN30,?CurSaidaItemCopy.EN31,?CurSaidaItemCopy.EN32
			,?CurSaidaItemCopy.EN33,?CurSaidaItemCopy.EN34,?CurSaidaItemCopy.EN35,?CurSaidaItemCopy.EN36
			,?CurSaidaItemCopy.EN37,?CurSaidaItemCopy.EN38,?CurSaidaItemCopy.EN39,?CurSaidaItemCopy.EN40
			,?CurSaidaItemCopy.EN41,?CurSaidaItemCopy.EN42,?CurSaidaItemCopy.EN43,?CurSaidaItemCopy.EN44
			,?CurSaidaItemCopy.EN45,?CurSaidaItemCopy.EN46,?CurSaidaItemCopy.EN47,?CurSaidaItemCopy.EN48
			,?CurSaidaItemCopy.VALOR,?CurSaidaItemCopy.PRECO1,?CurSaidaItemCopy.PRECO2,?CurSaidaItemCopy.PRECO3,?CurSaidaItemCopy.PRECO4
			,?CurSaidaItemCopy.QTDE_SAIDA,getdate())	
	ENDTEXT
	
	*!* Carrega Cursores das Notas
	IF .Not. LoadCursorCopyNotaFotografia(strChaveOrigem)
		Return .f.
	Endif
	*!* Fim - Carrega Cursores das Notas
	Local bErro As Boolean
	bErro = .F.
	Select CurNotaCopy
	Go Top

	Main.Data.BeginTransaction()
	
	IF .Not. InsertSqlNotaInversa(strChaveOrigemInverso,intHrLjNfProcessoInverso,strChaveOrigem)
		Main.Data.RollbackTransaction() && Rollback antes da mensagem de erro
		MsgBox("Erro ao inserir infromações da nota Inversa.\n\n%v",48,"Atenção",Main.Data.LastError) && mostra erro sql
		bErro = .t.
	Endif
	
	IF .Not. SQLExecute(strInsertLojaEntradas)
		Main.Data.LastError = Message()
		Main.Data.RollbackTransaction() && Rollback antes da mensagem de erro
		MsgBox("Erro ao inserir infromações da nova Entrada.\n\n%v",48,"Atenção",Main.Data.LastError) && mostra erro sql
		bErro = .t.
	Endif
	
	IF .Not. bErro
		Select CurSaidaItemCopy
		Go Top
		Scan
			If .Not. SQLExecute(strInsertLojaEntradasProduto)
				Main.Data.LastError = Message()
				Main.Data.RollbackTransaction() && Rollback antes da mensagem de erro
				MsgBox("Erro ao inserir infromações dos itens da nova Entrada.\n\n%v",48,"Atenção",Main.Data.LastError) && mostra erro sql
				bErro = .T.
			Endif

			Select CurSaidaItemCopy
		Endscan
	Endif
	*!* Rever - Cade insert do loja entradas?
		
	If .Not. bErro && caso nao ocorram erros comita a transacao
		Main.Data.CommitTransaction()
	Endif
		
	If .Not. bErro
		ShowProgress("Enviando informações para a Retaguarda...")
		If HrNfEnviarDados(strChaveOrigemInverso)
			MsgBox("Gerado com sucesso e enviado para a retaguarda!",64,"Informação")
		Else
			MsgBox("Gerado com sucesso porém não foi possível enviar para a retaguarda, verifique!",64,"Informação")
		Endif
	Endif
	
	Release strChaveOrigemInverso , intHrLjNfProcessoInverso
	
	Return (.Not.bErro)
Endfunc

Function HrNfGerarProcessoInversoReforma
	parameters strChaveOrigem As Integer,intHrLjProcesso As Integer

	Local strPesquisaCabecalho As String,strInsertCabecalho as String,strLetraInverso as String
	
	Public strChaveOrigemInverso as String,intHrLjNfProcessoInverso as Integer

	*!* Defini tipo do processo inverso
	intHrLjNfProcessoInverso = _HR_LJ_PROCESSO_RETORNO_LOJA_REFORMA
	*!* Fim - Defini tipo do processo inverso
	
	
	strLetraInverso = GetLetraHrSapLjProcesso(intHrLjNfProcessoInverso)
	
	*!* Se nao conseguir formar a chave inversa, cancela e mostra mensagem de erro
	If Empty(Nvl(strLetraInverso,""))
		MsgBox("Erro ao definir codigo do processo inverso (letra não encontrada). Processo %v",16,"Erro",intHrLjNfProcessoInverso)
		Return .F.
	ENDIF
	
	*!* Gera chave inversa com a primeira letra do processo inverso e copia o restante da cahve origem referenciada 
	strChaveOrigemInverso = strLetraInverso  + Substr(strChaveOrigem ,2)
	*!* Fim - Monta chave inversa

	*!* Carrega Cursores das Notas
	IF .Not. LoadCursorCopyNota(strChaveOrigem,intHrLjProcesso)
		Return .f.
	ELSE
		*** Referencia a Nota e Apaga a Observação da Origem
		Select CurNotaCopy
		Go Top
		REPLACE CurNotaCopy.NFE_REFERENCIADA WITH CurNotaCopy.NF_NUMERO
		REPLACE CurNotaCopy.SERIE_NF_REFERENCIADA WITH CurNotaCopy.SERIE_NF
		REPLACE CurNotaCopy.OBS_NF WITH []
	Endif
	*!* Fim - Carrega Cursores das Notas
	
	Local bErro As Boolean
	bErro = .F.
	
	Select CurNotaCopy
	Go Top
	
	Main.Data.BeginTransaction()

	IF .Not. InsertSqlNotaInversa(strChaveOrigemInverso,intHrLjNfProcessoInverso,strChaveOrigem)
		Main.Data.LastError = Message()
		Main.Data.RollbackTransaction() && Rollback antes da mensagem de erro
		MsgBox("Erro ao inserir infromações da nota Inversa.\n\n%v",48,"Atenção",Main.Data.LastError) && mostra erro sql
		bErro = .t.
	Endif

	If .Not. bErro && caso nao ocorram erros comita a transacao
		Main.Data.CommitTransaction()
	ENDIF
	
	If .Not. bErro
		ShowProgress("Enviando informações para a Retaguarda...")
		If HrNfEnviarDados(strChaveOrigemInverso)
			MsgBox("Gerado com sucesso e enviado para a retaguarda!",64,"Informação")
		Else
			MsgBox("Gerado com sucesso porém não foi possível enviar para a retaguarda, verifique!",64,"Informação")
		Endif
	Endif

	Release strChaveOrigemInverso , intHrLjNfProcessoInverso
	
	Return (.Not.bErro)
Endfunc



*!* Copia Nota Global
Function LoadCursorCopyNota As Boolean
	Parameters strChaveOrigemBase As String, intHrLjProcesso as Integer


	TEXT TO strPesquisaCabecalho NOSHOW TEXTMERGE
	SELECT CODIGO_LINX,CHAVE_ORIGEM,HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,STATUS,SOLICITA_CANCELAMENTO,NF_NUMERO,SERIE_NF
		,EMISSAO_NF,CODIGO_FILIAL,CLIFOR_DESTINO,CODIGO_CLIENTE,INDICA_CLIENTE_OCASIONAL
		,INDICA_TRANSPORTE_PROPRIO,OBS_NF,TIPO_FRETE_LINX,FINALIDADE_NF
		,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,HR_SAP_LJ_PROCESSO.MOVIMENTA_ESTOQUE,NUMERO_VOLUME,PLACA_TRANSPORTADORA,PESO_CAIXA_TOTAL
		,getdate() as HR_DATA_CRIACAO,TRANSPORTADORA,CHAVE_ORIGEM_REFERENCIA,QTDE_TOTAL,OBS_NF_AUTOMATICA,CENTRO_CUSTO
	from HR_SAP_LOJA_NOTA
	left join HR_SAP_LJ_PROCESSO on HR_SAP_LJ_PROCESSO.HR_LJ_NF_PROCESSO = HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO
	WHERE HR_SAP_LOJA_NOTA.CHAVE_ORIGEM = ?strChaveOrigemBase 
		  AND  HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO = ?intHrLjProcesso 

	ENDTEXT	
	
	TEXT TO strPesquisaItem NOSHOW TEXTMERGE
		SELECT HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM
			,HR_SAP_LOJA_NOTA_ITEM.ITEM
			,HR_SAP_LOJA_NOTA_ITEM.INDICA_PRODUTO
			,PRODUTO		= HR_SAP_LOJA_NOTA_ITEM.PRODUTO
			,COR_PRODUTO	= HR_SAP_LOJA_NOTA_ITEM.COR_PRODUTO
			,TAMANHO		= HR_SAP_LOJA_NOTA_ITEM.TAMANHO
			,HR_SAP_LOJA_NOTA_ITEM.ITEM_FISCAL
			,HR_SAP_LOJA_NOTA_ITEM.QTDE
			,HR_SAP_LOJA_NOTA_ITEM.VALOR_LIQUIDO
			,HR_SAP_LOJA_NOTA_ITEM.OBS_ITEM_NF
			,HR_SAP_LOJA_NOTA_ITEM.CATEGORIA_ESTOQUE
			,HR_SAP_LOJA_NOTA_ITEM.INFO_CUPOM
		from HR_SAP_LOJA_NOTA_ITEM
		JOIN HR_SAP_LOJA_NOTA ON HR_SAP_LOJA_NOTA.CHAVE_ORIGEM  = HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM 
		WHERE HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM = ?strChaveOrigemBase 
			 AND  HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO = ?intHrLjProcesso 
	ENDTEXT

	If .Not. sqlSelect(strPesquisaCabecalho ,"CurNotaCopy","Erro pesquisando informações do cabeçalho para geração da nota fiscal inversa")
		Return .F.
	Endif
	If .Not. sqlSelect(strPesquisaItem ,"CurNotaItemCopy","Erro pesquisando informações dos itens para geração da nota fiscal inversa")
		Return .F.
	Endif

	If Reccount("CurNotaCopy")==0
		MsgBox("Não foram encontradas informações da solicitação de nota fiscal de origem para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif
	If Reccount("CurNotaItemCopy")==0
		MsgBox("Não foram encontradas informações dos itens da solicitação de nota fiscal de origem para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif

	Return .T.
Endfunc



*!* FOTOGRAFIA
Function LoadCursorCopyNotaFotografia As Boolean
	Parameters strChaveOrigemBase As String

	TEXT TO strPesquisaCabecalho NOSHOW TEXTMERGE
	SELECT CODIGO_LINX,CHAVE_ORIGEM,HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO,STATUS,SOLICITA_CANCELAMENTO,NF_NUMERO,SERIE_NF
		,EMISSAO_NF,CODIGO_FILIAL,CLIFOR_DESTINO,CODIGO_CLIENTE,INDICA_CLIENTE_OCASIONAL
		,INDICA_TRANSPORTE_PROPRIO,OBS_NF,TIPO_FRETE_LINX,FINALIDADE_NF
		,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,HR_SAP_LJ_PROCESSO.MOVIMENTA_ESTOQUE,NUMERO_VOLUME,PLACA_TRANSPORTADORA,PESO_CAIXA_TOTAL
		,HR_DATA_CRIACAO,TRANSPORTADORA,CHAVE_ORIGEM_REFERENCIA,QTDE_TOTAL,OBS_NF_AUTOMATICA,CENTRO_CUSTO
	from HR_SAP_LOJA_NOTA
	left join HR_SAP_LJ_PROCESSO on HR_SAP_LJ_PROCESSO.HR_LJ_NF_PROCESSO = HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO
	WHERE HR_SAP_LOJA_NOTA.CHAVE_ORIGEM = ?strChaveOrigemBase 
			AND ( HR_SAP_LOJA_NOTA.STATUS = 8 
			OR ( HR_SAP_LOJA_NOTA.STATUS =3 AND HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO = 23))
	ENDTEXT	
	
	TEXT TO strPesquisaItem NOSHOW TEXTMERGE
		SELECT HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM
			,HR_SAP_LOJA_NOTA_ITEM.ITEM
			,HR_SAP_LOJA_NOTA_ITEM.INDICA_PRODUTO
			,PRODUTO		=ISNULL(HR_SAP_LOJA_NOTA_ITEM.REF_PRODUTO,HR_SAP_LOJA_NOTA_ITEM.PRODUTO)
			,COR_PRODUTO	=ISNULL(HR_SAP_LOJA_NOTA_ITEM.REF_COR_PRODUTO,HR_SAP_LOJA_NOTA_ITEM.COR_PRODUTO)
			,TAMANHO		=ISNULL(HR_SAP_LOJA_NOTA_ITEM.REF_TAMANHO,HR_SAP_LOJA_NOTA_ITEM.TAMANHO)
			,REF_PRODUTO	=CASE WHEN HR_SAP_LOJA_NOTA_ITEM.REF_PRODUTO IS NOT NULL THEN HR_SAP_LOJA_NOTA_ITEM.PRODUTO END
			,REF_COR_PRODUTO=CASE WHEN HR_SAP_LOJA_NOTA_ITEM.REF_COR_PRODUTO IS NOT NULL THEN HR_SAP_LOJA_NOTA_ITEM.COR_PRODUTO END
			,REF_TAMANHO	=CASE WHEN HR_SAP_LOJA_NOTA_ITEM.REF_TAMANHO IS NOT NULL THEN HR_SAP_LOJA_NOTA_ITEM.TAMANHO END
			,HR_SAP_LOJA_NOTA_ITEM.ITEM_FISCAL
			,HR_SAP_LOJA_NOTA_ITEM.QTDE
			,HR_SAP_LOJA_NOTA_ITEM.VALOR_LIQUIDO
			,HR_SAP_LOJA_NOTA_ITEM.OBS_ITEM_NF
			,HR_SAP_LOJA_NOTA_ITEM.CATEGORIA_ESTOQUE
			,HR_SAP_LOJA_NOTA_ITEM.INFO_CUPOM
		from HR_SAP_LOJA_NOTA_ITEM
		JOIN HR_SAP_LOJA_NOTA ON HR_SAP_LOJA_NOTA.CHAVE_ORIGEM  = HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM 
		WHERE HR_SAP_LOJA_NOTA_ITEM.CHAVE_ORIGEM = ?strChaveOrigemBase 
			AND ( HR_SAP_LOJA_NOTA.STATUS = 8  
			OR ( HR_SAP_LOJA_NOTA.STATUS = 3 AND HR_SAP_LOJA_NOTA.HR_LJ_NF_PROCESSO = 23))
	ENDTEXT

	If .Not. sqlSelect(strPesquisaCabecalho ,"CurNotaCopy","Erro pesquisando informações do cabeçalho para geração da nota fiscal inversa")
		Return .F.
	Endif
	If .Not. sqlSelect(strPesquisaItem ,"CurNotaItemCopy","Erro pesquisando informações dos itens para geração da nota fiscal inversa")
		Return .F.
	Endif

	If Reccount("CurNotaCopy")==0
		MsgBox("Não foram encontradas informações da solicitação de nota fiscal de origem para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif
	If Reccount("CurNotaItemCopy")==0
		MsgBox("Não foram encontradas informações dos itens da solicitação de nota fiscal de origem para a geração da nota fiscal inversa",16,"Informação não encontrada")
		Return .F.
	Endif

	Return .T.
Endfunc

Function InsertSqlNotaInversa as Boolean
	Parameters strChaveOrigemInversoSqlInsert As String,intHrLjNfProcessoInverso As Integer,strChaveOrigem As String
	
	Local bErro as Boolean
	
	TEXT TO strInsertCabecalho NOSHOW TEXTMERGE
		INSERT INTO HR_SAP_LOJA_NOTA
			(CHAVE_ORIGEM,HR_LJ_NF_PROCESSO,STATUS,SOLICITA_CANCELAMENTO,NF_NUMERO,SERIE_NF
			,EMISSAO_NF,CODIGO_FILIAL,CLIFOR_DESTINO,CODIGO_CLIENTE,INDICA_CLIENTE_OCASIONAL
			,INDICA_TRANSPORTE_PROPRIO,OBS_NF,TIPO_FRETE_LINX,FINALIDADE_NF
			,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,MOVIMENTA_ESTOQUE,NUMERO_VOLUME,PLACA_TRANSPORTADORA,PESO_CAIXA_TOTAL
			,HR_DATA_CRIACAO,TRANSPORTADORA,CHAVE_ORIGEM_REFERENCIA,QTDE_TOTAL,OBS_NF_AUTOMATICA,CENTRO_CUSTO)
		values
			(?strChaveOrigemInversoSqlInsert,?intHrLjNfProcessoInverso,0,0,null,null
			,null,?CurNotaCopy.CODIGO_FILIAL,?CurNotaCopy.CLIFOR_DESTINO,?CurNotaCopy.CODIGO_CLIENTE,?CurNotaCopy.INDICA_CLIENTE_OCASIONAL
			,?CurNotaCopy.INDICA_TRANSPORTE_PROPRIO,?CurNotaCopy.OBS_NF,?CurNotaCopy.TIPO_FRETE_LINX,?CurNotaCopy.FINALIDADE_NF
			,?CurNotaCopy.NFE_REFERENCIADA,?CurNotaCopy.SERIE_NF_REFERENCIADA,?CurNotaCopy.MOVIMENTA_ESTOQUE,?CurNotaCopy.NUMERO_VOLUME
			,?CurNotaCopy.PLACA_TRANSPORTADORA,?CurNotaCopy.PESO_CAIXA_TOTAL
			,?CurNotaCopy.HR_DATA_CRIACAO,?CurNotaCopy.TRANSPORTADORA,?strChaveOrigem,?CurNotaCopy.QTDE_TOTAL,?CurNotaCopy.OBS_NF_AUTOMATICA,?CurNotaCopy.CENTRO_CUSTO)
	ENDTEXT
*
	TEXT TO strInsertItem NOSHOW TEXTMERGE
		INSERT INTO HR_SAP_LOJA_NOTA_ITEM
			(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO
			,PRODUTO,COR_PRODUTO,TAMANHO
			,REF_PRODUTO,REF_COR_PRODUTO,REF_TAMANHO
			,ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE)
		VALUES
			(?strChaveOrigemInversoSqlInsert,?CurNotaItemCopy.ITEM,?CurNotaItemCopy.INDICA_PRODUTO
			,?CurNotaItemCopy.PRODUTO,?CurNotaItemCopy.COR_PRODUTO,?CurNotaItemCopy.TAMANHO
			,?CurNotaItemCopy.REF_PRODUTO,?CurNotaItemCopy.REF_COR_PRODUTO,?CurNotaItemCopy.REF_TAMANHO
			,?CurNotaItemCopy.ITEM_FISCAL,?CurNotaItemCopy.QTDE,?CurNotaItemCopy.VALOR_LIQUIDO
			,?CurNotaItemCopy.OBS_ITEM_NF,?CurNotaItemCopy.CATEGORIA_ESTOQUE)
	ENDTEXT

	If .Not. SqlExecute(strInsertCabecalho)
		Main.Data.LastError = "Erro ao inserir infromações do cabeçalho da nota Inversa.\n\n"
		bErro = .T.
	Else
		Select CurNotaItemCopy
		Go Top
		Scan
			If .Not. SqlExecute(strInsertItem)
				Main.Data.LastError = "Erro ao inserir infromações do item da nota Inversa. Item "+Nvl(Transform(CurNotaItemCopy.Item),"Nulo")
				bErro = .T.
				Exit && sai do scan
			Endif
			Select CurNotaItemCopy
		Endscan
	Endif

	Return (.Not.bErro)
ENDFUNC


Function HrRelacionaShipFromTroca As Boolean
	Parameters strChaveOrigem As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas AS Boolean

	strCodigoFilial = Transf(Cast(Substr(strChaveOrigem ,2,6) As Int))
	strTicket = Substr(strChaveOrigem ,8, 8)
	strDataVenda = SUBSTR(strChaveOrigem, 16,8)

	TEXT TO strAtualizadaPedido
		UPDATE LOJA_PEDIDO
		SET SITUACAO_OMS = 6
		FROM LOJA_PEDIDO
		INNER JOIN LOJA_PEDIDO_DEVOLUCAO ON LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO_DEVOLUCAO.CODIGO_FILIAL_ORIGEM 
									AND LOJA_PEDIDO.PEDIDO = LOJA_PEDIDO_DEVOLUCAO.PEDIDO
		INNER JOIN LOJA_VENDA ON LOJA_VENDA.CODIGO_FILIAL = LOJA_PEDIDO_DEVOLUCAO.CODIGO_FILIAL_ORIGEM
							AND LOJA_VENDA.DATA_VENDA = LOJA_PEDIDO_DEVOLUCAO.DATA_VENDA
							AND LOJA_VENDA.TICKET = LOJA_PEDIDO_DEVOLUCAO.TICKET		
		WHERE LOJA_VENDA.CODIGO_FILIAL = ?strCodigoFilial 
			AND LOJA_VENDA.DATA_VENDA = ?strDataVenda
			AND LOJA_VENDA.TICKET = ?strTicket	
			
		UPDATE LOJA_PEDIDO_DEVOLUCAO
		SET NF_NUMERO = ?strNfNumeroLinx ,
			SERIE_NF = ?strSerieNfLinx 
		WHERE LOJA_PEDIDO_DEVOLUCAO.CODIGO_FILIAL_ORIGEM = ?strCodigoFilial 
			AND LOJA_PEDIDO_DEVOLUCAO.DATA_VENDA = ?strDataVenda
			AND LOJA_PEDIDO_DEVOLUCAO.TICKET = ?strTicket																	
	ENDTEXT

	Return sqlExecuteLocalMsg(strAtualizadaPedido,"Erro ao atualizar dados do pedido de troca para devolvido. ",bNaoMostrarCriticas)
Endfunc

Function HrRelacionaNfSaida As Boolean
	Parameters strChaveOrigem As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas AS Boolean

	strCodigoFilialSaidaRelaciona = Transf(Cast(Substr(strChaveOrigem,2,6) As Int))
	strRomaneioProdutoSaidaRelaciona = Substr(strChaveOrigem,8)

	TEXT TO strUpdateRelacionaNfcomEntrada NOSHOW TEXTMERGE
	UPDATE loja_saidas SET numero_nf_transferencia = ?strNfNumeroLinx , serie_nf = ?strSerieNfLinx ,EMISSAO = ?dEmissaoLinx, saida_encerrada = 1
	from loja_saidas join lojas_varejo on loja_saidas.filial = lojas_varejo.filial
	where lojas_varejo.codigo_filial = ?strCodigoFilialSaidaRelaciona and loja_saidas.ROMANEIO_PRODUTO = ?strRomaneioProdutoSaidaRelaciona
	ENDTEXT

	Return sqlExecuteLocalMsg(strUpdateRelacionaNfcomEntrada ,"Erro ao relacionar nota fiscal gerada com a movimentação de entrada no estoque. ",bNaoMostrarCriticas)
Endfunc

Function HrRelacionaNfEntrada
	Parameters strChaveOrigem As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas as Boolean

	strCodigoFilialEntradaRelaciona = Transf(Cast(Substr(strChaveOrigem,2,6) As Int))
	strRomaneioProdutoEntradaRelaciona = Substr(strChaveOrigem,8)

	TEXT TO strUpdateRelacionaNfcomEntrada NOSHOW TEXTMERGE
	UPDATE loja_entradas SET numero_nf_transferencia = ?strNfNumeroLinx , SERIE_NF_ENTRADA = ?strSerieNfLinx ,EMISSAO = ?dEmissaoLinx, entrada_encerrada = 1,
			entrada_conferida = 1
	from loja_entradas join lojas_varejo on loja_entradas.filial = lojas_varejo.filial
	where lojas_varejo.codigo_filial = ?strCodigoFilialEntradaRelaciona  and loja_entradas.ROMANEIO_PRODUTO = ?strRomaneioProdutoEntradaRelaciona
	ENDTEXT

	Return SqlExecuteLocalMsg(strUpdateRelacionaNfcomEntrada ,"Erro ao relacionar nota fiscal gerada com a movimentação de entrada no estoque. ",bNaoMostrarCriticas)

Endfunc

********************************************************************************
****----				Processos de Cancelamento						----****
********************************************************************************
********************************************************************************

Function HrCancelaTabelaOrigemBancoDados as Boolean
	Parameters strChaveOrigem As String,iHrLjTipoProcesso As Integer,bNaoMostrarCriticas AS Boolean 

	Do Case
			*!* Venda
		Case Inlist(iHrLjTipoProcesso,;
				_HR_LJ_PROCESSO_VENDA_CUPOM,;
				_HR_LJ_PROCESSO_NOTA_VENDA ,;
				_HR_LJ_PROCESSO_NOTA_VENDA_OMNI ;
				)

			Return HrRetiraVinculoNotaVenda(strChaveOrigem,bNaoMostrarCriticas)
		
			*!* Troca
		Case Inlist(iHrLjTipoProcesso,;
				_HR_LJ_PROCESSO_TROCA_CUPOM,;
				_HR_LJ_PROCESSO_TROCAS_DIA, ;
				_HR_LJ_PROCESSO_TROCA_CUPOM_OMNI)
			
			Return HrRetiraVinculoNotaTroca(strChaveOrigem,bNaoMostrarCriticas)
			
			*!* Cancelamento	
		Case Inlist(iHrLjTipoProcesso,;
				_HR_LJ_PROCESSO_CANCELAMENTOS_CUPOM)

			Return HrRetiraVinculoNotaCancelamento(strChaveOrigem,bNaoMostrarCriticas)

			*!* Saidas
		Case Inlist(iHrLjTipoProcesso,;
				_HR_LJ_PROCESSO_BONIFICACAO,;
				_HR_LJ_PROCESSO_BRINDE,;
				_HR_LJ_PROCESSO_SAIDA_ESTOQUE_AJUSTE,;
				_HR_LJ_PROCESSO_REMESSA_FOTOGRAFIA,;
				_HR_LJ_PROCESSO_SAIDA_UNIFORME,;
				_HR_LJ_PROCESSO_TRANSFERENCIA_NORMAL)
			
			strCodigoFilialSaida = transf(Cast(Substr(strChaveOrigem,2,6) as int))
			strRomaneioProdutoSaida = Substr(strChaveOrigem,8)
			
			If strCodigoFilialSaida == Main.P_CODIGO_FILIAL
				strFilial = Main.p_filial
			Else
				Return .F.
			Endif
			
			Return HrCancelaSaidaBancoDados(strRomaneioProdutoSaida ,strFilial,bNaoMostrarCriticas)
			
			*!* Entradas
		Case Inlist(iHrLjTipoProcesso,;
				_HR_LJ_PROCESSO_RETORNO_BONIFICACAO,;
				_HR_LJ_PROCESSO_RETORNO_BRINDE,;
				_HR_LJ_PROCESSO_ENTRADA_ESTOQUE_AJUSTE,;
				_HR_LJ_PROCESSO_RETORNO_FOTOGRAFIA )
			
			strCodigoFilialSaida = transf(Cast(Substr(strChaveOrigem,2,6) as int))
			strRomaneioProdutoSaida = Substr(strChaveOrigem,8)
			
			If strCodigoFilialSaida == Main.P_CODIGO_FILIAL
				strFilial = Main.p_filial
			Else
				Return .F.
			Endif
			
			Return HrCancelaEntradaBancoDados(strRomaneioProdutoSaida ,strFilial,bNaoMostrarCriticas)
			
			*!* Saida para transformacao
		Case Inlist(iHrLjTipoProcesso,_HR_LJ_PROCESSO_SAIDA_TRANSFORMACAO_PRODUTO)

			*!* Entrada para transformacao
		Case Inlist(iHrLjTipoProcesso,_HR_LJ_PROCESSO_ENTRADA_TRANSFORMACAO_PRODUTO)
		
		*!* Transferencia para matriz por concerto
		Case Inlist(iHrLjTipoProcesso,_HR_LJ_PROCESSO_TRANSFERENCIA_CONCERTO)
			HrCancelaConcerto(strChaveOrigem,bNaoMostrarCriticas)
			
						
		Case Inlist(iHrLjTipoProcesso,_HR_LJ_PROCESSO_RETORNO_CLIENTE_CONSERTO)
			HrCancelaConcerto(strChaveOrigem,bNaoMostrarCriticas)
		
		Otherwise
			*!* _HR_LJ_PROCESSO_RETORNO_CUPOM
			*!* _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_ENTRADA
			*!* _HR_LJ_PROCESSO_AJUSTE_REDUÇÃO_Z_SAIDA
			*!* _HR_LJ_PROCESSO_OUTRAS_ENTRADAS
			*!* _HR_LJ_PROCESSO_OUTRAS_SAIDAS
			*!* _HR_LJ_PROCESSO_REMESSA_VENDA_FORA_ESTAB
			*!* _HR_LJ_PROCESSO_RETORNO_VENDA_FORA_ESTAB
			*!* _HR_LJ_PROCESSO_COMPLEMENTO_VALOR_IMPOSTO
			*!* _HR_LJ_PROCESSO_REMESSA_LOJA_REFORMA
			*!* _HR_LJ_PROCESSO_RETORNO_LOJA_REFORMA
	Endcase



	Return .F.

Endfunc

Function HrRetiraVinculoNotaVenda As Boolean
	Parameters strChaveOrigem as String,bNaoMostrarCriticas AS Boolean
	
	TEXT TO strUpdateRetiraRelacionamento NOSHOW TEXTMERGE
	DECLARE @LINHAS_AFETADAS INT
	UPDATE LOJA_VENDA_PGTO
		SET HR_SAP_CHAVE_NF_VENDA = null
	WHERE HR_SAP_CHAVE_NF_VENDA = ?strChaveOrigem

	SET @LINHAS_AFETADAS = @@rowcount
	if @LINHAS_AFETADAS>1
	RAISERROR ('Encontrado mais de uma venda relacionada a nota de origem', 16, 10)
	if @LINHAS_AFETADAS=0
	RAISERROR ('Venda relacionada a nota de origem não encontrada', 16, 10)
	ENDTEXT

	Return SqlExecuteLocalMsg(strUpdateRetiraRelacionamento,"Erro ao retirar relacionamento da nota com a ticket",bNaoMostrarCriticas)
Endfunc

Function HrRetiraVinculoNotaTroca As Boolean
	Parameters strChaveOrigem as String,bNaoMostrarCriticas as Boolean

	TEXT TO strUpdateRetiraRelacionamento NOSHOW TEXTMERGE
		update LOJA_VENDA_PGTO
		set HR_SAP_CHAVE_NF_TROCA = null
		where HR_SAP_CHAVE_NF_TROCA = ?strChaveOrigem
	ENDTEXT

	Return sqlExecuteLocalMsg(strUpdateRetiraRelacionamento,"Erro ao retirar relacionamento da nota com a ticket",bNaoMostrarCriticas )
Endfunc

Function HrRetiraVinculoNotaCancelamento As Boolean
	Parameters strChaveOrigem as String,bNaoMostrarCriticas as Boolean

	TEXT TO strUpdateRetiraRelacionamento NOSHOW TEXTMERGE
		update LOJA_VENDA_PGTO
		set HR_SAP_CHAVE_NF_CANCELAMENTO = null
		where HR_SAP_CHAVE_NF_CANCELAMENTO = ?strChaveOrigem
	ENDTEXT

	Return sqlExecuteLocalMsg(strUpdateRetiraRelacionamento,"Erro ao retirar relacionamento da nota com a ticket",bNaoMostrarCriticas)
Endfunc


Function HrCancelaSaidaBancoDados as Boolean
	Parameters strRomaneioProduto as String,strFilial as String,bNaoMostrarCriticas as Boolean
	
	Local strCommand As String

	TEXT TO strCommand NOSHOW
	declare @errono int,
			@erromsg varchar(200)

	 begin tran
	 begin try
	  update LOJA_SAIDAS SET QTDE_TOTAL = 0,VALOR_TOTAL=0,SAIDA_CANCELADA=1,SAIDA_ENCERRADA=1
	  where ROMANEIO_PRODUTO = ?strRomaneioProduto and FILIAL = ?strFilial

	  if @@rowcount <> 1
	  RAISERROR ('Saída não encontrada', 16, 10)
	  update LOJA_SAIDAS_PRODUTO
		SET QTDE_SAIDA = 0,VALOR=0,PRECO1=0,PRECO2=0,PRECO3=0,PRECO4=0
			,EN1 = 0,EN2 = 0,EN3 = 0,EN4 = 0,EN5 = 0,EN6 = 0,EN7 = 0,EN8 = 0,EN9 = 0,EN10 = 0
			,EN11 = 0,EN12 = 0,EN13 = 0,EN14 = 0,EN15 = 0,EN16 = 0,EN17 = 0,EN18 = 0,EN19 = 0,EN20 = 0
			,EN21 = 0,EN22 = 0,EN23 = 0,EN24 = 0,EN25 = 0,EN26 = 0,EN27 = 0,EN28 = 0,EN29 = 0,EN30 = 0
			,EN31 = 0,EN32 = 0,EN33 = 0,EN34 = 0,EN35 = 0,EN36 = 0,EN37 = 0,EN38 = 0,EN39 = 0,EN40 = 0
			,EN41 = 0,EN42 = 0,EN43 = 0,EN44 = 0,EN45 = 0,EN46 = 0,EN47 = 0,EN48 = 0
	   where ROMANEIO_PRODUTO = ?strRomaneioProduto and FILIAL = ?strFilial

	  if @@rowcount = 0
	 
	   RAISERROR ('Nenhum produto encontrado na saída', 16, 10)
	  commit
	 end try
	 begin catch
	  while @@trancount > 0 rollback
	  set @errono = error_number()
	  set @erromsg = 'Linha: '+rtrim(convert(varchar(8),error_line()))+'-'+error_message()
	  RAISERROR (@erromsg, 16, 10)
	 end catch
	ENDTEXT

	Local bRetorno As Boolean
	bRetorno = sqlExecuteLocalMsg(strCommand ,"Erro ao cancelar e retirar os dados da saída.",bNaoMostrarCriticas)
	
	Return bRetorno

Endfunc 

Function HrCancelaEntradaBancoDados as Boolean
	Parameters strRomaneioProduto as String,strFilial as String,bNaoMostrarCriticas as Boolean
	
	Local strCommand As String

	TEXT TO strCommand NOSHOW
	declare @errono int,
			@erromsg varchar(200)

	 begin tran
	 begin try
	  update LOJA_ENTRADAS SET QTDE_TOTAL = 0,VALOR_TOTAL=0,ENTRADA_CANCELADA=1,ENTRADA_ENCERRADA=1
	  where ROMANEIO_PRODUTO = ?strRomaneioProduto and FILIAL_ORIGEM = ?strFilial

	  if @@rowcount <> 1
		RAISERROR ('Entrada não encontrada', 16, 10)
	  update LOJA_ENTRADAS_PRODUTO
		SET QTDE_ENTRADA = 0,VALOR=0,PRECO1=0,PRECO2=0,PRECO3=0,PRECO4=0
			,EN1 = 0,EN2 = 0,EN3 = 0,EN4 = 0,EN5 = 0,EN6 = 0,EN7 = 0,EN8 = 0,EN9 = 0,EN10 = 0
			,EN11 = 0,EN12 = 0,EN13 = 0,EN14 = 0,EN15 = 0,EN16 = 0,EN17 = 0,EN18 = 0,EN19 = 0,EN20 = 0
			,EN21 = 0,EN22 = 0,EN23 = 0,EN24 = 0,EN25 = 0,EN26 = 0,EN27 = 0,EN28 = 0,EN29 = 0,EN30 = 0
			,EN31 = 0,EN32 = 0,EN33 = 0,EN34 = 0,EN35 = 0,EN36 = 0,EN37 = 0,EN38 = 0,EN39 = 0,EN40 = 0
			,EN41 = 0,EN42 = 0,EN43 = 0,EN44 = 0,EN45 = 0,EN46 = 0,EN47 = 0,EN48 = 0
	   where ROMANEIO_PRODUTO = ?strRomaneioProduto and FILIAL = ?strFilial

	  if @@rowcount = 0
	  RAISERROR ('Nenhum produto encontrado na entrada', 16, 10)
	  commit
	 end try
	 begin catch
	  while @@trancount > 0 rollback
	  set @errono = error_number()
	  set @erromsg = 'Linha: '+rtrim(convert(varchar(8),error_line()))+'-'+error_message()
	 RAISERROR (@erromsg, 16, 10)
	 end catch
	ENDTEXT

	Local bRetorno As Boolean
	bRetorno = sqlExecuteLocalMsg(strCommand ,"Erro ao cancelar e retirar os dados da Entrada.",bNaoMostrarCriticas)
	
	Return bRetorno

Endfunc 

Function HrCancelaConcerto
	LParameters strChaveOrigem as String,bNaoMostrarCriticas as Boolean

	* Update na tabela LOJA_CONSERTO data_cancelamento /  MOTIVO_CANCELAMENTO /  
	* so cancela _CRIADO_ESTORNO_SAP ou _ESTORNO_CRIADO_SOMENTE_LINX -> hr_sap_loja_nota.status

	*!* Localizar Nota Fiscal
	nFilial = CAST(SUBSTR(strChaveOrigem,2,6) as int)
	nProtocolo = SUBSTR(strChaveOrigem,8)
	
	TEXT TO strPesquisaCabecalho NOSHOW TEXTMERGE
		select STATUS from hr_sap_loja_nota where CHAVE_ORIGEM = ?strChaveOrigem
	ENDTEXT
	
	If .Not. SqlSelectLocalMsg(strPesquisaCabecalho,"CurStatus","Erro pesquisando informações do cabeçalho da Nota Fiscal.",bNaoMostrarCriticas)
		Return .F.
	Endif	

	SELECT CurStatus
	GO TOP 
	IF INLIST(CurStatus.status,_CRIADO_ESTORNO_SAP,_ESTORNO_CRIADO_SOMENTE_LINX)
		*!* Definir motivo_cancelamento (LOJA_MOTIVO_CANC_CONSERTO)
		TEXT TO strCancelaConcerto NOSHOW TEXTMERGE
			update LOJA_CONSERTO SET DATA_CANCELAMENTO = getdate(), MOTIVO_CANCELAMENTO = '1' where CODIGO_FILIAL = ?nFilial and PROTOCOLO = ?nProtocolo 
		ENDTEXT
		
		IF .Not. sqlExecuteLocalMsg(strCancelaConcerto ,"Erro ao cancelar nota de Concerto.",bNaoMostrarCriticas)
			RETURN .F.
		ENDIF 

	ENDIF 	
	
ENDFUNC 


***********************************************************************
****	FUNCOES EXTRA PARA TRATAMENTO DE EXIBIR OU NAO MENSAGENS   ****
*---------------------------------------------------------------------*

FUNCTION SqlSelectLocalMsg
	LPARAMETERS strQuery as String,strCursorName as String,strMessagemCritica as String,bNaoMostrarCritica as Boolean
	
	IF bNaoMostrarCritica 
		RETURN sqlSelect(strQuery,strCursorName)
	ELSE
		RETURN sqlSelect(strQuery,strCursorName,strMessagemCritica )
	endif	
	
ENDFUNC 

FUNCTION SQLExecuteLocalMsg
	LPARAMETERS strQuery as String,strMessagemCritica as String,bNaoMostrarCritica as Boolean
	
	IF bNaoMostrarCritica 
		RETURN SQLExecute(strQuery)
	ELSE
		RETURN SQLExecute(strQuery,strMessagemCritica )
	endif
	
ENDFUNC 

FUNCTION msgBoxLocalMsg
	LPARAMETERS strMensagem as String,iBotoes as Integer,strTitulo as String,bNaoMostrarCritica as Boolean
	
	IF .Not. bNaoMostrarCritica
		RETURN MsgBox(strMensagem,iBotoes,strTitulo)
	ENDIF
	
	RETURN 0
	
ENDFUNC 

Function ShowProgressLocalMsg
	Lparameters strMensagem As String,lParam2 As Variant,lParam3 As Variant,lParam4 As Variant

	Do Case
		Case Pcount()==1
			If Type("strMensagem")=="L"
				If .Not. strMensagem
					ShowProgress()
				Endif
			Else
				Return ShowProgress(strMensagem)
			Endif
		Case Pcount()==2
			If Type("lParam2")=="L"
				If .Not. lParam2
					Return ShowProgress(strMensagem)
				Endif
			Else
				Return ShowProgress(strMensagem,lParam2)
			Endif

		Case Pcount()==3
			If Type("lParam3")=="L"
				If .Not. lParam3
					Return ShowProgress(strMensagem,lParam2)
				Endif
			Else
				Return ShowProgress(strMensagem,lParam2,lParam3)
			Endif

		Case Pcount()==4
			If .Not. lParam4
				Return ShowProgress(strMensagem,lParam2,lParam3)
			Endif

		Otherwise
			Return ShowProgress()
	Endcase
Endfunc

Function HrMergeLojaReservas As String && Retorna chave origem em caso de sucesso, em caso de erro retorna em branco
	parameters strFilial As String,strCodigoFilial As String,strRomaneioReserva As String,bJaValidouAlteracao as Boolean
	
	Public strChaveOrigemReserva As String

	TEXT TO strSelectLojaReserva noshow
		Select a.FILIAL
			,0 as SAIDA_CANCELADA
			,'RS' as TIPO_ENTRADA_SAIDA
			,CLIFOR_DESTINO = B.CLIFOR
			,CODIGO_CLIENTE
			,INDICA_CLIENTE_OCASIONAL = 1
			,A.QTDE_TOTAL
			,'0600' as HR_DEPOSITO_DESTINO
		from LOJA_RESERVA a
		inner join CADASTRO_CLI_FOR b on b.NOME_CLIFOR =A.FILIAL 
		where A.NUMERO_RESERVA = ?strRomaneioReserva and A.FILIAL = ?strFilial
	ENDTEXT

	IF .Not. SqlSelect(strSelectLojaReserva,"CurIntegraLojaReserva","Erro ao consultar cabecalho da Reserva")
		Return ""
	Endif
	
	TEXT TO strSelectLojaReservaProduto noshow
	select A.NUMERO_RESERVA,A.FILIAL,A.PRODUTO,A.COR_PRODUTO,A.QTDE_SAIDA,
		A.PRECO1,A.PRECO2,A.PRECO3,A.PRECO4,A.VALOR,
		A.EN1,A.EN2,A.EN3,A.EN4,A.EN5,A.EN6,A.EN7,A.EN8,A.EN9,A.EN10,
		A.EN11,A.EN12,A.EN13,A.EN14,A.EN15,A.EN16,A.EN17,A.EN18,A.EN19,A.EN20,
		A.EN21,A.EN22,A.EN23,A.EN24,A.EN25,A.EN26,A.EN27,A.EN28,A.EN29,A.EN30,
		A.EN31,A.EN32,A.EN33,A.EN34,A.EN35,A.EN36,A.EN37,A.EN38,A.EN39,A.EN40,
		A.EN41,A.EN42,A.EN43,A.EN44,A.EN45,A.EN46,A.EN47,A.EN48,
		B.GRADE,B.PONTEIRO_PRECO_TAM,B.VARIA_PRECO_TAM
	from LOJA_RESERVA_PRODUTO A
	join PRODUTOS B ON A.PRODUTO = B.PRODUTO 	 
	where a.NUMERO_RESERVA = ?strRomaneioReserva and a.filial = ?strFilial	
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectLojaReservaProduto,"CurIntegraLojaReservaProduto","Erro ao consultar produtos da Reserva")
		Return ""
	Endif
	
	TEXT TO strSelectProdutosTamanhos noshow
	select a.GRADE,a.NUMERO_TAMANHOS,
		a.TAMANHO_1,a.TAMANHO_2,a.TAMANHO_3,a.TAMANHO_4,a.TAMANHO_5,a.TAMANHO_6,
		a.TAMANHO_7,a.TAMANHO_8,a.TAMANHO_9,a.TAMANHO_10,a.TAMANHO_11,a.TAMANHO_12,
		a.TAMANHO_13,a.TAMANHO_14,a.TAMANHO_15,a.TAMANHO_16,a.TAMANHO_17,a.TAMANHO_18,
		a.TAMANHO_19,a.TAMANHO_20,a.TAMANHO_21,a.TAMANHO_22,a.TAMANHO_23,a.TAMANHO_24,
		a.TAMANHO_25,a.TAMANHO_26,a.TAMANHO_27,a.TAMANHO_28,a.TAMANHO_29,a.TAMANHO_30,
		a.TAMANHO_31,a.TAMANHO_32,a.TAMANHO_33,a.TAMANHO_34,a.TAMANHO_35,a.TAMANHO_36,
		a.TAMANHO_37,a.TAMANHO_38,a.TAMANHO_39,a.TAMANHO_40,a.TAMANHO_41,a.TAMANHO_42,
		a.TAMANHO_43,a.TAMANHO_44,a.TAMANHO_45,a.TAMANHO_46,a.TAMANHO_47,a.TAMANHO_48
	from produtos_tamanhos a	
	ENDTEXT 
	
	IF .Not. SqlSelect(strSelectProdutosTamanhos,"CurIntegraProdutosTamanhos","Erro ao consultar produtos da saida")
		Return ""
	Endif
	*!* Fim - Busca Dados
	
	*!* Validacoes
	If Reccount("CurIntegraLojaReserva")==0
		MsgBox("Erro ao gerar solicitação de nota. Reserva não encontrada na base de dados",16,"Erro")
		Return ""
	Endif
	If Reccount("CurIntegraLojaReservaProduto")==0
		MsgBox("Erro ao gerar solicitação de nota. Não foram encontrados os itens da Reserva na base de dados",16,"Erro")
		Return ""
	Endif
	
	Local strLetra As String,iHrSapLjProcesso As Integer
	iHrSapLjProcesso = GetHrSapLjProcessoEntradaSaida(Upper(Alltrim(CurIntegraLojaReserva.tipo_entrada_saida)))
	strLetra = GetLetraHrSapLjProcesso(iHrSapLjProcesso)
	If Empty(Nvl(strLetra,""))
		MsgBox("Erro ao gerar solicitação de nota. Não foi possível definir tipo de nota, pelo tipo de Reserva: "+Nvl(CurIntegraLojaReserva.tipo_entrada_saida,"(Nulo)"),16,"Erro")
		Return ""
	Endif
	strChaveOrigemReserva = strLetra + Padl(strCodigoFilial,6,"0")+strRomaneioReserva
	
	IF .Not. bJaValidouAlteracao
		If .Not. HrNfPermiteAlterar(strChaveOrigemReserva)
			Return ""
		Endif
	Endif
	*!* Fim - Validacoes

	*!* Envia dados para tabela de notas fiscais && Existem tratamentos para cliente ocasional
	TEXT TO strInsertCabecalho TEXTMERGE NOSHOW 
		DECLARE @cliente_ocasional bit,@CLIFOR_DESTINO char(6)
		SET @cliente_ocasional = ?CurIntegraLojaReserva.INDICA_CLIENTE_OCASIONAL
		SET @CLIFOR_DESTINO = case when @cliente_ocasional = 0 then ?CurIntegraLojaReserva.CLIFOR_DESTINO end
		
		IF exists(select TOP 1 1 from DBO.HR_SAP_LOJA_NOTA WHERE CHAVE_ORIGEM = ?strChaveOrigemReserva)
		 UPDATE dbo.HR_SAP_LOJA_NOTA
		  SET CLIFOR_DESTINO = @CLIFOR_DESTINO
			,INDICA_CLIENTE_OCASIONAL=@cliente_ocasional
			,FINALIDADE_NF=1
			,MOVIMENTA_ESTOQUE=1
			,STATUS = 0
			,SOLICITA_CANCELAMENTO = CASE WHEN ISNULL(SOLICITA_CANCELAMENTO,0)=1 THEN 1 ELSE ?CurIntegraLojaReserva.SAIDA_CANCELADA END
			,QTDE_TOTAL 		= ?CurIntegraLojaReserva.QTDE_TOTAL
			,DEPOSITO_DESTINO 	= ?CurIntegraLojaReserva.HR_DEPOSITO_DESTINO 
		 WHERE CHAVE_ORIGEM 	= ?strChaveOrigemReserva
		ELSE
		 Insert Into dbo.HR_SAP_LOJA_NOTA
			(CHAVE_ORIGEM,HR_LJ_NF_PROCESSO,Status,SOLICITA_CANCELAMENTO
			,NF_NUMERO,SERIE_NF,CODIGO_FILIAL,CLIFOR_DESTINO
			,INDICA_CLIENTE_OCASIONAL,CODIGO_CLIENTE,TRANSPORTADORA,INDICA_TRANSPORTE_PROPRIO,OBS_NF
			,TIPO_FRETE_LINX,FINALIDADE_NF,NFE_REFERENCIADA,SERIE_NF_REFERENCIADA,MOVIMENTA_ESTOQUE,NUMERO_VOLUME,QTDE_TOTAL,DEPOSITO_DESTINO,OBS_NF_AUTOMATICA)
		 Values (?strChaveOrigemReserva,<<iHrSapLjProcesso>>,0,?CurIntegraLojaReserva.SAIDA_CANCELADA
			,Null,Null,?strCodigoFilial,@CLIFOR_DESTINO
			,@cliente_ocasional,?CurIntegraLojaReserva.codigo_cliente,Null,0,Null
			,Null,1,Null,Null,1,0,?CurIntegraLojaReserva.QTDE_TOTAL,?CurIntegraLojaReserva.HR_DEPOSITO_DESTINO, Null)	
	ENDTEXT
		
	TEXT TO strDeleteItem TEXTMERGE NOSHOW 
		DELETE FROM dbo.HR_SAP_LOJA_NOTA_ITEM WHERE CHAVE_ORIGEM = ?strChaveOrigemReserva
	ENDTEXT
	
	TEXT TO strInsertItem TEXTMERGE NOSHOW 
		Insert Into dbo.HR_SAP_LOJA_NOTA_ITEM
		(CHAVE_ORIGEM,ITEM,INDICA_PRODUTO,PRODUTO,COR_PRODUTO,TAMANHO,
		ITEM_FISCAL,QTDE,VALOR_LIQUIDO,OBS_ITEM_NF,CATEGORIA_ESTOQUE )
		Values (?strChaveOrigemReserva,?nItem,1,?CurIntegraLojaReservaProduto.PRODUTO,?CurIntegraLojaReservaProduto.COR_PRODUTO,?strTamanho,
		NULL,?nQtdeItem,?nValorItem,NULL,NULL)
	ENDTEXT

	Local bRetornoOK as Boolean
	bRetornoOK = .f.
	main.data.BeginTransaction()
	Try
		If sqlExecute(strInsertCabecalho,"Erro inserindo informações do cabeçalho") .And.;
			sqlExecute(strDeleteItem,"Erro limpando informações anteriores")
			
			*!* Inseri itens
			Local bErroItens As Boolean
			bErroItens = .F.
			nItem=1
			Select CurIntegraLojaReservaProduto
				Go Top
				Scan
					Select CurIntegraProdutosTamanhos
					Go Top
					Locate For Alltrim(CurIntegraLojaReservaProduto.grade) == Alltrim(CurIntegraProdutosTamanhos.grade)
					Select CurIntegraLojaReservaProduto
					For _k = 1 To CurIntegraProdutosTamanhos.numero_tamanhos
						__k = Transf(_k)
						If CurIntegraLojaReservaProduto.EN&__k. > 0
							nQtdeItem = CurIntegraLojaReservaProduto.EN&__k.
							strTamanho = CurIntegraProdutosTamanhos.Tamanho_&__k.
							IF CurIntegraLojaReservaProduto.QTDE_SAIDA == 0
								MsgBox("Inconsistencia em informação de itens da saida. Produto "+CurIntegraLojaReservaProduto.Produto+ " cor "+CurIntegraLojaReservaProduto.cor_produto+;
										"\nQuantidade do item da saída não pode ser zero!",16,"Erro")
								Exit 
							Endif
							nValorItem = round(CurIntegraLojaReservaProduto.VALOR/QTDE_SAIDA * nQtdeItem,2)
							If .Not. sqlExecute(strInsertItem,"Erro inserindo informações dos itens")
								bErroItens = .T.
								Exit 
							Endif
							nItem=nItem+1
						Endif
					Endfor
					
					IF bErroItens 
						Exit
					Endif
					Select CurIntegraLojaReservaProduto
				ENDSCAN
			ENDIF 
					
			If bErroItens
				Main.Data.RollbackTransaction()
			Else
				*!* Fim - Vincula informacao da solicitacao de nota a venda

				*!* Commit e marca para chamar tela auxiliar
				IF .Not. bErroItens
					Main.Data.CommitTransaction()
					bRetornoOK = .t.
				Endif
			ENDIF
			
	Catch To oException
		Main.Data.RollbackTransaction()
		MsgBox("Erro ao Criar solicitação de nota fiscal de saída.\nDetalhes: Linha: "+ Transf(oException.Lineno)+"  "+;
			"Mensagem: "+oException.Message+;
			"\nConteudo da Linha: "+Nvl(oException.LineContents,"{Nulo}"),16,"Erro grave")
	Finally
	Endtry
	
	If bRetornoOK
		Return strChaveOrigemReserva
	Endif

	Return ""
	
Endfunc


Function HrRelacionaPedidoShipFrom As Boolean
	Parameters strChaveOrigem As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas AS Boolean


	strCodigoFilial = Transf(Cast(Substr(strChaveOrigem ,2,6) As Int))
	strTicket = Substr(strChaveOrigem ,8, 8)
	strDataVenda = SUBSTR(strChaveOrigem, 16,8)

	TEXT TO strAtualizadaPedido
		UPDATE LOJA_PEDIDO
		SET SITUACAO_OMS = 4
		FROM LOJA_PEDIDO
		INNER JOIN LOJA_PEDIDO_VENDA ON LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO_VENDA.CODIGO_FILIAL_ORIGEM 
									AND LOJA_PEDIDO.PEDIDO = LOJA_PEDIDO_VENDA.PEDIDO
		INNER JOIN LOJA_VENDA ON LOJA_VENDA.CODIGO_FILIAL = LOJA_PEDIDO_VENDA.CODIGO_FILIAL_ORIGEM
							AND LOJA_VENDA.DATA_VENDA = LOJA_PEDIDO_VENDA.DATA_VENDA
							AND LOJA_VENDA.TICKET = LOJA_PEDIDO_VENDA.TICKET		
		WHERE LOJA_VENDA.CODIGO_FILIAL = ?strCodigoFilial 
			AND LOJA_VENDA.DATA_VENDA = ?strDataVenda
			AND LOJA_VENDA.TICKET = ?strTicket															
	ENDTEXT

	Return sqlExecuteLocalMsg(strAtualizadaPedido,"Erro ao atualizar status de pedido para faturado. ",bNaoMostrarCriticas)
ENDFUNC


Function AtualizaStatusPedidoShipTroca As Boolean
	Parameters strChaveOrigem As String


	strCodigoFilial = Transf(Cast(Substr(strChaveOrigem ,2,6) As Int))
	strTicket = Substr(strChaveOrigem ,8, 8)
	strDataVenda = SUBSTR(strChaveOrigem, 16,8)

	TEXT TO strAtualizadaPedido
		UPDATE LOJA_PEDIDO
		SET SITUACAO_OMS = 5
		FROM LOJA_PEDIDO
		INNER JOIN LOJA_PEDIDO_DEVOLUCAO ON LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO_DEVOLUCAO.CODIGO_FILIAL_ORIGEM 
											AND LOJA_PEDIDO.PEDIDO = LOJA_PEDIDO_DEVOLUCAO.PEDIDO
		INNER JOIN LOJA_VENDA ON LOJA_VENDA.CODIGO_FILIAL = LOJA_PEDIDO_DEVOLUCAO .CODIGO_FILIAL_ORIGEM
							AND LOJA_VENDA.DATA_VENDA = LOJA_PEDIDO_DEVOLUCAO .DATA_VENDA
							AND LOJA_VENDA.TICKET = LOJA_PEDIDO_DEVOLUCAO .TICKET		
		WHERE LOJA_VENDA.CODIGO_FILIAL = ?strCodigoFilial 
			AND LOJA_VENDA.DATA_VENDA = ?strDataVenda
			AND LOJA_VENDA.TICKET = ?strTicket															
	ENDTEXT

	Return sqlExecuteLocalMsg(strAtualizadaPedido,"Erro ao atualizar status do pedido de troca. ",bNaoMostrarCriticas)
ENDFUNC






Function HrRelacionaNfRemessaReserva As Boolean
	Parameters strChaveOrigemReserva As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas AS Boolean

	strCodigoFilialRemessaReservaRelaciona = Transf(Cast(Substr(strChaveOrigemReserva,2,6) As Int))
	strRemessaReservaRelaciona = Substr(strChaveOrigemReserva,8)
	
	TEXT TO strUpdateRelacionaNfRemessaReserva NOSHOW TEXTMERGE
	UPDATE loja_reserva SET NUMERO_NF= ?strNfNumeroLinx , serie_nf = ?strSerieNfLinx ,EMISSAO = ?dEmissaoLinx
	from loja_reserva join lojas_varejo on loja_reserva.filial = lojas_varejo.filial
	where lojas_varejo.codigo_filial = ?strCodigoFilialRemessaReservaRelaciona and loja_reserva.numero_reserva = ?strRemessaReservaRelaciona 
	ENDTEXT

	Return sqlExecuteLocalMsg(strUpdateRelacionaNfRemessaReserva,"Erro ao relacionar nota fiscal gerada com a Reserva do estoque. ",bNaoMostrarCriticas)
ENDFUNC


Function HrRelacionaNfRetornoReserva As Boolean
	Parameters strChaveOrigemReserva As String,strSerieNfLinx As String,strNfNumeroLinx As String,dEmissaoLinx As Date,bNaoMostrarCriticas AS Boolean

	strCodigoFilialRetornoReservaRelaciona = Transf(Cast(Substr(strChaveOrigemReserva,2,6) As Int))
	strRetornoReservaRelaciona = Substr(strChaveOrigemReserva,8)

	TEXT TO strUpdateRelacionaNfRetornoReserva NOSHOW TEXTMERGE
	UPDATE loja_reserva SET NUMERO_NF_RETORNO= ?strNfNumeroLinx , SERIE_NF_RETORNO= ?strSerieNfLinx ,ENCERRAMENTO= ?dEmissaoLinx
	from loja_reserva join lojas_varejo on loja_reserva.filial = lojas_varejo.filial
	where lojas_varejo.codigo_filial = ?strCodigoFilialRetornoReservaRelaciona and loja_reserva.numero_reserva = ?strRetornoReservaRelaciona 
	ENDTEXT

	Return sqlExecuteLocalMsg(strUpdateRelacionaNfRetornoReserva,"Erro ao relacionar nota fiscal gerada com a Reserva do estoque. ",bNaoMostrarCriticas)
Endfunc