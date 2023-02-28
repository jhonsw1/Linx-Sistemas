*-- SUSTSP-799  - #5# - Wendel Crespigio - tratamento para trazer os dados do endere�o correto caso exista notas com o mesmo numero e series diferentes. 
*!* MODASP-9554 - #4# - F�bio Cunha - 26/12/2019 - Corre��o para nao trazer dados cadastrais alterados para reimpress�o da NF-e ap�s aprova��o (DANFE)
*-- Objetivo: Func�es Impress�o da DANFE (Nota Fiscal Eletr�nica)
*-- Vs-Lx   : Linx8.0: DANFE NORMAL Em 31-Ago-2009 | DPEC+FSDA Em 24-Out-2009 | Vers�o Unificada (LinxERP+LinxPOS+Monitor) com Paulo Mader em 26-Mar-2010
*-- Padial  : 09/04/2010: Tratamento desconto item do total da nota para a zona franca "desconto + icms_zf + pis_zf + cofins_zf"
*-- Vs-Lx   : 03/07/2010: Endere�o de Entrega + Controle de quebra dos itens
*-- Vs-Lx   : 17/07/2010: Marcar DANFE como Impressa
*-- Vs-Lx   : 25/08/2010: Tratamento no uso da fun��o DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE (n�o pode ser usado mais que uma vez no join porque fica lento)
*-- Vs-Lx   : 25/08/2010: Tratamento quebra campo de observa��es
*-- Vs-Lx   : 01/09/2010: Incluido campo complemento_emitente
*-- Vs-Lx   : 20/09/2010: Incluido campo OBS_INTERESSE_FISCO
*-- Vs-Lx   : 17/02/2011: Tratamento para NFe Vers�o 2.0
*-- Vs-Lx   : 04/03/2011: Inclus�o de Marca e N�mero de Volumes
*-- Vs-Lx   : 07/03/2011: Tratamento quebra campo codigo_item
*-- Padial  : 24/03/2011: Erro no codigo do tipo de frete da sefaz. Estava usando o padrao do Linx que estava errado
*-- Vs-Lx   : 15/04/2011: Altera��o na ordem das faturas/parcelas (fx_ctb_simula_parcelas n�o traz na ordem)
*-- Vs-Lx   : 28/07/2011: Tratamento para NF Importa��o
*-- Padial	: 23/10/2011: Campo IM do emitente errado, faltando ISS_R
*-- Padial	: 23/10/2011: Controle da observacao do item
*-- Padial	: 23/10/2011: Controle da observacao do item (Utilizado o feito por valmir)
*-- Vs-Lx   : 23/10/2011: Tratamento para Obs do Item
*-- Padial 	: 24/10/2011: Retirado o nvl da informacao de justificativa e data
*-- Fabiano : 26/10/2011: Ajuste do campo codigo do item que estava quebrando errado para codigos caracteres
*-- 07/06/2018 - Eder Silva - DM 77925  - #1# - Tratamento para impress�o da NF-e
*-- 21/08/2018 - Eder Silva - DM 89210  - #2# - Tratamento para as novas modalidades de frete <modFrete> 3 e 4 - NT 2016_002.
*-- 14/02/2019 - Eder Silva - DM 109532 - #3# - Tratamento para impress�o dos dados de COBRAN�A (Fatura/Duplicata) no DANFE conforme Grupo Y da NT 2016.002 Vers�o 1.61 e alinhado com Roberto Beda.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure PrintNFe
Lparameter xTipo,xObj,strSerie_NF,intQtdeVias,FormMain

Local bLinxERP As boolean, strFilial As String, strNF_Numero As String
Public xKimp

bLinxERP = Pcount() == 2
intQtdeVias = Iif(Type("intQtdeVias") != "N" Or (Type("intQtdeVias") == "N" And intQtdeVias < 1), 1, Iif(intQtdeVias > 5, 5, intQtdeVias))

If !bLinxERP
	strFilial = Rtrim(xTipo)
	strNF_Numero = Alltrim(xObj)
	xTipo = 'IMP'
	Public wwLogo As String
	wwLogo  = Addbs(FormMain.SystemPath) + "Reports\LogoReport.png"
	If !File(wwLogo)
		MsgBox('Logo n�o encontrado: ' + wwLogo, 64 ,'Aten��o')
		Release wwLogo
		Return .F.
	Endif
Endif

f_select("Select valor_atual From Parametros Where Parametro='LOGO_EXCLUSIVO_DANFE'","CurTmp_LogoDanfe",Alias())
xTmpLogo = Nvl(Alltrim(CurTmp_LogoDanfe.valor_atual),'')
If !Empty(xTmpLogo) And File(xTmpLogo)
	wwLogo = xTmpLogo
Endif

xSele    = Select()
xDefault = Sys(5) + Sys(2003)

If bLinxERP
	xCodigoReport = Left(Justfname(Fx_GetReportProperty(xObj,'ReportProgramFile')), 8)
	xReportFile   = Fx_GetReportProperty(xObj,'ReportFile')
	xDirRel  	  = Substr(xReportFile,1,(At(xCodigoReport,xReportFile))-1)
Endif

xOk = Iif(Type('ReportExport')='O',Fx_Control_Obj_Export(.T.),.T.)
If !xOk
	Return .F.
Endif

If Type('ReportExport')='O'
	xSaida1  = 'Object oXFRX NOPAGEEJECT'
	xSaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
	xLenObsFrm = '9/133' && Limite de Linhas/Caracteres por linha no campo de observa��es (por formul�rio)
Else
	xSaida1  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer' + Iif(bLinxERP, ' Prompt NOPAGEEJECT', ''))
	xSaida2  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer' + Iif(bLinxERP, ' NOPAGEEJECT NORESET', ''))
	xLenObsFrm = '8/139' && Limite de Linhas/Caracteres por linha no campo de observa��es (por formul�rio)
Endif

*-- Itens por formul�rio para o DANFE
f_select("Select valor_atual From Parametros Where Parametro='ITENS_P_FORM_DANFE'","CurTmp_Itens_p_form",Alias())
xItensPD = Nvl(Alltrim(CurTmp_Itens_p_form.valor_atual),'')

If  Atc('/',xItensPD) > 0
	xItensPD1 = Val( Substr(xItensPD,1,Atc('/',xItensPD)-1) )				&& Definido por parametro Primeiro Formul�rio
	xItensPD2 = Val( Substr(xItensPD,Atc('/',xItensPD)+1,Len(xItensPD)) )	&& Definido por parametro Segundo  Formul�rio
Else
	xItensPD1 = 16 && Padr�o Primeiro Formul�rio
	xItensPD2 = 46 && Padr�o Segundo  Formul�rio
Endif


If bLinxERP
	If !Fx_DANFE_Init(xItensPD1,xItensPD2,xLenObsFrm)
		Return .F.
	Endif
Else
	If !Fx_DANFE_Init(xItensPD1,xItensPD2,xLenObsFrm, strFilial, strNF_Numero, strSerie_NF, intQtdeVias, FormMain)
		Return .F.
	Endif
Endif

*-- Formul�rios
If bLinxERP
	pLst_Reports_1 = xDirRel+'L_DANFE1.FRX'
	pLst_Reports_2 = xDirRel+'L_DANFE2.FRX'
Else
	pLst_Reports_1 = Addbs(FormMain.SystemPath) + "Reports\L_Danfe1.frx"
	pLst_Reports_2 = Addbs(FormMain.SystemPath) + "Reports\L_Danfe2.frx"
Endif

pLst_Reports_1_Cr = Strt(pLst_Reports_1,'FRX','RPT')

If !File(pLst_Reports_1)
	If !File(pLst_Reports_1_Cr)
		If bLinxERP
			Messagebox('Report N�o Encontrado: ' + Chr(13)+pLst_Reports_1,16,'Aten��o')
		Else
			MsgBox('Report N�o Encontrado:\n' + pLst_Reports_1, -16, 'Aten��o')
		Endif
		Return .F.
	Else
		pLst_Reports_1 = pLst_Reports_1_Cr
	Endif

Endif

If Justext(pLst_Reports_1)='FRX' And !File(pLst_Reports_2)
	If bLinxERP
		Messagebox('Report N�o Encontrado: ' + Chr(13) + pLst_Reports_2,16,'Aten��o')
	Else
		MsgBox('Report N�o Encontrado:\n' + pLst_Reports_2, -16, 'Aten��o')
	Endif
	Return .F.
Endif

*-- Envia para saida
Select Distinct nf,serie_nf,filial,n_form,t_form,.F. As is_ultimo From vtmp_impressao_nf_00_itens Into Cursor Cur_Lst_DANFE_Emitir Readwrite
Select Cur_Lst_DANFE_Emitir
Go Bottom
Replace is_ultimo With .T.

Local intCountReports As Integer, bPritError As boolean, strMessage As String
For intCountReports = 1 To intQtdeVias
	If !bLinxERP And intCountReports > 1
		FormMain.SetMessage("Imprimindo " + Transform(intCountReports, '9.999') + "� via...")
	Endif

	If bLinxERP And Justext(Fx_GetReportProperty(xObj,'ReportFile'))='RPT' && -- Gera Arquivos Externos (Para o Crystal)
		xObj.CopyTables("vTmp_impressao_nf_00")
		xObj.CopyTables("vTmp_impressao_nf_00_itens")
		xObj.CopyTables("Cur_FrmNfe_Obs")
		xObj.CopyTables("Cur_Ctb_Parcelas")
	Else
		Select Max(t_form) t_form From Cur_Lst_DANFE_Emitir Into Cursor CurChk_t_form

		If CurChk_t_form.t_form=1 && Mais R�pido quando s� existe NFe's de uma via no lote.
			Select vtmp_impressao_nf_00_itens
			Go Top
			xSaida = xSaida1
			xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
			Try
				Report Form (pLst_Reports_1) &xSaida && Impress�o
			Catch To oPrinterError
				strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
				If bLinxERP
					Messagebox(strMessage, -16, "Aten��o")
				Else
					MsgBox(strMessage, -16, "Aten��o")
				Endif
			Endtry
		Else
			Select Cur_Lst_DANFE_Emitir
			xRAtu = 0
			Scan
				xRAtu = xRAtu+1
				xKimp = Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)

				Select vtmp_impressao_nf_00_itens
				Set Filter To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)==xKimp
				Go Top
				xSaida = Iif(xRAtu=1,xSaida1,xSaida2)
				If Cur_Lst_DANFE_Emitir.is_ultimo
					xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
				Endif

				If n_form=1
					Try
						Report Form (pLst_Reports_1) &xSaida && Impress�o
					Catch To oPrinterError
						strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
						If bLinxERP
							Messagebox(strMessage, -16, "Aten��o")
						Else
							MsgBox(strMessage, -16, "Aten��o")
						Endif
					Endtry
				Else
					Try
						Report Form (pLst_Reports_2) &xSaida  && Impress�o
					Catch To oPrinterError
						strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
						If bLinxERP
							Messagebox(strMessage, -16, "Aten��o")
						Else
							MsgBox(strMessage, -16, "Aten��o")
						Endif
					Endtry
				Endif

				If bPritError
					Return .F.
				Endif
			Endscan
*
		Endif

		If !bLinxERP
			FormMain.SetMessage()
		Endif
	Endif
Endfor

xSentToPrinter = .T.
If Type('ReportExport')='O'
	Fx_Control_Obj_Export(.F.)
Endif

Fx_DANFE_Destroy(bLinxERP)

If bLinxERP
	Set Default To &xDefault
Endif

Try
	Select (xSele)
Catch
Endtry

Endproc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_DANFE_Init
Lparameters pItens1,pItens2,pLenObsFrm,strFilial,strNF_Numero,strSerie_NF,intQtdeVias,FormMain

Local bLinxERP As boolean
bLinxERP = Pcount() == 3

*-- NF-e (D.A.N.F.E.)
Public x_Proce,xImp_DSai,Ext1,Ext2,Ext3,xSentToPrinter

xSentToPrinter = .F.
xImp_DSai = .T. && f_msg(['Deseja Imprimir a Data de Saida?',4+32+256,'<Aviso...>'])=6

If bLinxERP
	x_Proce = Set('PROCE')
	Set Procedure To ..\Report.prg\L002016.prg Additive && Barcodes Retaguarda
	xFilterPai = Strt(o_100108.p_comando_where,'W_IMPRESSAO_NF.','W_IMPRESSAO_NFe.')
	xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + " Empresa='" + Alltrim(Str(wEmpresa_Atual)) + "'"
	xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + ' Chave_NFe is Not Null AND ((Status_nfe=5 OR Status_nfe=9) OR (Tipo_emissao_nfe=4 OR Tipo_emissao_nfe=5))'
Else
	xFilterPai = "NF = '" + Alltrim(strNF_Numero) + "' and Serie_NF = '" + Alltrim(strSerie_NF) + "' and Filial = '" + Rtrim(strFilial) + "'"
Endif

*!* #2# - Alterado tratamento do desc_entrega_cif
*!*	Antes: Case When Entrega_cif=1 THEN 'Emitente' ELSE Case When Entrega_cif=0 THEN 'Dest/Rem' ELSE Case When Entrega_cif=2 THEN 'Terceiros' ELSE Case When Entrega_cif=9 THEN 'Sem Frete' ELSE '' END END END END as desc_entrega_cif,
TEXT TO xSqlNFE_Pai NOSHOW TEXTMERGE
				SELECT filial,nf,serie_nf,chave_nfe,Origem_NF,Importacao,status_nfe,CAST(tipo_emissao_nfe AS varchar(1)) as tipo_emissao_nfe,convert(varchar(10), emissao, 103) as emissao,empresa, IsNull(ctb_lancamento,0) as ctb_lancamento, IsNull(ctb_item,0) as ctb_item,cod_transacao,convert(varchar(10), data_saida, 103) as data_saida,
					   nome_clifor,IsNull(fatura,0) as fatura,desc_nf_natureza,pj_pf,CNPJ_DESTINATARIO AS CGC_CPF,razao_social_emitente,cnpj_emitente,endereco_emitente,numero_emitente,complemento_emitente,bairro_emitente,cidade_emitente,uf_emitente,pais_emitente,cep_emitente,ddd1_emitente, telefone1_emitente,ie_emitente,iest,pj_pf_emitente,razao_social,
					   endereco,numero,complemento,bairro,cep,cidade,ddi,RIGHT(RTRIM(ddd1),2) as ddd1,RIGHT(RTRIM(dbo.FX_REPLACE_CARACTER_ESPECIAL_NFe(1,telefone1)),8) as telefone1,
					   uf,case when pj_pf=0 then '' else rg_ie end as rg_ie,icms_base,icms,icms_st_base,icms_st,icms_str_base,icms_str,valor_sub_itens,
					   Case When Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' Then (IMPORTACAO_ALFANDEGA+IMPORTACAO_OUTRAS_DESPESAS+IMPORTACAO_SEGURO+IMPORTACAO_DESEMBARACO+PIS+COFINS) Else encargo End as encargo,
					   frete,seguro,(desconto + icms_zf + pis_zf + cofins_zf) as desconto,desconto_cond_pgto,ipi,valor_total,transportadora_razao_social,
					   Case When Entrega_cif=0 then cast(1 as numeric) else case when Entrega_cif = 1 then cast(0 as numeric) else Cast(entrega_cif AS numeric) end end as entrega_cif,
					   Case Entrega_cif When 0 Then 'Dest/Rem' When 1 Then 'Emitente' When 2 Then 'Terceiros' When 3 Then 'Proprio-Rem' When 4 Then 'Proprio-Dest' When 9 Then 'Sem Frete' Else '' End as desc_entrega_cif,
					   TRANSPORTADORA_PF_PJ, transportadora_cnpj,transportadora_endereco,transportadora_cidade,transportadora_uf,transportadora_ie,volumes,tipo_volume,marca_volumes,numeracao_volumes,peso_bruto,peso_liquido,IM_EMITENTE as im,(iss + ISS_R) as iss, (iss_base +ISS_R_BASE) as iss_base  ,valor_desconto_itens,valor_sub_itens_bruto,
					   rtrim(isnull(cod_serie_sintegra,case when serie_nf = 'U' OR serie_nf = 'UN' then '0' else Rtrim(serie_nf) end)) as serie_danfe, Obs, Texto_Legal,Obs_Interesse_Fisco, data_contingencia, justificativa_contingencia,
					   CASE When Entrega_Endereco Is Not Null AND (IsNull(Endereco,'')+IsNull(Numero,'')+IsNull(Complemento,''))<>(IsNull(Entrega_Endereco,'')+IsNull(Entrega_Numero,'')+IsNull(Entrega_Complemento,'')) Then IsNull('ENTREGA: '+rTrim(entrega_endereco),'') + IsNull(', '+rTrim(entrega_numero),'') + IsNull(' - ' + rTrim(entrega_complemento),'') + ' - ' + IsNull(rTrim(entrega_cidade),'') + '/' + IsNull(rTrim(entrega_uf),'') + IsNull(' - CEP: ' + rTrim(entrega_cep),'') + Case When pj_pf=1 Then IsNull(' - CNPJ: '+rTrim(entrega_cgc),'') Else IsNull(' - CPF: ' + rTrim(entrega_cgc),'') End Else '' End as Obs_Entrega
				  From W_IMPRESSAO_NFE Where <<xFilterPai>>
ENDTEXT

f_select(xSqlNFE_Pai, "vTmp_impressao_nf_00")
If Reccount('vTmp_impressao_nf_00')=0
	Messagebox('Nenhuma NFe V�lida Selecionada no Filtro:'+Chr(13) + (xFilterPai),48,'Aviso')
	Return .F.
Endif

*INICIO #4#
strSelect = "SELECT dados_cadastro_xml_nfe.endereco, dados_cadastro_xml_nfe.bairro, dados_cadastro_xml_nfe.cidade, " +;
	"dados_cadastro_xml_nfe.uf, dados_cadastro_xml_nfe.numero, dados_cadastro_xml_nfe.complemento, dados_cadastro_xml_nfe.cep " +;
	"from dados_cadastro_xml_nfe " +;
	"where nf_saida = ?vTmp_impressao_nf_00.nf and dados_cadastro_xml_nfe.SERIE_NF = ?vTmp_impressao_nf_00.serie_nf " &&SUSTSP-243  #5#

f_select(strSelect , "curEndEmissao")

If Reccount('curEndEmissao') > 0

	Select vTmp_impressao_nf_00
	GO TOP 

	Replace cep 	With curEndEmissao.cep;
		endereco	With curEndEmissao.endereco;
		bairro		With curEndEmissao.bairro;
		cidade		With curEndEmissao.cidade;
		uf			With curEndEmissao.uf;
		numero		With curEndEmissao.numero;
		COMPLEMENTO	With curEndEmissao.COMPLEMENTO
Endif
*FIM #4#

TEXT TO xSqlNFE_Filha NOSHOW
				Select filial,nf,serie_nf,Item_Impressao,Item_NFe,sub_item_tamanho,codigo_item,descricao_item,obs_item,substring(replace(classif_fiscal,'.',''),1,8) as classif_fiscal,
					   tribut_origem,tribut_icms,codigo_fiscal_operacao,id_excecao_imposto,unidade,qtde_item,
					   preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) , (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario,
					   CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' THEN Round(qtde_item * (preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) , (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE valor_item END as valor_item,
					   icms,icms_base,ipi,icms_aliquota,ipi_aliquota,
					   valor_descontos,desconto_total_item,valor_unitario_bruto,CONVERT(Numeric(13,2),valor_item_bruto) as valor_item_bruto,frete,seguro,Importacao,Danfe_NFe_Importacao_Calc
				  From W_IMPRESSAO_NFE_ITENS Where NF=?vTmp_impressao_nf_00.NF and Serie_NF=?vTmp_impressao_nf_00.Serie_nf and Filial=?vTmp_impressao_nf_00.Filial
ENDTEXT

If bLinxERP
	xFields_Ctrl_Add = "NVL(vTmp_impressao_nf_00.status_nfe,0) as status_nfe, NVL(VAL(vTmp_impressao_nf_00.tipo_emissao_nfe),0) as tipo_emissao_nfe, 0000 as n_form,0000 as t_form, 001 as n_qb_item, .f. as ult_n_qb_item, 0 as item_add, 1 as seq_obs"
	Select vTmp_impressao_nf_00
	Count To xTreg
	xRAtu = 0
	Scan
		xRAtu = xRAtu + 1
		f_prog_bar('Gerando Itens da NFe: '+ vTmp_impressao_nf_00.nf,xRAtu,xTreg)

		f_select(xSqlNFE_Filha,'vTmp_impressao_nf_00_itens_BASE',Alias())
		If !Used('vTmp_impressao_nf_00_itens')
			Select *,&xFields_Ctrl_Add From vTmp_impressao_nf_00_itens_BASE Into Cursor vtmp_impressao_nf_00_itens Readwrite
		Else
			Insert Into vtmp_impressao_nf_00_itens Select *,&xFields_Ctrl_Add From vTmp_impressao_nf_00_itens_BASE
		Endif

	Endscan
	Use In vTmp_impressao_nf_00_itens_BASE
	f_wait()
Else
	xRunMetodo = f_select(xSqlNFE_Filha,'vTmp_impressao_nf_00_itens_Base')
	Select *, 00 As status_nfe, 00 As tipo_emissao_nfe, 0000 As n_form, 0000 As t_form, 001 As n_qb_item, .F. As ult_n_qb_item, 0 As item_add, 0000 As seq_obs ;
		From vTmp_impressao_nf_00_itens_BASE Into Cursor vtmp_impressao_nf_00_itens Readwrite

	Use In vTmp_impressao_nf_00_itens_BASE
	Replace All seq_obs With 1, status_nfe With Nvl(vTmp_impressao_nf_00.status_nfe, 0), tipo_emissao_nfe With Nvl(Val(vTmp_impressao_nf_00.tipo_emissao_nfe),0) In vtmp_impressao_nf_00_itens
Endif


*-- Reculcular 'VALOR TOTAL DOS PRODUTOS' para NFe Importa��o COM Danfe_NFe_Importacao_Calc='.T.'
Select filial,nf,serie_nf,Sum(valor_item) valor_total From vtmp_impressao_nf_00_itens ;
	WHERE Importacao=1 And Danfe_NFe_Importacao_Calc='.T.' Group By 1,2,3 Into Cursor CurTmp_CalcSubItens_NF_import

Select CurTmp_CalcSubItens_NF_import
Scan
	Select vTmp_impressao_nf_00
	Locate For filial==CurTmp_CalcSubItens_NF_import.filial And nf==CurTmp_CalcSubItens_NF_import.nf And serie_nf==CurTmp_CalcSubItens_NF_import.serie_nf
	If Found()
		Replace valor_sub_itens With Round(CurTmp_CalcSubItens_NF_import.valor_total,2)
	Endif
Endscan

*--
F_Tratar_Len_Itens_DANFE()
F_Load_Ctrl_Frm_DANFE(pItens1,pItens2,pLenObsFrm, FormMain, bLinxERP)
F_Load_Ctrl_NF_Financ_Nfe(bLinxERP)

*-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------*

Select Cur_Ctb_Parcelas
Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag iParcs

Select Cur_FrmNfe_Obs
Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Tag iObsNfe

Select vTmp_impressao_nf_00
CursorSetProp('buffering',3)
Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag iFat
Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)  Into Cur_Ctb_Parcelas

Select vtmp_impressao_nf_00_itens
Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs)+Str(Item_nfe)+Str(item_add)+Str(n_qb_item) Tag iItens

Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Into vTmp_impressao_nf_00
Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Into Cur_FrmNfe_Obs Additive
Go Top

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_DANFE_Destroy
Lparameters bLinxERP


*-- Marcar DANFE como Impressa (para bot�o IMPRIMIR ou Print no Preview)
If bLinxERP And (( Type('Mreport')='C' And Mreport='IMP' ) Or ( Type('xSentToPrinter')='L' And xSentToPrinter ))
	Select vTmp_impressao_nf_00
	Scan
		If origem_nf = "S"
			xupdate = 'Update Faturamento set Nota_impressa=1 Where nf_saida=?vTmp_Impressao_NF_00.nf and serie_nf=?vTmp_Impressao_NF_00.serie_nf and filial=?vTmp_Impressao_NF_00.filial and nota_impressa=0'
		Else
			xupdate = 'Update Entradas set nf_propria_emitida=1 Where nf_entrada=?vTmp_Impressao_NF_00.nf and nome_clifor=?vTmp_Impressao_NF_00.nome_clifor and serie_nf_entrada=?vTmp_Impressao_NF_00.serie_nf and nf_propria_emitida=0'
		Endif
		If !f_update(xupdate)
			=F_msg(['Problema ao Marcar Nota Impressa !', 0+16, 'Erro !!!'])
			Sele &xalias
			Return .F.
		Endif
		Wait Window 'Marcando NFe Como Impressa: '+ Alltrim(vTmp_impressao_nf_00.nf) Nowait
	Endscan
	Wait Clear
Endif


*-- Clear
If bLinxERP
	Set Procedure To &x_Proce
Else
	Release wwLogo
Endif
Release x_Proce,xImp_DSai,Ext1,Ext2,Ext3,xMsg_NFe,xReport_Printed,xKimp

Local intCount As Integer, strCursor As String
Local Array aCursorsClose[20, 1]

aCursorsClose[1, 1]  = "cur_Ctb_Parcelas"
aCursorsClose[2, 1]  = "cur_FrmNfe_Obs"
aCursorsClose[3, 1]  = "vTmp_Impressao_NF_00_Itens"
aCursorsClose[4, 1]  = "vTmp_Impressao_NF_00"
aCursorsClose[5, 1]  = "cur_Lst_DANFE_Emitir"
aCursorsClose[6, 1]  = "curTmp_Maxfrm"
aCursorsClose[7, 1]  = "Cur_Lst_Nfs_Base"
aCursorsClose[8, 1]  = "cur_Lst_NFs"
aCursorsClose[9, 1]  = "cur_Info_UF"
aCursorsClose[10, 1] = "curTmp_Prot"
aCursorsClose[11, 1] = "cur_frmnfe_obs"
aCursorsClose[12, 1] = "cur_Ctb_Parcelas"
aCursorsClose[13, 1] = "curTmp_Itens_p_Form"
aCursorsClose[14, 1] = "Cur_Count_n_Form"
aCursorsClose[15, 1] = "curTmp_parc"
aCursorsClose[16, 1] = "Cur_lst_itens_add_len"
aCursorsClose[17, 1] = "CurTmp_TamLin_Item"
aCursorsClose[18, 1] = "CurTmp_Controle_Ult_ItemQb"
aCursorsClose[19, 1] = "CurChk_t_form"
aCursorsClose[20, 1] = "CurTmp_LogoDanfe"

For intCount = 1 To Alen(aCursorsClose, 1)
	strCursor = Alltrim(aCursorsClose[intCount, 1])
	If Used(strCursor)
		Use In &strCursor
	Endif
Endfor


Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Load_Ctrl_Frm_DANFE() && Form Control
Lparameters pItens1,pItens2,pLenObsFrm, FormMain, bLinxERP

*-  pItens1	   = Numero de Itens do primeiro formul�rio
*-  pItens2	   = Numero de Itens dos demais formul�rios
*-  pLenObsFrm = Tamanho M�ximo para quebra da OBS por Formul�rio (Linhas/Caracteres por linha)

Local intIdentifica_Ambiente_NFe As Integer
intIdentifica_Ambiente_NFe = Iif(bLinxERP, wIdentifica_Ambiente_NFe, FormMain.p_Identifica_Ambiente_NFe)


*-- Controle de Itens Por Frm
Select vtmp_impressao_nf_00_itens
Index On filial+nf+serie_nf+Str(Item_nfe) Tag iItem
Do Whil !Eof()
	xKey   = filial+nf+serie_nf
	xFrm   = 1
	xCount = 0
	xItensPFrm = pItens1
	Scan Whil filial+nf+serie_nf==xKey
		xCount = xCount+1
		If xCount > xItensPFrm
			xFrm   = xFrm + 1
			xCount = 1
*/xItensPFrm = IIF(tipo_emissao_nfe=5,pItens1,pItens2) && [Formul�rio de Seguran�a igual para todas as p�ginas]
			xItensPFrm = pItens2 && Papel timbrado (igual ao normal)
		Endif
		Replace n_form With xFrm
	Endscan
Enddo


*-- Controle de Quebra da OBS
Declare xMsg_NFe(3)
xMsg_NFe(1) = '( S E M   V A L O R   F I S C A L )'									 					  	&& > Para: wIdentifica_Ambiente_NFe=0 ou 2 ( quando em ambiente de homologa��o )
xMsg_NFe(2) = 'DANFE IMPRESSO EM CONTING�NCIA - DPEC REGULARMENTE RECEBIDA PELA RECEITA FEDERAL DO BRASIL'	&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='4'
xMsg_NFe(3) = 'DANFE EM CONTING�NCIA - IMPRESSO EM DECORR�NCIA DE PROBLEMAS T�CNICOS' 						&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='5'


*-- Trata Obs
Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,Count(*) Cnt_Itens ;
	FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6 Into Cursor Cur_Lst_Nfs_Base

Select a.*, b.Obs, b.Obs_Entrega, b.Texto_Legal, Obs_Interesse_Fisco, Obs As Obs_Final_Frm,;
	TTOC(b.data_contingencia) As data_contingencia, b.justificativa_contingencia justificativa_contingencia ;
	FROM Cur_Lst_Nfs_Base a Join vTmp_impressao_nf_00 b On a.nf=b.nf And a.serie_nf=b.serie_nf And a.filial=b.filial ;
	ORDER By a.nf,a.serie_nf,a.filial,a.n_form Into Cursor Cur_Lst_Nfs Readwrite

Select Cur_Lst_Nfs
Do Whil !Eof()
	xK=nf+serie_nf+filial
	xObsFinal = Iif(intIdentifica_Ambiente_NFe=0 Or intIdentifica_Ambiente_NFe=2,xMsg_NFe(1)+Chr(13),'') +;
		IIF(tipo_emissao_nfe=4,xMsg_NFe(2)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),;
		IIF(tipo_emissao_nfe=5,xMsg_NFe(3)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),''))

	xObsIntFisco = Iif(Empty(Nvl(Obs_Interesse_Fisco,'')),'','Informa��es Adicionais de Interesse do Fisco: '+Nvl(Alltrim(Obs_Interesse_Fisco),''))

	If !('ENTREGA:' $ Upper(Nvl(Obs,'')))
		xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs_Entrega,'')),'',Chr(13)+Chr(10)) + Nvl(Obs_Entrega,'')
	Endif

	xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs,'')),'',Chr(13)+Chr(10)) + Nvl(Obs,'')
	xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Texto_Legal,'')),'',Chr(13)+Chr(10)) + Nvl(Texto_Legal,'')
	xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs_Interesse_Fisco,'')),'',Chr(13)+Chr(10)) + xObsIntFisco

	Replace Obs_Final_Frm With Left(xObsFinal,5000) && Limite estipulado no manual
	Skip
	Scan While nf+serie_nf+filial==xK
		Replace Obs_Final_Frm With ''
	Endscan
Enddo

*--

Select nf,serie_nf,filial,vTmp_impressao_nf_00.Obs As Obs_Form,vTmp_impressao_nf_00.Obs As endereco_emitente_str,;
	00000 As n_form,00000 As seq_obs,;
	SPACE(50) As msg_Protocolo,Space(50) As msg_RegistroDped,;
	SPACE(55) chave_nfe_str,Space(36) dados_add_nfe,Space(44) dados_add_nfe_str,;
	SPACE(100) chave_nfe_str_barra,Space(100) dados_add_nfe_barra ;
	FROM Cur_Lst_Nfs Where .F. Into Cursor Cur_FrmNfe_Obs Readwrite

Select Cur_Lst_Nfs
Scan
	Select Count(Distinct n_form) Cnt_n_form From vtmp_impressao_nf_00_itens ;
		WHERE nf=Cur_Lst_Nfs.nf And serie_nf=Cur_Lst_Nfs.serie_nf And filial=Cur_Lst_Nfs.filial Into Cursor Cur_Count_n_Form

	Select vTmp_impressao_nf_00
	Locate For Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) == Alltrim(Cur_Lst_Nfs.filial)+Alltrim(Cur_Lst_Nfs.nf)+Alltrim(Cur_Lst_Nfs.serie_nf)
	xChaveSTR = Nvl(Subs(chave_nfe,1,4)+' '+Subs(chave_nfe,5,4)+' '+Subs(chave_nfe,9,4)+' '+Subs(chave_nfe,13,4)+' '+Subs(chave_nfe,17,4)+' '+Subs(chave_nfe,21,4)+' '+Subs(chave_nfe,25,4)+' '+Subs(chave_nfe,29,4)+' '+Subs(chave_nfe,33,4)+' '+Subs(chave_nfe,37,4)+' '+Subs(chave_nfe,41,4),'')

	xEndEmitenteStr = Allt(Nvl(vTmp_impressao_nf_00.endereco_emitente,'')) + Nvl(', ' + Allt(vTmp_impressao_nf_00.numero_emitente),'') + Nvl(Space(2) + Allt(vTmp_impressao_nf_00.complemento_emitente),'') + Nvl(' - '+Allt(vTmp_impressao_nf_00.bairro_emitente),'') + Chr(13) +;
		allt(vTmp_impressao_nf_00.cidade_emitente) + '/' + Allt(vTmp_impressao_nf_00.uf_emitente) + Nvl(' - ' + Allt(vTmp_impressao_nf_00.pais_emitente),'') + Chr(13) +;
		'CEP: ' + Allt(vTmp_impressao_nf_00.cep_emitente) + Chr(13) +;
		nvl('TEL: ' + '('+Allt(vTmp_impressao_nf_00.ddd1_emitente)+')'+Allt(vTmp_impressao_nf_00.telefone1_emitente),'')

	f_select('Select PROTOCOLO_AUTORIZACAO_NFe,DATA_AUTORIZACAO_NFe,REGISTRO_DPEC,DATA_REGISTRO_DPEC '+;
		'  FROM w_Impressao_NFe where nf=?Cur_Lst_Nfs.nf and serie_nf=?Cur_Lst_Nfs.serie_nf and filial=?Cur_Lst_Nfs.filial','CurTmp_Prot',Alias())


	xObsFrm = Alltrim(Nvl(Cur_Lst_Nfs.Obs_Final_Frm,''))
	=F_Quebra_Obs_Frm_DANFE(Upper(xObsFrm),pLenObsFrm)

	xSeqObs = 0
	xSeqObsFrm = 0

	Do Whil !Eof('Cur_Lst_Nfs')
		xSeqObs = xSeqObs + 1
		xSeqObsFrm = xSeqObsFrm+1

		Select Cur_Ctrl_ObsForm
		Locate For id_form==xSeqObsFrm
		xObs = Alltrim(Obs_Form)

		xn_form = Cur_Lst_Nfs.n_form
		If !Empty(xObs) And xSeqObs>1 And Cur_Count_n_Form.Cnt_n_form>1
			xn_form = xn_form+1
			xSeqObs = 1
			Select Cur_Lst_Nfs
			Skip
		Endif

		If xSeqObs>1 And Cur_Count_n_Form.Cnt_n_form=1
			xn_form = xSeqObs
		Endif

		Select Cur_FrmNfe_Obs
		Append Blank In Cur_FrmNfe_Obs
		Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial, n_form With xn_form,;
			seq_obs 				With xSeqObs,;
			Obs_Form 				With xObs,;
			endereco_emitente_str	With xEndEmitenteStr,;
			msg_Protocolo     		With Nvl(Allt(Nvl(CurTmp_Prot.PROTOCOLO_AUTORIZACAO_NFe,''))+' '+Nvl(Ttoc(CurTmp_Prot.DATA_AUTORIZACAO_NFe),''),''),;
			msg_RegistroDped  		With Nvl(Allt(Nvl(CurTmp_Prot.REGISTRO_DPEC,''))+' '+Nvl(Ttoc(CurTmp_Prot.DATA_REGISTRO_DPEC),''),''),;
			chave_nfe_str	  		With xChaveSTR,;
			dados_add_nfe	  		With F_Dados_NFE_Add(.F.),;
			dados_add_nfe_str 		With F_Dados_NFE_Add(.T.), ;
			chave_nfe_str_barra 	With bc_ocode128(Alltrim(Nvl(Allt(vTmp_impressao_nf_00.chave_nfe),'')),0,0,0),;
			dados_add_nfe_barra 	With bc_ocode128(Allt(Cur_FrmNfe_Obs.dados_add_nfe),0,0,0) In Cur_FrmNfe_Obs

		Select vtmp_impressao_nf_00_itens
		Locate For nf=Cur_Lst_Nfs.nf And serie_nf=Cur_Lst_Nfs.serie_nf And filial=Cur_Lst_Nfs.filial And n_form=xn_form And seq_obs=xSeqObs
		If Eof()
			Append Blank
			Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial,;
				status_nfe With Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe With  Cur_Lst_Nfs.tipo_emissao_nfe, n_form With xn_form, seq_obs With xSeqObs,item_add With 1
		Endif

		If Reccount('Cur_Ctrl_ObsForm')=0 Or Reccount('Cur_Ctrl_ObsForm')=xSeqObsFrm && Sem Obs ou Ultima linha da obs
			Exit
		Endif
	Enddo
Endscan


*-- Ajuste/Padroniza��o dos Itens: Fixar iguais para todos os formul�rios (para preencher espa�amento)
Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,seq_obs,Max(Item_nfe) Item_nfe,Min(n_qb_item) n_qb_item,Count(*) Cnt_Itens ;
	FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6,7 Into Cursor Cur_Lst_Nfs

Select Cur_Lst_Nfs
Scan
	xItensPFrm = Iif(n_form=1,pItens1,pItens2)
	If Cnt_Itens < xItensPFrm
		For i = Cnt_Itens+1 To xItensPFrm
			Select vtmp_impressao_nf_00_itens
			Append Blank
			Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial, Item_nfe With Cur_Lst_Nfs.Item_nfe,;
				status_nfe With Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe With  Cur_Lst_Nfs.tipo_emissao_nfe, ;
				n_form With Cur_Lst_Nfs.n_form, n_qb_item With Cur_Lst_Nfs.n_qb_item, seq_obs With Cur_Lst_Nfs.seq_obs, item_add With 1
		Endfor
	Endif
Endscan


*-- Ajuste t_form
Select nf,serie_nf,filial,Max(n_form) num_frm From vtmp_impressao_nf_00_itens Group By 1,2,3 Into Cursor CurTmp_MaxFrm
Select CurTmp_MaxFrm
Scan
	Select vtmp_impressao_nf_00_itens
	Replace All t_form With CurTmp_MaxFrm.num_frm For  nf=CurTmp_MaxFrm.nf And serie_nf=CurTmp_MaxFrm.serie_nf And filial=CurTmp_MaxFrm.filial
Endscan


*-- TP 5066773 Tratamento quando o n�mero de p�ginas para OBS excede o n�mero de p�ginas itens.
Select vTmp_impressao_nf_00
xNF 		= vTmp_impressao_nf_00.nf
xFILIAL 	= vTmp_impressao_nf_00.filial
xSERIE_NF 	= vTmp_impressao_nf_00.serie_nf

Select Cur_FrmNfe_Obs
Scan
	Replace All Cur_FrmNfe_Obs.nf 		With xNF 		For Len(Alltrim(Cur_FrmNfe_Obs.nf)) = 0
	Replace All Cur_FrmNfe_Obs.serie_nf With xSERIE_NF 	For Len(Alltrim(Cur_FrmNfe_Obs.serie_nf)) = 0
	Replace All Cur_FrmNfe_Obs.filial 	With xFILIAL 	For Len(Alltrim(Cur_FrmNfe_Obs.filial)) = 0
Endscan


Select vtmp_impressao_nf_00_itens
Scan
	Replace All vtmp_impressao_nf_00_itens.nf 		With xNF 		For Len(Alltrim(vtmp_impressao_nf_00_itens.nf)) = 0
	Replace All vtmp_impressao_nf_00_itens.serie_nf With xSERIE_NF 	For Len(Alltrim(vtmp_impressao_nf_00_itens.serie_nf)) = 0
	Replace All vtmp_impressao_nf_00_itens.filial 	With xFILIAL 	For Len(Alltrim(vtmp_impressao_nf_00_itens.filial)) = 0
Endscan

Return .T.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Dados_NFE_Add()
Lparameters pComSpace

Local xCBA_Str,xDV_CBA,xRetDados

f_select('SELECT TOP 1 f.uf,SUBSTRING(m.COD_MUNICIPIO_IBGE,1,2) as cMun '+;
	'  FROM cadastro_cli_for f  (nolock) '+;
	' INNER JOIN LCF_LX_MUNICIPIO m  (nolock) ON DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,f.cidade) = m.DESC_MUNICIPIO '+;
	' INNER JOIN LCF_LX_UF u (nolock) ON u.uf = f.uf and u.ID_UF = m.ID_UF'+;
	' WHERE f.nome_clifor=?vTmp_impressao_nf_00.nome_clifor','Cur_Info_UF',Alias())

xCBA_Str = Right('00'+Alltrim(Nvl(Cur_Info_UF.cMun,'99')),2)+;
	RIGHT('0'+Alltrim(Nvl(vTmp_impressao_nf_00.tipo_emissao_nfe,'')),1)+;
	RIGHT(Replicate('0',14)+Alltrim(Nvl(vTmp_impressao_nf_00.cnpj_emitente,'')),14)+;
	RIGHT(Replicate('0',14)+Alltrim(Str(vTmp_impressao_nf_00.valor_total*100)),14)+;
	IIF(vTmp_impressao_nf_00.icms>0,'1','2')+;
	IIF(vTmp_impressao_nf_00.icms_st>0,'1','2')+;
	RIGHT('00'+Alltrim(Str(Day(Ctod(vTmp_impressao_nf_00.emissao)))),2)

xDV_CBA = F_Mod11_Nfe(xCBA_Str)
xRetDados = xCBA_Str+xDV_CBA

If pComSpace
	xRetDados = Subs(xRetDados,1,4)+' '+Subs(xRetDados,5,4)+' '+Subs(xRetDados,9,4)+' '+Subs(xRetDados,13,4)+' '+Subs(xRetDados,17,4)+' '+Subs(xRetDados,21,4)+' '+Subs(xRetDados,25,4)+' '+Subs(xRetDados,29,4)+' '+Subs(xRetDados,33,4)
Endif

Return (xRetDados)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Mod11_Nfe()
Lparameters pStrChave

Local xStrPeso,xSeqMult,xResAcum,m,xCalc
xStrPeso = '98765432'

xSeqMult = 1
xResAcum = 0
For m = Len(pStrChave) To 1 Step -1
	xSeqMult = xSeqMult+1
	If xSeqMult>9
		xSeqMult = 2
	Endif
	xResAcum = xResAcum + ( Val(Substr(pStrChave,m,1)) * xSeqMult )
Endfor

xCalc = (11 - Mod(xResAcum,11))

Return Alltrim(Str((xCalc)))
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_GetReportProperty
Lparameters xObj,strReportField As String

Return Iif(Type("strReportField") == "C" And !Empty(strReportField) And Type("xObj.SelectedListObject.ListIndex") == "N" And xObj.SelectedListObject.ListIndex >= 0 And ;
	type("xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)") == "O" And ;
	!Isnull(xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)) , ;
	xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField).Value, "")

Return .F.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_Control_Obj_Export
Lparameters pStart

If pStart
	Public oXFRX, intStatusXFRX
	oXFRX = XFRX("XFRX#LISTENER")
	intStatusXFRX = oXFRX.SetParams(ReportExport.Filename,,.T.,,,,ReportExport.CurrentFileFormat)
	Return (intStatusXFRX = 0) && Success
Else
	oXFRX.finalize()
	Release oXFRX
	Return .T.
Endif

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Load_Ctrl_NF_Financ_Nfe
Lparameters bLinxERP

*-- Cursor (Cur_CTB_Parcelas)
Local xFields As Character, k As Character, k_ As Character
Store '' To xFields
For k = 1 To 48
	k_ = Alltrim(Str(k))
	xFields = xFields + Iif(Empty(xFields),'',',') + 'space(15) as Dup_Parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
Endfor

xFields = [nf,serie_nf,filial,NVL(fatura,'') as Fatura,ctb_lancamento,SPACE(LEN(fatura)) as fatura_conf,ctb_item,nome_clifor,origem_nf,cod_transacao,tipo_emissao_nfe,status_nfe,] + xFields
Select Distinct &xFields From vTmp_impressao_nf_00 Into Cursor Cur_Ctb_Parcelas Readwrite

*-- Dados
Select Cur_Ctb_Parcelas
Scan
	f_select("Select nFat as Fatura,Id_parcela as parcela,nDup as Duplicata,vDup as Valor,dVenc as Vencimento "+;
		"  From dbo.fx_ctb_simula_parcelas('" + Alltrim(Cur_Ctb_Parcelas.filial) + "','" + Alltrim(Cur_Ctb_Parcelas.nf) + "','" + Alltrim(Cur_Ctb_Parcelas.serie_nf) + "','" + Alltrim(Cur_Ctb_Parcelas.origem_nf) + "','" + Alltrim(Cur_Ctb_Parcelas.cod_transacao) + "') Order by Vencimento, Duplicata","curTmp_parc",Alias()) && #3#
*!*					 "  From dbo.fx_ctb_simula_parcelas('" + ALLTRIM(Cur_CTB_Parcelas.Filial) + "','" + ALLTRIM(Cur_CTB_Parcelas.NF) + "','" + ALLTRIM(Cur_CTB_Parcelas.serie_nf) + "','" + ALLTRIM(Cur_CTB_Parcelas.origem_nf) + "','" + ALLTRIM(Cur_CTB_Parcelas.cod_transacao) + "') Order by Fatura,Parcela","curTmp_parc",ALIAS()) && #3# - Alterado o "Order by" da linha acima

	Sele curTmp_parc
	Go Top

	Sele curTmp_parc
	xi_parc = 0
	Scan While !Eof() And xi_parc<48
		xi_parc = xi_parc + 1
		xi		= Alltrim(Str(xi_parc))

		If !Empty(Nvl(Alltrim(curTmp_parc.Duplicata),'')) And Nvl(curTmp_parc.valor,0)>0
			Sele Cur_Ctb_Parcelas
			Replace Dup_Parc&xi  With Nvl(Alltrim(curTmp_parc.Duplicata),''), ;
				Val_parc&xi  With Nvl(curTmp_parc.valor,0),;
				Venc_parc&xi With Nvl(curTmp_parc.vencimento,{})
			Sele curTmp_parc
		Endif

	Endscan

	Sele Cur_Ctb_Parcelas
Endscan

Return .T.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Tratar_Len_Itens_DANFE

*-- Numero de Caracters para quebra de linha (Descricao_Item)
f_select("Select valor_atual From Parametros Where Parametro='TAMANHO_LINHA_ITEM_DANFE'","CurTmp_TamLin_Item",Alias())
xLenMax = Val(Nvl(Alltrim(CurTmp_TamLin_Item.valor_atual),''))
xLenMax = Iif(xLenMax=0,38,xLenMax)

Select * From vtmp_impressao_nf_00_itens Where .F. Into Cursor Cur_Lst_Itens_Add_Len Readwrite

Select vtmp_impressao_nf_00_itens
Scan

*-- 23/10/2011 - Padial/Beda: Controle da observacao do item
	xObsItem = ''
	If !(Isnull(OBS_ITEM) Or Empty(OBS_ITEM))
		xcarUltimaLinha = Len(Alltrim(Descricao_Item)) % xLenMax
		If xcarUltimaLinha > 0 Then
			xObsItem = Replicate(' ',xLenMax - xcarUltimaLinha)
		Endif
		xObsItem = xObsItem + Alltrim(OBS_ITEM)
	Endif

	xDescItem = Alltrim(Descricao_Item) + xObsItem

	If Len(xDescItem)>xLenMax
		xCountQbLin = 0

		Do Whil !Empty(xDescItem)
			xCountQbLin = xCountQbLin + 1
			xDesItemQb  = Substr(xDescItem,1,xLenMax)

			If xCountQbLin > 1
				Select Cur_Lst_Itens_Add_Len
				Append Blank
				Replace filial 			 With vtmp_impressao_nf_00_itens.filial,;
					nf 				 With vtmp_impressao_nf_00_itens.nf,;
					serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
					Item_nfe		 With vtmp_impressao_nf_00_itens.Item_nfe,;
					item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
					sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
					status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
					tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
					item_add		 With vtmp_impressao_nf_00_itens.item_add,;
					seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
					n_qb_item		 With xCountQbLin
			Else
				Select vtmp_impressao_nf_00_itens
			Endif

			Replace Descricao_Item With xDesItemQb
			xDescItem = Substr(xDescItem,xLenMax+1,Len(xDescItem))
		Enddo
	Endif
Endscan
*--


*-- Numero de Caracters para quebra de linha (codigo_item)
xLenMax = 17

Select vtmp_impressao_nf_00_itens
Scan
	xCodItem = Alltrim(Codigo_Item)

	If Isdigit(xCodItem)
		xLenMax = 16
	Else
		xLenMax = 11
	Endif

	If Len(xCodItem)>xLenMax
		xCountQbLin = 0

		Do Whil !Empty(xCodItem)
			xCountQbLin = xCountQbLin + 1
			xCodItemQb  = Substr(xCodItem,1,xLenMax)

			If xCountQbLin > 1
				Select Cur_Lst_Itens_Add_Len
				Locate For filial==vtmp_impressao_nf_00_itens.filial And ;
					nf==vtmp_impressao_nf_00_itens.nf And ;
					serie_nf==vtmp_impressao_nf_00_itens.serie_nf And ;
					Item_nfe==vtmp_impressao_nf_00_itens.Item_nfe And ;
					item_impressao==vtmp_impressao_nf_00_itens.item_impressao And ;
					sub_item_tamanho==vtmp_impressao_nf_00_itens.sub_item_tamanho And ;
					item_add==vtmp_impressao_nf_00_itens.item_add And ;
					n_qb_item==xCountQbLin
				If Eof()
					Append Blank
					Replace filial 			 With vtmp_impressao_nf_00_itens.filial,;
						nf 				 With vtmp_impressao_nf_00_itens.nf,;
						serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
						Item_nfe		 With vtmp_impressao_nf_00_itens.Item_nfe,;
						item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
						sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
						status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
						tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
						item_add		 With vtmp_impressao_nf_00_itens.item_add,;
						seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
						n_qb_item		 With xCountQbLin
				Endif
			Else
				Select vtmp_impressao_nf_00_itens
			Endif

			Replace Codigo_Item With xCodItemQb
			xCodItem = Substr(xCodItem,xLenMax+1,Len(xCodItem))
		Enddo
	Endif
Endscan
*--


*--
If Reccount('Cur_Lst_Itens_Add_Len')>0
	Insert Into vtmp_impressao_nf_00_itens Select * From Cur_Lst_Itens_Add_Len
Endif

Select filial,nf,serie_nf,item_impressao,Item_nfe,Max(n_qb_item) max_n_qb_item ;
	FROM vtmp_impressao_nf_00_itens Where n_qb_item>1 Group By 1,2,3,4,5 Into Cursor CurTmp_Controle_Ult_ItemQb

Select CurTmp_Controle_Ult_ItemQb
Scan && Controle (identifica ultimo Item adicionado para uso na linha de separa��o)
	Select vtmp_impressao_nf_00_itens
	Locate For  filial==CurTmp_Controle_Ult_ItemQb.filial And nf==CurTmp_Controle_Ult_ItemQb.nf And serie_nf==CurTmp_Controle_Ult_ItemQb.serie_nf;
		AND item_impressao==CurTmp_Controle_Ult_ItemQb.item_impressao ;
		AND Item_nfe==CurTmp_Controle_Ult_ItemQb.Item_nfe And n_qb_item==CurTmp_Controle_Ult_ItemQb.max_n_qb_item
	If !Eof()
		Replace ult_n_qb_item With .T.
	Endif
Endscan
*--

Return .T.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Quebra_Obs_Frm_DANFE() && Form Control
Lparameters pObs,pLenObsFrm

*-- Vs-Lx   : 23/10/2011: Tratamento para Obs do Item

xLim_TamLin = Int(Val(Substr(xLenObsFrm,At('/',xLenObsFrm)+1,Len(xLenObsFrm))))
xLim_LinFrm = Int(Val(Substr(xLenObsFrm,1,At('/',xLenObsFrm)-1)))

*-- Tamanho das Linhas
Declare xObsLines(1)
xObs = Alltrim(Strt(pObs,Chr(10),''))
xObs = Strt(xObs,' = ','=')
xLim_TamLin = Iif(xLim_TamLin=0,Len(xObs),xLim_TamLin)

xCountLin = 0
Do Whil !Empty(xObs)

	xLin_txt = Substr(xObs,1,xLim_TamLin)
	If At(Chr(13),xLin_txt)>0
		xLin_txt = Substr(xLin_txt,1,At(Chr(13),xLin_txt))
		xObs = Substr(xObs,At(Chr(13),xLin_txt)+1,Len(xObs))
	Else
		If Substr(xObs,xLim_TamLin,1)=Chr(13) Or Empty(Substr(xObs,xLim_TamLin+1,1))
			xLin_txt = Strt(xLin_txt,Chr(13),'')
			xObs	 = Substr(xObs,xLim_TamLin+1,Len(xObs))
		Else
			For u = Len(xLin_txt) To 1 Step -1
				If Empty(Substr(xLin_txt,u,1)) Or Substr(xLin_txt,u,1)=Chr(13)
					xLin_txt = Substr(xLin_txt,1,u)
*!* #1# - In�cio
*!*	xObs = SUBSTR(xObs,u+1,LEN(xObs))
*!*	EXIT
				Endif
				xObs = Substr(xObs,u+1,Len(xObs))
				Exit
&& #1# - Fim
			Endfor
		Endif
	Endif

	xCountLin = xCountLin+1
	Declare xObsLines(xCountLin)
	xObsLines(xCountLin) = Strt(xLin_txt,Chr(13),'')
	xObs = Iif(Left(xObs,1)=Chr(13),Substr(xObs,2,Len(xObs)),xObs)
Enddo


*-- Linhas por formul�rio
If Used('Cur_Ctrl_ObsForm')
	Use In Cur_Ctrl_ObsForm
Endif

Create Cursor Cur_Ctrl_ObsForm(id_form N(1),Obs_Form m(4))
Select Cur_Ctrl_ObsForm
Append Blank
Replace id_form With 1

If xCountLin > 0
	xCount_Frm    = 1
	xCountLin_Frm = 0
	For kL =  1 To Alen(xObsLines)
		xCountLin_Frm = xCountLin_Frm+1
		If xCountLin_Frm> xLim_LinFrm
			xCount_Frm = xCount_Frm + 1
			xCountLin_Frm = 1
			Append Blank
			Replace id_form With xCount_Frm In Cur_Ctrl_ObsForm
		Endif
		Replace Obs_Form With Iif( Empty(Obs_Form) , xObsLines(kL) , Alltrim(Obs_Form)+Chr(13) + xObsLines(kL) )
	Endfor
Endif

Return .T.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
