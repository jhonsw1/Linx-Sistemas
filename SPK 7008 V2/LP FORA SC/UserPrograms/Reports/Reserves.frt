  �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
                           Courier New                    curReport.numero_reserva       curReport.produto              curReport.cor_produto          main.p_codigo_filial                                          8 cpi                          main.p_filial                                                 8 cpi                          "N�mero da reserva:"                                          Courier New                    
"Emiss�o:"                                                    Courier New                    curReport.numero_reserva                                      Courier New                    "Quantidade total:"                                           Courier New                    "Valor Total:"                                                Courier New                    curReport.filial                                              Courier New                    curReport.emissao                                             Courier New                    curReport.qtde_total                                          Courier New                    curReport.valor_total                                         Courier New                                                   Qtde                                                          Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              "X"                                                           Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              Preco                                                         Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              "="                                                           Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              Valor                                                         Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              
"Produto:"                     Courier New                    curReport.produto                                             Courier New                    curReport.desc_prod_nf                                        Courier New                    "Cor:"                         Courier New                    curReport.cor_produto                                         Courier New                    curReport.desc_cor_produto                                                                     Courier New                    Tamanho                                                       Courier New                    C!empty(Tamanho) and right(alltrim(Tamanho), 1) != "." and Qtde != 0                              "Reservas e consigna��es"                                     Courier New                     !empty(curReport.numero_reserva)                                	"Filial:"                                                     Courier New                    
"Cliente:"                                                    Courier New                    curReport.cliente_varejo                                      Courier New                    "Vendedor:"                                                   Courier New                    curReport.nome_vendedor        Courier New                    Courier New                    8 cpi                          Courier New                    Courier New                    dataenvironment                aTop = 386
Left = 343
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                                ePROCEDURE Init
local strSelect as string

text to strSelect noshow
SELECT A.FILIAL, A.NUMERO_RESERVA, CODIGO_RESERVA, A.CODIGO_CLIENTE, CLIENTE_VAREJO, A.VENDEDOR, NOME_VENDEDOR, 
	EMISSAO, PREVISAO_RETORNO, ENCERRAMENTO, QTDE_TOTAL, VALOR_TOTAL, A.OBS, FATOR_PRECO, CODIGO_TAB_PRECO, 
	B.PRODUTO, B.COR_PRODUTO, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, 
	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,
	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,
	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,
	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,
	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,
	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,
	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,
	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,
	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_SAIDA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,
	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,
	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,
	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48
FROM LOJA_RESERVA A
INNER JOIN LOJA_RESERVA_PRODUTO B ON A.NUMERO_RESERVA = B.NUMERO_RESERVA AND A.FILIAL = B.FILIAL
INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO
INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO
INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE
LEFT JOIN CLIENTES_VAREJO F ON A.CODIGO_CLIENTE = F.CODIGO_CLIENTE 
LEFT JOIN LOJA_VENDEDORES G ON A.VENDEDOR = G.VENDEDOR
WHERE
	A.NUMERO_RESERVA = ?curLojaReserva.NUMERO_RESERVA AND A.FILIAL = ?curLojaReserva.filial
ENDTEXT

if !SQLSelect(strSelect, "curReservas", "Erro pesquisando reservas.")
	return .f.
endif

select filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, ;
	emissao, previsao_retorno, encerramento, qtde_total, valor_total, obs, fator_preco, codigo_tab_preco, ;
	produto, cor_produto, desc_prod_nf, desc_cor_produto, 0 as posicao, tam1 as tamanho, en1 as qtde, preco1 as preco ;
	from curReservas where 1 = 0 ;
	into cursor curReportReservas readwrite

for intPosition = 1 to 48
	strInsert = "insert into curReportReservas (filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, "+;
		"emissao, previsao_retorno, encerramento, qtde_total, valor_total, obs, fator_preco, codigo_tab_preco, "+;
		"produto, cor_produto, desc_prod_nf, desc_cor_produto, posicao, tamanho, qtde, preco) "+;
		"select filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, "+;
		"emissao, previsao_retorno, encerramento, qtde_total, valor_total, obs, fator_preco, codigo_tab_preco, "+;
		"produto, cor_produto, desc_prod_nf, desc_cor_produto, "+;
		transform(intPosition) + ", tam" + transform(intPosition) + ", en" + transform(intPosition) + ", " + ;
		"evaluate('preco' + evl(substr(ponteiro_preco_tam, " + transform(intPosition) + ", 1), '1')) as preco " + ;
		"from curReservas where nvl(en" + transform(intPosition) + ", 0) != 0"
	&strInsert
endfor

select filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, ;
		emissao, previsao_retorno, encerramento, qtde_total, valor_total, fator_preco, codigo_tab_preco, ;
		produto, cor_produto, desc_prod_nf, desc_cor_produto, posicao, tamanho, preco, sum(qtde) as qtde, sum(preco * qtde) as valor ;
	from curReportReservas ;
	group by filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, ;
		emissao, previsao_retorno, encerramento, qtde_total, valor_total, fator_preco, codigo_tab_preco, ;
		produto, cor_produto, desc_prod_nf, desc_cor_produto, posicao, tamanho, preco;
	into cursor curReport

ENDPROC
       %���                              z   %   i      �  &   w          �  U  � ��  Q� STRING�	 M(�  ��v �p SELECT A.FILIAL, A.NUMERO_RESERVA, CODIGO_RESERVA, A.CODIGO_CLIENTE, CLIENTE_VAREJO, A.VENDEDOR, NOME_VENDEDOR, �o �i 	EMISSAO, PREVISAO_RETORNO, ENCERRAMENTO, QTDE_TOTAL, VALOR_TOTAL, A.OBS, FATOR_PRECO, CODIGO_TAB_PRECO, � �y 	B.PRODUTO, B.COR_PRODUTO, C.DESC_PROD_NF, D.DESC_COR_PRODUTO, C.VARIA_PRECO_TAM, C.PONTEIRO_PRECO_TAM, NUMERO_TAMANHOS, �� �~ 	E.TAMANHO_1 AS TAM1, E.TAMANHO_2 AS TAM2, E.TAMANHO_3 AS TAM3, E.TAMANHO_4 AS TAM4, E.TAMANHO_5 AS TAM5, E.TAMANHO_6 AS TAM6,�� �� 	E.TAMANHO_7 AS TAM7, E.TAMANHO_8 AS TAM8, E.TAMANHO_9 AS TAM9, E.TAMANHO_10 AS TAM10, E.TAMANHO_11 AS TAM11, E.TAMANHO_12 AS TAM12,�� �� 	E.TAMANHO_13 AS TAM13, E.TAMANHO_14 AS TAM14, E.TAMANHO_15 AS TAM15, E.TAMANHO_16 AS TAM16, E.TAMANHO_17 AS TAM17, E.TAMANHO_18 AS TAM18,�� �� 	E.TAMANHO_19 AS TAM19, E.TAMANHO_20 AS TAM20, E.TAMANHO_21 AS TAM21, E.TAMANHO_22 AS TAM22, E.TAMANHO_23 AS TAM23, E.TAMANHO_24 AS TAM24,�� �� 	E.TAMANHO_25 AS TAM25, E.TAMANHO_26 AS TAM26, E.TAMANHO_27 AS TAM27, E.TAMANHO_28 AS TAM28, E.TAMANHO_29 AS TAM29, E.TAMANHO_30 AS TAM30,�� �� 	E.TAMANHO_31 AS TAM31, E.TAMANHO_32 AS TAM32, E.TAMANHO_33 AS TAM33, E.TAMANHO_34 AS TAM34, E.TAMANHO_35 AS TAM35, E.TAMANHO_36 AS TAM36,�� �� 	E.TAMANHO_37 AS TAM37, E.TAMANHO_38 AS TAM38, E.TAMANHO_39 AS TAM39, E.TAMANHO_40 AS TAM40, E.TAMANHO_41 AS TAM41, E.TAMANHO_42 AS TAM42,�� �� 	E.TAMANHO_43 AS TAM43, E.TAMANHO_44 AS TAM44, E.TAMANHO_45 AS TAM45, E.TAMANHO_46 AS TAM46, E.TAMANHO_47 AS TAM47, E.TAMANHO_48 AS TAM48,�� �� 	E.QUEBRA_1, E.QUEBRA_2, E.QUEBRA_3, B.PRECO1, B.PRECO2, B.PRECO3, B.PRECO4, B.VALOR, B.QTDE_SAIDA, B.EN1, B.EN2, B.EN3, B.EN4, B.EN5,�� �� 	B.EN6, B.EN7, B.EN8, B.EN9, B.EN10, B.EN11, B.EN12, B.EN13, B.EN14, B.EN15, B.EN16, B.EN17, B.EN18, B.EN19, B.EN20, B.EN21, B.EN22, B.EN23, B.EN24,�� �� 	B.EN25, B.EN26, B.EN27, B.EN28, B.EN29, B.EN30, B.EN31, B.EN32, B.EN33, B.EN34, B.EN35, B.EN36, B.EN37, B.EN38, B.EN39, B.EN40, B.EN41, B.EN42, B.EN43,�- �' 	B.EN44, B.EN45, B.EN46, B.EN47, B.EN48� � FROM LOJA_RESERVA A�f �` INNER JOIN LOJA_RESERVA_PRODUTO B ON A.NUMERO_RESERVA = B.NUMERO_RESERVA AND A.FILIAL = B.FILIAL�4 �. INNER JOIN PRODUTOS C ON C.PRODUTO = B.PRODUTO�[ �U INNER JOIN PRODUTO_CORES D ON D.PRODUTO = B.PRODUTO AND D.COR_PRODUTO = B.COR_PRODUTO�9 �3 INNER JOIN PRODUTOS_TAMANHOS E ON E.GRADE = C.GRADE�I �C LEFT JOIN CLIENTES_VAREJO F ON A.CODIGO_CLIENTE = F.CODIGO_CLIENTE �< �6 LEFT JOIN LOJA_VENDEDORES G ON A.VENDEDOR = G.VENDEDOR� � WHERE�^ �X 	A.NUMERO_RESERVA = ?curLojaReserva.NUMERO_RESERVA AND A.FILIAL = ?curLojaReserva.filial� �> %�C �  � curReservas� Erro pesquisando reservas.� 
��[
� B�-�� �� o� curReservas�� ��� ��� ��� ��� ��� ��� ���	 ���
 ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� �Q� �� �Q� �� �Q� �� �Q� ���� ���� curReportReservas�� �� ���(��0��c�T� �ـ insert into curReportReservas (filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, �f emissao, previsao_retorno, encerramento, qtde_total, valor_total, obs, fator_preco, codigo_tab_preco, �U produto, cor_produto, desc_prod_nf, desc_cor_produto, posicao, tamanho, qtde, preco) �h select filial, numero_reserva, codigo_reserva, codigo_cliente, cliente_varejo, vendedor, nome_vendedor, �f emissao, previsao_retorno, encerramento, qtde_total, valor_total, obs, fator_preco, codigo_tab_preco, �6 produto, cor_produto, desc_prod_nf, desc_cor_produto, C� _� , tamC� _� , enC� _� , �2 evaluate('preco' + evl(substr(ponteiro_preco_tam, C� _� , 1), '1')) as preco � from curReservas where nvl(enC� _�	 , 0) != 0�� &strInsert
 ��@o� curReportReservas�� ��� ��� ��� ��� ��� ��� ���	 ���
 ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��C� ���Q� �C� � ���Q�  ��� ��� ��� ��� ��� ��� ��� ���	 ���
 ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ��� ����	 curReport� U" 	 STRSELECT	 SQLSELECT FILIAL NUMERO_RESERVA CODIGO_RESERVA CODIGO_CLIENTE CLIENTE_VAREJO VENDEDOR NOME_VENDEDOR EMISSAO PREVISAO_RETORNO ENCERRAMENTO
 QTDE_TOTAL VALOR_TOTAL OBS FATOR_PRECO CODIGO_TAB_PRECO PRODUTO COR_PRODUTO DESC_PROD_NF DESC_COR_PRODUTO POSICAO TAM1 TAMANHO EN1 QTDE PRECO1 PRECO CURRESERVAS CURREPORTRESERVAS INTPOSITION	 STRINSERT VALOR	 CURREPORT Init,     ��1 � a��A�						��	�	��aA����� �A �q A �r)1� A 	2                       Z      )                     