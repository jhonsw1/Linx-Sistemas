  �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
esenvolvimento
OUTPUT=IP_192.168.120.34
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
        R  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.34                                 Courier New                    curClientesVendas.data         $curClientesVendas.periodo_fechamento                            curClientesVendas.terminal                                      "curClientesVendas.vendedor_apelido                               curClientesVendas.cliente_varejo                                curClientesVendas.ticket        curClientesVendas.desc_tipo_pgto                                 curclientesvendas.codigo_cliente                                                               Courier New                     !empty(curClientesVendas.ticket)                                 curclientesvendas.cliente_varejo                                                               Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.ticket                                      Courier New                     !empty(curClientesVendas.ticket)                                 curclientesvendas.desc_tipo_pgto                                                               Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.qtde_total                                                                   Courier New                     !empty(curClientesVendas.ticket)                                CashRegisterReports.DataInicial                                                                Courier New                    "at�"                          Courier New                    CashRegisterReports.DataFinal                                                                  Courier New                    
datetime()                                                    Courier New                    "Relat�rio impresso em:"       Courier New                    "Relat�rio de"                 Courier New                    Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                             ""                             8 cpi                          "Ticket"                                                      Courier New                     !empty(curClientesVendas.ticket)                                "Quantidade"                                                  Courier New                     !empty(curClientesVendas.ticket)                                "Valor"                                                       Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.valor                                       Courier New                     !empty(curClientesVendas.ticket)                                curClientesVendas.total_venda                                                                  Courier New                     !empty(curClientesVendas.ticket)                                6"Data: " + dtoc(nvl(curClientesVendas.data, ctod("")))          Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         2"Per�odo: " + curClientesVendas.periodo_fechamento                                             Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    )"Terminal: " + curClientesVendas.terminal                                                      Courier New                    "!empty(curClientesVendas.terminal)                              ."Total do dia " + dtoc(curClientesVendas.data)                  Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         :"Total do per�odo " + curClientesVendas.periodo_fechamento                                     Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    1"Total do terminal " + curClientesVendas.terminal                                              Courier New                    "!empty(curClientesVendas.terminal)                              curClientesVendas.valor                                       Courier New                    "!empty(curClientesVendas.terminal)                              curClientesVendas.valor                                       Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    curClientesVendas.valor        Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         curClientesVendas.valor                                       Courier New                    (!empty(curClientesVendas.cliente_varejo)                        curclientesvendas.qtde_total                                                                   Courier New                    (!empty(curClientesVendas.cliente_varejo)                        	"Cliente"                                                     Courier New                    empty(curClientesVendas.ticket)                                 "Quantidade"                                                  Courier New                    empty(curClientesVendas.ticket)                                 "Valor"                                                       Courier New                    empty(curClientesVendas.ticket)                                  curclientesvendas.codigo_cliente                                                               Courier New                    (!empty(curClientesVendas.cliente_varejo)                         curclientesvendas.cliente_varejo                                                               Courier New                    (!empty(curClientesVendas.cliente_varejo)                        curClientesVendas.valor                                       Courier New                    "Total"                        Courier New                    1"Operador: " + curClientesVendas.vendedor_apelido                                              Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      9"Total do operador " + curClientesVendas.vendedor_apelido                                      Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      curClientesVendas.valor                                       Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      Courier New                    Courier New                    8 cpi                          Courier New                    dataenvironment                _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                   �PROCEDURE Init
select curClientesVendas
index on dtos(nvl(data, ctod(""))) + periodo_fechamento + terminal + vendedor_apelido + cliente_varejo tag tagReport

ENDPROC
                        =���    $  $                        �R   %   �       �      �           �  U  1  F�  �' & �CC� C�  #Ҏ� � � � ��� � U  CURCLIENTESVENDAS DATA PERIODO_FECHAMENTO TERMINAL VENDEDOR_APELIDO CLIENTE_VAREJO	 TAGREPORT Init,     ��1 q q2                       �       )   $                             �DRIVER=winspool
DEVICE=\\a-srv1\HP Desenvolvimento
OUTPUT=IP_192.168.120.34
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
        R  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.34                                 Courier New                    curClientesVendas.data         $curClientesVendas.periodo_fechamento                            curClientesVendas.terminal                                      "curClientesVendas.vendedor_apelido                               curClientesVendas.cliente_varejo                                curClientesVendas.ticket        curClientesVendas.desc_tipo_pgto                                 curclientesvendas.codigo_cliente                                                               Courier New                     !empty(curClientesVendas.ticket)                                 curclientesvendas.cliente_varejo                                                               Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.ticket                                      Courier New                     !empty(curClientesVendas.ticket)                                 curclientesvendas.desc_tipo_pgto                                                               Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.qtde_total                                                                   Courier New                     !empty(curClientesVendas.ticket)                                CashRegisterReports.DataInicial                                                                Courier New                    "at�"                          Courier New                    CashRegisterReports.DataFinal                                                                  Courier New                    
datetime()                                                    Courier New                    "Relat�rio impresso em:"       Courier New                    "Relat�rio de"                 Courier New                    Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                             ""                             8 cpi                          "Ticket"                                                      Courier New                     !empty(curClientesVendas.ticket)                                "Quantidade"                                                  Courier New                     !empty(curClientesVendas.ticket)                                "Valor"                                                       Courier New                     !empty(curClientesVendas.ticket)                                curclientesvendas.valor                                       Courier New                     !empty(curClientesVendas.ticket)                                curClientesVendas.total_venda                                                                  Courier New                     !empty(curClientesVendas.ticket)                                6"Data: " + dtoc(nvl(curClientesVendas.data, ctod("")))          Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         2"Per�odo: " + curClientesVendas.periodo_fechamento                                             Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    )"Terminal: " + curClientesVendas.terminal                                                      Courier New                    "!empty(curClientesVendas.terminal)                              ."Total do dia " + dtoc(curClientesVendas.data)                  Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         :"Total do per�odo " + curClientesVendas.periodo_fechamento                                     Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    1"Total do terminal " + curClientesVendas.terminal                                              Courier New                    "!empty(curClientesVendas.terminal)                              curClientesVendas.valor                                       Courier New                    "!empty(curClientesVendas.terminal)                              curClientesVendas.valor                                       Courier New                    ,!empty(curClientesVendas.periodo_fechamento)                    curClientesVendas.valor        Courier New                    '!empty(nvl(curClientesVendas.data, ""))                         curClientesVendas.valor                                       Courier New                    (!empty(curClientesVendas.cliente_varejo)                        curclientesvendas.qtde_total                                                                   Courier New                    (!empty(curClientesVendas.cliente_varejo)                        	"Cliente"                                                     Courier New                    empty(curClientesVendas.ticket)                                 "Quantidade"                                                  Courier New                    empty(curClientesVendas.ticket)                                 "Valor"                                                       Courier New                    empty(curClientesVendas.ticket)                                  curclientesvendas.codigo_cliente                                                               Courier New                    (!empty(curClientesVendas.cliente_varejo)                         curclientesvendas.cliente_varejo                                                               Courier New                    (!empty(curClientesVendas.cliente_varejo)                        curClientesVendas.valor                                       Courier New                    "Total"                        Courier New                    1"Operador: " + curClientesVendas.vendedor_apelido                                              Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      9"Total do operador " + curClientesVendas.vendedor_apelido                                      Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      curClientesVendas.valor                                       Courier New                    *!empty(curClientesVendas.vendedor_apelido)                      Courier New                    Courier New                    8 cpi                          Courier New                    dataenvironment                _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                   �PROCEDURE Init
select curClientesVendas
index on dtos(nvl(data, ctod(""))) + periodo_fechamento + terminal + vendedor_apelido + cliente_varejo tag tagReport

ENDPROC
                        =���    $  $                        �R   %   �       �      �           �  U  1  F�  �' & �CC� C�  #Ҏ� � � � ��� � U  CURCLIENTESVENDAS DATA PERIODO_FECHAMENTO TERMINAL VENDEDOR_APELIDO CLIENTE_VAREJO	 TAGREPORT Init,     ��1 q q2                       �       )   $                       