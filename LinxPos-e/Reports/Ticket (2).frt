  ¤   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              'ORIENTATION=0
PAPERSIZE=140
COLOR=1

COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=2
COLLATE=1
                                                      16 cpi                                                        curReport.Ticket                                              curReport.TipoRegistro                                        "Acréscimos (+)"                                                                                                            16 cpi                                                        @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) < 0                                                              curReport.codigo_filial                                                                                                     8 cpi                                                         "Ticket"                                                      16 cpi                                                        curReport.ticket                                                                                                            16 cpi                                                        "Data"                                                        16 cpi                                                        curReport.data_venda                                          "@D"                                                                                                                        16 cpi                                                        Ialltrim(curReport.vendedor) + " - " + alltrim(curReport.vendedor_apelido)                                                                                                                   16 cpi                                                        
"Vendedor"                                                    16 cpi                                                        
"Terminal"                                                    16 cpi                                                        curReport.Terminal                                                                                                          16 cpi                                                        "Nota/cupom"                                                                                                                16 cpi                                                        .!empty(nvl(curReport.numero_cupom_fiscal, ""))                curReport.numero_cupom_fiscal                                                                                               16 cpi                                                        .!empty(nvl(curReport.numero_cupom_fiscal, ""))                	"Cliente"                                                                                                                   16 cpi                                                        )!empty(nvl(curReport.codigo_cliente, ''))                     !nvl(curReport.codigo_cliente, '')                                                                                           16 cpi                                                        curReport.cliente_varejo                                                                                                    16 cpi                                                        "Itens vendidos"                                                                                                            13.3 cpi                                                      curReport.TipoRegistro == 1                                   "Itens trocados"                                                                                                            13.3 cpi                                                      curReport.TipoRegistro == 2                                   "Pagamentos"                                                                                                                13.3 cpi                                                      curReport.TipoRegistro == 3                                   curReport.descricao                                                                                                         16 cpi                                                        curReport.TipoRegistro == 1                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 1                                   (curReport.qtde * curReport.preco_liquido                                                                                    16 cpi                                                        curReport.TipoRegistro == 1                                   curReport.Qtde                                                                                                              16 cpi                                                        curReport.TipoRegistro == 1                                   	"peça(s)"                                                                                                                   16 cpi                                                        curReport.TipoRegistro == 1                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.TrocaQtde                                                                                                         16 cpi                                                        curReport.TipoRegistro == 2                                   2curReport.TrocaQtde * curReport.TrocaPreco_Liquido                                                                          16 cpi                                                        curReport.TipoRegistro == 2                                   	"peça(s)"                                                                                                                   16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.TrocaDescricao                                                                                                    16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.vencimento                                          "@D"                                                                                                                        16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.desc_tipo_pgto                                                                                                    16 cpi                                                        curReport.TipoRegistro == 3                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.parcela                                                                                                           16 cpi                                                        curReport.TipoRegistro == 3                                   "parcela(s)"                                                                                                                16 cpi                                                        curReport.TipoRegistro == 3                                   
"Detalhes"                                                                                                                  8 cpi                                                         "Venda bruta (+)"                                                                                                           16 cpi                                                        (nvl(curReport.valor_venda_bruta, 0) != 0                      "Trocas (-)"                                                                                                                16 cpi                                                        "nvl(curReport.valor_troca, 0) != 0                            "Descontos (-)"                                                                                                             16 cpi                                                        @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) > 0                                                              "Total líquido (=)"                                                                                                         16 cpi                                                        "nvl(curReport.total_venda, 0) != 0                            #nvl(curReport.valor_venda_bruta, 0)                                                                                         16 cpi                                                        (nvl(curReport.valor_venda_bruta, 0) != 0                      nvl(curReport.valor_troca, 0)                                                                                               16 cpi                                                        "nvl(curReport.valor_troca, 0) != 0                            <nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0)                                                                                                                                16 cpi                                                        Anvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) != 0                                                             nvl(curReport.total_venda, 0)                                                                                               16 cpi                                                        "nvl(curReport.total_venda, 0) != 0                            "Totais"                                                                                                                    8 cpi                                                         "f"                                                                                                                         control                                                                                                                     curReport.TipoRegistro != 0                                                                                                 curReport.TipoRegistro != 0                                   Main.p_filial                                                                                                               8 cpi                                                          Transform(_ReportCopy) + "Ş via"                                                                                            16 cpi (RED)                                                  type("_ReportCopy") != "U"                                    16 cpi                                                        8 cpi                                                         13.3 cpi                                                      control                                                       16 cpi (RED)                                                  dataenvironment                                               aTop = 237
Left = 368
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                            PROCEDURE Init
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
	c.item, c.descricao, c.codigo_barra, c.qtde, c.preco_liquido, c.desconto_item, c.produto, c.cor_produto, ;
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
	(TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, desconto_item, ;
	produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota) ;
select ;
	_PRODUTOS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, ;
	desconto_item, produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota ;
from ;
	curVendaProdutos ;
order by ;
	item
	
insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, TrocaDescricao, TrocaItem, TrocaCodigo_barra, TrocaQtde, ;
	TrocaPreco_liquido, TrocaDesconto_Item, TrocaProduto, TrocaCor_produto, TrocaTamanho, TrocaQtde_Cancelada, TrocaIpi) ;
select ;
	_TROCAS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, ;
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

ENDPROC
                                             ½ŝò˙    ¤  ¤                        şj   %   )      [     7          ü  U  a %üCÙ	 curReportŞŭù  ŝ Q÷  ŝ ŝoû curVendaQ÷ û curVendaPagamentoQ÷ û curVendaProdutosQ÷# û curVendaTrocasQ÷0 û curVendaParcelasQ÷< û curClienteVarejoQ÷ üĝ ŭQ÷ üġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷	 ŭüġ÷
 ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭQ÷  üġ÷! ŭüġ÷" ŭüġ÷$ ŭüġ÷% ŭüġ÷& ŭüġ÷' ŭüġ÷( ŭüġ÷) ŭüġ÷* ŭüġ÷+ ŭüġ÷, ŭüġ÷- ŭüġ÷. ŭüġ÷/ ŭüġ÷$ ŭQ÷1 üġ÷% ŭQ÷2 üġ÷& ŭQ÷3 üġ÷' ŭQ÷4 üġ÷( ŭQ÷5 üġ÷) ŭQ÷6 üġ÷* ŭQ÷7 üġ÷+ ŭQ÷8 üġ÷, ŭQ÷9 üġ÷- ŭQ÷: üġ÷. ŭQ÷; üġ÷= ŭüġ÷> ŭüġ÷? ŭüġ÷@ ŭüġ÷A ŭüġ÷B ŭüġ÷C ŭüġ÷D ŭüġ÷E ŭüġ÷F ŭüġ÷G ŭüġ÷H ŭüġ÷I ŭüġ÷ ŭQ÷J üġ÷K ŭĈüĝĝ ŭĵ½û	 curReport×ŝ×rĵû	 curReport÷ ÷ ÷ ÷ ÷ ÷	 ÷
 ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷  ÷! ÷" oû curVendaQ÷ ÔÒû curVendaPagamentoQ÷  üġ÷R ġ÷ ? ġ÷S ġ÷ 	? ġ÷ ġ÷ 	ŭüĝ ŭQ÷ üġ÷ ŭüġ÷ ŭüġ÷ ŭüCġ÷ Ù  Òŭüġ÷	 ŭüġ÷
 ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷! ŭüġ÷" ŭŝ %üCôL ÷ Ñ
ŭù6ŝ' pû	 curReportÊ÷ üôQ ÷ ŭĈü÷ ĝ ŭŝ ŝ? rĵû	 curReport÷ ÷ ÷ ÷ ÷% ÷$ ÷& ÷' ÷( ÷) ÷* ÷+ ÷, ÷- ÷. ÷/ oû curVendaProdutosüĝŭQ÷ ü÷ ŭü÷ ŭü÷ ŭü÷% ŭü÷$ ŭü÷& ŭü÷' ŭü÷( ŭü÷) ŭü÷* ŭü÷+ ŭü÷, ŭü÷- ŭü÷. ŭü÷/ ŭ?ü÷$ ŭŝÄ rĵû	 curReport÷ ÷ ÷ ÷ ÷2 ÷1 ÷3 ÷4 ÷5 ÷6 ÷7 ÷8 ÷9 ÷: ÷; oû curVendaTrocasüĝŭQ÷ ü÷ ŭü÷ ŭü÷ ŭü÷% ŭü÷$ ŭü÷& ŭü÷' ŭü÷( ŭü÷) ŭü÷* ŭü÷+ ŭü÷, ŭü÷- ŭü÷. ŭ?ü÷$ ŭŝfrĵû	 curReport÷ ÷ ÷ ÷ ÷= ÷> ÷? ÷@ ÷A ÷B ÷C ÷D ÷E ÷F ÷G ÷H ÷I ÷J ÷K oû curVendaParcelasQ÷ ÔÒû curVendaQ÷  üCġ÷ Cġ÷R ? Cġ÷ ġ÷S 	? Cġ÷ ġ÷ 	ŭüĝŭQ÷ üġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷= ŭüġ÷> ŭüġ÷? ŭüġ÷@ ŭüġ÷A ŭüġ÷B ŭüġ÷C ŭüġ÷D ŭüġ÷E ŭüġ÷F ŭüġ÷G ŭüġ÷H ŭüġ÷I ŭüġ÷ ŭQ÷J üġ÷K ŭ?ü÷A ŭü÷= ŭŝ F÷  ŝ & üC÷ _÷ ÷ C÷ _ŭÊ÷T ŝ #)ŝ UU 	 CURREPORT TIPOREGISTRO A CODIGO_FILIAL TICKET
 DATA_VENDA CODIGO_CLIENTE F CLIENTE_VAREJO VENDEDOR VENDEDOR_APELIDO OPERACAO_VENDA CODIGO_TAB_PRECO
 QTDE_TOTAL VALOR_VENDA_BRUTA QTDE_TROCA_TOTAL VALOR_TROCA DESCONTO VALOR_TIKET TICKET_IMPRESSO GERENTE_LOJA GERENTE_PERIODO VALOR_CANCELADO TOTAL_QTDE_CANCELADA PERIODO_FECHAMENTO B LANCAMENTO_CAIXA TERMINAL NUMERO_CUPOM_FISCAL COD_FORMA_PGTO DESCONTO_PGTO TOTAL_VENDA PGTOVALOR_CANCELADO NUMERO_FISCAL_TROCA CANCELADO_FISCAL C ITEM	 DESCRICAO CODIGO_BARRA QTDE PRECO_LIQUIDO DESCONTO_ITEM PRODUTO COR_PRODUTO TAMANHO QTDE_CANCELADA IPI ALIQUOTA D	 TROCAITEM TROCADESCRICAO TROCACODIGO_BARRA	 TROCAQTDE TROCAPRECO_LIQUIDO TROCADESCONTO_ITEM TROCAPRODUTO TROCACOR_PRODUTO TROCATAMANHO TROCAQTDE_CANCELADA TROCAIPI E PARCELA	 TIPO_PGTO DESC_TIPO_PGTO VALOR
 VENCIMENTO CODIGO_ADMINISTRADORA BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO MOEDA NUMERO_APROVACAO_CARTAO PARCELAS_CARTAO PARCELAVALOR_CANCELADO CHEQUE_CARTAO CURVENDA CURVENDAPAGAMENTO CURVENDAPRODUTOS CURVENDATROCAS CURVENDAPARCELAS CURCLIENTEVAREJO CODIGO_FILIAL_PGTO TERMINAL_PGTO TICKETS Init,     ˙˙1  A 00? q2qA Kor áQ 2                             )   ¤                                                                                   ORIENTATION=0
PAPERSIZE=140
ASCII=140
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=2
COLLATE=1
                                                      16 cpi                                                        curReport.Ticket                                              curReport.TipoRegistro                                        "Acréscimos (+)"                                                                                                            16 cpi                                                        @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) < 0                                                              curReport.codigo_filial                                                                                                     8 cpi                                                         "Ticket"                                                      16 cpi                                                        curReport.ticket                                                                                                            16 cpi                                                        "Data"                                                        16 cpi                                                        curReport.data_venda                                          "@D"                                                                                                                        16 cpi                                                        Ialltrim(curReport.vendedor) + " - " + alltrim(curReport.vendedor_apelido)                                                                                                                   16 cpi                                                        
"Vendedor"                                                    16 cpi                                                        
"Terminal"                                                    16 cpi                                                        curReport.Terminal                                                                                                          16 cpi                                                        "Nota/cupom"                                                                                                                16 cpi                                                        .!empty(nvl(curReport.numero_cupom_fiscal, ""))                curReport.numero_cupom_fiscal                                                                                               16 cpi                                                        .!empty(nvl(curReport.numero_cupom_fiscal, ""))                	"Cliente"                                                                                                                   16 cpi                                                        )!empty(nvl(curReport.codigo_cliente, ''))                     !nvl(curReport.codigo_cliente, '')                                                                                           16 cpi                                                        curReport.cliente_varejo                                                                                                    16 cpi                                                        "Itens vendidos"                                                                                                            13.3 cpi                                                      curReport.TipoRegistro == 1                                   "Itens trocados"                                                                                                            13.3 cpi                                                      curReport.TipoRegistro == 2                                   "Pagamentos"                                                                                                                13.3 cpi                                                      curReport.TipoRegistro == 3                                   curReport.descricao                                                                                                         16 cpi                                                        curReport.TipoRegistro == 1                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 1                                   (curReport.qtde * curReport.preco_liquido                                                                                    16 cpi                                                        curReport.TipoRegistro == 1                                   curReport.Qtde                                                                                                              16 cpi                                                        curReport.TipoRegistro == 1                                   	"peça(s)"                                                                                                                   16 cpi                                                        curReport.TipoRegistro == 1                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.TrocaQtde                                                                                                         16 cpi                                                        curReport.TipoRegistro == 2                                   2curReport.TrocaQtde * curReport.TrocaPreco_Liquido                                                                          16 cpi                                                        curReport.TipoRegistro == 2                                   	"peça(s)"                                                                                                                   16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.TrocaDescricao                                                                                                    16 cpi                                                        curReport.TipoRegistro == 2                                   curReport.vencimento                                          "@D"                                                                                                                        16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.desc_tipo_pgto                                                                                                    16 cpi                                                        curReport.TipoRegistro == 3                                   "Total"                                                                                                                     16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             16 cpi                                                        curReport.TipoRegistro == 3                                   curReport.parcela                                                                                                           16 cpi                                                        curReport.TipoRegistro == 3                                   "parcela(s)"                                                                                                                16 cpi                                                        curReport.TipoRegistro == 3                                   
"Detalhes"                                                                                                                  8 cpi                                                         "Venda bruta (+)"                                                                                                           16 cpi                                                        (nvl(curReport.valor_venda_bruta, 0) != 0                      "Trocas (-)"                                                                                                                16 cpi                                                        "nvl(curReport.valor_troca, 0) != 0                            "Descontos (-)"                                                                                                             16 cpi                                                        @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) > 0                                                              "Total líquido (=)"                                                                                                         16 cpi                                                        "nvl(curReport.total_venda, 0) != 0                            #nvl(curReport.valor_venda_bruta, 0)                                                                                         16 cpi                                                        (nvl(curReport.valor_venda_bruta, 0) != 0                      nvl(curReport.valor_troca, 0)                                                                                               16 cpi                                                        "nvl(curReport.valor_troca, 0) != 0                            <nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0)                                                                                                                                16 cpi                                                        Anvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) != 0                                                             nvl(curReport.total_venda, 0)                                                                                               16 cpi                                                        "nvl(curReport.total_venda, 0) != 0                            "Totais"                                                                                                                    8 cpi                                                         "f"                                                                                                                         control                                                                                                                     curReport.TipoRegistro != 0                                                                                                 curReport.TipoRegistro != 0                                   Main.p_filial                                                                                                               8 cpi                                                          Transform(_ReportCopy) + "Ş via"                                                                                            16 cpi (RED)                                                  type("_ReportCopy") != "U"                                    16 cpi                                                        8 cpi                                                         13.3 cpi                                                      control                                                       16 cpi (RED)                                                  dataenvironment                                               aTop = 237
Left = 368
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                            ŜPROCEDURE Init
#define _VENDA 0
#define _PRODUTOS 1
#define _TROCAS 2
#define _PARCELAS 3

select ;
	0 as TipoRegistro, ;
	a.codigo_filial, a.ticket, a.data_venda, a.codigo_cliente, f.cliente_varejo, a.vendedor, a.vendedor_apelido, ;
	a.operacao_venda, a.codigo_tab_preco, a.qtde_total, a.valor_venda_bruta, a.qtde_troca_total, a.valor_troca, ;
	a.desconto, a.valor_tiket, a.ticket_impresso, a.gerente_loja, a.gerente_periodo, a.valor_cancelado, a.total_qtde_cancelada, ;
	a.periodo_fechamento, b.lancamento_caixa, b.terminal, b.numero_cupom_fiscal, b.cod_forma_pgto, b.desconto_pgto, ;
	b.total_venda, b.valor_cancelado as PgtoValor_Cancelado, b.numero_fiscal_troca, b.cancelado_fiscal, ;
	c.item, c.descricao, c.codigo_barra, c.qtde, c.preco_liquido, c.desconto_item, c.produto, c.cor_produto, ;
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
	(TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, desconto_item, ;
	produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota) ;
select ;
	_PRODUTOS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, ;
	desconto_item, produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota ;
from ;
	curVendaProdutos ;
order by ;
	item
	
insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, TrocaDescricao, TrocaItem, TrocaCodigo_barra, TrocaQtde, ;
	TrocaPreco_liquido, TrocaDesconto_Item, TrocaProduto, TrocaCor_produto, TrocaTamanho, TrocaQtde_Cancelada, TrocaIpi) ;
select ;
	_TROCAS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, ;
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

ENDPROC
                               ŝò˙    z  z                        ÌI   %         1               ü  U  =oû curVendaQ÷ û curVendaPagamentoQ÷ û curVendaProdutosQ÷" û curVendaTrocasQ÷/ û curVendaParcelasQ÷; û curClienteVarejoQ÷ üĝ ŭQ÷  üġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷	 ŭüġ÷
 ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭQ÷ üġ÷  ŭüġ÷! ŭüġ÷# ŭüġ÷$ ŭüġ÷% ŭüġ÷& ŭüġ÷' ŭüġ÷( ŭüġ÷) ŭüġ÷* ŭüġ÷+ ŭüġ÷, ŭüġ÷- ŭüġ÷. ŭüġ÷# ŭQ÷0 üġ÷$ ŭQ÷1 üġ÷% ŭQ÷2 üġ÷& ŭQ÷3 üġ÷' ŭQ÷4 üġ÷( ŭQ÷5 üġ÷) ŭQ÷6 üġ÷* ŭQ÷7 üġ÷+ ŭQ÷8 üġ÷, ŭQ÷9 üġ÷- ŭQ÷: üġ÷< ŭüġ÷= ŭüġ÷> ŭüġ÷? ŭüġ÷@ ŭüġ÷A ŭüġ÷B ŭüġ÷C ŭüġ÷D ŭüġ÷E ŭüġ÷F ŭüġ÷G ŭüġ÷H ŭüġ÷ ŭQ÷I üġ÷J ŭĈüĝĝ ŭĵ½û	 curReport×ŝ×rĵû	 curReport÷  ÷ ÷ ÷ ÷ ÷ ÷	 ÷
 ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷  ÷! oû curVendaQ÷ ÔÒû curVendaPagamentoQ÷  üġ÷R ġ÷ ? ġ÷S ġ÷ 	? ġ÷ ġ÷ 	ŭüĝ ŭQ÷  üġ÷ ŭüġ÷ ŭüġ÷ ŭüCġ÷ Ù  Òŭüġ÷ ŭüġ÷	 ŭüġ÷
 ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷  ŭüġ÷! ŭŝ %üCôK ÷ Ñ
ŭùŝ' pû	 curReportÊ÷ üôP ÷ ŭĈü÷  ĝ ŭŝ ŝ? rĵû	 curReport÷  ÷ ÷ ÷ ÷$ ÷# ÷% ÷& ÷' ÷( ÷) ÷* ÷+ ÷, ÷- ÷. oû curVendaProdutosüĝŭQ÷  ü÷ ŭü÷ ŭü÷ ŭü÷$ ŭü÷# ŭü÷% ŭü÷& ŭü÷' ŭü÷( ŭü÷) ŭü÷* ŭü÷+ ŭü÷, ŭü÷- ŭü÷. ŭ?ü÷# ŭŝÄ rĵû	 curReport÷  ÷ ÷ ÷ ÷1 ÷0 ÷2 ÷3 ÷4 ÷5 ÷6 ÷7 ÷8 ÷9 ÷: oû curVendaTrocasüĝŭQ÷  ü÷ ŭü÷ ŭü÷ ŭü÷$ ŭü÷# ŭü÷% ŭü÷& ŭü÷' ŭü÷( ŭü÷) ŭü÷* ŭü÷+ ŭü÷, ŭü÷- ŭ?ü÷# ŭŝfrĵû	 curReport÷  ÷ ÷ ÷ ÷< ÷= ÷> ÷? ÷@ ÷A ÷B ÷C ÷D ÷E ÷F ÷G ÷H ÷I ÷J oû curVendaParcelasQ÷ ÔÒû curVendaQ÷  üCġ÷ Cġ÷R ? Cġ÷ ġ÷S 	? Cġ÷ ġ÷ 	ŭüĝŭQ÷  üġ÷ ŭüġ÷ ŭüġ÷ ŭüġ÷< ŭüġ÷= ŭüġ÷> ŭüġ÷? ŭüġ÷@ ŭüġ÷A ŭüġ÷B ŭüġ÷C ŭüġ÷D ŭüġ÷E ŭüġ÷F ŭüġ÷G ŭüġ÷H ŭüġ÷ ŭQ÷I üġ÷J ŭ?ü÷@ ŭü÷< ŭŝ F÷Q ŝ & üC÷  _÷ ÷ C÷ _ŭÊ÷T ŝ #)ŝ UU  TIPOREGISTRO A CODIGO_FILIAL TICKET
 DATA_VENDA CODIGO_CLIENTE F CLIENTE_VAREJO VENDEDOR VENDEDOR_APELIDO OPERACAO_VENDA CODIGO_TAB_PRECO
 QTDE_TOTAL VALOR_VENDA_BRUTA QTDE_TROCA_TOTAL VALOR_TROCA DESCONTO VALOR_TIKET TICKET_IMPRESSO GERENTE_LOJA GERENTE_PERIODO VALOR_CANCELADO TOTAL_QTDE_CANCELADA PERIODO_FECHAMENTO B LANCAMENTO_CAIXA TERMINAL NUMERO_CUPOM_FISCAL COD_FORMA_PGTO DESCONTO_PGTO TOTAL_VENDA PGTOVALOR_CANCELADO NUMERO_FISCAL_TROCA CANCELADO_FISCAL C ITEM	 DESCRICAO CODIGO_BARRA QTDE PRECO_LIQUIDO DESCONTO_ITEM PRODUTO COR_PRODUTO TAMANHO QTDE_CANCELADA IPI ALIQUOTA D	 TROCAITEM TROCADESCRICAO TROCACODIGO_BARRA	 TROCAQTDE TROCAPRECO_LIQUIDO TROCADESCONTO_ITEM TROCAPRODUTO TROCACOR_PRODUTO TROCATAMANHO TROCAQTDE_CANCELADA TROCAIPI E PARCELA	 TIPO_PGTO DESC_TIPO_PGTO VALOR
 VENCIMENTO CODIGO_ADMINISTRADORA BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO MOEDA NUMERO_APROVACAO_CARTAO PARCELAS_CARTAO PARCELAVALOR_CANCELADO CHEQUE_CARTAO CURVENDA CURVENDAPAGAMENTO CURVENDAPRODUTOS CURVENDATROCAS CURVENDAPARCELAS CURCLIENTEVAREJO	 CURREPORT CODIGO_FILIAL_PGTO TERMINAL_PGTO TICKETS Init,     ˙˙1 p0? q2qA Kor áQ 2                       Ó      )   z                                                       