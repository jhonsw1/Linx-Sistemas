   �   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=2
                         Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               %str(curReportPar.installmentcontract)                         Arial                                                         curReportPar.date                                             Arial                                                         curReportpar.OriginalAmount                                   "99 999.99"                                                   Arial                                                         STR(curReport.idContract)                                     Arial                                                         Ciif(empty(nvl(curCliente.cpf_cgc,'')),documento,curCliente.cpf_cgc)                                                           Arial                                                         !dadosCliente or !empty(documento)                             "CONTRATO:"                                                   Arial                                                         
"CLIENTE:"                                                    Arial                                                         
"PARCELA:"                                                    Arial                                                         "VENCIMENTO:"                                                 Arial                                                         "VALOR:"                                                      Arial                                                         Wbc_code128(allt(str(curReport.idContract))+allt(str(curReportPar.installmentcontract)))                                       BC C128 HD Wide                                               !curReportPar.paid                                            UPPER(curReport.customer)                                     Arial                                                         "CPF:"                                                        Arial                                                         dadosCliente                                                  
"EMISS�O:"                                                    Arial                                                         curReport.emission                                            Arial                                                         "VALOR TOTAL:"                                                Arial                                                         curReport.amount                                              "999 999.99"                                                  Arial                                                         "LOJA:"                                                       Arial                                                         curReport.store                                               Arial                                                         "PARCELA PAGA!"                                               Arial                                                         curReportPar.paid                                             "OBRIGADO PELA PREFER�NCIA!"                                  Arial                                                         "VENDEDOR:"                                                   Arial                                                         
(logotipo)                                                    
vendedores                                                    Arial                                                         wLogo                                                         2'..\LinxPOS\Sources\Resources\Images\LinxLogo.png'            2'..\LinxPOS\Sources\Resources\Images\LinxLogo.png'            Arial                                                         Times New Roman                                               Arial                                                         Arial                                                         Arial                                                         Arial                                                         BC C128 HD Wide                                               Arial                                                         dataenvironment                                               _Top = 33
Left = 71
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                              �PROCEDURE Init
**Carlos G. Gon�alves - Crediario Online Carn�
local strReportLocation as String
PUBLIC dadosCliente
dadosCliente = .f.

PUBLIC logotipo , vendedores, documento, strDefaultDir  
vendedores = ''

strDefaultDir  = ALLTRIM(main.SystemPath)

logotipo = strDefaultDir + "Reports\chargeaccountlinxLogo.png"
if !file(logotipo)
	MsgBox('Logo n�o encontrado: ' + logotipo , 64 ,'Aten��o')
	return .f.
endif

IF SqlSelect("select ISNULL(cpf_cgc,'') as cpf_cgc from clientes_varejo where codigo_cliente = ?curreport.customercode",'cur1',ALIAS())
	documento = NVL(cur1.cpf_cgc,'')
endif


IF SqlSelect("select dbo.[fn_retornaVendedorContrato](?curReport.idContract) as retorno",'cur',ALIAS())
	vendedores = NVL(cur.retorno,'')
endif

strReportLocation = addbs(main.SystemPath) + "Reports\BarcodePrintFunctions.prg"

set proce to "&strReportLocation" additive

IF USED('curCliente')
	dadosCliente = .t.
	SELECT curcliente 
	INDEX on codigo_cliente TAG dffd
	go top
endif

select curReport
INDEX on idContract TAG io
go top


select curReportPar
INDEX on installmentcontract TAG ido 
SET RELATION TO idcontract INTO curReport
go top



ENDPROC
                  ����    �  �                        �N   %         S  "             �  U  � ��  Q� STRING� 7� � T� �-�� 7� � � � � T� ��  �� T� �C� � ���2 T� �� �! Reports\chargeaccountlinxLogo.png�� %�C� 0
��� �3 ��C� Logo n�o encontrado: � �@� Aten��o� �� B�-�� �� %�C�h select ISNULL(cpf_cgc,'') as cpf_cgc from clientes_varejo where codigo_cliente = ?curreport.customercode� cur1C�	 ��l� T� �C�
 � �  ��� �b %�C�I select dbo.[fn_retornaVendedorContrato](?curReport.idContract) as retorno� curC�	 ���� T� �C� � �  ��� �8 T�  �C� � ���! Reports\BarcodePrintFunctions.prg��. set proce to "&strReportLocation" additive
 %�C�
 curCliente����� T� �a�� F� � & �� ��� � #)� � F� � & �� ��� � #)� F� � & �� ��� � G-(�� ��� � #)� U  STRREPORTLOCATION DADOSCLIENTE LOGOTIPO
 VENDEDORES	 DOCUMENTO STRDEFAULTDIR MAIN
 SYSTEMPATH MSGBOX	 SQLSELECT CUR1 CPF_CGC CUR RETORNO
 CURCLIENTE CODIGO_CLIENTE DFFD	 CURREPORT
 IDCONTRACT IO CURREPORTPAR INSTALLMENTCONTRACT IDO Init,     ��1 q � 2� ""1q A "QA #QA ���� q � Q A r � Q s � � Q 4                       �      )   �                           %ORIENTATION=0
PAPERSIZE=9
COLOR=2
                         Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               %str(curReportPar.installmentcontract)                         Arial                                                         curReportPar.date                                             Arial                                                         curReportpar.OriginalAmount                                   "99 999.99"                                                   Arial                                                         STR(curReport.idContract)                                     Arial                                                         Ciif(empty(nvl(curCliente.cpf_cgc,'')),documento,curCliente.cpf_cgc)                                                           Arial                                                         !dadosCliente or !empty(documento)                             "CONTRATO:"                                                   Arial                                                         
"CLIENTE:"                                                    Arial                                                         
"PARCELA:"                                                    Arial                                                         "VENCIMENTO:"                                                 Arial                                                         "VALOR:"                                                      Arial                                                         Wbc_code128(allt(str(curReport.idContract))+allt(str(curReportPar.installmentcontract)))                                       BC C128 HD Wide                                               !curReportPar.paid                                            UPPER(curReport.customer)                                     Arial                                                         "CPF:"                                                        Arial                                                         dadosCliente                                                  
"EMISS�O:"                                                    Arial                                                         curReport.emission                                            Arial                                                         "VALOR TOTAL:"                                                Arial                                                         curReport.amount                                              "999 999.99"                                                  Arial                                                         "LOJA:"                                                       Arial                                                         curReport.store                                               Arial                                                         "PARCELA PAGA!"                                               Arial                                                         curReportPar.paid                                             "OBRIGADO PELA PREFER�NCIA!"                                  Arial                                                         "VENDEDOR:"                                                   Arial                                                         
(logotipo)                                                    
vendedores                                                    Arial                                                         wLogo                                                         2'..\LinxPOS\Sources\Resources\Images\LinxLogo.png'            2'..\LinxPOS\Sources\Resources\Images\LinxLogo.png'            Arial                                                         Times New Roman                                               Arial                                                         Arial                                                         Arial                                                         Arial                                                         BC C128 HD Wide                                               Arial                                                         dataenvironment                                               _Top = 33
Left = 71
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                              �PROCEDURE Init
**Carlos G. Gon�alves - Crediario Online Carn�
local strReportLocation as String
PUBLIC dadosCliente
dadosCliente = .f.

PUBLIC logotipo , vendedores, documento, strDefaultDir  
vendedores = ''

strDefaultDir  = ALLTRIM(main.SystemPath)

logotipo = strDefaultDir + "Reports\chargeaccountlinxLogo.png"
if !file(logotipo)
	MsgBox('Logo n�o encontrado: ' + logotipo , 64 ,'Aten��o')
	return .f.
endif

IF SqlSelect("select ISNULL(cpf_cgc,'') as cpf_cgc from clientes_varejo where codigo_cliente = ?curreport.customercode",'cur1',ALIAS())
	documento = NVL(cur1.cpf_cgc,'')
endif


IF SqlSelect("select dbo.[fn_retornaVendedorContrato](?curReport.idContract) as retorno",'cur',ALIAS())
	vendedores = NVL(cur.retorno,'')
endif

strReportLocation = addbs(main.SystemPath) + "Reports\BarcodePrintFunctions.prg"

set proce to "&strReportLocation" additive

IF USED('curCliente')
	dadosCliente = .t.
	SELECT curcliente 
	INDEX on codigo_cliente TAG dffd
	go top
endif

select curReport
INDEX on idContract TAG io
go top


select curReportPar
INDEX on installmentcontract TAG ido 
SET RELATION TO idcontract INTO curReport
go top



ENDPROC
                  ����    �  �                        �N   %         S  "             �  U  � ��  Q� STRING� 7� � T� �-�� 7� � � � � T� ��  �� T� �C� � ���2 T� �� �! Reports\chargeaccountlinxLogo.png�� %�C� 0
��� �3 ��C� Logo n�o encontrado: � �@� Aten��o� �� B�-�� �� %�C�h select ISNULL(cpf_cgc,'') as cpf_cgc from clientes_varejo where codigo_cliente = ?curreport.customercode� cur1C�	 ��l� T� �C�
 � �  ��� �b %�C�I select dbo.[fn_retornaVendedorContrato](?curReport.idContract) as retorno� curC�	 ���� T� �C� � �  ��� �8 T�  �C� � ���! Reports\BarcodePrintFunctions.prg��. set proce to "&strReportLocation" additive
 %�C�
 curCliente����� T� �a�� F� � & �� ��� � #)� � F� � & �� ��� � #)� F� � & �� ��� � G-(�� ��� � #)� U  STRREPORTLOCATION DADOSCLIENTE LOGOTIPO
 VENDEDORES	 DOCUMENTO STRDEFAULTDIR MAIN
 SYSTEMPATH MSGBOX	 SQLSELECT CUR1 CPF_CGC CUR RETORNO
 CURCLIENTE CODIGO_CLIENTE DFFD	 CURREPORT
 IDCONTRACT IO CURREPORTPAR INSTALLMENTCONTRACT IDO Init,     ��1 q � 2� ""1q A "QA #QA ���� q � Q A r � Q s � � Q 4                       �      )   �                     