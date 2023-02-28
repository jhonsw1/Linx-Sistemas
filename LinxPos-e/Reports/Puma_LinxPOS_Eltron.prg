**-- Cliente : Puma ( Etiqueta para LinxPOS )
**-- Conteudo: Programação Para Impressora Zebra TLP-2844
*---------------------------------------------------------------------------------------------------------------------------*

Procedure Etiqueta_LinxPOS

xControl   = ''
xClear     = 'N'
xDirection = 'ZT'
xWindows   = 'WY'
xMargem    = 'R080,090' 
xini       = xControl + chr(13) + chr(10) + ;
			 xClear + chr(13) + chr(10) + ;
			 xDirection + chr(13) + chr(10) + ;
			 xWindows + chr(13) + chr(10) + ;
			 xMargem + chr(13) + chr(10)
xfim       = ''   + chr(13) + chr(10)
xQtdeEti   = 'P0001' + chr(13) + chr(10) 

store '' to x_Eltron

sele vtmp_tabelas_preco_barra_00
go top

xColA = 001
xColB = 380

xQtde = 0

do while !eof()

	store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10,xA11,xA12,xA13,xA14,xA15,;
				xB1,xB2,xB3,xB4,xB5,xB6,xB7,xB8,xB9,xB10,xB11,xB12,xB13,xB14,xB15

	for K = 65 to 66
		K_ = chr(K)
		xQtde = xQtde + 1

		x&K_.1  = 'A' + f_StrZero(xCol&K_+035,3)    + ',025,0,3,1,1,N,'    + '"P u m a  S t o r e' + '"' + chr(13) + chr(10)
		x&K_.2  = 'A' + f_StrZero(xCol&K_+008,3)    + ',060,0,1,1,1,N,'    + '"Troca somente com esta etiqueta' + '"' + chr(13) + chr(10)
		x&K_.3  = 'A' + f_StrZero(xCol&K_+008,3)    + ',080,0,1,1,1,N,'    + '"no prazo de 30 dias    /   /   ' + '"' + chr(13) + chr(10)
		x&K_.4  = 'A' + f_StrZero(xCol&K_+012,3)    + ',110,0,2,1,1,N,'    + '"' + subs(allt(vtmp_tabelas_preco_barra_00.desc_produto),1,30) + '"' + chr(13) + chr(10)
		x&K_.5  = 'A' + f_StrZero(xCol&K_+012,3)    + ',140,0,2,1,1,N,'    + '"' + allt(vtmp_tabelas_preco_barra_00.produto) + '"' + chr(13) + chr(10)
		x&K_.6  = 'A' + f_StrZero(xCol&K_+012,3)    + ',170,0,1,1,1,N,'    + '"Cod.Puma: ' + allt(vtmp_tabelas_preco_barra_00.produto) + '"' + chr(13) + chr(10)
		x&K_.7  = 'A' + f_StrZero(xCol&K_+012,3)    + ',200,0,2,1,1,N,'    + '"Cor: ' + allt(vtmp_tabelas_preco_barra_00.cor_produto) + '"' + chr(13) + chr(10)
		x&K_.8  = 'A' + f_StrZero(xCol&K_+200,3)    + ',200,0,2,1,1,N,'    + '"Tam: ' + allt(vtmp_tabelas_preco_barra_00.nome_tamanho) + '"' + chr(13) + chr(10)
		x&K_.9  = 'A' + f_StrZero(xCol&K_+080,3)    + ',235,0,2,1,1,N,'    + '"' + allt(vtmp_tabelas_preco_barra_00.codigo_barra)   + '"' + chr(13) + chr(10)	
		x&K_.10 = 'B' + f_StrZero(xCol&K_+040,3)    + ',262,0,1,2,3,90,N,' + '"' + allt(vtmp_tabelas_preco_barra_00.codigo_barra) + '"' + chr(13) + chr(10)
		x&K_.11 = 'A' + f_StrZero(xCol&K_+020,3)    + ',362,0,1,1,1,N,'    + '"Cor: ' + allt(vtmp_tabelas_preco_barra_00.cor_produto) + '"' + chr(13) + chr(10)
		x&K_.12 = 'A' + f_StrZero(xCol&K_+180,3)    + ',362,0,1,1,1,N,'    + '"Tam: ' + allt(vtmp_tabelas_preco_barra_00.nome_tamanho) + '"' + chr(13) + chr(10)
		x&K_.13 = 'A' + f_StrZero(xCol&K_+020,3)    + ',382,0,1,1,1,N,'    + '"Cod: ' + allt(vtmp_tabelas_preco_barra_00.produto) + '"' + chr(13) + chr(10)
		x&K_.14 = 'A' + f_StrZero(xCol&K_+180,3)    + ',382,0,1,1,1,N,'    + '"Puma: ' + allt(vtmp_tabelas_preco_barra_00.produto) + '"' + chr(13) + chr(10)
		x&K_.15 = 'A' + f_StrZero(xCol&K_+100,3)    + ',412,0,3,1,1,N,'    + '"R$ ' + strt(transf(vtmp_tabelas_preco_barra_00.preco1,'9999.99'),'.',',') + '"' + chr(13) + chr(10)

		if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
			skip
			xQtde = 0
		endif

		if eof()
			exit
		endif

	endfor

	x_Eltron = x_Eltron + xini + xA1 + xA2 + xA3 + xA4 + xA5 + xA6 + xA7 + xA8 + xA9 + xA10 + xA11 + xA12 + xA13 + xA14 + xA15 ;
							   + xB1 + xB2 + xB3 + xB4 + xB5 + xB6 + xB7 + xB8 + xB9 + xB10 + xB11 + xB12 + xB13 + xB14 + xB15 ;
	                		   + xQtdeEti + xfim
                 
enddo

Return(allt(x_Eltron))
*---------------------------------------------------------------------------------------------------------------------------*
