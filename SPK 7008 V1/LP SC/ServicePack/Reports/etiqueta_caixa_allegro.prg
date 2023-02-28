**--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
**-- Cliente : Nike OutLet																																				 --**
**-- Conteudo: Programação Para Impressora Allegro
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 
Procedure Etiqueta_Caixa_Allegro

	**   1 2 11 002 0070 0010 DADO ENTER
	**   | |  |   |    |    |
	**   | |  |   |    |    +--> Coluna
	**   | |  |   |    +-------> Linha
	**   | |  |   +------------> Largura da Fonte
	**   | |  +----------------> Altura  da Fonte
	**   | +-------------------> Fonte
	**   +---------------------> Rotação

	xini  = '' + "L" + chr(13) + chr(10) + "SK" + chr(13) + chr(10) + "PG" + chr(13) + chr(10) + "D11" + chr(13) + chr(10) + "H12" + chr(13) + chr(10) 
	xfim  = "E" + chr(13) + chr(10) 
	xQtdeEti = "Q0001" + chr(13) + chr(10) 

	store '' to x_Allegro

	sele vtmp_tabelas_preco_barra_00
	go top
	xColA = 005

	xQtde = 0
	
	do while !eof()

		store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10
	
		for k = 65 to 65
		

			sele vtmp_tabelas_preco_barra_00
			
			K_ = chr(K)
			xQtde = xQtde + 1
			xBarra = allt(vtmp_tabelas_preco_barra_00.caixa)


*******---------------------------------------------------------------------------------------------------------			
			xdata = SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),7,2) +'/'+ SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),5,2)+'/'+ SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),1,4)

			col7 = vtmp_tabelas_preco_barra_00.col7

			xbox = SUBST(vtmp_tabelas_preco_barra_00.caixa,4,3) + SUBST(vtmp_tabelas_preco_barra_00.caixa,10,3) + SUBST(vtmp_tabelas_preco_barra_00.caixa,21,LEN(vtmp_tabelas_preco_barra_00.caixa))

*******---------------------------------------------------------------------------------------------------------	

			SELECT vtmp_tabelas_preco_barra_00	
			
*!*				x&K_.1  = "13120040220"+f_StrZero(xCol&K_+35,4) + 'NIKE FACTORY STORE' + chr(13) + chr(3)
			x&K_.1  = "12110020240"+f_StrZero(xCol&K_+10,4) +'Origem:  '+  subs(allt(vtmp_tabelas_preco_barra_00.filial_origem),1,20) + chr(1) + chr(10)		
			x&K_.2  = "12110010225"+f_StrZero(xCol&K_+10,4) +'Destino: '+  subs(allt(vtmp_tabelas_preco_barra_00.filial_destino),1,20) + chr(13) + chr(10)
			x&K_.3  = "1e120400055"+f_StrZero(xCol&K_+005,4) + "C" + Allt(xBarra) + chr(13) + chr(10)
			x&K_.4  = "14100010200"+f_StrZero(xCol&K_+10,4) +'NF: '+ allt(vtmp_tabelas_preco_barra_00.numero_nf_transferencia) + chr(13) + chr(10)
			x&K_.5  = "12100030170"+f_StrZero(xCol&K_+10,4) + 'Data: '+ xdata  + chr(13) + chr(10)
			x&K_.6  = "12010020185"+f_StrZero(xCol&K_+10,4) + 'Serie: '+ left(allt(vtmp_tabelas_preco_barra_00.serie_nf),15) + chr(13) + chr(10)
			x&K_.7  = "14100010140"+f_StrZero(xCol&K_+10,4) + 'Caixa/Qde '+ col7  + chr(13) + chr(10)
*!*				
			x&k_.9	= "12111500040"+f_StrZero(xCol&K_+25,4) + vtmp_tabelas_preco_barra_00.caixa + chr(13) + chr(10)

			if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
				skip
				xQtde = 0
			endif

			if eof()
				exit
			endif

		endfor

		x_Allegro = x_Allegro + xini+xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10 ;
		                			+xQtdeEti+xfim

	enddo

Return(allt(x_Allegro))
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------* 

