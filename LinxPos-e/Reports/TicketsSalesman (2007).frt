  5   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
                         Courier New                                                   curReportVendedores.data                                      &curReportVendedores.periodo_fechamento                        curReportVendedores.terminal                                  $curReportVendedores.vendedor_apelido                          !curreportvendedores.nome_vendedor                             Courier New                                                   curReportVendedores.ticket                                    Courier New                                                   Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                                                                                                                        Courier New                                                   q"Relat�rio de " + transform(cashregisterreports.datainicial) + " at� " + transform(cashregisterreports.datafinal)                                                                           Courier New                                                   
datetime()                                                    Courier New                                                   "Relat�rio impresso em:"                                      Courier New                                                   
"Vendedor"                                                    Courier New                                                   "Venda total"                                                 Courier New                                                   	"Tickets"                                                     Courier New                                                   "Itens"                                                       Courier New                                                   "Pe�as"                                                       Courier New                                                   curReportVendedores.valor                                     Courier New                                                   curReportVendedores.qtde_itens                                Courier New                                                   curReportVendedores.pecas                                     Courier New                                                   curReportVendedores.valor                                                                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.ticket                                                                                                  Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.qtde_itens                                                                                              Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.pecas                                                                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.valor                                                                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.ticket                                                                                                  Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.qtde_itens                                                                                              Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.pecas                                                                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.valor                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.ticket                                    Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.qtde_itens                                Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.pecas                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     3"Total do terminal " + curReportVendedores.terminal                                                                         Courier New                                                   %!empty(curTicketsVendedores.terminal)                         <"Total do per�odo " + curReportVendedores.periodo_fechamento                                                                                                                                Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               0"Total do dia " + dtoc(curReportVendedores.data)              Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     2"Data: " + nvl(dtoc(curReportVendedores.data), "")            Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     4"Per�odo: " + curReportVendedores.periodo_fechamento                                                                        Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               +"Terminal: " + curReportVendedores.terminal                                                                                 Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.ranking                                   Courier New                                                   	"Ranking"                                                     Courier New                                                   curReportVendedores.valor                                                                                                   Courier New                                                   curReportVendedores.ticket                                                                                                  Courier New                                                   curReportVendedores.qtde_itens                                                                                              Courier New                                                   curReportVendedores.pecas                                                                                                   Courier New                                                   "Total do relat�rio"                                          Courier New                                                   3"Operador: " + curReportVendedores.vendedor_apelido                                                                         Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.valor                                                                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.ticket                                                                                                  Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.qtde_itens                                                                                              Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.pecas                                                                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 3"Total do operador " + curReportVendedores.terminal                                                                         Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 "Pe�as por Ticket"                                           "@I"                                                          Courier New                                                   ?round(curReportVendedores.pecas /curReportVendedores.ticket, 2)                                                               	"9999.99"                                                     Courier New                                                   )round(ptotalterminal / ttotalterminal, 2)                     	"9999.99"                                                     Courier New                                                   %!empty(curTicketsVendedores.terminal)                         'round(Ptotalperiodo / ttotalperiodo, 2)                       	"9999.99"                                                     Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               !round(ptotaldata / ttotaldata, 2)                             	"9999.99"                                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     #round(ptotaltotal / ttotaltotal, 2)                           	"9999.99"                                                     Courier New                                                   (round(ptotalvendedor/ ttotalvendedor, 2)                      	"9999.99"                                                     Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 "TicketM�dio"                                                "@I"                                                          Courier New                                                   @round(curReportVendedores.valor / curReportVendedores.ticket, 2)                                                              "99,999.99"                                                                                                                 Courier New                                                   )round(vtotalterminal / ttotalterminal, 2)                     "99,999.99"                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         'round(vtotalperiodo / ttotalperiodo, 2)                       "99,999.99"                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               !round(vtotaldata / ttotaldata, 2)                             "99,999.99"                                                   Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     #round(vtotaltotal / ttotaltotal, 2)                           "99,999.99"                                                   Courier New                                                   (round(vtotalvendedor/ ttotalvendedor, 2)                      "99,999.99"                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 vtotalvendedor                                                curReportVendedores.valor                                     0                                                             vtotalperiodo                                                 curReportVendedores.valor                                     0                                                             vtotalterminal                                                curReportVendedores.valor                                     0                                                             
vtotaldata                                                    curReportVendedores.valor                                     0                                                             ttotalvendedor                                                curReportVendedores.ticket                                    0                                                             ttotalperiodo                                                 curReportVendedores.ticket                                    0                                                             ttotalterminal                                                curReportVendedores.ticket                                    0                                                             
ttotaldata                                                    curReportVendedores.ticket                                    0                                                             vtotaltotal                                                   curReportVendedores.valor                                     0                                                             ttotaltotal                                                   curReportVendedores.ticket                                    0                                                             
ptotaldata                                                    curReportVendedores.pecas                                     0                                                             ptotalperiodo                                                 curReportVendedores.pecas                                     0                                                             ptotalvendedor                                                curReportVendedores.pecas                                     0                                                             ptotalterminal                                                curReportVendedores.pecas                                     0                                                             ptotaltotal                                                   curReportVendedores.pecas                                     0                                                             Courier New                                                   Courier New                                                   dataenvironment                                               aTop = 194
Left = 526
Width = 726
Height = 584
DataSource = .NULL.
Name = "dataenvironment"
                            WPROCEDURE Init
if used("curReportVendedores")
	use in curReportVendedores
endif

select count(a.data) as Ranking, a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, a.vendedor, a.nome_vendedor, ;
	sum(a.total_venda) as valor, nvl(b.tickets, 1) as ticket, sum(a.qtde_itens) as qtde_itens, sum(a.qtde_produto) as pecas ;
	from curTicketsVendedores a left join curTicketsVendedoresTotais b on nvl(a.data, ctod("")) == nvl(b.data, ctod("")) and a.periodo_fechamento == b.periodo_fechamento ;
	and a.terminal == b.terminal and a.caixa_vendedor == b.caixa_vendedor and a.vendedor == b.vendedor ;
	group by a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, a.vendedor, a.nome_vendedor, b.tickets ;
	order by a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, valor desc ;
	into cursor curReportVendedores

ENDPROC
                                      m���    T  T                        �l   %   �           �          �  U  �" %�C� curReportVendedores���* � Q�  � ��o� curTicketsVendedoresQ� X�� curTicketsVendedoresTotaisQ�  �C�� C�  #�C�� C�  #�� �� �� 	� �� �� 	� �� �� 	� �� �� 	��C�� ���Q� ��� ���� ���� ���� ���� ����	 ��C��
 ���Q� �C�� ���Q� �C�� ���Q� �C�� ���Q� ���� ���� ���� ���� ���� ����	 ���� ����� ���� ���� ���� ��� �<��� curReportVendedores� U  CURREPORTVENDEDORES COUNT DATA RANKING A PERIODO_FECHAMENTO TERMINAL VENDEDOR_APELIDO VENDEDOR NOME_VENDEDOR TOTAL_VENDA VALOR TICKETS TICKET
 QTDE_ITENS QTDE_PRODUTO PECAS CURTICKETSVENDEDORES CURTICKETSVENDEDORESTOTAIS B CAIXA_VENDEDOR Init,     ��1 !� A �2                       L      )   T                                   %ORIENTATION=0
PAPERSIZE=9
COLOR=1
                         Courier New                                                   curReportVendedores.data                                      &curReportVendedores.periodo_fechamento                        curReportVendedores.terminal                                  $curReportVendedores.vendedor_apelido                          !curreportvendedores.nome_vendedor                             Courier New                                                   curReportVendedores.ticket                                    Courier New                                                   Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                                                                                                                        Courier New                                                   q"Relat�rio de " + transform(cashregisterreports.datainicial) + " at� " + transform(cashregisterreports.datafinal)                                                                           Courier New                                                   
datetime()                                                    Courier New                                                   "Relat�rio impresso em:"                                      Courier New                                                   
"Vendedor"                                                    Courier New                                                   "Venda total"                                                 Courier New                                                   	"Tickets"                                                     Courier New                                                   "Itens"                                                       Courier New                                                   "Pe�as"                                                       Courier New                                                   curReportVendedores.valor                                     Courier New                                                   curReportVendedores.qtde_itens                                Courier New                                                   curReportVendedores.pecas                                     Courier New                                                   curReportVendedores.valor                                                                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.ticket                                                                                                  Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.qtde_itens                                                                                              Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.pecas                                                                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.valor                                                                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.ticket                                                                                                  Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.qtde_itens                                                                                              Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.pecas                                                                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               curReportVendedores.valor                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.ticket                                    Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.qtde_itens                                Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     curReportVendedores.pecas                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     3"Total do terminal " + curReportVendedores.terminal                                                                         Courier New                                                   %!empty(curTicketsVendedores.terminal)                         <"Total do per�odo " + curReportVendedores.periodo_fechamento                                                                                                                                Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               0"Total do dia " + dtoc(curReportVendedores.data)              Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     2"Data: " + nvl(dtoc(curReportVendedores.data), "")            Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     4"Per�odo: " + curReportVendedores.periodo_fechamento                                                                        Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               +"Terminal: " + curReportVendedores.terminal                                                                                 Courier New                                                   %!empty(curTicketsVendedores.terminal)                         curReportVendedores.ranking                                   Courier New                                                   	"Ranking"                                                     Courier New                                                   curReportVendedores.valor                                                                                                   Courier New                                                   curReportVendedores.ticket                                                                                                  Courier New                                                   curReportVendedores.qtde_itens                                                                                              Courier New                                                   curReportVendedores.pecas                                                                                                   Courier New                                                   "Total do relat�rio"                                          Courier New                                                   3"Operador: " + curReportVendedores.vendedor_apelido                                                                         Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.valor                                                                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.ticket                                                                                                  Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.qtde_itens                                                                                              Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 curReportVendedores.pecas                                                                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 3"Total do operador " + curReportVendedores.terminal                                                                         Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 "Pe�as por Ticket"                                           "@I"                                                          Courier New                                                   ?round(curReportVendedores.pecas /curReportVendedores.ticket, 2)                                                               	"9999.99"                                                     Courier New                                                   )round(ptotalterminal / ttotalterminal, 2)                     	"9999.99"                                                     Courier New                                                   %!empty(curTicketsVendedores.terminal)                         'round(Ptotalperiodo / ttotalperiodo, 2)                       	"9999.99"                                                     Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               !round(ptotaldata / ttotaldata, 2)                             	"9999.99"                                                     Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     #round(ptotaltotal / ttotaltotal, 2)                           	"9999.99"                                                     Courier New                                                   (round(ptotalvendedor/ ttotalvendedor, 2)                      	"9999.99"                                                     Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 "TicketM�dio"                                                "@I"                                                          Courier New                                                   @round(curReportVendedores.valor / curReportVendedores.ticket, 2)                                                              "99,999.99"                                                                                                                 Courier New                                                   )round(vtotalterminal / ttotalterminal, 2)                     "99,999.99"                                                   Courier New                                                   %!empty(curTicketsVendedores.terminal)                         'round(vtotalperiodo / ttotalperiodo, 2)                       "99,999.99"                                                   Courier New                                                   /!empty(curTicketsVendedores.periodo_fechamento)               !round(vtotaldata / ttotaldata, 2)                             "99,999.99"                                                   Courier New                                                   )!empty(nvl(curReportVendedores.data, ""))                     #round(vtotaltotal / ttotaltotal, 2)                           "99,999.99"                                                   Courier New                                                   (round(vtotalvendedor/ ttotalvendedor, 2)                      "99,999.99"                                                   Courier New                                                   -!empty(curTicketsVendedores.vendedor_apelido)                 vtotalvendedor                                                curReportVendedores.valor                                     0                                                             vtotalperiodo                                                 curReportVendedores.valor                                     0                                                             vtotalterminal                                                curReportVendedores.valor                                     0                                                             
vtotaldata                                                    curReportVendedores.valor                                     0                                                             ttotalvendedor                                                curReportVendedores.ticket                                    0                                                             ttotalperiodo                                                 curReportVendedores.ticket                                    0                                                             ttotalterminal                                                curReportVendedores.ticket                                    0                                                             
ttotaldata                                                    curReportVendedores.ticket                                    0                                                             vtotaltotal                                                   curReportVendedores.valor                                     0                                                             ttotaltotal                                                   curReportVendedores.ticket                                    0                                                             
ptotaldata                                                    curReportVendedores.pecas                                     0                                                             ptotalperiodo                                                 curReportVendedores.pecas                                     0                                                             ptotalvendedor                                                curReportVendedores.pecas                                     0                                                             ptotalterminal                                                curReportVendedores.pecas                                     0                                                             ptotaltotal                                                   curReportVendedores.pecas                                     0                                                             Courier New                                                   Courier New                                                   dataenvironment                                               aTop = 194
Left = 526
Width = 726
Height = 584
DataSource = .NULL.
Name = "dataenvironment"
                            fPROCEDURE Init
if used("curReportVendedores")
	use in curReportVendedores
endif

select count(a.data) as Ranking, a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, a.vendedor, a.nome_vendedor, ;
	sum(a.total_venda) as valor, nvl(b.tickets, 1) as ticket, sum(a.qtde_itens) as qtde_itens, sum(a.qtde_produto - a.qtde_troca) as pecas ;
	from curTicketsVendedores a left join curTicketsVendedoresTotais b on nvl(a.data, ctod("")) == nvl(b.data, ctod("")) and a.periodo_fechamento == b.periodo_fechamento ;
	and a.terminal == b.terminal and a.caixa_vendedor == b.caixa_vendedor and a.vendedor == b.vendedor ;
	group by a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, a.vendedor, a.nome_vendedor, b.tickets ;
	order by a.data, a.periodo_fechamento, a.terminal, a.vendedor_apelido, valor desc ;
	into cursor curReportVendedores

ENDPROC
                       ���    f  f                        =0   %                        �  U  �" %�C� curReportVendedores���* � Q�  � ��o� curTicketsVendedoresQ� X�� curTicketsVendedoresTotaisQ�  �C�� C�  #�C�� C�  #�� �� �� 	� �� �� 	� �� �� 	� �� �� 	��C�� ���Q� ��� ���� ���� ���� ���� ����	 ��C��
 ���Q� �C�� ���Q� �C�� ���Q� �C�� �� ���Q� ���� ���� ���� ���� ���� ����	 ���� ����� ���� ���� ���� ��� �<��� curReportVendedores� U  CURREPORTVENDEDORES COUNT DATA RANKING A PERIODO_FECHAMENTO TERMINAL VENDEDOR_APELIDO VENDEDOR NOME_VENDEDOR TOTAL_VENDA VALOR TICKETS TICKET
 QTDE_ITENS QTDE_PRODUTO
 QTDE_TROCA PECAS CURTICKETSVENDEDORES CURTICKETSVENDEDORESTOTAIS B CAIXA_VENDEDOR Init,     ��1 !� A H2                       [      )   f                                                                           