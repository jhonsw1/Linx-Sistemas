   ?   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=1
PAPERSIZE=9
COLOR=2
nno on a-srv62 (redirected 1)
OUTPUT=TS001
ORIENTATION=1
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=0
                              U  >  winspool  HP_Suporte_Cenno on a-srv62 (redirected 1)  TS001                                                           Courier New                                                   (wLogo)                                                       @iif(type('wLogo')='C' and !EMPTY(wLogo) and FILE(wLogo),.t.,.f.)                                                              #"Relat?rio de lan?amentos de caixa"                           Arial                                                         main.p_filial                                                                                                               Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ("LinxPOS " + alltrim(main.p_versao_loja)                      Arial                                                         (Curlojacaixalancamentos.lancamento_caixa                      Courier New                                                   'Curlojacaixalancamentos.desc_lanc_caixa                       Courier New                                                   Curlojacaixalancamentos.data                                  Courier New                                                   ?iIf(Curlojacaixalancamentos.indicador_mov_caixa == "E", "ENTRADA", iIf(Curlojacaixalancamentos.indicador_mov_caixa == "S", "SA?DA", "IND"))                                                   Courier New                                                   ?iIf(Upper(AllTrim(Curlojacaixalancamentos.indicador_mov_caixa)) == 'E', Curlojacaixalancamentos.entrada_caixa,  Curlojacaixalancamentos.saida_caixa)                                          "@B 9,999,999.99"                                             Courier New                                                   DAllTrim(Nvl(Evl(Curlojacaixalancamentos.historico, "----"), "----"))                                                          Courier New                                                   
"N? Lanc."                                                    Courier New                                                   "Data"                                                        Courier New                                                   "Descri??o"                                                   Courier New                                                   "Valor"                                                       Courier New                                                   "Hist?rico"                                                   Courier New                                                   "Tipo"                                                        Courier New                                                   LCurlojacaixalancamentos.entrada_caixa +  Curlojacaixalancamentos.saida_caixa                                                  Courier New                                                   "Total Geral"                                                 Courier New                                                   wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                      Courier New                                                   Arial                                                         Arial                                                         Times New Roman                                               Arial                                                         Courier New                                                   dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                             IPROCEDURE Destroy
if empty(wOrdemRelMovCaixa)
	select curLojaCaixaLancamentos
	set order to
else
	set order to tag &wOrdemRelMovCaixa in curLojaCaixaLancamentos
endif

try
	go wRecNoRelMovCaixa in curLojaCaixaLancamentos
catch
endtry

if type("wOrdemRelMovCaixa") != 'U'
	release wOrdemRelMovCaixa
endif

if type("wRecNoRelMovCaixa") != 'U'
	release wRecNoRelMovCaixa
endif

ENDPROC
PROCEDURE Init
if type("wOrdemRelMovCaixa") != "U"
	release wOrdemRelMovCaixa
endif

if type("wRecNoRelMovCaixa") != "U"
	release wRecNoRelMovCaixa
endif

public wOrdemRelMovCaixa, wRecNoRelMovCaixa

select curLojaCaixaLancamentos
wRecNoRelMovCaixa = recno("curLojaCaixaLancamentos")
wOrdemRelMovCaixa = tag()

index on dtos(data) + alltrim(Lancamento_Caixa) tag TagRelMvCx
go top in curLojaCaixaLancamentos

ENDPROC
                                                    Y???    @  @                        ?   %   ?      ?     ?          ?  U  ?  %?C?  ??? ? F? ? G((? ?f ?B set order to tag &wOrdemRelMovCaixa in curLojaCaixaLancamentos
 ? ?? ? #? ?? ?? ??? ? ??% %?C? wOrdemRelMovCaixab? U??? ? <?  ? ?% %?C? wRecNoRelMovCaixab? U??? ? <? ? ? U  WORDEMRELMOVCAIXA CURLOJACAIXALANCAMENTOS WRECNORELMOVCAIXA? % %?C? wOrdemRelMovCaixab? U??, ? <?  ? ?% %?C? wRecNoRelMovCaixab? U??\ ? <? ? ? 7?  ? ? F? ?& T? ?C? curLojaCaixaLancamentosO?? T?  ?C??? & ?C? ?C? ???? ?	 #? )? U  WORDEMRELMOVCAIXA WRECNORELMOVCAIXA CURLOJACAIXALANCAMENTOS DATA LANCAMENTO_CAIXA
 TAGRELMVCX Destroy,     ?? Init]    ??1 ? q a ? !A ? ? ? A Rq A Rq A 3 Qq A Rq A ? r a? b? 2                       ?        ?  >      )   @                                                       ?DRIVER=winspool
DEVICE=HP_Suporte_Cenno on a-srv62 (redirected 1)
OUTPUT=TS001
ORIENTATION=1
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
DUPLEX=1
YRESOLUTION=600
TTOPTION=3
COLLATE=0
                              U  >  winspool  HP_Suporte_Cenno on a-srv62 (redirected 1)  TS001                                                           Courier New                                                   (wLogo)                                                       @iif(type('wLogo')='C' and !EMPTY(wLogo) and FILE(wLogo),.t.,.f.)                                                              #"Relat?rio de lan?amentos de caixa"                           Arial                                                         main.p_filial                                                                                                               Arial                                                         %dtoc(date()) + ' - ' + time() + 'hs.'                                                                                       Times New Roman                                               'Pg: ' + alltrim(str(_pageno))                                                                                              Arial                                                         ("LinxPOS " + alltrim(main.p_versao_loja)                      Arial                                                         (Curlojacaixalancamentos.lancamento_caixa                      Courier New                                                   'Curlojacaixalancamentos.desc_lanc_caixa                       Courier New                                                   Curlojacaixalancamentos.data                                  Courier New                                                   ?iIf(Curlojacaixalancamentos.indicador_mov_caixa == "E", "ENTRADA", iIf(Curlojacaixalancamentos.indicador_mov_caixa == "S", "SA?DA", "IND"))                                                   Courier New                                                   ?iIf(Upper(AllTrim(Curlojacaixalancamentos.indicador_mov_caixa)) == 'E', Curlojacaixalancamentos.entrada_caixa,  Curlojacaixalancamentos.saida_caixa)                                          "@B 9,999,999.99"                                             Courier New                                                   DAllTrim(Nvl(Evl(Curlojacaixalancamentos.historico, "----"), "----"))                                                          Courier New                                                   
"N? Lanc."                                                    Courier New                                                   "Data"                                                        Courier New                                                   "Descri??o"                                                   Courier New                                                   "Valor"                                                       Courier New                                                   "Hist?rico"                                                   Courier New                                                   "Tipo"                                                        Courier New                                                   LCurlojacaixalancamentos.entrada_caixa +  Curlojacaixalancamentos.saida_caixa                                                  Courier New                                                   "Total Geral"                                                 Courier New                                                   Courier New                                                   Arial                                                         Arial                                                         Times New Roman                                               Arial                                                         Courier New                                                   dataenvironment                                               `Top = 40
Left = 433
Width = 649
Height = 334
DataSource = .NULL.
Name = "Dataenvironment"
                             IPROCEDURE Init
if type("wOrdemRelMovCaixa") != "U"
	release wOrdemRelMovCaixa
endif

if type("wRecNoRelMovCaixa") != "U"
	release wRecNoRelMovCaixa
endif

public wOrdemRelMovCaixa, wRecNoRelMovCaixa

select curLojaCaixaLancamentos
wRecNoRelMovCaixa = recno("curLojaCaixaLancamentos")
wOrdemRelMovCaixa = tag()

index on dtos(data) + alltrim(Lancamento_Caixa) tag TagRelMvCx
go top in curLojaCaixaLancamentos

ENDPROC
PROCEDURE Destroy
if empty(wOrdemRelMovCaixa)
	select curLojaCaixaLancamentos
	set order to
else
	set order to tag &wOrdemRelMovCaixa in curLojaCaixaLancamentos
endif

try
	go wRecNoRelMovCaixa in curLojaCaixaLancamentos
catch
endtry

if type("wOrdemRelMovCaixa") != 'U'
	release wOrdemRelMovCaixa
endif

if type("wRecNoRelMovCaixa") != 'U'
	release wRecNoRelMovCaixa
endif

ENDPROC
                                                    Y???    @  @                        ?   %   ?      ?     ?          ?  U  ? % %?C? wOrdemRelMovCaixab? U??, ? <?  ? ?% %?C? wRecNoRelMovCaixab? U??\ ? <? ? ? 7?  ? ? F? ?& T? ?C? curLojaCaixaLancamentosO?? T?  ?C??? & ?C? ?C? ???? ?	 #? )? U  WORDEMRELMOVCAIXA WRECNORELMOVCAIXA CURLOJACAIXALANCAMENTOS DATA LANCAMENTO_CAIXA
 TAGRELMVCX?  %?C?  ??? ? F? ? G((? ?f ?B set order to tag &wOrdemRelMovCaixa in curLojaCaixaLancamentos
 ? ?? ? #? ?? ?? ??? ? ??% %?C? wOrdemRelMovCaixab? U??? ? <?  ? ?% %?C? wRecNoRelMovCaixab? U??? ? <? ? ? U  WORDEMRELMOVCAIXA CURLOJACAIXALANCAMENTOS WRECNORELMOVCAIXA Init,     ?? DestroyY    ??1 Qq A Rq A ? r a? b? 3 ? q a ? !A ? ? ? A Rq A Rq A 2                       ?        ?  >      )   @                                                       wLogo                                                         "Reports\LogoReport.png"                                      "Reports\LogoReport.png"                                