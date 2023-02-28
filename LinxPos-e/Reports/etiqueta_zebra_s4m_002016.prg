**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
**-- Cliente : Nike 04/03/2015
**-- Conteudo: Programação Para Impressora Zebra S4M
**--------------------------------------------------------------------------------------------------------------------------------------------**
Procedure Etiqueta_Produto_São_Paulo

xprimeira = "^LH015"
xini      = "^XA" + chr(13) + chr(10)
xfim      = "^XZ" + chr(13) + chr(10)
xqtde     = vtmp_tabelas_preco_barra_00.qtde_etiquetas
xBarra    = ALLTRIM(vtmp_tabelas_preco_barra_00.codigo_barra)
xData     = PADL(ALLTRIM(STR(DAY(DATE()))),2,'0')+PADL(ALLTRIM(STR(MONTH(DATE()))),2,'0')
xDescProd = strt(strt(strt(strt(strt(strt(strt(strt(allt(vtmp_tabelas_preco_barra_00.desc_produto),'Ã','A'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Ç','C'),'Õ','O')

			IF TYPE('WCONTROLE')='U'
				=SQLSelect("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '00'",'tmp_preco')
				=SQLSelect("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '01'",'tmp_precos')
				=SQLSelect("SELECT GRADE_NACIONAL, GRADE_IMPORTADO FROM etiqueta_nike where CODIGO_BARRA =?vtmp_tabelas_preco_barra_00.CODIGO_BARRA",'tmp_grade')
				=SQLSelect("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '01'",'tmp_prod')
				=SQLSelect("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '02'",'tmp_prod1')
			ELSE && Retaguarda
				f_Select("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '00'","tmp_preco",ALIAS())
				f_Select("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '01'","tmp_precos",ALIAS())
				f_Select("SELECT GRADE_NACIONAL,GRADE_IMPORTADO FROM etiqueta_nike where CODIGO_BARRA =?vtmp_tabelas_preco_barra_00.CODIGO_BARRA","tmp_grade",ALIAS())
				f_Select("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '01'","tmp_prod",ALIAS())
				f_Select("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '02'","tmp_prod1",ALIAS())
			ENDIF	
			
			sele vtmp_tabelas_preco_barra_00 

xcom1  = "^PQ"+transf(xqtde,'@L 99999')+",0,1,Y" + chr(13) + chr(10)
xcom2  = "^FO045,065^ABN,56,15^FH^FD" +'NIKE FACTORY STORE'+"^FS" + chr(13) + chr(10)
xcom3  = "^FO015,130^AEN,26,20^FH^FD" + subs(allt(vtmp_tabelas_preco_barra_00.desc_produto),1,19)+"^FS" + chr(13) + chr(10)
xcom4  = "^FO0115,160^AEN,26,15^FH^FD" + subs(allt(vtmp_tabelas_preco_barra_00.produto),1,6) +'-'+ SUBSTR(allt(vtmp_tabelas_preco_barra_00.produto),7,9)+"^FS" + chr(13) + chr(10)
xcom5  = "^FO015,190^AEN,39,20^FH^FD" +allt(tmp_prod.desc_cor)+"^FS" + chr(13) + chr(10)
xcom6  = "^FO015,160^AEN,28,15^FH^FD" +allt(tmp_prod1.desc_cor)+"^FS" + chr(13) + chr(10)
xcom7  = "^FO015,220^AEN,36,20^FH^FD" +'TAM.:'+allt(tmp_grade.GRADE_NACIONAL) +'/'+ allt(tmp_grade.GRADE_IMPORTADO)+"^FS" + chr(13) + chr(10)
xcom8  = "^FO017,260^BCN,135,N,N,^FD" +xBarra+"^FS" + chr(13) + chr(10)

xcom9 = "^FO015,440^AEN,36,20^FH^FD" + 'Original:'+ transf(tmp_precos.preco1,"999.99")+"^FS" + chr(13) + chr(10)
xcom10 = "^FO015,500^AEN,46,20^FH^FD" +'Factory:'+"^FS" + chr(13) + chr(10)
xcom11 = "^FO180,500^AEN,46,20^FH^FD" + transf(tmp_preco.preco1,"999.99") +"^FS" + chr(13) + chr(10)
xcom12 = "^FO115,400^ADN,20,10^FH^FD" + allt(vtmp_tabelas_preco_barra_00.codigo_barra )+"^FS" + chr(13) + chr(10)

xcom_zebra = xini+xprimeira+xcom1+xcom2+xcom3+xcom4+xcom5+xcom6+xcom7+xcom8+xcom9+xcom10+xcom11+xcom12+xfim

Return(xcom_zebra)
**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------**

Procedure Etiqueta_Produto_Rio_De_Janeiro

xprimeira = "^LH015"
xini      = "^XA" + chr(13) + chr(10)
xfim      = "^XZ" + chr(13) + chr(10)
xqtde     = vtmp_tabelas_preco_barra_00.qtde_etiquetas
xBarra    = ALLTRIM(vtmp_tabelas_preco_barra_00.codigo_barra)
xData     = PADL(ALLTRIM(STR(DAY(DATE()))),2,'0')+PADL(ALLTRIM(STR(MONTH(DATE()))),2,'0')
xDescProd = strt(strt(strt(strt(strt(strt(strt(strt(allt(vtmp_tabelas_preco_barra_00.desc_produto),'Ã','A'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Ç','C'),'Õ','O')

			IF TYPE('WCONTROLE')='U'
				=SQLSelect("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '00'",'tmp_preco')
				=SQLSelect("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '01'",'tmp_precos')
				=SQLSelect("SELECT GRADE_NACIONAL, GRADE_IMPORTADO FROM etiqueta_nike where CODIGO_BARRA =?vtmp_tabelas_preco_barra_00.CODIGO_BARRA",'tmp_grade')
				=SQLSelect("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '01'",'tmp_prod')
				=SQLSelect("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '02'",'tmp_prod1')
			ELSE && Retaguarda
				f_Select("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '00'","tmp_preco",ALIAS())
				f_Select("select preco1 from produtos_preco_cor where produto=?vtmp_tabelas_preco_barra_00.produto AND COR_PRODUTO =?vtmp_tabelas_preco_barra_00.COR_PRODUTO and codigo_tab_preco = '01'","tmp_precos",ALIAS())
				f_Select("SELECT GRADE_NACIONAL,GRADE_IMPORTADO FROM etiqueta_nike where CODIGO_BARRA =?vtmp_tabelas_preco_barra_00.CODIGO_BARRA","tmp_grade",ALIAS())
				f_Select("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '01'","tmp_prod",ALIAS())
				f_Select("select desc_cor from cores_basicas where cor =?vtmp_tabelas_preco_barra_00.cor_produto AND COR = '02'","tmp_prod1",ALIAS())
			ENDIF	
			
			sele vtmp_tabelas_preco_barra_00 

xcom1  = "^PQ"+transf(xqtde,'@L 99999')+",0,1,Y" + chr(13) + chr(10)
xcom2  = "^FO170,070^ADN,46,20^FH^FD"+"NIKE"+"^FS" + chr(13) + chr(10)
xcom3  = "^FO015,130^AEN,26,20^FH^FD" + subs(allt(vtmp_tabelas_preco_barra_00.desc_produto),1,19)+"^FS" + chr(13) + chr(10)
xcom4  = "^FO115,160^AEN,26,15^FH^FD" + subs(allt(vtmp_tabelas_preco_barra_00.produto),1,6) +'-'+ SUBSTR(allt(vtmp_tabelas_preco_barra_00.produto),7,9)+"^FS" + chr(13) + chr(10)
xcom5  = "^FO015,190^AEN,39,20^FH^FD" +allt(tmp_prod.desc_cor)+"^FS" + chr(13) + chr(10)
xcom6  = "^FO015,160^AEN,28,15^FH^FD" +allt(tmp_prod1.desc_cor)+"^FS" + chr(13) + chr(10)
xcom7  = "^FO015,220^AEN,36,20^FH^FD" +'TAM.:'+allt(tmp_grade.GRADE_NACIONAL) +'/'+ allt(tmp_grade.GRADE_IMPORTADO)+"^FS" + chr(13) + chr(10)
xcom8  = "^FO017,260^BCN,135,N,N,^FD" +xBarra+"^FS" + chr(13) + chr(10)


xcom9  = "^FO020,500^AEN,46,20^FH^FD" + 'Preco:'+' '+"^FS" + chr(13) + chr(10)
xcom10 = "^FO150,500^AEN,46,20^FH^FD" + transf(tmp_preco.preco1,"999.99") +"^FS" + chr(13) + chr(10)
xcom11 = "^FO115,400^ADN,20,10^FH^FD" + allt(vtmp_tabelas_preco_barra_00.codigo_barra )+"^FS" + chr(13) + chr(10)


xcom_zebra = xini+xprimeira+xcom1+xcom2+xcom3+xcom4+xcom5+xcom6+xcom7+xcom8+xcom9+xcom10+xcom11+xfim

Return(xcom_zebra)


*!*	**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------**
*!*	**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------**



