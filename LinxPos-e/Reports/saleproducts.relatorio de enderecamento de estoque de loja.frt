  b   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ?DRIVER=winspool
DEVICE=Microsoft XPS Document Writer
OUTPUT=XPSPort:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
COLLATE=1
       d  1  winspool  Microsoft XPS Document Writer  XPSPort:                                                                    9Microsoft XPS Document Writer   ? ??   	 ?4d   X  X  A4                                                            ????GIS4            DINU"  | ???r                            	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                SMTJ     { 0 F 4 1 3 0 D D - 1 9 C 7 - 7 a b 6 - 9 9 A 1 - 9 8 0 F 0 3 B 2 E E 4 E }   InputBin FORMSOURCE RESDLL UniresDLL Interleaving OFF ImageType JPEGMed Orientation PORTRAIT Collate OFF Resolution Option1 PaperSize LETTER ColorMode 24bpp                                         V4DM                                                                                             Courier New                                                   5TITULO=
CRIADOR=
PADRAO=N
PUBLICO=N
FAVORITOS=;
         "EXPORTAR PARA EXCEL"                                         Arial                                                         Courier New                                                   Arial                                                         dataenvironment                                               ?Top = 50
Left = 307
Width = 538
Height = 371
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                                                H?PROCEDURE Init
xDataAtual = SaleProducts.ChkSearchToday.Value
xHoraataul = SaleProducts.chkHour.Value
If xDataAtual
	xD_i = Date()
	xD_f = Date()
Else
	xD_i = SaleProducts.txtStartDate.Value
	xD_f = SaleProducts.txtFinishDate.Value
Endif

If Empty(xD_i) Or Empty(xD_f)
	Messagebox('Favor Informar Faixa de Datas',16,'Aviso')
	Return .F.
Endif

If (xD_f - xD_i) > 7
	Messagebox('A Faixa de Datas maior que 7',16,'Aviso')
	Return .F.
Endif

xH_i = SaleProducts.txtStartHour.Value
xH_f = SaleProducts.txtFinishHour.Value

If Empty(xH_i) Or Empty(xH_f)
	Messagebox('Favor Informar Faixa de Horas',16,'Aviso')
	Return .F.
Endif

xFromDate = xD_i
xToDate   = xD_f
xFromTime = xH_i
xToTime   = xH_f
xSOH  = [1]
xUnitsSold = [1]

xDiv           = [All]
xDeparment     = [All]
xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = [sa]

Do Case
Case Inlist(SaleProducts.optStockInfo.Value,3,4)
	xSOH  = [1]
	xUnitsSold = [1]
Case SaleProducts.optStockInfo.Value = 2
	xSOH  = [0]
	xUnitsSold = [0]
Otherwise
Endcase

Use In Select([CRS_PESQUISA])
Select GRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By GRUPO_PRODUTO Into Cursor CRS_PESQUISA

xDiv           = [All]
If Reccount([CRS_PESQUISA]) = 1
	xDiv = Alltrim(Nvl(CRS_PESQUISA.GRUPO_PRODUTO,[All]))
Endif

Use In Select([CRS_PESQUISA])
Select SUBGRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By SUBGRUPO_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	xDeparment = Alltrim(Nvl(CRS_PESQUISA.SUBGRUPO_PRODUTO,[All]))
ENDIF

STORE [] TO CPRODUTO, CCOR_PRODUTO 

Use In Select([CRS_PESQUISA])
Select PRODUTO From CURSALEPRODUCTCOLORS Group By PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CPRODUTO = Alltrim(CRS_PESQUISA.PRODUTO)
Endif

Use In Select([CRS_PESQUISA])
Select COR_PRODUTO From CURSALEPRODUCTCOLORS Group By COR_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CCOR_PRODUTO = Alltrim(CRS_PESQUISA.COR_PRODUTO)
Endif

Use In Select([CRS_PESQUISA])

xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = Alltrim(Main.Data.SQLUsername)

xFilial    = "'"+Alltrim(Main.p_filial)+"'"
xFilialEst = Alltrim(Main.p_filial)

xWhFilter = "a.DATA_VENDA Between '" + Dtos(xD_i) + "' and '" + Dtos(xD_f)+ "'" + " AND a.codigo_filial='"+Main.p_codigo_filial+"' and b.Qtde<>0"

If SaleProducts.chkHour.Value
	xWhFilter = xWhFilter + " and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between '" + Alltrim(xH_i) + "' and '" + Alltrim(xH_f) + "'"
Endif

XWHERE = [ A.QTDE <> 0 ]
XWHERE = XWHERE + [ AND A.codigo_filial = '] + Main.P_CODIGO_FILIAL + [']
XWHERE = XWHERE + [ AND a.DATA_VENDA Between '] + Dtos(XD_I) + [' and '] + Dtos(XD_F)+ [']

If SALEPRODUCTS.CHKHOUR.Value
	XWHERE = XWHERE + [ and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between '] + Alltrim(XH_I) + [' and '] + Alltrim(XH_F) + [']
Endif

If XDIV != [All]
	XWHERE = XWHERE + [ and B.GRUPO_PRODUTO = ?xDiv ]
ENDIF

If 	XDEPARMENT != [All]
	XWHERE = XWHERE + [ and B.SUBGRUPO_PRODUTO = ?xDeparment ]
Endif

If 	! EMPTY(CPRODUTO)
	XWHERE = XWHERE + [ and A.PRODUTO = ?CPRODUTO ]
Endif

If 	! EMPTY(CCOR_PRODUTO)
	XWHERE = XWHERE + [ and A.COR_PRODUTO= ?CCOR_PRODUTO]
Endif


* NOVA QUERY 
TEXT TO SSQL NOSHOW TEXTMERGE
	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE 
	FROM LOJA_VENDA_PRODUTO A
	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO
	WHERE <<XWHERE>>

ENDTEXT


*!*	TEXT TO SSQL TEXTMERGE NOSHOW
*!*		SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
*!*		B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
*!*		H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
*!*		CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
*!*			 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
*!*			 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
*!*			 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
*!*			 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
*!*			 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
*!*			 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
*!*			 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
*!*			 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
*!*			 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
*!*			 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
*!*			 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
*!*			 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
*!*			 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
*!*			 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
*!*			 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
*!*			 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
*!*			 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
*!*			 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
*!*			 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
*!*			 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
*!*			 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
*!*			 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
*!*			 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
*!*			 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
*!*			 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
*!*			 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
*!*			 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
*!*			 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
*!*			 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
*!*			 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
*!*			 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
*!*			 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
*!*			 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
*!*			 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
*!*			 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
*!*			 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
*!*			 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
*!*			 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
*!*			 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
*!*			 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
*!*			 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
*!*			 ELSE '' END AS INT) AS QTD_ESTOQUE 
*!*		FROM LOJA_VENDA_PRODUTO A
*!*		INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
*!*		INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
*!*		INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
*!*		INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
*!*		INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
*!*		INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
*!*		INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
*!*		WHERE <<XWHERE>>
*!*	ENDTEXT

If !SQLSELECT(SSQL , "Cur_Exportar_Base", "Erro pesquisando dados dos relat?rios.")
	Return .F.
Endif

USE IN SELECT([CRS_EXPORTAR_BASE]) 
SELECT GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, SUM(QTDE) as QTDE, QTD_ESTOQUE,ESTOQUE ;
FROM Cur_Exportar_Base ;
GROUP BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, QTD_ESTOQUE,ESTOQUE ;
ORDER BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, PRODUTO6, PRODUTO3  ;
INTO CURSOR CRS_EXPORTAR_BASE

xRelExp	= Getfile([XLS],'Salvar Como...',[Salvar],0,[Digite o nome do arquivo em Excel])

If Empty(xRelExp)
	Return .F.
Endif

Try

	oExcel 			= Createobject('Excel.Application')
	oWorkbook 		= oExcel.Workbooks.Add()
	oWorkbook.SaveAs(xRelExp)
	oExcel.Visible 	= .F.

	oExcel.Range("A3:N3").BorderS(8).LineStyle = 1

	oExcel.Range("D4").Value = "REFILL FROM POS"
	oExcel.Range("D4").Font.Size = 14

	oExcel.Range("B6").Value = "From Date:"
	oExcel.Range("B6").Font.Size = 8
	oExcel.Range("B6").Font.Bold = .T.
	oExcel.Range("B6").HorizontalAlignment = 2

	oExcel.Range("C6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("C6").Value = xD_i
	oExcel.Range("C6").Font.Size = 8
	oExcel.Range("C6").Font.Bold = .F.
	oExcel.Range("C6").HorizontalAlignment = 2

	oExcel.Range("G6").Value = "To Date:"
	oExcel.Range("G6").Font.Size = 8
	oExcel.Range("G6").Font.Bold = .T.
	oExcel.Range("G6").HorizontalAlignment = 2

	oExcel.Range("H6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("H6").Value = xD_f
	oExcel.Range("H6").Font.Size = 8
	oExcel.Range("H6").Font.Bold = .F.
	oExcel.Range("H6").HorizontalAlignment = 2

	oExcel.Range("L6").Value = "SOH >=:"
	oExcel.Range("L6").Font.Size = 8
	oExcel.Range("L6").Font.Bold = .T.
	oExcel.Range("L6").HorizontalAlignment = 2

	oExcel.Range("M6").NumberFormat = '@'
	oExcel.Range("M6").Value = xSOH
	oExcel.Range("M6").Font.Size = 8
	oExcel.Range("M6").Font.Bold = .F.
	oExcel.Range("M6").HorizontalAlignment = 2


	oExcel.Range("B7").Value = "From Time:"
	oExcel.Range("B7").Font.Size = 8
	oExcel.Range("B7").Font.Bold = .T.
	oExcel.Range("B7").HorizontalAlignment = 2

	oExcel.Range("C7").NumberFormat = '@'
	oExcel.Range("C7").Value = xH_i
	oExcel.Range("C7").Font.Size = 8
	oExcel.Range("C7").Font.Bold = .F.
	oExcel.Range("C7").HorizontalAlignment = 2

	oExcel.Range("G7").Value = "To Time:"
	oExcel.Range("G7").Font.Size = 8
	oExcel.Range("G7").Font.Bold = .T.
	oExcel.Range("G7").HorizontalAlignment = 2

	oExcel.Range("H7").NumberFormat = '@'
	oExcel.Range("H7").Value = xH_f
	oExcel.Range("H7").Font.Size = 8
	oExcel.Range("H7").Font.Bold = .F.
	oExcel.Range("H7").HorizontalAlignment = 2

	oExcel.Range("L7").Value = "Units Sold >=:"
	oExcel.Range("L7").Font.Size = 8
	oExcel.Range("L7").Font.Bold = .T.
	oExcel.Range("L7").HorizontalAlignment = 2

	oExcel.Range("M7").NumberFormat = '@'
	oExcel.Range("M7").Value = xUnitsSold
	oExcel.Range("M7").Font.Size = 8
	oExcel.Range("M7").Font.Bold = .F.
	oExcel.Range("M7").HorizontalAlignment = 2

	oExcel.Range("B8").Value = "Div:"
	oExcel.Range("B8").Font.Size = 8
	oExcel.Range("B8").Font.Bold = .T.
	oExcel.Range("B8").HorizontalAlignment = 2

	oExcel.Range("C8").NumberFormat = '@'
	oExcel.Range("C8").Value = xDiv
	oExcel.Range("C8").Font.Size = 8
	oExcel.Range("C8").Font.Bold = .F.
	oExcel.Range("C8").HorizontalAlignment = 2


	oExcel.Range("G8").Value = "Deparment:"
	oExcel.Range("G8").Font.Size = 8
	oExcel.Range("G8").Font.Bold = .T.
	oExcel.Range("G8").HorizontalAlignment = 2

	oExcel.Range("H8").NumberFormat = '@'
	oExcel.Range("H8").Value = xDeparment
	oExcel.Range("H8").Font.Size = 8
	oExcel.Range("H8").Font.Bold = .F.
	oExcel.Range("H8").HorizontalAlignment = 2

	oExcel.Range("L8").Value = "Sub Department:"
	oExcel.Range("L8").Font.Size = 8
	oExcel.Range("L8").Font.Bold = .T.
	oExcel.Range("L8").HorizontalAlignment = 2

	oExcel.Range("M8").NumberFormat = '@'
	oExcel.Range("M8").Value = xSubDepartment
	oExcel.Range("M8").Font.Size = 8
	oExcel.Range("M8").Font.Bold = .F.
	oExcel.Range("M8").HorizontalAlignment = 2


	oExcel.Range("B9").Value = "Show:"
	oExcel.Range("B9").Font.Size = 8
	oExcel.Range("B9").Font.Bold = .T.
	oExcel.Range("B9").HorizontalAlignment = 2

	oExcel.Range("C9").NumberFormat = '@'
	oExcel.Range("C9").Value = xShow
	oExcel.Range("C9").Font.Size = 8
	oExcel.Range("C9").Font.Bold = .F.
	oExcel.Range("C9").HorizontalAlignment = 2

	oExcel.Range("G9").Value = "Printed By:"
	oExcel.Range("G9").Font.Size = 8
	oExcel.Range("G9").Font.Bold = .T.
	oExcel.Range("G9").HorizontalAlignment = 2

	oExcel.Range("H9").NumberFormat = '@'
	oExcel.Range("H9").Value = xPrintedBy
	oExcel.Range("H9").Font.Size = 8
	oExcel.Range("H9").Font.Bold = .F.
	oExcel.Range("H9").HorizontalAlignment = 2

	oExcel.Range("A10:N10").BorderS(9).LineStyle = 1


	oExcel.Range("A13:N13").Select
	oExcel.Selection.Font.Bold = .T.
	oExcel.Selection.Interior.ColorIndex = 15


*!*	  	***Cabe?alhos
	oExcel.Range("A13").Value = ""
	oExcel.Range("B13").Value = "Div"
	oExcel.Range("C13").Value = "Department"
	oExcel.Range("D13").Value = "Sub Department"
	oExcel.Range("E13").Value = "Style"
	oExcel.Range("F13").Value = "Clr"
	oExcel.Range("G13").Value = "Size"
	oExcel.Range("H13").Value = "QC"
	oExcel.Range("I13").Value = "Item No"
	oExcel.Range("J13").Value = "Item Description"
	oExcel.Range("K13").Value = "Units Sold"
	oExcel.Range("L13").Value = "SOH"
	oExcel.Range("M13").Value = "TOTAL SOH"
	oExcel.Range("N13").Value = "Bin"

	oExcel.Range("A13:N13").Font.Size = 8
	oExcel.Range("A13:N13").Font.Bold = .T.
	oExcel.Range("B13:N13").Select
	oExcel.Range("B13:N13").AutoFilter

	oExcel.Columns("A").ColumnWidth = 2
	oExcel.Columns("B:N").ColumnWidth = 15

*-- Incluir Produtos e Fotos
	xLin=14

	Select CRS_EXPORTAR_BASE
	XTOTCMP = Afields(XARRCMP)
	Go Top
	Scan
		NLETRA = Asc('A')
		For XC = 1 To XTOTCMP
			NLETRA = NLETRA  + 1
			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").NumberFormat = "] + Iif(XARRCMP(XC,2) = 'C', [@], [#####0]) + ["]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Size = 8]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Bold = .F.]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").ColumnWidth = 12]
			&CMACRO.

			CMACRO = [CRS_EXPORTAR_BASE.] + XARRCMP(XC,1)
			CCAMPO = &CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Value = ] + Iif(XARRCMP(XC,2) = 'C', ["], []) +  Iif(XARRCMP(XC,2) = 'C', Alltrim(CCAMPO), Alltrim(Str(CCAMPO))) + Iif(XARRCMP(XC,2) = 'C', ["], [])
			&CMACRO.
		Endfor
		xLin	=	xLin + 1
		Select CRS_EXPORTAR_BASE
	Endscan

 
IF RECCOUNT([CRS_EXPORTAR_BASE]) > 1
	xlsum = -4157
	Local Array LAARRAY(3)
	LAARRAY(1) = 11
	LAARRAY(2) = 12
	LAARRAY(3) = 13

	CMACRO = [oExcel.Range("A13:N] + Alltrim(Str(xLin)) + [").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)]
	&CMACRO.
ENDIF

 

*!*	oExcel.Range("A14:M10000").Subtotal(2, xlsum, @laArray,.T.,.F.,.T.)
*!*	.WrapText = True	
	
	oExcel.Range("A14:N" + Alltrim(Str(xLin+10))).EntireColumn.AutoFit
	oExcel.Range("K14:L" + Alltrim(Str(xLin+10))).HorizontalAlignment = 2

    oExcel.Columns("C:C").ColumnWidth = 15
    oExcel.Columns("D:D").ColumnWidth = 16
    oExcel.Columns("E:E").ColumnWidth = 7
    oExcel.Columns("F:F").ColumnWidth = 6
    oExcel.Columns("J:J").ColumnWidth = 14

    oExcel.Columns("K:K").ColumnWidth = 10
    oExcel.Columns("M:M").ColumnWidth = 11
    oExcel.Columns("N:N").ColumnWidth = 6


	oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
	oExcel.ActiveSheet.PageSetup.PrintArea = ("A1:N" + Alltrim(Str(xLin+10)))
	oExcel.ActiveSheet.PageSetup.PrintTitleRows = "A$13:N$13"
	oExcel.ActiveSheet.PageSetup.Orientation = 2
	oExcel.ActiveSheet.PageSetup.FitToPagesWide = 1
	oExcel.ActiveSheet.PageSetup.Zoom = 80
	oExcel.ActiveSheet.PageSetup.FitToPagesTall = 100
	oExcel.Range("A4:N4").Select
	oExcel.Selection.MergeCells = .T.
	oExcel.Selection.HorizontalAlignment = 3

*-- Fechar
	oExcel.ActiveWorkbook.Save
	oExcel.Application.Quit()
	oExcel.Quit()
	Release oExcel

	Messagebox('Arquivo Gerado Com Sucesso: ',48,'Aviso')
Catch
	Messagebox('N?o foi Possivel Gerar o Arquivo ' + Chr(13) + 'Verifique se n?o est? aberto',16,'Aviso')
Endtry


Return .F.

ENDPROC
                                               5????    ?5  ?5                        g?   %   ?2      ?5  k  ?2          ?  U  ). T?  ?? ? ? ?? T? ?? ? ? ?? %??  ??K ? T? ?C$?? T? ?C$?? ?y ? T? ?? ? ? ?? T? ?? ?	 ? ?? ? %?C? ?? C? ???? ?4 ??C? Favor Informar Faixa de Datas?? Aviso?x?? B?-?? ? %?? ? ???$?3 ??C? A Faixa de Datas maior que 7?? Aviso?x?? B?-?? ? T?
 ?? ? ? ?? T? ?? ? ? ?? %?C?
 ?? C? ?????4 ??C? Favor Informar Faixa de Horas?? Aviso?x?? B?-?? ? T? ?? ?? T? ?? ?? T? ??
 ?? T? ?? ?? T? ?? 1?? T? ?? 1?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? sa?? H?Q??? ?C? ? ? ??????? T? ?? 1?? T? ?? 1?? ?? ? ? ????? T? ?? 0?? T? ?? 0?? 2??? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? T? ?? All?? %?C? CRS_PESQUISAN???f? T? ?CC? ? ? Allқ?? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?CC? ? ? Allқ?? ? J??  ?(? ?  ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??! ????! ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?C? ?! ??? ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??# ????# ???? CRS_PESQUISA? %?C? CRS_PESQUISAN???? T?  ?C? ?# ??? ? Q?C? CRS_PESQUISAW?? T? ?? All?? T? ?? All?? T? ?C?$ ?% ?& ??? T?' ?? 'C?$ ?( ?? '?? T?) ?C?$ ?( ???s T?* ?? a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?  AND a.codigo_filial='?$ ?+ ? ' and b.Qtde<>0?? %?? ? ? ????h T?* ??* ?;  and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? T?, ??  A.QTDE <> 0 ??5 T?, ??, ?  AND A.codigo_filial = '?$ ?+ ? '??H T?, ??, ?  AND a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?? %?? ? ? ????h T?, ??, ?;  and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? %?? ? All????. T?, ??, ?  and B.GRUPO_PRODUTO = ?xDiv ?? ? %?? ? All??,?7 T?, ??, ?&  and B.SUBGRUPO_PRODUTO = ?xDeparment ?? ? %?C? ?
??l?, T?, ??, ?  and A.PRODUTO = ?CPRODUTO ?? ? %?C?  ?
????2 T?, ??, ?!  and A.COR_PRODUTO= ?CCOR_PRODUTO?? ?
 M(?- `??? ?? 	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, ?| ?v 	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	?N ?H 	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, ?7 ?1 	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)?/ ?) 		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)?/ ?) 		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)?/ ?) 		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)?/ ?) 		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)?/ ?) 		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)?/ ?) 		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)?/ ?) 		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)?/ ?) 		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)?0 ?* 		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)?0 ?* 		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)?0 ?* 		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)?0 ?* 		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)?0 ?* 		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)?0 ?* 		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)?0 ?* 		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)?0 ?* 		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)?0 ?* 		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)?0 ?* 		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)?0 ?* 		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)?0 ?* 		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)?0 ?* 		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)?0 ?* 		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)?0 ?* 		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)?0 ?* 		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)?0 ?* 		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)?0 ?* 		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)?0 ?* 		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)?0 ?* 		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)?0 ?* 		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)?0 ?* 		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)?0 ?* 		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)?0 ?* 		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)?0 ?* 		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)?0 ?* 		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)?0 ?* 		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)?0 ?* 		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)?0 ?* 		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)?0 ?* 		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)?0 ?* 		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)?0 ?* 		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)?0 ?* 		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)?7 ?1 		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE ?  ? 	FROM LOJA_VENDA_PRODUTO A?5 ?/ 	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO?\ ?V 	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO?: ?4 	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE?{ ?u 	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA?E ?? 	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL?E ?? 	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA?w ?q 	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO?? ?? 	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO? ? 	WHERE <<XWHERE>>? ?  ? ?P %?C ?- ? Cur_Exportar_Base?& Erro pesquisando dados dos relat?rios.?. 
???? B?-?? ? Q?C? CRS_EXPORTAR_BASEW??? o? Cur_Exportar_Base?? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ??C? ???Q? ??5 ???6 ???? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ???5 ???6 ???? ??? ???0 ???1 ???? CRS_EXPORTAR_BASE?S T?9 ?C? XLS? Salvar Como...? Salvar? ?! Digite o nome do arquivo em Excel??? %?C?9 ???I? B?-?? ? ???-?! T?: ?C? Excel.Application?N?? T?; ?C?: ?< ?= ?? ??C ?9 ?; ?> ?? T?: ?? ?-??' T?: ?@ ?? A3:N3??A ????B ????* T?: ?@ ?? D4?? ?? REFILL FROM POS?? T?: ?@ ?? D4??C ?D ????% T?: ?@ ?? B6?? ??
 From Date:?? T?: ?@ ?? B6??C ?D ???? T?: ?@ ?? B6??C ?E ?a?? T?: ?@ ?? B6??F ????# T?: ?@ ?? C6??G ?? dd/mm/yy?? T?: ?@ ?? C6?? ?? ?? T?: ?@ ?? C6??C ?D ???? T?: ?@ ?? C6??C ?E ?-?? T?: ?@ ?? C6??F ????# T?: ?@ ?? G6?? ?? To Date:?? T?: ?@ ?? G6??C ?D ???? T?: ?@ ?? G6??C ?E ?a?? T?: ?@ ?? G6??F ????# T?: ?@ ?? H6??G ?? dd/mm/yy?? T?: ?@ ?? H6?? ?? ?? T?: ?@ ?? H6??C ?D ???? T?: ?@ ?? H6??C ?E ?-?? T?: ?@ ?? H6??F ????" T?: ?@ ?? L6?? ?? SOH >=:?? T?: ?@ ?? L6??C ?D ???? T?: ?@ ?? L6??C ?E ?a?? T?: ?@ ?? L6??F ???? T?: ?@ ?? M6??G ?? @?? T?: ?@ ?? M6?? ?? ?? T?: ?@ ?? M6??C ?D ???? T?: ?@ ?? M6??C ?E ?-?? T?: ?@ ?? M6??F ????% T?: ?@ ?? B7?? ??
 From Time:?? T?: ?@ ?? B7??C ?D ???? T?: ?@ ?? B7??C ?E ?a?? T?: ?@ ?? B7??F ???? T?: ?@ ?? C7??G ?? @?? T?: ?@ ?? C7?? ??
 ?? T?: ?@ ?? C7??C ?D ???? T?: ?@ ?? C7??C ?E ?-?? T?: ?@ ?? C7??F ????# T?: ?@ ?? G7?? ?? To Time:?? T?: ?@ ?? G7??C ?D ???? T?: ?@ ?? G7??C ?E ?a?? T?: ?@ ?? G7??F ???? T?: ?@ ?? H7??G ?? @?? T?: ?@ ?? H7?? ?? ?? T?: ?@ ?? H7??C ?D ???? T?: ?@ ?? H7??C ?E ?-?? T?: ?@ ?? H7??F ????) T?: ?@ ?? L7?? ?? Units Sold >=:?? T?: ?@ ?? L7??C ?D ???? T?: ?@ ?? L7??C ?E ?a?? T?: ?@ ?? L7??F ???? T?: ?@ ?? M7??G ?? @?? T?: ?@ ?? M7?? ?? ?? T?: ?@ ?? M7??C ?D ???? T?: ?@ ?? M7??C ?E ?-?? T?: ?@ ?? M7??F ???? T?: ?@ ?? B8?? ?? Div:?? T?: ?@ ?? B8??C ?D ???? T?: ?@ ?? B8??C ?E ?a?? T?: ?@ ?? B8??F ???? T?: ?@ ?? C8??G ?? @?? T?: ?@ ?? C8?? ?? ?? T?: ?@ ?? C8??C ?D ???? T?: ?@ ?? C8??C ?E ?-?? T?: ?@ ?? C8??F ????% T?: ?@ ?? G8?? ??
 Deparment:?? T?: ?@ ?? G8??C ?D ???? T?: ?@ ?? G8??C ?E ?a?? T?: ?@ ?? G8??F ???? T?: ?@ ?? H8??G ?? @?? T?: ?@ ?? H8?? ?? ?? T?: ?@ ?? H8??C ?D ???? T?: ?@ ?? H8??C ?E ?-?? T?: ?@ ?? H8??F ????* T?: ?@ ?? L8?? ?? Sub Department:?? T?: ?@ ?? L8??C ?D ???? T?: ?@ ?? L8??C ?E ?a?? T?: ?@ ?? L8??F ???? T?: ?@ ?? M8??G ?? @?? T?: ?@ ?? M8?? ?? ?? T?: ?@ ?? M8??C ?D ???? T?: ?@ ?? M8??C ?E ?-?? T?: ?@ ?? M8??F ????  T?: ?@ ?? B9?? ?? Show:?? T?: ?@ ?? B9??C ?D ???? T?: ?@ ?? B9??C ?E ?a?? T?: ?@ ?? B9??F ???? T?: ?@ ?? C9??G ?? @?? T?: ?@ ?? C9?? ?? ?? T?: ?@ ?? C9??C ?D ???? T?: ?@ ?? C9??C ?E ?-?? T?: ?@ ?? C9??F ????& T?: ?@ ?? G9?? ?? Printed By:?? T?: ?@ ?? G9??C ?D ???? T?: ?@ ?? G9??C ?E ?a?? T?: ?@ ?? G9??F ???? T?: ?@ ?? H9??G ?? @?? T?: ?@ ?? H9?? ?? ?? T?: ?@ ?? H9??C ?D ???? T?: ?@ ?? H9??C ?E ?-?? T?: ?@ ?? H9??F ????) T?: ?@ ?? A10:N10??A ??	??B ???? ??: ?@ ?? A13:N13??H ? T?: ?I ?C ?E ?a?? T?: ?I ?J ?K ???? T?: ?@ ?? A13?? ??  ?? T?: ?@ ?? B13?? ?? Div??& T?: ?@ ?? C13?? ??
 Department??* T?: ?@ ?? D13?? ?? Sub Department??! T?: ?@ ?? E13?? ?? Style?? T?: ?@ ?? F13?? ?? Clr??  T?: ?@ ?? G13?? ?? Size?? T?: ?@ ?? H13?? ?? QC??# T?: ?@ ?? I13?? ?? Item No??, T?: ?@ ?? J13?? ?? Item Description??& T?: ?@ ?? K13?? ??
 Units Sold?? T?: ?@ ?? L13?? ?? SOH??% T?: ?@ ?? M13?? ??	 TOTAL SOH?? T?: ?@ ?? N13?? ?? Bin??# T?: ?@ ?? A13:N13??C ?D ????! T?: ?@ ?? A13:N13??C ?E ?a?? ??: ?@ ?? B13:N13??H ? ??: ?@ ?? B13:N13??L ? T?: ?M ?? A??N ???? T?: ?M ?? B:N??N ???? T?O ???? F?8 ? T?P ?C??Q ??? #)? ~?#*? T?R ?C? A?? ??S ???(??P ??*? T?R ??R ???k T?T ?? oExcel.Range("C?R  CC?O Z?? ").NumberFormat = "CC ?S ??Q ? C? ? @?	 ? #####06? "?? &CMACRO.
= T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Size = 8?? &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Bold = .F.?? &CMACRO.
@ T?T ?? oExcel.Range("C?R  CC?O Z?? ").ColumnWidth = 12?? &CMACRO.
+ T?T ?? CRS_EXPORTAR_BASE.C ?S ??Q ?? CCAMPO = &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Value = CC ?S ??Q ? C? ? "? ?  6CC ?S ??Q ? C? C?U ?? CC?U Z?6CC ?S ??Q ? C? ? "? ?  6?? &CMACRO.
 ?? T?O ??O ??? F?8 ? ?$ %?C? CRS_EXPORTAR_BASEN???+? T?V ?????? ??W ???? T?W ??????? T?W ??????? T?W ???????W T?T ?? oExcel.Range("A13:NCC?O Z??+ ").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)?? &CMACRO.
 ?' ??: ?@ ?? A14:NCC?O ?
Z???X ?Y ?* T?: ?@ ?? K14:LCC?O ?
Z???F ???? T?: ?M ?? C:C??N ???? T?: ?M ?? D:D??N ???? T?: ?M ?? E:E??N ???? T?: ?M ?? F:F??N ???? T?: ?M ?? J:J??N ???? T?: ?M ?? K:K??N ??
?? T?: ?M ?? M:M??N ???? T?: ?M ?? N:N??N ????@ oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
' T?: ?Z ?[ ?\ ?? A1:NCC?O ?
Z??? T?: ?Z ?[ ?] ??	 A$13:N$13?? T?: ?Z ?[ ?^ ???? T?: ?Z ?[ ?_ ???? T?: ?Z ?[ ?` ??P?? T?: ?Z ?[ ?a ??d?? ??: ?@ ?? A4:N4??H ? T?: ?I ?b ?a?? T?: ?I ?F ???? ??: ?c ?d ? ??C?: ?e ?f ?? ??C?: ?f ?? <?: ?3 ??C? Arquivo Gerado Com Sucesso: ?0? Aviso?x?? ??.?^ ??C?! N?o foi Possivel Gerar o Arquivo C? ? Verifique se n?o est? aberto?? Aviso?x?? ?? B?-?? Ug 
 XDATAATUAL SALEPRODUCTS CHKSEARCHTODAY VALUE
 XHORAATAUL CHKHOUR XD_I XD_F TXTSTARTDATE TXTFINISHDATE XH_I TXTSTARTHOUR XH_F TXTFINISHHOUR	 XFROMDATE XTODATE	 XFROMTIME XTOTIME XSOH
 XUNITSSOLD XDIV
 XDEPARMENT XSUBDEPARTMENT XSHOW
 XPRINTEDBY OPTSTOCKINFO GRUPO_PRODUTO QTDE CURSALEPRODUCTS CRS_PESQUISA SUBGRUPO_PRODUTO CPRODUTO CCOR_PRODUTO PRODUTO CURSALEPRODUCTCOLORS COR_PRODUTO MAIN DATA SQLUSERNAME XFILIAL P_FILIAL
 XFILIALEST	 XWHFILTER P_CODIGO_FILIAL XWHERE SSQL	 SQLSELECT TIPO_PRODUTO PRODUTO6 PRODUTO3 GRADE CODIGO_BARRA DESC_PROD_NF QTD_ESTOQUE ESTOQUE CUR_EXPORTAR_BASE CRS_EXPORTAR_BASE XRELEXP OEXCEL	 OWORKBOOK	 WORKBOOKS ADD SAVEAS VISIBLE RANGE BORDERS	 LINESTYLE FONT SIZE BOLD HORIZONTALALIGNMENT NUMBERFORMAT SELECT	 SELECTION INTERIOR
 COLORINDEX
 AUTOFILTER COLUMNS COLUMNWIDTH XLIN XTOTCMP XARRCMP NLETRA XC CMACRO CCAMPO XLSUM LAARRAY ENTIRECOLUMN AUTOFIT ACTIVESHEET	 PAGESETUP	 PRINTAREA PRINTTITLEROWS ORIENTATION FITTOPAGESWIDE ZOOM FITTOPAGESTALL
 MERGECELLS ACTIVEWORKBOOK SAVE APPLICATION QUIT Init,     ??1 11? ? ? ? 11A ?Aq A b1q A 21?Aq A ? ? ? ? ? ? ? ? ?? ? q? ? ? A ????A ????A ???!A ???!A ?Q?!22?A ?Q?2?A B?A BqA ?A !A ? 
??q????????qQ???QQq?
qa A  q A ?u2? q A ? A? r??R???2????2???2????"????????S????????2??????????????????????????S?????????????????????????b??????????Aa??a???1?a?Q?2????? r !Q ? q?? ?? ?? ? ?Q?	? A q A C? ? 111r? A w?????????q?aaaa?1? ? q 2? ?A s 2                       ?H      )   ?5                                                                                      ?DRIVER=winspool
DEVICE=Microsoft XPS Document Writer
OUTPUT=XPSPort:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
COLLATE=1
       d  1  winspool  Microsoft XPS Document Writer  XPSPort:                                                                    9Microsoft XPS Document Writer   ? ??   	 ?4d   X  X  A4                                                            ????GIS4            DINU"  | ???r                            	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                SMTJ     { 0 F 4 1 3 0 D D - 1 9 C 7 - 7 a b 6 - 9 9 A 1 - 9 8 0 F 0 3 B 2 E E 4 E }   InputBin FORMSOURCE RESDLL UniresDLL Interleaving OFF ImageType JPEGMed Orientation PORTRAIT Collate OFF Resolution Option1 PaperSize LETTER ColorMode 24bpp                                         V4DM                                                                                             Courier New                                                   5TITULO=
CRIADOR=
PADRAO=N
PUBLICO=N
FAVORITOS=;
         "EXPORTAR PARA EXCEL"                                         Arial                                                         Courier New                                                   Arial                                                         dataenvironment                                               ?Top = 50
Left = 307
Width = 538
Height = 371
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                                                H?PROCEDURE Init
xDataAtual = SaleProducts.ChkSearchToday.Value
xHoraataul = SaleProducts.chkHour.Value
If xDataAtual
	xD_i = Date()
	xD_f = Date()
Else
	xD_i = SaleProducts.txtStartDate.Value
	xD_f = SaleProducts.txtFinishDate.Value
Endif

If Empty(xD_i) Or Empty(xD_f)
	Messagebox('Favor Informar Faixa de Datas',16,'Aviso')
	Return .F.
Endif

If (xD_f - xD_i) > 7
	Messagebox('A Faixa de Datas maior que 7',16,'Aviso')
	Return .F.
Endif

xH_i = SaleProducts.txtStartHour.Value
xH_f = SaleProducts.txtFinishHour.Value

If Empty(xH_i) Or Empty(xH_f)
	Messagebox('Favor Informar Faixa de Horas',16,'Aviso')
	Return .F.
Endif

xFromDate = xD_i
xToDate   = xD_f
xFromTime = xH_i
xToTime   = xH_f
xSOH  = [1]
xUnitsSold = [1]

xDiv           = [All]
xDeparment     = [All]
xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = [sa]

Do Case
Case Inlist(SaleProducts.optStockInfo.Value,3,4)
	xSOH  = [1]
	xUnitsSold = [1]
Case SaleProducts.optStockInfo.Value = 2
	xSOH  = [0]
	xUnitsSold = [0]
Otherwise
Endcase

Use In Select([CRS_PESQUISA])
Select GRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By GRUPO_PRODUTO Into Cursor CRS_PESQUISA

xDiv           = [All]
If Reccount([CRS_PESQUISA]) = 1
	xDiv = Alltrim(Nvl(CRS_PESQUISA.GRUPO_PRODUTO,[All]))
Endif

Use In Select([CRS_PESQUISA])
Select SUBGRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By SUBGRUPO_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	xDeparment = Alltrim(Nvl(CRS_PESQUISA.SUBGRUPO_PRODUTO,[All]))
ENDIF

STORE [] TO CPRODUTO, CCOR_PRODUTO 

Use In Select([CRS_PESQUISA])
Select PRODUTO From CURSALEPRODUCTCOLORS Group By PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CPRODUTO = Alltrim(CRS_PESQUISA.PRODUTO)
Endif

Use In Select([CRS_PESQUISA])
Select COR_PRODUTO From CURSALEPRODUCTCOLORS Group By COR_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CCOR_PRODUTO = Alltrim(CRS_PESQUISA.COR_PRODUTO)
Endif

Use In Select([CRS_PESQUISA])

xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = Alltrim(Main.Data.SQLUsername)

xFilial    = "'"+Alltrim(Main.p_filial)+"'"
xFilialEst = Alltrim(Main.p_filial)

xWhFilter = "a.DATA_VENDA Between '" + Dtos(xD_i) + "' and '" + Dtos(xD_f)+ "'" + " AND a.codigo_filial='"+Main.p_codigo_filial+"' and b.Qtde<>0"

If SaleProducts.chkHour.Value
	xWhFilter = xWhFilter + " and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between '" + Alltrim(xH_i) + "' and '" + Alltrim(xH_f) + "'"
Endif

XWHERE = [ A.QTDE <> 0 ]
XWHERE = XWHERE + [ AND A.codigo_filial = '] + Main.P_CODIGO_FILIAL + [']
XWHERE = XWHERE + [ AND a.DATA_VENDA Between '] + Dtos(XD_I) + [' and '] + Dtos(XD_F)+ [']

If SALEPRODUCTS.CHKHOUR.Value
	XWHERE = XWHERE + [ and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between '] + Alltrim(XH_I) + [' and '] + Alltrim(XH_F) + [']
Endif

If XDIV != [All]
	XWHERE = XWHERE + [ and B.GRUPO_PRODUTO = ?xDiv ]
ENDIF

If 	XDEPARMENT != [All]
	XWHERE = XWHERE + [ and B.SUBGRUPO_PRODUTO = ?xDeparment ]
Endif

If 	! EMPTY(CPRODUTO)
	XWHERE = XWHERE + [ and A.PRODUTO = ?CPRODUTO ]
Endif

If 	! EMPTY(CCOR_PRODUTO)
	XWHERE = XWHERE + [ and A.COR_PRODUTO= ?CCOR_PRODUTO]
Endif


* NOVA QUERY 
TEXT TO SSQL NOSHOW TEXTMERGE
	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE 
	FROM LOJA_VENDA_PRODUTO A
	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO
	WHERE <<XWHERE>>

ENDTEXT


*!*	TEXT TO SSQL TEXTMERGE NOSHOW
*!*		SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
*!*		B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
*!*		H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
*!*		CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
*!*			 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
*!*			 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
*!*			 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
*!*			 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
*!*			 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
*!*			 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
*!*			 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
*!*			 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
*!*			 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
*!*			 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
*!*			 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
*!*			 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
*!*			 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
*!*			 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
*!*			 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
*!*			 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
*!*			 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
*!*			 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
*!*			 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
*!*			 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
*!*			 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
*!*			 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
*!*			 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
*!*			 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
*!*			 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
*!*			 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
*!*			 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
*!*			 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
*!*			 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
*!*			 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
*!*			 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
*!*			 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
*!*			 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
*!*			 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
*!*			 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
*!*			 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
*!*			 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
*!*			 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
*!*			 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
*!*			 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
*!*			 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
*!*			 ELSE '' END AS INT) AS QTD_ESTOQUE 
*!*		FROM LOJA_VENDA_PRODUTO A
*!*		INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
*!*		INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
*!*		INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
*!*		INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
*!*		INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
*!*		INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
*!*		INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
*!*		WHERE <<XWHERE>>
*!*	ENDTEXT

If !SQLSELECT(SSQL , "Cur_Exportar_Base", "Erro pesquisando dados dos relat?rios.")
	Return .F.
Endif

USE IN SELECT([CRS_EXPORTAR_BASE]) 
SELECT GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, SUM(QTDE) as QTDE, QTD_ESTOQUE,ESTOQUE ;
FROM Cur_Exportar_Base ;
GROUP BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, QTD_ESTOQUE,ESTOQUE ;
ORDER BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, COR_PRODUTO,QTD_ESTOQUE  ;
INTO CURSOR CRS_EXPORTAR_BASE

xRelExp	= Getfile([XLS],'Salvar Como...',[Salvar],0,[Digite o nome do arquivo em Excel])

If Empty(xRelExp)
	Return .F.
Endif

Try

	oExcel 			= Createobject('Excel.Application')
	oWorkbook 		= oExcel.Workbooks.Add()
	oWorkbook.SaveAs(xRelExp)
	oExcel.Visible 	= .F.

	oExcel.Range("A3:N3").BorderS(8).LineStyle = 1

	oExcel.Range("D4").Value = "REFILL FROM POS"
	oExcel.Range("D4").Font.Size = 14

	oExcel.Range("B6").Value = "From Date:"
	oExcel.Range("B6").Font.Size = 8
	oExcel.Range("B6").Font.Bold = .T.
	oExcel.Range("B6").HorizontalAlignment = 2

	oExcel.Range("C6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("C6").Value = xD_i
	oExcel.Range("C6").Font.Size = 8
	oExcel.Range("C6").Font.Bold = .F.
	oExcel.Range("C6").HorizontalAlignment = 2

	oExcel.Range("G6").Value = "To Date:"
	oExcel.Range("G6").Font.Size = 8
	oExcel.Range("G6").Font.Bold = .T.
	oExcel.Range("G6").HorizontalAlignment = 2

	oExcel.Range("H6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("H6").Value = xD_f
	oExcel.Range("H6").Font.Size = 8
	oExcel.Range("H6").Font.Bold = .F.
	oExcel.Range("H6").HorizontalAlignment = 2

	oExcel.Range("L6").Value = "SOH >=:"
	oExcel.Range("L6").Font.Size = 8
	oExcel.Range("L6").Font.Bold = .T.
	oExcel.Range("L6").HorizontalAlignment = 2

	oExcel.Range("M6").NumberFormat = '@'
	oExcel.Range("M6").Value = xSOH
	oExcel.Range("M6").Font.Size = 8
	oExcel.Range("M6").Font.Bold = .F.
	oExcel.Range("M6").HorizontalAlignment = 2


	oExcel.Range("B7").Value = "From Time:"
	oExcel.Range("B7").Font.Size = 8
	oExcel.Range("B7").Font.Bold = .T.
	oExcel.Range("B7").HorizontalAlignment = 2

	oExcel.Range("C7").NumberFormat = '@'
	oExcel.Range("C7").Value = xH_i
	oExcel.Range("C7").Font.Size = 8
	oExcel.Range("C7").Font.Bold = .F.
	oExcel.Range("C7").HorizontalAlignment = 2

	oExcel.Range("G7").Value = "To Time:"
	oExcel.Range("G7").Font.Size = 8
	oExcel.Range("G7").Font.Bold = .T.
	oExcel.Range("G7").HorizontalAlignment = 2

	oExcel.Range("H7").NumberFormat = '@'
	oExcel.Range("H7").Value = xH_f
	oExcel.Range("H7").Font.Size = 8
	oExcel.Range("H7").Font.Bold = .F.
	oExcel.Range("H7").HorizontalAlignment = 2

	oExcel.Range("L7").Value = "Units Sold >=:"
	oExcel.Range("L7").Font.Size = 8
	oExcel.Range("L7").Font.Bold = .T.
	oExcel.Range("L7").HorizontalAlignment = 2

	oExcel.Range("M7").NumberFormat = '@'
	oExcel.Range("M7").Value = xUnitsSold
	oExcel.Range("M7").Font.Size = 8
	oExcel.Range("M7").Font.Bold = .F.
	oExcel.Range("M7").HorizontalAlignment = 2

	oExcel.Range("B8").Value = "Div:"
	oExcel.Range("B8").Font.Size = 8
	oExcel.Range("B8").Font.Bold = .T.
	oExcel.Range("B8").HorizontalAlignment = 2

	oExcel.Range("C8").NumberFormat = '@'
	oExcel.Range("C8").Value = xDiv
	oExcel.Range("C8").Font.Size = 8
	oExcel.Range("C8").Font.Bold = .F.
	oExcel.Range("C8").HorizontalAlignment = 2


	oExcel.Range("G8").Value = "Deparment:"
	oExcel.Range("G8").Font.Size = 8
	oExcel.Range("G8").Font.Bold = .T.
	oExcel.Range("G8").HorizontalAlignment = 2

	oExcel.Range("H8").NumberFormat = '@'
	oExcel.Range("H8").Value = xDeparment
	oExcel.Range("H8").Font.Size = 8
	oExcel.Range("H8").Font.Bold = .F.
	oExcel.Range("H8").HorizontalAlignment = 2

	oExcel.Range("L8").Value = "Sub Department:"
	oExcel.Range("L8").Font.Size = 8
	oExcel.Range("L8").Font.Bold = .T.
	oExcel.Range("L8").HorizontalAlignment = 2

	oExcel.Range("M8").NumberFormat = '@'
	oExcel.Range("M8").Value = xSubDepartment
	oExcel.Range("M8").Font.Size = 8
	oExcel.Range("M8").Font.Bold = .F.
	oExcel.Range("M8").HorizontalAlignment = 2


	oExcel.Range("B9").Value = "Show:"
	oExcel.Range("B9").Font.Size = 8
	oExcel.Range("B9").Font.Bold = .T.
	oExcel.Range("B9").HorizontalAlignment = 2

	oExcel.Range("C9").NumberFormat = '@'
	oExcel.Range("C9").Value = xShow
	oExcel.Range("C9").Font.Size = 8
	oExcel.Range("C9").Font.Bold = .F.
	oExcel.Range("C9").HorizontalAlignment = 2

	oExcel.Range("G9").Value = "Printed By:"
	oExcel.Range("G9").Font.Size = 8
	oExcel.Range("G9").Font.Bold = .T.
	oExcel.Range("G9").HorizontalAlignment = 2

	oExcel.Range("H9").NumberFormat = '@'
	oExcel.Range("H9").Value = xPrintedBy
	oExcel.Range("H9").Font.Size = 8
	oExcel.Range("H9").Font.Bold = .F.
	oExcel.Range("H9").HorizontalAlignment = 2

	oExcel.Range("A10:N10").BorderS(9).LineStyle = 1


	oExcel.Range("A13:N13").Select
	oExcel.Selection.Font.Bold = .T.
	oExcel.Selection.Interior.ColorIndex = 15


*!*	  	***Cabe?alhos
	oExcel.Range("A13").Value = ""
	oExcel.Range("B13").Value = "Div"
	oExcel.Range("C13").Value = "Department"
	oExcel.Range("D13").Value = "Sub Department"
	oExcel.Range("E13").Value = "Style"
	oExcel.Range("F13").Value = "Clr"
	oExcel.Range("G13").Value = "Size"
	oExcel.Range("H13").Value = "QC"
	oExcel.Range("I13").Value = "Item No"
	oExcel.Range("J13").Value = "Item Description"
	oExcel.Range("K13").Value = "Units Sold"
	oExcel.Range("L13").Value = "SOH"
	oExcel.Range("M13").Value = "TOTAL SOH"
	oExcel.Range("N13").Value = "Bin"

	oExcel.Range("A13:N13").Font.Size = 8
	oExcel.Range("A13:N13").Font.Bold = .T.
	oExcel.Range("B13:N13").Select
	oExcel.Range("B13:N13").AutoFilter

	oExcel.Columns("A").ColumnWidth = 2
	oExcel.Columns("B:N").ColumnWidth = 15

*-- Incluir Produtos e Fotos
	xLin=14

	Select CRS_EXPORTAR_BASE
	XTOTCMP = Afields(XARRCMP)
	Go Top
	Scan
		NLETRA = Asc('A')
		For XC = 1 To XTOTCMP
			NLETRA = NLETRA  + 1
			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").NumberFormat = "] + Iif(XARRCMP(XC,2) = 'C', [@], [#####0]) + ["]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Size = 8]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Bold = .F.]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").ColumnWidth = 12]
			&CMACRO.

			CMACRO = [CRS_EXPORTAR_BASE.] + XARRCMP(XC,1)
			CCAMPO = &CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Value = ] + Iif(XARRCMP(XC,2) = 'C', ["], []) +  Iif(XARRCMP(XC,2) = 'C', Alltrim(CCAMPO), Alltrim(Str(CCAMPO))) + Iif(XARRCMP(XC,2) = 'C', ["], [])
			&CMACRO.
		Endfor
		xLin	=	xLin + 1
		Select CRS_EXPORTAR_BASE
	Endscan

 
IF RECCOUNT([CRS_EXPORTAR_BASE]) > 1
	xlsum = -4157
	Local Array LAARRAY(3)
	LAARRAY(1) = 11
	LAARRAY(2) = 12
	LAARRAY(3) = 13

	CMACRO = [oExcel.Range("A13:N] + Alltrim(Str(xLin)) + [").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)]
	&CMACRO.
ENDIF

 

*!*	oExcel.Range("A14:M10000").Subtotal(2, xlsum, @laArray,.T.,.F.,.T.)
*!*	.WrapText = True	
	
	oExcel.Range("A14:N" + Alltrim(Str(xLin+10))).EntireColumn.AutoFit
	oExcel.Range("K14:L" + Alltrim(Str(xLin+10))).HorizontalAlignment = 2

    oExcel.Columns("C:C").ColumnWidth = 15
    oExcel.Columns("D:D").ColumnWidth = 16
    oExcel.Columns("E:E").ColumnWidth = 7
    oExcel.Columns("F:F").ColumnWidth = 6
    oExcel.Columns("J:J").ColumnWidth = 14

    oExcel.Columns("K:K").ColumnWidth = 10
    oExcel.Columns("M:M").ColumnWidth = 11
    oExcel.Columns("N:N").ColumnWidth = 6


	oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
	oExcel.ActiveSheet.PageSetup.PrintArea = ("A1:N" + Alltrim(Str(xLin+10)))
	oExcel.ActiveSheet.PageSetup.PrintTitleRows = "A$13:N$13"
	oExcel.ActiveSheet.PageSetup.Orientation = 2
	oExcel.ActiveSheet.PageSetup.FitToPagesWide = 1
	oExcel.ActiveSheet.PageSetup.Zoom = 80
	oExcel.ActiveSheet.PageSetup.FitToPagesTall = 100
	oExcel.Range("A4:N4").Select
	oExcel.Selection.MergeCells = .T.
	oExcel.Selection.HorizontalAlignment = 3

*-- Fechar
	oExcel.ActiveWorkbook.Save
	oExcel.Application.Quit()
	oExcel.Quit()
	Release oExcel

	Messagebox('Arquivo Gerado Com Sucesso: ',48,'Aviso')
Catch
	Messagebox('N?o foi Possivel Gerar o Arquivo ' + Chr(13) + 'Verifique se n?o est? aberto',16,'Aviso')
Endtry


Return .F.

ENDPROC
        6???    ?5  ?5                        ?   %   ?2      ?5  k  ?2          ?  U  ;. T?  ?? ? ? ?? T? ?? ? ? ?? %??  ??K ? T? ?C$?? T? ?C$?? ?y ? T? ?? ? ? ?? T? ?? ?	 ? ?? ? %?C? ?? C? ???? ?4 ??C? Favor Informar Faixa de Datas?? Aviso?x?? B?-?? ? %?? ? ???$?3 ??C? A Faixa de Datas maior que 7?? Aviso?x?? B?-?? ? T?
 ?? ? ? ?? T? ?? ? ? ?? %?C?
 ?? C? ?????4 ??C? Favor Informar Faixa de Horas?? Aviso?x?? B?-?? ? T? ?? ?? T? ?? ?? T? ??
 ?? T? ?? ?? T? ?? 1?? T? ?? 1?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? sa?? H?Q??? ?C? ? ? ??????? T? ?? 1?? T? ?? 1?? ?? ? ? ????? T? ?? 0?? T? ?? 0?? 2??? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? T? ?? All?? %?C? CRS_PESQUISAN???f? T? ?CC? ? ? Allқ?? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?CC? ? ? Allқ?? ? J??  ?(? ?  ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??! ????! ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?C? ?! ??? ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??# ????# ???? CRS_PESQUISA? %?C? CRS_PESQUISAN???? T?  ?C? ?# ??? ? Q?C? CRS_PESQUISAW?? T? ?? All?? T? ?? All?? T? ?C?$ ?% ?& ??? T?' ?? 'C?$ ?( ?? '?? T?) ?C?$ ?( ???s T?* ?? a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?  AND a.codigo_filial='?$ ?+ ? ' and b.Qtde<>0?? %?? ? ? ????h T?* ??* ?;  and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? T?, ??  A.QTDE <> 0 ??5 T?, ??, ?  AND A.codigo_filial = '?$ ?+ ? '??H T?, ??, ?  AND a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?? %?? ? ? ????h T?, ??, ?;  and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? %?? ? All????. T?, ??, ?  and B.GRUPO_PRODUTO = ?xDiv ?? ? %?? ? All??,?7 T?, ??, ?&  and B.SUBGRUPO_PRODUTO = ?xDeparment ?? ? %?C? ?
??l?, T?, ??, ?  and A.PRODUTO = ?CPRODUTO ?? ? %?C?  ?
????2 T?, ??, ?!  and A.COR_PRODUTO= ?CCOR_PRODUTO?? ?
 M(?- `??? ?? 	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, ?| ?v 	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	?N ?H 	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, ?7 ?1 	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)?/ ?) 		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)?/ ?) 		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)?/ ?) 		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)?/ ?) 		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)?/ ?) 		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)?/ ?) 		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)?/ ?) 		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)?/ ?) 		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)?0 ?* 		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)?0 ?* 		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)?0 ?* 		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)?0 ?* 		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)?0 ?* 		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)?0 ?* 		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)?0 ?* 		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)?0 ?* 		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)?0 ?* 		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)?0 ?* 		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)?0 ?* 		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)?0 ?* 		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)?0 ?* 		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)?0 ?* 		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)?0 ?* 		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)?0 ?* 		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)?0 ?* 		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)?0 ?* 		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)?0 ?* 		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)?0 ?* 		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)?0 ?* 		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)?0 ?* 		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)?0 ?* 		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)?0 ?* 		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)?0 ?* 		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)?0 ?* 		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)?0 ?* 		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)?0 ?* 		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)?0 ?* 		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)?0 ?* 		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)?0 ?* 		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)?0 ?* 		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)?0 ?* 		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)?7 ?1 		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE ?  ? 	FROM LOJA_VENDA_PRODUTO A?5 ?/ 	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO?\ ?V 	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO?: ?4 	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE?{ ?u 	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA?E ?? 	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL?E ?? 	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA?w ?q 	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO?? ?? 	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO? ? 	WHERE <<XWHERE>>? ?  ? ?P %?C ?- ? Cur_Exportar_Base?& Erro pesquisando dados dos relat?rios.?. 
???? B?-?? ? Q?C? CRS_EXPORTAR_BASEW??? o? Cur_Exportar_Base?? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ??C? ???Q? ??5 ???6 ???? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ???5 ???6 ???? ??? ???/ ???0 ???1 ???# ???5 ???? CRS_EXPORTAR_BASE?S T?9 ?C? XLS? Salvar Como...? Salvar? ?! Digite o nome do arquivo em Excel??? %?C?9 ???[? B?-?? ? ???-?! T?: ?C? Excel.Application?N?? T?; ?C?: ?< ?= ?? ??C ?9 ?; ?> ?? T?: ?? ?-??' T?: ?@ ?? A3:N3??A ????B ????* T?: ?@ ?? D4?? ?? REFILL FROM POS?? T?: ?@ ?? D4??C ?D ????% T?: ?@ ?? B6?? ??
 From Date:?? T?: ?@ ?? B6??C ?D ???? T?: ?@ ?? B6??C ?E ?a?? T?: ?@ ?? B6??F ????# T?: ?@ ?? C6??G ?? dd/mm/yy?? T?: ?@ ?? C6?? ?? ?? T?: ?@ ?? C6??C ?D ???? T?: ?@ ?? C6??C ?E ?-?? T?: ?@ ?? C6??F ????# T?: ?@ ?? G6?? ?? To Date:?? T?: ?@ ?? G6??C ?D ???? T?: ?@ ?? G6??C ?E ?a?? T?: ?@ ?? G6??F ????# T?: ?@ ?? H6??G ?? dd/mm/yy?? T?: ?@ ?? H6?? ?? ?? T?: ?@ ?? H6??C ?D ???? T?: ?@ ?? H6??C ?E ?-?? T?: ?@ ?? H6??F ????" T?: ?@ ?? L6?? ?? SOH >=:?? T?: ?@ ?? L6??C ?D ???? T?: ?@ ?? L6??C ?E ?a?? T?: ?@ ?? L6??F ???? T?: ?@ ?? M6??G ?? @?? T?: ?@ ?? M6?? ?? ?? T?: ?@ ?? M6??C ?D ???? T?: ?@ ?? M6??C ?E ?-?? T?: ?@ ?? M6??F ????% T?: ?@ ?? B7?? ??
 From Time:?? T?: ?@ ?? B7??C ?D ???? T?: ?@ ?? B7??C ?E ?a?? T?: ?@ ?? B7??F ???? T?: ?@ ?? C7??G ?? @?? T?: ?@ ?? C7?? ??
 ?? T?: ?@ ?? C7??C ?D ???? T?: ?@ ?? C7??C ?E ?-?? T?: ?@ ?? C7??F ????# T?: ?@ ?? G7?? ?? To Time:?? T?: ?@ ?? G7??C ?D ???? T?: ?@ ?? G7??C ?E ?a?? T?: ?@ ?? G7??F ???? T?: ?@ ?? H7??G ?? @?? T?: ?@ ?? H7?? ?? ?? T?: ?@ ?? H7??C ?D ???? T?: ?@ ?? H7??C ?E ?-?? T?: ?@ ?? H7??F ????) T?: ?@ ?? L7?? ?? Units Sold >=:?? T?: ?@ ?? L7??C ?D ???? T?: ?@ ?? L7??C ?E ?a?? T?: ?@ ?? L7??F ???? T?: ?@ ?? M7??G ?? @?? T?: ?@ ?? M7?? ?? ?? T?: ?@ ?? M7??C ?D ???? T?: ?@ ?? M7??C ?E ?-?? T?: ?@ ?? M7??F ???? T?: ?@ ?? B8?? ?? Div:?? T?: ?@ ?? B8??C ?D ???? T?: ?@ ?? B8??C ?E ?a?? T?: ?@ ?? B8??F ???? T?: ?@ ?? C8??G ?? @?? T?: ?@ ?? C8?? ?? ?? T?: ?@ ?? C8??C ?D ???? T?: ?@ ?? C8??C ?E ?-?? T?: ?@ ?? C8??F ????% T?: ?@ ?? G8?? ??
 Deparment:?? T?: ?@ ?? G8??C ?D ???? T?: ?@ ?? G8??C ?E ?a?? T?: ?@ ?? G8??F ???? T?: ?@ ?? H8??G ?? @?? T?: ?@ ?? H8?? ?? ?? T?: ?@ ?? H8??C ?D ???? T?: ?@ ?? H8??C ?E ?-?? T?: ?@ ?? H8??F ????* T?: ?@ ?? L8?? ?? Sub Department:?? T?: ?@ ?? L8??C ?D ???? T?: ?@ ?? L8??C ?E ?a?? T?: ?@ ?? L8??F ???? T?: ?@ ?? M8??G ?? @?? T?: ?@ ?? M8?? ?? ?? T?: ?@ ?? M8??C ?D ???? T?: ?@ ?? M8??C ?E ?-?? T?: ?@ ?? M8??F ????  T?: ?@ ?? B9?? ?? Show:?? T?: ?@ ?? B9??C ?D ???? T?: ?@ ?? B9??C ?E ?a?? T?: ?@ ?? B9??F ???? T?: ?@ ?? C9??G ?? @?? T?: ?@ ?? C9?? ?? ?? T?: ?@ ?? C9??C ?D ???? T?: ?@ ?? C9??C ?E ?-?? T?: ?@ ?? C9??F ????& T?: ?@ ?? G9?? ?? Printed By:?? T?: ?@ ?? G9??C ?D ???? T?: ?@ ?? G9??C ?E ?a?? T?: ?@ ?? G9??F ???? T?: ?@ ?? H9??G ?? @?? T?: ?@ ?? H9?? ?? ?? T?: ?@ ?? H9??C ?D ???? T?: ?@ ?? H9??C ?E ?-?? T?: ?@ ?? H9??F ????) T?: ?@ ?? A10:N10??A ??	??B ???? ??: ?@ ?? A13:N13??H ? T?: ?I ?C ?E ?a?? T?: ?I ?J ?K ???? T?: ?@ ?? A13?? ??  ?? T?: ?@ ?? B13?? ?? Div??& T?: ?@ ?? C13?? ??
 Department??* T?: ?@ ?? D13?? ?? Sub Department??! T?: ?@ ?? E13?? ?? Style?? T?: ?@ ?? F13?? ?? Clr??  T?: ?@ ?? G13?? ?? Size?? T?: ?@ ?? H13?? ?? QC??# T?: ?@ ?? I13?? ?? Item No??, T?: ?@ ?? J13?? ?? Item Description??& T?: ?@ ?? K13?? ??
 Units Sold?? T?: ?@ ?? L13?? ?? SOH??% T?: ?@ ?? M13?? ??	 TOTAL SOH?? T?: ?@ ?? N13?? ?? Bin??# T?: ?@ ?? A13:N13??C ?D ????! T?: ?@ ?? A13:N13??C ?E ?a?? ??: ?@ ?? B13:N13??H ? ??: ?@ ?? B13:N13??L ? T?: ?M ?? A??N ???? T?: ?M ?? B:N??N ???? T?O ???? F?8 ? T?P ?C??Q ??? #)? ~?5*? T?R ?C? A?? ??S ???(??P ??*? T?R ??R ???k T?T ?? oExcel.Range("C?R  CC?O Z?? ").NumberFormat = "CC ?S ??Q ? C? ? @?	 ? #####06? "?? &CMACRO.
= T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Size = 8?? &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Bold = .F.?? &CMACRO.
@ T?T ?? oExcel.Range("C?R  CC?O Z?? ").ColumnWidth = 12?? &CMACRO.
+ T?T ?? CRS_EXPORTAR_BASE.C ?S ??Q ?? CCAMPO = &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Value = CC ?S ??Q ? C? ? "? ?  6CC ?S ??Q ? C? C?U ?? CC?U Z?6CC ?S ??Q ? C? ? "? ?  6?? &CMACRO.
 ?? T?O ??O ??? F?8 ? ?$ %?C? CRS_EXPORTAR_BASEN???+? T?V ?????? ??W ???? T?W ??????? T?W ??????? T?W ???????W T?T ?? oExcel.Range("A13:NCC?O Z??+ ").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)?? &CMACRO.
 ?' ??: ?@ ?? A14:NCC?O ?
Z???X ?Y ?* T?: ?@ ?? K14:LCC?O ?
Z???F ???? T?: ?M ?? C:C??N ???? T?: ?M ?? D:D??N ???? T?: ?M ?? E:E??N ???? T?: ?M ?? F:F??N ???? T?: ?M ?? J:J??N ???? T?: ?M ?? K:K??N ??
?? T?: ?M ?? M:M??N ???? T?: ?M ?? N:N??N ????@ oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
' T?: ?Z ?[ ?\ ?? A1:NCC?O ?
Z??? T?: ?Z ?[ ?] ??	 A$13:N$13?? T?: ?Z ?[ ?^ ???? T?: ?Z ?[ ?_ ???? T?: ?Z ?[ ?` ??P?? T?: ?Z ?[ ?a ??d?? ??: ?@ ?? A4:N4??H ? T?: ?I ?b ?a?? T?: ?I ?F ???? ??: ?c ?d ? ??C?: ?e ?f ?? ??C?: ?f ?? <?: ?3 ??C? Arquivo Gerado Com Sucesso: ?0? Aviso?x?? ??-.?^ ??C?! N?o foi Possivel Gerar o Arquivo C? ? Verifique se n?o est? aberto?? Aviso?x?? ?? B?-?? Ug 
 XDATAATUAL SALEPRODUCTS CHKSEARCHTODAY VALUE
 XHORAATAUL CHKHOUR XD_I XD_F TXTSTARTDATE TXTFINISHDATE XH_I TXTSTARTHOUR XH_F TXTFINISHHOUR	 XFROMDATE XTODATE	 XFROMTIME XTOTIME XSOH
 XUNITSSOLD XDIV
 XDEPARMENT XSUBDEPARTMENT XSHOW
 XPRINTEDBY OPTSTOCKINFO GRUPO_PRODUTO QTDE CURSALEPRODUCTS CRS_PESQUISA SUBGRUPO_PRODUTO CPRODUTO CCOR_PRODUTO PRODUTO CURSALEPRODUCTCOLORS COR_PRODUTO MAIN DATA SQLUSERNAME XFILIAL P_FILIAL
 XFILIALEST	 XWHFILTER P_CODIGO_FILIAL XWHERE SSQL	 SQLSELECT TIPO_PRODUTO PRODUTO6 PRODUTO3 GRADE CODIGO_BARRA DESC_PROD_NF QTD_ESTOQUE ESTOQUE CUR_EXPORTAR_BASE CRS_EXPORTAR_BASE XRELEXP OEXCEL	 OWORKBOOK	 WORKBOOKS ADD SAVEAS VISIBLE RANGE BORDERS	 LINESTYLE FONT SIZE BOLD HORIZONTALALIGNMENT NUMBERFORMAT SELECT	 SELECTION INTERIOR
 COLORINDEX
 AUTOFILTER COLUMNS COLUMNWIDTH XLIN XTOTCMP XARRCMP NLETRA XC CMACRO CCAMPO XLSUM LAARRAY ENTIRECOLUMN AUTOFIT ACTIVESHEET	 PAGESETUP	 PRINTAREA PRINTTITLEROWS ORIENTATION FITTOPAGESWIDE ZOOM FITTOPAGESTALL
 MERGECELLS ACTIVEWORKBOOK SAVE APPLICATION QUIT Init,     ??1 11? ? ? ? 11A ?Aq A b1q A 21?Aq A ? ? ? ? ? ? ? ? ?? ? q? ? ? A ????A ????A ???!A ???!A ?Q?!22?A ?Q?2?A B?A BqA ?A !A ? 
??q????????qQ???QQq?
qa A  q A ??2? q A ? A? r??R???2????2???2????"????????S????????2??????????????????????????S?????????????????????????b??????????Aa??a???1?a?Q?2????? r !Q ? q?? ?? ?? ? ?Q?	? A q A C? ? 111r? A w?????????q?aaaa?1? ? q 2? ?A s 2                       ?H      )   ?5                                                                    ?DRIVER=winspool
DEVICE=Microsoft XPS Document Writer
OUTPUT=XPSPort:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
COLLATE=1
       d  1  winspool  Microsoft XPS Document Writer  XPSPort:                                                                    9Microsoft XPS Document Writer   ? ??   	 ?4d   X  X  A4                                                            ????GIS4            DINU"  | ???r                            	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                SMTJ     { 0 F 4 1 3 0 D D - 1 9 C 7 - 7 a b 6 - 9 9 A 1 - 9 8 0 F 0 3 B 2 E E 4 E }   InputBin FORMSOURCE RESDLL UniresDLL Interleaving OFF ImageType JPEGMed Orientation PORTRAIT Collate OFF Resolution Option1 PaperSize LETTER ColorMode 24bpp                                         V4DM                                                                                             Courier New                                                   5TITULO=
CRIADOR=
PADRAO=N
PUBLICO=N
FAVORITOS=;
         "EXPORTAR PARA EXCEL"                                         Arial                                                         Courier New                                                   Arial                                                         dataenvironment                                               ?Top = 50
Left = 307
Width = 538
Height = 371
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                                                H?PROCEDURE Init
xDataAtual = SaleProducts.ChkSearchToday.Value
xHoraataul = SaleProducts.chkHour.Value
If xDataAtual
	xD_i = Date()
	xD_f = Date()
Else
	xD_i = SaleProducts.txtStartDate.Value
	xD_f = SaleProducts.txtFinishDate.Value
Endif

If Empty(xD_i) Or Empty(xD_f)
	Messagebox('Favor Informar Faixa de Datas',16,'Aviso')
	Return .F.
Endif

If (xD_f - xD_i) > 7
	Messagebox('A Faixa de Datas maior que 7',16,'Aviso')
	Return .F.
Endif

xH_i = SaleProducts.txtStartHour.Value
xH_f = SaleProducts.txtFinishHour.Value

If Empty(xH_i) Or Empty(xH_f)
	Messagebox('Favor Informar Faixa de Horas',16,'Aviso')
	Return .F.
Endif

xFromDate = xD_i
xToDate   = xD_f
xFromTime = xH_i
xToTime   = xH_f
xSOH  = [1]
xUnitsSold = [1]

xDiv           = [All]
xDeparment     = [All]
xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = [sa]

Do Case
Case Inlist(SaleProducts.optStockInfo.Value,3,4)
	xSOH  = [1]
	xUnitsSold = [1]
Case SaleProducts.optStockInfo.Value = 2
	xSOH  = [0]
	xUnitsSold = [0]
Otherwise
Endcase

Use In Select([CRS_PESQUISA])
Select GRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By GRUPO_PRODUTO Into Cursor CRS_PESQUISA

xDiv           = [All]
If Reccount([CRS_PESQUISA]) = 1
	xDiv = Alltrim(Nvl(CRS_PESQUISA.GRUPO_PRODUTO,[All]))
Endif

Use In Select([CRS_PESQUISA])
Select SUBGRUPO_PRODUTO,Count(*) As QTDE From CURSALEPRODUCTS Group By SUBGRUPO_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	xDeparment = Alltrim(Nvl(CRS_PESQUISA.SUBGRUPO_PRODUTO,[All]))
ENDIF

STORE [] TO CPRODUTO, CCOR_PRODUTO 

Use In Select([CRS_PESQUISA])
Select PRODUTO From CURSALEPRODUCTCOLORS Group By PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CPRODUTO = Alltrim(CRS_PESQUISA.PRODUTO)
Endif

Use In Select([CRS_PESQUISA])
Select COR_PRODUTO From CURSALEPRODUCTCOLORS Group By COR_PRODUTO Into Cursor CRS_PESQUISA
If Reccount([CRS_PESQUISA]) = 1
	CCOR_PRODUTO = Alltrim(CRS_PESQUISA.COR_PRODUTO)
Endif

Use In Select([CRS_PESQUISA])

xSubDepartment = [All]
xShow          = [All]
xPrintedBy     = Alltrim(Main.Data.SQLUsername)

xFilial    = "'"+Alltrim(Main.p_filial)+"'"
xFilialEst = Alltrim(Main.p_filial)

xWhFilter = "a.DATA_VENDA Between '" + Dtos(xD_i) + "' and '" + Dtos(xD_f)+ "'" + " AND a.codigo_filial='"+Main.p_codigo_filial+"' and b.Qtde<>0"

If SaleProducts.chkHour.Value
	xWhFilter = xWhFilter + " and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between '" + Alltrim(xH_i) + "' and '" + Alltrim(xH_f) + "'"
Endif

XWHERE = [ A.QTDE <> 0 ]
XWHERE = XWHERE + [ AND A.codigo_filial = '] + Main.P_CODIGO_FILIAL + [']
XWHERE = XWHERE + [ AND a.DATA_VENDA Between '] + Dtos(XD_I) + [' and '] + Dtos(XD_F)+ [']

If SALEPRODUCTS.CHKHOUR.Value
	XWHERE = XWHERE + [ and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between '] + Alltrim(XH_I) + [' and '] + Alltrim(XH_F) + [']
Endif

If XDIV != [All]
	XWHERE = XWHERE + [ and B.GRUPO_PRODUTO = ?xDiv ]
ENDIF

If 	XDEPARMENT != [All]
	XWHERE = XWHERE + [ and B.SUBGRUPO_PRODUTO = ?xDeparment ]
Endif

If 	! EMPTY(CPRODUTO)
	XWHERE = XWHERE + [ and A.PRODUTO = ?CPRODUTO ]
Endif

If 	! EMPTY(CCOR_PRODUTO)
	XWHERE = XWHERE + [ and A.COR_PRODUTO= ?CCOR_PRODUTO]
Endif


* NOVA QUERY 
TEXT TO SSQL NOSHOW TEXTMERGE
	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE 
	FROM LOJA_VENDA_PRODUTO A
	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO
	WHERE <<XWHERE>>

ENDTEXT


*!*	TEXT TO SSQL TEXTMERGE NOSHOW
*!*		SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, 
*!*		B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	
*!*		H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, 
*!*		CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)
*!*			 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)
*!*			 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)
*!*			 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)
*!*			 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)
*!*			 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)
*!*			 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)
*!*			 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)
*!*			 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)
*!*			 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)
*!*			 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)
*!*			 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)
*!*			 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)
*!*			 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)
*!*			 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)
*!*			 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)
*!*			 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)
*!*			 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)
*!*			 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)
*!*			 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)
*!*			 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)
*!*			 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)
*!*			 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)
*!*			 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)
*!*			 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)
*!*			 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)
*!*			 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)
*!*			 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)
*!*			 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)
*!*			 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)
*!*			 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)
*!*			 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)
*!*			 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)
*!*			 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)
*!*			 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)
*!*			 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)
*!*			 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)
*!*			 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)
*!*			 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)
*!*			 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)
*!*			 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)
*!*			 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)
*!*			 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)
*!*			 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)
*!*			 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)
*!*			 ELSE '' END AS INT) AS QTD_ESTOQUE 
*!*		FROM LOJA_VENDA_PRODUTO A
*!*		INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO
*!*		INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO
*!*		INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE
*!*		INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA
*!*		INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL
*!*		INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA
*!*		INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO
*!*		WHERE <<XWHERE>>
*!*	ENDTEXT

If !SQLSELECT(SSQL , "Cur_Exportar_Base", "Erro pesquisando dados dos relat?rios.")
	Return .F.
Endif

USE IN SELECT([CRS_EXPORTAR_BASE]) 
SELECT GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, SUM(QTDE) as QTDE, QTD_ESTOQUE,ESTOQUE ;
FROM Cur_Exportar_Base ;
GROUP BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, GRADE, COR_PRODUTO, CODIGO_BARRA, DESC_PROD_NF, QTD_ESTOQUE,ESTOQUE ;
ORDER BY GRUPO_PRODUTO, SUBGRUPO_PRODUTO, TIPO_PRODUTO, PRODUTO6, PRODUTO3, COR_PRODUTO,QTD_ESTOQUE  ;
INTO CURSOR CRS_EXPORTAR_BASE

xRelExp	= Getfile([XLS],'Salvar Como...',[Salvar],0,[Digite o nome do arquivo em Excel])

If Empty(xRelExp)
	Return .F.
Endif

Try

	oExcel 			= Createobject('Excel.Application')
	oWorkbook 		= oExcel.Workbooks.Add()
	oWorkbook.SaveAs(xRelExp)
	oExcel.Visible 	= .F.

	oExcel.Range("A3:N3").BorderS(8).LineStyle = 1

	oExcel.Range("D4").Value = "REFILL FROM POS"
	oExcel.Range("D4").Font.Size = 14

	oExcel.Range("B6").Value = "From Date:"
	oExcel.Range("B6").Font.Size = 8
	oExcel.Range("B6").Font.Bold = .T.
	oExcel.Range("B6").HorizontalAlignment = 2

	oExcel.Range("C6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("C6").Value = xD_i
	oExcel.Range("C6").Font.Size = 8
	oExcel.Range("C6").Font.Bold = .F.
	oExcel.Range("C6").HorizontalAlignment = 2

	oExcel.Range("G6").Value = "To Date:"
	oExcel.Range("G6").Font.Size = 8
	oExcel.Range("G6").Font.Bold = .T.
	oExcel.Range("G6").HorizontalAlignment = 2

	oExcel.Range("H6").NumberFormat = 'dd/mm/yy'
	oExcel.Range("H6").Value = xD_f
	oExcel.Range("H6").Font.Size = 8
	oExcel.Range("H6").Font.Bold = .F.
	oExcel.Range("H6").HorizontalAlignment = 2

	oExcel.Range("L6").Value = "SOH >=:"
	oExcel.Range("L6").Font.Size = 8
	oExcel.Range("L6").Font.Bold = .T.
	oExcel.Range("L6").HorizontalAlignment = 2

	oExcel.Range("M6").NumberFormat = '@'
	oExcel.Range("M6").Value = xSOH
	oExcel.Range("M6").Font.Size = 8
	oExcel.Range("M6").Font.Bold = .F.
	oExcel.Range("M6").HorizontalAlignment = 2


	oExcel.Range("B7").Value = "From Time:"
	oExcel.Range("B7").Font.Size = 8
	oExcel.Range("B7").Font.Bold = .T.
	oExcel.Range("B7").HorizontalAlignment = 2

	oExcel.Range("C7").NumberFormat = '@'
	oExcel.Range("C7").Value = xH_i
	oExcel.Range("C7").Font.Size = 8
	oExcel.Range("C7").Font.Bold = .F.
	oExcel.Range("C7").HorizontalAlignment = 2

	oExcel.Range("G7").Value = "To Time:"
	oExcel.Range("G7").Font.Size = 8
	oExcel.Range("G7").Font.Bold = .T.
	oExcel.Range("G7").HorizontalAlignment = 2

	oExcel.Range("H7").NumberFormat = '@'
	oExcel.Range("H7").Value = xH_f
	oExcel.Range("H7").Font.Size = 8
	oExcel.Range("H7").Font.Bold = .F.
	oExcel.Range("H7").HorizontalAlignment = 2

	oExcel.Range("L7").Value = "Units Sold >=:"
	oExcel.Range("L7").Font.Size = 8
	oExcel.Range("L7").Font.Bold = .T.
	oExcel.Range("L7").HorizontalAlignment = 2

	oExcel.Range("M7").NumberFormat = '@'
	oExcel.Range("M7").Value = xUnitsSold
	oExcel.Range("M7").Font.Size = 8
	oExcel.Range("M7").Font.Bold = .F.
	oExcel.Range("M7").HorizontalAlignment = 2

	oExcel.Range("B8").Value = "Div:"
	oExcel.Range("B8").Font.Size = 8
	oExcel.Range("B8").Font.Bold = .T.
	oExcel.Range("B8").HorizontalAlignment = 2

	oExcel.Range("C8").NumberFormat = '@'
	oExcel.Range("C8").Value = xDiv
	oExcel.Range("C8").Font.Size = 8
	oExcel.Range("C8").Font.Bold = .F.
	oExcel.Range("C8").HorizontalAlignment = 2


	oExcel.Range("G8").Value = "Deparment:"
	oExcel.Range("G8").Font.Size = 8
	oExcel.Range("G8").Font.Bold = .T.
	oExcel.Range("G8").HorizontalAlignment = 2

	oExcel.Range("H8").NumberFormat = '@'
	oExcel.Range("H8").Value = xDeparment
	oExcel.Range("H8").Font.Size = 8
	oExcel.Range("H8").Font.Bold = .F.
	oExcel.Range("H8").HorizontalAlignment = 2

	oExcel.Range("L8").Value = "Sub Department:"
	oExcel.Range("L8").Font.Size = 8
	oExcel.Range("L8").Font.Bold = .T.
	oExcel.Range("L8").HorizontalAlignment = 2

	oExcel.Range("M8").NumberFormat = '@'
	oExcel.Range("M8").Value = xSubDepartment
	oExcel.Range("M8").Font.Size = 8
	oExcel.Range("M8").Font.Bold = .F.
	oExcel.Range("M8").HorizontalAlignment = 2


	oExcel.Range("B9").Value = "Show:"
	oExcel.Range("B9").Font.Size = 8
	oExcel.Range("B9").Font.Bold = .T.
	oExcel.Range("B9").HorizontalAlignment = 2

	oExcel.Range("C9").NumberFormat = '@'
	oExcel.Range("C9").Value = xShow
	oExcel.Range("C9").Font.Size = 8
	oExcel.Range("C9").Font.Bold = .F.
	oExcel.Range("C9").HorizontalAlignment = 2

	oExcel.Range("G9").Value = "Printed By:"
	oExcel.Range("G9").Font.Size = 8
	oExcel.Range("G9").Font.Bold = .T.
	oExcel.Range("G9").HorizontalAlignment = 2

	oExcel.Range("H9").NumberFormat = '@'
	oExcel.Range("H9").Value = xPrintedBy
	oExcel.Range("H9").Font.Size = 8
	oExcel.Range("H9").Font.Bold = .F.
	oExcel.Range("H9").HorizontalAlignment = 2

	oExcel.Range("A10:N10").BorderS(9).LineStyle = 1


	oExcel.Range("A13:N13").Select
	oExcel.Selection.Font.Bold = .T.
	oExcel.Selection.Interior.ColorIndex = 15


*!*	  	***Cabe?alhos
	oExcel.Range("A13").Value = ""
	oExcel.Range("B13").Value = "Div"
	oExcel.Range("C13").Value = "Department"
	oExcel.Range("D13").Value = "Sub Department"
	oExcel.Range("E13").Value = "Style"
	oExcel.Range("F13").Value = "Clr"
	oExcel.Range("G13").Value = "Size"
	oExcel.Range("H13").Value = "QC"
	oExcel.Range("I13").Value = "Item No"
	oExcel.Range("J13").Value = "Item Description"
	oExcel.Range("K13").Value = "Units Sold"
	oExcel.Range("L13").Value = "SOH"
	oExcel.Range("M13").Value = "TOTAL SOH"
	oExcel.Range("N13").Value = "Bin"

	oExcel.Range("A13:N13").Font.Size = 8
	oExcel.Range("A13:N13").Font.Bold = .T.
	oExcel.Range("B13:N13").Select
	oExcel.Range("B13:N13").AutoFilter

	oExcel.Columns("A").ColumnWidth = 2
	oExcel.Columns("B:N").ColumnWidth = 15

*-- Incluir Produtos e Fotos
	xLin=14

	Select CRS_EXPORTAR_BASE
	XTOTCMP = Afields(XARRCMP)
	Go Top
	Scan
		NLETRA = Asc('A')
		For XC = 1 To XTOTCMP
			NLETRA = NLETRA  + 1
			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").NumberFormat = "] + Iif(XARRCMP(XC,2) = 'C', [@], [#####0]) + ["]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Size = 8]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Font.Bold = .F.]
			&CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").ColumnWidth = 12]
			&CMACRO.

			CMACRO = [CRS_EXPORTAR_BASE.] + XARRCMP(XC,1)
			CCAMPO = &CMACRO.

			CMACRO = [oExcel.Range("] + Chr(NLETRA) + Alltrim(Str(xLin)) + [").Value = ] + Iif(XARRCMP(XC,2) = 'C', ["], []) +  Iif(XARRCMP(XC,2) = 'C', Alltrim(CCAMPO), Alltrim(Str(CCAMPO))) + Iif(XARRCMP(XC,2) = 'C', ["], [])
			&CMACRO.
		Endfor
		xLin	=	xLin + 1
		Select CRS_EXPORTAR_BASE
	Endscan

 
IF RECCOUNT([CRS_EXPORTAR_BASE]) > 1
	xlsum = -4157
	Local Array LAARRAY(3)
	LAARRAY(1) = 11
	LAARRAY(2) = 12
	LAARRAY(3) = 13

	CMACRO = [oExcel.Range("A13:N] + Alltrim(Str(xLin)) + [").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)]
	&CMACRO.
ENDIF

 

*!*	oExcel.Range("A14:M10000").Subtotal(2, xlsum, @laArray,.T.,.F.,.T.)
*!*	.WrapText = True	
	
	oExcel.Range("A14:N" + Alltrim(Str(xLin+10))).EntireColumn.AutoFit
	oExcel.Range("K14:L" + Alltrim(Str(xLin+10))).HorizontalAlignment = 2

    oExcel.Columns("C:C").ColumnWidth = 15
    oExcel.Columns("D:D").ColumnWidth = 16
    oExcel.Columns("E:E").ColumnWidth = 7
    oExcel.Columns("F:F").ColumnWidth = 6
    oExcel.Columns("J:J").ColumnWidth = 14

    oExcel.Columns("K:K").ColumnWidth = 10
    oExcel.Columns("M:M").ColumnWidth = 11
    oExcel.Columns("N:N").ColumnWidth = 6


	oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
	oExcel.ActiveSheet.PageSetup.PrintArea = ("A1:N" + Alltrim(Str(xLin+10)))
	oExcel.ActiveSheet.PageSetup.PrintTitleRows = "A$13:N$13"
	oExcel.ActiveSheet.PageSetup.Orientation = 2
	oExcel.ActiveSheet.PageSetup.FitToPagesWide = 1
	oExcel.ActiveSheet.PageSetup.Zoom = 80
	oExcel.ActiveSheet.PageSetup.FitToPagesTall = 100
	oExcel.Range("A4:N4").Select
	oExcel.Selection.MergeCells = .T.
	oExcel.Selection.HorizontalAlignment = 3

*-- Fechar
	oExcel.ActiveWorkbook.Save
	oExcel.Application.Quit()
	oExcel.Quit()
	Release oExcel

	Messagebox('Arquivo Gerado Com Sucesso: ',48,'Aviso')
Catch
	Messagebox('N?o foi Possivel Gerar o Arquivo ' + Chr(13) + 'Verifique se n?o est? aberto',16,'Aviso')
Endtry


Return .F.

ENDPROC
        6???    ?5  ?5                        ?   %   ?2      ?5  k  ?2          ?  U  ;. T?  ?? ? ? ?? T? ?? ? ? ?? %??  ??K ? T? ?C$?? T? ?C$?? ?y ? T? ?? ? ? ?? T? ?? ?	 ? ?? ? %?C? ?? C? ???? ?4 ??C? Favor Informar Faixa de Datas?? Aviso?x?? B?-?? ? %?? ? ???$?3 ??C? A Faixa de Datas maior que 7?? Aviso?x?? B?-?? ? T?
 ?? ? ? ?? T? ?? ? ? ?? %?C?
 ?? C? ?????4 ??C? Favor Informar Faixa de Horas?? Aviso?x?? B?-?? ? T? ?? ?? T? ?? ?? T? ??
 ?? T? ?? ?? T? ?? 1?? T? ?? 1?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? All?? T? ?? sa?? H?Q??? ?C? ? ? ??????? T? ?? 1?? T? ?? 1?? ?? ? ? ????? T? ?? 0?? T? ?? 0?? 2??? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? T? ?? All?? %?C? CRS_PESQUISAN???f? T? ?CC? ? ? Allқ?? ? Q?C? CRS_PESQUISAW??> o? CURSALEPRODUCTS?? ??C???Q? ??? ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?CC? ? ? Allқ?? ? J??  ?(? ?  ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??! ????! ???? CRS_PESQUISA? %?C? CRS_PESQUISAN????? T? ?C? ?! ??? ? Q?C? CRS_PESQUISAW??8 o? CURSALEPRODUCTCOLORS??# ????# ???? CRS_PESQUISA? %?C? CRS_PESQUISAN???? T?  ?C? ?# ??? ? Q?C? CRS_PESQUISAW?? T? ?? All?? T? ?? All?? T? ?C?$ ?% ?& ??? T?' ?? 'C?$ ?( ?? '?? T?) ?C?$ ?( ???s T?* ?? a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?  AND a.codigo_filial='?$ ?+ ? ' and b.Qtde<>0?? %?? ? ? ????h T?* ??* ?;  and CONVERT(nvarchar(30), A.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? T?, ??  A.QTDE <> 0 ??5 T?, ??, ?  AND A.codigo_filial = '?$ ?+ ? '??H T?, ??, ?  AND a.DATA_VENDA Between 'C? ?? ' and 'C? ?? '?? %?? ? ? ????h T?, ??, ?;  and CONVERT(nvarchar(30), E.DATA_DIGITACAO, 108) between 'C?
 ?? ' and 'C? ?? '?? ? %?? ? All????. T?, ??, ?  and B.GRUPO_PRODUTO = ?xDiv ?? ? %?? ? All??,?7 T?, ??, ?&  and B.SUBGRUPO_PRODUTO = ?xDeparment ?? ? %?C? ?
??l?, T?, ??, ?  and A.PRODUTO = ?CPRODUTO ?? ? %?C?  ?
????2 T?, ??, ?!  and A.COR_PRODUTO= ?CCOR_PRODUTO?? ?
 M(?- `??? ?? 	SELECT B.GRUPO_PRODUTO, cast(LTRIM(RTRIM(ISNULL(B.LINHA,''))) + ' - ' + LTRIM(RTRIM(ISNULL(B.SUBGRUPO_PRODUTO,''))) AS VARCHAR(101)) AS SUBGRUPO_PRODUTO, ?| ?v 	B.TIPO_PRODUTO, LEFT(RTRIM(A.PRODUTO),6) AS PRODUTO6, RIGHT(RTRIM(A.PRODUTO),3) AS PRODUTO3, H.GRADE, A.COR_PRODUTO,	?N ?H 	H.CODIGO_BARRA, B.DESC_PROD_NF,	CAST(ISNULL(A.QTDE,0) AS INT) AS QTDE, ?7 ?1 	CAST(CASE WHEN A.TAMANHO=1  THEN ISNULL(I.ES1,0)?/ ?) 		 WHEN A.TAMANHO=2  THEN ISNULL(I.ES2,0)?/ ?) 		 WHEN A.TAMANHO=3  THEN ISNULL(I.ES3,0)?/ ?) 		 WHEN A.TAMANHO=4  THEN ISNULL(I.ES4,0)?/ ?) 		 WHEN A.TAMANHO=5  THEN ISNULL(I.ES5,0)?/ ?) 		 WHEN A.TAMANHO=6  THEN ISNULL(I.ES6,0)?/ ?) 		 WHEN A.TAMANHO=7  THEN ISNULL(I.ES7,0)?/ ?) 		 WHEN A.TAMANHO=8  THEN ISNULL(I.ES8,0)?/ ?) 		 WHEN A.TAMANHO=9  THEN ISNULL(I.ES9,0)?0 ?* 		 WHEN A.TAMANHO=10 THEN ISNULL(I.ES10,0)?0 ?* 		 WHEN A.TAMANHO=11 THEN ISNULL(I.ES11,0)?0 ?* 		 WHEN A.TAMANHO=12 THEN ISNULL(I.ES12,0)?0 ?* 		 WHEN A.TAMANHO=13 THEN ISNULL(I.ES13,0)?0 ?* 		 WHEN A.TAMANHO=14 THEN ISNULL(I.ES14,0)?0 ?* 		 WHEN A.TAMANHO=15 THEN ISNULL(I.ES15,0)?0 ?* 		 WHEN A.TAMANHO=16 THEN ISNULL(I.ES16,0)?0 ?* 		 WHEN A.TAMANHO=17 THEN ISNULL(I.ES17,0)?0 ?* 		 WHEN A.TAMANHO=18 THEN ISNULL(I.ES18,0)?0 ?* 		 WHEN A.TAMANHO=19 THEN ISNULL(I.ES19,0)?0 ?* 		 WHEN A.TAMANHO=20 THEN ISNULL(I.ES20,0)?0 ?* 		 WHEN A.TAMANHO=21 THEN ISNULL(I.ES21,0)?0 ?* 		 WHEN A.TAMANHO=22 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=23 THEN ISNULL(I.ES23,0)?0 ?* 		 WHEN A.TAMANHO=24 THEN ISNULL(I.ES24,0)?0 ?* 		 WHEN A.TAMANHO=25 THEN ISNULL(I.ES22,0)?0 ?* 		 WHEN A.TAMANHO=26 THEN ISNULL(I.ES26,0)?0 ?* 		 WHEN A.TAMANHO=27 THEN ISNULL(I.ES27,0)?0 ?* 		 WHEN A.TAMANHO=28 THEN ISNULL(I.ES28,0)?0 ?* 		 WHEN A.TAMANHO=29 THEN ISNULL(I.ES29,0)?0 ?* 		 WHEN A.TAMANHO=30 THEN ISNULL(I.ES30,0)?0 ?* 		 WHEN A.TAMANHO=31 THEN ISNULL(I.ES31,0)?0 ?* 		 WHEN A.TAMANHO=32 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=33 THEN ISNULL(I.ES33,0)?0 ?* 		 WHEN A.TAMANHO=34 THEN ISNULL(I.ES34,0)?0 ?* 		 WHEN A.TAMANHO=35 THEN ISNULL(I.ES32,0)?0 ?* 		 WHEN A.TAMANHO=36 THEN ISNULL(I.ES36,0)?0 ?* 		 WHEN A.TAMANHO=37 THEN ISNULL(I.ES37,0)?0 ?* 		 WHEN A.TAMANHO=38 THEN ISNULL(I.ES38,0)?0 ?* 		 WHEN A.TAMANHO=39 THEN ISNULL(I.ES39,0)?0 ?* 		 WHEN A.TAMANHO=40 THEN ISNULL(I.ES40,0)?0 ?* 		 WHEN A.TAMANHO=41 THEN ISNULL(I.ES41,0)?0 ?* 		 WHEN A.TAMANHO=42 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=43 THEN ISNULL(I.ES43,0)?0 ?* 		 WHEN A.TAMANHO=44 THEN ISNULL(I.ES44,0)?0 ?* 		 WHEN A.TAMANHO=45 THEN ISNULL(I.ES42,0)?0 ?* 		 WHEN A.TAMANHO=46 THEN ISNULL(I.ES46,0)?0 ?* 		 WHEN A.TAMANHO=47 THEN ISNULL(I.ES47,0)?0 ?* 		 WHEN A.TAMANHO=48 THEN ISNULL(I.ES48,0)?7 ?1 		 ELSE '' END AS INT) AS QTD_ESTOQUE,ST.ESTOQUE ?  ? 	FROM LOJA_VENDA_PRODUTO A?5 ?/ 	INNER JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO?\ ?V 	INNER JOIN PRODUTO_CORES C ON A.PRODUTO = C.PRODUTO AND A.COR_PRODUTO = C.COR_PRODUTO?: ?4 	INNER JOIN PRODUTOS_TAMANHOS D ON B.GRADE = D.GRADE?{ ?u 	INNER JOIN LOJA_VENDA E ON E.CODIGO_FILIAL = A.CODIGO_FILIAL AND E.TICKET = A.TICKET AND E.DATA_VENDA = A.DATA_VENDA?E ?? 	INNER JOIN LOJAS_VAREJO F ON A.CODIGO_FILIAL = F.CODIGO_FILIAL?E ?? 	INNER JOIN PRODUTOS_BARRA H ON A.CODIGO_BARRA = H.CODIGO_BARRA?w ?q 	INNER JOIN ESTOQUE_PRODUTOS I ON F.FILIAL = I.FILIAL AND A.PRODUTO = I.PRODUTO AND A.COR_PRODUTO = I.COR_PRODUTO?? ?? 	INNER JOIN (SELECT FILIAL,PRODUTO,SUM(ESTOQUE) AS ESTOQUE FROM ESTOQUE_PRODUTOS GROUP BY FILIAL,PRODUTO) AS ST ON  ST.FILIAL = F.FILIAL AND ST.PRODUTO =B.PRODUTO? ? 	WHERE <<XWHERE>>? ?  ? ?P %?C ?- ? Cur_Exportar_Base?& Erro pesquisando dados dos relat?rios.?. 
???? B?-?? ? Q?C? CRS_EXPORTAR_BASEW??? o? Cur_Exportar_Base?? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ??C? ???Q? ??5 ???6 ???? ??? ???/ ???0 ???1 ???2 ???# ???3 ???4 ???5 ???6 ???? ??? ???/ ???0 ???1 ???# ???5 ???? CRS_EXPORTAR_BASE?S T?9 ?C? XLS? Salvar Como...? Salvar? ?! Digite o nome do arquivo em Excel??? %?C?9 ???[? B?-?? ? ???-?! T?: ?C? Excel.Application?N?? T?; ?C?: ?< ?= ?? ??C ?9 ?; ?> ?? T?: ?? ?-??' T?: ?@ ?? A3:N3??A ????B ????* T?: ?@ ?? D4?? ?? REFILL FROM POS?? T?: ?@ ?? D4??C ?D ????% T?: ?@ ?? B6?? ??
 From Date:?? T?: ?@ ?? B6??C ?D ???? T?: ?@ ?? B6??C ?E ?a?? T?: ?@ ?? B6??F ????# T?: ?@ ?? C6??G ?? dd/mm/yy?? T?: ?@ ?? C6?? ?? ?? T?: ?@ ?? C6??C ?D ???? T?: ?@ ?? C6??C ?E ?-?? T?: ?@ ?? C6??F ????# T?: ?@ ?? G6?? ?? To Date:?? T?: ?@ ?? G6??C ?D ???? T?: ?@ ?? G6??C ?E ?a?? T?: ?@ ?? G6??F ????# T?: ?@ ?? H6??G ?? dd/mm/yy?? T?: ?@ ?? H6?? ?? ?? T?: ?@ ?? H6??C ?D ???? T?: ?@ ?? H6??C ?E ?-?? T?: ?@ ?? H6??F ????" T?: ?@ ?? L6?? ?? SOH >=:?? T?: ?@ ?? L6??C ?D ???? T?: ?@ ?? L6??C ?E ?a?? T?: ?@ ?? L6??F ???? T?: ?@ ?? M6??G ?? @?? T?: ?@ ?? M6?? ?? ?? T?: ?@ ?? M6??C ?D ???? T?: ?@ ?? M6??C ?E ?-?? T?: ?@ ?? M6??F ????% T?: ?@ ?? B7?? ??
 From Time:?? T?: ?@ ?? B7??C ?D ???? T?: ?@ ?? B7??C ?E ?a?? T?: ?@ ?? B7??F ???? T?: ?@ ?? C7??G ?? @?? T?: ?@ ?? C7?? ??
 ?? T?: ?@ ?? C7??C ?D ???? T?: ?@ ?? C7??C ?E ?-?? T?: ?@ ?? C7??F ????# T?: ?@ ?? G7?? ?? To Time:?? T?: ?@ ?? G7??C ?D ???? T?: ?@ ?? G7??C ?E ?a?? T?: ?@ ?? G7??F ???? T?: ?@ ?? H7??G ?? @?? T?: ?@ ?? H7?? ?? ?? T?: ?@ ?? H7??C ?D ???? T?: ?@ ?? H7??C ?E ?-?? T?: ?@ ?? H7??F ????) T?: ?@ ?? L7?? ?? Units Sold >=:?? T?: ?@ ?? L7??C ?D ???? T?: ?@ ?? L7??C ?E ?a?? T?: ?@ ?? L7??F ???? T?: ?@ ?? M7??G ?? @?? T?: ?@ ?? M7?? ?? ?? T?: ?@ ?? M7??C ?D ???? T?: ?@ ?? M7??C ?E ?-?? T?: ?@ ?? M7??F ???? T?: ?@ ?? B8?? ?? Div:?? T?: ?@ ?? B8??C ?D ???? T?: ?@ ?? B8??C ?E ?a?? T?: ?@ ?? B8??F ???? T?: ?@ ?? C8??G ?? @?? T?: ?@ ?? C8?? ?? ?? T?: ?@ ?? C8??C ?D ???? T?: ?@ ?? C8??C ?E ?-?? T?: ?@ ?? C8??F ????% T?: ?@ ?? G8?? ??
 Deparment:?? T?: ?@ ?? G8??C ?D ???? T?: ?@ ?? G8??C ?E ?a?? T?: ?@ ?? G8??F ???? T?: ?@ ?? H8??G ?? @?? T?: ?@ ?? H8?? ?? ?? T?: ?@ ?? H8??C ?D ???? T?: ?@ ?? H8??C ?E ?-?? T?: ?@ ?? H8??F ????* T?: ?@ ?? L8?? ?? Sub Department:?? T?: ?@ ?? L8??C ?D ???? T?: ?@ ?? L8??C ?E ?a?? T?: ?@ ?? L8??F ???? T?: ?@ ?? M8??G ?? @?? T?: ?@ ?? M8?? ?? ?? T?: ?@ ?? M8??C ?D ???? T?: ?@ ?? M8??C ?E ?-?? T?: ?@ ?? M8??F ????  T?: ?@ ?? B9?? ?? Show:?? T?: ?@ ?? B9??C ?D ???? T?: ?@ ?? B9??C ?E ?a?? T?: ?@ ?? B9??F ???? T?: ?@ ?? C9??G ?? @?? T?: ?@ ?? C9?? ?? ?? T?: ?@ ?? C9??C ?D ???? T?: ?@ ?? C9??C ?E ?-?? T?: ?@ ?? C9??F ????& T?: ?@ ?? G9?? ?? Printed By:?? T?: ?@ ?? G9??C ?D ???? T?: ?@ ?? G9??C ?E ?a?? T?: ?@ ?? G9??F ???? T?: ?@ ?? H9??G ?? @?? T?: ?@ ?? H9?? ?? ?? T?: ?@ ?? H9??C ?D ???? T?: ?@ ?? H9??C ?E ?-?? T?: ?@ ?? H9??F ????) T?: ?@ ?? A10:N10??A ??	??B ???? ??: ?@ ?? A13:N13??H ? T?: ?I ?C ?E ?a?? T?: ?I ?J ?K ???? T?: ?@ ?? A13?? ??  ?? T?: ?@ ?? B13?? ?? Div??& T?: ?@ ?? C13?? ??
 Department??* T?: ?@ ?? D13?? ?? Sub Department??! T?: ?@ ?? E13?? ?? Style?? T?: ?@ ?? F13?? ?? Clr??  T?: ?@ ?? G13?? ?? Size?? T?: ?@ ?? H13?? ?? QC??# T?: ?@ ?? I13?? ?? Item No??, T?: ?@ ?? J13?? ?? Item Description??& T?: ?@ ?? K13?? ??
 Units Sold?? T?: ?@ ?? L13?? ?? SOH??% T?: ?@ ?? M13?? ??	 TOTAL SOH?? T?: ?@ ?? N13?? ?? Bin??# T?: ?@ ?? A13:N13??C ?D ????! T?: ?@ ?? A13:N13??C ?E ?a?? ??: ?@ ?? B13:N13??H ? ??: ?@ ?? B13:N13??L ? T?: ?M ?? A??N ???? T?: ?M ?? B:N??N ???? T?O ???? F?8 ? T?P ?C??Q ??? #)? ~?5*? T?R ?C? A?? ??S ???(??P ??*? T?R ??R ???k T?T ?? oExcel.Range("C?R  CC?O Z?? ").NumberFormat = "CC ?S ??Q ? C? ? @?	 ? #####06? "?? &CMACRO.
= T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Size = 8?? &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Font.Bold = .F.?? &CMACRO.
@ T?T ?? oExcel.Range("C?R  CC?O Z?? ").ColumnWidth = 12?? &CMACRO.
+ T?T ?? CRS_EXPORTAR_BASE.C ?S ??Q ?? CCAMPO = &CMACRO.
? T?T ?? oExcel.Range("C?R  CC?O Z?? ").Value = CC ?S ??Q ? C? ? "? ?  6CC ?S ??Q ? C? C?U ?? CC?U Z?6CC ?S ??Q ? C? ? "? ?  6?? &CMACRO.
 ?? T?O ??O ??? F?8 ? ?$ %?C? CRS_EXPORTAR_BASEN???+? T?V ?????? ??W ???? T?W ??????? T?W ??????? T?W ???????W T?T ?? oExcel.Range("A13:NCC?O Z??+ ").Subtotal(3, xlsum, @laArray,.T.,.F.,.F.)?? &CMACRO.
 ?' ??: ?@ ?? A14:NCC?O ?
Z???X ?Y ?* T?: ?@ ?? K14:LCC?O ?
Z???F ???? T?: ?M ?? C:C??N ???? T?: ?M ?? D:D??N ???? T?: ?M ?? E:E??N ???? T?: ?M ?? F:F??N ???? T?: ?M ?? J:J??N ???? T?: ?M ?? K:K??N ??
?? T?: ?M ?? M:M??N ???? T?: ?M ?? N:N??N ????@ oExcel.ActiveSheet.PageSetup.RightFooter = "P?gina &P de &N"
' T?: ?Z ?[ ?\ ?? A1:NCC?O ?
Z??? T?: ?Z ?[ ?] ??	 A$13:N$13?? T?: ?Z ?[ ?^ ???? T?: ?Z ?[ ?_ ???? T?: ?Z ?[ ?` ??P?? T?: ?Z ?[ ?a ??d?? ??: ?@ ?? A4:N4??H ? T?: ?I ?b ?a?? T?: ?I ?F ???? ??: ?c ?d ? ??C?: ?e ?f ?? ??C?: ?f ?? <?: ?3 ??C? Arquivo Gerado Com Sucesso: ?0? Aviso?x?? ??-.?^ ??C?! N?o foi Possivel Gerar o Arquivo C? ? Verifique se n?o est? aberto?? Aviso?x?? ?? B?-?? Ug 
 XDATAATUAL SALEPRODUCTS CHKSEARCHTODAY VALUE
 XHORAATAUL CHKHOUR XD_I XD_F TXTSTARTDATE TXTFINISHDATE XH_I TXTSTARTHOUR XH_F TXTFINISHHOUR	 XFROMDATE XTODATE	 XFROMTIME XTOTIME XSOH
 XUNITSSOLD XDIV
 XDEPARMENT XSUBDEPARTMENT XSHOW
 XPRINTEDBY OPTSTOCKINFO GRUPO_PRODUTO QTDE CURSALEPRODUCTS CRS_PESQUISA SUBGRUPO_PRODUTO CPRODUTO CCOR_PRODUTO PRODUTO CURSALEPRODUCTCOLORS COR_PRODUTO MAIN DATA SQLUSERNAME XFILIAL P_FILIAL
 XFILIALEST	 XWHFILTER P_CODIGO_FILIAL XWHERE SSQL	 SQLSELECT TIPO_PRODUTO PRODUTO6 PRODUTO3 GRADE CODIGO_BARRA DESC_PROD_NF QTD_ESTOQUE ESTOQUE CUR_EXPORTAR_BASE CRS_EXPORTAR_BASE XRELEXP OEXCEL	 OWORKBOOK	 WORKBOOKS ADD SAVEAS VISIBLE RANGE BORDERS	 LINESTYLE FONT SIZE BOLD HORIZONTALALIGNMENT NUMBERFORMAT SELECT	 SELECTION INTERIOR
 COLORINDEX
 AUTOFILTER COLUMNS COLUMNWIDTH XLIN XTOTCMP XARRCMP NLETRA XC CMACRO CCAMPO XLSUM LAARRAY ENTIRECOLUMN AUTOFIT ACTIVESHEET	 PAGESETUP	 PRINTAREA PRINTTITLEROWS ORIENTATION FITTOPAGESWIDE ZOOM FITTOPAGESTALL
 MERGECELLS ACTIVEWORKBOOK SAVE APPLICATION QUIT Init,     ??1 11? ? ? ? 11A ?Aq A b1q A 21?Aq A ? ? ? ? ? ? ? ? ?? ? q? ? ? A ????A ????A ???!A ???!A ?Q?!22?A ?Q?2?A B?A BqA ?A !A ? 
??q????????qQ???QQq?
qa A  q A ??2? q A ? A? r??R???2????2???2????"????????S????????2??????????????????????????S?????????????????????????b??????????Aa??a???1?a?Q?2????? r !Q ? q?? ?? ?? ? ?Q?	? A q A C? ? 111r? A w?????????q?aaaa?1? ? q 2? ?A s 2                       ?H      )   ?5                                                              