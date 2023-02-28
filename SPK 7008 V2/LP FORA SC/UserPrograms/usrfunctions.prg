*## Hering Userprograms Versao: 20230216
*## TIPO_FILIAL: PROPRIA
*## VERSAO_MIDE: 1.0.59
*--- Nao retirar a linha da versao


Define Class UserHering As Custom	
	
	Procedure VerificaSeJaEstaEmexecucao
		
		IF _vfp.StartMode == 0
			Return .t.
		Endif
		
		IF CountProcessByName("LPMLib.exe") > 1
			ShowProgress("O Aplicativo j� est� em execu��o")
			sleep(3000)
			ShowProgress()
			Main.ExitCommand()
			Quit
			Clear events
		Endif
		
		Return .t.
	Endproc 	
		
		*** Fim - Verifica se Existem notas Pendentes
	
	
	Procedure MsgTransitoPendente() As Boolean && Verifica Notas em Transito
		Local strConsultaTransito As String,bRetorno As Boolean
		bRetorno = .T.
		TEXT TO strConsultaTransito NOSHOW
			select COUNT(*) numeroDeNotasEmTransito
			from LOJA_TRANSITO
			where LANCADO_LOJA = 0
				and EMISSAO <= dateadd(day,-21,getdate())
				and QTDE_TOTAL > 0
				and FILIAL = ?main.p_filial
		ENDTEXT

		If SQLSelect(strConsultaTransito ,[CurTransito],[Erro ao consultar notas em transito.\n\nVerifique se existem notas em transito.])
			Select CurTransito
			Go Top
			If Reccount("CurTransito")==0
				MsgBox([Erro ao consultar notas em transito.\n\nVerifique se existem notas em transito.],-48,[Aten��o])
			Endif
			If CurTransito.numeroDeNotasEmTransito >0
				MsgBox([A loja possui ]+Alltrim(Str(CurTransito.numeroDeNotasEmTransito))+[ notas fiscais a mais de 20 dias pendentes no tr�nsito. \n\nFavor entrar em contato com a retaguarda.],-48,[Aten��o])
				bRetorno = .F.
			Endif
			Use In CurTransito
		Endif
		Return bRetorno
	Endproc
		
Enddefin

*** hrInputBox
Function hrInputBox(strInfo As String,strTitulo As String,strDado As String) As String
	Local strRetorno As String,hrInputBox As Form

	hrInputBox = Createobject("hrInputBox",strInfo,strTitulo,strDado)
	hrInputBox.Show()
	strRetorno = hrInputBox.Unload()
	hrInputBox.Release

	Return strRetorno
Endfunc


Define Class hrInputBox As Form

	BorderStyle = 2
	Height = 78
	Width = 391
	ShowWindow = 1
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "T�tulo"
	ControlBox = .F.
	WindowState = 0
	WindowType = 1

	p_retorno = ""
	Name = "hrInputBox"


	Add Object cmd_ok As CommandButton With ;
		Top = 51, ;
		Left = 252, ;
		Height = 23, ;
		Width = 62, ;
		FontSize = 7, ;
		Caption = "OK", ;
		Name = "cmd_ok"


	Add Object cmd_cancelar As CommandButton With ;
		Top = 51, ;
		Left = 318, ;
		Height = 23, ;
		Width = 62, ;
		FontSize = 7, ;
		Caption = "Cancelar", ;
		Name = "cmd_cancelar"


	Add Object tx_dados_retorno As TextBox With ;
		ControlSource = "thisform.p_retorno", ;
		Height = 23, ;
		Left = 7, ;
		Top = 24, ;
		Width = 374, ;
		Name = "tx_dados_retorno"


	Add Object lb_info As Label With ;
		Caption = "lb_info", ;
		Left = 12, ;
		Top = 10, ;
		Name = "lb_info", ;
		BackStyle = 0, ;
		AutoSize = .t.


	Procedure Init
		Lparameters strInfo As String,strTitulo As String,strDado As String

		If Type("strInfo")=="N"
			strInfo = Transform(strInfo )
		Endif

		If Type("strTitulo")=="N"
			strTitulo = Transform(strTitulo)
		Endif

		Thisform.lb_info.Caption = Nvl(Evl(strInfo ,Null),"Entre com a informa��o necess�ria")
		Thisform.Caption = Nvl(Evl(strTitulo ,Null),"Informa��o")
		Thisform.p_retorno = Nvl(Evl(strDado ,Null),"")
	Endproc


	Procedure cmd_ok.Click
		Thisform.Hide()
	Endproc


	Procedure cmd_cancelar.Click
		Thisform.p_retorno=""
		Thisform.Hide()
	Endproc


	Procedure Unload
		Return Thisform.p_retorno
	Endproc

Enddefine
*** Fim - hrInputBox

Procedure CountProcessByName(tcProcessID)
	Local nCount As Number
	nCount = 0
	If Vartype(tcProcessID) = 'C' And Not Empty(tcProcessID)
		loService = Getobject("winmgmts://./root/cimv2")
		loProcesses = loService.ExecQuery([SELECT name,* FROM Win32_Process WHERE Name = '] + Alltrim(tcProcessID) + ['])
		For Each loProcess In loProcesses
			*!*  loProcess.Terminate(0)
			nCount = nCount +1
		Next
	Endif
	Return nCount
Endproc

** M�todos CRM - Compatilhado

FUNCTION getCNPJLojas()
	PARAMETERS codigoFilial as String
	TEXT TO strCNPJFilial NOSHOW
		SELECT CGC_CPF AS CNPJ
		FROM FILIAIS
		WHERE COD_FILIAL = RTRIM(?codigoFilial)
	ENDTEXT
	
	IF !SQLSelect(strCNPJFilial, [curFilialDados])
		RETURN ""				
	ENDIF
	
	RETURN curFilialDados.CNPJ
ENDFUNC

FUNCTION getStringConexaoCSharp() as String
	PARAMETERS AppName as string
	RETURN "server="+ALLTRIM(Main.Data.SQLServer)+";"+;
		    iif(!Main.Data.WindowsAuthentication, ;                    
			"user id="+ALLTRIM(Main.Data.SQLUSername)+";" +;
			'password=' + Main.StringBuffer.LoadBuffer(Main.StringBuffer.BuildBuffer(), Main.Data.SQLPassword)+";", +;
		    " Trusted_Connection=yes;")+;
	        "connection timeout=10;" +;
	        "database="++ Alltrim(Main.Data.SQLDatabase)+";"+;
	        "Application Name="+ALLTRIM(AppName)+";"+;
	        "Pooling=false;"
ENDFUNC

FUNCTION getBuscarCliente() as Boolean
	PARAMETERS strCodigoFilial as String, ;
			   strCpfCNPJ as STRING
			   
	TEXT TO strBuscaClienteCRM NOSHOW
		SELECT FX_HR_CRM_CONSULTA_CLIENTE.ATUALIZA_CRM 
		FROM DBO.[FX_HR_CRM_CONSULTA_CLIENTE](?strCodigoFilial, ?strCpfCNPJ)	
	ENDTEXT				
	
	IF !SQLSELECT(strBuscaClienteCRM, [curAtualizaCRM])
		RETURN .F.	
	ENDIF
	
	IF RECCOUNT("curAtualizaCRM") = 0 THEN
		RETURN .F.
	ENDIF	

	RETURN curAtualizaCRM.ATUALIZA_CRM 

ENDFUNC
** FIM - M�todos CRM - Compatilhado

** M�todos CRM - Cliente CRM

Procedure ValidarEmailSafetyMail() As Custom
	Parameters strCodigoFilial As String, strEmail As String
	
	Local oRetorno As Custom
	Local iOldAlias as Integer
	iOldAlias = Select()
	
	oRetorno = CreateObject("Custom")
	oRetorno.AddProperty("EmailValido",.T.)
	oRetorno.AddProperty("Mensagem","N�o Foi poss�vel validar e-mail")

	Try
		strUrl = Rtrim(Main.P_HR_CRM_URL_SafetyMail)
		strToken = Rtrim(Main.P_HR_CRM_token_SafetyMail)
		
		*!* Busca CNPJ
		strCnpj = .Null.
		paramCodigoFilial = strCodigoFilial
		If sqlSelect("select cgc_cpf from filiais inner join lojas_varejo on lojas_varejo.filial = filiais.filial where codigo_filial = ?paramCodigoFilial","CurCnpjFilial")
			strCnpj = Alltrim(Nvl(CurCnpjFilial.cgc_cpf,""))
		Endif
		*!* Fim - Busca CNPJ
		
		objSafety = Createobject("Hering.SafetyMail")
		oRetornoDll = objSafety.ValidateEmailFilial(strUrl, strToken, strEmail, strCnpj)
		oRetorno.EmailValido = oRetornoDll.Status
		oRetorno.Mensagem = oRetornoDll.Message
		strLog = "Email "+Nvl(strEmail,"{Null}")+" - v�lido: "+Iif(oRetorno.EmailValido,"Sim","N�o")+" - "+Nvl(oRetorno.Mensagem,"")
		
		Main.Events.NewEvent(102, Null, strLog )
	Catch To oError
		Main.Events.NewEvent(102, Null, "Erro na DLL para validar email SafetyMail. Email: "+Nvl(Transform(strEmail),"{Null}")+" Erro: "+Nvl(oError.Message,"Null"))
	Finally
		Use In Select("CurCnpjFilial")
		Select(iOldAlias)
	Endtry

	Return oRetorno
Endproc


** M�todos CRM - Cliente CRM
** Cometado por Otavio e reescrito com melhoria no log

*!*	PROCEDURE ConsultarClienteCrm()	
*!*		PARAMETERS codigoFilial as string, cpfCpf AS string
*!*		TRY
*!*			strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
*!*			strCNPJLoja =  getCNPJLojas(codigoFilial)
*!*			
*!*			IF(getBuscarCliente(codigoFilial ,cpfCpf) ) THEN		
*!*				objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
*!*				objCrm.ConexaoSQL = strConexaoDll 
*!*				objCrm.ConsultarCliente(codigoFilial, strCNPJLoja, cpfCpf)		
*!*			ENDIF
*!*		CATCH TO oError 
*!*			main.events.NewEvent(102, null, "Erro na DLL para procura do cliente no servidor do CRM. Erro: "+oError.Message)
*!*		ENDTRY	
*!*	ENDPROC

PROCEDURE ConsultarClienteCrm()	
	PARAMETERS codigoFilial as string, cpfCpf AS string
	
	&& Try para abrir a dll
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")		
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro na ao abrir dll Hering.CRM.Foxpro. Erro: "+oError.Message)
	ENDTRY	

	&& Try para consultar a function no banco de dados
	TRY
		strCNPJLoja =  getCNPJLojas(codigoFilial)
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro na consulta do CNPJ da loja, na function FX_HR_CRM_CONSULTA_CLIENTE.ATUALIZA_CRM. Erro: "+oError.Message)
	ENDTRY	

	&& Try para get na api
	TRY		
		IF(getBuscarCliente(codigoFilial ,cpfCpf) ) THEN		
			objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
			objCrm.ConexaoSQL = strConexaoDll 
			objCrm.ConsultarCliente(codigoFilial, strCNPJLoja, cpfCpf)		
		ENDIF
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro na DLL para procura do cliente no servidor do CRM. Erro: "+oError.Message)
	ENDTRY	
ENDPROC
** M�todos CRM - Fim Cliente CRM

** M�todos Novos  CRM - Cliente CRM

FUNCTION ConsultarEmailClienteCrm()	
	PARAMETERS codigoFilial as string, cpfCpf as string, email as string
	objCrmCliente = null
	TRY
		
		strCNPJLoja =  getCNPJLojas(codigoFilial)
				
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_CRM_URL_SERVIDOR
		objCrm.TokenBase = main.P_HR_CRM_TOKEN_ACESSO
		objCrmCliente = objCrm.ConsultarEmailClienteCRM(cpfCpf, ALLTRIM(strCNPJLoja), email)		

	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para consultar e-mail do cliente no servidor do CRM. Erro: "+oError.Message)
	ENDTRY		
	RETURN objCrmCliente 
ENDPROC

FUNCTION ConsultarTelefoneClienteCrm()	
	PARAMETERS codigoFilial as string, cpfCpf as string, ddd as string, telefone as String
	objCrmCliente = null
	TRY
		
		strCNPJLoja =  getCNPJLojas(codigoFilial)

		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_CRM_URL_SERVIDOR
		objCrm.TokenBase = main.P_HR_CRM_TOKEN_ACESSO
		objCrmCliente = objCrm.ConsultarTelefoneClienteCRM(cpfCpf, ALLTRIM(strCNPJLoja), ddd, telefone)	
		
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para consultar telefone do cliente no servidor do CRM. Erro: "+oError.Message)
	ENDTRY
	RETURN objCrmCliente 	
ENDPROC
** M�todos Novos CRM - Fim Cliente CRM


** M�todos Novos MOTOR - Voucher CRM
FUNCTION AtivarVoucherCrm()	
	PARAMETERS idVoucher as string, codigoFilial as string, cpfCliente as string, ticket as string, idVoucherTipo as Integer, idPromocao as Integer,valorVenda as decimal, idTipoGatilho as Integer, textoCampanha as String, dataVenda as String, dataValidade as String, valorVenda as decimal, valor as decimal , valorGatilho as decimal, fisico as Boolean, web as Boolean, omni as Boolean
			
	objMotorVoucher = null
	TRY
			
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.AtivarVoucherCRM(idVoucher, codigoFilial, cpfCliente, ticket, idVoucherTipo, idPromocao, idTipoGatilho, textoCampanha,dataVenda, dataValidade, valorVenda, valor, valorGatilho, fisico, web, omni)		
	
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para ativar voucher no Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION CadastraAtivaVoucherCrm()	
	PARAMETERS idVoucher as string, codigoFilial as string, cpfCliente as string, ticket as string, idVoucherTipo as Integer, idPromocao as Integer, idTipoGatilho as Integer, textoCampanha as String, dataVenda as String, dataValidade as String, valorVenda as decimal, valor as decimal , valorGatilho as decimal, fisico as Boolean, web as Boolean, omni as Boolean
			
	objMotorVoucher = null
	TRY
	
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.CadastraAtivaVoucherCRM(idVoucher, codigoFilial, cpfCliente, ticket, idVoucherTipo, idPromocao, idTipoGatilho, textoCampanha,dataVenda, dataValidade, valorVenda, valor, valorGatilho, fisico, web, omni)		
	
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para cadastrar e ativar voucher no Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION EstornarVoucherCrm()	
	PARAMETERS codigoFilial as String, cpfCliente as String, idVoucher as String, dataVenda as String, ticket as String, valorVenda as Decimal, idPromocao as Integer, fisicoWebOmni as String
	
	objMotorVoucher = null
	TRY
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.EstornarVoucherCRM(codigoFilial, cpfCliente, idVoucher, dataVenda, ticket, valorVenda, idPromocao, fisicoWebOmni)		

	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para estornar voucher do Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION ResgatarVoucherCrm()	
	PARAMETERS codigoFilial as String, cpfCliente as String, idVoucher as String, dataVenda as String, ticket as String, valorVenda as Decimal, idPromocao as Integer, fisicoWebOmni as String
	
	objMotorVoucher = null
	TRY
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.ResgatarVoucherCRM(codigoFilial, cpfCliente, idVoucher, dataVenda, ticket, valorVenda, idPromocao, fisicoWebOmni)		
	
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para resgatar voucher do Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION DesativarVoucherCrm()	
	PARAMETERS codigoFilial as String, cpfCliente as String, idVoucher as String, dataVenda as String, ticket as String, valorVenda as Decimal, idPromocao as Integer, fisicoWebOmni as String
	
	objMotorVoucher = null
	TRY

		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.DesativarVoucherCRM(codigoFilial, cpfCliente, idVoucher, dataVenda, ticket, valorVenda, idPromocao, fisicoWebOmni)		

	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para desativar voucher do Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION ResgatarConfirmaVoucherCrm()	
	PARAMETERS codigoFilial as String, cpfCliente as String, idVoucher as String, dataVenda as String, ticket as String, valorVenda as Decimal, idPromocao as Integer, fisicoWebOmni as String
	
	objMotorVoucher = null
	TRY
			
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.ResgataConfirmaVoucherCRM(codigoFilial, cpfCliente, idVoucher, dataVenda, ticket, valorVenda, idPromocao, fisicoWebOmni)		
		
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para resgatar e confirmar voucher do Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC

FUNCTION ConsultarVoucherCrm()	
	PARAMETERS codigoFilial as String, cpfCliente as String, idVoucher as String, dataVenda as String, ticket as String, valorVenda as Decimal, idPromocao as Integer, fisicoWebOmni as String
	
	objMotorVoucher = null
	TRY

		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ApiUrlBase = main.P_HR_MOTOR_WS_URL_VOUCHER
		objCrm.TokenBase = main.P_HR_MOTOR_WS_TOKEN_VOUCHER
		objMotorVoucher = objCrm.ConsultarVoucherCRM(codigoFilial, cpfCliente, idVoucher, dataVenda, ticket, valorVenda, idPromocao, fisicoWebOmni)		
		
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento para consultar voucher do Motor. Erro: "+oError.Message)
	ENDTRY
			
	RETURN objMotorVoucher
ENDPROC


** M�todos Novos MOTOR - Fim Voucher CRM


** M�todos CRM - Voucher CRM
Function DesativarVoucher()	
	PARAMETERS strCodigoFilial AS string, strCodigoVoucher as String,strCpfCliente as String, dtDataVenda as string, strTicket as String, strValorVoucher as Decimal
		
	objCrmVoucher = null
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCNPJLoja =  getCNPJLojas(strCodigoFilial)
		
				
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		objCrmVoucher  = objCrm.DesativarVoucher(strCNPJLoja , strCodigoFilial ,strCodigoVoucher, strCpfCliente, dtDataVenda, strTicket ,strValorVoucher  )		
		
	CATCH TO oError 
		main.events.NewEvent(102, null, "Erro no procedimento de desativar voucher no servidor de CRM. Erro: "+oError.Message)
		objCrmVoucher = null
	ENDTRY	
	
	RETURN objCrmVoucher 
ENDPROC

Function AtivarVoucher()	
	PARAMETERS strCodigoFilial AS string, strCodigoVoucher as String,strCpfCliente as String, dtDataVenda as string, dtDataValidade as string, strTicket as String,;
	strValorVenda as Decimal, strValorVoucher as Decimal, intTipo as Integer, intIdPromocao as Integer

	objCrmVoucher = null
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCNPJLoja =  getCNPJLojas(strCodigoFilial)
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		objCrmVoucher  = objCrm.AtivarVoucher(  strCNPJLoja , strCodigoFilial ,strCodigoVoucher, strCpfCliente ,;
												dtDataVenda,dtDataValidade ,strTicket ,strValorVenda, strValorVoucher, intTipo, intIdPromocao   )	
																								
												
	CATCH TO oError 
		strMessageErro = "Erro no procedimento de valida��o do voucher. Erro: "+oError.Message
		main.events.NewEvent(102, null, strMessageErro )
		MsgBox(strMessageErro , 16, "Erro")
		objCrmVoucher = null
	ENDTRY	
	
	RETURN objCrmVoucher 
ENDPROC


FUNCTION ConsultarSaldo()
	PARAMETERS strCodigoFilial as String, strCodigoVoucher as String, strCpfCliente as String, dtDataVenda as String, strTicket as String, strValorVenda as Decimal
	
	objCrmVoucher = null
	
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCnpjLoja =  getCNPJLojas(strCodigoFilial)

		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		
		objCrmVoucher  = objCrm.ConsultarSaldo(strCnpjLoja, strCodigoFilial, strCodigoVoucher, strCpfCliente, dtDataVenda, strTicket, strValorVenda)						
	
	CATCH TO oError
		strMessageErro = "Erro no procedimento de consulta de saldo de voucher. Erro: "+oError.Message
		main.events.NewEvent(102, null, strMessageErro )
		MsgBox(strMessageErro , 16, "Erro")
		objCrmVoucher = null
	ENDTRY
	
	
	RETURN objCrmVoucher 
ENDPROC


FUNCTION ResgatarVoucher
	PARAMETERS strCodigoFilial as String, strCodigoVoucher as String, strCpfCliente as String, dtDataVenda as String, strTicket as String, strValorVenda as Decimal, ;
	intIdPromocao as Integer
	
	objCrmVoucher = null
	
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCnpjLoja =  getCNPJLojas(strCodigoFilial)
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		objCrmVoucher  = objCrm.ResgatarVoucher(strCnpjLoja, strCodigoFilial, strCodigoVoucher, strCpfCliente, dtDataVenda, strTicket, strValorVenda, intIdPromocao )						
	CATCH TO oError
		strMessageErro = "Erro no procedimento de regastar de saldo de voucher. Erro: "+oError.Message
		main.events.NewEvent(102, null, strMessageErro )
		MsgBox(strMessageErro , 16, "Erro")
		objCrmVoucher = null	
	ENDTRY
		
	RETURN objCrmVoucher 	
ENDPROC


FUNCTION ConfirmarVoucher
	PARAMETERS strCodigoFilial as String, strCodigoVoucher as String, strCpfCliente as String, dtDataVenda as String, strTicket as String, strValorVenda as Decimal,;
	intIdPromocao  as Integer
	
	objCrmVoucher = null
	
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCnpjLoja =  getCNPJLojas(strCodigoFilial)
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		objCrmVoucher  = objCrm.ConfirmarVoucher(strCnpjLoja, strCodigoFilial, strCodigoVoucher, strCpfCliente, dtDataVenda, strTicket, strValorVenda,intIdPromocao  )						
	CATCH TO oError
		strMessageErro = "Erro no procedimento de confirmar voucher. Erro: "+oError.Message
		main.events.NewEvent(102, null, strMessageErro )
		MsgBox(strMessageErro , 16, "Erro")
		objCrmVoucher = null	
	ENDTRY
		
	RETURN objCrmVoucher 	
ENDPROC


FUNCTION EstornarVoucher
	PARAMETERS strCodigoFilial as String, strCodigoVoucher as String, strCpfCliente as String, dtDataVenda as String, strTicket as String, strValorVenda as Decimal

	objCrmVoucher = null
	
	TRY
		strConexaoDll = getStringConexaoCSharp("Hering.CRM.Foxpro")
		strCnpjLoja =  getCNPJLojas(strCodigoFilial)
		
		objCrm = CREATEOBJECT("Hering.CRM.Foxpro")
		objCrm.ConexaoSQL = strConexaoDll 
		objCrmVoucher  = objCrm.EstornarVoucher(strCnpjLoja, strCodigoFilial, strCodigoVoucher, strCpfCliente, dtDataVenda, strTicket, strValorVenda)
	CATCH TO oError
		strMessageErro = "Erro no procedimento de estornar voucher. Erro: "+oError.Message
		main.events.NewEvent(102, null, strMessageErro )
		MsgBox(strMessageErro , 16, "Erro")
		objCrmVoucher = null	
	ENDTRY
	
		
		
	RETURN objCrmVoucher 
ENDPROC

** M�todos CRM - Fim Voucher CRM

** Procedure para identificar filiais pr�prias

Procedure HrCriaPropriedadeFilialPropria

	If Pemstatus(Main, "hr_indica_filial_propria",5)

		Return.T.


	Endif


	If .Not. SQLSELECT("SELECT TIPO_FILIAL FROM FILIAIS WHERE FILIAL =?main.p_filial","curHrTipoFilial","ERRO AO BUSCAR TIPO DA FILIAL AVISE O SUPORTE")

		Return .F.

	Endif
	
	IF RECCOUNT("curHrTipoFilial") ==0 
		
		MSGBOX("ERRO AO BUSCAR TIPO DA FILIAL AVISE O SUPORTE",0,"ATEN��O")
		return.f.
	
	ENDIF
	
	LOCAL bIndicaFilialPropria as Boolean
	
	bIndicaFilialPropria = (ALLTRIM(curHrTipoFilial.TIPO_FILIAL) == "PROPRIA")
	
	main.addproperty("hr_indica_filial_propria",bIndicaFilialPropria)
	
	RETURN .T.
	

Endproc

