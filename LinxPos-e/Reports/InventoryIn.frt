  .   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                Courier New                                                   curReport.romaneio_produto                                    curReport.produto                                             curReport.cor_produto                                         main.p_codigo_filial                                                                                                        8 cpi                                                         main.p_filial                                                                                                               8 cpi                                                         "Romaneio:"                                                                                                                 Courier New                                                   "!empty(curReport.romaneio_produto)                            "N?mero NF:"                                                                                                                Courier New                                                   "!empty(curReport.romaneio_produto)                            "Respons?vel:"                                                                                                              Courier New                                                   "!empty(curReport.romaneio_produto)                            
"Emiss?o:"                                                                                                                  Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.romaneio_produto                                                                                                  Courier New                                                   "!empty(curReport.romaneio_produto)                            "Quantidade total:"                                                                                                         Courier New                                                   "!empty(curReport.romaneio_produto)                            "Valor Total:"                                                                                                              Courier New                                                   "!empty(curReport.romaneio_produto)                            !curReport.numero_nf_transferencia                                                                                           Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.filial_origem                                                                                                     Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.emissao                                                                                                           Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.responsavel                                                                                                       Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.qtde_total                                                                                                        Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.valor_total                                                                                                       Courier New                                                   "!empty(curReport.romaneio_produto)                                                                                          "!empty(curReport.romaneio_produto)                            Qtde                                                                                                                        Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "X"                                                                                                                         Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           Preco                                                                                                                       Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "="                                                                                                                         Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           Valor                                                                                                                       Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           
"Produto:"                                                    Courier New                                                   curReport.produto                                                                                                           Courier New                                                   curReport.desc_prod_nf                                                                                                      Courier New                                                   "Cor:"                                                        Courier New                                                   curReport.cor_produto                                                                                                       Courier New                                                   curReport.desc_cor_produto                                                                                                  Courier New                                                   Tamanho                                                                                                                     Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "Entrada de mercadorias"                                                                                                    Courier New                                                   "!empty(curReport.romaneio_produto)                            	"Origem:"                                                                                                                   Courier New                                                   "!empty(curReport.romaneio_produto)                            Courier New                                                   8 cpi                                                         Courier New                                                   Courier New                                                   dataenvironment                                               `Top = 92
Left = 604
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                             ?PROCEDURE Init
*!* Fillipi Ramos - DM 110557 - (18/02/2019) - #01# - Alterado para LEFT na tabela TABELAS_PRECO G, pois ? poss?vel existir entrada sem tabela de pre?o.
local strSelect as string

text to strSelect noshow
SELECT
	F.DESC_TIPO_ENTRADA_SAIDA, G.TABELA, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, A.ROMANEIO_PRODUTO,
	A.FILIAL, A.CODIGO_TAB_PRECO, A.FORNECEDOR, A.TIPO_ENTRADA_SAIDA, A.FILIAL_ORIGEM, A.NUMERO_NF_TRANSFERENCIA, A.RESPONSAVEL, A.EMISSAO, A.QTDE_TOTAL,
	A.VALOR_TOTAL, B.PRODUTO, B.COR_PRODUTO,
	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,
	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,
	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,
	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,
	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,
	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,
	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,
	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,
	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_ENTRADA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,
	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,
	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,
	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48
FROM
	LOJA_ENTRADAS A INNER JOIN LOJA_ENTRADAS_PRODUTO B ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND A.FILIAL = B.FILIAL
	INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO
	INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO
	INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE
	INNER JOIN LOJA_TIPOS_ENTRADA_SAIDA F ON F.TIPO_ENTRADA_SAIDA = A.TIPO_ENTRADA_SAIDA
	LEFT JOIN TABELAS_PRECO G ON G.CODIGO_TAB_PRECO = A.CODIGO_TAB_PRECO
WHERE
	A.ROMANEIO_PRODUTO = ?curLojaEntradas.romaneio_produto AND A.FILIAL = ?curLojaEntradas.filial
ORDER BY
	A.ROMANEIO_PRODUTO, B.PRODUTO, B.COR_PRODUTO
ENDTEXT

if !SQLSelect(strSelect, "curEntradas", "Erro pesquisando entradas.")
	return .f.
endif

if used("curReportEntradas")
	use in curReportEntradas
endif

select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, ;
	desc_prod_nf, desc_cor_produto, qtde_total, valor_total, 0 as posicao, tam1 as tamanho, en1 as qtde, preco1 as preco ;
	from curEntradas where 1 = 0 ;
	into cursor curReportEntradas readwrite

for intPosition = 1 to 48
	strInsert = "insert into curReportEntradas (romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, " + ;
		"produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, qtde, preco) " + ;
		"select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, " + ;
		"desc_prod_nf, desc_cor_produto, qtde_total, valor_total, " + ;
		transform(intPosition) + ", tam" + transform(intPosition) + ", en" + transform(intPosition) + ", " + ;
		"evaluate('preco' + evl(substr(ponteiro_preco_tam, " + transform(intPosition) + ", 1), '1')) as preco " + ;
		"from curEntradas where nvl(en" + transform(intPosition) + ", 0) != 0"
	&strInsert
endfor

if used("curReport")
	use in curReport
endif

select romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, ;
	desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco, sum(qtde) as qtde, sum(preco * qtde) as valor ;
	from curReportEntradas ;
	group by romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco ;
	order by romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco ;
	into cursor curReport

SELECT curReport
GO top

ENDPROC
                         ????    ?  ?                           %   ?      g  1             ?  U  ? ??  Q? STRING?	 M(?  ?? ? SELECT?? ?? 	F.DESC_TIPO_ENTRADA_SAIDA, G.TABELA, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, A.ROMANEIO_PRODUTO,?? ?? 	A.FILIAL, A.CODIGO_TAB_PRECO, A.FORNECEDOR, A.TIPO_ENTRADA_SAIDA, A.FILIAL_ORIGEM, A.NUMERO_NF_TRANSFERENCIA, A.RESPONSAVEL, A.EMISSAO, A.QTDE_TOTAL,?/ ?) 	A.VALOR_TOTAL, B.PRODUTO, B.COR_PRODUTO,?? ?~ 	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,?? ?? 	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,?? ?? 	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,?? ?? 	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,?? ?? 	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,?? ?? 	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,?? ?? 	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,?? ?? 	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,?? ?? 	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_ENTRADA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,?? ?? 	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,?? ?? 	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,?- ?' 	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48?
 ? FROM?| ?v 	LOJA_ENTRADAS A INNER JOIN LOJA_ENTRADAS_PRODUTO B ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND A.FILIAL = B.FILIAL?5 ?/ 	INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO?\ ?V 	INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO?: ?4 	INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE?[ ?U 	INNER JOIN LOJA_TIPOS_ENTRADA_SAIDA F ON F.TIPO_ENTRADA_SAIDA = A.TIPO_ENTRADA_SAIDA?K ?E 	LEFT JOIN TABELAS_PRECO G ON G.CODIGO_TAB_PRECO = A.CODIGO_TAB_PRECO? ? WHERE?d ?^ 	A.ROMANEIO_PRODUTO = ?curLojaEntradas.romaneio_produto AND A.FILIAL = ?curLojaEntradas.filial? ? ORDER BY?3 ?- 	A.ROMANEIO_PRODUTO, B.PRODUTO, B.COR_PRODUTO? ?> %?C ?  ? curEntradas? Erro pesquisando entradas.? 
???
? B?-?? ?  %?C? curReportEntradas???? Q? ? ?? o? curEntradas?? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ?Q? ?? ?Q? ?? ?Q? ?? ?Q? ???? ???? curReportEntradas?? ?? ???(??0???NT? ??o insert into curReportEntradas (romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, ?n produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, qtde, preco) ?m select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, ?9 desc_prod_nf, desc_cor_produto, qtde_total, valor_total, C? _? , tamC? _? , enC? _? , ?2 evaluate('preco' + evl(substr(ponteiro_preco_tam, C? _? , 1), '1')) as preco ? from curEntradas where nvl(enC? _?	 , 0) != 0?? &strInsert
 ?? %?C?	 curReport???C? Q? ? ?@o? curReportEntradas?? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ??C? ???Q? ?C? ? ???Q? ??? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ???? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ????	 curReport? F? ? #)? U 	 STRSELECT	 SQLSELECT CURREPORTENTRADAS ROMANEIO_PRODUTO FILIAL_ORIGEM NUMERO_NF_TRANSFERENCIA EMISSAO RESPONSAVEL PRODUTO COR_PRODUTO DESC_PROD_NF DESC_COR_PRODUTO
 QTDE_TOTAL VALOR_TOTAL POSICAO TAM1 TAMANHO EN1 QTDE PRECO1 PRECO CURENTRADAS INTPOSITION	 STRINSERT	 CURREPORT VALOR Init,     ??1 ? ? ?	?	?A?						??	?	?? ?Q????? A? 1A ?q A ? A ?	r?$? A ?? A r Q 2                       ?      )   ?                                                                       ?ORIENTATION=0
PAPERSIZE=9
ASCII=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                Courier New                                                   curReport.romaneio_produto                                    curReport.produto                                             curReport.cor_produto                                         main.p_codigo_filial                                                                                                        8 cpi                                                         main.p_filial                                                                                                               8 cpi                                                         "Romaneio:"                                                                                                                 Courier New                                                   "!empty(curReport.romaneio_produto)                            "N?mero NF:"                                                                                                                Courier New                                                   "!empty(curReport.romaneio_produto)                            "Respons?vel:"                                                                                                              Courier New                                                   "!empty(curReport.romaneio_produto)                            
"Emiss?o:"                                                                                                                  Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.romaneio_produto                                                                                                  Courier New                                                   "!empty(curReport.romaneio_produto)                            "Quantidade total:"                                                                                                         Courier New                                                   "!empty(curReport.romaneio_produto)                            "Valor Total:"                                                                                                              Courier New                                                   "!empty(curReport.romaneio_produto)                            !curReport.numero_nf_transferencia                                                                                           Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.filial_origem                                                                                                     Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.emissao                                                                                                           Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.responsavel                                                                                                       Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.qtde_total                                                                                                        Courier New                                                   "!empty(curReport.romaneio_produto)                            curReport.valor_total                                                                                                       Courier New                                                   "!empty(curReport.romaneio_produto)                                                                                          "!empty(curReport.romaneio_produto)                            Qtde                                                                                                                        Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "X"                                                                                                                         Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           Preco                                                                                                                       Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "="                                                                                                                         Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           Valor                                                                                                                       Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           
"Produto:"                                                    Courier New                                                   curReport.produto                                                                                                           Courier New                                                   curReport.desc_prod_nf                                                                                                      Courier New                                                   "Cor:"                                                        Courier New                                                   curReport.cor_produto                                                                                                       Courier New                                                   curReport.desc_cor_produto                                                                                                  Courier New                                                   Tamanho                                                                                                                     Courier New                                                   C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                                                           "Entrada de mercadorias"                                                                                                    Courier New                                                   "!empty(curReport.romaneio_produto)                            	"Origem:"                                                                                                                   Courier New                                                   "!empty(curReport.romaneio_produto)                            Courier New                                                   8 cpi                                                         Courier New                                                   Courier New                                                   dataenvironment                                               aTop = 386
Left = 343
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                            KPROCEDURE Init
local strSelect as string

text to strSelect noshow
SELECT
	F.DESC_TIPO_ENTRADA_SAIDA, G.TABELA, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, A.ROMANEIO_PRODUTO,
	A.FILIAL, A.CODIGO_TAB_PRECO, A.FORNECEDOR, A.TIPO_ENTRADA_SAIDA, A.FILIAL_ORIGEM, A.NUMERO_NF_TRANSFERENCIA, A.RESPONSAVEL, A.EMISSAO, A.QTDE_TOTAL,
	A.VALOR_TOTAL, B.PRODUTO, B.COR_PRODUTO,
	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,
	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,
	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,
	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,
	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,
	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,
	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,
	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,
	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_ENTRADA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,
	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,
	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,
	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48
FROM
	LOJA_ENTRADAS A INNER JOIN LOJA_ENTRADAS_PRODUTO B ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND A.FILIAL = B.FILIAL
	INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO
	INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO
	INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE
	INNER JOIN LOJA_TIPOS_ENTRADA_SAIDA F ON F.TIPO_ENTRADA_SAIDA = A.TIPO_ENTRADA_SAIDA
	INNER JOIN TABELAS_PRECO G ON G.CODIGO_TAB_PRECO = A.CODIGO_TAB_PRECO
WHERE
	A.ROMANEIO_PRODUTO = ?curLojaEntradas.romaneio_produto AND A.FILIAL = ?curLojaEntradas.filial
ORDER BY
	A.ROMANEIO_PRODUTO, B.PRODUTO, B.COR_PRODUTO
ENDTEXT

if !SQLSelect(strSelect, "curEntradas", "Erro pesquisando entradas.")
	return .f.
endif

if used("curReportEntradas")
	use in curReportEntradas
endif

select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, ;
	desc_prod_nf, desc_cor_produto, qtde_total, valor_total, 0 as posicao, tam1 as tamanho, en1 as qtde, preco1 as preco ;
	from curEntradas where 1 = 0 ;
	into cursor curReportEntradas readwrite

for intPosition = 1 to 48
	strInsert = "insert into curReportEntradas (romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, " + ;
		"produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, qtde, preco) " + ;
		"select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, " + ;
		"desc_prod_nf, desc_cor_produto, qtde_total, valor_total, " + ;
		transform(intPosition) + ", tam" + transform(intPosition) + ", en" + transform(intPosition) + ", " + ;
		"evaluate('preco' + evl(substr(ponteiro_preco_tam, " + transform(intPosition) + ", 1), '1')) as preco " + ;
		"from curEntradas where nvl(en" + transform(intPosition) + ", 0) != 0"
	&strInsert
endfor

if used("curReport")
	use in curReport
endif

select romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, ;
	desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco, sum(qtde) as qtde, sum(preco * qtde) as valor ;
	from curReportEntradas ;
	group by romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco ;
	order by romaneio_produto, filial_origem, emissao, responsavel, numero_nf_transferencia, produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, preco ;
	into cursor curReport

SELECT curReport
GO top

ENDPROC
                                                  ????    ?  ?                        ?
   %   ?      h  1             ?  U  ? ??  Q? STRING?	 M(?  ?? ? SELECT?? ?? 	F.DESC_TIPO_ENTRADA_SAIDA, G.TABELA, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, A.ROMANEIO_PRODUTO,?? ?? 	A.FILIAL, A.CODIGO_TAB_PRECO, A.FORNECEDOR, A.TIPO_ENTRADA_SAIDA, A.FILIAL_ORIGEM, A.NUMERO_NF_TRANSFERENCIA, A.RESPONSAVEL, A.EMISSAO, A.QTDE_TOTAL,?/ ?) 	A.VALOR_TOTAL, B.PRODUTO, B.COR_PRODUTO,?? ?~ 	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,?? ?? 	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,?? ?? 	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,?? ?? 	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,?? ?? 	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,?? ?? 	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,?? ?? 	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,?? ?? 	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,?? ?? 	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_ENTRADA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,?? ?? 	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,?? ?? 	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,?- ?' 	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48?
 ? FROM?| ?v 	LOJA_ENTRADAS A INNER JOIN LOJA_ENTRADAS_PRODUTO B ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND A.FILIAL = B.FILIAL?5 ?/ 	INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO?\ ?V 	INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO?: ?4 	INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE?[ ?U 	INNER JOIN LOJA_TIPOS_ENTRADA_SAIDA F ON F.TIPO_ENTRADA_SAIDA = A.TIPO_ENTRADA_SAIDA?L ?F 	INNER JOIN TABELAS_PRECO G ON G.CODIGO_TAB_PRECO = A.CODIGO_TAB_PRECO? ? WHERE?d ?^ 	A.ROMANEIO_PRODUTO = ?curLojaEntradas.romaneio_produto AND A.FILIAL = ?curLojaEntradas.filial? ? ORDER BY?3 ?- 	A.ROMANEIO_PRODUTO, B.PRODUTO, B.COR_PRODUTO? ?> %?C ?  ? curEntradas? Erro pesquisando entradas.? 
???
? B?-?? ?  %?C? curReportEntradas???? Q? ? ?? o? curEntradas?? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ?Q? ?? ?Q? ?? ?Q? ?? ?Q? ???? ???? curReportEntradas?? ?? ???(??0?? ?NT? ??o insert into curReportEntradas (romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, ?n produto, cor_produto, desc_prod_nf, desc_cor_produto, qtde_total, valor_total, posicao, tamanho, qtde, preco) ?m select romaneio_produto, filial_origem, numero_nf_transferencia, emissao, responsavel, produto, cor_produto, ?9 desc_prod_nf, desc_cor_produto, qtde_total, valor_total, C? _? , tamC? _? , enC? _? , ?2 evaluate('preco' + evl(substr(ponteiro_preco_tam, C? _? , 1), '1')) as preco ? from curEntradas where nvl(enC? _?	 , 0) != 0?? &strInsert
 ?? %?C?	 curReport???D? Q? ? ?@o? curReportEntradas?? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ??C? ???Q? ?C? ? ???Q? ??? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ???? ??? ??? ??? ??? ??? ???	 ???
 ??? ??? ??? ??? ??? ??? ????	 curReport? F? ? #)? U 	 STRSELECT	 SQLSELECT CURREPORTENTRADAS ROMANEIO_PRODUTO FILIAL_ORIGEM NUMERO_NF_TRANSFERENCIA EMISSAO RESPONSAVEL PRODUTO COR_PRODUTO DESC_PROD_NF DESC_COR_PRODUTO
 QTDE_TOTAL VALOR_TOTAL POSICAO TAM1 TAMANHO EN1 QTDE PRECO1 PRECO CURENTRADAS INTPOSITION	 STRINSERT	 CURREPORT VALOR Init,     ??1 ? ? ?	?	?A?						??	?	?? ?Q????? A? 1A ?q A ? A ?	r?$? A ?? A r Q 2                       @      )   ?                                                                