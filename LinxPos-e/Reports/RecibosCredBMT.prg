procedure MontaReciboBematech
lparameters oChargeAccontBMT as object

local strTerminal as string, strTransacao_EMS as string, strTransacao_EMS_Original as string, ;
	  strData_Hora as string, strNumeroCartao as string, ;
	  intParcelas as integer, strDataParcela as string, strValorParcela as string, intQtdeColumns as integer

strTextoComprovante = ""

strCursorDados = "curResposta_" + oChargeAccontBMT.Tipo + "_" + alltrim(str(oChargeAccontBMT.CodigoResposta))
if !used(strCursorDados)
	MsgBox('O cursor "' + strCursorDados + '" necessário para imprimir o recibo não está em uso.')
	return .f.
endif

intQtdeColumns = iif(empty(main.p_impressora_fiscal), 40, main.objECF.columns)

strTerminal = oChargeAccontBMT.Loja + "-" + oChargeAccontBMT.Terminal
strTransacao_EMS = padl(&strCursorDados..Transacao_EMS, 9, "0")
strData_Hora = dtoc(&strCursorDados..Data_Transacao_EMS) + " " + alltrim(&strCursorDados..Hora_Transacao_EMS)
strNumeroCartao = padr(oChargeAccontBMT.NumeroCartao, 16, " ")

do case
	case inlist(oChargeAccontBMT.Tipo, "VEND", "CANC")
		if type(strCursorDados + ".Transacao_EMS_Original") == "N"
			strTransacao_EMS_Original = padl(&strCursorDados..Transacao_EMS_Original, 9, "0")
		endif
		strTextoComprovante = "\n" + ;
							  "\n" + ;
							  padc(iif(oChargeAccontBMT.Tipo == "VEND", "", "CANCELAMENTO DE ") + "VENDA A CREDITO", intQtdeColumns, " ") + ;
							  "\n" + ;
							  "\n" + ;
							  "/*Via*\" + ;
							  "\n" + ;
							  "\n" + ;
							  strData_Hora + replicate(" ", intQtdeColumns - (len(strData_Hora) + len(strTerminal) + 5)) + "TERM " + strTerminal + "\n" + ;
							  "CARTAO " + strNumeroCartao + replicate(" ", intQtdeColumns - (len(strNumeroCartao) + len(strTransacao_EMS) + 7 + 4)) + "DOC " + strTransacao_EMS + "\n"
		if oChargeAccontBMT.Tipo == "CANC" and type("strTransacao_EMS_Original") == "C"
			strTextoComprovante = strTextoComprovante + ;
							  replicate(" ", intQtdeColumns - (len(strTransacao_EMS_Original) + 14)) + "DOC CANCELADO " + strTransacao_EMS_Original + "\n"
		endif
		strTextoComprovante = strTextoComprovante + ;
							  "CONTRATO " + iif(oChargeAccontBMT.Tipo == "VEND", "", "CANCELADO ") + padl(&strCursorDados..Local_Contrato_EMS, 3, "0") + padl(&strCursorDados..Contrato_EMS, 7, "0") + "\n" + ;
							  "\n"
		if oChargeAccontBMT.Tipo == "VEND"
			strTextoComprovante = strTextoComprovante + ;
					  		  "PARCELA   DATA VCTO.          VALOR\n"
			select curResposta_Parcelas
			scan
				strTextoComprovante = strTextoComprovante + ;
								  "  " + padl(curResposta_Parcelas.Numero_Parcela, 2, "0") + "/" + padl(&strCursorDados..Quant_Parcelas, 2, "0") + "   " + dtoc(curResposta_Parcelas.Vencimento) + " " + padl(alltrim(transform(curResposta_Parcelas.Valor, "9,999,999,999.99")), 16, ".") + "\n"
			endscan
			strTextoComprovante = strTextoComprovante + "\n"
		endif
							if oChargeAccontBMT.Tipo == "VEND"
								strTextoComprovante = strTextoComprovante + ;
								"VALOR TOTAL DA VENDA " + padl(alltrim(transform(&strCursorDados..Valor_Venda, "9,999,999,999.99")), 16, ".") + "\n" + ;
								"VALOR DA ENTRADA     " + padl(alltrim(transform(&strCursorDados..Valor_Entrada, "9,999,999,999.99")), 16, ".") + "\n"
							endif
		strTextoComprovante = strTextoComprovante + ;
							  "VALOR FINANCIADO     " + padl(alltrim(transform(&strCursorDados..Valor_Financiado, "9,999,999,999.99")), 16, ".") + "\n" + ;
							  "QUANT. PARCELAS      " + padl(padl(alltrim(transform(&strCursorDados..Quant_Parcelas, "99")), 2, "0"), 16, ".") + "\n" + ;
							  "JUROS                " + padl(alltrim(transform(&strCursorDados..Perc_Juros_Financiamento, "9,999,999,999.99")), 16, ".") + "\n" + ;
							  "\n" + ;
							  "PROXIMA FATURA NO DIA : " + padl(day(&strCursorDados..Data_Primeira_Parcela), 2, "0") + "\n" + ;
							  "  VENCTO....:   " + dtoc(&strCursorDados..Data_Primeira_Parcela) + "\n" + ;
							  "  SALDO (R$): " + transform(&strCursorDados..Valor_1_Parcela, "9,999,999.99") + "\n" + ;
							  "\n" + ;
							  "\n"
							if oChargeAccontBMT.Tipo == "VEND"
								strTextoComprovante = strTextoComprovante + ;
								padc("RECONHECO E PAGAREI ESTA DIVIDA", intQtdeColumns, " ") + "\n" + ;
								"\n" + ;
								"\n" + ;
								padc("---------------------------------", intQtdeColumns, " ") + "\n" + ;
								padc(alltrim(&strCursorDados..Nome_Cliente), intQtdeColumns, " ") + "\n"
							else
								strTextoComprovante = strTextoComprovante + ;
								padc(alltrim(&strCursorDados..Nome_Cliente), intQtdeColumns, " ") + "\n\n" + ;
								replicate("*", 38) + "\n" + ;
								" A TRANSACAO INDICADA NESTE DOCUMENTO" + "\n" + ;
								" FICA CANCELADA" + "\n" + ;
								replicate("*", 38) + "\n"
							endif
		strTextoComprovante = strTextoComprovante + ;
							  "\n" + ;
							  "\n" + ;
							  padc("ATENDIMENTO AO CLIENTE " + alltrim(&strCursorDados..Tel_Central), intQtdeColumns, " ")
	case oChargeAccontBMT.Tipo == "PGTO"
		local intRecibo as integer
		intRecibo = 0
		strTextoComprovante = ""
		select curLojaPgtoClienteQuitados
		scan
			intRecibo = intRecibo + 1
			strTransacao_EMS = padl(curLojaPgtoClienteQuitados.Numero_Aprovacao_Cartao, 9, "0")
			strData_Hora = dtoc(curLojaPgtoClienteQuitados.Data_Hora_TEF) + " " + time()
			strTextoComprovante = strTextoComprovante + ;
								  "\n" + ;
								  "\n" + ;
								  padc("RECIBO DE PAGAMENTO", intQtdeColumns, " ") + ;
								  "\n" + ;
								  "\n" + ;
								  strData_Hora + replicate(" ", intQtdeColumns - (len(strData_Hora) + len(strTerminal) + 5)) + "TERM " + strTerminal + ;
								  "\n" + ;
								  "\n" + ;
								  "/*Via*\" + ;
								  "\n" + ;
								  "\n" + ;
								  "CONTRATO..: " + alltrim(curLojaPgtoClienteQuitados.Documento) + "\n" + ;
								  "PARCELA...: " + right(alltrim(curLojaPgtoClienteQuitados.Finalizacao), 2) + "\n" + ;
								  "DOC.......: " + strTransacao_EMS + "\n" + ;
								  "CLIENTE...: " + alltrim(&strCursorDados..Nome_Cliente) + "\n" + ;
								  "\n" + ;
								  "VALOR PAGO: " + alltrim(transform(curLojaPgtoClienteQuitados.Valor_Pago, "9,999,999,999.99")) + "\n" + ;
								  "\n" + ;
								  padc("ATENDIMENTO AO CLIENTE " + alltrim(&strCursorDados..Tel_Central), intQtdeColumns, " ") + "\n" + ;
								  "*/|\*"
		endscan
endcase

return strTextoComprovante

endproc