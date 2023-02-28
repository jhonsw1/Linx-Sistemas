CREATE VIEW [dbo].[W_IMPRESSAO_NFE_ITENS]
AS
  -- SUSTSP-1526  - Fábio Cunha / Eder / Wendel - #25# - 15/10/2020 - Tratamento para trazer valor maior que 0 de FCP.
  -- SUSTSP-731   - Wendel Crespigio - #24# - Correção para gerar o frete quando há mais de uma quantidade do mesmo item.
  -- MODASP-10427 - André Artuzo	 - #23# - Correção para gerar o frete quando há mais de uma quantidade do mesmo item.
  -- ModaSP-9775 -  Wesley Batista   - #22# - Ajuste para quando a informação estiver incorreta como NULL não quebrar o envio na DLL
  -- ModaSP-5769 -  Edson Filenti	 - #21# - Ajuste no ICMS_ST_BASE da Loja. Imposto (12) não considerado no cálculo.
  -- MODASP-3705 -  Fábio Santos		 - #20# - 20/08/2019 -  inclusão do imposto ICMS-DESONERADO
  -- MODASP-2351 -  Diego Moreno		 - #19# - 30/05/2019 - Melhoria referente ao imposto ICMS Substituto.
  -- 25/03/2019 -   Diego Moreno		 - #18# - SEM DM - Passou a considerar o imposto 86.
  -- 02/01/2019 -   Giedson Silva		 - #17# - SEM DM    - Inclusão do campo SUB_ITEM_SPED.
  -- 26/06/2018 -   Diego Moreno		 - #16# ID 80414    - NOTA TECNICA 2016.002 Versão 1.60.
  -- DM 69992   -   Wendel Crespigio e Fillipi Ramos #15# (29/03/2018) - Tratamento para quando código de barras do produto for TIPO_COD_BAR <> 1.
  -- DM 69094   -   Wendel Crespigio #14# (29/03/2018) - Tratamento pata getin nfce e nfe.
  -- DM 64234	-   Diego Moreno - #13# - (20/09/2017) - Adequacao NFE 4.00. Melhoria para atender ao layout 4.0 - ICMS 60.
  -- 14/02/2018   - DIEGO MORENO - #12# - Inclusão do IPI-E + ICMS_STA + ICMS_STAR nos itens
  -- DM 58430/59147 - 30/11/2017 - Diego Moreno - #11# DM  - Adequacao NFE 4.00. Melhoria no tratamento para os impostos 42 e 76.
  -- DM 1145 - Wendel Crespigio - #10# - Melhoria de performance - Nova função para busca de código de barras EAN (FX_GTIN_BARCODE_SEEK)
  -- DM 2050 - Edson Filenti - #9# - (08/03/2016) - Referente a TP10769689 onde forçar a criação das tags. Para validação forçar aliquota PART_ICMS_DEST_ALIQUOTA qdo a zerada.
  -- TP10769689 - Joao Gonzales - #8# - (24/11/2015) - Inclusão dos campos para atender a NT2015003
  -- TP10769689 - Gilvano.Santos - #7# - (18/11/2015) - Adequação NT 2015.003 - Inclusão do codigo CEST
  -- Sem TP banco online - Gerson.Prado - #6# - (21/09/2015) - Adequação na chamada da function FX_LOCALIZA_CODIGO_BARRA, Adequação Banco online ERP e LinxPOS
  -- TP9074062 - JORGE.DAMASCO - #5# - (09/07/2015) - Adequação na emissão da Nota de Aupração de IPI (Nota Fiscal - Movimento Diário):
  --													a) a natureza da operação: “Uso interno”;
  --													b) o destinatário: “Resumo do dia”;
  --													c) o Código Fiscal de Operações ou Prestações (CFOP): 5.949;
  --													d) o Código de Situação Tributária (CST): 090 - Outras;
  --													e) a discriminação do produto e a quantidade total vendida no dia;
  --													f) a classificação fiscal do produto;
  --													g) o valor total do produto e o valor total da nota;
  --													h) a alíquota e o valor do IPI; e
  --													i) a declaração, no campo “Informações Complementares”: “Nota fiscal emitida exclusivamente para uso interno”.
  -- Sem TP    - João Gonzales - #4# - (05/05/2015) - Tratamento para possiveis erros de caracteres especiais.
  -- TP7602726 - JORGE.DAMASCO - #3# - (16/01/2015) - LEI 12741/2012 - ALTERAÇÃO NA LEI PARA SEPARAÇÃO DOS IMPOSTOS. RETIRADA DOS DELIMITADORES DO CAMPO OBS
  -- 20/09/2013 - Gilvano Santos - #2# - Replicação da TP6390180 no ambiente de Loja (Adicionado os campos NUMERO_PROCESSO_ISS e INDICADOR_INCENTIVO_ISS para atender layout da NF-e 3.10).
  -- 20/09/2013 - Gilvano Santos - #1# - Adequação de estrutura entre ERP e Loja PARA ATENDER DEMANDA DA NFC-e (DLL)

  SELECT Isnull(CONVERT(VARCHAR(40), CADASTRO_CLI_FOR.NOME_CLIFOR), CLIENTES_VAREJO.CLIENTE_VAREJO)                                                           AS NOME_CLIFOR,
         LOJA_NOTA_FISCAL_ITEM.NF_NUMERO                                                                                                                      AS NF,
         LOJA_NOTA_FISCAL_ITEM.SERIE_NF,
         LOJAS_VAREJO.FILIAL                                                                                                                                  AS FILIAL,
         CASE Isnull(LOJA_NOTA_FISCAL_ITEM.ITEM_NFE, 0)
           WHEN 0 THEN CONVERT(SMALLINT, LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO)
           ELSE LOJA_NOTA_FISCAL_ITEM.ITEM_NFE
         END                                                                                                                                                  AS ITEM_NFE,
         LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO,
         LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO,
         [dbo].[Fx_replace_caracter_especial_nfe](0, LOJA_NOTA_FISCAL_ITEM.DESCRICAO_ITEM)                                                                    AS DESCRICAO_ITEM,--#4#
		 LOJA_NOTA_FISCAL_ITEM.QTDE_ITEM,
         LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM,
         --LOJA_NOTA_FISCAL_ITEM.TRIBUT_ICMS, 
         CASE
           WHEN CST_ICMS.ID_EXCECAO_IMPOSTO IS NULL
                AND ( ICMS.ID_IMPOSTO = 1
                       OR SIMPLES_F.ID_IMPOSTO = 44 ) THEN '00'
           WHEN LOJA_NOTA_FISCAL_ITEM.TRIBUT_ICMS = '90' THEN '90'
		   
		   WHEN CST_ICMS.TRIBUT_ICMS IS NULL THEN '' --#22#

		   ELSE CST_ICMS.TRIBUT_ICMS
		 END                                                                                                                    
			
                              AS TRIBUT_ICMS,-- #5#


         LOJA_NOTA_FISCAL_ITEM.TRIBUT_ORIGEM,
         LOJA_NOTA_FISCAL_ITEM.UNIDADE,
         LOJA_NOTA_FISCAL_ITEM.CLASSIF_FISCAL,
         LOJA_NOTA_FISCAL_ITEM.PORCENTAGEM_ITEM_RATEIO,
         LOJA_NOTA_FISCAL_ITEM.CODIGO_FISCAL_OPERACAO,
         LOJA_NOTA_FISCAL_ITEM.PESO,
         LOJA_NOTA_FISCAL_ITEM.CONTA_CONTABIL,
         LOJA_NOTA_FISCAL_ITEM.PRECO_UNITARIO,
         CASE
           WHEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM < 0 THEN 0
           ELSE LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM
         END                                                                                                                                                  AS DESCONTO_ITEM,
         LOJA_NOTA_FISCAL_ITEM.VALOR_ITEM,
         CONVERT(NUMERIC(13, 10), 0)                                                                                                                          AS PORC_COMISSAO_ITEM_REPRESENTANTE,
         CONVERT(NUMERIC(13, 10), 0)                                                                                                                          AS PORC_COMISSAO_ITEM_GERENTE,
         LOJA_NOTA_FISCAL_ITEM.INDICADOR_CFOP,
         LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO,
         TRIBUT_ICMS.DESCRICAO                                                                                                                                AS TRIBUT_ICMS_DESCRICAO,
         TRIBUT_ORIGEM.DESCRICAO                                                                                                                              AS TRIBUT_ORIGEM_DESCRICAO,
         CLASSIF_FISCAL.DESC_CLASSIFICACAO,
         CLASSIF_FISCAL.CLASSIF_REDUZIDA,
         CTB_LX_NATUREZAS_OPERACAO.DENOMINACAO                                                                                                                AS CODIGO_FISCAL_OPERACAO_DENOMINACAO,
         CONVERT(VARCHAR(40), '')                                                                                                                             AS CONTA_CONTABIL_DESCRICAO,
         CTB_LX_INDICADOR_CFOP.DESCRICAO_INDICADOR_CFOP,
         CASE WHEN ISNULL(FECP.VALOR_IMPOSTO,0) > 0 and Replace(LOJA_NOTA_FISCAL_ITEM.OBS_ITEM, Char(1), '') ='' then 'OBS_ITEM' else  Replace(LOJA_NOTA_FISCAL_ITEM.OBS_ITEM, Char(1), '') end AS OBS_ITEM,-- #3#
         CASE
           WHEN CST_IPI.ID_EXCECAO_IMPOSTO IS NULL
                AND IPI.ID_IMPOSTO = 2 THEN '50'
           ELSE ( CASE
                    WHEN IPI.ID_IMPOSTO IS NULL THEN NULL
                    ELSE CST_IPI.SITUACAO_TRIBUTARIA
                  END )
         END                                                                                                                                                  AS CST_IPI,
         CASE
           WHEN CST_PIS.ID_EXCECAO_IMPOSTO IS NULL
                AND PIS.ID_IMPOSTO = 5 THEN '01'
           ELSE ( CASE
                    WHEN PIS.ID_IMPOSTO IS NULL THEN NULL
                    ELSE CST_PIS.SITUACAO_TRIBUTARIA
                  END )
         END                                                                                                                                                  AS CST_PIS,
         CASE
           WHEN CST_COFINS.ID_EXCECAO_IMPOSTO IS NULL
                AND COFINS.ID_IMPOSTO = 6 THEN '01'
           ELSE ( CASE
                    WHEN COFINS.ID_IMPOSTO IS NULL THEN NULL
                    ELSE CST_COFINS.SITUACAO_TRIBUTARIA
                  END )
         END                                                                                                                                                  AS CST_COFINS,
         CST_ISS.SITUACAO_TRIBUTARIA                                                                                                                          AS CST_ISS,-- 2.00
         CST_ISS.NUMERO_PROCESSO                                                                                                                              AS NUMERO_PROCESSO_ISS,--#2#
         CST_ISS.INDICADOR_INCENTIVO                                                                                                                          AS INDICADOR_INCENTIVO_ISS,--#2#
         --ICMS_PREDBC.PORCENT_REDUCAO_DE_BASE as pREDBC,	-- Percentual de reducao da margem de calculo
         -- 25/03/2011
         CASE
           WHEN Isnull(CST_ICMS.TRIBUT_ICMS, '00') = '51' THEN ICMS_BST_PREDBC.PORCENT_REDUCAO_DE_BASE
           ELSE ICMS_PREDBC.PORCENT_REDUCAO_DE_BASE
         END                                                                                                                                                  AS pREDBC,
         NULL                                                                                                                                                 AS PREDBCST,-- Percentual de reducao de BC do ICMS ST

		 CASE
           WHEN ICMS_ST_MVAST.PORCENT_REDUCAO_DE_BASE < 0 THEN ICMS_ST_MVAST.PORCENT_REDUCAO_DE_BASE * -1
           ELSE ICMS_ST_MVAST.PORCENT_REDUCAO_DE_BASE
         END                                                                                                                                                  AS pMVAST,-- Percentual da margem de valor adicionado do ICMS ST
		 --#16#
		 
		 CASE
           WHEN ICMS_BST_PREDBCEFET.PORCENT_REDUCAO_DE_BASE < 0 THEN ICMS_BST_PREDBCEFET.PORCENT_REDUCAO_DE_BASE * -1
           ELSE ICMS_BST_PREDBCEFET.PORCENT_REDUCAO_DE_BASE
         END																																				  AS pRedBCEfet ,

		 ISNULL(ICMS_EFETIVO.BASE_IMPOSTO,0)																												  AS ICMS_EFET_BASE,
		 ISNULL(ICMS_EFETIVO.TAXA_IMPOSTO,0)																												  AS ICMS_EFET_ALIQUOTA,
		 ISNULL(ICMS_EFETIVO.VALOR_IMPOSTO,0)																												  AS ICMS_EFET_VALOR, 


		 --#16#


         CLASSIF_FISCAL.CLASSIF_REDUZIDA                                                                                                                      AS COD_SERVICO,
         --CASE WHEN ISNULL(CST_ICMS.TRIBUT_ICMS,'00') IN ('30','40','60') THEN 0 ELSE ISNULL(ICMS.VALOR_IMPOSTO,0) END AS ICMS,      
         --CASE WHEN ISNULL(CST_ICMS.TRIBUT_ICMS,'00') IN ('30','40','60') THEN 0 ELSE ISNULL(ICMS.TAXA_IMPOSTO, 0) END AS ICMS_ALIQUOTA,         
         --CASE WHEN ISNULL(CST_ICMS.TRIBUT_ICMS,'00') IN ('30','40','60') THEN 0 ELSE ISNULL(ICMS.BASE_IMPOSTO, 0) END AS ICMS_BASE,
         Isnull(ICMS.VALOR_IMPOSTO, 0)                                                                                                                        AS ICMS,
         Isnull(ICMS.TAXA_IMPOSTO, 0)                                                                                                                         AS ICMS_ALIQUOTA,
         Isnull(ICMS.BASE_IMPOSTO, 0)                                                                                                                         AS ICMS_BASE,
         Isnull(IPI.VALOR_IMPOSTO, 0)                                                                                                                         AS IPI,
         Isnull(IPI.TAXA_IMPOSTO, 0)                                                                                                                          AS IPI_ALIQUOTA,         
		 Isnull(IPI.BASE_IMPOSTO, 0)																														  AS IPI_BASE,
		  --#11#
         Isnull(IPI_E.valor_imposto, 0)																														  AS IPI_E,
         Isnull(IPI_E.taxa_imposto, 0)																														  AS IPI_E_ALIQUOTA,
         Isnull(IPI_E.base_imposto, 0)																														  AS IPI_E_BASE,
         Isnull(ICMS_STA.valor_imposto, 0)																													  AS ICMS_STA,
         Isnull(ICMS_STA.taxa_imposto, 0)																													  AS ICMS_STA_ALIQUOTA,
         Isnull(ICMS_STA.base_imposto, 0)																													  AS ICMS_STA_BASE,
         Isnull(ICMS_STAR.valor_imposto, 0)																													  AS ICMS_STAR,
         Isnull(ICMS_STAR.taxa_imposto, 0)																													  AS ICMS_STAR_ALIQUOTA,
         Isnull(ICMS_STAR.base_imposto, 0)																													  AS ICMS_STAR_BASE,
		 Isnull(FECP_STA.valor_imposto, 0)																													  AS FECP_STA,
         Isnull(FECP_STA.taxa_imposto, 0)																													  AS FECP_STA_ALIQUOTA,
         Isnull(FECP_STA.base_imposto, 0)																													  AS FECP_STA_BASE,
         Isnull(FECP_STAR.valor_imposto, 0)																													  AS FECP_STAR,
         Isnull(FECP_STAR.taxa_imposto, 0)																													  AS FECP_STAR_ALIQUOTA,
         Isnull(FECP_STAR.base_imposto, 0)																													  AS FECP_STAR_BASE,
		 --#11#
		 /*#19# - Início*/
		 Isnull(ICMS_SUBSTITUTO.valor_imposto, 0)                                      AS ICMS_SUBSTITUTO,
         Isnull(ICMS_SUBSTITUTO.taxa_imposto, 0)                                       AS ICMS_SUBSTITUTO_ALIQUOTA,
         Isnull(ICMS_SUBSTITUTO.base_imposto, 0)                                       AS ICMS_SUBSTITUTO_BASE,
		 /*#19# - Fim*/
         Isnull(IRRF.VALOR_IMPOSTO, 0)                                                                                                                        AS IRRF,
         Isnull(IRRF.TAXA_IMPOSTO, 0)                                                                                                                         AS IRRF_ALIQUOTA,
         Isnull(IRRF.BASE_IMPOSTO, 0)                                                                                                                         AS IRRF_BASE,
         Isnull(INSS.VALOR_IMPOSTO, 0)                                                                                                                        AS INSS,
         Isnull(INSS.TAXA_IMPOSTO, 0)                                                                                                                         AS INSS_ALIQUOTA,
         Isnull(INSS.BASE_IMPOSTO, 0)                                                                                                                         AS INSS_BASE,
         Isnull(PIS.VALOR_IMPOSTO, 0)                                                                                                                         AS PIS,
         Isnull(PIS.TAXA_IMPOSTO, 0)                                                                                                                          AS PIS_ALIQUOTA,
         Isnull(PIS.BASE_IMPOSTO, 0)                                                                                                                          AS PIS_BASE,
         Isnull(COFINS.VALOR_IMPOSTO, 0)                                                                                                                      AS COFINS,
         Isnull(COFINS.TAXA_IMPOSTO, 0)                                                                                                                       AS COFINS_ALIQUOTA,
         Isnull(COFINS.BASE_IMPOSTO, 0)                                                                                                                       AS COFINS_BASE,
         Isnull(IMPORT.VALOR_IMPOSTO, 0)                                                                                                                      AS I_IMPORT,
         Isnull(IMPORT.TAXA_IMPOSTO, 0)                                                                                                                       AS I_IMPORT_ALIQUOTA,
         Isnull(IMPORT.BASE_IMPOSTO, 0)                                                                                                                       AS I_IMPORT_BASE,
         Isnull(IVA.VALOR_IMPOSTO, 0)                                                                                                                         AS IVA,
         Isnull(IVA.TAXA_IMPOSTO, 0)                                                                                                                          AS IVA_ALIQUOTA,
         Isnull(IVA.BASE_IMPOSTO, 0)                                                                                                                          AS IVA_BASE,
         Isnull(RECARGO.VALOR_IMPOSTO, 0)                                                                                                                     AS RECARGO,
         Isnull(RECARGO.TAXA_IMPOSTO, 0)                                                                                                                      AS RECARGO_ALIQUOTA,
         Isnull(RECARGO.BASE_IMPOSTO, 0)                                                                                                                      AS RECARGO_BASE,
         Isnull(IRPF.VALOR_IMPOSTO, 0)                                                                                                                        AS IRPF,
         Isnull(IRPF.TAXA_IMPOSTO, 0)                                                                                                                         AS IRPF_ALIQUOTA,
         Isnull(IRPF.BASE_IMPOSTO, 0)                                                                                                                         AS IRPF_BASE,
         Isnull(DICMS.VALOR_IMPOSTO, 0)                                                                                                                       AS DICMS,
         Isnull(DICMS.TAXA_IMPOSTO, 0)                                                                                                                        AS DICMS_ALIQUOTA,
         Isnull(DICMS.BASE_IMPOSTO, 0)                                                                                                                        AS DICMS_BASE,
         
		 --#21# ICMS ST - Impostos 12, 60 e 63
         Isnull(icms_st.valor_imposto, 0) + Isnull(icms_snst.valor_imposto, 0) + Isnull(icms_stc.valor_imposto, 0)/*#21*/									  AS ICMS_ST, 
         Isnull(icms_st.taxa_imposto, 0) + Isnull(icms_snst.taxa_imposto, 0)   + Isnull(icms_stc.taxa_imposto, 0)/*#21*/ 									  AS ICMS_ST_ALIQUOTA, 
         Isnull(icms_st.base_imposto, 0) + Isnull(icms_snst.base_imposto, 0)   + Isnull(icms_stc.base_imposto, 0)/*#21*/ 									  AS ICMS_ST_BASE, 

         Isnull(ICMS_STR.VALOR_IMPOSTO, 0)                                                                                                                    AS ICMS_STR,
         Isnull(ICMS_STR.TAXA_IMPOSTO, 0)                                                                                                                     AS ICMS_STR_ALIQUOTA,
         Isnull(ICMS_STR.BASE_IMPOSTO, 0)                                                                                                                     AS ICMS_STR_BASE,
         Isnull(ISS.VALOR_IMPOSTO, 0)                                                                                                                         AS ISS,
         Isnull(ISS.TAXA_IMPOSTO, 0)                                                                                                                          AS ISS_ALIQUOTA,
         Isnull(ISS.BASE_IMPOSTO, 0)                                                                                                                          AS ISS_BASE,
         Isnull(IVA_IC.VALOR_IMPOSTO, 0)                                                                                                                      AS IVA_IC,
         Isnull(IVA_IC.TAXA_IMPOSTO, 0)                                                                                                                       AS IVA_IC_ALIQUOTA,
         Isnull(IVA_IC.BASE_IMPOSTO, 0)                                                                                                                       AS IVA_IC_BASE,
         Isnull(PC_CSL.VALOR_IMPOSTO, 0)                                                                                                                      AS PC_CSL,
         Isnull(PC_CSL.TAXA_IMPOSTO, 0)                                                                                                                       AS PC_CSL_ALIQUOTA,
         Isnull(PC_CSL.BASE_IMPOSTO, 0)                                                                                                                       AS PC_CSL_BASE,
         Isnull(PIS_R.VALOR_IMPOSTO, 0)                                                                                                                       AS PIS_R,
         Isnull(PIS_R.TAXA_IMPOSTO, 0)                                                                                                                        AS PIS_R_ALIQUOTA,
         Isnull(PIS_R.BASE_IMPOSTO, 0)                                                                                                                        AS PIS_R_BASE,
         Isnull(COFINS_R.VALOR_IMPOSTO, 0)                                                                                                                    AS COFINS_R,
         Isnull(COFINS_R.TAXA_IMPOSTO, 0)                                                                                                                     AS COFINS_R_ALIQUOTA,
         Isnull(COFINS_R.BASE_IMPOSTO, 0)                                                                                                                     AS COFINS_R_BASE,
         Isnull(CSLL_R.VALOR_IMPOSTO, 0)                                                                                                                      AS CSLL_R,
         Isnull(CSLL_R.TAXA_IMPOSTO, 0)                                                                                                                       AS CSLL_R_ALIQUOTA,
         Isnull(CSLL_R.BASE_IMPOSTO, 0)                                                                                                                       AS CSLL_R_BASE,
         Isnull(IRRF_R.VALOR_IMPOSTO, 0)                                                                                                                      AS IRRF_R,
         Isnull(IRRF_R.TAXA_IMPOSTO, 0)                                                                                                                       AS IRRF_R_ALIQUOTA,
         Isnull(IRRF_R.BASE_IMPOSTO, 0)                                                                                                                       AS IRRF_R_BASE,
         Isnull(INSS_R.VALOR_IMPOSTO, 0)                                                                                                                      AS INSS_R,
         Isnull(INSS_R.TAXA_IMPOSTO, 0)                                                                                                                       AS INSS_R_ALIQUOTA,
         Isnull(INSS_R.BASE_IMPOSTO, 0)                                                                                                                       AS INSS_R_BASE,
         Isnull(ISS_R.VALOR_IMPOSTO, 0)                                                                                                                       AS ISS_R,
         Isnull(ISS_R.TAXA_IMPOSTO, 0)                                                                                                                        AS ISS_R_ALIQUOTA,
         Isnull(ISS_R.BASE_IMPOSTO, 0)                                                                                                                        AS ISS_R_BASE,
         Isnull(PIS_S.VALOR_IMPOSTO, 0)                                                                                                                       AS PIS_S,
         Isnull(PIS_S.TAXA_IMPOSTO, 0)                                                                                                                        AS PIS_S_ALIQUOTA,
         Isnull(PIS_S.BASE_IMPOSTO, 0)                                                                                                                        AS PIS_S_BASE,
         Isnull(COFINS_S.VALOR_IMPOSTO, 0)                                                                                                                    AS COFINS_S,
         Isnull(COFINS_S.TAXA_IMPOSTO, 0)                                                                                                                     AS COFINS_S_ALIQUOTA,
         Isnull(COFINS_S.BASE_IMPOSTO, 0)                                                                                                                     AS COFINS_S_BASE,
         Isnull(CSLL_S.VALOR_IMPOSTO, 0)                                                                                                                      AS CSLL_S,
         Isnull(CSLL_S.TAXA_IMPOSTO, 0)                                                                                                                       AS CSLL_S_ALIQUOTA,
         Isnull(CSLL_S.BASE_IMPOSTO, 0)                                                                                                                       AS CSLL_S_BASE,
         Isnull(RTEIVA.VALOR_IMPOSTO, 0)                                                                                                                      AS RTEIVA,
         Isnull(RTEIVA.TAXA_IMPOSTO, 0)                                                                                                                       AS RTEIVA_ALIQUOTA,
         Isnull(RTEIVA.BASE_IMPOSTO, 0)                                                                                                                       AS RTEIVA_BASE,
         Isnull(RTEIVA_R.VALOR_IMPOSTO, 0)                                                                                                                    AS RTEIVA_R,
         Isnull(RTEIVA_R.TAXA_IMPOSTO, 0)                                                                                                                     AS RTEIVA_R_ALIQUOTA,
         Isnull(RTEIVA_R.BASE_IMPOSTO, 0)                                                                                                                     AS RTEIVA_R_BASE,
         Isnull(ICA.VALOR_IMPOSTO, 0)                                                                                                                         AS ICA,
         Isnull(ICA.TAXA_IMPOSTO, 0)                                                                                                                          AS ICA_ALIQUOTA,
         Isnull(ICA.BASE_IMPOSTO, 0)                                                                                                                          AS ICA_BASE,
         Isnull(RTEICA.VALOR_IMPOSTO, 0)                                                                                                                      AS RTEICA,
         Isnull(RTEICA.TAXA_IMPOSTO, 0)                                                                                                                       AS RTEICA_ALIQUOTA,
         Isnull(RTEICA.BASE_IMPOSTO, 0)                                                                                                                       AS RTEICA_BASE,
         Isnull(RTEFTE.VALOR_IMPOSTO, 0)                                                                                                                      AS RTEFTE,
         Isnull(RTEFTE.TAXA_IMPOSTO, 0)                                                                                                                       AS RTEFTE_ALIQUOTA,
         Isnull(RTEFTE.BASE_IMPOSTO, 0)                                                                                                                       AS RTEFTE_BASE,
         Isnull(RTEFTE_R.VALOR_IMPOSTO, 0)                                                                                                                    AS RTEFTE_R,
         Isnull(RTEFTE_R.TAXA_IMPOSTO, 0)                                                                                                                     AS RTEFTE_R_ALIQUOTA,
         Isnull(RTEFTE_R.BASE_IMPOSTO, 0)                                                                                                                     AS RTEFTE_R_BASE,
         Isnull(SIMPLES_F.VALOR_IMPOSTO, 0)                                                                                                                   AS SIMPLES_F,
         Isnull(SIMPLES_F.TAXA_IMPOSTO, 0)                                                                                                                    AS SIMPLES_F_ALIQUOTA,
         Isnull(SIMPLES_F.BASE_IMPOSTO, 0)                                                                                                                    AS SIMPLES_F_BASE,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                           AS CP_INSS,--#1#	
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                           AS CP_INSS_ALIQUOTA,--#1# 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                           AS CP_INSS_BASE,--#1#
         ( LOJA_NOTA_FISCAL_ITEM.VALOR_DESCONTOS
           + Isnull(ICMS_ZF.VALOR_IMPOSTO, 0)
           + Isnull(PIS_ZF.VALOR_IMPOSTO, 0)
           + Isnull(COFINS_ZF.VALOR_IMPOSTO, 0) )                                                                                                             AS VALOR_DESCONTOS,
         CASE
           WHEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM < 0 THEN 0
           ELSE Isnull(LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM * LOJA_NOTA_FISCAL_ITEM.QTDE_ITEM, 0)
         END                                                                                                                                                  AS DESCONTO_TOTAL_ITEM,
         Isnull(LOJA_NOTA_FISCAL_ITEM.PRECO_UNITARIO, 0)
         + CASE WHEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM < 0 THEN 0 ELSE Isnull(LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM, 0) END                                   AS VALOR_UNITARIO_BRUTO,
         Isnull(LOJA_NOTA_FISCAL_ITEM.VALOR_ITEM, 0)
         + CASE WHEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM < 0 THEN 0 ELSE Isnull(LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM * LOJA_NOTA_FISCAL_ITEM.QTDE_ITEM, 0) END AS VALOR_ITEM_BRUTO,
         Isnull(LOJA_NOTA_FISCAL_ITEM.VALOR_RATEIO_FRETE , 0)                                                                AS FRETE, --#23# #24#
         Isnull(LOJA_NOTA_FISCAL_ITEM.VALOR_RATEIO_SEGURO, 0)                                                                                                 AS SEGURO,
         LOJA_NOTA_FISCAL_ITEM.VALOR_ENCARGOS                                                                                                                 AS ENCARGO,-- (2.0)
         CASE
           WHEN LOJA_NOTA_FISCAL_ITEM.NAO_SOMA_VALOR = 0 THEN '1'
           ELSE '0'
         END                                                                                                                                                  AS indTot,
         Cast(NULL AS VARCHAR(12))                                                                                                                            AS PEDIDO_COMPRA,--(2.0) NÚMERO DO PEDIDO DE COMPRA    --- null AS PEDIDO_COMPRA
         NULL                                                                                                                                                 AS ITEM_PEDIDO_COMPRA,--(2.0) ITEM DO PEDIDO DE COMPRA
         CASE
           WHEN Isnull(LOJA_NOTA_FISCAL_ITEM.OBS_ITEM, '') = '' THEN NULL
           ELSE Replace(LOJA_NOTA_FISCAL_ITEM.OBS_ITEM, Char(1), '')
         END                                                                                                                                                  AS INFORMACAO_ADICIONAL_PROD,-- #3#	
         CONVERT(NUMERIC(15, 2), 0)                                                                                                                           AS VDESPADU,
         Isnull(CST_ICMS.CODIGO_ENQUADRAMENTO, 999)                                                                                                           AS CODIGO_ENQUADRAMENTO,-- (2.0) IPI BEBIDAS
         CST_ICMS.CODIGO_CLASSE_TRIBUTACAO,-- (2.0) IPI BEBIDAS	 
         Isnull(ICMS_SN.VALOR_IMPOSTO, 0)                                                                                                                     AS ICMS_SN,
         Isnull(ICMS_SN.TAXA_IMPOSTO, 0)                                                                                                                      AS ICMS_SN_ALIQUOTA,
         Isnull(ICMS_SN.BASE_IMPOSTO, 0)                                                                                                                      AS ICMS_SN_BASE,
         Isnull(PIS_SN.VALOR_IMPOSTO, 0)                                                                                                                      AS PIS_SN,
         Isnull(PIS_SN.TAXA_IMPOSTO, 0)                                                                                                                       AS PIS_SN_ALIQUOTA,
         Isnull(PIS_SN.BASE_IMPOSTO, 0)                                                                                                                       AS PIS_SN_BASE,
         Isnull(COFINS_SN.VALOR_IMPOSTO, 0)                                                                                                                   AS COFINS_SN,
         Isnull(COFINS_SN.TAXA_IMPOSTO, 0)                                                                                                                    AS COFINS_SN_ALIQUOTA,
         Isnull(COFINS_SN.BASE_IMPOSTO, 0)                                                                                                                    AS COFINS_SN_BASE,
         ICMS_SN.ID_IMPOSTO                                                                                                                                   AS ID_IMPOSTO_ICMS_SN,
         PIS_SN.ID_IMPOSTO                                                                                                                                    AS ID_IMPOSTO_PIS_SN,
         COFINS_SN.ID_IMPOSTO                                                                                                                                 AS ID_IMPOSTO_COFINS_SN,
         Isnull(ICMS_BST.VALOR_IMPOSTO, 0)                                                                                                                    AS ICMS_BST,
         Isnull(ICMS_BST.TAXA_IMPOSTO, 0)                                                                                                                     AS ICMS_BST_ALIQUOTA,
         Isnull(ICMS_BST.BASE_IMPOSTO, 0)                                                                                                                     AS ICMS_BST_BASE,

		 --#11# - Início #14#
	CASE WHEN ESPECIE_SERIE.NUMERO_MODELO_FISCAL IN ('55') THEN --#15#

	CASE WHEN Isnull(DBO.Fx_parametro_loja('VERSAO_LAYOUT_XML_NFE', LOJA_NOTA_FISCAL.CODIGO_FILIAL),'3.10') = '4.00' and ESPECIE_SERIE.NUMERO_MODELO_FISCAL in ('55')
	THEN
		CASE
        	WHEN Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0') <> '2' THEN 'SEM GTIN'
			when	
			ISNULL(DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
			,'SEM GTIN') = '' then 'SEM GTIN' 
			else ISNULL(DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
			,'SEM GTIN') END		                                                                                
		ELSE
		  CASE
           WHEN Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0') <> '2' THEN ''
		   ELSE DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
         END   
	END 
	Else
             CASE WHEN Isnull(DBO.Fx_parametro_loja('VERSAO_LAYOUT_JSON_NFCE', LOJA_NOTA_FISCAL.CODIGO_FILIAL),'3.10') = '4.00' and ESPECIE_SERIE.NUMERO_MODELO_FISCAL in ('65')
             THEN
                    CASE
                    WHEN Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0') <> '2' THEN 'SEM GTIN'
                           when   
                           ISNULL(DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
                           ,'SEM GTIN') = '' then 'SEM GTIN' 
                           else ISNULL(DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
                           ,'SEM GTIN') END                                                                                           
                    ELSE
                    CASE
                       WHEN Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0') <> '2' THEN ''
                       ELSE DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
                    END   
             END 
             end   EAN,
	 -- fim #14#
     --    CASE
     --      WHEN Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0') <> '2' THEN ''
		   --ELSE DBO.FX_GTIN_BARCODE_SEEK(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'',LOJA_NOTA_FISCAL_ITEM.REFERENCIA,LOJA_NOTA_FISCAL_ITEM.REFERENCIA_ITEM)
     --      --#WENDEL#ELSE DBO.Fx_localiza_codigo_barra(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'),'')
     --      -- #6#ELSE DBO.Fx_localiza_codigo_barra(LOJA_NOTA_FISCAL_ITEM.CODIGO_ITEM, Isnull(DBO.Fx_parametro_loja('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'))
     --    END                                                                                                                                                  EAN,
         0                                                                                                                                                    AS IMPORTACAO,
         'P'                                                                                                                                                  AS COD_TABELA_FILHA,-- Perguntar Denys se a loja tem????
         '.F.'                                                                                                                                                AS DANFE_NFE_IMPORTACAO_CALC,
         -- NT 2011/004
         Isnull(ICMS_ZF.VALOR_IMPOSTO, 0)                                                                                                                     AS ICMS_ZF,
         Isnull(ICMS_ZF.TAXA_IMPOSTO, 0)                                                                                                                      AS ICMS_ZF_ALIQUOTA,
         Isnull(ICMS_ZF.BASE_IMPOSTO, 0)                                                                                                                      AS ICMS_ZF_BASE,
         Isnull(PIS_ZF.VALOR_IMPOSTO, 0)                                                                                                                      AS PIS_ZF,
         Isnull(PIS_ZF.TAXA_IMPOSTO, 0)                                                                                                                       AS PIS_ZF_ALIQUOTA,
         Isnull(PIS_ZF.BASE_IMPOSTO, 0)                                                                                                                       AS PIS_ZF_BASE,
         Isnull(COFINS_ZF.VALOR_IMPOSTO, 0)                                                                                                                   AS COFINS_ZF,
         Isnull(COFINS_ZF.TAXA_IMPOSTO, 0)                                                                                                                    AS COFINS_ZF_ALIQUOTA,
         Isnull(COFINS_ZF.BASE_IMPOSTO, 0)                                                                                                                    AS COFINS_ZF_BASE,
         --#20# - Início		
         Isnull(icms_desonerado.valor_imposto, 0)																											  AS ICMS_DESONERADO,
         Isnull(icms_desonerado.taxa_imposto, 0)																											  AS ICMS_DESONERADO_ALIQUOTA,
         Isnull(icms_desonerado.base_imposto, 0)																											  AS ICMS_DESONERADO_BASE,
		 --#20# - Fim
		 CASE WHEN Isnull(icms_desonerado.valor_imposto, 0) > 0 THEN ISNULL(CST_ICMS_DESONERADO.SITUACAO_TRIBUTARIA,'9') ELSE ISNULL(CST_ICMS_ZF.SITUACAO_TRIBUTARIA,'' ) END  AS ST_MOT_DESONERACAO,
         Isnull(LOJA_NOTA_FISCAL_ITEM.VALOR_APROX_IMPOSTOS, 0)                                                                                                AS VALOR_IMPOSTO_ITEM,
         CONVERT(CHAR(36), LOJA_NOTA_FISCAL_ITEM.CODIGO_FCI)                                                                                                  AS CODIGO_FCI, --LOJA_NOTA_FISCAL_ITEM.CODIGO_FCI
		 TABELA_LX_CEST.CODIGO_CEST																															  AS CODIGO_CEST, --#7# 	 
		 Isnull(FECP_DEST.TAXA_IMPOSTO, 0)																													  AS FECP_DEST_ALIQUOTA, --#8#
		 Isnull(FECP_DEST.VALOR_IMPOSTO, 0)                                                                                                                   AS FECP_DEST_VALOR, --#8#
		 --#11#
		 Isnull(FECP_DEST.BASE_IMPOSTO, 0)                            AS FECP_DEST_BASE, 
		 --#11#
		 CASE WHEN Isnull(DICMS.TAXA_IMPOSTO, 0) > 0 THEN ( Isnull(DICMS.TAXA_IMPOSTO, 0) + Isnull(ICMS.TAXA_IMPOSTO, 0) ) ELSE 0 END 						  AS ICMS_DEST_ALIQUOTA, --#8#
		 
		 CASE WHEN Isnull(DICMS_DEST.TAXA_IMPOSTO, 0)  >  0   THEN DICMS_DEST.TAXA_IMPOSTO
		 ELSE 
		 (SELECT (FATOR_PARTILHA_DESTINO * 100) AS TAXA
				FROM UNIDADES_FEDERACAO_ICMS_PARTILHA A  with (nolock) WHERE  LOJA_NOTA_FISCAL.EMISSAO BETWEEN A.DATA_INICIO AND A.DATA_FIM ) 
		 END										                                                                                                          AS PART_ICMS_DEST_ALIQUOTA, --#8# #9#

		 Isnull(DICMS_DEST.VALOR_IMPOSTO, 0)                                                                                                                  AS DICMS_DEST_VALOR, --#8#
 		 Isnull(DICMS_ORIG.VALOR_IMPOSTO, 0)                                                                                                                  AS DICMS_ORIG_VALOR, --#8#

		 --#11#
		 ISNULL(CASE WHEN ISNULL(CST_ICMS.TRIBUT_ICMS, '00') IN ('00','10','20','30','51','70','90','201') THEN CASE WHEN ISNULL(FECP.BASE_IMPOSTO,0) > 0.01 THEN FECP.TAXA_IMPOSTO ELSE 0.00 END END,0) AS FECP_ALIQUOTA,  --#13#
		 CASE WHEN ISNULL(FECP.VALOR_IMPOSTO,0) > 0 THEN ISNULL(FECP.VALOR_IMPOSTO,0) ELSE 0 END  AS FECP_VALOR, --#25#
		 CASE WHEN ISNULL(FECP.BASE_IMPOSTO,0) > 0 THEN  ISNULL(FECP.BASE_IMPOSTO,0)  ELSE 0 END  AS FECP_BASE, --#25#
		 ISNULL(CASE WHEN ISNULL(CST_ICMS.TRIBUT_ICMS, '00') IN ('10','30','70','90','201','202','203','500','900') THEN FECP_ST.TAXA_IMPOSTO END,0) AS FECP_ST_ALIQUOTA,  --#13#
		 ISNULL(FECP_ST.VALOR_IMPOSTO,0) AS FECP_ST_VALOR,
		 ISNULL(FECP_ST.BASE_IMPOSTO,0)  AS FECP_ST_BASE,
		 --#11#

		 --ISNULL(CASE WHEN Isnull(CST_ICMS.TRIBUT_ICMS, '00') IN ('60') THEN FECP_ST.TAXA_IMPOSTO END,0) AS FECP_STR_ALIQUOTA,  --#13#
		 ISNULL(CASE WHEN Isnull(CST_ICMS.TRIBUT_ICMS, '00') IN ('10','30','70','90','201','202','203','500','900','60') THEN FECP_STR.TAXA_IMPOSTO END,0) AS FECP_STR_ALIQUOTA,  --#46# #52#
		 ISNULL(FECP_STR.VALOR_IMPOSTO,0) AS FECP_STR_VALOR,
		 ISNULL(FECP_STR.BASE_IMPOSTO,0)  AS FECP_STR_BASE,
		 ITEM_SPED.SUB_ITEM_SPED --#17#		
  FROM   LOJA_NOTA_FISCAL_ITEM  with (nolock)
         INNER JOIN LOJA_NOTA_FISCAL with (nolock)
                 ON LOJA_NOTA_FISCAL.CODIGO_FILIAL = LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL
                    AND LOJA_NOTA_FISCAL.NF_NUMERO = LOJA_NOTA_FISCAL_ITEM.NF_NUMERO
                    AND LOJA_NOTA_FISCAL.SERIE_NF = LOJA_NOTA_FISCAL_ITEM.SERIE_NF
         INNER JOIN LOJAS_VAREJO with (nolock)
                 ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = LOJAS_VAREJO.CODIGO_FILIAL
         LEFT JOIN CLIENTES_VAREJO with (nolock)
                ON LOJA_NOTA_FISCAL.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
         LEFT JOIN CADASTRO_CLI_FOR
                ON LOJA_NOTA_FISCAL.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR
         LEFT JOIN TRIBUT_ORIGEM with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.TRIBUT_ORIGEM = TRIBUT_ORIGEM.TRIBUT_ORIGEM
         LEFT JOIN TRIBUT_ICMS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.TRIBUT_ICMS = TRIBUT_ICMS.TRIBUT_ICMS
         LEFT JOIN CLASSIF_FISCAL with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CLASSIF_FISCAL = CLASSIF_FISCAL.CLASSIF_FISCAL
         LEFT JOIN CTB_LX_INDICADOR_CFOP with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.INDICADOR_CFOP = CTB_LX_INDICADOR_CFOP.INDICADOR_CFOP
         LEFT JOIN CTB_LX_NATUREZAS_OPERACAO with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FISCAL_OPERACAO = CTB_LX_NATUREZAS_OPERACAO.CODIGO_FISCAL_OPERACAO
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS.SUB_ITEM_TAMANHO
                   AND ICMS.ID_IMPOSTO = 1
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IPI with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IPI.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IPI.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IPI.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IPI.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IPI.SUB_ITEM_TAMANHO
                   AND IPI.ID_IMPOSTO = 2
		--#11#	
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IPI_E  with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IPI_E.CODIGO_FILIAL 
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IPI_E.NF_NUMERO 
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IPI_E.SERIE_NF 
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IPI_E.ITEM_IMPRESSAO 
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IPI_E.SUB_ITEM_TAMANHO 
                   AND IPI_E.ID_IMPOSTO = 52 
         --#11#

         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IRRF with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IRRF.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IRRF.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IRRF.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IRRF.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IRRF.SUB_ITEM_TAMANHO
                   AND IRRF.ID_IMPOSTO = 3
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO INSS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = INSS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = INSS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = INSS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = INSS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = INSS.SUB_ITEM_TAMANHO
                   AND INSS.ID_IMPOSTO = 4
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PIS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PIS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PIS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PIS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PIS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PIS.SUB_ITEM_TAMANHO
                   AND PIS.ID_IMPOSTO = 5
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO COFINS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = COFINS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = COFINS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = COFINS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = COFINS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = COFINS.SUB_ITEM_TAMANHO
                   AND COFINS.ID_IMPOSTO = 6
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IMPORT with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IMPORT.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IMPORT.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IMPORT.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IMPORT.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IMPORT.SUB_ITEM_TAMANHO
                   AND IMPORT.ID_IMPOSTO = 7
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IVA with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IVA.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IVA.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IVA.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IVA.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IVA.SUB_ITEM_TAMANHO
                   AND IVA.ID_IMPOSTO = 8
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RECARGO with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RECARGO.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RECARGO.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RECARGO.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RECARGO.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RECARGO.SUB_ITEM_TAMANHO
                   AND RECARGO.ID_IMPOSTO = 9
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IRPF with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IRPF.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IRPF.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IRPF.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IRPF.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IRPF.SUB_ITEM_TAMANHO
                   AND IRPF.ID_IMPOSTO = 10
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO DICMS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = DICMS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = DICMS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = DICMS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = DICMS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = DICMS.SUB_ITEM_TAMANHO
                   AND DICMS.ID_IMPOSTO = 11
		--#21# ICMS ST - Impostos 12, 60 e 63
				 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_ST with (nolock)
						ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_ST.CODIGO_FILIAL
						   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_ST.NF_NUMERO
						   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_ST.SERIE_NF
						   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_ST.ITEM_IMPRESSAO
						   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_ST.SUB_ITEM_TAMANHO
						   AND ICMS_ST.ID_IMPOSTO = 12																	--#21#
				 LEFT JOIN loja_nota_fiscal_imposto ICMS_SNST (nolock) 
						ON loja_nota_fiscal_item.codigo_filial = ICMS_SNST.codigo_filial 
						   AND loja_nota_fiscal_item.nf_numero = ICMS_SNST.nf_numero 
						   AND loja_nota_fiscal_item.serie_nf = ICMS_SNST.serie_nf 
						   AND loja_nota_fiscal_item.item_impressao = ICMS_SNST.item_impressao 
						   AND loja_nota_fiscal_item.sub_item_tamanho = ICMS_SNST.sub_item_tamanho 
						   AND ICMS_SNST.id_imposto = 60 and loja_nota_fiscal_item.tribut_icms in ('201','202','203')	--#21#
				 LEFT JOIN loja_nota_fiscal_imposto ICMS_STC (nolock) 
						ON loja_nota_fiscal_item.codigo_filial = ICMS_STC.codigo_filial 
						   AND loja_nota_fiscal_item.nf_numero = ICMS_STC.nf_numero 
						   AND loja_nota_fiscal_item.serie_nf = ICMS_STC.serie_nf 
						   AND loja_nota_fiscal_item.item_impressao = ICMS_STC.item_impressao 
						   AND loja_nota_fiscal_item.sub_item_tamanho = ICMS_STC.sub_item_tamanho 
						   AND ICMS_STC.id_imposto = 63 and loja_nota_fiscal_item.tribut_icms in ('10','30','70')		--#21#
				--#21#
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_STR with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_STR.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_STR.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_STR.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_STR.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_STR.SUB_ITEM_TAMANHO
                   AND ICMS_STR.ID_IMPOSTO = 13
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ISS with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ISS.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ISS.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ISS.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ISS.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ISS.SUB_ITEM_TAMANHO
                   AND ISS.ID_IMPOSTO = 14
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IVA_IC with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IVA_IC.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IVA_IC.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IVA_IC.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IVA_IC.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IVA_IC.SUB_ITEM_TAMANHO
                   AND IVA_IC.ID_IMPOSTO = 15
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PC_CSL with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PC_CSL.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PC_CSL.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PC_CSL.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PC_CSL.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PC_CSL.SUB_ITEM_TAMANHO
                   AND PC_CSL.ID_IMPOSTO = 16
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PIS_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PIS_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PIS_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PIS_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PIS_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PIS_R.SUB_ITEM_TAMANHO
                   AND PIS_R.ID_IMPOSTO = 17
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO COFINS_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = COFINS_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = COFINS_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = COFINS_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = COFINS_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = COFINS_R.SUB_ITEM_TAMANHO
                   AND COFINS_R.ID_IMPOSTO = 18
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO CSLL_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = CSLL_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = CSLL_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = CSLL_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = CSLL_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = CSLL_R.SUB_ITEM_TAMANHO
                   AND CSLL_R.ID_IMPOSTO = 19
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO IRRF_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = IRRF_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = IRRF_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = IRRF_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = IRRF_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = IRRF_R.SUB_ITEM_TAMANHO
                   AND IRRF_R.ID_IMPOSTO = 20
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO INSS_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = INSS_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = INSS_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = INSS_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = INSS_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = INSS_R.SUB_ITEM_TAMANHO
                   AND INSS_R.ID_IMPOSTO = 21
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ISS_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ISS_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ISS_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ISS_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ISS_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ISS_R.SUB_ITEM_TAMANHO
                   AND ISS_R.ID_IMPOSTO = 22
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PIS_S with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PIS_S.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PIS_S.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PIS_S.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PIS_S.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PIS_S.SUB_ITEM_TAMANHO
                   AND PIS_S.ID_IMPOSTO = 23
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO COFINS_S with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = COFINS_S.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = COFINS_S.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = COFINS_S.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = COFINS_S.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = COFINS_S.SUB_ITEM_TAMANHO
                   AND COFINS_S.ID_IMPOSTO = 24
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO CSLL_S with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = CSLL_S.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = CSLL_S.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = CSLL_S.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = CSLL_S.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = CSLL_S.SUB_ITEM_TAMANHO
                   AND CSLL_S.ID_IMPOSTO = 25
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RTEIVA with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RTEIVA.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RTEIVA.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RTEIVA.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RTEIVA.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RTEIVA.SUB_ITEM_TAMANHO
                   AND RTEIVA.ID_IMPOSTO = 30
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RTEIVA_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RTEIVA_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RTEIVA_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RTEIVA_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RTEIVA_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RTEIVA_R.SUB_ITEM_TAMANHO
                   AND RTEIVA_R.ID_IMPOSTO = 31
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICA with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICA.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICA.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICA.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICA.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICA.SUB_ITEM_TAMANHO
                   AND ICA.ID_IMPOSTO = 32
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RTEICA with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RTEICA.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RTEICA.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RTEICA.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RTEICA.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RTEICA.SUB_ITEM_TAMANHO
                   AND RTEICA.ID_IMPOSTO = 33
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RTEFTE with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RTEFTE.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RTEFTE.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RTEFTE.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RTEFTE.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RTEFTE.SUB_ITEM_TAMANHO
                   AND RTEFTE.ID_IMPOSTO = 34
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO RTEFTE_R with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = RTEFTE_R.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = RTEFTE_R.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = RTEFTE_R.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = RTEFTE_R.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = RTEFTE_R.SUB_ITEM_TAMANHO
                   AND RTEFTE_R.ID_IMPOSTO = 35
         LEFT JOIN CTB_EXCECAO_IMPOSTO CST_ICMS (NOLOCK)
                ON CST_ICMS.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_IPI with (nolock)
                ON CST_IPI.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND CST_IPI.ID_IMPOSTO = 2
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_PIS with (nolock)
                ON CST_PIS.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND CST_PIS.ID_IMPOSTO = 5
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_COFINS with (nolock)
                ON CST_COFINS.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND CST_COFINS.ID_IMPOSTO = 6
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_ISS with (nolock)
                ON CST_ISS.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND CST_ISS.ID_IMPOSTO IN ( 14, 22 )
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM ICMS_ST_MVAST
                ON ICMS_ST_MVAST.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND ( ICMS_ST_MVAST.ID_IMPOSTO = 12
                          OR ICMS_ST_MVAST.ID_IMPOSTO = 13 )
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM ICMS_PREDBC with (nolock)
                ON ICMS_PREDBC.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND ICMS_PREDBC.ID_IMPOSTO = 1
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_ZF with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_ZF.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_ZF.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_ZF.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_ZF.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_ZF.SUB_ITEM_TAMANHO
                   AND ICMS_ZF.ID_IMPOSTO = 36
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PIS_ZF with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PIS_ZF.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PIS_ZF.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PIS_ZF.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PIS_ZF.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PIS_ZF.SUB_ITEM_TAMANHO
                   AND PIS_ZF.ID_IMPOSTO = 37
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO COFINS_ZF with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = COFINS_ZF.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = COFINS_ZF.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = COFINS_ZF.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = COFINS_ZF.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = COFINS_ZF.SUB_ITEM_TAMANHO
                   AND COFINS_ZF.ID_IMPOSTO = 38
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO SIMPLES_F with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = SIMPLES_F.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = SIMPLES_F.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = SIMPLES_F.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = SIMPLES_F.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = SIMPLES_F.SUB_ITEM_TAMANHO
                   AND SIMPLES_F.ID_IMPOSTO = 44
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_SN with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_SN.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_SN.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_SN.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_SN.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_SN.SUB_ITEM_TAMANHO
                   AND ICMS_SN.ID_IMPOSTO = 55
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO PIS_SN with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = PIS_SN.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = PIS_SN.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = PIS_SN.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = PIS_SN.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = PIS_SN.SUB_ITEM_TAMANHO
                   AND PIS_SN.ID_IMPOSTO = 56
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO COFINS_SN with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = COFINS_SN.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = COFINS_SN.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = COFINS_SN.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = COFINS_SN.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = COFINS_SN.SUB_ITEM_TAMANHO
                   AND COFINS_SN.ID_IMPOSTO = 57
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_BST with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_BST.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_BST.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_BST.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_BST.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_BST.SUB_ITEM_TAMANHO
                   AND ICMS_BST.ID_IMPOSTO = 51
		 --#8#
         LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP_DEST with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP_DEST.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP_DEST.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP_DEST.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP_DEST.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP_DEST.SUB_ITEM_TAMANHO
                   AND FECP_DEST.ID_IMPOSTO = 70

		  LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO DICMS_ORIG with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = DICMS_ORIG.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = DICMS_ORIG.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = DICMS_ORIG.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = DICMS_ORIG.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = DICMS_ORIG.SUB_ITEM_TAMANHO
                   AND DICMS_ORIG.ID_IMPOSTO = 71

		  LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO DICMS_DEST with (nolock)
                ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = DICMS_DEST.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = DICMS_DEST.NF_NUMERO
                   AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = DICMS_DEST.SERIE_NF
                   AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = DICMS_DEST.ITEM_IMPRESSAO
                   AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = DICMS_DEST.SUB_ITEM_TAMANHO
                   AND DICMS_DEST.ID_IMPOSTO = 72
		 --#8#
		 --#11#
		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP.SUB_ITEM_TAMANHO
					AND FECP.ID_IMPOSTO = 42   
					
		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP_ST with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP_ST.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP_ST.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP_ST.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP_ST.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP_ST.SUB_ITEM_TAMANHO
					AND FECP_ST.ID_IMPOSTO = 76 					       
		

		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP_STR with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP_STR.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP_STR.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP_STR.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP_STR.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP_STR.SUB_ITEM_TAMANHO
					AND FECP_STR.ID_IMPOSTO = 77			
					
		LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_STAR with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_STAR.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_STAR.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_STAR.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_STAR.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_STAR.SUB_ITEM_TAMANHO
					AND ICMS_STAR.ID_IMPOSTO = 64	
	
		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_STA with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_STA.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_STA.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_STA.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_STA.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_STA.SUB_ITEM_TAMANHO
					AND ICMS_STA.ID_IMPOSTO = 65
					
		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP_STA with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP_STA.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP_STA.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP_STA.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP_STA.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP_STA.SUB_ITEM_TAMANHO
					AND FECP_STA.ID_IMPOSTO = 83	
					
		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO FECP_STAR with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = FECP_STAR.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = FECP_STAR.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = FECP_STAR.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = FECP_STAR.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = FECP_STAR.SUB_ITEM_TAMANHO
					AND FECP_STAR.ID_IMPOSTO = 84
		--#16# - Inicio
		LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_EFETIVO with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_EFETIVO.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_EFETIVO.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_EFETIVO.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_EFETIVO.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_EFETIVO.SUB_ITEM_TAMANHO
					AND ICMS_EFETIVO.ID_IMPOSTO = 85								
		--#16# - Fim
		--#20# - Início
         LEFT JOIN loja_nota_fiscal_imposto ICMS_desonerado (nolock) 
                ON loja_nota_fiscal_item.codigo_filial = icms_desonerado.codigo_filial 
                   AND loja_nota_fiscal_item.nf_numero = icms_desonerado.nf_numero 
                   AND loja_nota_fiscal_item.serie_nf = icms_desonerado.serie_nf 
                   AND loja_nota_fiscal_item.item_impressao = icms_desonerado.item_impressao 
                   AND loja_nota_fiscal_item.sub_item_tamanho = icms_desonerado.sub_item_tamanho 
                   AND icms_desonerado.id_imposto = 87
		--#20# - Fim
		----#18# - Inicio
		--	LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_SUBST with (nolock)
		--		ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_SUBST.CODIGO_FILIAL
		--			AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_SUBST.NF_NUMERO
		--			AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_SUBST.SERIE_NF
		--			AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_SUBST.ITEM_IMPRESSAO
		--			AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_SUBST.SUB_ITEM_TAMANHO
		--			AND ICMS_SUBST.ID_IMPOSTO = 86				
		----#18# - Fim
		--#19#  - Início  
  		 LEFT JOIN LOJA_NOTA_FISCAL_IMPOSTO ICMS_SUBSTITUTO with (nolock)
				ON LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = ICMS_SUBSTITUTO.CODIGO_FILIAL
					AND LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = ICMS_SUBSTITUTO.NF_NUMERO
					AND LOJA_NOTA_FISCAL_ITEM.SERIE_NF = ICMS_SUBSTITUTO.SERIE_NF
					AND LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = ICMS_SUBSTITUTO.ITEM_IMPRESSAO
					AND LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = ICMS_SUBSTITUTO.SUB_ITEM_TAMANHO
					AND ICMS_SUBSTITUTO.ID_IMPOSTO = 86 and LOJA_NOTA_FISCAL_ITEM.TRIBUT_ICMS IN ('60', '500') --#19#
	--#19# - Fim
	 --#11#
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM ICMS_BST_PREDBC with (nolock)
                ON ICMS_BST_PREDBC.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND ICMS_BST_PREDBC.ID_IMPOSTO = 51
		--#16# - Inicio
		LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM ICMS_BST_PREDBCEFET with (nolock)
                ON ICMS_BST_PREDBCEFET.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND ICMS_BST_PREDBCEFET.ID_IMPOSTO = 85
		--#16# - Fim
		--#17# - Início
		LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM ITEM_SPED with (nolock)
                ON ITEM_SPED.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND ITEM_SPED.ID_IMPOSTO = 1 AND ITEM_SPED.SUB_ITEM_SPED IS NOT NULL
		--#17# - Fim
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_ICMS_ZF with (nolock)
                ON CST_ICMS_ZF.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO
                   AND CST_ICMS_ZF.ID_IMPOSTO = 36 
		--#20#-INÍCIO
         LEFT JOIN CTB_EXCECAO_IMPOSTO_ITEM CST_ICMS_DESONERADO (NOLOCK) 
                ON CST_ICMS_DESONERADO.ID_EXCECAO_IMPOSTO = LOJA_NOTA_FISCAL_ITEM.ID_EXCECAO_IMPOSTO 
                   AND CST_ICMS_DESONERADO.ID_IMPOSTO = 87 
		--#20#-FIM
		 LEFT JOIN CEST_NCM LISTA_CEST_NCM with (nolock) ON LOJA_NOTA_FISCAL_ITEM.ID_CEST_NCM = LISTA_CEST_NCM.ID --#7#
         LEFT JOIN TABELA_LX_CEST with (nolock) ON LISTA_CEST_NCM.ID_CEST = TABELA_LX_CEST.ID --#7#
		 INNER JOIN SERIES_NF SERIES_NF with (nolock)
		 ON LOJA_NOTA_FISCAL.SERIE_NF = SERIES_NF.SERIE_NF
		 INNER JOIN CTB_ESPECIE_SERIE ESPECIE_SERIE with (nolock)
		 ON SERIES_NF.ESPECIE_SERIE = ESPECIE_SERIE.ESPECIE_SERIE
