  �   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              'ORIENTATION=0
PAPERSIZE=140
COLOR=1
URCE=15
YRESOLUTION=72
TTOPTION=3
                                                  Courier New                                                   curReport.Ticket                                              curReport.TipoRegistro                                        "Acr�scimos (+)"                                                                                                            Courier New                                                   @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) < 0                                                                                                                            curReport.TipoRegistro > 0                                    Aalltrim(curReport.codigo_filial) + " - " + alltrim(Main.p_filial)                                                                                                                           Courier New                                                   "Ticket"                                                      Courier New                                                   curReport.ticket                                                                                                            Courier New                                                   "Data"                                                        Courier New                                                   curReport.data_venda                                          "@D"                                                                                                                        Courier New                                                   Ialltrim(curReport.vendedor) + " - " + alltrim(curReport.vendedor_apelido)                                                                                                                   Courier New                                                   
"Vendedor"                                                    Courier New                                                   
"Terminal"                                                    Courier New                                                   curReport.Terminal                                                                                                          Courier New                                                   "Nota/cupom"                                                                                                                Courier New                                                   .!empty(nvl(curReport.numero_cupom_fiscal, ""))                curReport.numero_cupom_fiscal                                                                                               Courier New                                                   .!empty(nvl(curReport.numero_cupom_fiscal, ""))                	"Cliente"                                                                                                                   Courier New                                                   )!empty(nvl(curReport.codigo_cliente, ''))                     !nvl(curReport.codigo_cliente, '')                                                                                           Courier New                                                   curReport.cliente_varejo                                                                                                    Courier New                                                                                                                 curReport.TipoRegistro > 0                                    "Itens vendidos"                                                                                                            Courier New                                                   curReport.TipoRegistro == 1                                   "Itens trocados"                                                                                                            Courier New                                                   curReport.TipoRegistro == 2                                   "Pagamentos"                                                                                                                Courier New                                                   curReport.TipoRegistro == 3                                   curReport.descricao                                                                                                         Courier New                                                   curReport.TipoRegistro == 1                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 1                                   curReport.preco_liquido                                                                                                     Courier New                                                   curReport.TipoRegistro == 1                                   curReport.Qtde                                                                                                              Courier New                                                   curReport.TipoRegistro == 1                                   	"pe�a(s)"                                                                                                                   Courier New                                                   curReport.TipoRegistro == 1                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaQtde                                                                                                         Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaPreco_Liquido                                                                                                Courier New                                                   curReport.TipoRegistro == 2                                   	"pe�a(s)"                                                                                                                   Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaDescricao                                                                                                    Courier New                                                   curReport.TipoRegistro == 2                                   curReport.vencimento                                          "@D"                                                                                                                        Courier New                                                   curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             Courier New                                                   curReport.TipoRegistro == 3                                   curReport.desc_tipo_pgto                                                                                                    Courier New                                                   curReport.TipoRegistro == 3                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             Courier New                                                   curReport.TipoRegistro == 3                                   curReport.parcela                                                                                                           Courier New                                                   curReport.TipoRegistro == 3                                   "parcela(s)"                                                                                                                Courier New                                                   curReport.TipoRegistro == 3                                   
"Detalhes"                                                                                                                  Courier New                                                   "Venda bruta (+)"                                                                                                           Courier New                                                   (nvl(curReport.valor_venda_bruta, 0) != 0                      "Trocas (-)"                                                                                                                Courier New                                                   "nvl(curReport.valor_troca, 0) != 0                            "Descontos (-)"                                                                                                             Courier New                                                   @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) > 0                                                              "Total l�quido (=)"                                                                                                         Courier New                                                   "nvl(curReport.total_venda, 0) != 0                            #nvl(curReport.valor_venda_bruta, 0)                                                                                         Courier New                                                   (nvl(curReport.valor_venda_bruta, 0) != 0                      nvl(curReport.valor_troca, 0)                                                                                               Courier New                                                   "nvl(curReport.valor_troca, 0) != 0                            <nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0)                                                                                                                                Courier New                                                   Anvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) != 0                                                             nvl(curReport.total_venda, 0)                                                                                               Courier New                                                   "nvl(curReport.total_venda, 0) != 0                            "Totais"                                                                                                                    Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               aTop = 408
Left = 498
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                            PROCEDURE Init
#define _VENDA 0
#define _PRODUTOS 1
#define _TROCAS 2
#define _PARCELAS 3

*!* Debug

*!*	sqlexec(Main.pActiveConnection, "SELECT LOJA_VENDA.*, CONVERT(NUMERIC(14, 2), 0) AS PercentualDesconto, VENDEDOR_APELIDO FROM LOJA_VENDA INNER JOIN LOJA_VENDEDORES B ON LOJA_VENDA.VENDEDOR = B.VENDEDOR WHERE TICKET = '00000227'", "curVenda")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.* FROM CLIENTES_VAREJO A INNER JOIN LOJA_VENDA B ON A.CODIGO_CLIENTE = B.CODIGO_CLIENTE WHERE TICKET = '00000227'", "curClienteVarejo")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.*, CONVERT(VARCHAR, QTDE) + ' X ' + CONVERT(VARCHAR, PRECO_LIQUIDO) + ' = ' + " + ;
*!*		"CONVERT(VARCHAR, QTDE * PRECO_LIQUIDO) + CHAR(13) + DESC_PROD_NF AS DESCRICAO FROM LOJA_VENDA_PRODUTO A INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO WHERE TICKET = '00000227'", "curVendaProdutos")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.*, CONVERT(VARCHAR, QTDE) + ' X ' + CONVERT(VARCHAR, PRECO_LIQUIDO) + ' = ' + " + ;
*!*		"CONVERT(VARCHAR, QTDE * PRECO_LIQUIDO) + CHAR(13) + DESC_PROD_NF AS DESCRICAO FROM LOJA_VENDA_TROCA A INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO WHERE TICKET = '00000227'", "curVendaTrocas")

*!*	sqlexec(Main.pActiveConnection, "SELECT * FROM LOJA_VENDA_PGTO WHERE LANCAMENTO_CAIXA = '2863003'", "curVendaPagamento")

*!*	sqlexec(Main.pActiveConnection, "SELECT LOJA_VENDA_PARCELAS.*, ADMINISTRADORA, DESC_TIPO_PGTO, ACEITA_PARCELAMENTO, CONVERT(VARCHAR(20), '') AS CPF, " + ;
*!*		"CONVERT(TEXT, '') AS RESULTADOTEF FROM LOJA_VENDA_PARCELAS INNER JOIN TIPOS_PGTO B ON LOJA_VENDA_PARCELAS.TIPO_PGTO = B.TIPO_PGTO " + ;
*!*		"LEFT JOIN ADMINISTRADORAS_CARTAO C ON C.CODIGO_ADMINISTRADORA = LOJA_VENDA_PARCELAS.CODIGO_ADMINISTRADORA  WHERE LANCAMENTO_CAIXA = '2863003'", "curVendaParcelas")

*!* End Debug

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
	(TipoRegistro, codigo_filial, ticket, data_venda, codigo_cliente, cliente_varejo, vendedor, vendedor_apelido, ;
	operacao_venda, codigo_tab_preco, qtde_total, valor_venda_bruta, qtde_troca_total, valor_troca, desconto, valor_tiket, ;
	ticket_impresso, gerente_loja, gerente_periodo, valor_cancelado, total_qtde_cancelada, periodo_fechamento, ;
	lancamento_caixa, terminal, numero_cupom_fiscal, cod_forma_pgto, desconto_pgto, total_venda, PgtoValor_cancelado, ;
	numero_fiscal_troca, cancelado_fiscal) ;
select ;
	_VENDA as TipoRegistro, a.codigo_filial, a.ticket, a.data_venda, a.codigo_cliente, nvl(c.cliente_varejo, ""), a.vendedor, ;
	a.vendedor_apelido, a.operacao_venda, a.codigo_tab_preco, a.qtde_total, a.valor_venda_bruta, a.qtde_troca_total, ;
	a.valor_troca, a.desconto, a.valor_tiket, a.ticket_impresso, a.gerente_loja, a.gerente_periodo, a.valor_cancelado, ;
	a.total_qtde_cancelada, a.periodo_fechamento, b.lancamento_caixa, b.terminal, b.numero_cupom_fiscal, b.cod_forma_pgto, ;
	b.desconto_pgto, b.total_venda, b.valor_cancelado, b.numero_fiscal_troca, b.cancelado_fiscal ;
from ;
	curVenda a inner join curVendaPagamento b on a.codigo_filial_pgto = b.codigo_filial and a.terminal_pgto = b.terminal ;
	and a.lancamento_caixa = b.lancamento_caixa ;
	left join curClienteVarejo c on c.codigo_cliente = a.codigo_cliente
	
insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, desconto_item, ;
	produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota) ;
select ;
	_PRODUTOS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, desconto_item, ;
	preco_liquido, produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota ;
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
	curVendaParcelas a inner join curVenda b on a.codigo_filial = b.codigo_filial_pgto and a.terminal = b.terminal_pgto ;
	and a.lancamento_caixa = b.lancamento_caixa ;
order by ;
	vencimento, parcela


ENDPROC
                                         l���    S  S                        A�   %   �      
     �          �  U  # %�C�	 curReport���  � Q�  � �o� curVendaQ� � curVendaPagamentoQ� � curVendaProdutosQ�# � curVendaTrocasQ�0 � curVendaParcelasQ�< � curClienteVarejoQ� �� �Q� ��� ���� ���� ���� ���� ����	 ����
 ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� �Q�  ���! ����" ����$ ����% ����& ����' ����( ����) ����* ����+ ����, ����- ����. ����/ ����$ �Q�1 ���% �Q�2 ���& �Q�3 ���' �Q�4 ���( �Q�5 ���) �Q�6 ���* �Q�7 ���+ �Q�8 ���, �Q�9 ���- �Q�: ���. �Q�; ���= ����> ����? ����@ ����A ����B ����C ����D ����E ����F ����G ����H ����I ���� �Q�J ���K ����� ����	 curReport��
r��	 curReport� � � � � � �	 �
 � � � � � � � � � � � � � � � � � � � � �  �! �" o� curVendaQ� ��� curVendaPagamentoQ�  ���R �� � ��S �� 	� �� �� 	�X�� curClienteVarejoQ�#  ��� �� ��� �Q� ��� ���� ���� ���� ��C�� �  �����	 ����
 ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ����! ����" ��� r��	 curReport� � � � �% �$ �& �' �( �) �* �+ �, �- �. �/ o� curVendaProdutos���Q� �� ��� ��� ���% ���$ ���& ���' ���) ���( ���* ���+ ���, ���- ���. ���/ ����$ ��� r��	 curReport� � � � �2 �1 �3 �4 �5 �6 �7 �8 �9 �: �; o� curVendaTrocas���Q� �� ��� ��� ���% ���$ ���& ���' ���( ���) ���* ���+ ���, ���- ���. ����$ ��]r��	 curReport� � � � �= �> �? �@ �A �B �C �D �E �F �G �H �I �J �K o� curVendaParcelasQ� ��� curVendaQ�  ��� ��R � �� ��S 	� �� �� 	����Q� ��� ���� ���� ����= ����> ����? ����@ ����A ����B ����C ����D ����E ����F ����G ����H ����I ���� �Q�J ���K ����A ���= �� UT 	 CURREPORT TIPOREGISTRO A CODIGO_FILIAL TICKET
 DATA_VENDA CODIGO_CLIENTE F CLIENTE_VAREJO VENDEDOR VENDEDOR_APELIDO OPERACAO_VENDA CODIGO_TAB_PRECO
 QTDE_TOTAL VALOR_VENDA_BRUTA QTDE_TROCA_TOTAL VALOR_TROCA DESCONTO VALOR_TIKET TICKET_IMPRESSO GERENTE_LOJA GERENTE_PERIODO VALOR_CANCELADO TOTAL_QTDE_CANCELADA PERIODO_FECHAMENTO B LANCAMENTO_CAIXA TERMINAL NUMERO_CUPOM_FISCAL COD_FORMA_PGTO DESCONTO_PGTO TOTAL_VENDA PGTOVALOR_CANCELADO NUMERO_FISCAL_TROCA CANCELADO_FISCAL C ITEM	 DESCRICAO CODIGO_BARRA QTDE PRECO_LIQUIDO DESCONTO_ITEM PRODUTO COR_PRODUTO TAMANHO QTDE_CANCELADA IPI ALIQUOTA D	 TROCAITEM TROCADESCRICAO TROCACODIGO_BARRA	 TROCAQTDE TROCAPRECO_LIQUIDO TROCADESCONTO_ITEM TROCAPRODUTO TROCACOR_PRODUTO TROCATAMANHO TROCAQTDE_CANCELADA TROCAIPI E PARCELA	 TIPO_PGTO DESC_TIPO_PGTO VALOR
 VENCIMENTO CODIGO_ADMINISTRADORA BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO MOEDA NUMERO_APROVACAO_CARTAO PARCELAS_CARTAO PARCELAVALOR_CANCELADO CHEQUE_CARTAO CURVENDA CURVENDAPAGAMENTO CURVENDAPRODUTOS CURVENDATROCAS CURVENDAPARCELAS CURCLIENTEVAREJO CODIGO_FILIAL_PGTO TERMINAL_PGTO Init,     ��1 ��� A 00 � K�3                       	      )   S                                    LORIENTATION=0
PAPERSIZE=140
DEFAULTSOURCE=15
YRESOLUTION=72
TTOPTION=3
                                                  Courier New                                                   curReport.Ticket                                              curReport.TipoRegistro                                        "Acr�scimos (+)"                                                                                                            Courier New                                                   @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) < 0                                                                                                                            curReport.TipoRegistro > 0                                    Aalltrim(curReport.codigo_filial) + " - " + alltrim(Main.p_filial)                                                                                                                           Courier New                                                   "Ticket"                                                      Courier New                                                   curReport.ticket                                                                                                            Courier New                                                   "Data"                                                        Courier New                                                   curReport.data_venda                                          "@D"                                                                                                                        Courier New                                                   Ialltrim(curReport.vendedor) + " - " + alltrim(curReport.vendedor_apelido)                                                                                                                   Courier New                                                   
"Vendedor"                                                    Courier New                                                   
"Terminal"                                                    Courier New                                                   curReport.Terminal                                                                                                          Courier New                                                   "Nota/cupom"                                                                                                                Courier New                                                   .!empty(nvl(curReport.numero_cupom_fiscal, ""))                curReport.numero_cupom_fiscal                                                                                               Courier New                                                   .!empty(nvl(curReport.numero_cupom_fiscal, ""))                	"Cliente"                                                                                                                   Courier New                                                   )!empty(nvl(curReport.codigo_cliente, ''))                     !nvl(curReport.codigo_cliente, '')                                                                                           Courier New                                                   curReport.cliente_varejo                                                                                                    Courier New                                                                                                                 curReport.TipoRegistro > 0                                    "Itens vendidos"                                                                                                            Courier New                                                   curReport.TipoRegistro == 1                                   "Itens trocados"                                                                                                            Courier New                                                   curReport.TipoRegistro == 2                                   "Pagamentos"                                                                                                                Courier New                                                   curReport.TipoRegistro == 3                                   curReport.descricao                                                                                                         Courier New                                                   curReport.TipoRegistro == 1                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 1                                   curReport.preco_liquido                                                                                                     Courier New                                                   curReport.TipoRegistro == 1                                   curReport.Qtde                                                                                                              Courier New                                                   curReport.TipoRegistro == 1                                   	"pe�a(s)"                                                                                                                   Courier New                                                   curReport.TipoRegistro == 1                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaQtde                                                                                                         Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaPreco_Liquido                                                                                                Courier New                                                   curReport.TipoRegistro == 2                                   	"pe�a(s)"                                                                                                                   Courier New                                                   curReport.TipoRegistro == 2                                   curReport.TrocaDescricao                                                                                                    Courier New                                                   curReport.TipoRegistro == 2                                   curReport.vencimento                                          "@D"                                                                                                                        Courier New                                                   curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             Courier New                                                   curReport.TipoRegistro == 3                                   curReport.desc_tipo_pgto                                                                                                    Courier New                                                   curReport.TipoRegistro == 3                                   "Total"                                                                                                                     Courier New                                                   curReport.TipoRegistro == 3                                   curReport.valor                                                                                                             Courier New                                                   curReport.TipoRegistro == 3                                   curReport.parcela                                                                                                           Courier New                                                   curReport.TipoRegistro == 3                                   "parcela(s)"                                                                                                                Courier New                                                   curReport.TipoRegistro == 3                                   
"Detalhes"                                                                                                                  Courier New                                                   "Venda bruta (+)"                                                                                                           Courier New                                                   (nvl(curReport.valor_venda_bruta, 0) != 0                      "Trocas (-)"                                                                                                                Courier New                                                   "nvl(curReport.valor_troca, 0) != 0                            "Descontos (-)"                                                                                                             Courier New                                                   @nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) > 0                                                              "Total l�quido (=)"                                                                                                         Courier New                                                   "nvl(curReport.total_venda, 0) != 0                            #nvl(curReport.valor_venda_bruta, 0)                                                                                         Courier New                                                   (nvl(curReport.valor_venda_bruta, 0) != 0                      nvl(curReport.valor_troca, 0)                                                                                               Courier New                                                   "nvl(curReport.valor_troca, 0) != 0                            <nvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0)                                                                                                                                Courier New                                                   Anvl(curReport.desconto, 0) + nvl(curReport.desconto_pgto, 0) != 0                                                             nvl(curReport.total_venda, 0)                                                                                               Courier New                                                   "nvl(curReport.total_venda, 0) != 0                            "Totais"                                                                                                                    Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               aTop = 408
Left = 498
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                            �PROCEDURE Init
#define _VENDA 0
#define _PRODUTOS 1
#define _TROCAS 2
#define _PARCELAS 3

*!* Debug

*!*	sqlexec(Main.pActiveConnection, "SELECT LOJA_VENDA.*, CONVERT(NUMERIC(14, 2), 0) AS PercentualDesconto, VENDEDOR_APELIDO FROM LOJA_VENDA INNER JOIN LOJA_VENDEDORES B ON LOJA_VENDA.VENDEDOR = B.VENDEDOR WHERE TICKET = '00000227'", "curVenda")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.* FROM CLIENTES_VAREJO A INNER JOIN LOJA_VENDA B ON A.CODIGO_CLIENTE = B.CODIGO_CLIENTE WHERE TICKET = '00000227'", "curClienteVarejo")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.*, CONVERT(VARCHAR, QTDE) + ' X ' + CONVERT(VARCHAR, PRECO_LIQUIDO) + ' = ' + " + ;
*!*		"CONVERT(VARCHAR, QTDE * PRECO_LIQUIDO) + CHAR(13) + DESC_PROD_NF AS DESCRICAO FROM LOJA_VENDA_PRODUTO A INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO WHERE TICKET = '00000227'", "curVendaProdutos")

*!*	sqlexec(Main.pActiveConnection, "SELECT A.*, CONVERT(VARCHAR, QTDE) + ' X ' + CONVERT(VARCHAR, PRECO_LIQUIDO) + ' = ' + " + ;
*!*		"CONVERT(VARCHAR, QTDE * PRECO_LIQUIDO) + CHAR(13) + DESC_PROD_NF AS DESCRICAO FROM LOJA_VENDA_TROCA A INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO WHERE TICKET = '00000227'", "curVendaTrocas")

*!*	sqlexec(Main.pActiveConnection, "SELECT * FROM LOJA_VENDA_PGTO WHERE LANCAMENTO_CAIXA = '2863003'", "curVendaPagamento")

*!*	sqlexec(Main.pActiveConnection, "SELECT LOJA_VENDA_PARCELAS.*, ADMINISTRADORA, DESC_TIPO_PGTO, ACEITA_PARCELAMENTO, CONVERT(VARCHAR(20), '') AS CPF, " + ;
*!*		"CONVERT(TEXT, '') AS RESULTADOTEF FROM LOJA_VENDA_PARCELAS INNER JOIN TIPOS_PGTO B ON LOJA_VENDA_PARCELAS.TIPO_PGTO = B.TIPO_PGTO " + ;
*!*		"LEFT JOIN ADMINISTRADORAS_CARTAO C ON C.CODIGO_ADMINISTRADORA = LOJA_VENDA_PARCELAS.CODIGO_ADMINISTRADORA  WHERE LANCAMENTO_CAIXA = '2863003'", "curVendaParcelas")

*!* End Debug

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
	(TipoRegistro, codigo_filial, ticket, data_venda, codigo_cliente, cliente_varejo, vendedor, vendedor_apelido, ;
	operacao_venda, codigo_tab_preco, qtde_total, valor_venda_bruta, qtde_troca_total, valor_troca, desconto, valor_tiket, ;
	ticket_impresso, gerente_loja, gerente_periodo, valor_cancelado, total_qtde_cancelada, periodo_fechamento, ;
	lancamento_caixa, terminal, numero_cupom_fiscal, cod_forma_pgto, desconto_pgto, total_venda, PgtoValor_cancelado, ;
	numero_fiscal_troca, cancelado_fiscal) ;
select ;
	_VENDA as TipoRegistro, a.codigo_filial, a.ticket, a.data_venda, a.codigo_cliente, nvl(c.cliente_varejo, ""), a.vendedor, ;
	a.vendedor_apelido, a.operacao_venda, a.codigo_tab_preco, a.qtde_total, a.valor_venda_bruta, a.qtde_troca_total, ;
	a.valor_troca, a.desconto, a.valor_tiket, a.ticket_impresso, a.gerente_loja, a.gerente_periodo, a.valor_cancelado, ;
	a.total_qtde_cancelada, a.periodo_fechamento, b.lancamento_caixa, b.terminal, b.numero_cupom_fiscal, b.cod_forma_pgto, ;
	b.desconto_pgto, b.total_venda, b.valor_cancelado, b.numero_fiscal_troca, b.cancelado_fiscal ;
from ;
	curVenda a inner join curVendaPagamento b on a.codigo_filial_pgto = b.codigo_filial and a.terminal_pgto = b.terminal ;
	and a.lancamento_caixa = b.lancamento_caixa ;
	left join curClienteVarejo c on c.codigo_cliente = a.codigo_cliente
	
insert into curReport ;
	(TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, preco_liquido, desconto_item, ;
	produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota) ;
select ;
	_PRODUTOS as TipoRegistro, codigo_filial, ticket, data_venda, Descricao, item, codigo_barra, qtde, desconto_item, ;
	preco_liquido, produto, cor_produto, tamanho, qtde_cancelada, ipi, aliquota ;
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
	curVendaParcelas a inner join curVenda b on a.codigo_filial = b.codigo_filial_pgto and a.terminal = b.terminal_pgto ;
	and a.lancamento_caixa = b.lancamento_caixa ;
order by ;
	vencimento, parcela


ENDPROC
                           @���    '  '                        �   %   �      �  	   �          �  U  �o� curVendaQ� � curVendaPagamentoQ� � curVendaProdutosQ�" � curVendaTrocasQ�/ � curVendaParcelasQ�; � curClienteVarejoQ� �� �Q�  ��� ���� ���� ���� ���� ���� ����	 ����
 ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� �Q� ���  ����! ����# ����$ ����% ����& ����' ����( ����) ����* ����+ ����, ����- ����. ����# �Q�0 ���$ �Q�1 ���% �Q�2 ���& �Q�3 ���' �Q�4 ���( �Q�5 ���) �Q�6 ���* �Q�7 ���+ �Q�8 ���, �Q�9 ���- �Q�: ���< ����= ����> ����? ����@ ����A ����B ����C ����D ����E ����F ����G ����H ���� �Q�I ���J ����� ����	 curReport��
r��	 curReport�  � � � � � � �	 �
 � � � � � � � � � � � � � � � � � � � � �  �! o� curVendaQ� ��� curVendaPagamentoQ�  ���R �� � ��S �� 	� �� �� 	�X�� curClienteVarejoQ�"  ��� �� ��� �Q�  ��� ���� ���� ���� ��C�� �  ����� ����	 ����
 ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ����  ����! ��� r��	 curReport�  � � � �$ �# �% �& �' �( �) �* �+ �, �- �. o� curVendaProdutos���Q�  �� ��� ��� ���$ ���# ���% ���& ���( ���' ���) ���* ���+ ���, ���- ���. ����# ��� r��	 curReport�  � � � �1 �0 �2 �3 �4 �5 �6 �7 �8 �9 �: o� curVendaTrocas���Q�  �� ��� ��� ���$ ���# ���% ���& ���' ���( ���) ���* ���+ ���, ���- ����# ��]r��	 curReport�  � � � �< �= �> �? �@ �A �B �C �D �E �F �G �H �I �J o� curVendaParcelasQ� ��� curVendaQ�  ��� ��R � �� ��S 	� �� �� 	����Q�  ��� ���� ���� ����< ����= ����> ����? ����@ ����A ����B ����C ����D ����E ����F ����G ����H ���� �Q�I ���J ����@ ���< �� UT  TIPOREGISTRO A CODIGO_FILIAL TICKET
 DATA_VENDA CODIGO_CLIENTE F CLIENTE_VAREJO VENDEDOR VENDEDOR_APELIDO OPERACAO_VENDA CODIGO_TAB_PRECO
 QTDE_TOTAL VALOR_VENDA_BRUTA QTDE_TROCA_TOTAL VALOR_TROCA DESCONTO VALOR_TIKET TICKET_IMPRESSO GERENTE_LOJA GERENTE_PERIODO VALOR_CANCELADO TOTAL_QTDE_CANCELADA PERIODO_FECHAMENTO B LANCAMENTO_CAIXA TERMINAL NUMERO_CUPOM_FISCAL COD_FORMA_PGTO DESCONTO_PGTO TOTAL_VENDA PGTOVALOR_CANCELADO NUMERO_FISCAL_TROCA CANCELADO_FISCAL C ITEM	 DESCRICAO CODIGO_BARRA QTDE PRECO_LIQUIDO DESCONTO_ITEM PRODUTO COR_PRODUTO TAMANHO QTDE_CANCELADA IPI ALIQUOTA D	 TROCAITEM TROCADESCRICAO TROCACODIGO_BARRA	 TROCAQTDE TROCAPRECO_LIQUIDO TROCADESCONTO_ITEM TROCAPRODUTO TROCACOR_PRODUTO TROCATAMANHO TROCAQTDE_CANCELADA TROCAIPI E PARCELA	 TIPO_PGTO DESC_TIPO_PGTO VALOR
 VENCIMENTO CODIGO_ADMINISTRADORA BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO MOEDA NUMERO_APROVACAO_CARTAO PARCELAS_CARTAO PARCELAVALOR_CANCELADO CHEQUE_CARTAO CURVENDA CURVENDAPAGAMENTO CURVENDAPRODUTOS CURVENDATROCAS CURVENDAPARCELAS CURCLIENTEVAREJO	 CURREPORT CODIGO_FILIAL_PGTO TERMINAL_PGTO Init,     ��1 �0 � K�3                       �      )   '                                                                          