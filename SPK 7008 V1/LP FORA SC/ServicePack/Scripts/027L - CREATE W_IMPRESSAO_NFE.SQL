CREATE VIEW [DBO].[W_IMPRESSAO_NFE]
AS
  -- PRODSHOP-6652 - EDER SILVA       - #85# - (21/06/2021) - Tratamento para calcular o vICMSUFDest em notas de troca 
  -- PRODSHOP-5704 - Fábio Cunha  	  - #84# - (08/04/2021) - Feito tratamento para quando o cliente fizer uma compra do exterior apresentar as TAGS <UFSaidaPais> e <xLocExporta> no XML da nota.
  -- POSSP-5157    - Gilvano Santos	  - #83# - (31/03/2021) - Nota Técnica 2020.006
  -- SUSTSP-1385   - Fábio Cunha      - #82# - (01/10/2020) - tratamento na para buscar o valor do "ICMS Interestadual para UF de Destino" quando for Nf-e de consumíveis.
  -- POSSP-3854    - Wesley Batista   - #81# - (18/08/2020) - Inclusão de Tag IPI_E.
  -- MODASP-5153   - André Artuzo     - #80# - (30/09/2019) - AJUSTE PARA CONSIDERAR CAMPOS COMO NUMÉRICO.
  -- MODASP-5769   - Edson Filenti    - #74# - (12/09/2019) - Ajuste no ICMS_ST_BASE da Loja. Imposto (12) não considerado no cálculo.
  -- MODASP-5826   - WENDEL CRESPIGIO - #73# - (06/08/2019) - Tratamento para imposto FECP_DEST , DICMS_DEST ,DICMS_ORIG
  -- MODASP-3705   - Fábio Santos     - #72# - (20/08/2019) - Incluido ICMS-DESONERADO.
  -- DM 110354     - Edson Filenti    - #71# - (19/02/2019) - Adicionada a coluna TIPO_OPERACAO.
  -- DM 90628      - Eder Silva       - #70# - (24/08/2018) - Tratamento para emissão de nota TIPO_ORIGEM = 11 (Entrada para conserto) para clientes com UF = "EX".
  -- SEM DM        - ANDRÉ ARTUZO     - #69# - (18/09/2018) - ADEQUAÇÃO PARA UTILIZAR O CODIGO DO MUNICIPIO DO CADASTRO DE ENTREGA DO PEDIDO OMS.
  -- SEM DM        - ANDRÉ ARTUZO	    - #68# - (14/09/2018) - ADEQUAÇÃO PARA UTILIZAR O CPF/CNPJ DE ENTREGA DE UM PEDIDO OMS CASO EXISTIR
  -- SEM DM        - MAYDSON HEDLUND  - #67# - (10/09/2018) - ADEQUAÇÃO PARA CONSULTAR OS DADOS DE ENTREGA DE UM PEDIDO OMS CASO EXISTIR.
  -- DM 64234	   - DIEGO MORENO	    - #66# - (28/02/2018) - ADEQUACAO NFE 4.00. MELHORIA NO TRATAMENTO PARA O GRUPO ICMS60.
  -- DM 58430	   - DIEGO MORENO	    - #65# - (20/09/2017) - ADEQUACAO NFE 4.00. MELHORIA NO TRATAMENTO PARA O IMPOSTO 76.
  -- DM 37504      - WENDEL CRESPIGIO - #64# - (18/07/2017) - ADICIONANDO O CAMPO CODIGO DA FILIAL PARA SER CONSIDERADO NA DLL LINX.NFCE.FOXPRO QUANDO UTILIZADO NFCE.
  -- DM 13714      - EDER SILVA       - #63# - (13/12/2016) - CORREÇÃO DO CAMPO BAIRRO (TAG XBAIRRO) PARA CONSIDERAR NOMES QUE CONTENHAM NO MÍNIMO 2 CARACTERES.
  -- DM 13486      - WENDEL CRESPIGIO - #62# - (08/12/2016) - TRATAMENTO PARA QUANDO A FILIAL FOR CADASTRADA COMO TIPO SIMPLES NACIONAL COM SUBLIMITE.
  -- DM 12121      - WENDEL CRESPIGIO - #61# - (02/12/2016) - TRATAMENTO PARA NÃO REMOVER O HÍFEN (-) DAS CIDADES COM NOMES COMPOSTOS.
  -- DM 11083      - WENDEL CRESPIGIO - #60# - (24/10/2016) - INCLUSO COD_MUNICIPIO_IBGE PARA CLIENTES ESTRANGEIRO.
  -- DM10977       - WENDEL CRESPIGIO - #59# - (19/10/2016) - FOI DESFEITO A PROGRAMAÇÃO #57#.  
  -- DM9976        - FABIO SANTOS     - #58# - (17/10/2016) - CORREÇÃO PARA NFCE ACIMA DE 10.000 NAO ESTAVA SENDO CARREGADO O CLIENTE NFCE 
  -- D8458         - EDSON FILENTI    - #57# - (09/09/2016  - CORREÇÃO NA VALIDAÇÃO DA INFORMÇÃO PARA COLUNA INDICADOR_IE_DESTINARARIO. CORREÇÃO NA ORDENAÇÃO DOS CASE.
  -- DM 3823       - VÍVIAN DOMINGUES - #56# - (15/07/2016) - INCLUSÃO DA INFORMAÇÃO DO CAMPO IEST.
  -- DM 1372       - EDSON FILENTI    - #55# - (16/12/2015) - REPLICAÇÃO DA DEMANDA #1294# - BUSCAR O CNPJ DO DESTINATÁRIO DA TABELA DADOS_CADASTRO_XML_NFE 
  -- DM1873        - WENDEL CRESPIGIO - #54# - (22/02/2016) - CONFORME VALIDAÇÃO COM THIAGO , INCLUIDO NOVO CAMPO NF_NUMERO_REFERENCIADA PARA CONTROLE DA NOTA REFERENCIADAS.
  -- D1517         - EDSON FILENTI	   - #53# - (21/01/2016) - REPLICAÇÃO DA CORREÇÃO DA DEMANDA 1322. SOLICITANDO POR THIAGO MARCON (1322 - TRATAMENTO PARA GERAR OS TOTAIS DE IMPOSTOS REFERENTE AS TAGS VFCPUFDEST VICMSUFDEST E VICMSUFREMET NO GRUPO ICMSTOT APENAS QUANDO FOR NFE DE VENDA DE MERCADORIAS TIPO ORIGEM 1 OU 10.)
  -- D1321         - GILVANO.SANTOS   - #52# - (14/12/2015) - REMOÇÃO DA FUNCTION FX_VALIDA_IE, UMA VEZ QUE A VALIDAÇÃO JÁ É FEITA NO CADASTRO DO CLIENTE.
  -- TP10769689    - DIEGO.MORENO	   - #51# - (26/11/2015) - NÃO DEVE VERIFICAR O INDICA_CONSUMIDOR_FINAL PARA O CLIENTE QUE É PJ E TEM INSCRIAÇÃO ESTADUAL VALIDA.
  -- TP10769689    - JOAO GONZALES    - #50# - (30/11/2015) - INCLUSÃO DOS NOVOS CAMPOS, PARA ATENDER A NT2015003
  -- TP11206534    - EDER SILVA       - #49# - (26/11/2015) - REPLICAÇÃO DO TRATAMENTO PARA INDIEDEST FEITO NA RETAGUARDA.
  -- TP11148244    - WENDEL CRESPIGIO - #48# - (18/11/2015) - CORREÇÃO PARA GERAR O CAMPO "INDICADOR_IE_DESTINARARIO" COM O VALOR "9" PARA CLIENTE "PESSOA FÍSICA", "CONSUMIDOR FINAL" E QUE SEJA DE FORA DO ESTADO DO EMITENTE.
  -- TP10089905    - WENDEL CRESPIGIO - #47# - (18/11/2015) - CORREÇÃO PARA GERAR O CAMPO "INDICADOR_IE_DESTINARARIO" COM O VALOR "9" PARA CLIENTE "PESSOA FÍSICA", "NÃO CONSUMIDOR FINAL" E QUE SEJA DE FORA DO ESTADO DO EMITENTE.
  -- TP10505235    - GILVANO SANTOS   - #46# - (13/11/2015) - USO DO CAMPO CPF_CGC_ECF DA TABELA LOJA_VENDA PARA IDENTIFICAR CLIENTES NA EMISSÃO DA NFC-E. 
  -- TP11036880    - EDSON FILENTI    - #45# - (12/11/2015) - INCLUSÃO DA COLUNA MARCA_VOLUME NA SELEÇÃO DA NF DE LOJA. 
  -- TP10839227    - EDER SILVA       - #44# - (03/11/2015) - CORREÇÃO PARA PEGAR O NÚMERO DO DOCUMENTO DE CLIENTE ESTRANGEIRO, OBRIGATÓRIO PARA NFCE ACIMA DE 10MIL, POIS ESTAVA GERANDO VAZIO
  -- 10885554      - GILVANO SANTOS   - #43# - (29/10/2015) - CORREÇÃO DA TP #39#, ISSO PORQUE ESTAVA CRIANDO AS COLUNAS "EMAIL_NFE" E "EMAIL_DESTINATARIO" NÃO FICAVA NULA QUANDO OS RESPECTIVOS CAMPOS POSSUI 0 CARACTERE
  -- SEM TP        - JOAO GONZALES    - #42# - (12/08/2015) - EFETUADA A CORREÇÃO DA ESTRUTURA PARA AS DEMAIS COLUNAS.
  -- 9357406       - GILVANO SANTOS   - #41# - (12/08/2015) - CORREÇÃO DA ESTRUTURA DA COLUNA CEP_EMITENTE DE 8000 CARACTERES PARA 9 CARACTERES
  -- SEM TP        - WENDEL CRESPIGIO - #40# - (10/08/2015) - ADICIONADO TRATAMENTO PARA CAMPOS QUE PRECISAM DE TRATAMENTO PARA CARACTERES ESPECIAIS
  -- TP9390484     - JORGE.DAMASCO    - #39# - (10/07/2015) - TRATATIVA PARA OS CAMPOS "EMAIL_NFE" E "EMAIL_DESTINATARIO" NÃO EXCEDEREM OS 60 CARACTERES.
  -- TP8936960     - VICTOR KAJIYAMA  - #38# - (22/06/2015) - IMPLEMENTAÇÃO DE ICMS DIFERIDO PARA A NFE 3.10. 
  -- TP8459846     - JORGE DAMASCO    - #37# - (09/06/2015) - CRIAÇÃO DA "CTE CFOP" PARA CORRETA UTILIZAÇÃO DOS CFOP'S POR ITEM NA NOTA.
  -- TP8820108     - VICTOR KAJIYAMA  - #36# - (03/06/2015) - CASO NÃO EXISTA UMA DATA_SAIDA EM LOJA_NOTA_FISCAL, O SISTEMA NÃO COLOCA UMA DATA, ASSIM, DEIXANDO A DANFE SEM O REGISTRO REFERENTE. 
  -- TP8666922     - WENDEL CRESPIGIO - #35# - (21/05/2015) - IMPLEMENTADO O CONVERT PARA STRING, PARA NÃO DAR INCOMPATIBILIDADE NO EDMX DO COMPONENTE LINX.FOXPRONFCE.DLL
  -- SEM TP        - WENDEL CRESPIGIO - #34# - (05/05/2015) - ADICIONADO CAMPOS PARA O TRATAMENTO DE CARACTERES ESPECIAIS 
  -- SEM TP        - WENDEL CRESPIGIO - #33# - (30/04/2015) - #FORÇA TAREFA LAYOUT 3.10# CORREÇÃO PARA NOTA FISCAL REMOVE CARACTERES ESPECIAIS. 
  -- TP8466037     - WENDEL CRESPIGIO - #32# - (30/04/2015) - #FORÇA TAREFA LAYOUT 3.10# CORREÇÃO PARA NOTA FISCAL COM VARIOS CUPOMS DE TROCAS FEITOS DURANTE O DIA. 
  -- TP8425108     - JORGE.DAMASCO    - #31# - (28/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO PARA QUANDO FOR NOTA DE CONSUMÍVEL.
  -- TP8425108     - JORGE.DAMASCO    - #30# - (27/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO PARA NF-E PARA QUANDO CADASTRO_CLI_FOR.UF OU CLIENTES_VAREJO.UF UF = EX.
  --			  										   COMPLEMENTO PARA O CAMPO "RG_IE".
  -- TP8425108     - WENDEL CRESPIGIO - #29# - (26/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO PARA NF-E PARA QUANDO CADASTRO_CLI_FOR.UF OU CLIENTES_VAREJO.UF UF = EX. 
  -- TP8425108     - JORGE DAMASCO    - #28# - (26/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO PARA UTILIZAR O CAMPO CORRETO: TIPO_ORIGEM. 
  -- (SEM TP!)     - JORGE DAMASCO    - #27# - (22/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO PARA NÃO PREENCHER A TAG <EXPORTA>. 
  -- TP8300181     - JORGE DAMASCO    - #26# - (17/04/2015) - #FORÇA TAREFA LAYOUT 3.10# - CORREÇÃO P/ QUANDO SE TRATAR DE CONSUMIDOR FINAL E FOR ALGUM TIPO ABAIXO, SEMPRE UTILIZAR ID_DESTINO_OPERACAO = 1 (NF-E NORMAL):
  --													1	-	VENDA
  --													2	-	TROCA
  --													7	-	CANCELAMENTO DE VENDA
  --													10	-	VENDA À CONSUMIDOR
  -- REPLICACAO- THIAGO E JORGE - #25# - (08/04/2015) - REPLICAÇÃO AJUSTE NF-E ERP	
  -- TP5639147 - GILVANO SANTOS - #24# - (11/02/2015) - IMPLANTAÇÃO CF-E SAT, ***(TRECHO REMOVIDO)
  -- TP7715503 - JORGE.DAMASCO - #23# - (06/02/2015) - PASSOU A UTILIZAR CORRETAMENTE O CAMPO "INFORMACAO_COMPLEMENTAR".
  -- TP7700824 - JOÃO GONZALES - #22# - (29/01/2015) - TRATAMENTO PARA A CONCATENAÇÃO CONTER APENA "--", ESTE CAMPO NA NFCE É SUBSTITUIDO POR "\N" QUE FAZ A QUEBRA DE LINHA ENTRE O MD5 E AS INFORMAÇÕES COMPLEMENTARES(TAG:INFCPL) - VS(LINX.DANFE.GENERATOR - NFCEDANFE.CS)
  -- TP7679545 - JORGE.DAMASCO - #21# - (26/01/2015) - CORREÇÃO P/ SÓ ADICIONAR AS INFORMAÇÕES COMPLEMENTARES AO CAMPO OBS_INTERESSE_FISCO QUANDO SE TRATAR DE NFC-E.
  -- TP7602726 - JORGE.DAMASCO - #20# - (16/01/2015) - LEI 12741/2012 - ALTERAÇÃO NA LEI PARA SEPARAÇÃO DOS IMPOSTOS. RETIRADA DOS DELIMITADORES DO CAMPO OBS
  -- 26/11/2014 - JORGE.DAMASCO  - #19# - SEMPRE QUE FOR UMA NFC-E UTILIZARÁ O E-MAIL DE LOJA_NOTA_FISCAL_XML.EMAIL.RETORNO
  -- 19/11/2014 - JORGE.DAMASCO  - #18# - INCLUSÃO DO CAMPO "COD_PAIS_BC" P/ UTILIZAÇÃO NA TAG <ENDERDEST> - NFC-E.
  -- 09/10/2014 - GILVANO/GIEDSON  - #17# - INCLUSÃO DE TRECHO PARA RETORNO DA INFORMACAO DO I.E QUANDO UTILIZADO O LAYOUT 2.0 DA NFE.
  -- 01/10/2014 - FILENTI  - #16# - INCLUSÃO DOS CAMPOS UTC_EMISSAO E UTC_DATA_SAIDA E ALTERAÇÃO PARA CAMPOS PADRÕES DE EMISSAO E DATA_SAIDA 
  -- 30/09/2014 - FILENTI  - #15# - CAMPO INDICADOR_IE_DESTINARARIO E RG_IE VALIDA SE CONSUMIDOR É PESSOA FISICA.	
  -- 22/09/2014 - GILVANO SANTOS - TP 6491153 - #14# O CAMPO DATA_HORA É NECESSARIO PARA EMISSÃO DA NFC-E
  -- 28/08/2014 - FILENTI  - ALTERAÇÕES PARA LAYOUT 3.10
  -- #7#  - NOTA TÉCNICA 2013.005 V1.02 - 03.1 - INCLUSÃO DO MODELO DO DOCUMENTO FISCAL - COLUNA MODELO_FISCAL
  -- #8#  - NOTA TÉCNICA 2013.005 V1.02 - 03.2 - ALTERAÇÃO NO FORMATO DA DATA PARA UTC
  -- #9#  - NOTA TÉCNICA 2013.005 V1.02 - 03.3 - INCLUSÃO DO ID LOCAL DESTINO. (1 - INTERNO; 2 - INTERESTADUAL; 3 - EXTERIOR) - COLUNA ID_DESTINO_OPERACAO
  -- #10# - NOTA TÉCNICA 2013.005 V1.02 - 03.6 - INDICA OPERAÇÃO COM CONSUMIDOR FINAL - INDFINAL
  -- #11# - NOTA TÉCNICA 2013.005 V1.02 - 03.6 - INDICA PRESENÇA DO COMPRADOR - INDPRES
  -- #12# - NOTA TÉCNICA 2013.005 V1.02 - 03.7 - IDENTIFICAÇÃO DO DESTINATÁRIO. OPERAÇÃO COM O EXTERIOR, OU PARA COMPRADOR ESTRANGEIRO. INFORMAR O NÚMERO DO PASSAPORTE OU OUTRO DOCUMENTO LEGAL PARA IDENTIFICAR PESSOA ESTRANGEIRA.
  -- #13# - NOTA TÉCNICA 2013.005 V1.02 - 03.7 - IDENTIFICAÇÃO DO DESTINATÁRIO E ALTERAÇÕES NA EXIBIÇÃO RG_IE
  -- 1=CONTRIBUINTE ICMS (INFORMAR A IE DO DESTINATÁRIO)
  -- 2=CONTRIBUINTE ISENTO DE INSCRIÇÃO NO CADASTRO DE CONTRIBUINTES DO ICMS;
  -- 9=NÃO CONTRIBUINTE, QUE PODE OU NÃO POSSUIR INSCRIÇÃO ESTADUAL NO CADASTRO DE CONTRIBUINTES DO ICMS;
  -- NOTA 1: NO CASO DE NFC-E INFORMAR INDIEDEST=9 E NÃO INFORMAR A TAG IE DO DESTINATÁRIO;
  -- NOTA 2: NO CASO DE OPERAÇÃO COM O EXTERIOR INFORMAR INDIEDEST=9 E NÃO INFORMAR A TAG IE DO DESTINATÁRIO;
  -- NOTA 3: NO CASO DE CONTRIBUINTE ISENTO DE INSCRIÇÃO (INDIEDEST=2), NÃO INFORMAR A TAG IE DO DESTINATÁRIO.
  -- 18/06/2014 - GILVANO SANTOS - TP 5719199 - #6# - ALTERAÇÃO DA RAZÃO SOCIAL DO DESTINATARIO DE ACORDO COM O DOCUMENTO EMITIDO E AMBIENTE (NFC-E/NF-E)
  -- 24/10/2013 - DIEGO MORENO - TP 3996736 - #5# - ALTERAÇÃO NO TAMANHO DO CAMPO EMAIL, PASSOU DE VARCHAR (40) PARA VARCHAR (60)
  -- 01/10/2013 - GILVANO SANTOS - TP 4348002/TP4444801 - #4# - INCLUSÃO DA TABELA LOJA_NOTA_FISCAL_XML PARA BUSCAR INFORMAÇÃO DO E-MAIL DE RETORNO QUANDO O USUARIO QUISER RECEBER A DANFE POR OUTRO E-MAIL.
  -- 28/09/2013 - ROBERTO BEDA - TP 4348002 - #3# - SUPORTE A CLIENTE NÃO CADASTRADO QUE INFORMOU O CPF NA VENDA
  -- 18/09/2013 - GILVANO SANTOS - #2# - INCLUSÃO DO CAMPO CP_INSS E CP_INSS_BASE PARA ATENDER DEMANDA DA NFC-E (DLL)
  -- 09/11/2012 - JORGE DAMASCO - #1# - ALTERADO DE CODIGO_FILIAL PARA FILIAL NO CAMPO OBS
  WITH CFOP
       AS (SELECT DISTINCT FILIAL,
                           SERIE_NF,
                           NF,
                           CAST(LEFT(CODIGO_FISCAL_OPERACAO, 1) AS INT) CODIGO
           FROM   W_IMPRESSAO_NFE_ITENS) -- #37#
  SELECT CASE
           WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('EXIBE_NOME_FANTASIA_XML', LOJAS_VAREJO.CODIGO_FILIAL), '.F.') = '.T.' THEN LOJAS_VAREJO.FILIAL
           ELSE
             CASE
               WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('EXIBE_NOME_FANTASIA_XML', LOJAS_VAREJO.CODIGO_FILIAL), '.F.') = '.F.' THEN NULL
               ELSE LOJAS_VAREJO.FILIAL
             END
         END                                                                                                                                                                        NOME_FANTASIA_EMITENTE,
         LOJAS_VAREJO.FILIAL,
         EMITENTE.CGC_CPF                                                                                                                                                           AS CNPJ_EMITENTE,
         LOJA_NOTA_FISCAL.NF_NUMERO                                                                                                                                                 AS NF,
         LOJA_NOTA_FISCAL.SERIE_NF,
         CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL                                                                                                                                     AS MODELO_FISCAL,--#7#
         CASE
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN 1 -- #37#
           WHEN ( LOJA_NOTA_FISCAL.TIPO_ORIGEM IN ( '1', '2', '7', '10','11' ) -- #70#
                  AND LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 1
                  AND ( CFOP.CODIGO IN ( 1, 5 ) ) ) THEN 1 -- (LOJA_NOTA_FISCAL.NATUREZA_OPERACAO_CODIGO LIKE '1%' OR LOJA_NOTA_FISCAL.NATUREZA_OPERACAO_CODIGO LIKE '5%')) THEN 1 -- #26# - #28# - #37#
           WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN 3 --#9#
           WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = EMITENTE.UF THEN 1 --#9#
           WHEN LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 1
                AND CFOP.CODIGO IN ( 1, 5 ) THEN 1 -- LOJA_NOTA_FISCAL.NATUREZA_OPERACAO_CODIGO LIKE '5%' THEN 1 -- #31# - #37#
           ELSE 2 --#9#
         END                                                                                                                                                                        AS ID_DESTINO_OPERACAO,--#9#
         LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL                                                                                                                                   AS INDICA_OPERACAO_FINAL,--#10# 
         LOJA_NOTA_FISCAL.INDICA_PRESENCA_COMPRADOR                                                                                                                                 AS INDICA_PRESENCA_COMPRADOR,--#11# AGUARDANDO CRIAÇÃO DA COLUNA. VALOR PADRÃO 1 = CONSUMIDOR FINAL 
         CASE
           WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE)
           ELSE NULL
         END                                                                                                                                                                        AS DOC_ESTRANGEIRO,-- #12#  
   --      CASE
   --        WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN 9
   --        WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN 9 -- #29#
   --        WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
   --             AND LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) > 1
   --             AND ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO'
   --             AND ( ISNULL(CADASTRO_CLI_FOR.PJ_PF, 1) = 1
   --                   AND ISNULL(CLIENTES_VAREJO.PF_PJ, 0) = 0 ) THEN 1 --#15#
   --        WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
   --             AND ( LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) = 0
   --                    OR ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) = 'ISENTO' )
   --             AND ( LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 1 )
   --             OR (CLIENTES_VAREJO.PF_PJ = 1) THEN 9 --#49# [SUBSTITUÍDO PELO ABAIXO]
			--/*#47# - INÍCIO*/
			--WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
   --             AND ( LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) = 0
   --                    OR ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO' )
   --             AND ( LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 0 ) THEN 9
			--/*#47# - FIM*/
			--/*#48# - INÍCIO*/
			-- WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
   --             AND LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) > 1
   --             AND ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO'
   --             AND ( ISNULL(CADASTRO_CLI_FOR.PJ_PF, 0) = 0
   --                   AND ISNULL(CLIENTES_VAREJO.PF_PJ, 0) = 1 ) THEN 9 
   --         /*#48# - FIM*/
   --        ELSE 2
   --      END                                                                                                                                                                        AS INDICADOR_IE_DESTINARARIO,--#13# 
		-- #51# - INÍCIO -
		-- ATENÇÃO: O PROCESSO ABAIXO ATENDE DIVERSOS CENÁRIOS, COM PARTILHA E TIPOS DE DESTINATÁRIO.
	    CASE
			WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN 9 --#37#
		    WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN 9 -- #29#
			--WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' AND LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) > 1 AND (ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO' AND DBO.FX_VALIDA_IE(ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF), RTRIM(LTRIM(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE)))) = 1) AND ( ISNULL(CADASTRO_CLI_FOR.PJ_PF, 1) = 1 AND ISNULL(CLIENTES_VAREJO.PF_PJ, 0) = 0 ) THEN 1 --#52#
			WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' AND LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) > 1 AND ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO' AND ( ISNULL(CADASTRO_CLI_FOR.PJ_PF, 1) = 1 AND ISNULL(CLIENTES_VAREJO.PF_PJ, 0) = 0 ) THEN 1 --#52#
			WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' AND (LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) = 0 OR ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) = 'ISENTO') AND (LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 0 ) THEN 2
            WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' AND  ISNULL(CLIENTE_VAR_TIPOS.INDICADOR_FISCAL_TERCEIRO, 8) IN (8,10,11) THEN 9 -- #38# #39#
            ELSE 2
		--#51# - FIM
		END                                                                                                                                                                        AS INDICADOR_IE_DESTINARARIO,--#13# 
		 -- #49# - FIM
         SERIES_NF.COD_SERIE_SINTEGRA,
         ISNULL(CONVERT(VARCHAR(40), CADASTRO_CLI_FOR.NOME_CLIFOR), CLIENTES_VAREJO.CLIENTE_VAREJO)                                                                                 AS NOME_CLIFOR,
         CONVERT(CHAR(3), '')                                                                                                                                                       AS CONDICAO_PGTO,
         CASE
           WHEN CTB_LX_TIPO_OPERACAO.INDICA_ENTRADA_SAIDA = 'E' THEN LOJAS_NATUREZA_OPERACAO.NATUREZA_ENTRADA
           ELSE LOJAS_NATUREZA_OPERACAO.NATUREZA_SAIDA
         END                                                                                                                                                                        AS NATUREZA,
         CASE
           WHEN LOJA_NOTA_FISCAL.TRANSP_RAZAO_SOCIAL = ''
                 OR FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_RAZAO_SOCIAL
         END                                                                                                                                                                        AS TRANSPORTADORA,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS TRANSP_REDESPACHO,
         CONVERT(VARCHAR(23), '')                                                                                                                                                   AS COD_TRANSACAO,
         CASE
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN LOJA_NOTA_FISCAL.DATA_SAIDA
           ELSE LOJA_NOTA_FISCAL.EMISSAO
         END                                                                                                                                                                        AS EMISSAO,--#8# #16#
         LOJA_NOTA_FISCAL.DATA_SAIDA                                                                                                                                                AS DATA_SAIDA,--#8# #16#
         CASE
           WHEN CONVERT(VARCHAR(10), LOJA_NOTA_FISCAL.DATA_SAIDA, 108) = '00:00:00' THEN NULL
           ELSE CONVERT(VARCHAR(10), LOJA_NOTA_FISCAL.DATA_SAIDA, 108)
         END                                                                                                                                                                        AS HORA_SAIDA,--#8# #14#	
         LOJA_NOTA_FISCAL.FRETE,
         LOJA_NOTA_FISCAL.SEGURO,
         CONVERT(NUMERIC(15, 5), LOJA_NOTA_FISCAL.DESCONTO)                                                                                                                         AS DESCONTO,
         CONVERT(NUMERIC(13, 10), CASE
                                    WHEN LOJA_NOTA_FISCAL.VALOR_TOTAL_ITENS != 0 THEN LOJA_NOTA_FISCAL.DESCONTO / LOJA_NOTA_FISCAL.VALOR_TOTAL_ITENS * 100
                                    ELSE 0
                                  END)                                                                                                                                              AS PORC_DESCONTO,
         CONVERT(NUMERIC(15, 5), 0)                                                                                                                                                 AS DESCONTO_SEFAZ,
         CONVERT(NUMERIC(8, 5), 0)                                                                                                                                                  AS PORC_DESCONTO_SEFAZ,
         CONVERT(NUMERIC(15, 5), 0)                                                                                                                                                 AS DESCONTO_COND_PGTO,
         CONVERT(NUMERIC(13, 10), 0)                                                                                                                                                AS PORC_DESCONTO_COND_PGTO,
         CONVERT(NUMERIC(15, 5), LOJA_NOTA_FISCAL.ENCARGO)                                                                                                                          AS ENCARGO,
         CONVERT(NUMERIC(13, 10), CASE
                                    WHEN LOJA_NOTA_FISCAL.VALOR_TOTAL_ITENS != 0 THEN LOJA_NOTA_FISCAL.ENCARGO / LOJA_NOTA_FISCAL.VALOR_TOTAL_ITENS * 100
                                    ELSE 0
                                  END)                                                                                                                                              AS PORC_ENCARGO,
         CONVERT(NUMERIC(15, 5), LOJA_NOTA_FISCAL.VALOR_TOTAL)                                                                                                                      AS VALOR_TOTAL,
         CONVERT(NUMERIC(15, 5), LOJA_NOTA_FISCAL.VALOR_TOTAL)                                                                                                                      AS VALOR_TOTAL_MOEDA,
         CONVERT(NUMERIC(10, 3), LOJA_NOTA_FISCAL.QTDE_TOTAL)                                                                                                                       AS QTDE_TOTAL,
         CONVERT(BIT, 0)                                                                                                                                                            AS NF_FATURA,
         CONVERT(CHAR(11), '')                                                                                                                                                      AS FATURA,
         LOJA_NOTA_FISCAL.NOTA_IMPRESSA,
         CONVERT(BIT, 0)                                                                                                                                                            AS ACERTO_CONTAS_P_R,
         CONVERT(CHAR(18), '')                                                                                                                                                      AS TABELA_FILHA,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, REPLACE(DBO.FX_DADOS_ADICIONAIS_NFE(LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, FILIAIS.FILIAL, 'L'), CHAR(1), '')) AS OBS,-- #1# - #20# #34#
         LOJA_NOTA_FISCAL.PESO_LIQUIDO,
         LOJA_NOTA_FISCAL.PESO_BRUTO,
         LOJA_NOTA_FISCAL.VOLUMES,
         LOJA_NOTA_FISCAL.TIPO_VOLUME,
         CAST(NULL AS VARCHAR(8))                                                                                                                                                   AS VEICULO_PLACA,--NULL AS VEICULO_PLACA,
         CAST(NULL AS CHAR)                                                                                                                                                         AS UF_PLACA_VEICULO,--NULL AS UF_PLACA_VEICULO,
         CONVERT(BIT, 0)                                                                                                                                                            AS CONFERIDO,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS CONFERIDO_POR,
         FRETE_A_PAGAR                                                                                                                                                              AS ENTREGA_CIF,
         LOJA_NOTA_FISCAL.RECEBIMENTO                                                                                                                                               AS DEVOLUCAO,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS REPRESENTANTE,
         CONVERT(NUMERIC(8, 5), 0)                                                                                                                                                  AS PORC_COMISSAO_REPRESENTANTE,
         CONVERT(NUMERIC(8, 5), 0)                                                                                                                                                  AS PORCENTAGEM_ACERTO,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS GERENTE,
         CONVERT(NUMERIC(8, 5), 0)                                                                                                                                                  AS PORC_COMISSAO_GERENTE,
         CONVERT(VARCHAR(11), '')                                                                                                                                                   AS CONFERENCIA,
         CTB_LX_TIPO_OPERACAO.DESC_TIPO_OPERACAO                                                                                                                                    AS TIPO,
         CONVERT(CHAR(6), 'R$')                                                                                                                                                     AS MOEDA,
         CONVERT(NUMERIC(11, 6), 0)                                                                                                                                                 AS CAMBIO_NA_DATA,
         CONVERT(DATETIME, '')                                                                                                                                                      AS DATA_FATURAMENTO_RELATIVO,
         CONVERT(CHAR(2), '')                                                                                                                                                       AS TIPO_FRETE,
         LOJA_NOTA_FISCAL.EMPRESA,
         CONVERT(BIT, 0)                                                                                                                                                            AS COBRAR_MOEDA_PADRAO,
         CONVERT(VARCHAR(200), '')                                                                                                                                                  AS OBS_TRANSPORTE,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS CLIENTE_ENTREGA,
         CONVERT(NUMERIC(16, 2), 0)                                                                                                                                                 AS VALOR_FRETE,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS TABELA_PRECO_FRETE,
         CONVERT(INT, 0)                                                                                                                                                            AS CTB_LANCAMENTO,
         CONVERT(SMALLINT, 0)                                                                                                                                                       AS CTB_ITEM,
         CONVERT(INT, 0)                                                                                                                                                            AS NUMERO_CONFERENCIA,
         CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS DESCONTO_SOBRE_1,
         CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS DESCONTO_SOBRE_2,
         CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS DESCONTO_SOBRE_3,
         CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS DESCONTO_SOBRE_4,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS FATURA_FILIAL,
         CONVERT(CHAR(7), '')                                                                                                                                                       AS FATURA_NUMERO,
         CONVERT(CHAR(2), '')                                                                                                                                                       AS FATURA_SERIE,
         CONVERT(VARCHAR(25), '')                                                                                                                                                   AS FATURA_NOME_CLIFOR,
         CONVERT(SMALLINT, ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL), '0'))                                                                        AS AGRUPAMENTO_ITENS,--ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', LOJAS_VAREJO.CODIGO_FILIAL),'0') AS AGRUPAMENTO_ITENS
         LOJA_NOTA_FISCAL.VALOR_TOTAL_ITENS                                                                                                                                         AS VALOR_SUB_ITENS,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS VALOR_DIFERENCA_GUIA_FATURA,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS VALOR_COMISSAO_REPRESENTANTE,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS VALOR_COMISSAO_GERENTE,
         LOJA_NOTA_FISCAL.VALOR_IMPOSTO_AGREGAR,
         DBO.FN_GETFISCALOPERATIONS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)                                                          AS CFOP,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, DBO.FX_TEXTO_LEGAL_NFE(LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 'L'))            AS TEXTO_LEGAL,--#34#
         CONVERT(BIT, 0)                                                                                                                                                            AS PRIORIZACAO,
         CONVERT(INT, LOJA_NOTA_FISCAL.FIN_EMISSAO_NFE)                                                                                                                             AS FIN_EMISSAO_NFE,--LOJA_NOTA_FISCAL.FIN_EMISSAO_NFE 
         LOJA_NOTA_FISCAL.TIPO_EMISSAO_NFE,
         CASE
           WHEN CTB_LX_TIPO_OPERACAO.TIPO_OPERACAO IN ( 'V', 'E' )
                AND INDICA_ENTRADA_SAIDA = 'S' THEN '0'
           ELSE '2'
         END                                                                                                                                                                        AS TIPO_PGTO_NFE,
         LOJA_NOTA_FISCAL.CHAVE_NFE,
         LOJA_NOTA_FISCAL.STATUS_NFE,
         LOJA_NOTA_FISCAL.PROTOCOLO_AUTORIZACAO_NFE,
         LOJA_NOTA_FISCAL.DATA_AUTORIZACAO_NFE,
         LOJA_NOTA_FISCAL.REGISTRO_DPEC,
         LOJA_NOTA_FISCAL.DATA_REGISTRO_DPEC,
         (SELECT SUM(CASE
                       WHEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM > 0 THEN LOJA_NOTA_FISCAL_ITEM.DESCONTO_ITEM * LOJA_NOTA_FISCAL_ITEM.QTDE_ITEM
                       ELSE 0
                     END)
          FROM   LOJA_NOTA_FISCAL_ITEM
          WHERE  CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL
                 AND NF_NUMERO = LOJA_NOTA_FISCAL.NF_NUMERO
                 AND SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF)                                                                                                                          AS VALOR_DESCONTO_ITENS,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS VALOR_SUB_ITENS_BRUTO,--0 AS VALOR_SUB_ITENS_BRUTO, 	
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_PF_PJ
         END                                                                                                                                                                        AS TRANSPORTADORA_PF_PJ,
         CASE
           WHEN LOJA_NOTA_FISCAL.TRANSP_CGC = ''
                 OR FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_CGC
         END                                                                                                                                                                        AS TRANSPORTADORA_CNPJ,
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_RAZAO_SOCIAL
         END                                                                                                                                                                        AS TRANSPORTADORA_RAZAO_SOCIAL,
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, LOJA_NOTA_FISCAL.TRANSP_ENDERECO)
         END                                                                                                                                                                        AS TRANSPORTADORA_ENDERECO,--#34#
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_CIDADE
         END                                                                                                                                                                        AS TRANSPORTADORA_CIDADE,
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_UF
         END                                                                                                                                                                        AS TRANSPORTADORA_UF,
         CASE
           WHEN FRETE_A_PAGAR = 9 THEN NULL
           ELSE LOJA_NOTA_FISCAL.TRANSP_INSCRICAO
         END                                                                                                                                                                        AS TRANSPORTADORA_IE,
		 CONVERT(VARCHAR(9),REPLICATE(0,8-LEN([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,EMITENTE.CEP)))+[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,EMITENTE.CEP))					AS CEP_EMITENTE, --#40# #41# #42#
         EMITENTE.PJ_PF                                                                                                                                                             AS PJ_PF_EMITENTE,
         EMITENTE.RAZAO_SOCIAL                                                                                                                                                      AS RAZAO_SOCIAL_EMITENTE,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, EMITENTE.ENDERECO)                                                                                                             AS ENDERECO_EMITENTE,--#34#
         EMITENTE.NUMERO                                                                                                                                                            AS NUMERO_EMITENTE,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, EMITENTE.COMPLEMENTO)                                                                                                          AS COMPLEMENTO_EMITENTE,--#34#
		 CASE WHEN LEN(EMITENTE.BAIRRO) >= 2 THEN CONVERT(VARCHAR(25),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,EMITENTE.BAIRRO)) ELSE NULL END									AS BAIRRO_EMITENTE, --#40# #42# #63#
         EMITENTE.CIDADE                                                                                                                                                            AS CIDADE_EMITENTE,
         EMITENTE.UF                                                                                                                                                                AS UF_EMITENTE,
         EMITENTE.PAIS                                                                                                                                                              AS PAIS_EMITENTE,
         EMITENTE.DDD1                                                                                                                                                              AS DDD1_EMITENTE,
         --CASE
         --  WHEN EMITENTE.TELEFONE1 = '' THEN NULL
         --  ELSE EMITENTE.TELEFONE1
		 CASE WHEN LEN(ISNULL(EMITENTE.TELEFONE1,''))>=6 THEN CONVERT(VARCHAR(10),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,EMITENTE.TELEFONE1)) ELSE NULL END						AS TELEFONE1_EMITENTE, --#40# #42#
         EMITENTE.RG_IE                                                                                                                                                             AS IE_EMITENTE,
         EMITENTE.IM                                                                                                                                                                AS IM_EMITENTE,
         EMITENTE.CNAE                                                                                                                                                              AS CNAE,
         ISNULL(CONVERT(VARCHAR(14), CADASTRO_CLI_FOR.CLIFOR), CLIENTES_VAREJO.CODIGO_CLIENTE)                                                                                      AS CLIFOR,
         CASE
		   --WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' AND ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN '' --#44#
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' AND ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) -- #44#
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' AND ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN '' -- #44#
           --WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' AND LEN(ISNULL(LOJA_VENDA.CPF_CGC_ECF, '')) > 0 THEN LOJA_VENDA.CPF_CGC_ECF -- #3# #46#
		   WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN ISNULL(LOJA_VENDA.CPF_CGC_ECF, '') -- #46#
           --ELSE ISNULL(CADASTRO_CLI_FOR.CGC_CPF, CLIENTES_VAREJO.CPF_CGC) 
		   ELSE ISNULL((CASE WHEN DADOS_CADASTRO_XML_NFE.CGC_DESTINATARIO='' THEN NULL ELSE DADOS_CADASTRO_XML_NFE.CGC_DESTINATARIO END),ISNULL(CADASTRO_CLI_FOR.CGC_CPF, CLIENTES_VAREJO.CPF_CGC)) --#55#
         END    
		                                                                                                                                                                     AS CNPJ_DESTINATARIO,
         -- EMAIL_NFE
         CASE
           WHEN LEN(RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))) = 0 THEN NULL --#43#
		   WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN RTRIM(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO)
		   ELSE
             CASE
			   WHEN LEN(RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))) <= 60 THEN RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))
               ELSE NULL
             END
         END                                                                                                                                                                        AS EMAIL_NFE,-- #39#
         -- EMAIL_DESTINATARIO	
         CASE
		   WHEN LEN(RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))) = 0 THEN NULL --#43#
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN RTRIM(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO)
           ELSE
             CASE
               WHEN LEN(RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))) <= 60 THEN RTRIM(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CADASTRO_CLI_FOR.EMAIL_NFE, CADASTRO_CLI_FOR.EMAIL, CLIENTES_VAREJO.EMAIL))
               ELSE NULL
             END
         END                                                                                                                                                                        AS EMAIL_DESTINATARIO,-- #39# 
         -- TRATAMENTO HOMOLOGACAO NF-E 2.00 A PARTIR DE 01/05/2011
         CASE
           WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('IDENTIFICA_AMBIENTE_NFE', LOJAS_VAREJO.CODIGO_FILIAL), '0') = '2'
                AND CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55' --#6#
         THEN 'NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'
           WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('IDENTIFICA_AMBIENTE_NFCE', LOJAS_VAREJO.CODIGO_FILIAL), '0') = '2'
                AND CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' --#6#
         THEN 'NFC-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL' --#6#
           ELSE ISNULL(CADASTRO_CLI_FOR.RAZAO_SOCIAL, CONVERT(VARCHAR(90), CLIENTES_VAREJO.CLIENTE_VAREJO))
         END                                                                                                                                                                        AS RAZAO_SOCIAL,
         CASE
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN NULL
           WHEN ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX' THEN NULL -- #30#
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
                AND LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) > 1
                AND ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) <> 'ISENTO'
                AND ( ISNULL(CADASTRO_CLI_FOR.PJ_PF, 1) = 1
                      AND ISNULL(CLIENTES_VAREJO.PF_PJ, 0) = 0 ) THEN ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) --#15#
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '55'
                AND ( LEN(ISNULL(ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE), 0)) = 0
                       OR ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE) = 'ISENTO' )
                AND ( ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF) = 'EX'
                       OR LOJA_NOTA_FISCAL.INDICA_CONSUMIDOR_FINAL = 1 ) THEN NULL
           WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('VERSAO_LAYOUT_XML_NFE', LOJAS_VAREJO.CODIGO_FILIAL), '') = '2.00' THEN ISNULL(CADASTRO_CLI_FOR.RG_IE, CLIENTES_VAREJO.RG_IE)--#17#
           ELSE NULL
         END                                                                                                                                                                        AS RG_IE,--#13#	
         --CONVERT(VARCHAR(14), NULL)                                                                                                                                               AS IEST, --#56# - COMENTADO
         DBO.FX_BUSCA_IE_ST(FILIAIS.FILIAL, ISNULL(CLIENTES_VAREJO.UF, CADASTRO_CLI_FOR.UF))				                                                                        AS IEST, --#56#
         CADASTRO_CLI_FOR.IM                                                                                                                                                        AS IM,
         ISNULL(CADASTRO_CLI_FOR.IM_ENTREGA, '')                                                                                                                                    AS IM_ENTREGA,
         ISNULL(CADASTRO_CLI_FOR.IM_COBRANCA, '')                                                                                                                                   AS IM_COBRANCA,
         ISNULL(CADASTRO_CLI_FOR.PJ_PF, ~CLIENTES_VAREJO.PF_PJ)                                                                                                                     AS PJ_PF,
         ISNULL(CADASTRO_CLI_FOR.PAIS, ISNULL(CLIENTES_VAREJO.PAIS, CASE
                                                                      WHEN CLIENTES_VAREJO.UF = 'EX' THEN NULL
                                                                      ELSE 'BRASIL'
                                                                    END))                                                                                                           AS PAIS,
         ISNULL(CADASTRO_CLI_FOR.ENTREGA_PAIS, ISNULL(CLIENTES_VAREJO.PAIS, CASE
                                                                              WHEN CLIENTES_VAREJO.UF = 'EX' THEN NULL
                                                                              ELSE 'BRASIL'
                                                                            END))                                                                                                   AS ENTREGA_PAIS,
         -------------------
         -- INÍCIO - #67# --
         -------------------
         --ISNULL(CADASTRO_CLI_FOR.ENTREGA_DDD, '')                                                                                                                                   AS ENTREGA_DDD,
		 --CASE WHEN LEN(CADASTRO_CLI_FOR.ENTREGA_TELEFONE)>=6 THEN CONVERT(VARCHAR(10),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,CADASTRO_CLI_FOR.ENTREGA_TELEFONE)) ELSE NULL END	AS ENTREGA_TELEFONE, --#40# #42#		 
		 ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, DDD) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),ISNULL(CADASTRO_CLI_FOR.ENTREGA_DDD, ''))                                                                                                                                  AS ENTREGA_DDD,
		 ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, DDD) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),CASE WHEN LEN(CADASTRO_CLI_FOR.ENTREGA_TELEFONE)>=6 THEN CONVERT(VARCHAR(10),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,CADASTRO_CLI_FOR.ENTREGA_TELEFONE)) ELSE NULL END) AS ENTREGA_TELEFONE,
         ----------------
         -- FIM - #67# --
         ----------------
         CASE
           WHEN CADASTRO_CLI_FOR.INDICADOR_FISCAL_TERCEIRO <> 13
                 OR CADASTRO_CLI_FOR.INSCRICAO_SUFRAMA = '' THEN NULL
           ELSE CADASTRO_CLI_FOR.INSCRICAO_SUFRAMA
         END                                                                                                                                                                        AS INSCRICAO_SUFRAMA,
		 CONVERT(VARCHAR(9),REPLICATE(0,8-LEN([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.CEP, CLIENTES_VAREJO.CEP))))
							+[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.CEP, CLIENTES_VAREJO.CEP)))															AS CEP, --#40# #42#
         left([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, ISNULL(CADASTRO_CLI_FOR.ENDERECO, ISNULL(RTRIM(CLIENTES_VAREJO.TIPO_LOGRADOURO), '')
                                                                                       + ' '
                                                                                       + ISNULL(RTRIM(CLIENTES_VAREJO.ENDERECO), ''))), 60)                                         AS ENDERECO,--#34#
         ISNULL(CADASTRO_CLI_FOR.NUMERO, CLIENTES_VAREJO.NUMERO)                                                                                                                    AS NUMERO,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, ISNULL(CADASTRO_CLI_FOR.COMPLEMENTO, CONVERT(VARCHAR(60), CLIENTES_VAREJO.COMPLEMENTO)))                                       AS COMPLEMENTO,--#34#
         ISNULL(CADASTRO_CLI_FOR.CIDADE, CLIENTES_VAREJO.CIDADE)                                                                                                                    AS CIDADE,
         ISNULL(CADASTRO_CLI_FOR.UF, CLIENTES_VAREJO.UF)                                                                                                                            AS UF,
		 CASE WHEN LEN(ISNULL(CADASTRO_CLI_FOR.TELEFONE1, CLIENTES_VAREJO.TELEFONE))>=6 
			  THEN CONVERT(VARCHAR(10),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.TELEFONE1, CLIENTES_VAREJO.TELEFONE))) ELSE NULL	END						   TELEFONE1, --#40# #42#
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, ISNULL(CADASTRO_CLI_FOR.COBRANCA_ENDERECO, ''))                                                                                AS COBRANCA_ENDERECO,--#34#
         ISNULL(CADASTRO_CLI_FOR.COBRANCA_NUMERO, '')                                                                                                                               AS COBRANCA_NUMERO,
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, ISNULL(CADASTRO_CLI_FOR.COBRANCA_COMPLEMENTO, ''))                                                                             AS COBRANCA_COMPLEMENTO,--#34#
         ISNULL(CADASTRO_CLI_FOR.COBRANCA_CIDADE, '')                                                                                                                               AS COBRANCA_CIDADE,
         ISNULL(CADASTRO_CLI_FOR.BANCO, '')                                                                                                                                         AS BANCO,
         ISNULL(CADASTRO_CLI_FOR.CARTEIRA, '')                                                                                                                                      AS CARTEIRA,
         ISNULL(CADASTRO_CLI_FOR.COBRANCA_UF, '')                                                                                                                                   AS COBRANCA_UF,
		 CONVERT(VARCHAR(9),REPLICATE(0,8-LEN([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.COBRANCA_CEP, ''))))
							+ [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.COBRANCA_CEP, '')))																AS COBRANCA_CEP, --#40# #42#
         -------------------
         -- INÍCIO - #67# --
         -------------------
         --CADASTRO_CLI_FOR.ENTREGA_ENDERECO        
         --[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, CADASTRO_CLI_FOR.ENTREGA_NUMERO)                                                                                               AS ENTREGA_NUMERO,--#34#
         --[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, CADASTRO_CLI_FOR.ENTREGA_COMPLEMENTO)                                                                                          AS ENTREGA_COMPLEMENTO,--#34#
         --CADASTRO_CLI_FOR.ENTREGA_CIDADE,
         --CADASTRO_CLI_FOR.ENTREGA_UF,
		 --CONVERT(VARCHAR(9),REPLICATE(0,8-LEN([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.ENTREGA_CEP, ''))))
		 --					+ [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.ENTREGA_CEP, '')))																	AS ENTREGA_CEP, --#40# #42#
	     --						
         --
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, LOGRADOURO_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),CADASTRO_CLI_FOR.ENTREGA_ENDERECO)                                                   AS ENTREGA_ENDERECO,
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, NRO_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)), [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, CADASTRO_CLI_FOR.ENTREGA_NUMERO))              AS ENTREGA_NUMERO,
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, COMPLEMENTO_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)), [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, CADASTRO_CLI_FOR.ENTREGA_COMPLEMENTO)) AS ENTREGA_COMPLEMENTO,
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, MUN_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)), CADASTRO_CLI_FOR.ENTREGA_CIDADE)                                                           AS ENTREGA_CIDADE,
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, UF) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)), CADASTRO_CLI_FOR.ENTREGA_UF)                                                                        AS ENTREGA_UF,
		 ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, CADASTRO_CLI_FOR.CEP) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),
		         CONVERT(VARCHAR(9),REPLICATE(0,8-LEN([DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.ENTREGA_CEP, '')))) + [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.ENTREGA_CEP, ''))))																	       AS ENTREGA_CEP,
         ----------------
         -- FIM - #67# --
         ----------------
         ISNULL(CADASTRO_CLI_FOR.INDICA_FORNECEDOR, 0)                                                                                                                              AS INDICA_FORNECEDOR,
         ISNULL(CADASTRO_CLI_FOR.INDICA_CLIENTE, 1)                                                                                                                                 AS INDICA_CLIENTE,
         ISNULL(CADASTRO_CLI_FOR.IND_REPRESENTANTE, 0)                                                                                                                              AS IND_REPRESENTANTE,
         ISNULL(CADASTRO_CLI_FOR.INDICA_FILIAL, 0)                                                                                                                                  AS INDICA_FILIAL,
         ISNULL( (SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](1, CPF_CGC) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),CADASTRO_CLI_FOR.ENTREGA_CGC) AS ENTREGA_CGC, --#68# #75#
         ISNULL(CADASTRO_CLI_FOR.ENTREGA_IE, '')                                                                                                                                    AS ENTREGA_IE,
		 CASE WHEN LEN(ISNULL(CADASTRO_CLI_FOR.BAIRRO, CLIENTES_VAREJO.BAIRRO)) >= 2 
			  THEN CONVERT(VARCHAR(25),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,ISNULL(CADASTRO_CLI_FOR.BAIRRO, CLIENTES_VAREJO.BAIRRO))) ELSE NULL END							AS BAIRRO, --#40# #42# #63#
         [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, ISNULL(CADASTRO_CLI_FOR.OBS_DE_FATURAMENTO, ''))                                                                               AS OBS_DE_FATURAMENTO,--#34#
         ISNULL(CADASTRO_CLI_FOR.DDD1, CLIENTES_VAREJO.DDD)                                                                                                                         AS DDD1,
         CADASTRO_CLI_FOR.DDI,
         CONVERT(VARCHAR(20), ISNULL(CADASTRO_CLI_FOR.CONTA_CONTABIL, ''))                                                                                                          AS CONTA_CONTABIL_CLIENTE,-- ISNULL(CADASTRO_CLI_FOR.CONTA_CONTABIL, '') AS CONTA_CONTABIL_CLIENTE , 
		 -------------------
         -- INÍCIO - #67# --
         -------------------
		 --CASE WHEN LEN(CADASTRO_CLI_FOR.ENTREGA_BAIRRO) >= 2 THEN CONVERT(VARCHAR(25),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,CADASTRO_CLI_FOR.ENTREGA_BAIRRO)) ELSE NULL END	AS ENTREGA_BAIRRO,  --#40# #42# #63#
		 ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0, BAIRRO_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),
		         CASE WHEN LEN(CADASTRO_CLI_FOR.ENTREGA_BAIRRO) >= 2 THEN CONVERT(VARCHAR(25),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,CADASTRO_CLI_FOR.ENTREGA_BAIRRO)) ELSE NULL END)	                                AS ENTREGA_BAIRRO,
		 ----------------
         -- FIM - #67# --
         ----------------
		 CASE WHEN LEN(ISNULL(CADASTRO_CLI_FOR.COBRANCA_BAIRRO, '')) >= 2 
		      THEN CONVERT(VARCHAR(25),[DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](0,CADASTRO_CLI_FOR.COBRANCA_BAIRRO)) ELSE NULL END													AS COBRANCA_BAIRRO, --#40# #42# #63#
         CONVERT(VARCHAR(500), '')                                                                                                                                                  AS CAIXAS_ENVIADAS,
         DBO.FN_GETFISCALCLASSIFICATIONS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)                                                     AS CLASSIFICACOES,
         CONVERT(VARCHAR(500), '')                                                                                                                                                  AS PEDIDOS_ENVIADOS,
         CONVERT(VARCHAR(500), '')                                                                                                                                                  AS PEDIDOS_CLIENTE_ENVIADOS,
         LOJAS_NATUREZA_OPERACAO.NATUREZA_DESCRICAO                                                                                                                                 AS DESC_NATUREZA,
         LOJAS_NATUREZA_OPERACAO.CTB_TIPO_OPERACAO,
         LOJAS_NATUREZA_OPERACAO.LX_TIPO_LANCAMENTO,
         LOJAS_NATUREZA_OPERACAO.NATUREZA_DESCRICAO                                                                                                                                 AS DESC_NF_NATUREZA,
         CONVERT(VARCHAR(40), '')                                                                                                                                                   AS DESC_TIPO_LANCAMENTO,
         CTB_LX_TIPO_OPERACAO.DESC_TIPO_OPERACAO,
         CONVERT(VARCHAR(40), '')                                                                                                                                                   AS DESC_CONDICAO_PGTO,
         CONVERT(CHAR(6), '')                                                                                                                                                       AS CLIFOR_REPRESENTANTE,
         CONVERT(VARCHAR(40), '')                                                                                                                                                   AS DESC_CONTA_CONTABIL_CLIENTE,
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 1, 1, 'L')                                    AS ICMS,
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 51, 1, 'L')                                   AS ICMS_BST,--#38# - ADICIONANDO COLUNA NA VIEW
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 1, 2, 'L')                                    AS ICMS_BASE,
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 2, 1, 'L')                                    AS IPI,
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 2, 2, 'L')                                    AS IPI_BASE,
		 DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 52, 1)															AS IPI_E, --#81#
		 DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 52, 2)                                                          AS IPI_E_BASE, --#81#
		 DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 3, 1)                                                           AS IRRF,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 3, 2)                                                           AS IRRF_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 4, 1)                                                           AS INSS,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 4, 2)                                                           AS INSS_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 5, 1)                                                           AS PIS,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 5, 2)                                                           AS PIS_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 6, 1)                                                           AS COFINS,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 6, 2)                                                           AS COFINS_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 7, 1)                                                           AS I_IMPORT,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 7, 2)                                                           AS I_IMPORT_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 8, 1)                                                           AS IVA,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 8, 2)                                                           AS IVA_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 9, 1)                                                           AS RECARGO,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 9, 2)                                                           AS RECARGO_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 10, 1)                                                          AS IRPF,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 10, 2)                                                          AS IRPF_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 11, 1)                                                          AS DICMS,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 11, 2)                                                          AS DICMS_BASE,
         
		 --#74# - ICMS ST - Soma impostos 12, 60, 63 - ICMS_ST e ICMS_ST_BASE
		 DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 12, 1, 'L')+
		 DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 63, 1, 'L')+ 
	     DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 60, 1, 'L')						   /*#74#*/ AS ICMS_ST, 
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 12, 2, 'L')+
		 DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 63, 2, 'L')+ 
	     DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 60, 2, 'L')						   /*#74#*/ AS ICMS_ST_BASE, 

         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 13, 1, 'L')                                   AS ICMS_STR,
         DBO.FX_CALCULA_IMPOSTO_INCIDENCIA('', LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, LOJA_NOTA_FISCAL.CODIGO_FILIAL, 13, 2, 'L')                                   AS ICMS_STR_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 14, 1)                                                          AS ISS,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 14, 2)                                                          AS ISS_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 15, 1)                                                          AS IVA_IC,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 15, 2)                                                          AS IVA_IC_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 16, 1)                                                          AS PC_CSL,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 16, 2)                                                          AS PC_CSL_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 17, 1)                                                          AS PIS_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 17, 2)                                                          AS PIS_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 18, 1)                                                          AS COFINS_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 18, 2)                                                          AS COFINS_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 19, 1)                                                          AS CSLL_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 19, 2)                                                          AS CSLL_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 20, 1)                                                          AS IRRF_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 20, 2)                                                          AS IRRF_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 21, 1)                                                          AS INSS_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 21, 2)                                                          AS INSS_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 22, 1)                                                          AS ISS_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 22, 2)                                                          AS ISS_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 23, 1)                                                          AS PIS_S,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 23, 2)                                                          AS PIS_S_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 24, 1)                                                          AS COFINS_S,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 24, 2)                                                          AS COFINS_S_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 25, 1)                                                          AS CSLL_S,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 25, 2)                                                          AS CSLL_S_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 30, 1)                                                          AS RTEIVA,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 30, 2)                                                          AS RTEIVA_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 31, 1)                                                          AS RTEIVA_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 31, 2)                                                          AS RTEIVA_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 32, 1)                                                          AS ICA,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 32, 2)                                                          AS ICA_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 33, 1)                                                          AS RTEICA,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 33, 2)                                                          AS RTEICA_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 34, 1)                                                          AS RTEFTE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 34, 2)                                                          AS RTEFTE_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 35, 1)                                                          AS RTEFTE_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 35, 2)                                                          AS RTEFTE_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 36, 1)                                                          AS ICMS_ZF,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 36, 2)                                                          AS ICMS_ZF_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 36, 3)                                                          AS ICMS_ZF_ALIQ,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 37, 1)                                                          AS PIS_ZF,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 37, 2)                                                          AS PIS_ZF_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 37, 3)                                                          AS PIS_ZF_ALIQ,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 38, 1)                                                          AS COFINS_ZF,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 38, 2)                                                          AS COFINS_ZF_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 38, 3)                                                          AS COFINS_ZF_ALIQ,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 40, 1)                                                          AS DICMS_R,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 40, 2)                                                          AS DICMS_R_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 42, 1)                                                          AS FECP,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 42, 2)                                                          AS FECP_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 43, 1)                                                          AS SIMPLES_E,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 43, 2)                                                          AS SIMPLES_E_BASE,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 44, 1)                                                          AS SIMPLES_F,
         DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 44, 2)                                                          AS SIMPLES_F_BASE,
		 CASE WHEN LOJA_NOTA_FISCAL.TIPO_ORIGEM IN ('1','4','10','15') THEN DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 70, 1) ELSE 0 END AS FECP_DEST, -- #50# #53# #73# #82#
		 CASE WHEN LOJA_NOTA_FISCAL.TIPO_ORIGEM IN ('1','2','4','10','15') THEN DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 72, 1) ELSE 0 END AS DICMS_DEST,-- #50# #53# #73# #82# #85#
		 CASE WHEN LOJA_NOTA_FISCAL.TIPO_ORIGEM IN ('1','2','4','10','15') THEN DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 71, 1) ELSE 0 END AS DICMS_ORIG,-- #50# #53# #73# #82# #85#
		 --#65#
		 DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 76, 1)    AS FECP_ST, 
		   DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 83, 1) AS FECP_STA, -- #66#
		DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 84, 1) AS FECP_STAR,   -- #66#
		 --#65#		
		--#72#-Início
		DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 87, 1) AS ICMS_DESONERADO, 
		DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 87, 2) AS ICMS_DESONERADO_BASE, 
		DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 87, 3) AS ICMS_DESONERADO_ALIQ, 
	   --#72#-Fim
		 --DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 70, 1)                                                          AS FECP_DEST,--#50# #53#
         --DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 72, 1)                                                          AS DICMS_DEST,--#50# #53#
         --DBO.FN_GETFISCALTAX(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF, 71, 1)                                                          AS DICMS_ORIG,--#50# #53#
		 CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS CP_INSS,
         CONVERT(NUMERIC(8, 2), 0)                                                                                                                                                  AS CP_INSS_BASE,
         CONVERT(NUMERIC(15, 2), 0)                                                                                                                                                 AS PIS_SOBRE_SERVICO,
         CONVERT(NUMERIC(15, 2), 0)                                                                                                                                                 AS COFINS_SOBRE_SERVICO,
         FILIAIS.COD_FILIAL,
         CASE
           WHEN FRETE_A_PAGAR = 1 THEN 'CIF'
           ELSE 'FOB'
         END                                                                                                                                                                        AS DESCRICAO_TIPO_FRETE,
         SERIES_NF.DESCRICAO                                                                                                                                                        AS DESCRICAO_SERIE,
         SERIES_NF.ANO_FISCAL,
         LOJA_NOTA_FISCAL.NOTA_CANCELADA,
         CONVERT(CHAR(10), '')                                                                                                                                                      AS NF_E_NUMERO,
         CONVERT(DATETIME, '')                                                                                                                                                      AS NF_E_DATA_EMISSAO,
         CONVERT(CHAR(10), '')                                                                                                                                                      AS NF_E_COD_VERIFICACAO,
         CONVERT(DATETIME, '')                                                                                                                                                      AS NF_E_DATA_QUITACAO_GUIA,
         CONVERT(DATETIME, '')                                                                                                                                                      AS NF_E_GERACAO,
         'L' + CASE LOJA_NOTA_FISCAL.RECEBIMENTO WHEN 1 THEN 'E' ELSE 'S' END                                                                                                       AS ORIGEM_NF,
		 CASE WHEN ISNULL(NF_NUMERO_REFERENCIADA,'') = '' THEN 0 ELSE 1 END                                                                                                         AS NF_NUMERO_REFERENCIADA, --#54#
         CONVERT(INT, 0)                                                                                                                                                            AS SEQUENCIAL_UNICO,
         CONVERT(DATETIME, '')                                                                                                                                                      AS DATA_GERACAO_NSU,
         CASE
           WHEN CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = '65' THEN REPLACE(REPLACE(CONVERT(VARCHAR(MAX), LOJA_NOTA_FISCAL.OBS_INTERESSE_FISCO), CHAR(13), ''), CHAR(10), '')
                                                                   + '--'
           ELSE LOJA_NOTA_FISCAL.OBS_INTERESSE_FISCO
         END                                                                                                                                                                        AS OBS_INTERESSE_FISCO,-- 2.0 - #20# - #21# - #23#
         LOJA_NOTA_FISCAL.INFORMACAO_COMPLEMENTAR,-- #23#
         CONVERT(VARCHAR(24), LOJA_NOTA_FISCAL.DATA_CONTINGENCIA, 127)
         + '-0'
         + CONVERT(CHAR(1), LOJA_NOTA_FISCAL.UTC_EMISSAO)
         + ':00'                                                                                                                                                                    AS DATA_CONTINGENCIA_UTC,--#25#
         LOJA_NOTA_FISCAL.DATA_CONTINGENCIA,--2.0
         LOJA_NOTA_FISCAL.JUSTIFICATIVA_CONTINGENCIA,--2.0
         CASE
           WHEN EMITENTE.INDICADOR_FISCAL_TERCEIRO = 16 THEN 1
		   WHEN EMITENTE.INDICADOR_FISCAL_TERCEIRO = 18 THEN 2  --#62#
           ELSE 3
         END                                                                                                                                                                        AS CRT,--2.0
 --INICIO #84#
		 CASE
           WHEN CLIENTES_VAREJO.UF = 'EX' AND LOJA_NOTA_FISCAL.INDICA_PRESENCA_COMPRADOR in (2,3,9) THEN DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE (1,EMITENTE.UF)
		 ELSE
			CAST(NULL AS VARCHAR(60))
         END																																										UF_EMBARQUE_EXPORTACAO,
		 CASE
           WHEN CLIENTES_VAREJO.UF = 'EX' AND LOJA_NOTA_FISCAL.INDICA_PRESENCA_COMPRADOR in (2,3,9) THEN DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE (1,EMITENTE.CIDADE)
	     ELSE
	       CAST(NULL AS VARCHAR(60))
         END																																										LOCAL_EMBARQUE_EXPORTACAO,
--         CAST(NULL AS VARCHAR(60))                                                                                                                                                  AS UF_EMBARQUE_EXPORTACAO,--#27# #35#
--         CAST(NULL AS VARCHAR(60))                                                                                                                                                  AS LOCAL_EMBARQUE_EXPORTACAO,--#27# #35#
--FIM #84#
         NULL                                                                                                                                                                       AS NOTA_EMPENHO_COMPRA,
         NULL                                                                                                                                                                       AS PEDIDO_COMPRA,
         NULL                                                                                                                                                                       AS CONTRATO_COMPRA,--1.10
         --CAST(NULL AS VARCHAR(60))                                                                                                                                                AS MARCA_VOLUMES,--NULL AS MARCA_VOLUMES,  
		 CASE WHEN LEN(REPLACE(LOJA_NOTA_FISCAL.MARCA_VOLUME, ' ', '')) > 0 THEN  CAST(LOJA_NOTA_FISCAL.MARCA_VOLUME AS VARCHAR(60)) ELSE NULL END                                  AS MARCA_VOLUMES,--NULL AS MARCA_VOLUMES #45#,  
         CAST(NULL AS VARCHAR(60))                                                                                                                                                  AS NUMERACAO_VOLUMES,--NULL AS NUMERACAO_VOLUMES,								--1.10 (TRANSPORTE)
         EMITENTE.COD_MUNICIPIO_IBGE                                                                                                                                            AS EMITENTE_COD_MUNICIPIO_IBGE,--2.0
         CASE WHEN CLIENTES_VAREJO.UF = 'EX' THEN '9999999' ELSE  --#60#
			 ISNULL(CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE, (SELECT TOP 1 LCF_LX_MUNICIPIO.COD_MUNICIPIO_IBGE
														  FROM   LCF_LX_MUNICIPIO (NOLOCK)
																 INNER JOIN LCF_LX_UF U (NOLOCK)
																		 ON U.ID_UF = LCF_LX_MUNICIPIO.ID_UF
														  WHERE  U.UF = CLIENTES_VAREJO.UF
																 AND DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT, DESC_MUNICIPIO) = 
																	 DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(DEFAULT, CLIENTES_VAREJO.CIDADE))) END									AS COD_MUNICIPIO_IBGE,  -- #61#
         ISNULL((SELECT [DBO].[FX_REPLACE_CARACTER_ESPECIAL_NFE](1, COD_MUN_ENTREGA) FROM DBO.FX_RETORNAR_ENDERECO_ENTREGA_OMS(LOJA_NOTA_FISCAL.CODIGO_FILIAL, LOJA_NOTA_FISCAL.NF_NUMERO, LOJA_NOTA_FISCAL.SERIE_NF)),CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_ENTREGA)  AS COD_MUNICIPIO_IBGE_ENTREGA, --#69##75#
		 ISNULL(DBO.FX_PARAMETRO_LOJA('IDENTIFICA_AMBIENTE_NFE', LOJAS_VAREJO.CODIGO_FILIAL), '2')                                                                                  AS AMBIENTE_NFE,
         ISNULL(DBO.FX_PARAMETRO_LOJA('VERSAO_LAYOUT_XML_NFE', LOJAS_VAREJO.CODIGO_FILIAL), '2.00')                                                                                 AS VERSAO_LAYOUT_NFE,
         ISNULL(DBO.FX_PARAMETRO_LOJA('FORMATO_IMP_DANFE_NFE', LOJAS_VAREJO.CODIGO_FILIAL), '1')                                                                                    AS FORMATO_IMP_DANFE_NFE,
         ISNULL(DBO.FX_PARAMETRO_LOJA('VERSAO_EMISSOR_NFE', LOJAS_VAREJO.CODIGO_FILIAL), 'LINX POS 6')                                                                              AS VERSAO_EMISSOR_NFE,
         0                                                                                                                                                                          AS IMPORTACAO,
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_ALFANDEGA,--0 AS IMPORTACAO_ALFANDEGA, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_OUTRAS_DESPESAS,--0 AS IMPORTACAO_OUTRAS_DESPESAS, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_FRETE,--0 AS IMPORTACAO_FRETE, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_SEGURO,--0 AS IMPORTACAO_SEGURO, 
		 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_DESEMBARACO,--0 AS IMPORTACAO_DESEMBARACO, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_TX_CAPATAZIA,--0 AS IMPORTACAO_TX_CAPATAZIA, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_ICMS,--0 AS IMPORTACAO_ICMS, 
         CONVERT(NUMERIC(14, 2), 0)                                                                                                                                                 AS IMPORTACAO_IMPOSTO,--0 AS IMPORTACAO_IMPOSTO	
         '.F.'                                                                                                                                                                      AS DANFE_NFE_IMPORTACAO_CALC,
         CONVERT(VARCHAR(24), LOJA_NOTA_FISCAL.DATA_HORA_EMISSAO, 127)
         + '-0'
         + CONVERT(CHAR(1), LOJA_NOTA_FISCAL.UTC_EMISSAO)
         + ':00'                                                                                                                                                                    AS UTC_EMISSAO,--#16#
         CASE
           WHEN LOJA_NOTA_FISCAL.DATA_SAIDA IS NOT NULL THEN CONVERT(VARCHAR(24), LOJA_NOTA_FISCAL.DATA_HORA_SAIDA, 127)
                                                             + '-0'
                                                             + CONVERT(CHAR(1), LOJA_NOTA_FISCAL.UTC_DATA_SAIDA)
                                                             + ':00'
           ELSE NULL
         END                                                                                                                                                                        AS UTC_DATA_SAIDA,--#16# #36#
         LCF_LX_PAIS.COD_PAIS_BC, --#58# 
         LOJAS_VAREJO.CODIGO_FILIAL, --#64#
		 CTB_LX_TIPO_OPERACAO.TIPO_OPERACAO, --#71#
		 CASE WHEN LOJA_INTERMEDIADORES_TRANSACAO.ID_INTERMEDIADOR IS NOT NULL 
			AND LOJA_NOTA_FISCAL.ID_INTERMEDIADOR IS NOT NULL THEN 1 ELSE 0 END AS INTERMERDIADOR, --#83#
		 CASE WHEN LOJA_INTERMEDIADORES_TRANSACAO.ID_INTERMEDIADOR IS NOT NULL THEN LOJA_INTERMEDIADORES_TRANSACAO.CNPJ ELSE NULL END AS INTERMERDIADOR_CNPJ, --#83#
		 CASE WHEN LOJA_INTERMEDIADORES_TRANSACAO_FILIAL.ID_INTERMEDIADOR IS NOT NULL THEN LOJA_INTERMEDIADORES_TRANSACAO_FILIAL.IDCADINTTRAN ELSE NULL END AS INTERMERDIADOR_IDCADINTTRAN --#83#
		 FROM   LOJA_NOTA_FISCAL (NOLOCK)
         LEFT JOIN LOJAS_VAREJO (NOLOCK)
                ON LOJA_NOTA_FISCAL.CODIGO_FILIAL = LOJAS_VAREJO.CODIGO_FILIAL
         INNER JOIN SERIES_NF (NOLOCK)
                 ON LOJA_NOTA_FISCAL.SERIE_NF = SERIES_NF.SERIE_NF
         LEFT JOIN CLIENTES_VAREJO (NOLOCK)
                ON LOJA_NOTA_FISCAL.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
         LEFT JOIN CADASTRO_CLI_FOR (NOLOCK)
                ON LOJA_NOTA_FISCAL.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR
         INNER JOIN LOJAS_NATUREZA_OPERACAO (NOLOCK)
                 ON LOJA_NOTA_FISCAL.NATUREZA_OPERACAO_CODIGO = LOJAS_NATUREZA_OPERACAO.NATUREZA_OPERACAO_CODIGO
         LEFT JOIN CTB_LX_TIPO_OPERACAO (NOLOCK)
                ON LOJAS_NATUREZA_OPERACAO.CTB_TIPO_OPERACAO = CTB_LX_TIPO_OPERACAO.CTB_TIPO_OPERACAO
         LEFT JOIN CLIENTE_VAR_TIPOS (NOLOCK)
                ON CLIENTES_VAREJO.TIPO_VAREJO = CLIENTE_VAR_TIPOS.TIPO_VAREJO
         LEFT JOIN CTB_LX_INDICADOR_FISCAL_TERCEIRO CTB_LX_INDICADOR_FISCAL_TERCEIRO (NOLOCK)
                ON ISNULL(CLIENTE_VAR_TIPOS.INDICADOR_FISCAL_TERCEIRO, 8) = CTB_LX_INDICADOR_FISCAL_TERCEIRO.INDICADOR_FISCAL_TERCEIRO
         LEFT JOIN CTB_LX_INDICADOR_FISCAL_TERCEIRO CTB_LX_INDICADOR_FISCAL_TERCEIRO_2 (NOLOCK)
                ON CADASTRO_CLI_FOR.INDICADOR_FISCAL_TERCEIRO = CTB_LX_INDICADOR_FISCAL_TERCEIRO_2.INDICADOR_FISCAL_TERCEIRO
         LEFT JOIN CADASTRO_CLI_FOR EMITENTE (NOLOCK)
                ON LOJAS_VAREJO.FILIAL = EMITENTE.NOME_CLIFOR
		
		LEFT JOIN DADOS_CADASTRO_XML_NFE (NOLOCK) --#55#
				ON DADOS_CADASTRO_XML_NFE.NF_SAIDA = LOJA_NOTA_FISCAL.NF_NUMERO AND 
				   DADOS_CADASTRO_XML_NFE.FILIAL =   LOJAS_VAREJO.FILIAL AND 
				   DADOS_CADASTRO_XML_NFE.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF

         INNER JOIN FILIAIS (NOLOCK)
                 ON LOJAS_VAREJO.FILIAL = FILIAIS.FILIAL
         LEFT JOIN (SELECT RAZAO_SOCIAL,
                           MIN(EMAIL) AS EMAIL
                    FROM   TRANSPORTADORAS
                    GROUP  BY RAZAO_SOCIAL) TRANSPORTADORAS
                ON LOJA_NOTA_FISCAL.TRANSP_RAZAO_SOCIAL = TRANSPORTADORAS.RAZAO_SOCIAL
         LEFT JOIN CTB_ESPECIE_SERIE (NOLOCK)
                ON SERIES_NF.ESPECIE_SERIE = CTB_ESPECIE_SERIE.ESPECIE_SERIE
         --> #32# ALTERAÇÕES PARA EVITAR A GERAÇÃO DE UM PRODUTO CARTESIANO. 
         LEFT JOIN ( LOJA_VENDA_PGTO (NOLOCK)
                     INNER JOIN LOJA_VENDA (NOLOCK)
                             ON LOJA_VENDA_PGTO.CODIGO_FILIAL = LOJA_VENDA.CODIGO_FILIAL_PGTO
                                AND LOJA_VENDA_PGTO.TERMINAL = LOJA_VENDA.TERMINAL_PGTO
                                AND LOJA_VENDA_PGTO.LANCAMENTO_CAIXA = LOJA_VENDA.LANCAMENTO_CAIXA )
                ON LOJA_NOTA_FISCAL.CODIGO_FILIAL = LOJA_VENDA_PGTO.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL.SERIE_NF = LOJA_VENDA_PGTO.SERIE_NF_SAIDA
                   AND LOJA_NOTA_FISCAL.NF_NUMERO = LOJA_VENDA_PGTO.NUMERO_FISCAL_VENDA
                   AND CTB_ESPECIE_SERIE.NUMERO_MODELO_FISCAL = 65 -- #3#
         LEFT JOIN LOJA_NOTA_FISCAL_XML (NOLOCK)
                ON LOJA_NOTA_FISCAL.CODIGO_FILIAL = LOJA_NOTA_FISCAL_XML.CODIGO_FILIAL
                   AND LOJA_NOTA_FISCAL.NF_NUMERO = LOJA_NOTA_FISCAL_XML.NF_NUMERO
                   AND LOJA_NOTA_FISCAL.SERIE_NF = LOJA_NOTA_FISCAL_XML.SERIE_NF -- #4#
         LEFT JOIN LCF_LX_PAIS (NOLOCK)
                ON CLIENTES_VAREJO.PAIS = LCF_LX_PAIS.DESC_PAIS -- #18#
         LEFT JOIN LOJA_INTERMEDIADORES_TRANSACAO (NOLOCK) --#83#
			ON LOJA_NOTA_FISCAL.ID_INTERMEDIADOR = LOJA_INTERMEDIADORES_TRANSACAO.ID_INTERMEDIADOR --#83#
			AND LOJA_INTERMEDIADORES_TRANSACAO.INATIVO = 0 --#83#
		 LEFT JOIN LOJA_INTERMEDIADORES_TRANSACAO_FILIAL (NOLOCK) --#83#
			ON LOJA_INTERMEDIADORES_TRANSACAO.ID_INTERMEDIADOR = LOJA_INTERMEDIADORES_TRANSACAO_FILIAL.ID_INTERMEDIADOR --#83#
			AND LOJA_INTERMEDIADORES_TRANSACAO_FILIAL.COD_FILIAL = FILIAIS.COD_FILIAL
			AND LOJA_INTERMEDIADORES_TRANSACAO_FILIAL.INATIVO = 0 --#83#
		 INNER JOIN CFOP
                 ON CFOP.FILIAL = FILIAIS.FILIAL
                    AND CFOP.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF
                    AND CFOP.NF = LOJA_NOTA_FISCAL.NF_NUMERO -- #37#
         
