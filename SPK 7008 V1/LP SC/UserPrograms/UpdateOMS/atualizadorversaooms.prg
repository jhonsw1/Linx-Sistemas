PROCEDURE AtualizadorVersaoOMS

***** Upgrade Emergencial OMS ******

*------- Dependences
* main.Events.NewEvent
* SQLExecute
* ShowProgress
* MsgBox
*------- Fim - Dependences

#Define ERROR_INSUFFICIENT_BUFFER   0x7A

* Service Control Manager object specific access types
#Define SC_MANAGER_CONNECT             0x0001
#Define SC_MANAGER_CREATE_SERVICE      0x0002
#Define SC_MANAGER_ENUMERATE_SERVICE   0x0004
#Define SC_MANAGER_LOCK                0x0008
#Define SC_MANAGER_QUERY_LOCK_STATUS   0x0010
#Define SC_MANAGER_MODIFY_BOOT_CONFIG  0x0020

* Service object specific access type
#Define SERVICE_QUERY_CONFIG           0x0001
#Define SERVICE_CHANGE_CONFIG          0x0002
#Define SERVICE_QUERY_STATUS           0x0004
#Define SERVICE_ENUMERATE_DEPENDENTS   0x0008
#Define SERVICE_START                  0x0010
#Define SERVICE_STOP                   0x0020
#Define SERVICE_PAUSE_CONTINUE         0x0040
#Define SERVICE_INTERROGATE            0x0080
#Define SERVICE_USER_DEFINED_CONTROL   0x0100

* Service State -- for CurrentState
#Define SERVICE_STOPPED                0x00000001
#Define SERVICE_START_PENDING          0x00000002
#Define SERVICE_STOP_PENDING           0x00000003
#Define SERVICE_RUNNING                0x00000004
#Define SERVICE_CONTINUE_PENDING       0x00000005
#Define SERVICE_PAUSE_PENDING          0x00000006
#Define SERVICE_PAUSED                 0x00000007

#Define SERVICE_DISABLED_NAME          "DISABLED"

#Define SERVICE_STOPPED_NAME           "STOPPED"
#Define SERVICE_START_PENDING_NAME     "START_PENDING"
#Define SERVICE_STOP_PENDING_NAME      "STOP_PENDING"
#Define SERVICE_RUNNING_NAME           "RUNNING"
#Define SERVICE_CONTINUE_PENDING_NAME  "CONTINUE_PENDING"
#Define SERVICE_PAUSE_PENDING_NAME     "PAUSE_PENDING"
#Define SERVICE_PAUSED_NAME            "PAUSED"

#Define _LIMITE_WAIT_SERVICE_STATUS				100 && Numero de tentativas para aguardar servico. O tempo de espera é igual a _LIMITE_WAIT_SERVICE_STATUS * _DELAY_CHECK_WAIT_SERVICE_STATUS
#Define _DELAY_CHECK_WAIT_SERVICE_STATUS		300 && Tempo de delay entre tentativas de verificacao do status do servido do windows (aguardar para parar ou iniciar)

#Define _SERVICE_OMS_NAME				"LinxPOSOMSService"	&& Nome do serivo windows que sera parado para substituir a DLL

#Define _TRY_SLEEP_IO					300 && tempo em milisegundos para tentativas de leitura/escrita/exclusao de arquivos (delay para tentar novamente)
#Define _LIMITE_TENTATIVAS_IO 			8

TRY
	Initialize()
	CheckVersionOms()
Catch To oException
	MsgBox(oException.Message,16,"Falha na verificação de versão LinxOMS")
Finally
	ShowProgress()
	DestroyOMS()
Endtry

ENDPROC

	Procedure Initialize
		
		PUBLIC LastException as Exception

		LoadDependences()

		CreateEventTypeLinx()

	Endproc

	Procedure DestroyOMS

		DeallocateDependeces()

	Endproc

	Procedure CreateEventTypeLinx
		TRY 
			Local strCommandSQL As String
			TEXT TO strCommandSQL NOSHOW TEXTMERGE
	if not exists(select top 1 1 from dbo.LOJA_LX_EVENTOS_TIPOS  where tipo_evento = 120)
	 insert into dbo.LOJA_LX_EVENTOS_TIPOS
	 (TIPO_EVENTO
	,DESCRICAO
	,MODULO_EVENTO
	,DATA_PARA_TRANSFERENCIA)
	values (120,'Atualizacao LinxOMS',1,getdate())
			ENDTEXT

			SqlExecute(strCommandSQL ,"Falha ao criar tipo de evento para atualizacao do LinxOMS")
		CATCH
		ENDTRY 
		
	Endproc


	Procedure LoadDependences

		Declare Sleep In WIN32API Integer

		Declare Long OpenSCManager In Advapi32 String lpMachineName, String lpDatabaseName, Long dwDesiredAccess
		Declare Long OpenService In Advapi32 Long hSCManager, String lpServiceName, Long dwDesiredAccess
		Declare Long QueryServiceStatus In Advapi32 Long hService, String @ lpServiceStatus
		Declare Long CloseServiceHandle  In Advapi32 Long hSCObject
		Declare Integer QueryServiceConfig In Advapi32.Dll Integer, String@, Integer, Integer@
		Declare Integer OpenSCManager In Advapi32.Dll Integer, Integer, Integer
		Declare Integer GetLastError In Kernel32.Dll

	Endproc

	Procedure DeallocateDependeces

		Clear Dlls "OpenSCManager", "OpenService", "QueryServiceStatus", "CloseServiceHandle", "QueryServiceConfig", "OpenSCManager", "GetLastError"

	Endproc


	Procedure CheckVersionOms

		ShowMessage("Verificando Versão OMS...")
		Local strPathService As String

		strPathService = GetPathService()

		If Empty(Alltrim(Nvl(strPathService,"")))
			ShowMessage("OMS não encontrado na máquina...")
			ShowMessage()
			Return .T.
		Endif

		Local Array arAtualizar[6,3]

		*!* 2.12.1
		arAtualizar[1,1] = "\LinxPOSOMS.Core.dll"
		arAtualizar[1,2] = "2.12.1.0"
		arAtualizar[1,3] = "..\UserPrograms\UpdateOMS\UpgradeOms\2.12.1\LinxPOSOMS.Core.dll"
		arAtualizar[2,1] = "\LinxPOSOMS.DataAccess.dll"
		arAtualizar[2,2] = "2.12.1.0"
		arAtualizar[2,3] = "..\Userprograms\UpdateOMS\UpgradeOms\2.12.1\LinxPOSOMS.DataAccess.dll"
		arAtualizar[3,1] = "\LinxPOSOMS.Repository.dll"
		arAtualizar[3,2] = "2.12.1.0"
		arAtualizar[3,3] = "..\Userprograms\UpdateOMS\UpgradeOms\2.12.1\LinxPOSOMS.Repository.dll"

		*!* 2.13.4
		arAtualizar[4,1] = "\LinxPOSOMS.Core.dll"
		arAtualizar[4,2] = "2.13.4.0"
		arAtualizar[4,3] = "..\Userprograms\UpdateOMS\UpgradeOms\2.13.4\LinxPOSOMS.Core.dll"
		arAtualizar[5,1] = "\LinxPOSOMS.DataAccess.dll"
		arAtualizar[5,2] = "2.13.4.0"
		arAtualizar[5,3] = "..\Userprograms\UpdateOMS\UpgradeOms\2.13.4\LinxPOSOMS.DataAccess.dll"
		arAtualizar[6,1] = "\LinxPOSOMS.Repository.dll"
		arAtualizar[6,2] = "2.13.4.0"
		arAtualizar[6,3] = "..\Userprograms\UpdateOMS\UpgradeOms\2.13.4\LinxPOSOMS.Repository.dll"

*!*				Local Array arAtualizar[1,3]

*!*				*!* 2.13.4
*!*				arAtualizar[1,1] = "\LinxPOSOMS.Core.dll"
*!*				arAtualizar[1,2] = "2.13.4.0"
*!*				arAtualizar[1,3] = "..\Userprograms\UpgradeOms\2.13.4\LinxPOSOMS.Core.dll"
*!*				arAtualizar[2,1] = "\LinxPOSOMS.DataAccess.dll"
*!*				arAtualizar[2,2] = "2.13.4.0"
*!*				arAtualizar[2,3] = "..\Userprograms\UpgradeOms\2.13.4\LinxPOSOMS.Core.dll"
*!*				arAtualizar[3,1] = "\LinxPOSOMS.Repository.dll"
*!*				arAtualizar[3,2] = "2.13.4.0"
*!*				arAtualizar[3,3] = "..\Userprograms\UpgradeOms\2.13.4\LinxPOSOMS.Repository.dll"

SET STEP ON

		Local _k As Integer, strFile As String,strFileVersion As String,bNeedsUpgrade As Boolean,;
			strBackupDllFile As String,bArquivoUpgradeNaoEncontrado as Boolean 

		*!* Verifica se algum arquivos esta na versao errada
		For _k = 1 To Alen(arAtualizar,1)

			strFile = strPathService + arAtualizar[_k,1]

			If File(strFile)
				strFileVersion = GetFileVersion(strFile)

				AddEventMessage("Versao arquivo OMS: "+Justfname(strFile)+" - "+strFileVersion )

				If strFileVersion == arAtualizar[_k,2]
					bNeedsUpgrade = .T.
					
					*!* Valida se arquivo do upgrade existe para atualizacao
					IF .Not. FILE(arAtualizar[_k,3])
						bArquivoUpgradeNaoEncontrado = .t.
					Endif
				Endif
			Endif
		Endfor
		*!* Fim - Verifica se algum arquivos esta na versao errada

		If .Not. bNeedsUpgrade
			ShowMessage()
			RELEASE arAtualizar
			Return .T.
		Endif
		
		If bArquivoUpgradeNaoEncontrado
			MsgBox("Falha na atualização do serviço OMS\nArquivo de nova versão não encontrado na pasta do Userprograms.",48,"Upgrade OMS")
			ShowMessage()
			
			Return .F.
		Endif
		
		AddEventMessage("Upgrade OMS necessário. Iniciando atualizacao pelo Userprograms")

		ShowMessage("Atualizando Versão OMS...")
		
		Local bNeedsRestart as Boolean,strServiceState as String
		bNeedsRestart = .t.
		strServiceState = GetStatusService(_SERVICE_OMS_NAME)
		
		IF .Not. strServiceState == SERVICE_STOPPED_NAME && Aguarda Servico parar para atualizacao
			bNeedsRestart = .t.
			StopServiceAndWait(_SERVICE_OMS_NAME)
		Endif
		
		For _k = 1 To Alen(arAtualizar,1)

			strFile = strPathService + arAtualizar[_k,1]


			If File(strFile)
				strFileVersion = GetFileVersion(strFile)

				If strFileVersion == arAtualizar[_k,2]

					strBackupDllFile = Justpath(strFile)+"\Backup-"+Justfname(strFile)

					If File(strBackupDllFile) && Apaga backup anterior, caso exista
						DeleteFile(strBackupDllFile)
					Endif

					RenameFile(strFile,strBackupDllFile)

					strNewFile = arAtualizar[_k,3]

					CopyFile(strNewFile,strFile)

				ENDIF
				
			Endif
		Endfor
		
		IF bNeedsRestart && Startar apenas se tiver parado pelo proprio codigo para evitar subir processos desativados
			StartServiceAndWait(_SERVICE_OMS_NAME)
		Endif
		
		strServiceState = GetStatusService(_SERVICE_OMS_NAME)
		
		AddEventMessage("Status Servico OMS: "+strServiceState)
		
		ShowMessage()
		
		RELEASE arAtualizar

	Endproc


	Procedure DeleteFile
		Lparameters strFilePath As String

		Local bSucesso As Boolean,nTentativas As Number
		bSucesso = .F.
		nTentativas = 0
		Do While .Not.bSucesso .And. nTentativas < _LIMITE_TENTATIVAS_IO
			nTentativas = nTentativas + 1
			bSucesso = TryDeleteFile(strFilePath)

		Enddo

		Return bSucesso

	Endproc


	Procedure TryDeleteFile
		Lparameters strFilePath As String

		Local bSucesso As Boolean
		bSucesso = .F.

		Try
			Delete File (strFilePath)
			bSucesso = .T.
		Catch To oException
			LastException = oException
			Sleep(_TRY_SLEEP_IO)
		Endtry

		Return bSucesso

	Endproc

	Procedure RenameFile
		Lparameters strFileOrigin As String, strFileDestination As String

		Local bSucesso As Boolean,nTentativas As Number
		bSucesso = .F.
		nTentativas = 0
		Do While .Not.bSucesso .And. nTentativas < _LIMITE_TENTATIVAS_IO
			nTentativas = nTentativas + 1
			bSucesso = TryRenameFile(strFileOrigin ,strFileDestination )

		Enddo

		Return bSucesso
	Endproc


	Procedure TryRenameFile
		Lparameters strFileOrigin As String, strFileDestination As String

		Local bSucesso As Boolean
		bSucesso = .F.

		Try
			Rename (strFileOrigin ) To (strFileDestination )
			bSucesso = .T.
		Catch To oException
			LastException = oException
			Sleep(_TRY_SLEEP_IO)
		Endtry

		Return bSucesso

	Endproc

	Procedure CopyFile
		Lparameters strFileOrigin As String, strFileDestination As String

		Local bSucesso As Boolean,nTentativas As Number
		bSucesso = .F.
		nTentativas = 0
		Do While .Not.bSucesso .And. nTentativas < _LIMITE_TENTATIVAS_IO
			nTentativas = nTentativas + 1
			bSucesso = TryCopyFile(strFileOrigin ,strFileDestination )

		Enddo

		Return bSucesso

	Endproc


	Procedure TryCopyFile
		Lparameters strFileOrigin As String, strFileDestination As String

		Local bSucesso As Boolean
		bSucesso = .F.

		Try
			Copy File (strFileOrigin ) To (strFileDestination )
			bSucesso = .T.
		Catch To oException
			LastException = oException
			Sleep(_TRY_SLEEP_IO)
		Endtry

		Return bSucesso
	Endproc


	Procedure AddEventMessage
		Lparameters strMensagem As String

		Try
			Main.Events.NewEvent(_EVENT_TYPE_LINX,Null,strMensagem+" ["+sys(0)+"]")
		Catch
		Endtry

	Endproc

	Procedure ShowMessage
		Lparameters strMensagem

		ShowProgress(strMensagem)

	Endproc


	Procedure GetFileVersion
		Lparameters strFilePath As String

		Local Array aDadosArquivo[1]
		Agetfileversion(aDadosArquivo,strFilePath)
		local vRetorno as Variant
		vRetorno = aDadosArquivo[4]
		RELEASE aDadosArquivo
		Return vRetorno
	Endproc

	Procedure StartServiceAndWait
		Lparameters lcServiceName As String

		StartService(lcServiceName )

		Return WaitService(lcServiceName,SERVICE_RUNNING_NAME)

	Endproc

	Procedure WaitService
		Lparameters lcServiceName As String, statusName As String

		Local strStatusService As String,iCount As Integer
		strStatusService = GetStatusService(lcServiceName)
		iCount = 1

		Do While .Not. strStatusService == statusName .And. iCount < _LIMITE_WAIT_SERVICE_STATUS
			Sleep(_DELAY_CHECK_WAIT_SERVICE_STATUS)
			iCount = iCount + 1
			strStatusService = GetStatusService(lcServiceName)
		Enddo

		Return strStatusService == statusName
	Endfunc

	Procedure StartService
		Lparameters lcServiceName As String

		Local Os1 As Object
		Os1 = Createobject("Shell.Application")
		Return Os1.ServiceStart(lcServiceName , .T.)


	Endproc

	Procedure StopServiceAndWait
		Lparameters lcServiceName As String

		StopService(lcServiceName )

		Return WaitService(lcServiceName,SERVICE_STOPPED_NAME)

	Endproc


	Procedure StopService
		Lparameters lcServiceName As String

		Local Os1 As Object
		Os1 = Createobject("Shell.Application")
		Return Os1.ServiceStop(lcServiceName , .T.)


	Endproc

	Procedure GetStatusService
		Lparameters lcServiceName As String

		lhSCManager = OpenSCManager(0, 0, SC_MANAGER_CONNECT + SC_MANAGER_ENUMERATE_SERVICE)
		If lhSCManager = 0
			* Error
		Endif
		* lcServiceName = "MSSQLSERVER"

		lhSChandle = OpenService(lhSCManager, lcServiceName, SERVICE_QUERY_STATUS)

		If lhSCManager = 0
			* Error
		Endif

		lcQueryBuffer = Replicate(Chr(0), 4*7 )
		lnRetVal = QueryServiceStatus(lhSChandle, @lcQueryBuffer )
		If lnRetVal = 0
			* Error
		Endif
		* Close Handles
		CloseServiceHandle(lhSChandle)
		CloseServiceHandle(lhSCManager)
		lnServiceStatus = Asc(Substr(lcQueryBuffer,5,1))
	
		Do Case
			Case lnServiceStatus = SERVICE_STOPPED
				Return SERVICE_STOPPED_NAME

			Case lnServiceStatus = SERVICE_START_PENDING
				Return SERVICE_START_PENDING_NAME

			Case lnServiceStatus = SERVICE_STOP_PENDING
				Return SERVICE_STOP_PENDING_NAME

			Case lnServiceStatus = SERVICE_RUNNING
				Return SERVICE_RUNNING_NAME

			Case lnServiceStatus = SERVICE_CONTINUE_PENDING
				Return SERVICE_CONTINUE_PENDING_NAME

			Case lnServiceStatus = SERVICE_PAUSE_PENDING
				Return SERVICE_PAUSE_PENDING_NAME

			Case lnServiceStatus = SERVICE_PAUSED
				Return SERVICE_PAUSED_NAME

			Case lnServiceStatus = SERVICE_PAUSED_NAME
				Return SERVICE_STOPPED_NAME

			Otherwise
				Return "OTHER"
		Endcase

	Endproc


	Procedure GetPathService
		Lparameters strService As String

		If Pcount()==0
			strService = _SERVICE_OMS_NAME
		Endif

		Return GetWinServicePath(strService)

	Endproc

*!*		Hidden 
		Procedure GetWinServicePath
		Lparameters tcServiceName As String

		Local lcResult, lnManager, lnService, lcBuffer, lnSize

		lcResult = ""
		lnManager = OpenSCManager(0, 0, SC_MANAGER_CONNECT)
		If lnManager <> 0
			lnService = OpenService(lnManager, tcServiceName, SERVICE_QUERY_CONFIG)
			If lnService <> 0 Then
				lcBuffer = ""
				lnSize = 0
				If QueryServiceConfig(lnService, @lcBuffer, 0, @lnSize) = 0 And GetLastError() = ERROR_INSUFFICIENT_BUFFER
					lcBuffer = Space(lnSize)
					If QueryServiceConfig(lnService, @lcBuffer, lnSize, 2) = 1
						lcResult = Justpath(Substr(lcBuffer, 37, Atc(["], Substr(lcBuffer, 38)) + 1))
					Endif
				Endif
				CloseServiceHandle(lnService)
			Endif
			CloseServiceHandle(lnManager)
		Endif

		Return lcResult
	Endproc

