   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              �DRIVER=winspool
DEVICE=\\SERVIDOR\HP 845C
OUTPUT=USB002
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=-2
COLOR=1
DUPLEX=1
TTOPTION=3
COLLATE=1
                      s  &  winspool  \\SERVIDOR\HP 845C  USB002                  osoft Document Imaging Writer Port:                                	\\servidor\HP 845C              !@� h߀ 	     d   ��      y,DrvConvert                                                                      B�e�                                   R  L   d  	                                o                                                                                                                                                                                         O  B�e��ں                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     �ںH P   8 4 5 C   O R \ H P   8 4 5 C   e t   8 4 5 c   s e r i e s   ( C o p y   2 ) , L o c a l O n l y , D r v C o n v e r t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Courier New                    curguiaranking.vendedor        curguiaranking.vendedor        Courier New                    
"Vendedor"                     Courier New                    "Venda total"                  Courier New                    curguiaranking.vendas          Courier New                    curguiaranking.vendedor        Courier New                    	"Ranking"                      Courier New                    curguiaranking.vendas          Courier New                    "Total do relat�rio"           Courier New                    curguiaranking.nome            Courier New                    curguiaranking.comissao        Courier New                    curguiaranking.comissao        Courier New                    !"pagina: " + allt(str(_pageno,6))                               Courier New                    ,round(curguiaranking.vendas/totvendas*100,2)                    Courier New                    0round(curguiaranking.comissao/totcomissao*100,2)                Courier New                    
"Comiss�o"                     Courier New                    "%"                            Courier New                    "%"                            Courier New                    Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                                                            Courier New                    �"Relat�rio de Ranking de Guias , periodo de vendas de: " + dtoc(hfundofixohering.pageframe.page3.txtdatainicial.Value) + " at� " + dtoc(hfundofixohering.pageframe.page3.txtdatafinal.Value)        Courier New                    
datetime()                                                    Courier New                    "Relat�rio impresso em:"       Courier New                    'Pendentes'                    Courier New                    	xnpend1=1                      'Pagos'                        Courier New                    	xnpend2=1                      'Todos'                        Courier New                    xnpend1= 0 and xnpend2=0       #"Situa��o da Pesquisa de Comiss�o:"                             Courier New                    �"Periodo de Pagamento de: " + dtoc(hfundofixohering.pageframe.page3.txtdatpgtoini.Value) + " at� " + dtoc(hfundofixohering.pageframe.page3.txtdatpgtofim.Value)                                     Courier New                    	xnpend2=1                      Courier New                    Courier New                    Courier New                    dataenvironment                aTop = 194
Left = 526
Width = 726
Height = 584
DataSource = .NULL.
Name = "dataenvironment"
                                vPROCEDURE Init
IF !hfundofixohering.pageFrame.ActivePage=3
	messagebox("Ative a p�gina de Historico e pagamentos e efetue a pesquisa para Visualizar este Relatorio!!!",64+0,"Atenc�o")
	RETURN .f.
ENDIF


PUBLIC totcomissao,totvendas
SELECT codigo_filial,vendedor,nome,SUM(valor_total) as vendas, SUM(valor_pago) as comissao FROM curHRGuiaPgtohistorico ;
GROUP BY codigo_filial,vendedor,nome  ORDER BY vendas  DESC INTO CURSOR  curguiaranking
 
 
select curguiaranking
SUM(comissao) to totcomissao
SUM(vendas) to totvendas

select curguiaranking
ENDPROC
PROCEDURE Destroy
release totcomissao,totvendas
ENDPROC
                           ���    �  �                        3�   %   T      �     s          �  U  G %��  � � �
��� �w ��C�^ Ative a p�gina de Historico e pagamentos e efetue a pesquisa para Visualizar este Relatorio!!!�@� Atenc�o�x�� B�-�� � 7� � �u o� curHRGuiaPgtohistorico�� ��� ��� ��C� ���Q�	 �C�
 ���Q� ��� ��� ��� ����	 �<��� curguiaranking� F� � K(� �� �� K(� ��	 �� F� � U  HFUNDOFIXOHERING	 PAGEFRAME
 ACTIVEPAGE TOTCOMISSAO	 TOTVENDAS CODIGO_FILIAL VENDEDOR NOME VALOR_TOTAL VENDAS
 VALOR_PAGO COMISSAO CURHRGUIAPGTOHISTORICO CURGUIARANKING  <�  � � U  TOTCOMISSAO	 TOTVENDAS Init,     �� Destroy*    ��1 �qq A � Rs � � r 2 � 1                       0        N  k      )   �                                 