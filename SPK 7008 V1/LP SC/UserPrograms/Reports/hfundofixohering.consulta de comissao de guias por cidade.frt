   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              �DRIVER=winspool
DEVICE=\\SERVIDOR\HP 845C
OUTPUT=USB002
ORIENTATION=0
PAPERSIZE=1
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=-2
COLOR=1
DUPLEX=1
TTOPTION=3
COLLATE=1
                      s  &  winspool  \\SERVIDOR\HP 845C  USB002                  osoft Document Imaging Writer Port:                                	\\servidor\HP 845C              !@� h߀      d   ��      y,DrvConvert                                                                      B�e�                                   R  L   d  	                                o                                                                                                                                                                                         O  B�e��ں                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     �ںH P   8 4 5 C   O R \ H P   8 4 5 C   e t   8 4 5 c   s e r i e s   ( C o p y   2 ) , L o c a l O n l y , D r v C o n v e r t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Courier New                    HCurhrguiapgtolancamento2.codigo_filial_a+Curhrguiapgtolancamento2.cidade                         �Curhrguiapgtolancamento2.codigo_filial_a+Curhrguiapgtolancamento2.cidade+DTOS(emissao)+str(numero_guia)+vendedor_a+STR(lancamento)                                 ,round(Curhrguiapgtolancamento2.valor_pago,2)                    Tahoma                         #Curhrguiapgtolancamento2.PERCENTUAL                             Tahoma                         $Curhrguiapgtolancamento2.valor_TOTAL                            Tahoma                         Eallt(Curhrguiapgtolancamento2.Cidade)+'-'+Curhrguiapgtolancamento2.uf                            Tahoma                         	"Cidade:"                      Tahoma                         "Total de vendas"              Tahoma                         "% "                           Tahoma                         
"Comiss�o"                     Tahoma                         'PAG:.'+ STR( _pageno)         Tahoma                         "Grupo"                        Tahoma                         $Curhrguiapgtolancamento2.numero_guia                            "@B"                           Tahoma                         Wiif(Curhrguiapgtolancamento2.empresa_guia='%','',Curhrguiapgtolancamento2.empresa_guia)          "@B"                           Tahoma                         "Agencia Guia"                 Tahoma                         Zallt(Curhrguiapgtolancamento2.vendedor_a)+"-"+allt(Curhrguiapgtolancamento2.nome_vendedor)       "@B"                           Tahoma                         " Nome Guia"                   Tahoma                         ,round(Curhrguiapgtolancamento2.valor_pago,2)                    Tahoma                         ,round(Curhrguiapgtolancamento2.valor_pago,2)                    Tahoma                         "Total da Cidade:"             Tahoma                         "Total geral.."                Tahoma                         Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                                                            Courier New                    �"Relat�rio de comis�o de Guias por Cidade , periodo de vendas de: " + dtoc(hfundofixohering.pageframe.page3.txtdatainicial.Value) + " at� " + dtoc(hfundofixohering.pageframe.page3.txtdatafinal.Value)                              Courier New                    
datetime()                                                    Courier New                    "Relat�rio impresso em:"       Courier New                    �"Periodo de Pagamento de: " + dtoc(hfundofixohering.pageframe.page3.txtdatpgtoini.Value) + " at� " + dtoc(hfundofixohering.pageframe.page3.txtdatpgtofim.Value)                                     Courier New                    	xnpend2=1                      Courier New                    Tahoma                         Tahoma                         Tahoma                         Tahoma                         Courier New                    dataenvironment                `Top = 93
Left = 761
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                 XPROCEDURE Init

IF !hfundofixohering.pageFrame.ActivePage=3
	messagebox("Ative a p�gina de Historico e pagamentos e efetue a pesquisa para Visualizar este Relatorio!!!",64+0,"Atenc�o")
	RETURN .f.
ENDIF

SQLselect([select *from HR_GUIAS_TURISMO], [curguia])
 select curHRGuiaPgtohistorico
 
 SELECT * FROM curguia ;
 JOIN curHRGuiaPgtohistorico;
 ON curguia.vendedor = curHRGuiaPgtohistorico.vendedor INTO CURSOR  curHRGuiaPgtoLancamento2
 

  select curHRGuiaPgtoLancamento2
 INDEX on codigo_filial_a+cidade+DTOS(emissao)+STR(numero_guia)+vendedor_a+STR(lancamento) TAG I8
ENDPROC
                        ����    �  �                        )!   %   S      w     a          �  U  _ %��  � � �
��� �w ��C�^ Ative a p�gina de Historico e pagamentos e efetue a pesquisa para Visualizar este Relatorio!!!�@� Atenc�o�x�� B�-�� �4 ��C� select *from HR_GUIAS_TURISMO� curguia� �� F� �X o� curguia��� curHRGuiaPgtohistorico �� � � � �Ǽ�� curHRGuiaPgtoLancamento2� F� �( & �� �	 C�
 �C� Z� C� Z��� � U  HFUNDOFIXOHERING	 PAGEFRAME
 ACTIVEPAGE	 SQLSELECT CURHRGUIAPGTOHISTORICO CURGUIA VENDEDOR CURHRGUIAPGTOLANCAMENTO2 CODIGO_FILIAL_A CIDADE EMISSAO NUMERO_GUIA
 VENDEDOR_A
 LANCAMENTO I8 Init,     ��1 �qq A Bq �s �1                       M      )   �                                        