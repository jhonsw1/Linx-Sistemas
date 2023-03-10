  ?   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ?DRIVER=winspool
DEVICE=Enviar para o OneNote 2013
OUTPUT=nul:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
                         D  .  winspool  Enviar para o OneNote 2013  nul:                                                                           ?Enviar para o OneNote 2013      ? @/   	 ?4d   X  X  A4                                                            ????GIS4            DINU" ? $ ???                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ?   SMTJ     ? { 3 E E 3 9 1 1 4 - 3 0 B 4 - 4 5 a 4 - A 1 0 9 - 1 9 D 4 A 4 0 F C C 2 2 }   RESDLL UniresDLL PaperSize LETTER Orientation PORTRAIT Resolution DPI600 ColorMode 24bpp                     V4DM                                                     Courier New                                                   main.LocalRazao                                               Courier New                                                   )"DOCUMENTO AUXILIAR DE VENDA - OR?AMENTO"                     Courier New                                                   :"N?O ? DOCUMENTO FISCAL - N?O ? V?LIDO COMO RECIBO E COMO"                                                                    Courier New                                                   "N? do Documento:"                                            Courier New                                                   "curLojaPedido.sequencial_pre_venda                            Courier New                                                   $"N? do Documento Fiscal: __________"                          Courier New                                                   )"? vedada a autentica??o desse documento"                     Courier New                                                   curReport.DAVText                                             Courier New                                                   1"GARANTIA DE MERCADORIA - N?O COMPROVA PAGAMENTO"             Courier New                                                   +"Identifica??o do Estabelecimento Emitente"                   Courier New                                                   "Denomina??o:"                                                Courier New                                                   "CNPJ:"                                                       Courier New                                                   main.LocalCNPJ                                                "@R 99.999.999/9999-99"                                       Courier New                                                   "Identifica??o do Destinat?rio"                               Courier New                                                   "Nome:"                                                       Courier New                                                   xIIF(EMPTY(nvl(curClienteVarejo.cliente_varejo, "")),CurlojaPedido.identificacao_cliente,curClienteVarejo.cliente_varejo)      Courier New                                                   "CNPJ/CPF:"                                                   Courier New                                                   `IIF(EMPTY(nvl(curClienteVarejo.cpf_cgc, "")),CurlojaPedido.cpf_cgc_ecf,curClienteVarejo.cpf_cgc)                              "@R 999.999.999-99"                                           Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                              ?PROCEDURE Init
*!* 25/06/2015 - Gerson Prado - TP8279508 - #2# Programa??o do LinxPOS para o PAF-ECF 2015 - Impress?o do c?digo do produto no documento DAV
*- V?vian Domingues - Data 12/11/2014 - TP6649049 - #1# - Altera??o para incluir o desconto / acr?scimo referente a forma de pagamento.

local strText as string, intColumns as Integer, strProduct as String

IF USED("curReport") &&#1#
	USE IN curReport &&#1#
ENDIF &&#1#

intColumns = 40

create cursor curReport (DAVText M)
append blank

strText = padc("PRODUTOS", intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n"

select curLojaPedidoProduto
scan
	nPrice = preco_liquido
	strDescription = alltrim(desc_prod_nf)
	strProduct = main.general.Translate("Ref.") + ": " + alltrim(iif(main.p_mostra_no_ticket == 1, codigo_barra, alltrim(produto) + " - " + alltrim(cor_produto) + " - " + transform(tamanho))) && #2#
	*!* Roberto Beda (28/02/2011) - Indica que o item est? cancelado
	if curLojaPedidoProduto.cancelado
		strProduct = strProduct + " (cancelado)" && #2#
	endif
	
	nQuantity = qtde
	nTotal = nPrice * nQuantity

	strLine = padr(transform(nQuantity), 7) + "x" + padr(transform(nPrice, "999,999.99"), 10)
	strLine = strLine + padl(transform(nTotal, "99,999,999.99"), intColumns - len(strLine) - 1)

	strText = strText + strLine + "\n" + strProduct + "\n" + strDescription + "\n" && #2#
endscan
strText = strText + replicate("-", intColumns) + "\n"

strLine = "SOMA: " + transform(curLojaPedido.qtde_total) + " "
strLine = strLine + padl(transform(curLojaPedido.valor_total, "99,999,999.99"), intColumns - len(strLine) - 1, " ")

strText = strText + strLine + "\n"

strText = strText + "\n" + ;
	padc("SUGESTAO DE PAGAMENTO", intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n" + ;
	padc(padr("TIPO", 15) + " " + padc("VENCTO", 10) + " " + padl("VALOR", 12), intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n"

select curLojaPedidoPgto
 
*-V?vian - In?cio
IF USED("curDiscountPgto") 
	select curDiscountPgto
	GO top
	SCAN
		IF curDiscountPgto.Tipo = "V"
			nValor = curLojaPedidoPgto.valor + (curDiscountPgto.Desconto) 
		ENDIF
		
		IF curDiscountPgto.Tipo = "I" 
			nValor = curLojaPedidoPgto.valor
		ENDIF
		
		IF curDiscountPgto.Tipo = "T" 
			select curPedidoItem
			GO TOP
			
			nPreco = 0
			SCAN
				nPreco = nPreco + curPedidoItem.PrecoBruto
			ENDSCAN
			
			nValor = nPreco
		ENDIF
	ENDSCAN
ELSE
	nValor = curLojaPedidoPgto.valor
ENDIF
*-V?vian - Fim
select curLojaPedidoPgto &&#1#

scan
	*-strLine = padc(padr(desc_tipo_pgto, 15) + " " + dtoc(vencimento) + " " + transform(valor, "9,999,999.99"), intColumns - 1) &&#1#
	strLine = padc(padr(desc_tipo_pgto, 15) + " " + dtoc(vencimento) + " " + transform(nValor, "9,999,999.99"), intColumns - 1) &&#1#
	strText = strText + strLine + "\n"
endscan
strText = strText + replicate("-", intColumns) + "\n"

strText = strText + "\n"
	
*- &&#1# - In?cio
nDesconto = curLojaPedido.desconto

if USED("curDiscountPgto")
	select curDiscountPgto
	GO top
	
	nValida = 0
	nDiscountPgto = curDiscountPgto.Desconto
	
	if curDiscountPgto.Tipo = "V"
		nValorLiquido = curLojaPedido.valor_liquido + (nDiscountPgto)
	ENDIF
	
	IF curDiscountPgto.Tipo = "I"
		nValorLiquido = curLojaPedido.valor_liquido
	ENDIF
	
	IF curDiscountPgto.Tipo = "T"
		nValorLiquido = nValor + (nDiscountPgto) + (nDesconto *(-1))
	endif
	
	*-Soma os Desconto 
	IF nDiscountPgto < 0 AND nDesconto > 0
		
		nDesconto = nDesconto *(-1)
		nDesconto = nDesconto + curDiscountPgto.Desconto
		nValida = nDesconto
	ENDIF
	
	*- Soma os Acrescimo
	IF nDiscountPgto > 0 AND nDesconto < 0
		
		nDesconto = nDesconto *(-1)
		nDesconto = nDesconto + curDiscountPgto.Desconto
		nValida = nDesconto
	ENDIF


	*-Subtra??o entre Desconto e Acrescimo
	IF nValida = 0
		
		nDesconto = nDesconto *(-1)
		nDiscountPgto = nDiscountPgto *(-1)
		
		IF nDesconto > nDiscountPgto
			nDesconto = nDesconto - nDiscountPgto
			
		ELSE
			nDesconto = nDiscountPgto - nDesconto
			nDesconto = nDesconto *(-1)
			
		ENDIF
		
	ENDIF

ELSE
	nValorLiquido = curLojaPedido.valor_liquido
	nDesconto = nDesconto *(-1)

endif
*- &&#1# - Fim 

*-if curLojaPedido.desconto != 0
if nDesconto != 0
	*-strText = strText + padc("DESCONTO ......: " + transform(curLojaPedido.desconto, "99,999,999.99"), intColumns - 1) + "\n" &&#1#
	strText = strText + padc(IIF(nDesconto < 0,"DESCONTO ......: " + transform(nDesconto, "99,999,999.99"), "ACRESCIMO .....: " + TRANSFORM(nDesconto, "99,999,999.99")), intColumns - 1) + "\n" &&#1#
endif

*-strText = strText + padc("VALOR A PAGAR .: " + transform(curLojaPedido.valor_liquido, "99,999,999.99"), intColumns - 1) + "\n" &&#1#
strText = strText + padc("VALOR A PAGAR .: " + transform(nValorLiquido, "99,999,999.99"), intColumns - 1) + "\n" &&#1#


select curReport
replace DAVText with main.general.FormatText(strText) 
go TOP &&#1#


*- In?cio - #1#
if USED("curDiscountPgto")
	USE IN curDiscountPgto
ENDIF
*- Fim - #1#

ENDPROC
          ????    ?  ?                        ?   %   ?
      s  m   ?
          ?  U  \. ??  Q? STRING? Q? INTEGER? Q? STRING? %?C?	 curReport???N ? Q? ? ? T? ??(?? h??	 curReport? ? M? ?4 T?  ?C? PRODUTOS? ??? \nC? -? Q? \n?? F? ? ~?? T? ?? ?? T? ?C?	 ???X T? ?C? Ref.?
 ? ? ? : CC?
 ? ?? ? ? C? ??  - C? ??  - C? _6??? %?? ? ??b? T? ?? ?  (cancelado)?? ? T? ?? ?? T? ?? ? ??1 T? ?CC? _??? xCC? ?
 999,999.99_?
???2 T? ?? CC? ? 99,999,999.99_? C? >????+ T?  ??  ? ? \n? ? \n? ? \n?? ? T?  ??  C? -? Q? \n??! T? ?? SOMA: C? ? _?  ??9 T? ?? CC? ? ? 99,999,999.99_? C? >??  ??? T?  ??  ? ? \n??? T?  ??  ? \nC? SUGESTAO DE PAGAMENTO? ??? \nC? -? Q? \nCC? TIPO???  C? VENCTO?
??  C? VALOR??? ??? \nC? -? Q? \n?? F? ? %?C? curDiscountPgto???8? F? ? #)? ~?4? %?? ? ? V???? T? ?? ? ? ? ?? ? %?? ? ? I???? T? ?? ? ?? ? %?? ? ? T??0? F?  ? #)? T?! ?? ?? ~?? T?! ??! ?  ?" ?? ? T? ??! ?? ? ? ?P? T? ?? ? ?? ? F? ? ~???@ T? ?CC?# ???  C?$ *?  C? ? 9,999,999.99_? ???? T?  ??  ? ? \n?? ? T?  ??  C? -? Q? \n?? T?  ??  ? \n?? T?% ?? ? ?? %?C? curDiscountPgto???? F? ? #)? T?& ?? ?? T?' ?? ? ?? %?? ? ? V??o? T?( ?? ?) ?' ?? ? %?? ? ? I???? T?( ?? ?) ?? ? %?? ? ? T???? T?( ?? ?' ?% ????? ? %??' ? ? ?% ? 	?? ? T?% ??% ????? T?% ??% ? ? ?? T?& ??% ?? ? %??' ? ? ?% ? 	??s? T?% ??% ????? T?% ??% ? ? ?? T?& ??% ?? ? %??& ? ???? T?% ??% ????? T?' ??' ????? %??% ?' ???? T?% ??% ?' ?? ??? T?% ??' ?% ?? T?% ??% ????? ? ? ?+? T?( ?? ?) ?? T?% ??% ????? ? %??% ? ????? T?  ??  CC?% ? ?- ? DESCONTO ......: C?% ? 99,999,999.99_?* ? ACRESCIMO .....: C?% ? 99,999,999.99_6? ??? \n?? ?G T?  ??  C? VALOR A PAGAR .: C?( ? 99,999,999.99_? ??? \n?? F? ? >? ??C ?  ?
 ? ?* ?? #)? %?C? curDiscountPgto???U? Q? ? ? U+  STRTEXT
 INTCOLUMNS
 STRPRODUCT	 CURREPORT DAVTEXT CURLOJAPEDIDOPRODUTO NPRICE PRECO_LIQUIDO STRDESCRIPTION DESC_PROD_NF MAIN GENERAL	 TRANSLATE P_MOSTRA_NO_TICKET CODIGO_BARRA PRODUTO COR_PRODUTO TAMANHO	 CANCELADO	 NQUANTITY QTDE NTOTAL STRLINE CURLOJAPEDIDO
 QTDE_TOTAL VALOR_TOTAL CURLOJAPEDIDOPGTO CURDISCOUNTPGTO TIPO NVALOR VALOR DESCONTO CURPEDIDOITEM NPRECO
 PRECOBRUTO DESC_TIPO_PGTO
 VENCIMENTO	 NDESCONTO NVALIDA NDISCOUNTPGTO NVALORLIQUIDO VALOR_LIQUIDO
 FORMATTEXT Init,     ??1 ??? A ? ?Q Cr ? ? ? ??A ? !?A ??r?	r ?q Q ? Q?A RA Rq Q ? ? AA ? A A ? A r ? qA ?2?q Q ? RQA RA R?A ?"A? A ?"A? A "!? !B B ? !B A ss ?Q ?? A 3                       ?      )   ?                                                           ?DRIVER=winspool
DEVICE=Enviar para o OneNote 2013
OUTPUT=nul:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
                         D  .  winspool  Enviar para o OneNote 2013  nul:                                                                           ?Enviar para o OneNote 2013      ? @/   	 ?4d   X  X  A4                                                            ????GIS4            DINU" ? $ ???                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ?   SMTJ     ? { 3 E E 3 9 1 1 4 - 3 0 B 4 - 4 5 a 4 - A 1 0 9 - 1 9 D 4 A 4 0 F C C 2 2 }   RESDLL UniresDLL PaperSize LETTER Orientation PORTRAIT Resolution DPI600 ColorMode 24bpp                     V4DM                                                     Courier New                                                   main.LocalRazao                                               Courier New                                                   )"DOCUMENTO AUXILIAR DE VENDA - OR?AMENTO"                     Courier New                                                   :"N?O ? DOCUMENTO FISCAL - N?O ? V?LIDO COMO RECIBO E COMO"                                                                    Courier New                                                   "N? do Documento:"                                            Courier New                                                   "curLojaPedido.sequencial_pre_venda                            Courier New                                                   $"N? do Documento Fiscal: __________"                          Courier New                                                   )"? vedada a autentica??o desse documento"                     Courier New                                                   curReport.DAVText                                             Courier New                                                   1"GARANTIA DE MERCADORIA - N?O COMPROVA PAGAMENTO"             Courier New                                                   +"Identifica??o do Estabelecimento Emitente"                   Courier New                                                   "Denomina??o:"                                                Courier New                                                   "CNPJ:"                                                       Courier New                                                   main.LocalCNPJ                                                "@R 99.999.999/9999-99"                                       Courier New                                                   "Identifica??o do Destinat?rio"                               Courier New                                                   "Nome:"                                                       Courier New                                                   xIIF(EMPTY(nvl(curClienteVarejo.cliente_varejo, "")),CurlojaPedido.identificacao_cliente,curClienteVarejo.cliente_varejo)      Courier New                                                   "CNPJ/CPF:"                                                   Courier New                                                   `IIF(EMPTY(nvl(curClienteVarejo.cpf_cgc, "")),CurlojaPedido.cpf_cgc_ecf,curClienteVarejo.cpf_cgc)                              "@R 999.999.999-99"                                           Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                              ?PROCEDURE Init
*!* 25/06/2015 - Gerson Prado - TP8279508 - #2# Programa??o do LinxPOS para o PAF-ECF 2015 - Impress?o do c?digo do produto no documento DAV
*- V?vian Domingues - Data 12/11/2014 - TP6649049 - #1# - Altera??o para incluir o desconto / acr?scimo referente a forma de pagamento.

local strText as string, intColumns as Integer, strProduct as String

IF USED("curReport") &&#1#
	USE IN curReport &&#1#
ENDIF &&#1#

intColumns = 40

create cursor curReport (DAVText M)
append blank

strText = padc("PRODUTOS", intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n"

select curLojaPedidoProduto
scan
	nPrice = preco_liquido
	strDescription = alltrim(desc_prod_nf)
	strProduct = main.general.Translate("Ref.") + ": " + alltrim(iif(main.p_mostra_no_ticket == 1, codigo_barra, alltrim(produto) + " - " + alltrim(cor_produto) + " - " + transform(tamanho))) && #2#
	*!* Roberto Beda (28/02/2011) - Indica que o item est? cancelado
	if curLojaPedidoProduto.cancelado
		strProduct = strProduct + " (cancelado)" && #2#
	endif
	
	nQuantity = qtde
	nTotal = nPrice * nQuantity

	strLine = padr(transform(nQuantity), 7) + "x" + padr(transform(nPrice, "999,999.99"), 10)
	strLine = strLine + padl(transform(nTotal, "99,999,999.99"), intColumns - len(strLine) - 1)

	strText = strText + strLine + "\n" + strProduct + "\n" + strDescription + "\n" && #2#
endscan
strText = strText + replicate("-", intColumns) + "\n"

strLine = "SOMA: " + transform(curLojaPedido.qtde_total) + " "
strLine = strLine + padl(transform(curLojaPedido.valor_total, "99,999,999.99"), intColumns - len(strLine) - 1, " ")

strText = strText + strLine + "\n"

strText = strText + "\n" + ;
	padc("SUGESTAO DE PAGAMENTO", intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n" + ;
	padc(padr("TIPO", 15) + " " + padc("VENCTO", 10) + " " + padl("VALOR", 12), intColumns - 1) + "\n" + ;
	replicate("-", intColumns) + "\n"

select curLojaPedidoPgto
 
*-V?vian - In?cio
IF USED("curDiscountPgto") 
	select curDiscountPgto
	GO top
	SCAN
		IF curDiscountPgto.Tipo = "V"
			nValor = curLojaPedidoPgto.valor + (curDiscountPgto.Desconto) 
		ENDIF
		
		IF curDiscountPgto.Tipo = "I" 
			nValor = curLojaPedidoPgto.valor
		ENDIF
		
		IF curDiscountPgto.Tipo = "T" 
			select curPedidoItem
			GO TOP
			
			nPreco = 0
			SCAN
				nPreco = nPreco + curPedidoItem.PrecoBruto
			ENDSCAN
			
			nValor = nPreco
		ENDIF
	ENDSCAN
ELSE
	nValor = curLojaPedidoPgto.valor
ENDIF
*-V?vian - Fim
select curLojaPedidoPgto &&#1#

scan
	*-strLine = padc(padr(desc_tipo_pgto, 15) + " " + dtoc(vencimento) + " " + transform(valor, "9,999,999.99"), intColumns - 1) &&#1#
	strLine = padc(padr(desc_tipo_pgto, 15) + " " + dtoc(vencimento) + " " + transform(nValor, "9,999,999.99"), intColumns - 1) &&#1#
	strText = strText + strLine + "\n"
endscan
strText = strText + replicate("-", intColumns) + "\n"

strText = strText + "\n"
	
*- &&#1# - In?cio
nDesconto = curLojaPedido.desconto

if USED("curDiscountPgto")
	select curDiscountPgto
	GO top
	
	nValida = 0
	nDiscountPgto = curDiscountPgto.Desconto
	
	if curDiscountPgto.Tipo = "V"
		nValorLiquido = curLojaPedido.valor_liquido + (nDiscountPgto)
	ENDIF
	
	IF curDiscountPgto.Tipo = "I"
		nValorLiquido = curLojaPedido.valor_liquido
	ENDIF
	
	IF curDiscountPgto.Tipo = "T"
		nValorLiquido = nValor + (nDiscountPgto) + (nDesconto *(-1))
	endif
	
	*-Soma os Desconto 
	IF nDiscountPgto < 0 AND nDesconto > 0
		
		nDesconto = nDesconto *(-1)
		nDesconto = nDesconto + curDiscountPgto.Desconto
		nValida = nDesconto
	ENDIF
	
	*- Soma os Acrescimo
	IF nDiscountPgto > 0 AND nDesconto < 0
		
		nDesconto = nDesconto *(-1)
		nDesconto = nDesconto + curDiscountPgto.Desconto
		nValida = nDesconto
	ENDIF


	*-Subtra??o entre Desconto e Acrescimo
	IF nValida = 0
		
		nDesconto = nDesconto *(-1)
		nDiscountPgto = nDiscountPgto *(-1)
		
		IF nDesconto > nDiscountPgto
			nDesconto = nDesconto - nDiscountPgto
			
		ELSE
			nDesconto = nDiscountPgto - nDesconto
			nDesconto = nDesconto *(-1)
			
		ENDIF
		
	ENDIF

ELSE
	nValorLiquido = curLojaPedido.valor_liquido
	nDesconto = nDesconto *(-1)

endif
*- &&#1# - Fim 

*-if curLojaPedido.desconto != 0
if nDesconto != 0
	*-strText = strText + padc("DESCONTO ......: " + transform(curLojaPedido.desconto, "99,999,999.99"), intColumns - 1) + "\n" &&#1#
	strText = strText + padc(IIF(nDesconto < 0,"DESCONTO ......: " + transform(nDesconto, "99,999,999.99"), "ACRESCIMO .....: " + TRANSFORM(nDesconto, "99,999,999.99")), intColumns - 1) + "\n" &&#1#
endif

*-strText = strText + padc("VALOR A PAGAR .: " + transform(curLojaPedido.valor_liquido, "99,999,999.99"), intColumns - 1) + "\n" &&#1#
strText = strText + padc("VALOR A PAGAR .: " + transform(nValorLiquido, "99,999,999.99"), intColumns - 1) + "\n" &&#1#


select curReport
replace DAVText with main.general.FormatText(strText) 
go TOP &&#1#


*- In?cio - #1#
if USED("curDiscountPgto")
	USE IN curDiscountPgto
ENDIF
*- Fim - #1#

ENDPROC
          ????    ?  ?                        ?   %   ?
      s  m   ?
          ?  U  \. ??  Q? STRING? Q? INTEGER? Q? STRING? %?C?	 curReport???N ? Q? ? ? T? ??(?? h??	 curReport? ? M? ?4 T?  ?C? PRODUTOS? ??? \nC? -? Q? \n?? F? ? ~?? T? ?? ?? T? ?C?	 ???X T? ?C? Ref.?
 ? ? ? : CC?
 ? ?? ? ? C? ??  - C? ??  - C? _6??? %?? ? ??b? T? ?? ?  (cancelado)?? ? T? ?? ?? T? ?? ? ??1 T? ?CC? _??? xCC? ?
 999,999.99_?
???2 T? ?? CC? ? 99,999,999.99_? C? >????+ T?  ??  ? ? \n? ? \n? ? \n?? ? T?  ??  C? -? Q? \n??! T? ?? SOMA: C? ? _?  ??9 T? ?? CC? ? ? 99,999,999.99_? C? >??  ??? T?  ??  ? ? \n??? T?  ??  ? \nC? SUGESTAO DE PAGAMENTO? ??? \nC? -? Q? \nCC? TIPO???  C? VENCTO?
??  C? VALOR??? ??? \nC? -? Q? \n?? F? ? %?C? curDiscountPgto???8? F? ? #)? ~?4? %?? ? ? V???? T? ?? ? ? ? ?? ? %?? ? ? I???? T? ?? ? ?? ? %?? ? ? T??0? F?  ? #)? T?! ?? ?? ~?? T?! ??! ?  ?" ?? ? T? ??! ?? ? ? ?P? T? ?? ? ?? ? F? ? ~???@ T? ?CC?# ???  C?$ *?  C? ? 9,999,999.99_? ???? T?  ??  ? ? \n?? ? T?  ??  C? -? Q? \n?? T?  ??  ? \n?? T?% ?? ? ?? %?C? curDiscountPgto???? F? ? #)? T?& ?? ?? T?' ?? ? ?? %?? ? ? V??o? T?( ?? ?) ?' ?? ? %?? ? ? I???? T?( ?? ?) ?? ? %?? ? ? T???? T?( ?? ?' ?% ????? ? %??' ? ? ?% ? 	?? ? T?% ??% ????? T?% ??% ? ? ?? T?& ??% ?? ? %??' ? ? ?% ? 	??s? T?% ??% ????? T?% ??% ? ? ?? T?& ??% ?? ? %??& ? ???? T?% ??% ????? T?' ??' ????? %??% ?' ???? T?% ??% ?' ?? ??? T?% ??' ?% ?? T?% ??% ????? ? ? ?+? T?( ?? ?) ?? T?% ??% ????? ? %??% ? ????? T?  ??  CC?% ? ?- ? DESCONTO ......: C?% ? 99,999,999.99_?* ? ACRESCIMO .....: C?% ? 99,999,999.99_6? ??? \n?? ?G T?  ??  C? VALOR A PAGAR .: C?( ? 99,999,999.99_? ??? \n?? F? ? >? ??C ?  ?
 ? ?* ?? #)? %?C? curDiscountPgto???U? Q? ? ? U+  STRTEXT
 INTCOLUMNS
 STRPRODUCT	 CURREPORT DAVTEXT CURLOJAPEDIDOPRODUTO NPRICE PRECO_LIQUIDO STRDESCRIPTION DESC_PROD_NF MAIN GENERAL	 TRANSLATE P_MOSTRA_NO_TICKET CODIGO_BARRA PRODUTO COR_PRODUTO TAMANHO	 CANCELADO	 NQUANTITY QTDE NTOTAL STRLINE CURLOJAPEDIDO
 QTDE_TOTAL VALOR_TOTAL CURLOJAPEDIDOPGTO CURDISCOUNTPGTO TIPO NVALOR VALOR DESCONTO CURPEDIDOITEM NPRECO
 PRECOBRUTO DESC_TIPO_PGTO
 VENCIMENTO	 NDESCONTO NVALIDA NDISCOUNTPGTO NVALORLIQUIDO VALOR_LIQUIDO
 FORMATTEXT Init,     ??1 ??? A ? ?Q Cr ? ? ? ??A ? !?A ??r?	r ?q Q ? Q?A RA Rq Q ? ? AA ? A A ? A r ? qA ?2?q Q ? RQA RA R?A ?"A? A ?"A? A "!? !B B ? !B A ss ?Q ?? A 3                       ?      )   ?                                                     