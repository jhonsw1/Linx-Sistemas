  R   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
esenv_1
OUTPUT=IP_192.168.120.96
ORIENTATION=0
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=0
               K  (  winspool  \\a-srv4\HP_Desenv_1  IP_192.168.120.96                                        Courier New                    "Ticket"                       Tahoma                         
!xMovCaixa                     curSalesDetails_tmp.ticket                                      Tahoma                         
!xMovCaixa                     (wLogo)                        !empty(wLogo) and file(wLogo)                                   ''Resumo do caixa por tipo de pagamento'                         Arial                          
!xMovCaixa                     main.p_filial                                                 Arial                          %dtoc(date()) + ' - ' + time() + 'hs.'                                                          Times New Roman                'Pg: ' + alltrim(str(_pageno))                                                                 Arial                          �alltrim(main.productname)+' ' + iif(alltrim(main.productname) == 'LinxB2C', alltrim(main.p_versao_linxb2c), alltrim(main.p_versao_loja))                           Arial                          fiif(type('wCodigoReport')='C',wCodigoReport,'...') + iif(type('wUserReport')='C',' - '+wUserReport,'')                                                           Arial                          curSalesDetails_tmp.valor      "@Z"                           Tahoma                         7iif(!xMovCaixa,ttod(curSalesDetails_tmp.vencimento),'')         "@D"                           Tahoma                         "Vencimento"                   Tahoma                         
!xMovCaixa                     "Valor"                        Tahoma                         "Parc."                        Tahoma                         
!xMovCaixa                     curSalesDetails_tmp.parcela                                     Tahoma                         
!xMovCaixa                     "Informa��es   Adicionais"                                      Tahoma                         Yinlist(curVendas.tipo_pgto,  "C", "P", "A", "B", "E", "I", "K", "N", "R" ) and !xMovCaixa        "nvl(curSalesDetails_tmp.banco, "")                              Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            +nvl(curSalesDetails_tmp.conta_corrente, "")                     Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            $nvl(curSalesDetails_tmp.agencia, "")                            Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Banco:"                       Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Ag:"                          Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Cta:"                         Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            curSalesDetails_tmp.valor      "@Z"                           Tahoma                         
"Total-->"                     Tahoma                         ,nvl(curSalesDetails_tmp.parcelas_cartao, "")                    Tahoma                         Hinlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N") and !xMovCaixa                         "N� Parcelas"                  Tahoma                         Hinlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N") and !xMovCaixa                         $nvl(curSalesDetails_tmp.cpf_cgc, "")                            Tahoma                         9inlist(curVendas.tipo_pgto, "C", "P", "R") and !xMovCaixa       "CPF:"                         Tahoma                         9inlist(curVendas.tipo_pgto, "C", "P", "R") and !xMovCaixa       *nvl(curSalesDetails_tmp.numero_titulo, "")                      Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Nr.Cheque:"                   Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "N� T�tulo:"                   Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 *nvl(curSalesDetails_tmp.numero_titulo, "")                      Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 %nvl(curSalesDetails_tmp.terminal, "")                           Tahoma                         Minlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N", "R") and !xMovCaixa                    "Terminal:"                    Tahoma                         Minlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N", "R") and !xMovCaixa                    curSalesDetails_tmp.data       "@D"                           Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 "Data:"                        Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 "Per�odo Fechamento"           Tahoma                         	xMovCaixa                      "Lan�amento Caixa"             Tahoma                         	xMovCaixa                      "Hist�rico"                    Tahoma                         	xMovCaixa                      &curSalesDetails_tmp.periodo_fechamento                          Tahoma                         	xMovCaixa                      $curSalesDetails_tmp.lancamento_caixa                            Tahoma                         	xMovCaixa                      curSalesDetails_tmp.historico                                   Tahoma                         	xMovCaixa                      "Data"                         Tahoma                         	xMovCaixa                      curSalesDetails_tmp.data       Tahoma                         	xMovCaixa                      !'Resumo de movimenta��o de caixa'                               ""                             Arial                          	xMovCaixa                      xCampo                         'CurSaleProducts.Tam'          'CurSaleProducts.Tam'          xTamanho                       'CurProductGrid.Tamanho_'      'CurProductGrid.Tamanho_'      wLogo                          "Reports\LogoReport.png"       "Reports\LogoReport.png"       Courier New                    Tahoma                         Tahoma                         Arial                          Arial                          Times New Roman                Arial                          Arial                          Tahoma                         Tahoma                         dataenvironment                `Top = 86
Left = 211
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                                 QPROCEDURE Init
PUBLIC xMovCaixa 

IF RECCOUNT('curSalesDetails') > 0

	xMovCaixa = .f.

	SELECT *,SPACE(14) as cpf_cgc,SPACE(12) historico FROM curSalesDetails INTO CURSOR curSalesDetails_tmp READWRITE

	SELECT curSalesDetails_tmp
	GO top
	SCAN
		SqlSelect('SELECT b.cpf_cgc FROM loja_venda a INNER JOIN clientes_varejo b ON '+;
				  'a.codigo_cliente=b.codigo_cliente WHERE a.terminal=?curSalesDetails_tmp.terminal '+;
				  'and a.ticket=?curSalesDetails_tmp.ticket and a.lancamento_caixa=?curSalesDetails_tmp.lancamento_caixa','cur_cpf_cgc')
		SELECT curSalesDetails_tmp
		REPLACE cpf_cgc WITH TRANSFORM(cur_cpf_cgc.cpf_cgc,'@R 999.999.999-99')	
	ENDSCAN
ELSE

	xMovCaixa = .t.

	SELECT *,SPACE(12) banco,SPACE(12) conta_corrente,SPACE(12) parcelas_cartao,SPACE(12) cpf_cgc,;
		SPACE(12) numero_titulo,SPACE(12) ticket,SPACE(12) vencimento,SPACE(12) parcela,SPACE(12) agencia FROM curTransactionsDetails INTO CURSOR curSalesDetails_tmp

ENDIF

SELECT curSalesDetails_tmp
INDEX on NVL(banco,'') TAG iBanco
GO top

ENDPROC
PROCEDURE Destroy
RELEASE xMovCaixa 
ENDPROC
              ����    �  �                        ��   %   �      (     �          �  U  � 7�  �" %�C� curSalesDetailsN� ���� T�  �-��I o� curSalesDetails��C�X�Q� �C�X�Q� ��� curSalesDetails_tmp�� F� � #)� ~�����C�C SELECT b.cpf_cgc FROM loja_venda a INNER JOIN clientes_varejo b ON �Q a.codigo_cliente=b.codigo_cliente WHERE a.terminal=?curSalesDetails_tmp.terminal �e and a.ticket=?curSalesDetails_tmp.ticket and a.lancamento_caixa=?curSalesDetails_tmp.lancamento_caixa� cur_cpf_cgc� �� F� �& >� ��C� � � @R 999.999.999-99_�� � ��� T�  �a��� o� curTransactionsDetails��C�X�Q� �C�X�Q� �C�X�Q�	 �C�X�Q� �C�X�Q�
 �C�X�Q� �C�X�Q� �C�X�Q� �C�X�Q� ��� curSalesDetails_tmp� � F� � & �C� �  ���� � #)� U 	 XMOVCAIXA CPF_CGC	 HISTORICO CURSALESDETAILS CURSALESDETAILS_TMP	 SQLSELECT CUR_CPF_CGC BANCO CONTA_CORRENTE PARCELAS_CARTAO NUMERO_TITULO TICKET
 VENCIMENTO PARCELA AGENCIA CURTRANSACTIONSDETAILS IBANCO
  <�  � U 	 XMOVCAIXA Init,     �� Destroy�    ��1 q "� �r Q � �q aA � � 3
B r 1Q 3 q 1                               4  F  !    )   �                          �DRIVER=winspool
DEVICE=\\a-srv4\HP_Desenv_1
OUTPUT=IP_192.168.120.96
ORIENTATION=0
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=0
               K  (  winspool  \\a-srv4\HP_Desenv_1  IP_192.168.120.96                                        Courier New                    "Ticket"                       Tahoma                         
!xMovCaixa                     curSalesDetails_tmp.ticket                                      Tahoma                         
!xMovCaixa                     (wLogo)                        !empty(wLogo) and file(wLogo)                                   ''Resumo do caixa por tipo de pagamento'                         Arial                          
!xMovCaixa                     main.p_filial                                                 Arial                          %dtoc(date()) + ' - ' + time() + 'hs.'                                                          Times New Roman                'Pg: ' + alltrim(str(_pageno))                                                                 Arial                          �alltrim(main.productname)+' ' + iif(alltrim(main.productname) == 'LinxB2C', alltrim(main.p_versao_linxb2c), alltrim(main.p_versao_loja))                           Arial                          fiif(type('wCodigoReport')='C',wCodigoReport,'...') + iif(type('wUserReport')='C',' - '+wUserReport,'')                                                           Arial                          curSalesDetails_tmp.valor      "@Z"                           Tahoma                         7iif(!xMovCaixa,ttod(curSalesDetails_tmp.vencimento),'')         "@D"                           Tahoma                         "Vencimento"                   Tahoma                         
!xMovCaixa                     "Valor"                        Tahoma                         "Parc."                        Tahoma                         
!xMovCaixa                     curSalesDetails_tmp.parcela                                     Tahoma                         
!xMovCaixa                     "Informa��es   Adicionais"                                      Tahoma                         Yinlist(curVendas.tipo_pgto,  "C", "P", "A", "B", "E", "I", "K", "N", "R" ) and !xMovCaixa        "nvl(curSalesDetails_tmp.banco, "")                              Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            +nvl(curSalesDetails_tmp.conta_corrente, "")                     Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            $nvl(curSalesDetails_tmp.agencia, "")                            Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Banco:"                       Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Ag:"                          Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Cta:"                         Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            curSalesDetails_tmp.valor      "@Z"                           Tahoma                         
"Total-->"                     Tahoma                         ,nvl(curSalesDetails_tmp.parcelas_cartao, "")                    Tahoma                         Hinlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N") and !xMovCaixa                         "N� Parcelas"                  Tahoma                         Hinlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N") and !xMovCaixa                         $nvl(curSalesDetails_tmp.cpf_cgc, "")                            Tahoma                         9inlist(curVendas.tipo_pgto, "C", "P", "R") and !xMovCaixa       "CPF:"                         Tahoma                         9inlist(curVendas.tipo_pgto, "C", "P", "R") and !xMovCaixa       *nvl(curSalesDetails_tmp.numero_titulo, "")                      Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "Nr.Cheque:"                   Tahoma                         4inlist(curVendas.tipo_pgto, "C", "P") and !xMovCaixa            "N� T�tulo:"                   Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 *nvl(curSalesDetails_tmp.numero_titulo, "")                      Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 %nvl(curSalesDetails_tmp.terminal, "")                           Tahoma                         Minlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N", "R") and !xMovCaixa                    "Terminal:"                    Tahoma                         Minlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N", "R") and !xMovCaixa                    curSalesDetails_tmp.data       "@D"                           Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 "Data:"                        Tahoma                         /inlist(curVendas.tipo_pgto, "R") and !xMovCaixa                 "Per�odo Fechamento"           Tahoma                         	xMovCaixa                      "Lan�amento Caixa"             Tahoma                         	xMovCaixa                      "Hist�rico"                    Tahoma                         	xMovCaixa                      &curSalesDetails_tmp.periodo_fechamento                          Tahoma                         	xMovCaixa                      $curSalesDetails_tmp.lancamento_caixa                            Tahoma                         	xMovCaixa                      curSalesDetails_tmp.historico                                   Tahoma                         	xMovCaixa                      "Data"                         Tahoma                         	xMovCaixa                      curSalesDetails_tmp.data       Tahoma                         	xMovCaixa                      !'Resumo de movimenta��o de caixa'                               ""                             Arial                          	xMovCaixa                      xCampo                         'CurSaleProducts.Tam'          'CurSaleProducts.Tam'          xTamanho                       'CurProductGrid.Tamanho_'      'CurProductGrid.Tamanho_'      wLogo                          "Reports\LogoReport.png"       "Reports\LogoReport.png"       Courier New                    Tahoma                         Tahoma                         Arial                          Arial                          Times New Roman                Arial                          Arial                          Tahoma                         Tahoma                         dataenvironment                `Top = 86
Left = 211
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                                 QPROCEDURE Destroy
RELEASE xMovCaixa 
ENDPROC
PROCEDURE Init
PUBLIC xMovCaixa 

IF RECCOUNT('curSalesDetails') > 0

	xMovCaixa = .f.

	SELECT *,SPACE(14) as cpf_cgc,SPACE(12) historico FROM curSalesDetails INTO CURSOR curSalesDetails_tmp READWRITE

	SELECT curSalesDetails_tmp
	GO top
	SCAN
		SqlSelect('SELECT b.cpf_cgc FROM loja_venda a INNER JOIN clientes_varejo b ON '+;
				  'a.codigo_cliente=b.codigo_cliente WHERE a.terminal=?curSalesDetails_tmp.terminal '+;
				  'and a.ticket=?curSalesDetails_tmp.ticket and a.lancamento_caixa=?curSalesDetails_tmp.lancamento_caixa','cur_cpf_cgc')
		SELECT curSalesDetails_tmp
		REPLACE cpf_cgc WITH TRANSFORM(cur_cpf_cgc.cpf_cgc,'@R 999.999.999-99')	
	ENDSCAN
ELSE

	xMovCaixa = .t.

	SELECT *,SPACE(12) banco,SPACE(12) conta_corrente,SPACE(12) parcelas_cartao,SPACE(12) cpf_cgc,;
		SPACE(12) numero_titulo,SPACE(12) ticket,SPACE(12) vencimento,SPACE(12) parcela,SPACE(12) agencia FROM curTransactionsDetails INTO CURSOR curSalesDetails_tmp

ENDIF

SELECT curSalesDetails_tmp
INDEX on NVL(banco,'') TAG iBanco
GO top

ENDPROC
              ����    �  �                        ��   %   �      (     �          �  U  
  <�  � U 	 XMOVCAIXA� 7�  �" %�C� curSalesDetailsN� ���� T�  �-��I o� curSalesDetails��C�X�Q� �C�X�Q� ��� curSalesDetails_tmp�� F� � #)� ~�����C�C SELECT b.cpf_cgc FROM loja_venda a INNER JOIN clientes_varejo b ON �Q a.codigo_cliente=b.codigo_cliente WHERE a.terminal=?curSalesDetails_tmp.terminal �e and a.ticket=?curSalesDetails_tmp.ticket and a.lancamento_caixa=?curSalesDetails_tmp.lancamento_caixa� cur_cpf_cgc� �� F� �& >� ��C� � � @R 999.999.999-99_�� � ��� T�  �a��� o� curTransactionsDetails��C�X�Q� �C�X�Q� �C�X�Q�	 �C�X�Q� �C�X�Q�
 �C�X�Q� �C�X�Q� �C�X�Q� �C�X�Q� ��� curSalesDetails_tmp� � F� � & �C� �  ���� � #)� U 	 XMOVCAIXA CPF_CGC	 HISTORICO CURSALESDETAILS CURSALESDETAILS_TMP	 SQLSELECT CUR_CPF_CGC BANCO CONTA_CORRENTE PARCELAS_CARTAO NUMERO_TITULO TICKET
 VENCIMENTO PARCELA AGENCIA CURTRANSACTIONSDETAILS IBANCO Destroy,     �� InitE     ��1 q 2 q "� �r Q � �q aA � � 3
B r 1Q 2                       %         @   F      )   �                    