     @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=1
COLOR=1
nt to PDF
OUTPUT=PORTPROMPT:
ORIENTATION=0
PAPERSIZE=1
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
                      G  *  winspool  Microsoft Print to PDF  PORTPROMPT:                                                                         Courier New                                                   (WWLOGO)                                                                                                                    File(WWLOGO)                                                  curCabecalho.RAZAO_SOCIAL                                     Courier New                                                   "CNPJ: " + curCabecalho.CNPJ                                  Courier New                                                   curCabecalho.ENDERECO1                                        Courier New                                                   curCabecalho.ENDERECO2                                        Courier New                                                   curCabecalho.ENDERECO3                                        Courier New                                                   "CEP: " + curCabecalho.CEP                                    Courier New                                                   !"IE: " + alltrim(curCabecalho.IE)                             Courier New                                                   "Data.....:"                                                  Courier New                                                   *"Produto     Cor                  Tamanho"                    Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          jiif(pemstatus(main,"p_data_reimpressao_ticket_presente",5),main.p_data_reimpressao_ticket_presente,DATE())                    ""                                                            Courier New                                                   alltrim(curRPTLinha.produto)                                  Courier New                                                   !alltrim(curRPTLinha.Desc_prod_nf)                             Courier New                                                   alltrim(curRPTLinha.idTicket)                                 Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          +curRPTLinha.message1 + curRPTLinha.message2                   Arial Narrow                                                  ?IIF(PEMSTATUS(MAIN,"P_TITULO_TICKET_PRESENTE",5)AND !EMPTY(NVL(MAIN.P_TITULO_TICKET_PRESENTE,"")),MAIN.P_TITULO_TICKET_PRESENTE,"COMPROVANTE TICKET PRESENTE")                                Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          alltrim(curRPTLinha.corproduto)                               Courier New                                                   alltrim(curRPTLinha.grade)                                    Courier New                                                   "IDENTIFICADOR DO TICKET"                                     Courier New                                                   "N?o ? documento fiscal"                                      Courier New                                                   "Filial ..:"                                                  Courier New                                                   ,main.p_codigo_filial + " - " + main.p_filial                  Courier New                                                   "Ticket ..:"                                                  Courier New                                                   HSUBSTR(curRPTLinha.idticket,len(alltrim(curRPTLinha.idticket)) - 10 , 8)                                                      Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          )bc_code128(alltrim(curRPTLinha.idTicket))                     BC C128 HD Wide                                               Courier New                                                   Courier New                                                   Courier New                                                   Arial Narrow                                                  Courier New                                                   Courier New                                                   BC C128 HD Wide                                               dataenvironment                                               `Top = 375
Left = 24
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                             ?PROCEDURE BeforeOpenTables
local intAlias as Integer
intAlias = select()

if used("curCabecalho")
	use in curCabecalho
endif

public wwLogo as string
wwLogo  = strDefaultDir + "Reports\LogoReport.png"
if !file(wwLogo)
	MsgBox('Logo n?o encontrado: ' + wwLogo, 64 ,'Aten??o')
	Release wwLogo
	return .f.
endif

local strCabecalho as String

strCabecalho = ''

text to strCabecalho textmerge noshow
	SELECT Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,
	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,
	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,	       
	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '
	       + Ltrim(Rtrim(Isnull(B.NUMERO, ''))) + ' '	       
	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, ''))) AS ENDERECO1,	       
	       + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO2,
	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'
	       + Ltrim(Rtrim(Isnull(B.UF, ''))) AS ENDERECO3,
	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP	       
	FROM   LOJAS_VAREJO A
	       INNER JOIN CADASTRO_CLI_FOR B
	               ON A.FILIAL = B.NOME_CLIFOR
	       LEFT JOIN FILIAIS C
	              ON A.FILIAL = C.FILIAL
	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial
endtext

if !SQLSelect(strCabecalho, "curCabecalho", "Erro ao montar cabe?alho do relat?rio")
	return .f.
endif 

select(intAlias)
ENDPROC
                                                       9???                                ?]   %   q      ?  &   ?          ?  U  ? ??  Q? INTEGER? T?  ?CW?? %?C? curCabecalho???A ? Q? ? ? 7? Q? STRING?' T? ?? ? Reports\LogoReport.png?? %?C? 0
??? ?3 ??C? Logo n?o encontrado: ? ?@? Aten??o? ?? <? ? B?-?? ? ?? Q? STRING? T? ??  ??
 M(? `??K ?E 	SELECT Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,?C ?= 	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,?I ?C 	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,	       ?9 ?3 	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '?@ ?: 	       + Ltrim(Rtrim(Isnull(B.NUMERO, ''))) + ' '	       ?M ?G 	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, ''))) AS ENDERECO1,	       ?@ ?: 	       + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO2,?6 ?0 	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'?< ?6 	       + Ltrim(Rtrim(Isnull(B.UF, ''))) AS ENDERECO3,?I ?C 	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP	       ? ? 	FROM   LOJAS_VAREJO A?+ ?% 	       INNER JOIN CADASTRO_CLI_FOR B?1 ?+ 	               ON A.FILIAL = B.NOME_CLIFOR?! ? 	       LEFT JOIN FILIAIS C?+ ?% 	              ON A.FILIAL = C.FILIAL?5 ?/ 	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial? ?J %?C ? ? curCabecalho?% Erro ao montar cabe?alho do relat?rio? 
???? B?-?? ?
 F??  ?? U  INTALIAS CURCABECALHO WWLOGO STRDEFAULTDIR MSGBOX STRCABECALHO	 SQLSELECT BeforeOpenTables,     ??1 !? ?? A q1q q A ? ? ?1???a?????QA ?q A ? 1                       {      )                                                                                           ?DRIVER=winspool
DEVICE=Microsoft Print to PDF
OUTPUT=PORTPROMPT:
ORIENTATION=0
PAPERSIZE=1
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
                      G  *  winspool  Microsoft Print to PDF  PORTPROMPT:                                                                         Courier New                                                   (WWLOGO)                                                                                                                    File(WWLOGO)                                                  curCabecalho.RAZAO_SOCIAL                                     Courier New                                                   "CNPJ: " + curCabecalho.CNPJ                                  Courier New                                                   curCabecalho.ENDERECO1                                        Courier New                                                   curCabecalho.ENDERECO2                                        Courier New                                                   curCabecalho.ENDERECO3                                        Courier New                                                   "CEP: " + curCabecalho.CEP                                    Courier New                                                   !"IE: " + alltrim(curCabecalho.IE)                             Courier New                                                   "Data.....:"                                                  Courier New                                                   *"Produto     Cor                  Tamanho"                    Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          jiif(pemstatus(main,"p_data_reimpressao_ticket_presente",5),main.p_data_reimpressao_ticket_presente,DATE())                    ""                                                            Courier New                                                   alltrim(curRPTLinha.produto)                                  Courier New                                                   !alltrim(curRPTLinha.Desc_prod_nf)                             Courier New                                                   alltrim(curRPTLinha.idTicket)                                 Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          +curRPTLinha.message1 + curRPTLinha.message2                   Arial Narrow                                                  ?IIF(PEMSTATUS(MAIN,"P_TITULO_TICKET_PRESENTE",5)AND !EMPTY(NVL(MAIN.P_TITULO_TICKET_PRESENTE,"")),MAIN.P_TITULO_TICKET_PRESENTE,"COMPROVANTE TICKET PRESENTE")                                Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          alltrim(curRPTLinha.corproduto)                               Courier New                                                   alltrim(curRPTLinha.grade)                                    Courier New                                                   "IDENTIFICADOR DO TICKET"                                     Courier New                                                   "N?o ? documento fiscal"                                      Courier New                                                   "Filial ..:"                                                  Courier New                                                   ,main.p_codigo_filial + " - " + main.p_filial                  Courier New                                                   "Ticket ..:"                                                  Courier New                                                   HSUBSTR(curRPTLinha.idticket,len(alltrim(curRPTLinha.idticket)) - 10 , 8)                                                      Courier New                                                   $!empty(alltrim(curRPTLinha.produto))                          $!empty(alltrim(curRPTLinha.produto))                          )bc_code128(alltrim(curRPTLinha.idTicket))                     BC C128 HD Wide                                               Courier New                                                   Courier New                                                   Courier New                                                   Arial Narrow                                                  Courier New                                                   Courier New                                                   BC C128 HD Wide                                               dataenvironment                                               `Top = 375
Left = 24
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                             ?PROCEDURE BeforeOpenTables
local intAlias as Integer
intAlias = select()

if used("curCabecalho")
	use in curCabecalho
endif

public wwLogo as string
wwLogo  = strDefaultDir + "Reports\LogoReport.png"
if !file(wwLogo)
	MsgBox('Logo n?o encontrado: ' + wwLogo, 64 ,'Aten??o')
	Release wwLogo
	return .f.
endif

local strCabecalho as String

strCabecalho = ''

text to strCabecalho textmerge noshow
	SELECT Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,
	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,
	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,	       
	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '
	       + Ltrim(Rtrim(Isnull(B.NUMERO, ''))) + ' '	       
	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, ''))) AS ENDERECO1,	       
	       + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO2,
	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'
	       + Ltrim(Rtrim(Isnull(B.UF, ''))) AS ENDERECO3,
	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP	       
	FROM   LOJAS_VAREJO A
	       INNER JOIN CADASTRO_CLI_FOR B
	               ON A.FILIAL = B.NOME_CLIFOR
	       LEFT JOIN FILIAIS C
	              ON A.FILIAL = C.FILIAL
	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial
endtext

if !SQLSelect(strCabecalho, "curCabecalho", "Erro ao montar cabe?alho do relat?rio")
	return .f.
endif 

select(intAlias)
ENDPROC
                                                       9???                                ?]   %   q      ?  &   ?          ?  U  ? ??  Q? INTEGER? T?  ?CW?? %?C? curCabecalho???A ? Q? ? ? 7? Q? STRING?' T? ?? ? Reports\LogoReport.png?? %?C? 0
??? ?3 ??C? Logo n?o encontrado: ? ?@? Aten??o? ?? <? ? B?-?? ? ?? Q? STRING? T? ??  ??
 M(? `??K ?E 	SELECT Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,?C ?= 	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,?I ?C 	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,	       ?9 ?3 	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '?@ ?: 	       + Ltrim(Rtrim(Isnull(B.NUMERO, ''))) + ' '	       ?M ?G 	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, ''))) AS ENDERECO1,	       ?@ ?: 	       + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO2,?6 ?0 	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'?< ?6 	       + Ltrim(Rtrim(Isnull(B.UF, ''))) AS ENDERECO3,?I ?C 	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP	       ? ? 	FROM   LOJAS_VAREJO A?+ ?% 	       INNER JOIN CADASTRO_CLI_FOR B?1 ?+ 	               ON A.FILIAL = B.NOME_CLIFOR?! ? 	       LEFT JOIN FILIAIS C?+ ?% 	              ON A.FILIAL = C.FILIAL?5 ?/ 	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial? ?J %?C ? ? curCabecalho?% Erro ao montar cabe?alho do relat?rio? 
???? B?-?? ?
 F??  ?? U  INTALIAS CURCABECALHO WWLOGO STRDEFAULTDIR MSGBOX STRCABECALHO	 SQLSELECT BeforeOpenTables,     ??1 !? ?? A q1q q A ? ? ?1???a?????QA ?q A ? 1                       {      )                                                                                     