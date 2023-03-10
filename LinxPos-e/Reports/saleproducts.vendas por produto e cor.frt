  m   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=2
                         Courier New                                                   curVendaProduto.grupo_produto                                  curVendaProduto.subgrupo_produto                              curVendaProduto.Produto                                       	"Produto"                                                     Arial                                                         Callt(curVendaProduto.produto) + ' - '+ curVendaProduto.desc_prod_nf                                                           Arial                                                         (wLogo)                                                       !empty(wLogo) and file(wLogo)                                 &'Consulta de Vendas Por Produto e Cor'                        Arial                                                         main.p_filial                                                 Arial                                                         'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ''LinxPOS '+ alltrim(main.p_versao_loja)                       Arial                                                         "Qtde"                                                        Arial                                                         curVendaProduto.qtde                                          "@Z"                                                          Arial                                                         "Grupo"                                                       Arial                                                         curVendaProduto.grupo_produto                                 Arial                                                         
"Subgrupo"                                                    Arial                                                          curVendaProduto.subgrupo_produto                              Arial                                                         "Total do subgrupo"                                           Arial                                                         curVendaProduto.qtde                                          Arial                                                         "Total do grupo"                                              Arial                                                         curVendaProduto.qtde                                          Arial                                                         _DESC_ESTOQUE                                                 Arial                                                         	"Estoque"                                                     Arial                                                         Kallt(curVendaProduto.cor_produto) + ' - '+ curVendaProduto.DESC_COR_PRODUTO                                                   Arial                                                         curVendaProduto.tamanho                                       "@Z"                                                          Arial                                                         "Cor"                                                         Arial                                                         "Tam"                                                         "@I"                                                          Arial                                                         SaleProducts.DataInicial                                      Arial                                                         SaleProducts.DataFinal                                        Arial                                                         "at?"                                                         Arial                                                         "Per?odo de"                                                  Arial                                                         curVendaProduto.qtde                                          "@Z"                                                          Arial                                                         "Total geral"                                                 Arial                                                         wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                      Courier New                                                   Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                             ?PROCEDURE Destroy
select CurReport
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iRep

select curVendaProduto 
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd

ENDPROC
PROCEDURE Init
public _DESC_ESTOQUE as String
Local strFilter as string

if used("CurReport")
	use in CurReport
ENDIF

if used("curVendaProduto")
	use in curVendaProduto
ENDIF


do case
case SaleProducts.Stockinfo == 1
	_DESC_ESTOQUE = "Estoque negativo"
case SaleProducts.Stockinfo == 2
	_DESC_ESTOQUE = "Sem estoque"
case SaleProducts.Stockinfo == 3
	_DESC_ESTOQUE = "Com estoque"
case SaleProducts.Stockinfo == 4
	_DESC_ESTOQUE = "Todos os produtos"
ENDCASE

strDataInicial = iif(SaleProducts.chkSearchToday.value, dtoc(main.date), iif(empty(SaleProducts.txtStartDate.value), "", dtoc(SaleProducts.txtStartDate.value)))
strDataFinal = iif(SaleProducts.chkSearchToday.value, dtoc(main.date), iif(empty(SaleProducts.txtFinishDate.value), "", dtoc(SaleProducts.txtFinishDate.value)))
strHoraInicial = iif(empty(strtran(strtran(SaleProducts.txtStartHour.value, ":", ""), " ", "")) or !SaleProducts.chkHour.value, "", strtran(strtran(SaleProducts.txtStartHour.value, ":", ""), " ", ""))
strHoraInicial = iif(empty(strHoraInicial), "", stuff(stuff(strHoraInicial, 3, 0, ":"), 6, 0, ":"))
strHoraFinal = iif(empty(strtran(strtran(SaleProducts.txtFinishHour.value, ":", ""), " ", "")) or !SaleProducts.chkHour.value, "", strtran(strtran(SaleProducts.txtFinishHour.value, ":", ""), " ", ""))
strHoraFinal = iif(empty(strHoraFinal), "", stuff(stuff(strHoraFinal, 3, 0, ":"), 6, 0, ":"))


strFilter = ""
if !empty(strDataInicial) or !empty(strDataFinal) or !empty(strHoraInicial) or !empty(strHoraFinal)
	
	do case
	
		case (!empty(strDataInicial) or !empty(strDataFinal)) and empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctod(strDataInicial)
			SaleProducts.DataFinal = ctod(strDataFinal)
			
			do case
			
				case !empty(SaleProducts.DataInicial) and !empty(SaleProducts.DataFinal)
					if SaleProducts.DataInicial == SaleProducts.DataFinal
						strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) = ?SaleProducts.DataInicial"
					else
						strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal"
					endif
				
				case !empty(SaleProducts.DataInicial) and empty(SaleProducts.DataFinal)
					strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial"
				
				case empty(SaleProducts.DataInicial) and !empty(SaleProducts.DataFinal)
					strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal"
			
			endcase
		
		case !empty(strDataInicial) and !empty(strDataFinal) and !empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			
			if SaleProducts.DataInicial == SaleProducts.DataFinal
				strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO = ?SaleProducts.DataInicial'
			else
				strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
			endif
		
		case !empty(strDataInicial) and !empty(strDataFinal) and !empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			thisSaleProductsform.DataFinal = ctod(strDataFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal'
		
		case !empty(strDataInicial) and !empty(strDataFinal) and empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataInicial = ctod(strDataInicial)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
		
		case !empty(strDataInicial) and empty(strDataFinal) and !empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial'
		
		case empty(strDataInicial) and !empty(strDataFinal) and empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
		
	endcase
endif

strFilter = strFilter + iif(empty(SaleProducts.group), "", iif(empty(strFilter), "", " AND ") + "B.GRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Group)")
strFilter = strFilter + iif(empty(SaleProducts.SubGroup), "", iif(empty(strFilter), "", " AND ") + "B.SUBGRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Subgroup)")
strFilter = strFilter + iif(empty(SaleProducts.product), "", iif(empty(strFilter), "", " AND ") + "A.PRODUTO LIKE RTRIM(?SaleProducts.Product)")
strFilter = strFilter + iif(empty(SaleProducts.ProductColor), "", iif(empty(strFilter), "", " AND ") + "A.COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColor)")
stFilter = strFilter + iif(empty(SaleProducts.ProductDescription), "", iif(empty(strFilter), "", " AND ") + "B.DESC_PROD_NF LIKE RTRIM(?SaleProducts.ProductDescription)")
strFilter = strFilter + iif(empty(SaleProducts.ProductColorDescription), "", iif(empty(strFilter), "", " AND ") + "C.DESC_COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColorDescription)")

do case
	case SaleProducts.Stockinfo == 1
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE < 0"
	case SaleProducts.Stockinfo == 2
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE = 0"
	case SaleProducts.Stockinfo == 3
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE > 0"
endcase

strSelect	= "SELECT A.PRODUTO, B.DESC_PROD_NF, A.COR_PRODUTO,	C.DESC_COR_PRODUTO,	B.GRUPO_PRODUTO, B.SUBGRUPO_PRODUTO, "+;
			  " PB.GRADE AS TAMANHO, A.QTDE AS QTDE, (A.QTDE * A.PRECO_LIQUIDO) AS VALOR FROM LOJA_VENDA_PRODUTO A "+;
			" INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO "+;
			" INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO "+;
			" INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE "+;
			" INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA "+;
			" INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL "+;
			" INNER JOIN ESTOQUE_PRODUTOS G ON F.FILIAL = G.FILIAL AND A.PRODUTO = G.PRODUTO AND A.COR_PRODUTO = G.COR_PRODUTO "+;
			" INNER JOIN PRODUTOS_BARRA PB ON A.CODIGO_BARRA = PB.CODIGO_BARRA "+;
			" WHERE A.CODIGO_FILIAL = ?main.p_codigo_filial and	A.QTDE != 0 and  "+ strFilter + " "

if !SQLSelect(strSelect, "CurReport", "Erro pesquisando tipos de pagamento.")
	return .f.
ENDIF

select CurReport
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iRep
go top

select ;
	PRODUTO, DESC_PROD_NF, COR_PRODUTO,	DESC_COR_PRODUTO, GRUPO_PRODUTO, SUBGRUPO_PRODUTO, ;
	TAMANHO, sum(QTDE) AS QTDE, sum(VALOR) AS VALOR ;
from CurReport ;
Group by PRODUTO, DESC_PROD_NF, COR_PRODUTO, DESC_COR_PRODUTO, GRUPO_PRODUTO, SUBGRUPO_PRODUTO,TAMANHO ;
Into Cursor curVendaProduto Readwrite


select curVendaProduto 
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd
go top


ENDPROC
                      ????    ?  ?                        ??   %   a      D  b   ?          ?  U  E  F?  ? & ?? ? ? ? ??? ? F? ? & ?? ? ? ? ??? ? U 	 CURREPORT GRUPO_PRODUTO SUBGRUPO_PRODUTO PRODUTO COR_PRODUTO IREP CURVENDAPRODUTO IPRODz 7?  Q? STRING? ?? Q? STRING? %?C?	 CurReport???B ? Q? ? ? %?C? curVendaProduto???l ? Q? ? ? H?} ?8? ?? ? ???? ? T?  ?? Estoque negativo?? ?? ? ???? ? T?  ?? Sem estoque?? ?? ? ???? T?  ?? Com estoque?? ?? ? ???8? T?  ?? Todos os produtos?? ?D T? ?C? ? ? ? C?	 ?
 *?! CC? ? ? ?? ?  ? C? ? ? *66??D T? ?C? ? ? ? C?	 ?
 *?! CC? ? ? ?? ?  ? C? ? ? *66??[ T? ?CCCC? ? ? ? :?  ??  ?  ??? ? ? ? 
? ?  ? CC? ? ? ? :?  ??  ?  ?6??5 T? ?CC? ?? ?  ? CC? ?? ? :[?? ? :[6??[ T? ?CCCC? ? ? ? :?  ??  ?  ??? ? ? ? 
? ?  ? CC? ? ? ? :?  ??  ?  ?6??5 T? ?CC? ?? ?  ? CC? ?? ? :[?? ? :[6?? T? ??  ??. %?C? ?
? C? ?
? C? ?
? C? ?
??/? H?,?+?- ?C? ?
? C? ?
? C? ?	? C? ?	??o? T? ? ?C? #?? T? ? ?C? #?? H???k?  ?C? ? ?
?
 C? ? ?
	??+? %?? ? ? ? ??B?? T? ?? CC? ?? ?  ? ?  AND 6?W CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) = ?SaleProducts.DataInicial?? ?'?? T? ?? CC? ?? ?  ? ?  AND 6?? CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal?? ? ?C? ? ?
?	 C? ? ?	????? T? ?? CC? ?? ?  ? ?  AND 6?X CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial?? ?C? ? ??
 C? ? ?
	??k?? T? ?? CC? ?? ?  ? ?  AND 6?V CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal?? ?. ?C? ?
? C? ?
	? C? ?
	? C? ?
	???? T? ? ?C? ?  ? ???? T? ? ?C? ?  ? ???? %?? ? ? ? ??B?V T? ?? CC? ?? ?  ? ?  AND 6?, E.DATA_DIGITACAO = ?SaleProducts.DataInicial?? ???? T? ?? CC? ?? ?  ? ?  AND 6?] E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal?? ?- ?C? ?
? C? ?
	? C? ?
	? C? ?	???? T? ? ?C? ?  ? ???? T? ? ?C? #??? T? ?? CC? ?? ?  ? ?  AND 6?? E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal??- ?C? ?
? C? ?
	? C? ?	? C? ?
	???	? T? ? ?C? #?? T? ? ?C? ?  ? ????? T? ?? CC? ?? ?  ? ?  AND 6?? CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal??, ?C? ?
? C? ?	? C? ?
	? C? ?	???
? T? ? ?C? ?  ? ????W T? ?? CC? ?? ?  ? ?  AND 6?- E.DATA_DIGITACAO >= ?SaleProducts.DataInicial??, ?C? ?? C? ?
	? C? ?	? C? ?
	??+? T? ? ?C? ?  ? ????U T? ?? CC? ?? ?  ? ?  AND 6?+ E.DATA_DIGITACAO <= ?SaleProducts.DataFinal?? ? ?l T? ?? CC? ? ?? ?  ?K CC? ?? ?  ? ?  AND 6?/ B.GRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Group)6??r T? ?? CC? ? ?? ?  ?Q CC? ?? ?  ? ?  AND 6?5 B.SUBGRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Subgroup)6??h T? ?? CC? ? ?? ?  ?G CC? ?? ?  ? ?  AND 6?+ A.PRODUTO LIKE RTRIM(?SaleProducts.Product)6??q T? ?? CC? ? ?? ?  ?P CC? ?? ?  ? ?  AND 6?4 A.COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColor)6??x T? ?? CC? ? ?? ?  ?W CC? ?? ?  ? ?  AND 6?; B.DESC_PROD_NF LIKE RTRIM(?SaleProducts.ProductDescription)6??? T? ?? CC? ? ?? ?  ?` CC? ?? ?  ? ?  AND 6?D C.DESC_COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColorDescription)6?? H????? ?? ? ???;?7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE < 0?? ?? ? ?????7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE = 0?? ?? ? ?????7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE > 0?? ?rT? ??j SELECT A.PRODUTO, B.DESC_PROD_NF, A.COR_PRODUTO,	C.DESC_COR_PRODUTO,	B.GRUPO_PRODUTO, B.SUBGRUPO_PRODUTO, ?d  PB.GRADE AS TAMANHO, A.QTDE AS QTDE, (A.QTDE * A.PRECO_LIQUIDO) AS VALOR FROM LOJA_VENDA_PRODUTO A ?0  INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO ?W  INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO ?5  INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE ?v  INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA ?@  INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL ?r  INNER JOIN ESTOQUE_PRODUTOS G ON F.FILIAL = G.FILIAL AND A.PRODUTO = G.PRODUTO AND A.COR_PRODUTO = G.COR_PRODUTO ?B  INNER JOIN PRODUTOS_BARRA PB ON A.CODIGO_BARRA = PB.CODIGO_BARRA ?D  WHERE A.CODIGO_FILIAL = ?main.p_codigo_filial and	A.QTDE != 0 and  ? ?  ??F %?C ? ?	 CurReport?$ Erro pesquisando tipos de pagamento.? 
???? B?-?? ? F? ? & ?? ?  ?! ?" ???# ? #)?? o?	 CurReport??! ???$ ???" ???% ??? ???  ???& ??C?' ???Q?' ?C?( ???Q?( ???! ???$ ???" ???% ??? ???  ???& ???? curVendaProduto?? F? ? & ?? ?  ?! ?" ???) ? #)? U*  _DESC_ESTOQUE	 STRFILTER	 CURREPORT CURVENDAPRODUTO SALEPRODUCTS	 STOCKINFO STRDATAINICIAL CHKSEARCHTODAY VALUE MAIN DATE TXTSTARTDATE STRDATAFINAL TXTFINISHDATE STRHORAINICIAL TXTSTARTHOUR CHKHOUR STRHORAFINAL TXTFINISHHOUR DATAINICIAL	 DATAFINAL THISSALEPRODUCTSFORM GROUP SUBGROUP PRODUCT PRODUCTCOLOR STFILTER PRODUCTDESCRIPTION PRODUCTCOLORDESCRIPTION	 STRSELECT	 SQLSELECT GRUPO_PRODUTO SUBGRUPO_PRODUTO PRODUTO COR_PRODUTO IREP DESC_PROD_NF DESC_COR_PRODUTO TAMANHO QTDE VALOR IPROD Destroy,     ?? Init?     ??1 q ?r ?3 ?? A ?? A ? A?A?A?A?A BA?Q?Q? ?? ?!!? q? ?A ?!?B ???ra? qA ??!!?!?!??q??QB A ?!??? AqAqAqA +7bq A r ?Q 7	s ?Q 3                       ?         ?   ?  	    )   ?                          %ORIENTATION=0
PAPERSIZE=9
COLOR=2
                         Courier New                                                   curVendaProduto.grupo_produto                                  curVendaProduto.subgrupo_produto                              curVendaProduto.Produto                                       	"Produto"                                                     Arial                                                         Callt(curVendaProduto.produto) + ' - '+ curVendaProduto.desc_prod_nf                                                           Arial                                                         (wLogo)                                                       !empty(wLogo) and file(wLogo)                                 &'Consulta de Vendas Por Produto e Cor'                        Arial                                                         main.p_filial                                                 Arial                                                         'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ''LinxPOS '+ alltrim(main.p_versao_loja)                       Arial                                                         "Qtde"                                                        Arial                                                         curVendaProduto.qtde                                          "@Z"                                                          Arial                                                         "Grupo"                                                       Arial                                                         curVendaProduto.grupo_produto                                 Arial                                                         
"Subgrupo"                                                    Arial                                                          curVendaProduto.subgrupo_produto                              Arial                                                         "Total do subgrupo"                                           Arial                                                         curVendaProduto.qtde                                          Arial                                                         "Total do grupo"                                              Arial                                                         curVendaProduto.qtde                                          Arial                                                         _DESC_ESTOQUE                                                 Arial                                                         	"Estoque"                                                     Arial                                                         Kallt(curVendaProduto.cor_produto) + ' - '+ curVendaProduto.DESC_COR_PRODUTO                                                   Arial                                                         curVendaProduto.tamanho                                       "@Z"                                                          Arial                                                         "Cor"                                                         Arial                                                         "Tam"                                                         "@I"                                                          Arial                                                         SaleProducts.DataInicial                                      Arial                                                         SaleProducts.DataFinal                                        Arial                                                         "at?"                                                         Arial                                                         "Per?odo de"                                                  Arial                                                         curVendaProduto.qtde                                          "@Z"                                                          Arial                                                         "Total geral"                                                 Arial                                                         wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                      Courier New                                                   Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                             ?PROCEDURE Init
public _DESC_ESTOQUE as String
Local strFilter as string
SET STEP on
if used("CurReport")
	use in CurReport
ENDIF

if used("curVendaProduto")
	use in curVendaProduto
ENDIF


do case
case SaleProducts.Stockinfo == 1
	_DESC_ESTOQUE = "Estoque negativo"
case SaleProducts.Stockinfo == 2
	_DESC_ESTOQUE = "Sem estoque"
case SaleProducts.Stockinfo == 3
	_DESC_ESTOQUE = "Com estoque"
case SaleProducts.Stockinfo == 4
	_DESC_ESTOQUE = "Todos os produtos"
ENDCASE

strDataInicial = iif(SaleProducts.chkSearchToday.value, dtoc(main.date), iif(empty(SaleProducts.txtStartDate.value), "", dtoc(SaleProducts.txtStartDate.value)))
strDataFinal = iif(SaleProducts.chkSearchToday.value, dtoc(main.date), iif(empty(SaleProducts.txtFinishDate.value), "", dtoc(SaleProducts.txtFinishDate.value)))
strHoraInicial = iif(empty(strtran(strtran(SaleProducts.txtStartHour.value, ":", ""), " ", "")) or !SaleProducts.chkHour.value, "", strtran(strtran(SaleProducts.txtStartHour.value, ":", ""), " ", ""))
strHoraInicial = iif(empty(strHoraInicial), "", stuff(stuff(strHoraInicial, 3, 0, ":"), 6, 0, ":"))
strHoraFinal = iif(empty(strtran(strtran(SaleProducts.txtFinishHour.value, ":", ""), " ", "")) or !SaleProducts.chkHour.value, "", strtran(strtran(SaleProducts.txtFinishHour.value, ":", ""), " ", ""))
strHoraFinal = iif(empty(strHoraFinal), "", stuff(stuff(strHoraFinal, 3, 0, ":"), 6, 0, ":"))


strFilter = ""
if !empty(strDataInicial) or !empty(strDataFinal) or !empty(strHoraInicial) or !empty(strHoraFinal)
	
	do case
	
		case (!empty(strDataInicial) or !empty(strDataFinal)) and empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctod(strDataInicial)
			SaleProducts.DataFinal = ctod(strDataFinal)
			
			do case
			
				case !empty(SaleProducts.DataInicial) and !empty(SaleProducts.DataFinal)
					if SaleProducts.DataInicial == SaleProducts.DataFinal
						strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) = ?SaleProducts.DataInicial"
					else
						strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal"
					endif
				
				case !empty(SaleProducts.DataInicial) and empty(SaleProducts.DataFinal)
					strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial"
				
				case empty(SaleProducts.DataInicial) and !empty(SaleProducts.DataFinal)
					strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal"
			
			endcase
		
		case !empty(strDataInicial) and !empty(strDataFinal) and !empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			
			if SaleProducts.DataInicial == SaleProducts.DataFinal
				strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO = ?SaleProducts.DataInicial'
			else
				strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
			endif
		
		case !empty(strDataInicial) and !empty(strDataFinal) and !empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			thisSaleProductsform.DataFinal = ctod(strDataFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal'
		
		case !empty(strDataInicial) and !empty(strDataFinal) and empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataInicial = ctod(strDataInicial)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
		
		case !empty(strDataInicial) and empty(strDataFinal) and !empty(strHoraInicial) and empty(strHoraFinal)
			SaleProducts.DataInicial = ctot(strDataInicial + " " + strHoraInicial)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO >= ?SaleProducts.DataInicial'
		
		case empty(strDataInicial) and !empty(strDataFinal) and empty(strHoraInicial) and !empty(strHoraFinal)
			SaleProducts.DataFinal = ctot(strDataFinal + " " + strHoraFinal)
			strFilter = strFilter + iif(empty(strFilter), "", " AND ") + 'E.DATA_DIGITACAO <= ?SaleProducts.DataFinal'
		
	endcase
endif

strFilter = strFilter + iif(empty(SaleProducts.group), "", iif(empty(strFilter), "", " AND ") + "B.GRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Group)")
strFilter = strFilter + iif(empty(SaleProducts.SubGroup), "", iif(empty(strFilter), "", " AND ") + "B.SUBGRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Subgroup)")
strFilter = strFilter + iif(empty(SaleProducts.product), "", iif(empty(strFilter), "", " AND ") + "A.PRODUTO LIKE RTRIM(?SaleProducts.Product)")
strFilter = strFilter + iif(empty(SaleProducts.ProductColor), "", iif(empty(strFilter), "", " AND ") + "A.COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColor)")
stFilter = strFilter + iif(empty(SaleProducts.ProductDescription), "", iif(empty(strFilter), "", " AND ") + "B.DESC_PROD_NF LIKE RTRIM(?SaleProducts.ProductDescription)")
strFilter = strFilter + iif(empty(SaleProducts.ProductColorDescription), "", iif(empty(strFilter), "", " AND ") + "C.DESC_COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColorDescription)")

do case
	case SaleProducts.Stockinfo == 1
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE < 0"
	case SaleProducts.Stockinfo == 2
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE = 0"
	case SaleProducts.Stockinfo == 3
		strFilter = strFilter + iif(empty(strFilter), "", " AND ") + "G.ESTOQUE > 0"
endcase

strSelect	= "SELECT A.PRODUTO, B.DESC_PROD_NF, A.COR_PRODUTO,	C.DESC_COR_PRODUTO,	B.GRUPO_PRODUTO, B.SUBGRUPO_PRODUTO, "+;
			  " PB.GRADE AS TAMANHO, A.QTDE AS QTDE, (A.QTDE * A.PRECO_LIQUIDO) AS VALOR FROM LOJA_VENDA_PRODUTO A "+;
			" INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO "+;
			" INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO "+;
			" INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE "+;
			" INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA "+;
			" INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL "+;
			" INNER JOIN ESTOQUE_PRODUTOS G ON F.FILIAL = G.FILIAL AND A.PRODUTO = G.PRODUTO AND A.COR_PRODUTO = G.COR_PRODUTO "+;
			" INNER JOIN PRODUTOS_BARRA PB ON A.CODIGO_BARRA = PB.CODIGO_BARRA "+;
			" WHERE A.CODIGO_FILIAL = ?main.p_codigo_filial and	A.QTDE != 0 and  "+ strFilter + " "

if !SQLSelect(strSelect, "CurReport", "Erro pesquisando tipos de pagamento.")
	return .f.
ENDIF

select CurReport
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd
go top

select ;
	PRODUTO, DESC_PROD_NF, COR_PRODUTO,	DESC_COR_PRODUTO, GRUPO_PRODUTO, SUBGRUPO_PRODUTO, ;
	TAMANHO, sum(QTDE) AS QTDE, sum(VALOR) AS VALOR ;
from CurReport ;
Group by PRODUTO, DESC_PROD_NF, COR_PRODUTO, DESC_COR_PRODUTO, GRUPO_PRODUTO, SUBGRUPO_PRODUTO,TAMANHO ;
Into Cursor curVendaProduto Readwrite


select curVendaProduto 
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd
go top


ENDPROC
PROCEDURE Destroy
*!*	select curProductGrid
*!*	index on grade tag tagGrid

select CurReport
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd

select curVendaProduto 
index on grupo_produto + subgrupo_produto + produto + cor_produto tag iProd

ENDPROC
            ????    ?  ?                        ??   %   [      @  c   z          ?  U  ? 7?  Q? STRING? ?? Q? STRING? G1 ? %?C?	 CurReport???H ? Q? ? ? %?C? curVendaProduto???r ? Q? ? ? H?? ?>? ?? ? ???? ? T?  ?? Estoque negativo?? ?? ? ???? ? T?  ?? Sem estoque?? ?? ? ???? T?  ?? Com estoque?? ?? ? ???>? T?  ?? Todos os produtos?? ?D T? ?C? ? ? ? C?	 ?
 *?! CC? ? ? ?? ?  ? C? ? ? *66??D T? ?C? ? ? ? C?	 ?
 *?! CC? ? ? ?? ?  ? C? ? ? *66??[ T? ?CCCC? ? ? ? :?  ??  ?  ??? ? ? ? 
? ?  ? CC? ? ? ? :?  ??  ?  ?6??5 T? ?CC? ?? ?  ? CC? ?? ? :[?? ? :[6??[ T? ?CCCC? ? ? ? :?  ??  ?  ??? ? ? ? 
? ?  ? CC? ? ? ? :?  ??  ?  ?6??5 T? ?CC? ?? ?  ? CC? ?? ? :[?? ? :[6?? T? ??  ??. %?C? ?
? C? ?
? C? ?
? C? ?
??5? H?2?1?- ?C? ?
? C? ?
? C? ?	? C? ?	??u? T? ? ?C? #?? T? ? ?C? #?? H???q?  ?C? ? ?
?
 C? ? ?
	??1? %?? ? ? ? ??H?? T? ?? CC? ?? ?  ? ?  AND 6?W CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) = ?SaleProducts.DataInicial?? ?-?? T? ?? CC? ?? ?  ? ?  AND 6?? CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal?? ? ?C? ? ?
?	 C? ? ?	????? T? ?? CC? ?? ?  ? ?  AND 6?X CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial?? ?C? ? ??
 C? ? ?
	??q?? T? ?? CC? ?? ?  ? ?  AND 6?V CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal?? ?. ?C? ?
? C? ?
	? C? ?
	? C? ?
	???? T? ? ?C? ?  ? ???? T? ? ?C? ?  ? ???? %?? ? ? ? ??H?V T? ?? CC? ?? ?  ? ?  AND 6?, E.DATA_DIGITACAO = ?SaleProducts.DataInicial?? ???? T? ?? CC? ?? ?  ? ?  AND 6?] E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal?? ?- ?C? ?
? C? ?
	? C? ?
	? C? ?	???? T? ? ?C? ?  ? ???? T? ? ?C? #??? T? ?? CC? ?? ?  ? ?  AND 6?? E.DATA_DIGITACAO >= ?SaleProducts.DataInicial AND CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) <= ?SaleProducts.DataFinal??- ?C? ?
? C? ?
	? C? ?	? C? ?
	???	? T? ? ?C? #?? T? ? ?C? ?  ? ????? T? ?? CC? ?? ?  ? ?  AND 6?? CONVERT(DATETIME, CONVERT(CHAR(10), E.DATA_DIGITACAO, 112)) >= ?SaleProducts.DataInicial AND E.DATA_DIGITACAO <= ?SaleProducts.DataFinal??, ?C? ?
? C? ?	? C? ?
	? C? ?	???
? T? ? ?C? ?  ? ????W T? ?? CC? ?? ?  ? ?  AND 6?- E.DATA_DIGITACAO >= ?SaleProducts.DataInicial??, ?C? ?? C? ?
	? C? ?	? C? ?
	??1? T? ? ?C? ?  ? ????U T? ?? CC? ?? ?  ? ?  AND 6?+ E.DATA_DIGITACAO <= ?SaleProducts.DataFinal?? ? ?l T? ?? CC? ? ?? ?  ?K CC? ?? ?  ? ?  AND 6?/ B.GRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Group)6??r T? ?? CC? ? ?? ?  ?Q CC? ?? ?  ? ?  AND 6?5 B.SUBGRUPO_PRODUTO LIKE RTRIM(?SaleProducts.Subgroup)6??h T? ?? CC? ? ?? ?  ?G CC? ?? ?  ? ?  AND 6?+ A.PRODUTO LIKE RTRIM(?SaleProducts.Product)6??q T? ?? CC? ? ?? ?  ?P CC? ?? ?  ? ?  AND 6?4 A.COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColor)6??x T? ?? CC? ? ?? ?  ?W CC? ?? ?  ? ?  AND 6?; B.DESC_PROD_NF LIKE RTRIM(?SaleProducts.ProductDescription)6??? T? ?? CC? ? ?? ?  ?` CC? ?? ?  ? ?  AND 6?D C.DESC_COR_PRODUTO LIKE RTRIM(?SaleProducts.ProductColorDescription)6?? H????? ?? ? ???A?7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE < 0?? ?? ? ?????7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE = 0?? ?? ? ?????7 T? ?? CC? ?? ?  ? ?  AND 6? G.ESTOQUE > 0?? ?rT? ??j SELECT A.PRODUTO, B.DESC_PROD_NF, A.COR_PRODUTO,	C.DESC_COR_PRODUTO,	B.GRUPO_PRODUTO, B.SUBGRUPO_PRODUTO, ?d  PB.GRADE AS TAMANHO, A.QTDE AS QTDE, (A.QTDE * A.PRECO_LIQUIDO) AS VALOR FROM LOJA_VENDA_PRODUTO A ?0  INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO ?W  INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO ?5  INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE ?v  INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA ?@  INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL ?r  INNER JOIN ESTOQUE_PRODUTOS G ON F.FILIAL = G.FILIAL AND A.PRODUTO = G.PRODUTO AND A.COR_PRODUTO = G.COR_PRODUTO ?B  INNER JOIN PRODUTOS_BARRA PB ON A.CODIGO_BARRA = PB.CODIGO_BARRA ?D  WHERE A.CODIGO_FILIAL = ?main.p_codigo_filial and	A.QTDE != 0 and  ? ?  ??F %?C ? ?	 CurReport?$ Erro pesquisando tipos de pagamento.? 
???? B?-?? ? F? ? & ?? ?  ?! ?" ???# ? #)?? o?	 CurReport??! ???$ ???" ???% ??? ???  ???& ??C?' ???Q?' ?C?( ???Q?( ???! ???$ ???" ???% ??? ???  ???& ???? curVendaProduto?? F? ? & ?? ?  ?! ?" ???# ? #)? U)  _DESC_ESTOQUE	 STRFILTER	 CURREPORT CURVENDAPRODUTO SALEPRODUCTS	 STOCKINFO STRDATAINICIAL CHKSEARCHTODAY VALUE MAIN DATE TXTSTARTDATE STRDATAFINAL TXTFINISHDATE STRHORAINICIAL TXTSTARTHOUR CHKHOUR STRHORAFINAL TXTFINISHHOUR DATAINICIAL	 DATAFINAL THISSALEPRODUCTSFORM GROUP SUBGROUP PRODUCT PRODUCTCOLOR STFILTER PRODUCTDESCRIPTION PRODUCTCOLORDESCRIPTION	 STRSELECT	 SQLSELECT GRUPO_PRODUTO SUBGRUPO_PRODUTO PRODUTO COR_PRODUTO IPROD DESC_PROD_NF DESC_COR_PRODUTO TAMANHO QTDE VALORE  F?  ? & ?? ? ? ? ??? ? F? ? & ?? ? ? ? ??? ? U 	 CURREPORT GRUPO_PRODUTO SUBGRUPO_PRODUTO PRODUTO COR_PRODUTO IPROD CURVENDAPRODUTO Init,     ?? Destroy?    ??1 a ?? A ?? A ? A?A?A?A?A BA?Q?Q? ?? ?!!? q? ?A ?!?B ???ra? qA ??!!?!?!??q??QB A ?!??? AqAqAqA +7bq A r ?Q 7	s ?Q 4 t ?r ?2                       ?     ^   ?  ?  ?    )   ?                        