  v   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
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
        R  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.34                                 Courier New                    curReport.TipoGrupo            curReport.Data                 curReport.Periodo_Fechamento                                    curReport.Terminal             curReport.vendedor_apelido                                      curReport.TipoRegistro         curReport.QtdeItem                                            Courier New                    curReport.DescTipoRegistro                                                                     Courier New                    ?dtoc(iif(Main.IsManager, CashRegisterReports.DataInicial, main.Date)) + " - " + dtoc(iif(Main.IsManager, CashRegisterReports.DataFinal, main.Date))                                               Courier New                    Main.IsManager                 Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                             ""                             8 cpi                          "Data: " + dtoc(curReport.data)                                                                Courier New                    !empty(curReport.data)         *"Per?odo: " + curReport.periodo_fechamento                                                     Courier New                    $!empty(curReport.periodo_fechamento)                            !"Terminal: " + curReport.terminal                                                              Courier New                    !empty(curReport.terminal)                                      "Total"                                                       Courier New                                                   curReport.ValorItem                                           Courier New                    curReport.DescricaoItem                                       Courier New                    curReport.QtdeItem                                            Courier New                    curReport.ValorItem                                           Courier New                    	"Produto"                                                     Courier New                    "Quantidade"                                                  Courier New                    "Valor"                                                       Courier New                                                                                  )"Operador: " + curReport.vendedor_apelido                                                      Courier New                    "!empty(curReport.vendedor_apelido)                              _COD_INVENT_TROCAS             0                              0                              _COD_CANC_OUTROS               21                             1                              _COD_CANC_ULTIMO               2                              2                              Courier New                    Courier New                    8 cpi                          dataenvironment                aTop = 202
Left = 312
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                GPROCEDURE Init
#define _RESUMOS 1

#define _TIT_INVENT_TROCAS "Lista de trocas efetuadas"
#define _TIT_CANC_OUTROS "Cancelamentos de outros cupons"
#define _TIT_CANC_ULTIMO "Cancelamentos do ?ltimo cupom (ECF)"
#define _TIT_CANC_ITEM "Cancelamentos de itens (ECF)"

#define _COD_INVENT_TROCAS 0
#define _COD_CANC_OUTROS 1
#define _COD_CANC_ULTIMO 2
#define _COD_CANC_ITEM 3

local strSelect as string
strSelect = "SET FMTONLY ON " + ;
	"SELECT CONVERT(INT, 0) AS TipoGrupo, CONVERT(DATETIME, NULL) AS Data, A.PERIODO_FECHAMENTO AS Periodo_Fechamento, A.TERMINAL AS Terminal, " + ;
	"A.VENDEDOR AS CAIXA_VENDEDOR, C.VENDEDOR_APELIDO, " + ;
	"CONVERT(INT, 0) AS TipoRegistro, CONVERT(VARCHAR(100), '') AS DescTipoRegistro, CONVERT(VARCHAR(200), '') AS DescricaoItem, " + ;
	"B.PRECO_LIQUIDO AS ValorItem, B.QTDE AS QtdeItem " + ;
	"FROM LOJA_VENDA A INNER JOIN LOJA_VENDA_PRODUTO B " + ;
	"ON A.CODIGO_FILIAL = B.CODIGO_FILIAL AND A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA " + ;
	"INNER JOIN LOJA_VENDEDORES C ON A.VENDEDOR = C.VENDEDOR " + ;
	"SET FMTONLY OFF"
if !SQLSelect(strSelect, "curReport", "Erro pesquisando dados dos relat?rios.")
	return .f.
endif

if used("curResInventTrocas")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_INVENT_TROCAS, _TIT_INVENT_TROCAS, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde, valor ;
		from curResInventTrocas order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResProdutosCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_OUTROS, _TIT_CANC_OUTROS, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResProdutosCancelados where !cancelado_fiscal ;
		order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResProdutosCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_ULTIMO, _TIT_CANC_ULTIMO, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResProdutosCancelados where cancelado_fiscal ;
		order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResItensCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_ITEM, _TIT_CANC_ITEM, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResItensCancelados order by data, Periodo_Fechamento, Terminal, produto
endif

select curReport
index on str(TipoGrupo) + dtoc(nvl(data, ctod(""))) + Periodo_Fechamento + Terminal + Caixa_Vendedor + Vendedor_Apelido + str(TipoRegistro) tag tagReport

ENDPROC
             
k???    R
  R
                        ??   %   ?	      	
     ?	          ?  U  ! ??  Q? STRING?{T?  ?? SET FMTONLY ON ي SELECT CONVERT(INT, 0) AS TipoGrupo, CONVERT(DATETIME, NULL) AS Data, A.PERIODO_FECHAMENTO AS Periodo_Fechamento, A.TERMINAL AS Terminal, ?2 A.VENDEDOR AS CAIXA_VENDEDOR, C.VENDEDOR_APELIDO, ?| CONVERT(INT, 0) AS TipoRegistro, CONVERT(VARCHAR(100), '') AS DescTipoRegistro, CONVERT(VARCHAR(200), '') AS DescricaoItem, ?1 B.PRECO_LIQUIDO AS ValorItem, B.QTDE AS QtdeItem ?2 FROM LOJA_VENDA A INNER JOIN LOJA_VENDA_PRODUTO B ?] ON A.CODIGO_FILIAL = B.CODIGO_FILIAL AND A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA ?8 INNER JOIN LOJA_VENDEDORES C ON A.VENDEDOR = C.VENDEDOR ? SET FMTONLY OFF??H %?C ?  ?	 curReport?& Erro pesquisando dados dos relat?rios.? 
???? B?-?? ?! %?C? curResInventTrocas????r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResInventTrocas????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ??? ??? Lista de trocas efetuadas??C? ??  - C? ???? ??? ???? ??? ??? ??? ?? ?' %?C? curResProdutosCancelados???W?r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResProdutosCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ?????? Cancelamentos de outros cupons??C? ??  - C? ???? ??? ???? 
???? ??? ??? ??? ?? ?' %?C? curResProdutosCancelados?????#r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResProdutosCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ??????# Cancelamentos do ?ltimo cupom (ECF)??C? ??  - C? ???? ??? ???? ???? ??? ??? ??? ?? ?$ %?C? curResItensCancelados?????r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResItensCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ?????? Cancelamentos de itens (ECF)??C? ??  - C? ???? ??? ???? ??? ??? ??? ?? ? F? ?3 & ?C? ZCC? C?  #?*? ? ? ? C? Z??? ? U 	 STRSELECT	 SQLSELECT	 TIPOGRUPO DATA PERIODO_FECHAMENTO TERMINAL CAIXA_VENDEDOR VENDEDOR_APELIDO TIPOREGISTRO DESCTIPOREGISTRO DESCRICAOITEM QTDEITEM	 VALORITEM MAIN	 ISMANAGER DATE
 P_TERMINAL PRODUTO DESC_PROD_NF QTDE VALOR CURRESINVENTTROCAS QTDE_CANCELADA VALOR_CANCELADO CURRESPRODUTOSCANCELADOS CANCELADO_FISCAL CURRESITENSCANCELADOS	 CURREPORT	 TAGREPORT Init,     ??1 ?'?q A ?A r?A r5A B4A r 12                       <      )   R
                                                       ?DRIVER=winspool
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
        R  /  winspool  \\a-srv1\HP Desenvolvimento  IP_192.168.120.34                                 Courier New                    curReport.TipoGrupo            curReport.Data                 curReport.Periodo_Fechamento                                    curReport.Terminal             curReport.vendedor_apelido                                      curReport.TipoRegistro         curReport.QtdeItem                                            Courier New                    curReport.DescTipoRegistro                                                                     Courier New                    ?dtoc(iif(Main.IsManager, CashRegisterReports.DataInicial, main.Date)) + " - " + dtoc(iif(Main.IsManager, CashRegisterReports.DataFinal, main.Date))                                               Courier New                    Main.IsManager                 Dtranslate("Filial: ") + main.p_codigo_filial + " - " + main.p_filial                             ""                             8 cpi                          "Data: " + dtoc(curReport.data)                                                                Courier New                    !empty(curReport.data)         *"Per?odo: " + curReport.periodo_fechamento                                                     Courier New                    $!empty(curReport.periodo_fechamento)                            !"Terminal: " + curReport.terminal                                                              Courier New                    !empty(curReport.terminal)                                      "Total"                                                       Courier New                                                   curReport.ValorItem                                           Courier New                    curReport.DescricaoItem                                       Courier New                    curReport.QtdeItem                                            Courier New                    curReport.ValorItem                                           Courier New                    	"Produto"                                                     Courier New                    "Quantidade"                                                  Courier New                    "Valor"                                                       Courier New                                                                                  )"Operador: " + curReport.vendedor_apelido                                                      Courier New                    "!empty(curReport.vendedor_apelido)                              _COD_INVENT_TROCAS             0                              0                              _COD_CANC_OUTROS               21                             1                              _COD_CANC_ULTIMO               2                              2                              Courier New                    Courier New                    8 cpi                          dataenvironment                aTop = 202
Left = 312
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                GPROCEDURE Init
#define _RESUMOS 1

#define _TIT_INVENT_TROCAS "Lista de trocas efetuadas"
#define _TIT_CANC_OUTROS "Cancelamentos de outros cupons"
#define _TIT_CANC_ULTIMO "Cancelamentos do ?ltimo cupom (ECF)"
#define _TIT_CANC_ITEM "Cancelamentos de itens (ECF)"

#define _COD_INVENT_TROCAS 0
#define _COD_CANC_OUTROS 1
#define _COD_CANC_ULTIMO 2
#define _COD_CANC_ITEM 3

local strSelect as string
strSelect = "SET FMTONLY ON " + ;
	"SELECT CONVERT(INT, 0) AS TipoGrupo, CONVERT(DATETIME, NULL) AS Data, A.PERIODO_FECHAMENTO AS Periodo_Fechamento, A.TERMINAL AS Terminal, " + ;
	"A.VENDEDOR AS CAIXA_VENDEDOR, C.VENDEDOR_APELIDO, " + ;
	"CONVERT(INT, 0) AS TipoRegistro, CONVERT(VARCHAR(100), '') AS DescTipoRegistro, CONVERT(VARCHAR(200), '') AS DescricaoItem, " + ;
	"B.PRECO_LIQUIDO AS ValorItem, B.QTDE AS QtdeItem " + ;
	"FROM LOJA_VENDA A INNER JOIN LOJA_VENDA_PRODUTO B " + ;
	"ON A.CODIGO_FILIAL = B.CODIGO_FILIAL AND A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA " + ;
	"INNER JOIN LOJA_VENDEDORES C ON A.VENDEDOR = C.VENDEDOR " + ;
	"SET FMTONLY OFF"
if !SQLSelect(strSelect, "curReport", "Erro pesquisando dados dos relat?rios.")
	return .f.
endif

if used("curResInventTrocas")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_INVENT_TROCAS, _TIT_INVENT_TROCAS, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde, valor ;
		from curResInventTrocas order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResProdutosCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_OUTROS, _TIT_CANC_OUTROS, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResProdutosCancelados where !cancelado_fiscal ;
		order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResProdutosCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_ULTIMO, _TIT_CANC_ULTIMO, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResProdutosCancelados where cancelado_fiscal ;
		order by data, Periodo_Fechamento, Terminal, produto
endif

if used("curResItensCancelados")
	insert into curReport (TipoGrupo, data, Periodo_Fechamento, Terminal, Caixa_Vendedor, Vendedor_Apelido, TipoRegistro, DescTipoRegistro, DescricaoItem, QtdeItem, ValorItem) ;
		select _RESUMOS, iif(main.IsManager, nvl(data, ctod("")), main.date) as data, Periodo_Fechamento, iif(main.IsManager, Terminal, main.p_Terminal) as Terminal, Caixa_Vendedor, Vendedor_Apelido, ;
		_COD_CANC_ITEM, _TIT_CANC_ITEM, alltrim(produto) + " - " + alltrim(desc_prod_nf), qtde_cancelada, valor_cancelado ;
		from curResItensCancelados order by data, Periodo_Fechamento, Terminal, produto
endif

select curReport
index on str(TipoGrupo) + dtoc(nvl(data, ctod(""))) + Periodo_Fechamento + Terminal + Caixa_Vendedor + Vendedor_Apelido + str(TipoRegistro) tag tagReport

ENDPROC
             
k???    R
  R
                        ??   %   ?	      	
     ?	          ?  U  ! ??  Q? STRING?{T?  ?? SET FMTONLY ON ي SELECT CONVERT(INT, 0) AS TipoGrupo, CONVERT(DATETIME, NULL) AS Data, A.PERIODO_FECHAMENTO AS Periodo_Fechamento, A.TERMINAL AS Terminal, ?2 A.VENDEDOR AS CAIXA_VENDEDOR, C.VENDEDOR_APELIDO, ?| CONVERT(INT, 0) AS TipoRegistro, CONVERT(VARCHAR(100), '') AS DescTipoRegistro, CONVERT(VARCHAR(200), '') AS DescricaoItem, ?1 B.PRECO_LIQUIDO AS ValorItem, B.QTDE AS QtdeItem ?2 FROM LOJA_VENDA A INNER JOIN LOJA_VENDA_PRODUTO B ?] ON A.CODIGO_FILIAL = B.CODIGO_FILIAL AND A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA ?8 INNER JOIN LOJA_VENDEDORES C ON A.VENDEDOR = C.VENDEDOR ? SET FMTONLY OFF??H %?C ?  ?	 curReport?& Erro pesquisando dados dos relat?rios.? 
???? B?-?? ?! %?C? curResInventTrocas????r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResInventTrocas????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ??? ??? Lista de trocas efetuadas??C? ??  - C? ???? ??? ???? ??? ??? ??? ?? ?' %?C? curResProdutosCancelados???W?r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResProdutosCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ?????? Cancelamentos de outros cupons??C? ??  - C? ???? ??? ???? 
???? ??? ??? ??? ?? ?' %?C? curResProdutosCancelados?????#r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResProdutosCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ??????# Cancelamentos do ?ltimo cupom (ECF)??C? ??  - C? ???? ??? ???? ???? ??? ??? ??? ?? ?$ %?C? curResItensCancelados?????r??	 curReport? ? ? ? ? ? ? ?	 ?
 ? ? o? curResItensCancelados????C? ? ? C? C?  #?? ? ? 6?Q? ?? ??C? ? ? ? ? ? ? 6?Q? ?? ??? ?????? Cancelamentos de itens (ECF)??C? ??  - C? ???? ??? ???? ??? ??? ??? ?? ? F? ?3 & ?C? ZCC? C?  #?*? ? ? ? C? Z??? ? U 	 STRSELECT	 SQLSELECT	 TIPOGRUPO DATA PERIODO_FECHAMENTO TERMINAL CAIXA_VENDEDOR VENDEDOR_APELIDO TIPOREGISTRO DESCTIPOREGISTRO DESCRICAOITEM QTDEITEM	 VALORITEM MAIN	 ISMANAGER DATE
 P_TERMINAL PRODUTO DESC_PROD_NF QTDE VALOR CURRESINVENTTROCAS QTDE_CANCELADA VALOR_CANCELADO CURRESPRODUTOSCANCELADOS CANCELADO_FISCAL CURRESITENSCANCELADOS	 CURREPORT	 TAGREPORT Init,     ??1 ?'?q A ?A r?A r5A B4A r 12                       <      )   R
                                                 