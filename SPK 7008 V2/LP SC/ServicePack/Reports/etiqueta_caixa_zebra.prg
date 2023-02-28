*-- Cliente : NIKE CAIXA
*-- Conteudo: Programação Para Impressora Zebra 
*----------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Etiqueta_CAIXA

store '' to x_Zebra
sele vtmp_tabelas_preco_barra_00
go top

xini     = "^XA" + chr(13) + chr(10) + '^LH000,000' + chr(13) + chr(10) + '^MTT' + chr(13) + chr(10) + '^MD15' + chr(13) + chr(10)
xfim     = "^XZ" + chr(13) + chr(10)

xQtdeEti = "^PQ001,0,1,Y" + chr(13) + chr(10)
xColA    = 000

		
xQtde    = 0

do while !eof()

	store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10
						
	for k = 65 to 65
		k_ = chr(k)

		xQtde  = xQtde + 1
		xBarra = allt(vtmp_tabelas_preco_barra_00.codigo_barra)
		
		set step on

		xdata = SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),7,2) +'/'+ SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),5,2)+'/'+ SUBSTR(DTOS(vtmp_tabelas_preco_barra_00.emissao),1,4)

		col7 = vtmp_tabelas_preco_barra_00.col7
		
*		xbox = SUBST(vtmp_tabelas_preco_barra_00.caixa,4,3) + SUBST(vtmp_tabelas_preco_barra_00.caixa,10,3) + SUBST(vtmp_tabelas_preco_barra_00.caixa,21,LEN(vtmp_tabelas_preco_barra_00.caixa))
		xbox = vtmp_tabelas_preco_barra_00.caixa
		SELECT vtmp_tabelas_preco_barra_00		
		x&K_.1 = '^FO'+f_StrZero(xCol&K_+001,3) + ',070^AQN,20,20^FD' +'Origem:  '+ allt(vtmp_tabelas_preco_barra_00.filial_origem) + '^FS' + chr(13) + chr(10)
		x&K_.2 = '^FO'+f_StrZero(xCol&K_+001,3) + ',095^AQN,10,10^FD' +'Destino: '+ allt(vtmp_tabelas_preco_barra_00.filial_destino) + '^FS' + chr(13) + chr(10)
		x&K_.3 = '^FO'+f_StrZero(xCol&K_+010,3) + ',390^BY1,10^BCN,70,Y,N,^FD' + alltr(xbox) + '^FS' + chr(13) + chr(10)

		x&K_.4 = '^FO'+f_StrZero(xCol&K_+001,3) + ',135^ADN,40,20^FD' +'NF: '+ allt(vtmp_tabelas_preco_barra_00.numero_nf_transferencia) + '^FS' + chr(13) + chr(10)
		x&K_.5 = '^FO'+f_StrZero(xCol&K_+001,3) + ',195^AQN,10,10^FD' +'Data: '+ xdata + '^FS' + chr(13) + chr(10)

		x&K_.6  = '^FO'+f_StrZero(xCol&K_+001,3) + ',170^AQN,10,10^FD' +'Serie: '+ left(allt(vtmp_tabelas_preco_barra_00.serie_nf),15) + '^FS' + chr(13) + chr(10)
*!*			x&K_.7  = '^FO'+f_StrZero(xCol&K_+001,3) + ',260^ADN,40,20^FD' +'Caixa/Qde '+ALLTRIM(str(vTmp_tabelas_preco_barra_00.col7)) + '/' + ALLTRIM(str(vTmp_tabelas_preco_barra_00.qtde_total))+ '^FS' + chr(13) + chr(10)
		x&K_.8  = '^FO'+f_StrZero(xCol&K_+001,3) + ',260^ADN,40,20^FD' +'Caixa/Qde '+ col7 + '^FS' + chr(13) + chr(10)

		if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
			skip
			xQtde = 0
		endif

		if eof()
			exit
		endif

	endfor

	x_Zebra = x_Zebra + xini +xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10 ;
							 +xQtdeEti+xfim

enddo

Return(allt(x_Zebra))
**-------------------------------------------------------------------------------------------------------------------------** 
