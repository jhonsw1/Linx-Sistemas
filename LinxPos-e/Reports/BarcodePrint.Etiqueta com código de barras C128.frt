  ?   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ?DRIVER=winspool
DEVICE=\\a-srv62\HP_Suporte_Cenno
OUTPUT=192.168.104.122
ORIENTATION=1
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
           O  .  winspool  \\a-srv62\HP_Suporte_Cenno  192.168.104.122                                   ?\\a-srv62\HP_Suporte_Cenno       ? ?C?? 	 ?4d   X  X  A4                                                           ????                DINU" ?
?@(?R                            B                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ?  SMTJ     ?H P   L a s e r J e t   M 2 7 2 7   M F P   S e r i e s   P C L   6   InputBin FORMSOURCE RESDLL UniresDLL ESPRITSupported True HPDocUISUI True HPNUseDiffFirstPageChoice TRUE Resolution 600dpi FastRes True HPPrintInGrayScale True EMFSpoolingforPLSwoMopier True Collate OFF Orientation PORTRAIT HPOrientRotate180 False Duplex VERTICAL PaperSize A4 MediaType AUTO ColorMode Mono Economode False TextAsBlack False TTAsBitmapsSetting TTModeOutline RETChoice True HPEnableGrafitCompression True HPRequestObjectTagDump False HPRequestNullStripCommand False HPHybridRenderSwitch HPHybridPDL HPManualDuplexDialogItems InstructionID_01_FACEDOWN-NOROTATE HPManualFeedOrientation FACEDOWN HPOutputBinOrientation FACEDOWN PrintQualityGroup PQGroup_3 HPDocPropResourceData hpchl093.cab HPLpiSelection None HPColorMode MONOCHROME_MODE HPPDLType PDL_PCL6 HPPJLEncoding UTF8 HPJobAccounting HPJOBACCT_JOBACNT_GROUPNAME HPBornOnDate HPBOD HPXMLFileUsed hpc27276.xml HPEnableObjectTagging True HPEnablePageTimer False HPSmartDuplexSinglePageJob True HPSmartDuplexOddPageJob True HPEnableNullStrips True HPEnableEfficientMono FALSE HPEnableImageProcessingPath FALSE HPMonochromePrinter TRUE HPCallToWritePrinterRequired TRUE HPMemoryManager True HPGetCompressionRatioValue 17 MaxStripHeight 64 HPGetByteAlignedValueForWidth 256 HPGetDeltaRowHalfToneValue 1 HPPrintOnBothSidesManually False HPPaperSizeDuplexConstraints A3 HPMediaTypeDuplexConstraints HEAVY_111_130G HPStraightPaperPath False HPPageExceptionsFile HPCPE093 HPPageExceptionsLowEnd HPPageExceptionsLowEndVer HPPageExceptionsInterface ShowPageExceptions HPPageExceptions CoverInsertion PSAlignmentFile HPCLS093 PSServicesOption HPServiceFileNameEnd HPSmartHub Inet_SID_263_BID_514_HID_265 HPConsumerCustomPaper True HPManualDuplexDialogModel Modeless HPManualDuplexPageOrder EvenPagesFirst HPMapManualFeedToTray1 True HPManualDuplexPageRotate DriverRotate                                                                                              ?  IUPH  x????kAǿ?@i?X?"?Eo."9+ʚl?`[צD?zvS??&?? ????A????Z<(X?y?K?{C?N?KA]?|????y3?3a&ovfvƀRN]?E?????Z?#??&7???jy$???H~س??C?5?q?^?J?.??9^?Dx??&g??`?c԰?vGH*?Jv?x??t:?M?[n?H???Im^?2??:???I?1????Y<?????Ů$5G???2??В5jE?TK??3?I?S?pN?GU?N??X?b??o???*???<NژB]G.36?W?_??=??93c??k?m??e/??*???O??ń??Mx?.?"?i?BH??Y?????ot??S???????????z??w???Ղ????????{i??=?"na??z???????????H??&r/ɳfN?R??QA?Z?wi??$':?+$U?d?e?j??ӓ?T?eƙ???(c?q??*?($??;@?ʡ_,?=*U&????/??x??	?l}?9?p???
????W??|+|????{S~0?jB!?B!??!~??{?                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Courier New                    "alltrim(curBarcodePrint.descricao)                                                             Times New Roman                	"Produto"                      Times New Roman                %alltrim(curBarcodePrint.codigo_barra)                                                          Times New Roman                curBarcodePrint.Preco                                         Times New Roman                "Pre?o"                        Times New Roman                1bc_code128(alltrim(curBarcodePrint.Codigo_Barra))               BC C128 HD Wide                1bc_code128(alltrim(curBarcodePrint.Codigo_Barra))               BC C128 HD Wide                Courier New                    Times New Roman                Times New Roman                BC C128 HD Wide                dataenvironment                _Top = 35
Left = 99
Width = 806
Height = 471
DataSource = .NULL.
Name = "Dataenvironment"
                                  ?PROCEDURE Init
if used("curBarcodePrint")
	use in curBarcodePrint
endif

local strReportLocation as String
strReportLocation = addbs(main.SystemPath) + "Reports\BarcodePrintFunctions.prg"

set proce to "&strReportLocation" additive

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
              ????    ?  ?                        Ym   %         a     -          ?  U  z %?C? curBarcodePrint???& ? Q?  ? ? ?? Q? STRING?8 T? ?C? ? ???! Reports\BarcodePrintFunctions.prg??. set proce to "&strReportLocation" additive
2 o?
 curBarcode????? ???? curBarcodePrint?? F? ? ~?X?# ??C? Criando etiquetas...CN? ?? %?? ? ??T? ?? ???(?? ??P? ^J? ? F?  ? ? _J? ? F? ? ?? ? ? #)?
 ??C? ?? F?  ? #)? U	  CURBARCODEPRINT STRREPORTLOCATION MAIN
 SYSTEMPATH
 CURBARCODE SHOWPROGRESS BARCODES
 INTCOUNTER OBJBARCODETAG Init,     ??1 ?? A ??"r ? 1q? q Q ? q A A A Q ? r Q 2                       ?      )   ?                                   ?DRIVER=winspool
DEVICE=\\a-srv62\HP_Suporte_Cenno
OUTPUT=192.168.104.122
ORIENTATION=1
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
           O  .  winspool  \\a-srv62\HP_Suporte_Cenno  192.168.104.122                                   ?\\a-srv62\HP_Suporte_Cenno       ? ?C?? 	 ?4d   X  X  A4                                                           ????                DINU" ?
?@(?R                            B                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ?  SMTJ     ?H P   L a s e r J e t   M 2 7 2 7   M F P   S e r i e s   P C L   6   InputBin FORMSOURCE RESDLL UniresDLL ESPRITSupported True HPDocUISUI True HPNUseDiffFirstPageChoice TRUE Resolution 600dpi FastRes True HPPrintInGrayScale True EMFSpoolingforPLSwoMopier True Collate OFF Orientation PORTRAIT HPOrientRotate180 False Duplex VERTICAL PaperSize A4 MediaType AUTO ColorMode Mono Economode False TextAsBlack False TTAsBitmapsSetting TTModeOutline RETChoice True HPEnableGrafitCompression True HPRequestObjectTagDump False HPRequestNullStripCommand False HPHybridRenderSwitch HPHybridPDL HPManualDuplexDialogItems InstructionID_01_FACEDOWN-NOROTATE HPManualFeedOrientation FACEDOWN HPOutputBinOrientation FACEDOWN PrintQualityGroup PQGroup_3 HPDocPropResourceData hpchl093.cab HPLpiSelection None HPColorMode MONOCHROME_MODE HPPDLType PDL_PCL6 HPPJLEncoding UTF8 HPJobAccounting HPJOBACCT_JOBACNT_GROUPNAME HPBornOnDate HPBOD HPXMLFileUsed hpc27276.xml HPEnableObjectTagging True HPEnablePageTimer False HPSmartDuplexSinglePageJob True HPSmartDuplexOddPageJob True HPEnableNullStrips True HPEnableEfficientMono FALSE HPEnableImageProcessingPath FALSE HPMonochromePrinter TRUE HPCallToWritePrinterRequired TRUE HPMemoryManager True HPGetCompressionRatioValue 17 MaxStripHeight 64 HPGetByteAlignedValueForWidth 256 HPGetDeltaRowHalfToneValue 1 HPPrintOnBothSidesManually False HPPaperSizeDuplexConstraints A3 HPMediaTypeDuplexConstraints HEAVY_111_130G HPStraightPaperPath False HPPageExceptionsFile HPCPE093 HPPageExceptionsLowEnd HPPageExceptionsLowEndVer HPPageExceptionsInterface ShowPageExceptions HPPageExceptions CoverInsertion PSAlignmentFile HPCLS093 PSServicesOption HPServiceFileNameEnd HPSmartHub Inet_SID_263_BID_514_HID_265 HPConsumerCustomPaper True HPManualDuplexDialogModel Modeless HPManualDuplexPageOrder EvenPagesFirst HPMapManualFeedToTray1 True HPManualDuplexPageRotate DriverRotate                                                                                              ?  IUPH  x????kAǿ?@i?X?"?Eo."9+ʚl?`[צD?zvS??&?? ????A????Z<(X?y?K?{C?N?KA]?|????y3?3a&ovfvƀRN]?E?????Z?#??&7???jy$???H~س??C?5?q?^?J?.??9^?Dx??&g??`?c԰?vGH*?Jv?x??t:?M?[n?H???Im^?2??:???I?1????Y<?????Ů$5G???2??В5jE?TK??3?I?S?pN?GU?N??X?b??o???*???<NژB]G.36?W?_??=??93c??k?m??e/??*???O??ń??Mx?.?"?i?BH??Y?????ot??S???????????z??w???Ղ????????{i??=?"na??z???????????H??&r/ɳfN?R??QA?Z?wi??$':?+$U?d?e?j??ӓ?T?eƙ???(c?q??*?($??;@?ʡ_,?=*U&????/??x??	?l}?9?p???
????W??|+|????{S~0?jB!?B!??!~??{?                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Courier New                    "alltrim(curBarcodePrint.descricao)                                                             Times New Roman                	"Produto"                      Times New Roman                %alltrim(curBarcodePrint.codigo_barra)                                                          Times New Roman                curBarcodePrint.Preco                                         Times New Roman                "Pre?o"                        Times New Roman                1bc_code128(alltrim(curBarcodePrint.Codigo_Barra))               BC C128 HD Wide                1bc_code128(alltrim(curBarcodePrint.Codigo_Barra))               BC C128 HD Wide                Courier New                    Times New Roman                Times New Roman                BC C128 HD Wide                dataenvironment                bTop = 83
Left = -286
Width = 1088
Height = 714
DataSource = .NULL.
Name = "Dataenvironment"
                               ?PROCEDURE Init
if used("curBarcodePrint")
	use in curBarcodePrint
endif

local strReportLocation as String
strReportLocation = addbs(main.SystemPath) + "Reports\BarcodePrintFunctions.prg"

set proce to "&strReportLocation" additive

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
                          ????    ?  ?                        ??   %         W     #          ?  U  p %?C? curBarcodePrint???& ? Q?  ? ? ?? Q? STRING?8 T? ?C? ? ???! Reports\BarcodePrintFunctions.prg??. set proce to "&strReportLocation" additive
( o?
 curBarcodeǼ?? curBarcodePrint?? F? ? ~?N?# ??C? Criando etiquetas...CN? ?? %?? ? ??J? ?? ???(?? ??F? ^J? ? F?  ? ? _J? ? F? ? ?? ? ? #)?
 ??C? ?? F?  ? #)? U	  CURBARCODEPRINT STRREPORTLOCATION MAIN
 SYSTEMPATH
 CURBARCODE SHOWPROGRESS BARCODES
 INTCOUNTER OBJBARCODETAG Init,     ??1 ?? A ???r ? 1q? q Q ? q A A A Q ? r Q 2                       ?      )   ?                                       