**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
**-- Cliente : Nike OutLet																																				 --**
**-- Conteudo: Programação Para Impressora Allegro
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 
Procedure Etiqueta_Produto_São_Paulo

	**   1 2 11 002 0070 0010 DADO ENTER
	**   | |  |   |    |    |
	**   | |  |   |    |    +--> Coluna
	**   | |  |   |    +-------> Linha
	**   | |  |   +------------> Largura da Fonte
	**   | |  +----------------> Altura  da Fonte
	**   | +-------------------> Fonte
	**   +---------------------> Rotação

	xini  = '' + "L" + chr(13) + chr(10) + "SK" + chr(13) + chr(10) + "PG" + chr(13) + chr(10) + "D11" + chr(13) + chr(10) + "H20" + chr(13) + chr(10) 
	xfim  = "E" + chr(13) + chr(10) 
	xQtdeEti = "Q0001" + chr(13) + chr(10) 

	store '' to x_Allegro
	
	sele vtmp_tabelas_preco_barra_00
	go top
	xColA = 006
	xColB = 201

	xQtde = 0
	
	do while !eof()

		store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10,;
					xB1,xB2,xB3,xB4,xB5,xB6,xB7,xB8,xB9,xB10
	
		for k = 65 to 66
		
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
			
			K_ = chr(K)
			xQtde = xQtde + 1
			xBarra = allt(vtmp_tabelas_preco_barra_00.codigo_barra)
			
			x&K_.1  = "13120040220"+f_StrZero(xCol&K_+35,4) + 'NIKE OUTLET' + chr(13) + chr(10)
			x&K_.2  = "12110020200"+f_StrZero(xCol&K_+10,4) + subs(allt(vtmp_tabelas_preco_barra_00.desc_produto),1,20) + chr(13) + chr(10)		
			x&K_.3  = "12100010185"+f_StrZero(xCol&K_+10,4) + subs(allt(vtmp_tabelas_preco_barra_00.produto),1,20) + chr(13) + chr(10)
			x&K_.4  = "12100010185"+f_StrZero(xCol&K_+90,4)+ allt(tmp_prod.desc_cor) + chr(13) + chr(10)
			x&K_.5  = "12100010170"+f_StrZero(xCol&K_+10,4)+ allt(tmp_prod1.desc_cor) + chr(13) + chr(10)
			x&K_.6  = "12100030170"+f_StrZero(xCol&K_+90,4)+ 'TAM.:'+allt(tmp_grade.GRADE_NACIONAL) +' / '+ allt(tmp_grade.GRADE_IMPORTADO) + chr(13) + chr(10)
			x&K_.7  = "11010020170"+f_StrZero(xCol&K_+10,4) + allt(vtmp_tabelas_preco_barra_00.codigo_barra ) + chr(13) + chr(10)
			x&K_.8  = "1O121000055"+f_StrZero(xCol&K_+05,4) + allt(vtmp_tabelas_preco_barra_00.codigo_barra ) + chr(13) + chr(10)
			x&k_.9	= "12111500040"+f_StrZero(xCol&K_+10,4) + 'Preco Original.: '+ transf(tmp_precos.preco1,"999.99") + chr(13) + chr(10)
			x&k_.10 = "13120400005"+f_StrZero(xCol&K_+15,4) + 'OUTLET.: '+ transf(tmp_preco.preco1,"999.99") + chr(13) + chr(10)

			if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
				skip
				xQtde = 0
			endif

			if eof()
				exit
			endif

		endfor

		x_Allegro = x_Allegro + xini+xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10 ;
		                			+xB1+xB2+xB3+xB4+xB5+xB6+xB7+xB8+xB9+xB10 ;
		                			+xQtdeEti+xfim

	enddo

Return(allt(x_Allegro))
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 

Procedure Etiqueta_Produto_Rio_De_Janeiro

	**   1 2 11 002 0070 0010 DADO ENTER
	**   | |  |   |    |    |
	**   | |  |   |    |    +--> Coluna
	**   | |  |   |    +-------> Linha
	**   | |  |   +------------> Largura da Fonte
	**   | |  +----------------> Altura  da Fonte
	**   | +-------------------> Fonte
	**   +---------------------> Rotação

	xini  = '' + "L" + chr(13) + chr(10) + "SK" + chr(13) + chr(10) + "PG" + chr(13) + chr(10) + "D11" + chr(13) + chr(10) + "H20" + chr(13) + chr(10) 
	xfim  = "E" + chr(13) + chr(10) 
	xQtdeEti = "Q0001" + chr(13) + chr(10) 

	store '' to x_Allegro
	
	sele vtmp_tabelas_preco_barra_00
	go top
	xColA = 001
	xColB = 500

	xQtde = 0
	
	do while !eof()

		store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10,;
					xB1,xB2,xB3,xB4,xB5,xB6,xB7,xB8,xB9,xB10
	
		for k = 65 to 66
		
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
			
			K_ = chr(K)
			xQtde = xQtde + 1
			xBarra = allt(vtmp_tabelas_preco_barra_00.codigo_barra)
			
			x&K_.1  = "13120040570"+f_StrZero(xCol&K_+85,4) + 'NIKE OUTLET' + chr(13) + chr(10)
			x&K_.2  = "12110020530"+f_StrZero(xCol&K_+10,4) + subs(allt(vtmp_tabelas_preco_barra_00.desc_produto),1,20) + chr(13) + chr(10)		
			x&K_.3  = "12100010480"+f_StrZero(xCol&K_+10,4) + subs(allt(vtmp_tabelas_preco_barra_00.produto),1,20) + chr(13) + chr(10)
			x&K_.4  = "12100010480"+f_StrZero(xCol&K_+200,4)+ allt(tmp_prod.desc_cor) + chr(13) + chr(10)
			x&K_.5  = "12100010480"+f_StrZero(xCol&K_+200,4)+ allt(tmp_prod1.desc_cor) + chr(13) + chr(10)
			x&K_.6  = "12100030430"+f_StrZero(xCol&K_+200,4)+ 'TAM.:'+allt(tmp_grade.GRADE_NACIONAL) +' / '+ allt(tmp_grade.GRADE_IMPORTADO) + chr(13) + chr(10)
			x&K_.7  = "11010020430"+f_StrZero(xCol&K_+10,4) + allt(vtmp_tabelas_preco_barra_00.codigo_barra ) + chr(13) + chr(10)
			x&K_.8  = "1O122500150"+f_StrZero(xCol&K_+15,4) + allt(vtmp_tabelas_preco_barra_00.codigo_barra ) + chr(13) + chr(10)
			x&k_.9	= "12111500110"+f_StrZero(xCol&K_+60,4) + 'Preco Original.: '+ transf(tmp_precos.preco1,"999.99") + chr(13) + chr(10)
			x&k_.10 = "13120400020"+f_StrZero(xCol&K_+80,4) + 'OUTLET.: '+ transf(tmp_preco.preco1,"999.99") + chr(13) + chr(10)

			sele vtmp_tabelas_preco_barra_00
			if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
				skip
				xQtde = 0
			endif

			if eof()
				exit
			endif

		endfor

		x_Allegro = x_Allegro + xini+xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10 ;
		                			+xB1+xB2+xB3+xB4+xB5+xB6+xB7+xB8+xB9+xB10 ;
		                			+xQtdeEti+xfim

	enddo

Return(allt(x_Allegro))
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 

