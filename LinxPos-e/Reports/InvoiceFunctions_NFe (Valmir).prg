*-- Objetivo: Funcões Impressão da DANFE (Nota Fiscal Eletrônica)
*-- Impressão pelo LinxPOS: 19-Nov-2009
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION PrintNFe (strFilial as string, strNF_Numero as string, strSerie_NF as string, intQtdeVias as integer, FormMain as form)

	FormMain = iif(type("FormMain.Name") == "U", Main, FormMain)
	
	intQtdeVias = iif(type("intQtdeVias") != "N" or (type("intQtdeVias") == "N" and intQtdeVias < 1), 1, iif(intQtdeVias > 5, 5, intQtdeVias))

	xSele = SELECT()

	PUBLIC wwLogo

	wwLogo  = AddBS(FormMain.SystemPath) + "Reports\LogoReport.png"
	
	IF !FILE(wwLogo)
		MsgBox('Logo não encontrado: ' + wwLogo, 64 ,'Atenção')
		Release wwLogo
		RETURN .f.
	ENDIF
		
	xNf 	= strNF_Numero 
	xSerie  = strSerie_NF 
	xFilial = strFilial 

	TEXT TO xSqlNFE_Pai NOSHOW 
		SELECT filial,nf,serie_nf,convert(varchar(10), emissao, 103) as emissao,empresa,ctb_lancamento,ctb_item,convert(varchar(10), data_saida, 103) as data_saida,nome_clifor,fatura,pj_pf,CNPJ_DESTINATARIO AS CGC_CPF,
			   razao_social_emitente,cnpj_emitente,endereco_emitente,numero_emitente,bairro_emitente,cidade_emitente,uf_emitente,pais_emitente,cep_emitente,ddd1_emitente, telefone1_emitente,
			   Origem_NF,status_nfe,chave_nfe,desc_nf_natureza,convert(varchar(1),tipo_emissao_nfe) as tipo_emissao_nfe,ie_emitente,iest,pj_pf_emitente,razao_social,endereco,numero,complemento,bairro,
			   cep,cidade,ddd1,telefone1,uf,rg_ie,icms_base,icms,icms_st_base,icms_st,icms_str_base,icms_str,valor_sub_itens,encargo,frete,seguro,desconto,desconto_cond_pgto,ipi,valor_total,transportadora_razao_social,entrega_cif,
			   transportadora_cnpj,transportadora_endereco,transportadora_cidade,transportadora_uf,transportadora_ie,volumes,tipo_volume,peso_bruto,peso_liquido,im,iss,iss_base,
			   obs, Texto_Legal, cod_serie_sintegra, 
			   IsNull(rTrim(Convert(VarChar(2048), Obs)), '') + Char(13) + Char(10) + IsNull(rTrim(Texto_Legal), '') As Dados_Adicionais
		From W_IMPRESSAO_NFE 
		Where NF=?xNf and Serie_NF=?xSerie and Filial=?xFilial
	ENDTEXT 
	if !SQLSelect(xSqlNFE_Pai, "vTmp_impressao_nf_00", "Erro buscando dados da NFE (pai)")
		Release wwLogo
		return .f.
	endif

	TEXT TO xSqlNFE_Filha NOSHOW 
		Select filial,nf,serie_nf,Item_Impressao,Item_NFe,sub_item_tamanho,codigo_item,descricao_item,classif_fiscal,tribut_origem,tribut_icms,codigo_fiscal_operacao,id_excecao_imposto,unidade,
			   qtde_item,preco_unitario,valor_item,icms,icms_base,ipi,icms_aliquota,ipi_aliquota
		  From W_IMPRESSAO_NFE_ITENS Where NF=?xNf and Serie_NF=?xSerie and Filial=?xFilial
	ENDTEXT 
	if !SQLSelect(xSqlNFE_Filha, "v_impressao_nf_00_itens", "Erro buscando dados da NFE (filha)")
		Release wwLogo
		return .f.
	endif

	*--
	xSaidaPDF = .f. && Verificar Com Paulão...
	xTipo     = 'IMP'

	xOk = IIF(xSaidaPDF,Fx_Control_Obj_Export(.t.),.t.)
	IF !xOk
		RETURN .f.
	ENDIF 
	
	IF xSaidaPDF
		xSaida1  = 'Object oXFRX NOPAGEEJECT'
		xSaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
	ELSE
		xSaida1  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer')
		xSaida2  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer')
		*/xSaida1  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer Prompt NOPAGEEJECT')
		*/xSaida2  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer NOPAGEEJECT NORESET')
	ENDIF
	

	*-- Itens por formulário para o DANFE
		if !SQLSelect("Select valor_atual From Parametros Where Parametro='ITENS_P_FORM_DANFE'", "CurTmp_Itens_p_form", "Erro pesquisando parametros da NFE")
			return .f.
		endif
		xItensPD = NVL(ALLTRIM(CurTmp_Itens_p_form.valor_atual),'')

		IF  ATC('/',xItensPD) > 0
			xItensPD1 = VAL( SUBSTR(xItensPD,1,ATC('/',xItensPD)-1) )
			xItensPD2 = VAL( SUBSTR(xItensPD,ATC('/',xItensPD)+1,LEN(xItensPD)) )
		ELSE
			xItensPD1 = 18 && Padrão Primeiro Formulário
			xItensPD2 = 47 && Padrão Segundo Formulário
		ENDIF

		Fx_Invoice_DANFE_Init(xItensPD1,xItensPD2,1500, FormMain)

	*-- Formulários
		local pLst_Reports_1 as string, pLst_Reports_2 as string
*!*			If !File(FormMain.p_report_nf)
*!*				MsgBox(iIf(Empty(FormMain.p_report_nf), "O parâmetro com o arquivo para a impressão do DANFE está vazio.", "O arquivo para a impressão do DANFE não foi encontrado.\n\nArquivo: " + JustStem(FormMain.p_report_nf)), 64, "Atenção")
*!*				Return .f.
*!*			EndIf
		*!*	27/01/2010 - Paulão - Não usaremos mais o parâmetro "Report_NF" pois, quando se habilita a NFe também é possível imprimir notas que não são eletrônicas 
		*!*						  obrigando a existência de um template para as notas normais (REPORT_NF) e outro (DANFE) para a NFe.
		*!*						  Fixaremos o template [LinxPOS]\Reports\DANFE1.frx. Será obrigatória a existência dele.
		*!*	pLst_Reports_1 = Alltrim(FormMain.p_report_nf)
		pLst_Reports_1 = addbs(FormMain.SystemPath) + "Reports\L_Danfe1.frx"
		If !File(pLst_Reports_1)
			MsgBox("O arquivo para a impressão do DANFE não foi encontrado.\n\nArquivo: " + JustStem(pLst_Reports_1), 64, "Atenção")
			Return .f.
		EndIf
		*!*	27/01/2010 - Paulão - Não usaremos mais o parâmetro "Report_NF".
		pLst_Reports_2 = AllTrim(JustStem(pLst_Reports_1))
		pLst_Reports_2 = AddBS(JustPath(pLst_Reports_1)) + Left(pLst_Reports_2, Len(pLst_Reports_2) - 1) + "2." + JustExt(pLst_Reports_1)
		If !File(pLst_Reports_2)
			MsgBox("O segundo arquivo para a impressão do DANFE não foi encontrado.\n\nArquivo: " + JustStem(pLst_Reports_2), 64, "Atenção")
			Return .f.
		EndIf

		*-- Envia para saida
		SELECT distinct nf,serie_nf,filial,n_form,t_form,.f. as is_ultimo FROM vtmp_impressao_nf_00_itens INTO CURSOR Cur_Lst_DANFE_Emitir READWRITE 
			SELECT Cur_Lst_DANFE_Emitir
			GO BOTTOM 
			REPLACE is_ultimo WITH .t.
			
		Local intCountReports As Integer
		For intCountReports = 1 to intQtdeVias
			If intCountReports > 1
				FormMain.SetMessage("Imprimindo " + Transform(intCountReports, '9.999') + "ª via...")
			EndIf
			SELECT Cur_Lst_DANFE_Emitir
			xRAtu = 0
			SCAN 
				xRAtu = xRAtu+1 
				xKimp = ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf)+str(n_form)

				SELECT vtmp_impressao_nf_00_itens
					SET FILTER TO ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf)+str(n_form)==xKimp
					GO top
					xSaida = IIF(xRAtu=1,xSaida1,xSaida2)
					IF Cur_Lst_DANFE_Emitir.is_ultimo
						xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
					ENDIF
					if n_form=1
						try
							report form (pLst_Reports_1) &xSaida 
						catch to oPrinterError
							MsgBox(alltrim(str(oPrinterError.ErrorNo)) + " - " + alltrim(oPrinterError.Message), -16, "Atenção")
						endtry
					else
						try
							report form (pLst_Reports_2) &xSaida 
						catch to oPrinterError
							MsgBox(alltrim(str(oPrinterError.ErrorNo)) + " - " + alltrim(oPrinterError.Message), -16, "Atenção")
						endtry
					endif
			ENDSCAN 
			FormMain.SetMessage()
		EndFor
		
		xSentToPrinter = .t.
		IF TYPE('ReportExport')='O'
			Fx_Control_Obj_Export(.f.)
		ENDIF 

	Fx_Invoice_DANFE_Destroy()

	SELECT (xSele)
	*

ENDFUNC
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_Invoice_DANFE_Init
LPARAMETERS pItens1,pItens2,pLenObsFrm,FormMain

	*-- NF-e (D.A.N.F.E.)
	PUBLIC xImp_DSai,Ext1,Ext2,Ext3,xSentToPrinter

		xSentToPrinter = .f.
		xImp_DSai = .T. && f_msg(['Deseja Imprimir a Data de Saida?',4+32+256,'<Aviso...>'])=6

		SELECT b.*,NVL(a.status_nfe,0) as status_nfe,NVL(vTmp_impressao_nf_00.tipo_emissao_nfe,0) as tipo_emissao_nfe,;
			   0000 as n_form,0000 as t_form, 0 as item_add, 0001 as seq_obs ;
		  FROM vTmp_impressao_nf_00 a JOIN v_impressao_nf_00_itens b ON a.nf=b.nf AND a.serie_nf=b.serie_nf AND a.filial=b.filial ;
		  INTO CURSOR vTmp_impressao_nf_00_itens READWRITE 

		F_Load_Ctrl_Frm_DANFE(pItens1,pItens2,pLenObsFrm,FormMain)
		F_Load_Ctrl_NF_Financ()
	*----------------------------------------------------------------------------------------------------------------------------------------------------*
SET STEP ON

	SELECT Cur_Ctb_Parcelas 
		INDEX ON ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) + STR(ctb_lancamento)+STR(ctb_item)+ALLTRIM(NVL(fatura,'')) tag iParcs

	SELECT Cur_FrmNfe_Obs 
		INDEX ON ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) + STR(n_form) tag iObsNfe

	SELECT vTmp_impressao_nf_00
		CURSORSETPROP('buffering',3)
		INDEX ON ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) tag iFat
		SET RELATION TO ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) + STR(ctb_lancamento)+STR(ctb_item)+ALLTRIM(NVL(fatura,'')) INTO Cur_Ctb_Parcelas

	SELECT vtmp_impressao_nf_00_itens
*/		INDEX ON ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf)+STR(n_form)+STR(item_add)+ALLTRIM(Item_Impressao) tag iItens FOR (status_nfe=5 OR status_nfe=9) OR (tipo_emissao_nfe=4 OR tipo_emissao_nfe=5)
		INDEX ON ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf)+STR(n_form)+STR(item_add)+ALLTRIM(Item_Impressao) tag iItens
		SET RELATION TO ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) INTO vTmp_impressao_nf_00
		SET RELATION TO ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf)+STR(n_form) INTO Cur_FrmNfe_Obs ADDITIVE 

		GO TOP
		IF EOF()
			MESSAGEBOX('Nenhuma NFe Selecionada:'+CHR(13)+'Estatus NFe: 5 ou 9'+CHR(13)+'ou Tipo Emissão NFe: 4 ou 5',48,'Aviso')
		ENDIF 

ENDFUNC 
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_Invoice_DANFE_Destroy
SET STEP ON

	*-- Clear
	RELEASE xImp_DSai,Ext1,Ext2,Ext3,xMsg_NFe,xReport_Printed

	SELE Cur_Ctb_Parcelas 
		USE
	SELE Cur_FrmNfe_Obs 
		USE
	SELE vtmp_impressao_nf_00_itens
		USE

	SELECT vTmp_impressao_nf_00
		SET RELATION TO

ENDFUNC 
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_Frm_DANFE() && Form Control
LPARAMETERS pItens1,pItens2,pLenObsFrm,FormMain

	*-  pItens1	   = Numero de Itens do primeiro formulário
	*-  pItens2	   = Numero de Itens dos demais formulários
	*-  pLenObsFrm = Tamanho Máximo para quebra da OBS por Formulário

	*-- Controle de Itens Por Frm
		SELECT vtmp_impressao_nf_00_itens
		INDEX ON filial+nf+serie_nf+item_impressao tag iItem
		DO whil !eof()
			xKey   = filial+nf+serie_nf
			xFrm   = 1
			xCount = 0
			xItensPFrm = pItens1
			scan whil filial+nf+serie_nf=xKey 
				xCount = xCount+1
				IF xCount > xItensPFrm 
					xFrm   = xFrm + 1
					xCount = 1
					xItensPFrm = IIF(tipo_emissao_nfe=5,pItens1,pItens2) && [Formulário de Segurança igual para todas as páginas]
				ENDIF
				Replace n_form WITH xFrm
			endscan
		ENDDO 

	*-- Controle de Quebra da OBS + Informações adicionais que não cabem no cursor PAI (limite de colunas)
		DECLARE xMsg_NFe(3)
			xMsg_NFe(1) = '( S E M   V A L O R   F I S C A L )'									 					    && > Para: FormMain.p_Identifica_Ambiente_NFe=0 ou 2 ( quando em ambiente de homologação )
			xMsg_NFe(2) = 'DANFE IMPRESSO EM CONTIGÊNCIA - DPEC REGULARMENTE RECEBIDA PELA RECEITA FEDERAL DO BRASIL'   && >  Para: vTmp_impressao_nf_00.tipo_emissao_nfe='4'
			xMsg_NFe(3) = 'DANFE EM CONTIGÊNCIA - IMPRESSO EM DECORRÊNCIA DE PROBLEMAS TÉCNICOS'						&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='5'

		SELECT nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,count(*) Cnt_Itens FROM vTmp_impressao_nf_00_itens GROUP BY 1,2,3,4,5,6 INTO CURSOR Cur_Lst_Nfs

		SELECT nf,serie_nf,filial,vTmp_impressao_nf_00.obs as Obs_Form,00000 as n_form,00000 as seq_obs,;
				SPACE(50) AS msg_Protocolo,SPACE(50) AS msg_RegistroDped,;
				SPACE(55) chave_nfe_str,SPACE(36) dados_add_nfe,SPACE(44) dados_add_nfe_str ;
		  FROM Cur_Lst_Nfs WHERE .f. INTO CURSOR Cur_FrmNfe_Obs READWRITE 

		SELECT Cur_Lst_Nfs
		SCAN

			SELECT vTmp_impressao_nf_00
				LOCATE FOR ALLTRIM(Filial)+ALLTRIM(Nf)+ALLTRIM(Serie_nf) == ALLTRIM(Cur_Lst_Nfs.Filial)+ALLTRIM(Cur_Lst_Nfs.Nf)+ALLTRIM(Cur_Lst_Nfs.Serie_nf)
				xChaveSTR = NVL(Subs(chave_nfe,1,4)+' '+Subs(chave_nfe,5,4)+' '+Subs(chave_nfe,9,4)+' '+Subs(chave_nfe,13,4)+' '+Subs(chave_nfe,17,4)+' '+Subs(chave_nfe,21,4)+' '+Subs(chave_nfe,25,4)+' '+Subs(chave_nfe,29,4)+' '+Subs(chave_nfe,33,4)+' '+Subs(chave_nfe,37,4)+' '+Subs(chave_nfe,41,4),'')

			if !SQLSelect('Select PROTOCOLO_AUTORIZACAO_NFe,DATA_AUTORIZACAO_NFe,REGISTRO_DPEC,DATA_REGISTRO_DPEC '+;
					 	  '  FROM w_Impressao_NFe where nf=?Cur_Lst_Nfs.nf and serie_nf=?Cur_Lst_Nfs.serie_nf and filial=?Cur_Lst_Nfs.filial','CurTmp_Prot','Erro ao Localizar Protocolo de Autorização da NFe')
				Return .f.
			ENDIF

*!*			 	if !SQLSelect("SELECT dbo.FX_DADOS_ADICIONAIS_NFE(?Cur_Lst_Nfs.nf,?Cur_Lst_Nfs.serie_nf,?Cur_Lst_Nfs.filial,'') Dados_Adicionais","Cur_Dados_Add_NFe","Erro buscando Dados Adicionais da NFe")
*!*					Return .f.
*!*				ENDIF

*!*				xObsFrm = IIF(FormMain.p_Identifica_Ambiente_NFe=0 OR FormMain.p_Identifica_Ambiente_NFe=2,xMsg_NFe(1)+CHR(13),'') +;
*!*						  IIF(vTmp_impressao_nf_00.tipo_emissao_nfe=4,xMsg_NFe(2)+CHR(13),IIF(vTmp_impressao_nf_00.tipo_emissao_nfe=5,xMsg_NFe(3)+CHR(13),'')) +;
*!*						  ALLTRIM(NVL(Cur_Dados_Add_NFe.Dados_Adicionais,''))	
			
			xObsFrm = IIF(FormMain.p_Identifica_Ambiente_NFe=0 OR FormMain.p_Identifica_Ambiente_NFe=2,xMsg_NFe(1)+CHR(13),'') +;
					  IIF(vTmp_impressao_nf_00.tipo_emissao_nfe=4,xMsg_NFe(2)+CHR(13),IIF(vTmp_impressao_nf_00.tipo_emissao_nfe=5,xMsg_NFe(3)+CHR(13),'')) +;
					  ALLTRIM(NVL(vTmp_impressao_nf_00.Dados_Adicionais,''))	

			xSeqObs = 0
			DO whil .t.
				xSeqObs = xSeqObs + 1

				xObs = SUBSTR(xObsFrm,1,pLenObsFrm)
				IF LEN(xObs)=LEN(xObsFrm)
					xRat = LEN(xObs)
					xObsFrm = ''
				ELSE
					xRat = RAT(SPACE(1),xObs)
					xRat = IIF(xRat>0,xRat,LEN(xObs)) 
					xObs = SUBSTR(xObsFrm,1,xRat)
					xObsFrm = SUBSTR(xObsFrm,xRat+1,LEN(xObsFrm)) 
				ENDIF 
				
				SELECT Cur_FrmNfe_Obs 
				APPEND BLANK 
				REPLACE nf WITH Cur_Lst_Nfs.nf, serie_nf WITH Cur_Lst_Nfs.serie_nf, filial WITH Cur_Lst_Nfs.filial, n_form WITH Cur_Lst_Nfs.n_form,;
						Seq_Obs WITH xSeqObs, Obs_Form WITH xObs,;
						msg_Protocolo     WITH NVL(allt(NVL(CurTmp_Prot.PROTOCOLO_AUTORIZACAO_NFe,''))+' '+NVL(ttoc(CurTmp_Prot.DATA_AUTORIZACAO_NFe),''),''),;
						msg_RegistroDped  WITH NVL(allt(NVL(CurTmp_Prot.REGISTRO_DPEC,''))+' '+NVL(ttoc(CurTmp_Prot.DATA_REGISTRO_DPEC),''),''),;
						chave_nfe_str	  WITH xChaveSTR,;
						dados_add_nfe	  WITH F_Dados_NFE_Add(.f.),;
						dados_add_nfe_str WITH F_Dados_NFE_Add(.t.)
						
				SELECT vtmp_impressao_nf_00_itens
				LOCATE FOR nf=Cur_Lst_Nfs.nf AND serie_nf=Cur_Lst_Nfs.serie_nf AND filial=Cur_Lst_Nfs.filial AND n_form=Cur_Lst_Nfs.n_form AND Seq_Obs=xSeqObs
				IF EOF()
					APPEND BLANK 
					REPLACE nf WITH Cur_Lst_Nfs.nf, serie_nf WITH Cur_Lst_Nfs.serie_nf, filial WITH Cur_Lst_Nfs.filial,;
							status_nfe WITH Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe WITH  Cur_Lst_Nfs.tipo_emissao_nfe, n_form WITH xSeqObs, item_add WITH 1
				ENDIF 

				IF EMPTY(xObsFrm)
					EXIT 
				ENDIF
			ENDDO
		ENDSCAN 


	*-- Ajuste/Padronização dos Itens: Fixar iguais para todos os formuários (para preencher espaçamento)
		SELECT nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,count(*) Cnt_Itens FROM vTmp_impressao_nf_00_itens GROUP BY 1,2,3,4,5,6 INTO CURSOR Cur_Lst_Nfs
		SELECT Cur_Lst_Nfs
		SCAN
			xItensPFrm = IIF(n_form=1,pItens1,pItens2)
			IF Cnt_Itens < xItensPFrm
				FOR i = Cnt_Itens+1 TO xItensPFrm
					SELECT vtmp_impressao_nf_00_itens
					APPEND BLANK 
					REPLACE nf WITH Cur_Lst_Nfs.nf, serie_nf WITH Cur_Lst_Nfs.serie_nf, filial WITH Cur_Lst_Nfs.filial,;
							status_nfe WITH Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe WITH  Cur_Lst_Nfs.tipo_emissao_nfe, n_form WITH Cur_Lst_Nfs.n_form, item_add WITH 1
				ENDFOR 
			ENDIF
		ENDSCAN


	*-- Ajuste t_form
		SELECT nf,serie_nf,filial,MAX(n_form) num_frm FROM vtmp_impressao_nf_00_itens GROUP BY 1,2,3 INTO CURSOR CurTmp_MaxFrm
		SELECT CurTmp_MaxFrm
		SCAN
			SELECT vtmp_impressao_nf_00_itens
			REPLACE ALL t_form WITH CurTmp_MaxFrm.num_frm FOR  nf=CurTmp_MaxFrm.nf AND serie_nf=CurTmp_MaxFrm.serie_nf AND filial=CurTmp_MaxFrm.filial
		ENDSCAN

RETURN .t.
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Dados_NFE_Add()
LPARAMETERS pComSpace
	
	LOCAL xCBA_Str,xDV_CBA,xRetDados  

	if !SQLSelect('SELECT TOP 1 f.uf,SUBSTRING(COD_MUNICIPIO_IBGE,1,2) as cMun '+;
	  		 	  '  FROM cadastro_cli_for f  (nolock) '+;
	 		 	  ' INNER JOIN LCF_LX_MUNICIPIO m  (nolock) ON DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(f.cidade) = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(m.DESC_MUNICIPIO) '+;
	 		 	  ' INNER JOIN LCF_LX_UF u (nolock) ON u.uf = f.uf and u.ID_UF = m.ID_UF'+;
	 		 	  ' WHERE f.uf=?vTmp_impressao_nf_00.UF','Cur_Info_UF',"Erro buscando Dados Adicionais da NFe (Municipio)")
		RETURN SPACE(1)
	ENDIF
	
	xCBA_Str = RIGHT('00'+ALLTRIM(NVL(Cur_Info_UF.cMun,'99')),2)+;
			   RIGHT('0'+TRANSFORM(NVL(vTmp_impressao_nf_00.tipo_emissao_nfe,0)),1)+;
			   RIGHT(REPLICATE('0',14)+ALLTRIM(NVL(vTmp_impressao_nf_00.cnpj_emitente,'')),14)+;
			   RIGHT(REPLICATE('0',14)+ALLTRIM(STR(vTmp_impressao_nf_00.valor_total*100)),14)+;
			   IIF(vTmp_impressao_nf_00.icms>0,'1','2')+;
			   IIF(vTmp_impressao_nf_00.icms_st>0,'1','2')+;
			   RIGHT('00'+ALLTRIM(STR(DAY(CTOD(vTmp_impressao_nf_00.emissao)))),2)
	
	xDV_CBA = F_Mod11_Nfe(xCBA_Str)
	xRetDados = xCBA_Str+xDV_CBA
	
	IF pComSpace
		xRetDados = Subs(xRetDados,1,4)+' '+Subs(xRetDados,5,4)+' '+Subs(xRetDados,9,4)+' '+Subs(xRetDados,13,4)+' '+Subs(xRetDados,17,4)+' '+Subs(xRetDados,21,4)+' '+Subs(xRetDados,25,4)+' '+Subs(xRetDados,29,4)+' '+Subs(xRetDados,33,4)
	ENDIF 

RETURN (xRetDados)
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Mod11_Nfe()
LPARAMETERS pStrChave

	LOCAL xStrPeso,xSeqMult,xResAcum,m,xCalc 
	xStrPeso = '98765432'

	xSeqMult = 1
	xResAcum = 0
	FOR m = LEN(pStrChave) TO 1 STEP -1
		xSeqMult = xSeqMult+1
		IF xSeqMult>9
			xSeqMult = 2
		ENDIF
		xResAcum = xResAcum + ( VAL(SUBSTR(pStrChave,m,1)) * xSeqMult )
	ENDFOR

	xCalc = (11 - Mod(xResAcum,11))

RETURN ALLTRIM(STR((xCalc)))
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_Control_Obj_Export
LPARAMETERS pStart
 
	IF pStart
		PUBLIC oXFRX, intStatusXFRX
		oXFRX = XFRX("XFRX#LISTENER")
		intStatusXFRX = oXFRX.SetParams(AddBS(strTempDir) + "DANFE",,.T.,,,,"PDF")	
		Return (intStatusXFRX = 0) && Success
	ELSE
		oXFRX.finalize()
		RELEASE oXFRX
		RETURN .t.
	ENDIF 

ENDFUNC 
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*/



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_NF_Financ()

	LOCAL xFields as Character, k as Character, k_ as Character 
	STORE '' TO xFields
	FOR k = 1 TO 16
		k_ = ALLTRIM(STR(k))
		xFields = xFields + IIF(EMPTY(xFields),'',',') + ;
				  'space(2) as id_parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
	ENDFOR

	Select Distinct ctb_lancamento, ctb_item, fatura, nf, serie_nf, filial, nome_clifor, SPACE(LEN(fatura)) as fatura_conf, &xFields ;
	  From vTmp_impressao_nf_00 Into Cursor Cur_Ctb_Parcelas ReadWrite

	select Cur_Ctb_Parcelas

	IF used("curVendaParcelas")
		local intCounter as integer, evlValor as string, evlVencimento as string
		intCounter = 1

		SELECT curVendaParcelas
		SCAN 
			evlValor = "val_parc" + transform(intCounter)
			evlVencimento = "venc_parc" + transform(intCounter)

			select Cur_Ctb_Parcelas
			replace &evlValor with curVendaParcelas.valor, &evlVencimento with curVendaParcelas.vencimento

			intCounter = intCounter + 1
			SELECT curVendaParcelas
			if EOF()
				exit
			endif
		ENDSCAN
		
	ENDIF 

	return .t.
ENDFUNC 
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_Excecao()
	local intAlias as integer, strExcecao as string, strCodigoFilial as string, strNFNumero as string, strSerieNF as string

	intAlias = select()

	strExcecao = ""

	strCodigoFilial = curImpressaoNFItens.codigo_filial
	strNFNumero = curImpressaoNFItens.nf_numero
	strSerieNF = curImpressaoNFItens.serie_nf

	select distinct id_excecao_imposto from vTmp_impressao_nf_00_itens ;
		where codigo_filial = strCodigoFilial and nf_numero = strNFNumero and serie_nf = strSerieNF ;
		and id_excecao_imposto is not null into cursor cur_distinct_excecao

	select cur_distinct_excecao
	scan
		if !SQLSelect("SELECT TEXTO_LEGAL FROM CTB_EXCECAO_IMPOSTO_ITEM WHERE ID_EXCECAO_IMPOSTO = ?cur_distinct_excecao.id_excecao_imposto order by 1", "cur_excecao", "Não foi possível pesquisar a exceção")
			return .f.
		endif
		select cur_excecao
		scan for !empty(nvl(texto_legal, "")) and atc(alltrim(texto_legal), strExcecao) == 0
			strExcecao = strExcecao + iif(empty(nvl(strExcecao, "")), "", chr(13)) + alltrim(texto_legal)
		endscan
	endscan

	select (intAlias)

	return alltrim(strExcecao)
ENDFUNC
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*/



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure BC_OCode128
	Parameters m,fnc1,fnc2,fnc3
	
	Private codeset,cset,shift,pfcn4,cont,s_char,cnt,rtncode,t,rtnc
	Private fcn4,rcode

	set talk off
	codeset = 1
	cset =1
	shift = .f.
	fcn4 = 1
	pfcn4 = .f.
	cont = .t.
	dimension cvtarr[5,106]
	dimension contarr[2,10]
	s_char = chr(47)  && "/" character
	cnt = 1
	rtncode = ""

	if fnc1 <> 1
	  fnc1 = 0
	endif
	if fnc2 <> 1
	  fnc2 = 0
	endif
	if fnc3 <> 1
	  fnc3 = 0
	endif

	* Define the convertion array
	cvtarr[1,1]="000"
	cvtarr[2,1]=chr(32)
	cvtarr[3,1]=chr(32)
	cvtarr[4,1]="00"
	cvtarr[5,1]=chr(37)+chr(38)+chr(38)
	cvtarr[1,2]="001"
	cvtarr[2,2]=chr(33)
	cvtarr[3,2]=chr(33)
	cvtarr[4,2]="01"
	cvtarr[5,2]=chr(38)+chr(37)+chr(38)
	cvtarr[1,3]="002"
	cvtarr[2,3]=chr(34)
	cvtarr[3,3]=chr(34)
	cvtarr[4,3]="02"
	cvtarr[5,3]=chr(38)+chr(38)+chr(37)
	cvtarr[1,4]="003"
	cvtarr[2,4]=chr(35)
	cvtarr[3,4]=chr(35)
	cvtarr[4,4]="03"
	cvtarr[5,4]=chr(34)+chr(34)+chr(39)
	cvtarr[1,5]="004"
	cvtarr[2,5]=chr(36)
	cvtarr[3,5]=chr(36)
	cvtarr[4,5]="04"
	cvtarr[5,5]=chr(34)+chr(35)+chr(38)
	cvtarr[1,6]="005"
	cvtarr[2,6]=chr(37)
	cvtarr[3,6]=chr(37)
	cvtarr[4,6]="05"
	cvtarr[5,6]=chr(35)+chr(34)+chr(38)
	cvtarr[1,7]="006"
	cvtarr[2,7]=chr(38)
	cvtarr[3,7]=chr(38)
	cvtarr[4,7]="06"
	cvtarr[5,7]=chr(34)+chr(38)+chr(35)
	cvtarr[1,8]="007"
	cvtarr[2,8]=chr(39)
	cvtarr[3,8]=chr(39)
	cvtarr[4,8]="07"
	cvtarr[5,8]=chr(34)+chr(39)+chr(34)
	cvtarr[1,9]="008"
	cvtarr[2,9]=chr(40)
	cvtarr[3,9]=chr(40)
	cvtarr[4,9]="08"
	cvtarr[5,9]=chr(35)+chr(38)+chr(34)
	cvtarr[1,10]="009"
	cvtarr[2,10]=chr(41)
	cvtarr[3,10]=chr(41)
	cvtarr[4,10]="09"
	cvtarr[5,10]=chr(38)+chr(34)+chr(35)
	cvtarr[1,11]="010"
	cvtarr[2,11]=chr(42)
	cvtarr[3,11]=chr(42)
	cvtarr[4,11]="10"
	cvtarr[5,11]=chr(38)+chr(35)+chr(34)
	cvtarr[1,12]="011"
	cvtarr[2,12]=chr(43)
	cvtarr[3,12]=chr(43)
	cvtarr[4,12]="11"
	cvtarr[5,12]=chr(39)+chr(34)+chr(34)
	cvtarr[1,13]="012"
	cvtarr[2,13]=chr(44)
	cvtarr[3,13]=chr(44)
	cvtarr[4,13]="12"
	cvtarr[5,13]=chr(33)+chr(38)+chr(42)
	cvtarr[1,14]="013"
	cvtarr[2,14]=chr(45)
	cvtarr[3,14]=chr(45)
	cvtarr[4,14]="13"
	cvtarr[5,14]=chr(34)+chr(37)+chr(42)
	cvtarr[1,15]="014"
	cvtarr[2,15]=chr(46)
	cvtarr[3,15]=chr(46)
	cvtarr[4,15]="14"
	cvtarr[5,15]=chr(34)+chr(38)+chr(41)
	cvtarr[1,16]="015"
	cvtarr[2,16]=chr(47)
	cvtarr[3,16]=chr(47)
	cvtarr[4,16]="15"
	cvtarr[5,16]=chr(33)+chr(42)+chr(38)
	cvtarr[1,17]="016"
	cvtarr[2,17]=chr(48)
	cvtarr[3,17]=chr(48)
	cvtarr[4,17]="16"
	cvtarr[5,17]=chr(34)+chr(41)+chr(38)
	cvtarr[1,18]="017"
	cvtarr[2,18]=chr(49)
	cvtarr[3,18]=chr(49)
	cvtarr[4,18]="17"
	cvtarr[5,18]=chr(34)+chr(42)+chr(37)
	cvtarr[1,19]="018"
	cvtarr[2,19]=chr(50)
	cvtarr[3,19]=chr(50)
	cvtarr[4,19]="18"
	cvtarr[5,19]=chr(38)+chr(42)+chr(33)
	cvtarr[1,20]="019"
	cvtarr[2,20]=chr(51)
	cvtarr[3,20]=chr(51)
	cvtarr[4,20]="19"
	cvtarr[5,20]=chr(38)+chr(33)+chr(42)
	cvtarr[1,21]="020"
	cvtarr[2,21]=chr(52)
	cvtarr[3,21]=chr(52)
	cvtarr[4,21]="20"
	cvtarr[5,21]=chr(38)+chr(34)+chr(41)
	cvtarr[1,22]="021"
	cvtarr[2,22]=chr(53)
	cvtarr[3,22]=chr(53)
	cvtarr[4,22]="21"
	cvtarr[5,22]=chr(37)+chr(42)+chr(34)
	cvtarr[1,23]="022"
	cvtarr[2,23]=chr(54)
	cvtarr[3,23]=chr(54)
	cvtarr[4,23]="22"
	cvtarr[5,23]=chr(38)+chr(41)+chr(34)
	cvtarr[1,24]="023"
	cvtarr[2,24]=chr(55)
	cvtarr[3,24]=chr(55)
	cvtarr[4,24]="23"
	cvtarr[5,24]=chr(41)+chr(37)+chr(41)
	cvtarr[1,25]="024"
	cvtarr[2,25]=chr(56)
	cvtarr[3,25]=chr(56)
	cvtarr[4,25]="24"
	cvtarr[5,25]=chr(41)+chr(34)+chr(38)
	cvtarr[1,26]="025"
	cvtarr[2,26]=chr(57)
	cvtarr[3,26]=chr(57)
	cvtarr[4,26]="25"
	cvtarr[5,26]=chr(42)+chr(33)+chr(38)
	cvtarr[1,27]="026"
	cvtarr[2,27]=chr(58)
	cvtarr[3,27]=chr(58)
	cvtarr[4,27]="26"
	cvtarr[5,27]=chr(42)+chr(34)+chr(37)
	cvtarr[1,28]="027"
	cvtarr[2,28]=chr(59)
	cvtarr[3,28]=chr(59)
	cvtarr[4,28]="27"
	cvtarr[5,28]=chr(41)+chr(38)+chr(34)
	cvtarr[1,29]="028"
	cvtarr[2,29]=chr(60)
	cvtarr[3,29]=chr(60)
	cvtarr[4,29]="28"
	cvtarr[5,29]=chr(42)+chr(37)+chr(34)
	cvtarr[1,30]="029"
	cvtarr[2,30]=chr(61)
	cvtarr[3,30]=chr(61)
	cvtarr[4,30]="29"
	cvtarr[5,30]=chr(42)+chr(38)+chr(33)
	cvtarr[1,31]="030"
	cvtarr[2,31]=chr(62)
	cvtarr[3,31]=chr(62)
	cvtarr[4,31]="30"
	cvtarr[5,31]=chr(37)+chr(37)+chr(39)
	cvtarr[1,32]="031"
	cvtarr[2,32]=chr(63)
	cvtarr[3,32]=chr(63)
	cvtarr[4,32]="31"
	cvtarr[5,32]=chr(37)+chr(39)+chr(37)
	cvtarr[1,33]="032"
	cvtarr[2,33]=chr(64)
	cvtarr[3,33]=chr(64)
	cvtarr[4,33]="32"
	cvtarr[5,33]=chr(39)+chr(37)+chr(37)
	cvtarr[1,34]="033"
	cvtarr[2,34]=chr(65)
	cvtarr[3,34]=chr(65)
	cvtarr[4,34]="33"
	cvtarr[5,34]=chr(33)+chr(35)+chr(39)
	cvtarr[1,35]="034"
	cvtarr[2,35]=chr(66)
	cvtarr[3,35]=chr(66)
	cvtarr[4,35]="34"
	cvtarr[5,35]=chr(35)+chr(33)+chr(39)
	cvtarr[1,36]="035"
	cvtarr[2,36]=chr(67)
	cvtarr[3,36]=chr(67)
	cvtarr[4,36]="35"
	cvtarr[5,36]=chr(35)+chr(35)+chr(37)
	cvtarr[1,37]="036"
	cvtarr[2,37]=chr(68)
	cvtarr[3,37]=chr(68)
	cvtarr[4,37]="36"
	cvtarr[5,37]=chr(33)+chr(39)+chr(35)
	cvtarr[1,38]="037"
	cvtarr[2,38]=chr(69)
	cvtarr[3,38]=chr(69)
	cvtarr[4,38]="37"
	cvtarr[5,38]=chr(35)+chr(37)+chr(35)
	cvtarr[1,39]="038"
	cvtarr[2,39]=chr(70)
	cvtarr[3,39]=chr(70)
	cvtarr[4,39]="38"
	cvtarr[5,39]=chr(35)+chr(39)+chr(33)
	cvtarr[1,40]="039"
	cvtarr[2,40]=chr(71)
	cvtarr[3,40]=chr(71)
	cvtarr[4,40]="39"
	cvtarr[5,40]=chr(37)+chr(35)+chr(35)
	cvtarr[1,41]="040"
	cvtarr[2,41]=chr(72)
	cvtarr[3,41]=chr(72)
	cvtarr[4,41]="40"
	cvtarr[5,41]=chr(39)+chr(33)+chr(35)
	cvtarr[1,42]="041"
	cvtarr[2,42]=chr(73)
	cvtarr[3,42]=chr(73)
	cvtarr[4,42]="41"
	cvtarr[5,42]=chr(39)+chr(35)+chr(33)
	cvtarr[1,43]="042"
	cvtarr[2,43]=chr(74)
	cvtarr[3,43]=chr(74)
	cvtarr[4,43]="42"
	cvtarr[5,43]=chr(33)+chr(37)+chr(43)
	cvtarr[1,44]="043"
	cvtarr[2,44]=chr(75)
	cvtarr[3,44]=chr(75)
	cvtarr[4,44]="43"
	cvtarr[5,44]=chr(33)+chr(39)+chr(41)
	cvtarr[1,45]="044"
	cvtarr[2,45]=chr(76)
	cvtarr[3,45]=chr(76)
	cvtarr[4,45]="44"
	cvtarr[5,45]=chr(35)+chr(37)+chr(41)
	cvtarr[1,46]="045"
	cvtarr[2,46]=chr(77)
	cvtarr[3,46]=chr(77)
	cvtarr[4,46]="45"
	cvtarr[5,46]=chr(33)+chr(41)+chr(39)
	cvtarr[1,47]="046"
	cvtarr[2,47]=chr(78)
	cvtarr[3,47]=chr(78)
	cvtarr[4,47]="46"
	cvtarr[5,47]=chr(33)+chr(43)+chr(37)
	cvtarr[1,48]="047"
	cvtarr[2,48]=chr(79)
	cvtarr[3,48]=chr(79)
	cvtarr[4,48]="47"
	cvtarr[5,48]=chr(35)+chr(41)+chr(37)
	cvtarr[1,49]="048"
	cvtarr[2,49]=chr(80)
	cvtarr[3,49]=chr(80)
	cvtarr[4,49]="48"
	cvtarr[5,49]=chr(41)+chr(41)+chr(37)
	cvtarr[1,50]="049"
	cvtarr[2,50]=chr(81)
	cvtarr[3,50]=chr(81)
	cvtarr[4,50]="49"
	cvtarr[5,50]=chr(37)+chr(35)+chr(41)
	cvtarr[1,51]="050"
	cvtarr[2,51]=chr(82)
	cvtarr[3,51]=chr(82)
	cvtarr[4,51]="50"
	cvtarr[5,51]=chr(39)+chr(33)+chr(41)
	cvtarr[1,52]="051"
	cvtarr[2,52]=chr(83)
	cvtarr[3,52]=chr(83)
	cvtarr[4,52]="51"
	cvtarr[5,52]=chr(37)+chr(41)+chr(35)
	cvtarr[1,53]="052"
	cvtarr[2,53]=chr(84)
	cvtarr[3,53]=chr(84)
	cvtarr[4,53]="52"
	cvtarr[5,53]=chr(37)+chr(43)+chr(33)
	cvtarr[1,54]="053"
	cvtarr[2,54]=chr(85)
	cvtarr[3,54]=chr(85)
	cvtarr[4,54]="53"
	cvtarr[5,54]=chr(37)+chr(41)+chr(41)
	cvtarr[1,55]="054"
	cvtarr[2,55]=chr(86)
	cvtarr[3,55]=chr(86)
	cvtarr[4,55]="54"
	cvtarr[5,55]=chr(41)+chr(33)+chr(39)
	cvtarr[1,56]="055"
	cvtarr[2,56]=chr(87)
	cvtarr[3,56]=chr(87)
	cvtarr[4,56]="55"
	cvtarr[5,56]=chr(41)+chr(35)+chr(37)
	cvtarr[1,57]="056"
	cvtarr[2,57]=chr(88)
	cvtarr[3,57]=chr(88)
	cvtarr[4,57]="56"
	cvtarr[5,57]=chr(43)+chr(33)+chr(37)
	cvtarr[1,58]="057"
	cvtarr[2,58]=chr(89)
	cvtarr[3,58]=chr(89)
	cvtarr[4,58]="57"
	cvtarr[5,58]=chr(41)+chr(37)+chr(35)
	cvtarr[1,59]="058"
	cvtarr[2,59]=chr(90)
	cvtarr[3,59]=chr(90)
	cvtarr[4,59]="58"
	cvtarr[5,59]=chr(41)+chr(39)+chr(33)
	cvtarr[1,60]="059"
	cvtarr[2,60]=chr(91)
	cvtarr[3,60]=chr(91)
	cvtarr[4,60]="59"
	cvtarr[5,60]=chr(43)+chr(37)+chr(33)
	cvtarr[1,61]="060"
	cvtarr[2,61]=chr(92)
	cvtarr[3,61]=chr(92)
	cvtarr[4,61]="60"
	cvtarr[5,61]=chr(41)+chr(45)+chr(33)
	cvtarr[1,62]="061"
	cvtarr[2,62]=chr(93)
	cvtarr[3,62]=chr(93)
	cvtarr[4,62]="61"
	cvtarr[5,62]=chr(38)+chr(36)+chr(33)
	cvtarr[1,63]="062"
	cvtarr[2,63]=chr(94)
	cvtarr[3,63]=chr(94)
	cvtarr[4,63]="62"
	cvtarr[5,63]=chr(47)+chr(33)+chr(33)
	cvtarr[1,64]="063"
	cvtarr[2,64]=chr(95)
	cvtarr[3,64]=chr(95)
	cvtarr[4,64]="63"
	cvtarr[5,64]=chr(33)+chr(34)+chr(40)
	cvtarr[1,65]="064"
	cvtarr[2,65]=chr(0)
	cvtarr[3,65]=chr(96)
	cvtarr[4,65]="64"
	cvtarr[5,65]=chr(33)+chr(36)+chr(38)
	cvtarr[1,66]="065"
	cvtarr[2,66]=chr(1)
	cvtarr[3,66]=chr(97)
	cvtarr[4,66]="65"
	cvtarr[5,66]=chr(34)+chr(33)+chr(40)
	cvtarr[1,67]="066"
	cvtarr[2,67]=chr(2)
	cvtarr[3,67]=chr(98)
	cvtarr[4,67]="66"
	cvtarr[5,67]=chr(34)+chr(36)+chr(37)
	cvtarr[1,68]="067"
	cvtarr[2,68]=chr(3)
	cvtarr[3,68]=chr(99)
	cvtarr[4,68]="67"
	cvtarr[5,68]=chr(36)+chr(33)+chr(38)
	cvtarr[1,69]="068"
	cvtarr[2,69]=chr(4)
	cvtarr[3,69]=chr(100)
	cvtarr[4,69]="68"
	cvtarr[5,69]=chr(36)+chr(34)+chr(37)
	cvtarr[1,70]="069"
	cvtarr[2,70]=chr(5)
	cvtarr[3,70]=chr(101)
	cvtarr[4,70]="69"
	cvtarr[5,70]=chr(33)+chr(38)+chr(36)
	cvtarr[1,71]="070"
	cvtarr[2,71]=chr(6)
	cvtarr[3,71]=chr(102)
	cvtarr[4,71]="70"
	cvtarr[5,71]=chr(33)+chr(40)+chr(34)
	cvtarr[1,72]="071"
	cvtarr[2,72]=chr(7)
	cvtarr[3,72]=chr(103)
	cvtarr[4,72]="71"
	cvtarr[5,72]=chr(34)+chr(37)+chr(36)
	cvtarr[1,73]="072"
	cvtarr[2,73]=chr(8)
	cvtarr[3,73]=chr(104)
	cvtarr[4,73]="72"
	cvtarr[5,73]=chr(34)+chr(40)+chr(33)
	cvtarr[1,74]="073"
	cvtarr[2,74]=chr(9)
	cvtarr[3,74]=chr(105)
	cvtarr[4,74]="73"
	cvtarr[5,74]=chr(36)+chr(37)+chr(34)
	cvtarr[1,75]="074"
	cvtarr[2,75]=chr(10)
	cvtarr[3,75]=chr(106)
	cvtarr[4,75]="74"
	cvtarr[5,75]=chr(36)+chr(38)+chr(33)
	cvtarr[1,76]="075"
	cvtarr[2,76]=chr(11)
	cvtarr[3,76]=chr(107)
	cvtarr[4,76]="75"
	cvtarr[5,76]=chr(40)+chr(34)+chr(33)
	cvtarr[1,77]="076"
	cvtarr[2,77]=chr(12)
	cvtarr[3,77]=chr(108)
	cvtarr[4,77]="76"
	cvtarr[5,77]=chr(38)+chr(33)+chr(36)
	cvtarr[1,78]="077"
	cvtarr[2,78]=chr(13)
	cvtarr[3,78]=chr(109)
	cvtarr[4,78]="77"
	cvtarr[5,78]=chr(45)+chr(41)+chr(33)
	cvtarr[1,79]="078"
	cvtarr[2,79]=chr(14)
	cvtarr[3,79]=chr(110)
	cvtarr[4,79]="78"
	cvtarr[5,79]=chr(40)+chr(33)+chr(34)
	cvtarr[1,80]="079"
	cvtarr[2,80]=chr(15)
	cvtarr[3,80]=chr(111)
	cvtarr[4,80]="79"
	cvtarr[5,80]=chr(35)+chr(45)+chr(33)
	cvtarr[1,81]="080"
	cvtarr[2,81]=chr(16)
	cvtarr[3,81]=chr(112)
	cvtarr[4,81]="80"
	cvtarr[5,81]=chr(33)+chr(34)+chr(46)
	cvtarr[1,82]="081"
	cvtarr[2,82]=chr(17)
	cvtarr[3,82]=chr(113)
	cvtarr[4,82]="81"
	cvtarr[5,82]=chr(34)+chr(33)+chr(46)
	cvtarr[1,83]="082"
	cvtarr[2,83]=chr(18)
	cvtarr[3,83]=chr(114)
	cvtarr[4,83]="82"
	cvtarr[5,83]=chr(34)+chr(34)+chr(45)
	cvtarr[1,84]="083"
	cvtarr[2,84]=chr(19)
	cvtarr[3,84]=chr(115)
	cvtarr[4,84]="83"
	cvtarr[5,84]=chr(33)+chr(46)+chr(34)
	cvtarr[1,85]="084"
	cvtarr[2,85]=chr(20)
	cvtarr[3,85]=chr(116)
	cvtarr[4,85]="84"
	cvtarr[5,85]=chr(34)+chr(45)+chr(34)
	cvtarr[1,86]="085"
	cvtarr[2,86]=chr(21)
	cvtarr[3,86]=chr(117)
	cvtarr[4,86]="85"
	cvtarr[5,86]=chr(34)+chr(46)+chr(33)
	cvtarr[1,87]="086"
	cvtarr[2,87]=chr(22)
	cvtarr[3,87]=chr(118)
	cvtarr[4,87]="86"
	cvtarr[5,87]=chr(45)+chr(34)+chr(34)
	cvtarr[1,88]="087"
	cvtarr[2,88]=chr(23)
	cvtarr[3,88]=chr(119)
	cvtarr[4,88]="87"
	cvtarr[5,88]=chr(46)+chr(33)+chr(34)
	cvtarr[1,89]="088"
	cvtarr[2,89]=chr(24)
	cvtarr[3,89]=chr(120)
	cvtarr[4,89]="88"
	cvtarr[5,89]=chr(46)+chr(34)+chr(33)
	cvtarr[1,90]="089"
	cvtarr[2,90]=chr(25)
	cvtarr[3,90]=chr(121)
	cvtarr[4,90]="89"
	cvtarr[5,90]=chr(37)+chr(37)+chr(45)
	cvtarr[1,91]="090"
	cvtarr[2,91]=chr(26)
	cvtarr[3,91]=chr(122)
	cvtarr[4,91]="90"
	cvtarr[5,91]=chr(37)+chr(45)+chr(37)
	cvtarr[1,92]="091"
	cvtarr[2,92]=chr(27)
	cvtarr[3,92]=chr(123)
	cvtarr[4,92]="91"
	cvtarr[5,92]=chr(45)+chr(37)+chr(37)
	cvtarr[1,93]="092"
	cvtarr[2,93]=chr(28)
	cvtarr[3,93]=chr(124)
	cvtarr[4,93]="92"
	cvtarr[5,93]=chr(33)+chr(33)+chr(47)
	cvtarr[1,94]="093"
	cvtarr[2,94]=chr(29)
	cvtarr[3,94]=chr(125)
	cvtarr[4,94]="93"
	cvtarr[5,94]=chr(33)+chr(35)+chr(45)
	cvtarr[1,95]="094"
	cvtarr[2,95]=chr(30)
	cvtarr[3,95]=chr(126)
	cvtarr[4,95]="94"
	cvtarr[5,95]=chr(35)+chr(33)+chr(45)
	cvtarr[1,96]="095"
	cvtarr[2,96]=chr(31)
	cvtarr[3,96]=chr(127)
	cvtarr[4,96]="95"
	cvtarr[5,96]=chr(33)+chr(45)+chr(35)
	cvtarr[1,97]="096"
	cvtarr[2,97]=""
	cvtarr[3,97]=""
	cvtarr[4,97]="96"
	cvtarr[5,97]=chr(33)+chr(47)+chr(33)
	cvtarr[1,98]="097"
	cvtarr[2,98]=""
	cvtarr[3,98]=""
	cvtarr[4,98]="97"
	cvtarr[5,98]=chr(45)+chr(33)+chr(35)
	cvtarr[1,99]="098"
	cvtarr[2,99]=""
	cvtarr[3,99]=""
	cvtarr[4,99]="98"
	cvtarr[5,99]=chr(45)+chr(35)+chr(33)
	cvtarr[1,100]="099"
	cvtarr[2,100]=""
	cvtarr[3,100]=""
	cvtarr[4,100]="99"
	cvtarr[5,100]=chr(33)+chr(41)+chr(45)
	cvtarr[1,101]="100"
	cvtarr[2,101]=""
	cvtarr[3,101]=""
	cvtarr[4,101]=""
	cvtarr[5,101]=chr(33)+chr(45)+chr(41)
	cvtarr[1,102]="101"
	cvtarr[2,102]=""
	cvtarr[3,102]=""
	cvtarr[4,102]=""
	cvtarr[5,102]=chr(41)+chr(33)+chr(45)
	cvtarr[1,103]="102"
	cvtarr[2,103]=""
	cvtarr[3,103]=""
	cvtarr[4,103]=""
	cvtarr[5,103]=chr(45)+chr(33)+chr(41)
	cvtarr[1,104]="103"
	cvtarr[2,104]=""
	cvtarr[3,104]=""
	cvtarr[4,104]=""
	cvtarr[5,104]=chr(37)+chr(36)+chr(34)
	cvtarr[1,105]="104"
	cvtarr[2,105]=""
	cvtarr[3,105]=""
	cvtarr[4,105]=""
	cvtarr[5,105]=chr(37)+chr(34)+chr(36)
	cvtarr[1,106]="105"
	cvtarr[2,106]=""
	cvtarr[3,106]=""
	cvtarr[4,106]=""
	cvtarr[5,106]=chr(37)+chr(34)+chr(42)

	* private chkcnt = 0
	* private chktot = 0
	chkcnt = 0
	chktot = 0

	*** check the character string and optimize the structure
	m = chrcheck(m,fnc1,fnc2,fnc3)

	do while cont
	  t = substr(m,cnt,1)
	  do case
	    case t = s_char
	      rtnc = substr(m,cnt+1,1)
	*  remove this
	*     if rtnc = "#"
	*       rtnc = asubscript(contarr,ascan(contarr,t,aelement(contarr,2,1),10),2)
	*     endif
	      do case
	        case rtnc == chr(98)
	          shift = .t.
	          rtncode = rtncode + cvtarr[5,99]
	          chktot = chktot + (chkcnt * 98)
	          chkcnt = chkcnt + 1
	        case rtnc == chr(99)
	          codeset = 3
	          rtncode = rtncode + cvtarr[5,100]
	          chktot = chktot + (chkcnt * 99)
	          chkcnt = chkcnt + 1
	        case rtnc == chr(100)
	          codeset = 2
	          rtncode = rtncode + cvtarr[5,101]
	          chktot = chktot + (chkcnt * 100)
	          chkcnt = chkcnt + 1
	        case rtnc == chr(101)
	          codeset = 1
	          rtncode = rtncode + cvtarr[5,102]
	          chktot = chktot + (chkcnt * 101)
	          chkcnt = chkcnt + 1
	        case rtnc == chr(103)
	          codeset = 1
	          rtncode = rtncode + cvtarr[5,104]
	          chktot = chktot + 103
	          chkcnt = chkcnt + 1
	        case rtnc == chr(104)
	          codeset = 2
	          rtncode = rtncode + cvtarr[5,105]
	          chktot = chktot + 104
	          chkcnt = chkcnt + 1
	        case rtnc == chr(105)
	          codeset = 3
	          rtncode = rtncode + cvtarr[5,106]
	          chktot = chktot + 105
	          chkcnt = chkcnt + 1
	      endcase

	      if (rtnc = chr(100) .and. codeset = 2) .or. ;
	         (rtnc = chr(101) .and. codeset = 1)
	         fcn4 = iif(fcn4 < 4,fcn4 + 1,1)
	      endif
	      cnt = cnt + 2

	    case codeset = 3 .and. asc(t) >= asc("0") .and. asc(t) <= asc("9")
	      t = substr(m,cnt,2)
	      rtnc = asubscript(cvtarr,ascan(cvtarr,t,aelement(cvtarr,4,1),106),2)
	      if rtnc <> 0
	        rtncode = rtncode + cvtarr[5,rtnc]
	        chktot = chktot + (chkcnt * val(cvtarr[1,rtnc]))
	        chkcnt = chkcnt + 1
	      endif
	      cnt = cnt + 2
	      shift = .f.

	    otherwise
	      if fcn4 > 1
	        if fcn4 = 4
	          t = chr(asc(t) - 128)
	        endif
	        fcn4 = iif(fcn4 == 2,1,3)
	      endif
	      cset = iif(shift,iif(codeset == 1,2,1),codeset)
	      rtnc = asubscript(cvtarr,ascan(cvtarr,t,aelement(cvtarr,cset+1,1),100),2)
	      if rtnc <> 0
	        rtncode = rtncode + cvtarr[5,rtnc]
	        chktot = chktot + (chkcnt * val(cvtarr[1,rtnc]))
	        chkcnt = chkcnt + 1
	      endif
	      cnt = cnt + 1
	      shift = .f.
	  endcase
	  cont = iif(cnt > len(m),.f.,.t.)
	enddo

	*** add check digit
	* calculate the check digit
	rtnc = asubscript(cvtarr,ascan(cvtarr,padl(ltrim(str(mod(chktot,103),3,0)),3,"0"),;
	             aelement(cvtarr,1,1),106),2)

	if rtnc > 0
	  * add check digit and stop code
	  rtncode = rtncode+cvtarr[5,rtnc]+chr(39)+chr(41)+chr(33)+chr(49)
	endif

	** return the character pattern

return rtncode
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure chrcheck
	Parameter m,fnc1,fnc2,fnc3

	private i,tstr,rtnstr,codeset,cset,shift,fcn4,pfcn4,cont,numchr,malen

	codeset = 1
	cset =1
	shift = .f.
	fcn4 = 1
	pfcn4 = .f.
	numchr = 0

	if substr(m,1,1) = "/"
	  return m
	endif

	** place the message string in an array
	dimension ma(len(m))
	for i = 1 to len(m)
	  ma[i] = substr(m,i,1)
	endfor
	malen = alen(ma)

	rtnstr = ""

	ncodec = tcode(@ma,malen,1,3)

	*** calculate start code
	do case
	  case malen = 2 .and. ncodec = 2
	    rtnstr = "/"+chr(105)
	    codeset = 3

	  case ncodec >= 4

	   if chrodd(ncodec)
	     rtnstr = "/" + chr(104)
	     codeset = 2
	   else
	     rtnstr = "/" + chr(105)
	     codeset = 3
	   endif

	  otherwise
	    cont = .t.
	    i = 1
	    do while cont
	      do case
	        case chrbtwn(ma[i],chr(0),chr(31))
	          cont = .f.
	          rtnstr = "/"+chr(103)
	          codeset = 1
	        case chrbtwn(ma[i],chr(96),chr(127))
	          cont = .f.
	          rtnstr = "/"+chr(104)
	          codeset = 2
	      endcase
	      i = i + 1
	      if malen < i .and. cont
	        cont = .f.
	        rtnstr = "/"+chr(104)
	        codeset = 2
	      endif
	    enddo
	endcase

	if fnc1 = 1
	  rtnstr = rtnstr + "/" + chr(102)
	endif
	if fnc2 = 1
	  rtnstr = rtnstr + "/" + chr(97)
	endif
	if fnc3 = 1
	  rtnstr = rtnstr + "/" + chr(96)
	endif

	*** convert the message
	cont = .t.
	i = 1
	do while cont
	  ** process until code change is necessary
	  do case
	    case codeset = 1
	      numchr = tcode(@ma, malen, i, 1)
	      for k = 1 to numchr
	        rtnstr = rtnstr + ma[i]
	        i = i + 1
	      endfor
	    case codeset = 2
	      numchr = tcode(@ma,malen,i,2)
	      for k = 1 to numchr
	        rtnstr = rtnstr + ma[i]
	        i = i + 1
	      endfor
	    case codeset = 3
	      numchr = tcode(@ma,malen,i,3)
	      for k = 1 to numchr
	        rtnstr = rtnstr + ma[i]
	        i = i + 1
	      endfor
	  endcase

	  if i > malen
	    ** hit end of string
	    cont = .f.
	  endif

	  ** process code change
	  if cont
	    do case
	      case codeset = 1
	        do case
	          case chrbtwn(ma[i],"0","9")
	            numchr = tcode(@ma,malen,i,3)
	            if numchr >= 4
	              if chrodd(numchr)
	                rtnstr = rtnstr + ma[i] + "/" + chr(99)
	                codeset = 3
	                i = i + 1
	              else
	                rtnstr = rtnstr + "/" + chr(99)
	                codeset = 3
	              endif
	            else
	              for k = 1 to numchr
	                rtnstr = rtnstr + ma[i]
	                i = i + 1
	              endfor
	            endif
	          otherwise
	            * next char must be code set 2
	            if i+1 <= malen
	              do nxtab with ma,i+1,numchr
	              if numchr = 1
	                rtnstr = rtnstr + "/" + chr(98) + ma[i]
	                i = i + 1
	              else
	                rtnstr = rtnstr + "/" + chr(100)
	                codeset = 2
	              endif
	            else
	              rtnstr = rtnstr + "/" + chr(100)
	              codeset = 2
	            endif
	        endcase
	      case codeset = 2
	        do case
	          case chrbtwn(ma[i],"0","9")
	            numchr = tcode(@ma,malen,i,3)
	            if numchr >= 4
	              if chrodd(numchr)
	                rtnstr = rtnstr + ma[i] + "/" + chr(99)
	                codeset = 3
	                i = i + 1
	              else
	                rtnstr = rtnstr + "/" + chr(99)
	                codeset = 3
	              endif
	            else
	              for k = 1 to numchr
	                rtnstr = rtnstr + ma[i]
	                i = i + 1
	              endfor
	            endif
	          otherwise
	            * next char must be code set 1
	            if i+1 <= malen
	              do nxtab with ma,i,numchr
	              if numchr = 2
	                rtnstr = rtnstr + "/" + chr(98) + ma[i]
	                i = i + 1
	              else
	                rtnstr = rtnstr + "/" + chr(101)
	                codeset = 1
	              endif
	            else
	              rtnstr = rtnstr + "/" + chr(101)
	              codeset = 1
	            endif
	        endcase
	      case codeset = 3
	        do nxtab with ma,i,numchr
	        if numchr = 1
	          rtnstr = rtnstr + "/" + chr(101)
	          codeset = 1
	        else
	          rtnstr = rtnstr + "/" + chr(100)
	          codeset = 2
	        endif
	    endcase
	  endif
	  
	  if i > malen
	    ** hit end of string
	    cont = .f.
	  endif
	  
	enddo
return rtnstr
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure chrbtwn
	parameters c,b,e
return iif(asc(c)>=asc(b) .and. asc(c) <= asc(e),.t.,.f.)
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure tcode
	parameters ma, strl, i, cset, retnum

	private cont,j

	j = i
	cont = .t.
	retnum = 0
	do case
	  case cset = 1
	    do while cont
	      nstr = asc(ma[j])
	      if (nstr >= 0 .and. nstr <= 47) .or. (nstr >= 58 .and. nstr <= 95)
	        retnum = retnum + 1
	        j = j + 1
	      else
	        if (nstr >= 48 .and. nstr <= 57)
	          nchr = tcode(@ma,strl,j,3)
	          if (nchr >= 4)
	            if chrodd(nchr)
	              retnum = retnum + 1
	            endif
	            cont = .f.
	          else
	            for k = 1 to nchr
	              retnum = retnum + 1
	              j = j + 1
	            endfor
	          endif
	        else
	          cont = .f.
	        endif
	      endif

	      if j > strl
	        cont = .f.
	      endif
	    enddo
	  case cset = 2
	    do while cont
	      nstr = asc(ma[j])
	      if (nstr >= 32 .and. nstr <= 47) .or. (nstr >= 58 .and. nstr <= 127)
	        retnum = retnum + 1
	        j = j + 1
	      else
	        if nstr >= 48 .and. nstr <= 57
	          nchr = tcode(@ma,strl,j,3)
	          if (nchr >= 4)
	            if chrodd(nchr)
	              retnum = retnum + 1
	            endif
	            cont = .f.
	          else
	            for k = 1 to nchr
	              retnum = retnum + 1
	              j = j + 1
	            endfor
	          endif
	        else
	          cont = .f.
	        endif
	      endif
	      if j >= strl
	        cont = .f.
	      endif
	    enddo
	  case cset = 3
	    * this does not check for an even # of char
	    do while cont
	      nstr = asc(ma[j])
	      if nstr >= 48 .and. nstr <= 57
	        retnum = retnum + 1
	        j = j + 1
	      else
	        cont = .f.
	      endif

	      if j > strl
	        cont = .f.
	      endif
	    enddo

	endcase
return retnum
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure nxtab
	parameters carr,c,retnum
	private i,cont

	i = c
	cont = .t.
	retnum = 0
	do while cont
	  do case
	    case asc(carr[i]) >= 96 .and. asc(carr[i]) <= 127
	      retnum = 2
	      return
	    case asc(carr[i]) >= 0 .and. asc(carr[i]) <= 31
	      retnum = 1
	      return 1
	  endcase
	  i = i + 1
	  if i > alen(carr)
	    retnum = 0
	    return
	  endif
	enddo
	retnum = 0
return
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure chrodd
	parameters c
return iif(c%2>0,.t.,.f.)
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
