   �   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
esenvolvimento
OUTPUT=IP_192.168.120.107
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
COLLATE=1
                                S  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.107                                                             Courier New                                                   "Ticket"                                                      Tahoma                                                        curSalesDetails.ticket                                        Tahoma                                                        (wLogo)                                                       !empty(wLogo) and file(wLogo)                                 ''Resumo do caixa por tipo de pagamento'                       Arial                                                         main.p_filial                                                                                                               Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ''LinxPOS '+ alltrim(main.p_versao_loja)                                                                                     Arial                                                         fiif(type('wCodigoReport')='C',wCodigoReport,'...') + iif(type('wUserReport')='C',' - '+wUserReport,'')                                                                                      Arial                                                         curSalesDetails.valor                                         "@Z"                                                          Tahoma                                                        curSalesDetails.vencimento                                    "@D"                                                          Tahoma                                                        "Vencimento"                                                  Tahoma                                                        "Valor"                                                       Tahoma                                                        	"Parcela"                                                     Tahoma                                                        curSalesDetails.parcela                                       Tahoma                                                        "Informa��es Adicionais"                                      Tahoma                                                        nvl(curSalesDetails.banco, "")                                Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         'nvl(curSalesDetails.conta_corrente, "")                       "@Z"                                                          Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                          nvl(curSalesDetails.agencia, "")                              "@D"                                                          Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         "Banco"                                                       Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         	"Ag�ncia"                                                     Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         "Conta"                                                       Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         curSalesDetails.valor                                         "@Z"                                                          Tahoma                                                        "Total"                                                       Tahoma                                                        (nvl(curSalesDetails.parcelas_cartao, "")                      Tahoma                                                        9inlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N")                                                                     "N� Parcelas"                                                 Tahoma                                                        9inlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N")                                                                     xCampo                                                        'CurSaleProducts.Tam'                                         'CurSaleProducts.Tam'                                         xTamanho                                                      'CurProductGrid.Tamanho_'                                     'CurProductGrid.Tamanho_'                                     wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                      Courier New                                                   Tahoma                                                        Tahoma                                                        Arial                                                         Arial                                                         Times New Roman                                               Arial                                                         Arial                                                         Tahoma                                                        Tahoma                                                        dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                              :PROCEDURE Init
select curSalesDetails
go top 
ENDPROC
                                                                    ����    �   �                         H�   %   P       f      ^           �  U    F�  � #)� U  CURSALESDETAILS Init,     ��1 q Q 1                       /       )   �                                                                         �DRIVER=winspool
DEVICE=\\a-srv1\HP Desenvolvimento
OUTPUT=IP_192.168.120.107
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
COLLATE=1
                                S  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.107                                                             Courier New                                                   "Ticket"                                                      Tahoma                                                        curSalesDetails.ticket                                        Tahoma                                                        (wLogo)                                                       !empty(wLogo) and file(wLogo)                                 ''Resumo do caixa por tipo de pagamento'                       Arial                                                         main.p_filial                                                                                                               Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ''LinxPOS '+ alltrim(main.p_versao_loja)                                                                                     Arial                                                         fiif(type('wCodigoReport')='C',wCodigoReport,'...') + iif(type('wUserReport')='C',' - '+wUserReport,'')                                                                                      Arial                                                         curSalesDetails.valor                                         "@Z"                                                          Tahoma                                                        curSalesDetails.vencimento                                    "@D"                                                          Tahoma                                                        "Vencimento"                                                  Tahoma                                                        "Valor"                                                       Tahoma                                                        	"Parcela"                                                     Tahoma                                                        curSalesDetails.parcela                                       Tahoma                                                        "Informa��es Adicionais"                                      Tahoma                                                        nvl(curSalesDetails.banco, "")                                Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         'nvl(curSalesDetails.conta_corrente, "")                       "@Z"                                                          Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                          nvl(curSalesDetails.agencia, "")                              "@D"                                                          Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         "Banco"                                                       Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         	"Ag�ncia"                                                     Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         "Conta"                                                       Tahoma                                                        %inlist(curVendas.tipo_pgto, "C", "P")                         curSalesDetails.valor                                         "@Z"                                                          Tahoma                                                        "Total"                                                       Tahoma                                                        (nvl(curSalesDetails.parcelas_cartao, "")                      Tahoma                                                        9inlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N")                                                                     "N� Parcelas"                                                 Tahoma                                                        9inlist(curVendas.tipo_pgto, "A", "B", "E", "I", "K", "N")                                                                     xCampo                                                        'CurSaleProducts.Tam'                                         'CurSaleProducts.Tam'                                         xTamanho                                                      'CurProductGrid.Tamanho_'                                     'CurProductGrid.Tamanho_'                                     wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                      Courier New                                                   Tahoma                                                        Tahoma                                                        Arial                                                         Arial                                                         Times New Roman                                               Arial                                                         Arial                                                         Tahoma                                                        Tahoma                                                        dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                              :PROCEDURE Init
select curSalesDetails
go top 
ENDPROC
                                                                    ����    �   �                         H�   %   P       f      ^           �  U    F�  � #)� U  CURSALESDETAILS Init,     ��1 q Q 1                       /       )   �                                                                   