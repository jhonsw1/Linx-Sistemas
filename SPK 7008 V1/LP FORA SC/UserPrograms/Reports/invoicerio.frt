  �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Draft 17cpi                    5TITULO=
CRIADOR=
PADRAO=N
PUBLICO=N
FAVORITOS=;
           `curImpressaoNFItens.codigo_filial + curImpressaoNFItens.nf_numero + curImpressaoNFItens.serie_nf                                  curImpressaoNFItens.n_form                                      curImpressaoNF.cfop            Draft 17cpi                    !curImpressaoNF.natureza_descricao                               Draft 17cpi                    �iif(curImpressaoNF.pj_pf, transform(curImpressaoNF.cgc_cpf, "@R 99.999.999/9999-99"), transform(curImpressaoNF.cgc_cpf, "@R 999.999.999-99"))                      Draft 17cpi                    curImpressaoNF.endereco        Draft 17cpi                    curImpressaoNF.razao_social                                     Draft 17cpi                    curImpressaoNF.cep             Draft 17cpi                    curImpressaoNF.cidade          Draft 17cpi                    curImpressaoNF.telefone        7 '('+allt(Cur_Print_NF.ddd1)+')'+Cur_Print_NF.telefone1         Draft 17cpi                    curImpressaoNF.uf              Draft 17cpi                    curImpressaoNF.rg_ie           Draft 17cpi                    curImpressaoNF.emissao         Draft 17cpi                    curImpressaoNF.data_saida      # Impressao depende do Print When...                             Draft 17cpi                    
bPrintDate                     curImpressaoNF.bairro          Draft 17cpi                    ''                             Draft 17cpi                    ''                             Draft 17cpi                    curImpressaoNFItens.valor_item                                  Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        Wiif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.frete)          Draft 17cpi                    Xiif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.seguro)         Draft 17cpi                    Viif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.icms)           Draft 17cpi                    Uiif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.ipi)            Draft 17cpi                    "curImpressaoNF.transp_razao_social                              Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.transp_endereco                                  Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        'iif(curImpressaoNF.frete_a_pagar, 1, 2)                         "@B"                           Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.transp_cidade                                    Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.transp_uf       Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.transp_inscricao                                 Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        =transform(curImpressaoNF.transp_cgc, "@R 99.999.999/9999-99")                                    Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.tipo_volume                                      Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.volumes         Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.peso_bruto      Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.peso_liquido                                     Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        curImpressaoNF.nf_numero       Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        [iif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.icms_base)      Draft 17cpi                    curImpressaoNF.icms > 0        e"Folha: " + padl(curImpressaoNFItens.n_form, 2, "0") + "/" + padl(curImpressaoNFItens.t_form, 2, "0")                             Draft 17cpi                    ]iif(curImpressaoNFItens.n_form < curImpressaoNFItens.t_form, 1/0, curImpressaoNF.valor_total)                                     "99999999999.99"               Draft 17cpi                    ,substr(curImpressaoNFItens.codigo_item,1,10)                    Draft 17cpi                    8substr(alltrim(curImpressaoNFItens.descricao_item),1,25)        Draft 17cpi                    curImpressaoNFItens.valor_item                                  Draft 17cpi                    !curImpressaoNFItens.icms_aliquota                               "99"                           Draft 17cpi                     curImpressaoNFItens.ipi_aliquota                                "99"                           Draft 17cpi                    curImpressaoNFItens.ipi        Draft 17cpi                    Ualltrim(curImpressaoNFItens.tribut_origem) + alltrim(curImpressaoNFItens.tribut_icms)            Draft 17cpi                    curImpressaoNFItens.unidade                                     Draft 17cpi                    curImpressaoNFItens.qtde_item                                   "99999.999"                    Draft 17cpi                    J! (curImpressaoNFItens.qtde_item - INT(curImpressaoNFItens.qtde_item)) = 0                       +ROUND(curImpressaoNFItens.preco_unitario,2)                     Draft 17cpi                    curImpressaoNFItens.qtde_item                                   "99999"                        Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        $"Continua no pr�ximo formul�rio ..."                                                           Draft 17cpi                    7curImpressaoNFItens.n_form < curImpressaoNFItens.t_form         '"Desconto (                          )"                         Draft 17cpi                    XcurImpressaoNF.desconto > 0 and curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form         curImpressaoNF.desconto        Draft 17cpi                    XcurImpressaoNF.desconto > 0 and curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form         "curImpressaoNF.percentual_desconto                              	"999.99%"                      Draft 17cpi                    XcurImpressaoNF.desconto > 0 and curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form         
"Encargos"                     Draft 17cpi                    WcurImpressaoNF.encargo > 0 and curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form          Iiif(curImpressaoNF.tipo_volume = "BAZAR"," ",nvl(curImpressaoNF.obs, ""))                        Draft 17cpi                    curImpressaoNF.encargo         Draft 17cpi                    XcurImpressaoNF.encargo > 0  and curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form         ?"[  NF  HERING  >> ( Largura: 25,40cm  x  Altura: 33,49cm )  ]"                                  Draft 17cpi                    .f.                            curImpressaoNF.nf_numero       Draft 17cpi                    1"(" + alltrim(curImpressaoNF.codigo_clifor) + ")"               Draft 17cpi                    "X"                            Draft 17cpi                    curImpressaoNF.recebimento=.f.                                  "X"                            Draft 17cpi                    curImpressaoNF.recebimento                                      
"<- Sa�da"                     Draft 17cpi                    .f.                            "<- Entrada"                   Draft 17cpi                    .f.                            "Total de pe�as"               Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        ''                             Draft 17cpi                    curImpressaoNF.transp_uf       Draft 17cpi                    8curImpressaoNFItens.n_form >= curImpressaoNFItens.t_form        '.'+F_Load_Ctrl_Excecao()      Draft 17cpi                    ''                             dataenvironment                Draft 17cpi                    ,substr(curImpressaoNFItens.codigo_item,11,3)                    Draft 17cpi                    "."                            Draft 17cpi                    �'NSU: '+padl(alltrim(str(curImpressaoNF.sequencial_unico)),10,'0')+'   '+ttoc(curImpressaoNF.data_geracao_nsu)+'      IMP:'+ttoc(datetime())                       Draft 17cpi                    !curImpressaoNF.sequencial_unico>0                               ''                             Draft 17cpi                    '.'                            Draft 17cpi                    curImpressaoNFItens.qtde_item                                   "99999"                        Draft 17cpi                    H(curImpressaoNFItens.qtde_item - INT(curImpressaoNFItens.qtde_item)) = 0                         '.'                            Draft 17cpi                    curImpressaoNF.nf_numero       Draft 17cpi                    nvl(curImpressaoNF.obs, "")                                     Draft 17cpi                    $curImpressaoNF.tipo_volume = "BAZAR"                            bSendToPrinter                 "bSendToPrinter or sys(2040) == "2"                              "bSendToPrinter or sys(2040) == "2"                              Draft 17cpi                    Draft 17cpi                    �Top = 177
Left = 383
Width = 474
Height = 353
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                    	PROCEDURE Destroy
set procedure to &strProce
release strProce, bPrintDate, Ext1, Ext2, Ext3

select curNFFinanceiro
use

select curImpressaoNF
use

select curImpressaoNFItens
USE

select curDadosFilial
USE

ENDPROC
PROCEDURE Init
public strProce as string, bPrintDate as Boolean, Ext1 as string, Ext2 as string, Ext3 as string
local strSelect as string

strSelect = "SELECT * FROM CADASTRO_CLI_FOR WHERE CLIFOR = ?main.p_codigo_filial"
if !SQLSelect(strSelect, "curDadosFilial", "Erro pesquisando dados da filial para impress�o")
	return .f.
endif

bSendToPrinter = .f.
bPrintDate = MsgBox("Deseja imprimir a data de sa�da?", 4 + 32 + 256, "Aten��o") == 6


SQLEXECUTE([ UPDATE LOJA_NOTA_FISCAL SET OBS = CHAR(13)+CONVERT(CHAR(250),OBS)  ]+;
		   [ FROM LOJA_NOTA_FISCAL ]+;
		   [ WHERE  LOJA_NOTA_FISCAL.NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND ]+;
		   [ LOJA_NOTA_FISCAL.SERIE_NF  = ?curLojaNotaFiscal.serie_nf AND OBS NOT LIKE CHAR(13)+'%'])


strSelect = "SELECT * FROM W_IMPRESSAO_NF_LOJA WHERE CODIGO_FILIAL = ?curLojaNotaFiscal.codigo_filial " + ;
	"AND NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND SERIE_NF = ?curLojaNotaFiscal.serie_nf"
if !SQLSelect(strSelect, "curImpressaoNF", "Erro pesquisando dados da nota fiscal para impress�o")
	return .f.
endif

strSelect = "SELECT CONVERT(INT, 0) AS T_FORM, CONVERT(INT, 0) AS N_FORM, * " + ;
	"FROM W_IMPRESSAO_NF_LOJA_ITENS WHERE CODIGO_FILIAL = ?curLojaNotaFiscal.codigo_filial " + ;
	"AND NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND SERIE_NF = ?curLojaNotaFiscal.serie_nf"
if !SQLSelect(strSelect, "curImpressaoNFItens", "Erro pesquisando itens da nota fiscal para impress�o")
	return .f.
ENDIF

select curDadosFilial
go top

strProce = set("Procedure")
set procedure to InvoiceFunctions.prg additive
F_Load_Ctrl_NF_Form()
F_Load_Ctrl_NF_Financ()

select curNFFinanceiro
index on codigo_filial + nf_numero + serie_nf tag tagParcela
go top

select curImpressaoNF
index on codigo_filial + nf_numero + serie_nf tag tagNF
*!*	set relation to codigo_filial + nf_numero + serie_nf into curNFFinanceiro
go top

select curImpressaoNFItens
index on codigo_filial + nf_numero + serie_nf + item_impressao tag tagItens
set relation to codigo_filial + nf_numero + serie_nf into curImpressaoNF
go top


ENDPROC
      	���    �  �                        ��   %         �  .   9          �  U  d  set procedure to &strProce
 <�  � � � � � F� � Q� F� � Q� F� � Q� F� � Q� U	  STRPROCE
 BPRINTDATE EXT1 EXT2 EXT3 CURNFFINANCEIRO CURIMPRESSAONF CURIMPRESSAONFITENS CURDADOSFILIAL�J 7�  Q� STRING� Q� BOOLEAN� Q� STRING� Q� STRING� Q� STRING� �� Q� STRING�P T� ��C SELECT * FROM CADASTRO_CLI_FOR WHERE CLIFOR = ?main.p_codigo_filial��V %�C � � curDadosFilial�/ Erro pesquisando dados da filial para impress�o� 
��� B�-�� � T� �-��C T� �C�  Deseja imprimir a data de sa�da?�$� Aten��o� �����C�D  UPDATE LOJA_NOTA_FISCAL SET OBS = CHAR(13)+CONVERT(CHAR(250),OBS)  �  FROM LOJA_NOTA_FISCAL �F  WHERE  LOJA_NOTA_FISCAL.NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND �W  LOJA_NOTA_FISCAL.SERIE_NF  = ?curLojaNotaFiscal.serie_nf AND OBS NOT LIKE CHAR(13)+'%'�	 ��� T� ��Y SELECT * FROM W_IMPRESSAO_NF_LOJA WHERE CODIGO_FILIAL = ?curLojaNotaFiscal.codigo_filial �W AND NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND SERIE_NF = ?curLojaNotaFiscal.serie_nf��[ %�C � � curImpressaoNF�4 Erro pesquisando dados da nota fiscal para impress�o� 
���� B�-�� �T� ��? SELECT CONVERT(INT, 0) AS T_FORM, CONVERT(INT, 0) AS N_FORM, * �V FROM W_IMPRESSAO_NF_LOJA_ITENS WHERE CODIGO_FILIAL = ?curLojaNotaFiscal.codigo_filial �W AND NF_NUMERO = ?curLojaNotaFiscal.nf_numero AND SERIE_NF = ?curLojaNotaFiscal.serie_nf��` %�C � � curImpressaoNFItens�4 Erro pesquisando itens da nota fiscal para impress�o� 
���� B�-�� � F�
 � #)� T�  �C�	 Procedurev�� G+(� InvoiceFunctions.prg�
 ��C� ��
 ��C� �� F� � & �� � � ��� � #)� F� � & �� � � ��� � #)� F� � & �� � � � ��� � G-(�� � � ��� � #)� U  STRPROCE
 BPRINTDATE EXT1 EXT2 EXT3	 STRSELECT	 SQLSELECT BSENDTOPRINTER MSGBOX
 SQLEXECUTE CURDADOSFILIAL INVOICEFUNCTIONS PRG F_LOAD_CTRL_NF_FORM F_LOAD_CTRL_NF_FINANC CURNFFINANCEIRO CODIGO_FILIAL	 NF_NUMERO SERIE_NF
 TAGPARCELA CURIMPRESSAONF TAGNF CURIMPRESSAONFITENS ITEM_IMPRESSAO TAGITENS Destroy,     �� Init    ��1 �qr A r A r A r A 3 �aq A � 1�q A q A r Q ��� � r aQ r aR r �qQ 3                       �         �   	      )   �                                          