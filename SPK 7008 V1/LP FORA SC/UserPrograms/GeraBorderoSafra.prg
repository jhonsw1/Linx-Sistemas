Define Class ObjGeraBorderoSafra As Custom
	Procedure GeraBorderoSafra
		lParameters FormBorderoSafra, intDataSessionID
		Set Datasession To intDataSessionID
		If Empty(FormBorderoSafra.txtAgencia.Value)
			FormBorderoSafra.txtAgencia.SetFocus()
			MsgBox("Você deve colocar uma agência.", 16, "Atenção")
			Return .f.
		EndIf
		
		If Empty(FormBorderoSafra.txtCodigoCedente.Value)
			FormBorderoSafra.txtCodigoCedente.SetFocus()
			MsgBox("Você deve colocar um código do cedente.", 16, "Atenção")
			Return .f.
		EndIf
		
		If Empty(FormBorderoSafra.txtDigito.Value)
			FormBorderoSafra.txtDigito.SetFocus()
			MsgBox("Você deve colocar um dígito para código do cedente.", 16, "Atenção")
			Return .f.
		EndIf
		
		If Empty(FormBorderoSafra.cmbAgenciaCentralizadora.Value)
			FormBorderoSafra.cmbAgenciaCentralizadora.SetFocus()
			MsgBox("Você deve colocar uma agencia centralizadora.", 16, "Atenção")
			Return .f.
		EndIf
		
		Local	strCabecalho, strArquivo, strDiretorio, strArq, iCount, strNomeArq, strExtensao, strLote, hFile, ;
				strLinha, strCMC7, intRecNo, intRecNoValidos, strTag, strTagValidos, strDir, strDiret, strRecordSource, intOrdemNaoProcessado, ;
				intTotalNaoProcessados, strInsert, strSelect, intLote
		
		strDiretorio = AddBs(iIf(Left(FormBorderoSafra.txtDiretorio.Value, 2) == "\\" And !SubStr(FormBorderoSafra.txtDiretorio.Value, 3, 1) == "\", AllTrim(FormBorderoSafra.txtDiretorio.Value), AllTrim(FormBorderoSafra.cmbDiretorio.Value) + iIf(!Empty(FormBorderoSafra.txtDiretorio.Value) And !Left(FormBorderoSafra.txtDiretorio.Value, 1) == "\", "\", "") + AllTrim(FormBorderoSafra.txtDiretorio.Value)))
		
		If !Directory(strDiretorio)
			If MsgBox('O diretório "' + strDiretorio + '" não existe.\nVocê deseja criá-lo agora?', 4 + 32, "Atenção") = 7
				Return .f.
			EndIf
			Local Array aDiretorio(1)
			strDiret = Right(strDiretorio, Len(strDiretorio) - iIf(Left(strDiretorio, 2) == "\\" And !SubStr(strDiretorio, 3, 1) == "\", 2, 3))
			Do While At('\', strDiret) <> 0
				strDir = Left(strDiret, At('\', strDiret) - 1)
				strDiret = Right(strDiret, Len(strDiret) - At('\', strDiret))
				If Type("aDiretorio") != "L"
					Declare aDiretorio[aLen(aDiretorio, 1) + 1]
				EndIf
				aDiretorio[aLen(aDiretorio)] = strDir
			EndDo
			
			strDiret = iIf(Left(FormBorderoSafra.txtDiretorio.Value, 2) == "\\" And !SubStr(FormBorderoSafra.txtDiretorio.Value, 3, 1) == "\", "\\", Upper(AllTrim(FormBorderoSafra.cmbDiretorio.Value)))
			For iCount = 1 To aLen(aDiretorio, 1)
				strDiret = strDiret + iIf(Right(strDiret, 1) <> "\", "\", "") + aDiretorio[iCount]
				If !Directory(strDiret)
					MkDir "&strDiret"
				EndIf
			EndFor
		EndIf
		
		strDiretorio = strDiretorio + iIf(FormBorderoSafra.chkCriarSubPastas.Value, PadL(Day(Main.Date), 2, "0") + "_" + PadL(Month(Main.Date), 2, "0") + "_" + Right(PadL(Year(Main.Date), 4, "0"), 2) + "\", "")
		
		If !Directory(strDiretorio)
			MkDir "&strDiretorio"
		EndIf
		
		strCodigoCedente = Replicate("0", 8 - Len(AllTrim(FormBorderoSafra.txtCodigoCedente.Value))) + AllTrim(FormBorderoSafra.txtCodigoCedente.Value)
		
		intRecNo = RecNo("curChecksCMC7")
		intRecNoValidos = RecNo("curChecksCMC7ValidosPre")
		
		FormBorderoSafra.pgfPrincipal.Page1.grdCMC7.RecordSource = ""
		
		FormBorderoSafra.pgfPrincipal.Page1.opgTipos.Enabled = .f.
		
		If Used("curProcessados")
			Use In curProcessados
		EndIf
		
		intTotalNaoProcessados = 0
		If Used("curNaoProcessados")
			Use In curNaoProcessados
		EndIf
		
		If Used("curAlterados")
			Use In curAlterados
		EndIf
		
		intCount = 0
		
		strCabecalho =	PadL(Day(Main.Date), 2, "0") + PadL(Month(Main.Date), 2, "0") + PadL(Year(Main.Date), 4, "0") + " " + ;
						PadL(AllTrim(FormBorderoSafra.txtAgencia.Value), 5, "0") + strCodigoCedente + FormBorderoSafra.txtDigito.Value + " 000 "
		
		strData_Lote = Left(strCabecalho, At(" ", strCabecalho) - 1)
		strSelect = "Select Max(Valor_Propriedade) As Data_Lote " + ;
					"From Prop_Loja_Venda_Parcelas " + ;
					"Where Codigo_Filial = ?curChecksCMC7ValidosPre.Codigo_Filial And " + ;
					"Left(Valor_Propriedade, 8) = ?strData_Lote"
		If !SQLSelect(strSelect, "curLote", "Erro pesquisando último lote.")
			Main.Data.RollBackTransaction()
			FormBorderoSafra.pgfPrincipal.Page1.grdCMC7.RecordSource = "curChecksCMC7ValidosPre"
			Return .f.
		EndIf
		intLote = Nvl(Int(Val(Right(AllTrim(curLote.Data_Lote), 3))), 0) + 1
		Use In curLote
		strLote = PadL(intLote, 5, "0")
		
		strArquivo = strDiretorio + strCodigoCedente + "." + Right(strLote, 3)
		
		strData_Lote = Left(strCabecalho, At(" ", strCabecalho) - 1) + Right(strLote, 3)
		
		strExclusivoCliente = PadL(AllTrim(Str(FormBorderoSafra.txtExclusivoClienteN1.Value, 8, 0)), 8, "0") + PadL(AllTrim(Str(FormBorderoSafra.txtExclusivoClienteN2.Value, 8, 0)), 8, "0") + PadR(AllTrim(FormBorderoSafra.txtExclusivoCliente.Value), 9, " ")
		
		strInsert = "Insert Into Prop_Loja_Venda_Parcelas (" + ;
					"Propriedade, " + ;
					"Terminal, " + ;
					"Lancamento_Caixa, " + ;
					"Codigo_Filial, " + ; 
					"Parcela, " + ;
					"Item_Propriedade, " + ;
					"Valor_Propriedade" + ;
					") Values (" + ;
					"'LOTE', " + ;
					"?curChecksCMC7ValidosPre.Terminal, " + ;
					"?curChecksCMC7ValidosPre.Lancamento_Caixa, " + ;
					"?curChecksCMC7ValidosPre.Codigo_Filial, " + ; 
					"?curChecksCMC7ValidosPre.Parcela, " + ;
					"1, " + ;
					"?strData_Lote" + ;
					")"
		
		intCountJaProcessados = 0
		hFile = fCreate(strArquivo)
		bCMC7 = Used("curCMC7Tmp")
		Main.Data.BeginTransaction()
		Select curChecksCMC7ValidosPre
		Set Filter To !Processado
		Count To intTotalNaoProcessados
		Scan
			intCount = intCount + 1
			ShowProgress("Gerando registro " + AllTrim(Transform(intCount, "999,999,999,999")) + " de "+ AllTrim(Transform(intTotalNaoProcessados, "999,999,999,999")) + ".", intTotalNaoProcessados)
			If !SQLExecute(strInsert, 'Erro inserindo na tabela de propriedades.')
				Main.Data.RollBackTransaction()
				FormBorderoSafra.pgfPrincipal.Page1.grdCMC7.RecordSource = "curChecksCMC7ValidosPre"
				Return .f.
			EndIf
			strLinha = strCabecalho +	SubStr(curChecksCMC7ValidosPre.Cheque_Cartao,  9,  3) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao,  1,  3) + ;
										" " + ;
										"0000" +;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao,  12, 6) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao,  4,  4) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao, 20, 10) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao, 19,  1) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao,  8,  1) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao, 30,  1) + ;
										" " + ;
										SubStr(curChecksCMC7ValidosPre.Cheque_Cartao, 18,  1) + ;
										" " + ;
										PadL(AllTrim(curChecksCMC7ValidosPre.CPF_CGC), 15, "0") + ;
										" " + ;
										PadR(AllTrim(Left(curChecksCMC7ValidosPre.Cliente_Varejo, 30)), 30, " ") + ;
										" " + ;
										PadL(Day(curChecksCMC7ValidosPre.Vencimento), 2, "0") + PadL(Month(curChecksCMC7ValidosPre.Vencimento), 2, "0") + PadL(Year(curChecksCMC7ValidosPre.Vencimento), 4, "0") + ;
										" " + ;
										PadL(StrTran(StrTran(AllTrim(Str(curChecksCMC7ValidosPre.Valor, 15, 2)), ".", ""), ",", ""), 17, "0") + ;
										" " + ;
										AllTrim(FormBorderoSafra.cmbAgenciaCentralizadora.Value) + ;
										strLote + ;
										"00000" + ;
										" " + ;
										"99" + ;
										"  " + ;
										"   " + ;
										" " + ;
										strExclusivoCliente + ;
										"   " + ;
										" " + ;
										PadL(AllTrim(Str(intCount, 6, 0)), 6, "0")
			fPuts(hFile, strLinha)
			Replace Processado With .t. In curChecksCMC7ValidosPre
			
			Seek curChecksCMC7ValidosPre.Codigo_Filial + curChecksCMC7ValidosPre.Terminal + curChecksCMC7ValidosPre.Lancamento_Caixa + curChecksCMC7ValidosPre.Parcela In curChecksCMC7
			If !Eof("curChecksCMC7")
				Replace Processado With .t. In curChecksCMC7
			EndIf
		EndScan
		Select curChecksCMC7ValidosPre
		Set Filter To
		Main.Data.CommitTransaction()
		
		fSeek(hFile, -9, 2)
		fWrite(hFile, "F", 2)
		
		fClose(hFile)
		If intCount = 0
			Delete File "&strArquivo"
		EndIf
		
		ShowProgress()
		If Used("curCMC7Tmp")
			Use In curCMC7Tmp
		EndIf
		
		Try
			Go intRecNoValidos In curChecksCMC7ValidosPre
		Catch
		EndTry
		
		Select curChecksCMC7
		If Empty(strTag)
			Set Order To
		Else
			Set Order To &strTag
		EndIf
		Try
			Go intRecNo In curChecksCMC7
		Catch
		EndTry
		
		FormBorderoSafra.pTipo = 0
		FormBorderoSafra.pgfPrincipal.Page1.opgTipos.Value = 1
		FormBorderoSafra.pgfPrincipal.Page1.grdCMC7.RecordSource = "curChecksCMC7ValidosPre"
		FormBorderoSafra.pgfPrincipal.Page1.opgTipos.Valid()
	EndProc
EndDefine