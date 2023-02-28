CREATE VIEW [dbo].[W_IMPRESSAO_CFE] AS
-- DM		  - Diego Moreno	- #10# - (08/04/2019) - Medida emerg�ncial de melhoria de performance ao realizar vendas com SAT.
-- DM		  - Diego Moreno	- #9# - (07/08/2017) - Inclus�o da coluna CODIGO_FILIAL para utiliza��o no componente Linx.Nfce.FoxPro.
-- DM 11084   - V�vian Domingues - #8# - (08/12/2016) - Inclu�do o campo ID_EQUIPAMENTO para identifica��o de CUPOM que tenham o mesmo n�mero para equipamentos diferentes.
-- DM 5713	  - Eder Silva     - #7# - (29/07/2016) - Inclusa chamada da fun��o para remover os caracteres especiais do nome do cliente.
-- TP10505235 - Gilvano Santos - #6# - (13/11/2015) - Uso do campo CPF_CGC_ECF da tabela LOJA_VENDA para identificar clientes na emiss�o da NFC-e. 
-- TP10839227 - Eder Silva     - #5# - (03/11/2015) - Corre��o para pegar o n�mero do documento de cliente estrangeiro, obrigat�rio para NFCe acima de 10mil, pois estava gerando vazio
-- TP8692563  - JOAO.GONZALES/THIAGO MARCON - #4# - (23/05/2015) - Corre��o para buscar na coluna desconto
-- TP8679695  - Joao Gonzales  - #3# - (22/05/2015) - Implementa��o da regra de desconto no total na view, removendo o calculo que havia no componente.
-- TP5639147  - GILVANO SANTOS - #2# - (17/06/2015) - Remo��o do valor "TESTE" quando estiver parametrizado para homologa��o e documento modelo 59 
-- TP5639147  - GILVANO SANTOS - #1# - (27/03/2015) - IMPLANTA��O CF-E SAT, INCLUS�O DO "UNION ALL" PARA VIEW RECONHECER AS INFORMA��ES DAS TABELAS LOJA_CF_SAT...
SELECT
	CASE WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('EXIBE_NOME_FANTASIA_XML', C.CODIGO_FILIAL),'.F.') = '.T.' THEN 
			C.FILIAL 
		ELSE 
			CASE WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('EXIBE_NOME_FANTASIA_XML', C.CODIGO_FILIAL),'.F.') = '.F.' THEN  
				NULL ELSE C.FILIAL END 
		END NOME_FANTASIA_EMITENTE,
	C.FILIAL, 
	EMITENTE.CGC_CPF AS CNPJ_EMITENTE, 
	CFE.CF_NUMERO AS NF, 
	CFE.SERIE_NF, 
	CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL AS MODELO_FISCAL,  
	CASE WHEN Isnull(clientes_varejo.uf,'') = 'EX' THEN 3 
	     WHEN Isnull(clientes_varejo.uf,'') = EMITENTE.UF THEN 1
	ELSE 2 END AS ID_DESTINO_OPERACAO, 
	CFE.INDICA_CONSUMIDOR_FINAL AS INDICA_OPERACAO_FINAL,
    CFE.INDICA_PRESENCA_COMPRADOR AS INDICA_PRESENCA_COMPRADOR,
    CASE WHEN ISNULL(CLIENTES_VAREJO.UF,'') = 'EX' THEN ISNULL(CLIENTES_VAREJO.RG_IE,'') ELSE null END AS DOC_ESTRANGEIRO, 
	CASE WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL IN ('65','59') THEN  CFE.data_saida ELSE CFE.emissao END AS EMISSAO, 
	CFE.data_saida as DATA_SAIDA,
	CONVERT(NUMERIC(15, 5), CFE.DESCONTO) AS DESCONTO, --#4#
	CONVERT(NUMERIC(13, 10), CASE WHEN CFE.VALOR_TOTAL_ITENS != 0 THEN CFE.DESCONTO / CFE.VALOR_TOTAL_ITENS * 100 ELSE 0 END) AS PORC_DESCONTO, 
	CONVERT(NUMERIC(15,5), CFE.ENCARGO) AS ENCARGO, 
	CONVERT(NUMERIC(15,5), CFE.VALOR_TOTAL) AS VALOR_TOTAL, 
	CONVERT(NUMERIC(15,5), CFE.VALOR_TOTAL_ITENS) AS VALOR_SUB_ITENS, 
	CONVERT(INT, CFE.FIN_EMISSAO_CFE) AS FIN_EMISSAO_CFE, 
	CFE.TIPO_EMISSAO_CFE, 
	CFE.CHAVE_CFE, 
	CFE.STATUS_CFE, 
	CONVERT(CHAR(44), CFE.PROTOCOLO_AUTORIZACAO_CFE) as PROTOCOLO_AUTORIZACAO_CFE,
	CFE.DATA_AUTORIZACAO_CFE, 
	(SELECT (SUM(CASE WHEN LOJA_CF_SAT_ITEM.DESCONTO_ITEM > 0 THEN 
			CONVERT(NUMERIC(15,5), LOJA_CF_SAT_ITEM.DESCONTO_ITEM) * CONVERT(NUMERIC(15,5),LOJA_CF_SAT_ITEM.QTDE_ITEM) 
			ELSE 0 END) + sum(isnull(VALOR_DESCONTOS,0) )) * (-1)
		FROM LOJA_CF_SAT_ITEM 
		WHERE CODIGO_FILIAL = CFE.CODIGO_FILIAL
		AND ID_LOJA_CF_SAT = CFE.ID_LOJA_CF_SAT
	) AS VALOR_DESCONTO_ITENS, 
	ISNULL(CLIENTES_VAREJO.CODIGO_CLIENTE,'') AS CLIFOR, 	

	CASE WHEN ISNULL(CLIENTES_VAREJO.UF,'') = 'EX' and CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '59' THEN ''
		 WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' AND Isnull(CLIENTES_VAREJO.UF,'') = 'EX' THEN Isnull(CLIENTES_VAREJO.RG_IE,'') -- #5#
		 --WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL IN ('65','59') AND LEN(ISNULL(LOJA_VENDA.CPF_CGC_ECF,'')) > 0 THEN LOJA_VENDA.CPF_CGC_ECF	-- #6#
    	 --ELSE ISNULL(CLIENTES_VAREJO.CPF_CGC,'') -- #6#
		 ELSE ISNULL(LOJA_VENDA.CPF_CGC_ECF,'') --#6#
    END AS CNPJ_DESTINATARIO, -- #6#	
			      
	CASE RTRIM(COALESCE(LOJA_CF_SAT_XML.EMAIL_RETORNO, CLIENTES_VAREJO.EMAIL)) WHEN '' THEN NULL 
		ELSE RTRIM(COALESCE(LOJA_CF_SAT_XML.EMAIL_RETORNO,CLIENTES_VAREJO.EMAIL)) 
	END AS EMAIL_CFE,	

	-- TRATAMENTO HOMOLOGACAO NF-E 2.00 A PARTIR DE 01/05/2011
	CASE --WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('IDENTIFICA_AMBIENTE_NFCE', C.CODIGO_FILIAL),'0') = '2' AND CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '59' --#2#
		WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('IDENTIFICA_AMBIENTE_NFCE', C.CODIGO_FILIAL),'0') = '2' AND CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' --#2#
		THEN 'NFC-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'
		-- ELSE ISNULL(CLIENTES_VAREJO.CLIENTE_VAREJO,'') END AS RAZAO_SOCIAL,   --#7#
		ELSE [dbo].[Fx_replace_caracter_especial_nfe](0, ISNULL(CLIENTES_VAREJO.CLIENTE_VAREJO,'')) END AS RAZAO_SOCIAL,  --#7#

	ISNULL(CLIENTES_VAREJO.PAIS, CASE WHEN CLIENTES_VAREJO.UF = 'EX' THEN NULL ELSE 'BRASIL' END) AS PAIS, 
	ISNULL(CLIENTES_VAREJO.CEP,'') AS CEP, 
	ISNULL(RTRIM(CLIENTES_VAREJO.TIPO_LOGRADOURO) , '') + ' ' + ISNULL(RTRIM(CLIENTES_VAREJO.ENDERECO), '') AS ENDERECO, 
	ISNULL(CLIENTES_VAREJO.NUMERO,'') AS NUMERO, 
	ISNULL(CLIENTES_VAREJO.COMPLEMENTO,'') AS COMPLEMENTO, 
	ISNULL(CLIENTES_VAREJO.BAIRRO,'') AS BAIRRO, 
	ISNULL(CLIENTES_VAREJO.CIDADE,'') AS CIDADE, 
	ISNULL(CLIENTES_VAREJO.UF,'') AS UF, 
	ISNULL(CLIENTES_VAREJO.DDD,'') AS DDD1, 
	ISNULL(CLIENTES_VAREJO.TELEFONE,'') AS TELEFONE1, 
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 1, 1, 'L') AS ICMS, 
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 1, 2, 'L') AS ICMS_BASE,
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 2, 1, 'L') AS IPI, 
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 2, 2, 'L') AS IPI_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 3, 1) AS IRRF, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 3, 2) AS IRRF_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 4, 1) AS INSS, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 4, 2) AS INSS_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 5, 1) AS PIS, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 5, 2) AS PIS_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 6, 1) AS COFINS, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 6, 2) AS COFINS_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 7, 1) AS I_IMPORT, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 7, 2) AS I_IMPORT_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 8, 1) AS IVA, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 8, 2) AS IVA_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 9, 1) AS RECARGO, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 9, 2) AS RECARGO_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 10, 1) AS IRPF, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 10, 2) AS IRPF_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 11, 1) AS DICMS, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 11, 2) AS DICMS_BASE,
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 12, 1, 'L') AS ICMS_ST,
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 12, 2, 'L') AS ICMS_ST_BASE,
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 13, 1, 'L') AS ICMS_STR,
	DBO.FX_CALCULA_IMPOSTO_INCIDENCIA_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 13, 2, 'L') AS ICMS_STR_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 14, 1) AS ISS,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 14, 2) AS ISS_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 15, 1) AS IVA_IC,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 15, 2) AS IVA_IC_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 16, 1) AS PC_CSL,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 16, 2) AS PC_CSL_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 17, 1) AS PIS_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 17, 2) AS PIS_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 18, 1) AS COFINS_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 18, 2) AS COFINS_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 19, 1) AS CSLL_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 19, 2) AS CSLL_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 20, 1) AS IRRF_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 20, 2) AS IRRF_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 21, 1) AS INSS_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 21, 2) AS INSS_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 22, 1) AS ISS_R,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 22, 2) AS ISS_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 23, 1) AS PIS_S, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 23, 2) AS PIS_S_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 24, 1) AS COFINS_S, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 24, 2) AS COFINS_S_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 25, 1) AS CSLL_S, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 25, 2) AS CSLL_S_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 30, 1) AS RTEIVA, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 30, 2) AS RTEIVA_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 31, 1) AS RTEIVA_R, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 31, 2) AS RTEIVA_R_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 32, 1) AS ICA, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 32, 2) AS ICA_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 33, 1) AS RTEICA, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 33, 2) AS RTEICA_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 34, 1) AS RTEFTE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 34, 2) AS RTEFTE_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 35, 1) AS RTEFTE_R, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 35, 2) AS RTEFTE_R_BASE, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 36, 1) AS ICMS_ZF, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 36, 2) AS ICMS_ZF_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 36, 3) AS ICMS_ZF_ALIQ,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 37, 1) AS PIS_ZF, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 37, 2) AS PIS_ZF_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 37, 3) AS PIS_ZF_ALIQ,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 38, 1) AS COFINS_ZF, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 38, 2) AS COFINS_ZF_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 38, 3) AS COFINS_ZF_ALIQ,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 40, 1) AS DICMS_R, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 40, 2) AS DICMS_R_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 42, 1) AS FECP, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 42, 2) AS FECP_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 43, 1) AS SIMPLES_E, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 43, 2) AS SIMPLES_E_BASE,
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 44, 1) AS SIMPLES_F, 
	DBO.FN_GETFISCALTAX_CF(CFE.ID_LOJA_CF_SAT, CFE.CODIGO_FILIAL, 44, 2) AS SIMPLES_F_BASE,
	FILIAIS.COD_FILIAL, 
	CFE.CODIGO_FILIAL AS CODIGO_FILIAL, --
	B.DESCRICAO AS DESCRICAO_SERIE, 
	CFE.NOTA_CANCELADA, 
	DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT, RTRIM(CFE.OBS_INTERESSE_FISCO)) + '--' AS OBS_INTERESSE_FISCO,
	--CONVERT(varchar(5000), CFE.OBS_INTERESSE_FISCO) + '--' + CONVERT(varchar(5000), CFE.OBS) AS OBS_INTERESSE_FISCO,
	DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT, RTRIM(CFE.INFORMACAO_COMPLEMENTAR)) as INFORMACAO_COMPLEMENTAR, 
	CFE.DATA_CONTINGENCIA,											
	CFE.JUSTIFICATIVA_CONTINGENCIA,						
	(	SELECT TOP 1 LCF_LX_MUNICIPIO.COD_MUNICIPIO_IBGE 
		FROM LCF_LX_MUNICIPIO (NOLOCK) 
		INNER JOIN LCF_LX_UF U (NOLOCK)	ON U.ID_UF = LCF_LX_MUNICIPIO.ID_UF
		WHERE U.UF = CLIENTES_VAREJO.UF 
		AND DESC_MUNICIPIO = DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT, CLIENTES_VAREJO.CIDADE)) AS COD_MUNICIPIO_IBGE, 

	CONVERT(VARCHAR(24),CFE.DATA_HORA_EMISSAO,127)+'-0'+convert(char(1),CFE.UTC_EMISSAO)+':00'	AS UTC_EMISSAO,
	CONVERT(VARCHAR(24),CFE.DATA_HORA_SAIDA,127)+'-0'+convert(char(1),CFE.UTC_DATA_SAIDA)+':00' AS UTC_DATA_SAIDA, 
	LCF_LX_PAIS.COD_PAIS_BC,
	CFE.LANCAMENTO_CAIXA,
	CFE.TERMINAL,
	CONVERT(CHAR(38), CFE.GUID_VENDA_SAT) AS GUID_VENDA_SAT,
	CFE.GUID_VENDA_SAT AS GUID_VENDA, --#10#
	CFE.ID_LOJA_CF_SAT,
	CFE.ID_EQUIPAMENTO --#8#
FROM 
	LOJA_CF_SAT CFE (NOLOCK) 
	INNER JOIN SERIES_NF B (NOLOCK) ON CFE.SERIE_NF = B.SERIE_NF 
	LEFT JOIN LOJAS_VAREJO C (NOLOCK) ON CFE.CODIGO_FILIAL = C.CODIGO_FILIAL 
	LEFT JOIN CLIENTES_VAREJO (NOLOCK) ON CFE.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE 
	LEFT JOIN CADASTRO_CLI_FOR EMITENTE (NOLOCK) ON C.FILIAL = EMITENTE.NOME_CLIFOR
	INNER JOIN FILIAIS (NOLOCK) ON C.FILIAL = FILIAIS.FILIAL
	LEFT JOIN CTB_ESPECIE_SERIE (NOLOCK) ON B.ESPECIE_SERIE = CTB_ESPECIE_SERIE.ESPECIE_SERIE 
	LEFT JOIN LCF_LX_PAIS (NOLOCK) ON CLIENTES_VAREJO.PAIS = LCF_LX_PAIS.DESC_PAIS
	LEFT JOIN LOJA_CF_SAT_XML ON CFE.CODIGO_FILIAL = LOJA_CF_SAT_XML.CODIGO_FILIAL AND CFE.ID_LOJA_CF_SAT = LOJA_CF_SAT_XML.ID_LOJA_CF_SAT 
	INNER JOIN LOJA_VENDA_PGTO (NOLOCK) ON CFE.CODIGO_FILIAL = LOJA_VENDA_PGTO.CODIGO_FILIAL AND CFE.LANCAMENTO_CAIXA = LOJA_VENDA_PGTO.LANCAMENTO_CAIXA
		AND CFE.TERMINAL = LOJA_VENDA_PGTO.TERMINAL AND CFE.EMISSAO = LOJA_VENDA_PGTO.DATA
	INNER JOIN LOJA_VENDA (NOLOCK) ON LOJA_VENDA_PGTO.CODIGO_FILIAL = LOJA_VENDA.CODIGO_FILIAL AND LOJA_VENDA_PGTO.LANCAMENTO_CAIXA = LOJA_VENDA.LANCAMENTO_CAIXA
		AND LOJA_VENDA_PGTO.TERMINAL = LOJA_VENDA.TERMINAL AND LOJA_VENDA_PGTO.DATA = LOJA_VENDA.DATA_VENDA
