   ?   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=1
PAPERSIZE=9
COLOR=1
                           Courier New                    "alltrim(curBarcodePrint.descricao)                                                             Times New Roman                	"Produto"                      Times New Roman                %alltrim(curBarcodePrint.codigo_barra)                                                          Times New Roman                curBarcodePrint.Preco                                         Times New Roman                "Pre?o"                        Times New Roman                1"*" + alltrim(curBarcodePrint.Codigo_Barra) + "*"               BC C39 Narrow                  1"*" + alltrim(curBarcodePrint.Codigo_Barra) + "*"               BC C39 Narrow                  Courier New                    Times New Roman                Times New Roman                BC C39 Narrow                  dataenvironment                `Top = 24
Left = 101
Width = 620
Height = 468
DataSource = .NULL.
Name = "Dataenvironment"
                                 ?PROCEDURE Init
if used("curBarcodePrint")
	use in curBarcodePrint
endif

select * from curBarcode WHERE 1 = 0 into cursor curBarcodePrint readwrite

select curBarcode
scan
	ShowProgress("Criando etiquetas...", reccount())

	if Barcodes > 0
		for intCounter = 1 to Barcodes
			scatter name objBarcodeTag
			select curBarcodePrint
			append blank
			gather name objBarcodeTag
			select curBarcode
		endfor
	endif
endscan
go top

ShowProgress()

select curBarcodePrint
go top

ENDPROC
              !???                              |B   %   ?      ?     ?          ?  U   %?C? curBarcodePrint???& ? Q?  ? ?2 o?
 curBarcode????? ???? curBarcodePrint?? F? ? ~?? ?# ??C? Criando etiquetas...CN? ?? %?? ? ??? ? ?? ???(?? ??? ? ^J? ? F?  ? ? _J? ? F? ? ?? ? ? #)?
 ??C? ?? F?  ? #)? U  CURBARCODEPRINT
 CURBARCODE SHOWPROGRESS BARCODES
 INTCOUNTER OBJBARCODETAG Init,     ??1 ?? A "r ? 1q? q Q ? q A A A Q ? r Q 2                       ?      )                                   %ORIENTATION=1
PAPERSIZE=9
COLOR=1
                           Courier New                    "alltrim(curBarcodePrint.descricao)                                                             Times New Roman                	"Produto"                      Times New Roman                %alltrim(curBarcodePrint.codigo_barra)                                                          Times New Roman                curBarcodePrint.Preco                                         Times New Roman                "Pre?o"                        Times New Roman                1"*" + alltrim(curBarcodePrint.Codigo_Barra) + "*"               BC C39 Narrow                  1"*" + alltrim(curBarcodePrint.Codigo_Barra) + "*"               BC C39 Narrow                  Courier New                    Times New Roman                Times New Roman                BC C39 Narrow                  dataenvironment                bTop = 61
Left = -163
Width = 1088
Height = 714
DataSource = .NULL.
Name = "Dataenvironment"
                               ?PROCEDURE Init
if used("curBarcodePrint")
	use in curBarcodePrint
endif

select * from curBarcode into cursor curBarcodePrint readwrite

select curBarcode
scan
	ShowProgress("Criando etiquetas...", reccount())

	if Barcodes > 0
		for intCounter = 1 to Barcodes
			scatter name objBarcodeTag
			select curBarcodePrint
			append blank
			gather name objBarcodeTag
			select curBarcode
		endfor
	endif
endscan
go top

ShowProgress()

select curBarcodePrint
go top

ENDPROC
                          ???    ?  ?                        ??   %   y      ?     ?          ?  U  ?  %?C? curBarcodePrint???& ? Q?  ? ?( o?
 curBarcodeǼ?? curBarcodePrint?? F? ? ~?? ?# ??C? Criando etiquetas...CN? ?? %?? ? ??? ? ?? ???(?? ??? ? ^J? ? F?  ? ? _J? ? F? ? ?? ? ? #)?
 ??C? ?? F?  ? #)? U  CURBARCODEPRINT
 CURBARCODE SHOWPROGRESS BARCODES
 INTCOUNTER OBJBARCODETAG Init,     ??1 ?? A ?r ? 1q? q Q ? q A A A Q ? r Q 2                       ?      )   ?                                    