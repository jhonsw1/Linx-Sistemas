  0   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=2
Spooler
OUTPUT=COM1:
ORIENTATION=0
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=100
COLOR=2
YRESOLUTION=100
TTOPTION=2
COLLATE=1
                                                              -  &   winspool Daruma DR700 Spooler COM1:                   Courier New                                                   8iif(main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'')     :<VFPData>
	<reportdata name="Microsoft.VFP.Reporting.Builder.EvaluateContents" type="R" script="" execute="fonte" execwhen="main.p_FONTE_NEGRITO_RELATORIO == .T." class="" classlib="" declass="" declasslib="" penrgb="-1" fillrgb="-1" pena="255" filla="0" fname="Courier New" fsize="8" fstyle="129"/>
</VFPData>
                                                                    Courier New                                                   curCabecalho.NOME_FANTASIA                                    Courier New                                                   Aiif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.RAZAO_SOCIAL,'')                                                             Courier New                                                   >iif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO1,'')                                                                Courier New                                                   >iif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO2,'')                                                                Courier New                                                   Biif(!main.p_FONTE_NEGRITO_RELATORIO,"CEP: " + curCabecalho.CEP,'')                                                            Courier New                                                   Hiif(!main.p_FONTE_NEGRITO_RELATORIO,"Fone: " + curCabecalho.TELEFONE,'')                                                      Courier New                                                   (WWLOGO)                                                                                                                    File(WWLOGO)                                                  Diif(!main.p_FONTE_NEGRITO_RELATORIO,"CNPJ: " + curCabecalho.CNPJ,'')                                                          Courier New                                                   @iif(!main.p_FONTE_NEGRITO_RELATORIO,"IE: " + curCabecalho.IE,'')                                                              Courier New                                                   @iif(!main.p_FONTE_NEGRITO_RELATORIO,"IM: " + curCabecalho.IM,'')                                                              Courier New                                                   9iif(!main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'')                                                                    :<VFPData>
	<reportdata name="Microsoft.VFP.Reporting.Builder.EvaluateContents" type="R" script="" execute="fonte" execwhen="main.p_FONTE_NEGRITO_RELATORIO == .T." class="" classlib="" declass="" declasslib="" penrgb="-1" fillrgb="-1" pena="255" filla="0" fname="Courier New" fsize="8" fstyle="129"/>
</VFPData>
                                                                    Courier New                                                   @iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.RAZAO_SOCIAL,'')                                                              Courier New                                                   Ciif(main.p_FONTE_NEGRITO_RELATORIO,"CNPJ: " + curCabecalho.CNPJ,'')                                                           Courier New                                                   =iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO1,'')                                                                 Courier New                                                   =iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO2,'')                                                                 Courier New                                                   Aiif(main.p_FONTE_NEGRITO_RELATORIO,"CEP: " + curCabecalho.CEP,'')                                                             Courier New                                                   Giif(main.p_FONTE_NEGRITO_RELATORIO,"Fone: " + curCabecalho.TELEFONE,'')                                                       Courier New                                                   ?iif(main.p_FONTE_NEGRITO_RELATORIO,"IE: " + curCabecalho.IE,'')                                                               Courier New                                                   ?iif(main.p_FONTE_NEGRITO_RELATORIO,"IM: " + curCabecalho.IM,'')                                                               Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                              ?PROCEDURE BeforeOpenTables
*!* TP9543340 - #2# - Jorge Damasco (28/07/2015) - Cria??o de dois controles de impress?o do curRPTLinha onde passar? a verificar o par?metro
*!*													FONTE_NEGRITO_RELATORIO que ir? definir se a impress?o ser? ou n?o em negrito:
*!*													FONTE_NEGRITO_RELATORIO = .T. - iif(main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'') - NEGRITO
*!*													FONTE_NEGRITO_RELATORIO = .F. - iif(!main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'') - NORMAL
*!* TP9543340 - #1# - Jorge Damasco (27/07/2015) - Cria??o do cabe?alho para os relat?rios que chamam o report TEF do LinxPOS.

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
	SELECT Ltrim(Rtrim(Isnull(A.FILIAL, '')))           AS NOME_FANTASIA,
	       Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,
	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,
	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,
	       Ltrim(Rtrim(Isnull(B.IM, '')))               AS IM,
	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '
	       + Ltrim(Rtrim(Isnull(B.NUMERO, '')))
	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, '')))
	       + ' - ' + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO1,
	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'
	       + Ltrim(Rtrim(Isnull(B.UF, ''))) + ' - '
	       + Ltrim(Rtrim(Isnull(B.PAIS, '')))           AS ENDERECO2,
	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP,
	       + '(' + Ltrim(Rtrim(Isnull(B.DDD1, ''))) + ') '
	       + Ltrim(Rtrim(Isnull(B.TELEFONE1, '')))      AS TELEFONE
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
         j???    Q  Q                        ??   %   ?        +   ?          ?  U   ??  Q? INTEGER? T?  ?CW?? %?C? curCabecalho???A ? Q? ? ? 7? Q? STRING?' T? ?? ? Reports\LogoReport.png?? %?C? 0
??? ?3 ??C? Logo n?o encontrado: ? ?@? Aten??o? ?? <? ? B?-?? ? ?? Q? STRING? T? ??  ??
 M(? `??L ?F 	SELECT Ltrim(Rtrim(Isnull(A.FILIAL, '')))           AS NOME_FANTASIA,?K ?E 	       Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,?C ?= 	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,?A ?; 	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,?A ?; 	       Ltrim(Rtrim(Isnull(B.IM, '')))               AS IM,?9 ?3 	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '?2 ?, 	       + Ltrim(Rtrim(Isnull(B.NUMERO, '')))?7 ?1 	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, '')))?H ?B 	       + ' - ' + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO1,?6 ?0 	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'?6 ?0 	       + Ltrim(Rtrim(Isnull(B.UF, ''))) + ' - '?H ?B 	       + Ltrim(Rtrim(Isnull(B.PAIS, '')))           AS ENDERECO2,?B ?< 	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP,?= ?7 	       + '(' + Ltrim(Rtrim(Isnull(B.DDD1, ''))) + ') '?F ?@ 	       + Ltrim(Rtrim(Isnull(B.TELEFONE1, '')))      AS TELEFONE? ? 	FROM   LOJAS_VAREJO A?+ ?% 	       INNER JOIN CADASTRO_CLI_FOR B?1 ?+ 	               ON A.FILIAL = B.NOME_CLIFOR?! ? 	       LEFT JOIN FILIAIS C?+ ?% 	              ON A.FILIAL = C.FILIAL?5 ?/ 	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial? ?J %?C ? ? curCabecalho?% Erro ao montar cabe?alho do relat?rio? 
??? B?-?? ?
 F??  ?? U  INTALIAS CURCABECALHO WWLOGO STRDEFAULTDIR MSGBOX STRCABECALHO	 SQLSELECT BeforeOpenTables,     ??1 '? ?? A q1q q A ? ? ??1?!q?aa?!?a???QA ?q A ? 2                       ?      )   Q                                      ?DRIVER=winspool
DEVICE=Daruma DR700 Spooler
OUTPUT=COM1:
ORIENTATION=0
PAPERSIZE=9
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=100
COLOR=2
YRESOLUTION=100
TTOPTION=2
COLLATE=1
                                                              -  &   winspool Daruma DR700 Spooler COM1:                   Courier New                                                   8iif(main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'')     :<VFPData>
	<reportdata name="Microsoft.VFP.Reporting.Builder.EvaluateContents" type="R" script="" execute="fonte" execwhen="main.p_FONTE_NEGRITO_RELATORIO == .T." class="" classlib="" declass="" declasslib="" penrgb="-1" fillrgb="-1" pena="255" filla="0" fname="Courier New" fsize="8" fstyle="129"/>
</VFPData>
                                                                    Courier New                                                   curCabecalho.NOME_FANTASIA                                    Courier New                                                   Aiif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.RAZAO_SOCIAL,'')                                                             Courier New                                                   >iif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO1,'')                                                                Courier New                                                   >iif(!main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO2,'')                                                                Courier New                                                   Biif(!main.p_FONTE_NEGRITO_RELATORIO,"CEP: " + curCabecalho.CEP,'')                                                            Courier New                                                   Hiif(!main.p_FONTE_NEGRITO_RELATORIO,"Fone: " + curCabecalho.TELEFONE,'')                                                      Courier New                                                   (WWLOGO)                                                                                                                    File(WWLOGO)                                                  Diif(!main.p_FONTE_NEGRITO_RELATORIO,"CNPJ: " + curCabecalho.CNPJ,'')                                                          Courier New                                                   @iif(!main.p_FONTE_NEGRITO_RELATORIO,"IE: " + curCabecalho.IE,'')                                                              Courier New                                                   @iif(!main.p_FONTE_NEGRITO_RELATORIO,"IM: " + curCabecalho.IM,'')                                                              Courier New                                                   9iif(!main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'')                                                                    :<VFPData>
	<reportdata name="Microsoft.VFP.Reporting.Builder.EvaluateContents" type="R" script="" execute="fonte" execwhen="main.p_FONTE_NEGRITO_RELATORIO == .T." class="" classlib="" declass="" declasslib="" penrgb="-1" fillrgb="-1" pena="255" filla="0" fname="Courier New" fsize="8" fstyle="129"/>
</VFPData>
                                                                    Courier New                                                   @iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.RAZAO_SOCIAL,'')                                                              Courier New                                                   Ciif(main.p_FONTE_NEGRITO_RELATORIO,"CNPJ: " + curCabecalho.CNPJ,'')                                                           Courier New                                                   =iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO1,'')                                                                 Courier New                                                   =iif(main.p_FONTE_NEGRITO_RELATORIO,curCabecalho.ENDERECO2,'')                                                                 Courier New                                                   Aiif(main.p_FONTE_NEGRITO_RELATORIO,"CEP: " + curCabecalho.CEP,'')                                                             Courier New                                                   Giif(main.p_FONTE_NEGRITO_RELATORIO,"Fone: " + curCabecalho.TELEFONE,'')                                                       Courier New                                                   ?iif(main.p_FONTE_NEGRITO_RELATORIO,"IE: " + curCabecalho.IE,'')                                                               Courier New                                                   ?iif(main.p_FONTE_NEGRITO_RELATORIO,"IM: " + curCabecalho.IM,'')                                                               Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   dataenvironment                                               _Top = 220
Left = 1
Width = 520
Height = 200
DataSource = .NULL.
Name = "Dataenvironment"
                              ?PROCEDURE BeforeOpenTables
*!* TP9543340 - #2# - Jorge Damasco (28/07/2015) - Cria??o de dois controles de impress?o do curRPTLinha onde passar? a verificar o par?metro
*!*													FONTE_NEGRITO_RELATORIO que ir? definir se a impress?o ser? ou n?o em negrito:
*!*													FONTE_NEGRITO_RELATORIO = .T. - iif(main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'') - NEGRITO
*!*													FONTE_NEGRITO_RELATORIO = .F. - iif(!main.p_FONTE_NEGRITO_RELATORIO,curRPTLinha.LINHA,'') - NORMAL
*!* TP9543340 - #1# - Jorge Damasco (27/07/2015) - Cria??o do cabe?alho para os relat?rios que chamam o report TEF do LinxPOS.

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
	SELECT Ltrim(Rtrim(Isnull(A.FILIAL, '')))           AS NOME_FANTASIA,
	       Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,
	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,
	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,
	       Ltrim(Rtrim(Isnull(B.IM, '')))               AS IM,
	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '
	       + Ltrim(Rtrim(Isnull(B.NUMERO, '')))
	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, '')))
	       + ' - ' + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO1,
	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'
	       + Ltrim(Rtrim(Isnull(B.UF, ''))) + ' - '
	       + Ltrim(Rtrim(Isnull(B.PAIS, '')))           AS ENDERECO2,
	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP,
	       + '(' + Ltrim(Rtrim(Isnull(B.DDD1, ''))) + ') '
	       + Ltrim(Rtrim(Isnull(B.TELEFONE1, '')))      AS TELEFONE
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
         j???    Q  Q                        ??   %   ?        +   ?          ?  U   ??  Q? INTEGER? T?  ?CW?? %?C? curCabecalho???A ? Q? ? ? 7? Q? STRING?' T? ?? ? Reports\LogoReport.png?? %?C? 0
??? ?3 ??C? Logo n?o encontrado: ? ?@? Aten??o? ?? <? ? B?-?? ? ?? Q? STRING? T? ??  ??
 M(? `??L ?F 	SELECT Ltrim(Rtrim(Isnull(A.FILIAL, '')))           AS NOME_FANTASIA,?K ?E 	       Ltrim(Rtrim(Isnull(B.RAZAO_SOCIAL, '')))     AS RAZAO_SOCIAL,?C ?= 	       Ltrim(Rtrim(Isnull(B.CGC_CPF, '')))          AS CNPJ,?A ?; 	       Ltrim(Rtrim(Isnull(B.RG_IE, '')))            AS IE,?A ?; 	       Ltrim(Rtrim(Isnull(B.IM, '')))               AS IM,?9 ?3 	       Ltrim(Rtrim(Isnull(B.ENDERECO, ''))) + ', '?2 ?, 	       + Ltrim(Rtrim(Isnull(B.NUMERO, '')))?7 ?1 	       + Ltrim(Rtrim(Isnull(B.COMPLEMENTO, '')))?H ?B 	       + ' - ' + Ltrim(Rtrim(Isnull(B.BAIRRO, ''))) AS ENDERECO1,?6 ?0 	       Ltrim(Rtrim(Isnull(B.CIDADE, ''))) + '/'?6 ?0 	       + Ltrim(Rtrim(Isnull(B.UF, ''))) + ' - '?H ?B 	       + Ltrim(Rtrim(Isnull(B.PAIS, '')))           AS ENDERECO2,?B ?< 	       Ltrim(Rtrim(Isnull(B.CEP, '')))              AS CEP,?= ?7 	       + '(' + Ltrim(Rtrim(Isnull(B.DDD1, ''))) + ') '?F ?@ 	       + Ltrim(Rtrim(Isnull(B.TELEFONE1, '')))      AS TELEFONE? ? 	FROM   LOJAS_VAREJO A?+ ?% 	       INNER JOIN CADASTRO_CLI_FOR B?1 ?+ 	               ON A.FILIAL = B.NOME_CLIFOR?! ? 	       LEFT JOIN FILIAIS C?+ ?% 	              ON A.FILIAL = C.FILIAL?5 ?/ 	WHERE  A.CODIGO_FILIAL = ?main.p_codigo_filial? ?J %?C ? ? curCabecalho?% Erro ao montar cabe?alho do relat?rio? 
??? B?-?? ?
 F??  ?? U  INTALIAS CURCABECALHO WWLOGO STRDEFAULTDIR MSGBOX STRCABECALHO	 SQLSELECT BeforeOpenTables,     ??1 '? ?? A q1q q A ? ? ??1?!q?aa?!?a???QA ?q A ? 2                       ?      )   Q                                