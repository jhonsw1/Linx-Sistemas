     !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              16 cpi                         ?ORIENTATION=0
PAPERSIZE=1
ASCII=1
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                     curReport.Ticket               curReport.TipoRegistro         16 cpi                         @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) < 0                                                                "Acr?scimos (+)"               curReport.codigo_filial                                       8 cpi                          16 cpi                         "Ticket"                       curReport.ticket                                              16 cpi                         16 cpi                         "Data"                         curReport.data_venda                                          16 cpi                         "@D"                           Ialltrim(curReport.vendedor) + " - " + alltrim(curReport.vendedor_apelido)                                                       16 cpi                         16 cpi                         
"Vendedor"                     16 cpi                         
"Terminal"                     curReport.Terminal                                            16 cpi                         16 cpi                         .!empty(nvl(curReport.numero_cupom_fiscal, ""))                                                 "Nota/cupom"                   curReport.numero_cupom_fiscal                                                                  16 cpi                         .!empty(nvl(curReport.numero_cupom_fiscal, ""))                  16 cpi                         )!empty(nvl(curReport.codigo_cliente, ''))                                                      	"Cliente"                      !nvl(curReport.codigo_cliente, '')                                                              16 cpi                         curReport.cliente_varejo                                      16 cpi                         13.3 cpi                       curReport.TipoRegistro == 1                                                                    "Itens vendidos"               13.3 cpi                       curReport.TipoRegistro == 2                                                                    "Itens trocados"               13.3 cpi                       curReport.TipoRegistro == 3                                                                    "Pagamentos"                   7allt(curReport.desc_prod_nf)+'-'+allt(desc_cor_produto)                                        16 cpi                         curReport.TipoRegistro == 1                                     16 cpi                         curReport.TipoRegistro == 1                                                                    "Total"                        (curReport.qtde * curReport.preco_liquido                                                       16 cpi                         curReport.TipoRegistro == 1                                     curReport.Qtde                                                16 cpi                         curReport.TipoRegistro == 1                                     16 cpi                         curReport.TipoRegistro == 1                                                                    	"pe?a(s)"                      16 cpi                         curReport.TipoRegistro == 2                                                                    "Total"                        curReport.TrocaQtde                                           16 cpi                         curReport.TipoRegistro == 2                                     2curReport.TrocaQtde * curReport.TrocaPreco_Liquido                                             16 cpi                         curReport.TipoRegistro == 2                                     16 cpi                         curReport.TipoRegistro == 2                                                                    	"pe?a(s)"                      curReport.TrocaDescricao                                      16 cpi                         curReport.TipoRegistro == 2                                     curReport.vencimento                                          16 cpi                         curReport.TipoRegistro == 3                                     "@D"                           curReport.valor                                               16 cpi                         curReport.TipoRegistro == 3                                     curReport.desc_tipo_pgto                                      16 cpi                         curReport.TipoRegistro == 3                                     16 cpi                         curReport.TipoRegistro == 3                                                                    "Total"                        curReport.valor                                               16 cpi                         curReport.TipoRegistro == 3                                     curReport.parcela                                             16 cpi                         curReport.TipoRegistro == 3                                     16 cpi                         curReport.TipoRegistro == 3                                                                    "parcela(s)"                   
"Detalhes"                                                    8 cpi                          16 cpi                         (nvl(curReport.valor_venda_bruta, 0) != 0                                                       "Venda bruta (+)"              16 cpi                         "nvl(curReport.valor_troca, 0) != 0                                                             "Trocas (-)"                   16 cpi                         @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) > 0                                                                "Descontos (-)"                16 cpi                         "nvl(curReport.total_venda, 0) != 0                                                             "Total l?quido (=)"            #nvl(curReport.valor_venda_bruta, 0)                                                            16 cpi                         (nvl(curReport.valor_venda_bruta, 0) != 0                        nvl(curReport.valor_troca, 0)                                                                  16 cpi                         "nvl(curReport.valor_troca, 0) != 0                              <nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0)                                                                    16 cpi                         Anvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) != 0                                nvl(curReport.total_venda, 0)                                                                  16 cpi                         "nvl(curReport.total_venda, 0) != 0                              "Totais"                                                      8 cpi                          "f"                                                           control                                                       curReport.TipoRegistro != 0                                                                    curReport.TipoRegistro != 0                                     Main.p_filial                                                 8 cpi                           Transform(_ReportCopy) + "? via"                                                               16 cpi (RED)                   type("_ReportCopy") != "U"                                      curReport.qtde                                                16 cpi                         curReport.TipoRegistro == 1                                     curReport.preco_liquido                                       16 cpi                         curReport.TipoRegistro == 3                                     16 cpi                         8 cpi                          13.3 cpi                       control                        16 cpi (RED)                   dataenvironment                aTop = 237
Left = 368
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                cPROCEDURE Init
#define _VENDA 0
#define _PRODUTOS 1
#define _TROCAS 2
#define _PARCELAS 3

if used("curReport")
	use in curReport
endif

select ;
	0 as TipoRegistro, ;
	a.codigo_filial, a.ticket, a.data_venda, a.codigo_cliente, f.cliente_varejo, a.vendedor, a.vendedor_apelido, ;
	a.operacao_venda, a.codigo_tab_preco, a.qtde_total, a.valor_venda_bruta, a.qtde_troca_total, a.valor_troca, ;
	a.desconto, a.valor_tiket, a.ticket_impresso, a.gerente_loja, a.gerente_periodo, a.valor_cancelado, a.total_qtde_cancelada, ;
	a.periodo_fechamento, b.lancamento_caixa, b.terminal, b.numero_cupom_fiscal, b.cod_forma_pgto, b.desconto_pgto, ;
	b.total_venda, b.valor_cancelado as PgtoValor_Cancelado, b.numero_fiscal_troca, b.cancelado_fiscal, ;
	c.item, c.desc_prod_nf, c.codigo_barra, c.qtde, c.preco_liquido, c.desconto_item, c.produto, c.cor_produto, c.desc_cor_produto, ;
	c.tamanho, c.qtde_cancelada, c.ipi, c.aliquota, ;
	d.item as TrocaItem, d.descricao as TrocaDescricao, d.codigo_barra as TrocaCodigo_Barra, d.qtde as TrocaQtde, ;
	d.preco_liquido as TrocaPreco_Liquido, d.desconto_item as TrocaDesconto_Item, d.produto as TrocaProduto, ;
	d.cor_produto as TrocaCor_produto, d.tamanho as TrocaTamanho, d.qtde_cancelada as TrocaQtde_Cancelada, d.ipi as TrocaIpi, ;
	e.parcela, e.tipo_pgto, e.desc_tipo_pgto, e.valor, e.vencimento, e.codigo_administradora, e.banco, e.agencia, e.conta_corrente, ;
	e.numero_titulo, e.moeda, e.numero_aprovacao_cartao, e.parcelas_cartao, e.valor_cancelado as ParcelaValor_Cancelado, ;
	e.cheque_cartao ;
from ;
	curVenda a, curVendaPagamento b, curVendaProdutos c, curVendaTrocas d, curVendaParcelas e, curClienteVarejo f ;
where 1 = 0 ;
into cursor curReport readwrite

insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, codigo_cliente, vendedor, vendedor_apelido, ;
	operacao_venda, codigo_tab_preco, qtde_total, valor_venda_bruta, qtde_troca_total, valor_troca, desconto, valor_tiket, ;
	ticket_impresso, gerente_loja, gerente_periodo, valor_cancelado, total_qtde_cancelada, periodo_fechamento, ;
	lancamento_caixa, terminal, numero_cupom_fiscal, cod_forma_pgto, desconto_pgto, total_venda, PgtoValor_cancelado, ;
	numero_fiscal_troca, cancelado_fiscal) ;
select ;
	_VENDA as TipoRegistro, a.codigo_filial, a.ticket, a.data_venda, nvl(a.codigo_cliente, ""), a.vendedor, ;
	a.vendedor_apelido, a.operacao_venda, a.codigo_tab_preco, a.qtde_total, a.valor_venda_bruta, a.qtde_troca_total, ;
	a.valor_troca, a.desconto, a.valor_tiket, a.ticket_impresso, a.gerente_loja, a.gerente_periodo, a.valor_cancelado, ;
	a.total_qtde_cancelada, a.periodo_fechamento, b.lancamento_caixa, b.terminal, b.numero_cupom_fiscal, b.cod_forma_pgto, ;
	b.desconto_pgto, b.total_venda, b.valor_cancelado, b.numero_fiscal_troca, b.cancelado_fiscal ;
from ;
	curVenda a inner join curVendaPagamento b on a.codigo_filial_pgto = b.codigo_filial and a.terminal_pgto = b.terminal ;
	and a.lancamento_caixa = b.lancamento_caixa
	
if !isnull(curVenda.codigo_cliente)
	update curReport set cliente_varejo = curClienteVarejo.cliente_varejo where TipoRegistro = _VENDA
endif

insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, desc_prod_nf, item, codigo_barra, qtde, preco_liquido, desconto_item, ;
	produto, cor_produto, desc_cor_produto, tamanho, qtde_cancelada, ipi, aliquota) ;
select ;
	_PRODUTOS as TipoRegistro, codigo_filial, ticket, data_venda, desc_prod_nf, item, codigo_barra, qtde, preco_liquido, ;
	desconto_item, produto, cor_produto, desc_cor_produto, tamanho, qtde_cancelada, ipi, aliquota ;
from ;
	curVendaProdutos ;
order by ;
	item
	
insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, TrocaDescricao, TrocaItem, TrocaCodigo_barra, TrocaQtde, ;
	TrocaPreco_liquido, TrocaDesconto_Item, TrocaProduto, TrocaCor_produto, TrocaTamanho, TrocaQtde_Cancelada, TrocaIpi) ;
select ;
	_TROCAS as TipoRegistro, codigo_filial, ticket, data_venda, desc_prod_nf, item, codigo_barra, qtde, preco_liquido, ;
	desconto_item, produto, cor_produto, tamanho, qtde_cancelada, ipi ;
from ;
	curVendaTrocas ;
order by ;
	item

insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, parcela, tipo_pgto, desc_tipo_pgto, valor, vencimento, ;
	codigo_administradora, banco, agencia, conta_corrente, numero_titulo, moeda, numero_aprovacao_cartao, parcelas_cartao, ;
	ParcelaValor_Cancelado, cheque_cartao) ;
select ;
	_PARCELAS as TipoRegistro, a.codigo_filial, b.ticket, b.data_venda, a.parcela, a.tipo_pgto, a.desc_tipo_pgto, ;
	a.valor, a.vencimento, a.codigo_administradora, a.banco, a.agencia, a.conta_corrente, ;
	a.numero_titulo, a.moeda, a.numero_aprovacao_cartao, a.parcelas_cartao, a.valor_cancelado as ParcelaValor_Cancelado, ;
	a.cheque_cartao ;
from ;
	curVendaParcelas a inner join curVenda b on alltrim(a.codigo_filial) == alltrim(b.codigo_filial_pgto) ;
	and alltrim(a.terminal) == b.terminal_pgto and alltrim(a.lancamento_caixa) == (b.lancamento_caixa) ;
order by ;
	vencimento, parcela

select curReport
index on transform(TipoRegistro) + codigo_filial + ticket + transform(data_venda) tag Tickets
go top
BROWSE normal

ENDPROC
                         ????    ?  ?                        ";   %   `      ?     n          ?  U  x %?C?	 curReport???  ? Q?  ? ?	o? curVendaQ? ? curVendaPagamentoQ? ? curVendaProdutosQ?# ? curVendaTrocasQ?1 ? curVendaParcelasQ?> ? curClienteVarejoQ? ?? ?Q? ??? ???? ???? ???? ???? ????	 ????
 ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ?Q?  ???! ????" ????$ ????% ????& ????' ????( ????) ????* ????+ ????, ????- ????. ????/ ????0 ????$ ?Q?2 ???3 ?Q?4 ???& ?Q?5 ???' ?Q?6 ???( ?Q?7 ???) ?Q?8 ???* ?Q?9 ???+ ?Q?: ???- ?Q?; ???. ?Q?< ???/ ?Q?= ???? ????@ ????A ????B ????C ????D ????E ????F ????G ????H ????I ????J ????K ???? ?Q?L ???M ????? ????	 curReport???r??	 curReport? ? ? ? ? ?	 ?
 ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?  ?! ?" o? curVendaQ? ??? curVendaPagamentoQ?  ???T ?? ? ??U ?? 	? ?? ?? 	??? ?Q? ??? ???? ???? ??C?? ?  ?????	 ????
 ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ???? ????! ????" ?? %?C?N ? ?
??>?' p?	 curReport?? ??S ? ???? ? ?? ?? r??	 curReport? ? ? ? ?% ?$ ?& ?' ?( ?) ?* ?+ ?, ?- ?. ?/ ?0 o? curVendaProdutos???Q? ?? ??? ??? ???% ???$ ???& ???' ???( ???) ???* ???+ ???, ???- ???. ???/ ???0 ????$ ??? r??	 curReport? ? ? ? ?4 ?2 ?5 ?6 ?7 ?8 ?9 ?: ?; ?< ?= o? curVendaTrocas???Q? ?? ??? ??? ???% ???$ ???& ???' ???( ???) ???* ???+ ???- ???. ???/ ????$ ??fr??	 curReport? ? ? ? ?? ?@ ?A ?B ?C ?D ?E ?F ?G ?H ?I ?J ?K ?L ?M o? curVendaParcelasQ? ??? curVendaQ?  ?C?? ?C??T ?? C?? ???U 	? C?? ??? 	????Q? ??? ???? ???? ????? ????@ ????A ????B ????C ????D ????E ????F ????G ????H ????I ????J ????K ???? ?Q?L ???M ????C ???? ?? F?  ? & ?C? _? ? C? _???V ? #)? 	?? UW 	 CURREPORT TIPOREGISTRO A CODIGO_FILIAL TICKET
 DATA_VENDA CODIGO_CLIENTE F CLIENTE_VAREJO VENDEDOR VENDEDOR_APELIDO OPERACAO_VENDA CODIGO_TAB_PRECO
 QTDE_TOTAL VALOR_VENDA_BRUTA QTDE_TROCA_TOTAL VALOR_TROCA DESCONTO VALOR_TIKET TICKET_IMPRESSO GERENTE_LOJA GERENTE_PERIODO VALOR_CANCELADO TOTAL_QTDE_CANCELADA PERIODO_FECHAMENTO B LANCAMENTO_CAIXA TERMINAL NUMERO_CUPOM_FISCAL COD_FORMA_PGTO DESCONTO_PGTO TOTAL_VENDA PGTOVALOR_CANCELADO NUMERO_FISCAL_TROCA CANCELADO_FISCAL C ITEM DESC_PROD_NF CODIGO_BARRA QTDE PRECO_LIQUIDO DESCONTO_ITEM PRODUTO COR_PRODUTO DESC_COR_PRODUTO TAMANHO QTDE_CANCELADA IPI ALIQUOTA D	 TROCAITEM	 DESCRICAO TROCADESCRICAO TROCACODIGO_BARRA	 TROCAQTDE TROCAPRECO_LIQUIDO TROCADESCONTO_ITEM TROCAPRODUTO TROCACOR_PRODUTO TROCATAMANHO TROCAQTDE_CANCELADA TROCAIPI E PARCELA	 TIPO_PGTO DESC_TIPO_PGTO VALOR
 VENCIMENTO CODIGO_ADMINISTRADORA BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO MOEDA NUMERO_APROVACAO_CARTAO PARCELAS_CARTAO PARCELAVALOR_CANCELADO CHEQUE_CARTAO CURVENDA CURVENDAPAGAMENTO CURVENDAPRODUTOS CURVENDATROCAS CURVENDAPARCELAS CURCLIENTEVAREJO CODIGO_FILIAL_PGTO TERMINAL_PGTO TICKETS Init,     ??1 ?? A 0?0? q2qA ?Kor ?Q Q 2                       X      )   ?                  