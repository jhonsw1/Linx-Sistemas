CREATE PROCEDURE [DBO].[SP_VERIFYEXCHANGESOURCE]
 ( @CODIGO_FILIAL		CHAR(6), 
   @PRODUTO				CHAR(12),
   @QTDE				INT,
   @PRECO_LIQUIDO		NUMERIC(14, 2),
   @CODIGO_CLIENTE		VARCHAR(14),
   @IGNORA_EQUIPAMENTO	BIT = 0,
   @COR_PRODUTO			CHAR(10),
   @DATA_VENDA			DATETIME = '19000101',
   @TICKET				CHAR(8) = NULL
 )
   AS
  
  -- 25/05/2021	- FILLIPI RAMOS/WENDEL CRESPIGIO - #PRODSHOP-6943# - TRATAMENTO PARA N�O APRESENTAR TICKETS ONDE O SEU DOCUMENTO FISCAL (NF-E, NFC-E E SAT) N�O ESTIVER APROVADO (STATUS = 5)
  -- 21/06/2017 - WENDEL CRESPIGIO DM 32215 - #3# ALTERA��O DO TAMANHO DO CAMPO PRODUTO DA TABELA TEMPORARIA. 
  -- 28/06/2017 - FABIO SANTOS - DM 36138 #2# ERRO AO FINALIZAR TROCA COM EMISS�O DE NFE - INCLUS�O DA CHAVE_NFE_ORIGEM.
  -- 01/07/2016 - GIEDSON SILVA - ID1641 - #1# REFORMULA��O DA PROCEDURE CONFORME ORIENTA��ES E CONSIDERA��ES DO CRISPIM PARA MELHORAR A PERFORMANCE.
  -- ESTA MELHORIA OBJETIVA CONTEMPLAR TAMB�M OS PONTOS J� DESENVOLVIDOS ABAIXO:
  -- 17/03/2016 - GILVANO SANTOS - ID189 - CAPTURAR VENDAS SOMENTE VENDAS COM DOCUMENTO FISCAL AUTORIZADO OU COM NF-E VINCULADA.
  -- 19/01/2016 - GILVANO SANTOS - SEM DEMANDA - CORRE��O NA EXIBI��O DO MODELO FISCAL QUANDO O DOCUMENTO FOR GERADO NA TABELA LOJA_CF_SAT 
  -- 19/01/2016 - GILVANO SANTOS - ID571 - BUSCA ESPECIFICA QUANDO FOR PREENCHIDOS OS PARAMETROS @DATA_VENDA E @TICKET
  -- 12/01/2016 - GERSON PRADO - ID1512 - CRIAR PAR�METROS PARA USO NO PROCESSO DE TICKET PRESENTE/TROCA
  -- 06/01/2016 - GERSON PRADO - ID1282 - ADEQUAR PROCEDURE CONFORME CONSIDERA��ES DO CRISPIM PARA MELHORAR O DESEMPENHO.
  -- 15/12/2015 - GILVANO SANTOS - ID1244 - CORRE��O NO TRECHO DA JUN��O DA TABELA LOJA_NOTA_FISCAL PARA CONSIDERAR SERIE E CODIGO_FILIAL
  -- 09/12/2015 - GIEDSON SILVA - ID1232 - TRATAMENTO PARA VALIDAR O PRE�O AO RETORNAR AS INFORMA��ES PARA A TABELA TEMPOR�RIA #EXCHANGESOURCE ADEQUANDO CONFORME AS QUERYS 1 E 2.  
  -- 15/10/2015 - V�VIAN DOMINGUES - TP10652464 - TRATAMENTO PARA EXIBIR AS INFORMA��ES DO COO QUANDO TIVER NF MAS ESTA N�O ESTIVER AUTORIZADA.
  -- 13/10/2015 - GERSON PRADO - TRATAMENTO PARA O CURSOR RETORNAR TODOS OS REGISTROS CANDITADOS NO CURSOR 
  -- 01/09/2015 - GERSON PRADO - TRATAMENTO PARA O CURSOR RETORNAR APENAS UM REGISTRO NO CURSOR 
  -- 29/08/2015 - GIEDSON SILVA - ALTERADA A POSI��O DO RETORNO DAS INFORMA��ES DO CURSOR CUREXCHANGE. 
  -- 10/08/2015 - VICTOR KAJIYAMA - EFETUANDO TROCA DE VALOR DE CUPOM PARA QUE TRAGA O MESMO DOS PODUTOS QUE EST�O SENDO DEVOLVIDOS. 
  -- 06/08/2015 - GILVANO SANTOS  - TP9699816 - TRATAMENTO PARA DIFERENCIAR ID_EQUIPAMENTO DAS TABELA LOJA_CF_SAT E LOJA_VENDA_PGTO
  -- 16/03/2015 - DIEGO MORENO    - TP8061802 - REMO��O DO DESC DA CLAUSULA ORDER BY. 
  -- 04/02/2015 - VICTOR.KAJIYAMA - TP7122659 - TRATAMENTO PARA QUE A PROCEDURE N�O LISTE O CUPOM ATUAL NO QUAL A TROCA EST� SENDO EFETUADA. 
  -- 11/11/2014 - JORGE.DAMASCO   - TP6932595 - TRATAMENTO PARA NF-E/NFC-E/S@T
  -- 14/03/2014 - DIEGO CAMARGO   - TP5180592 - ALTERADO A VALIDA��O DE E. PARA A. (LOJA_VENDA), POIS PODIAMOS CONTER O CODIGO_CLIENTE IGUAL A NULL,
	BEGIN
		--#1#	 
		DECLARE @DATA_LIMITE AS DATETIME
		
		SET @DATA_LIMITE = NULL
		
		DECLARE @VENDAORIGEM TABLE(	CODIGO_FILIAL CHAR(6) COLLATE DATABASE_DEFAULT NOT NULL, 
									TICKET CHAR(8) COLLATE DATABASE_DEFAULT NOT NULL, 
									TERMINAL CHAR(03) COLLATE DATABASE_DEFAULT NULL, 
									DATA_VENDA DATETIME, 
									PRODUTO CHAR(12) COLLATE DATABASE_DEFAULT NOT NULL,  --#3#
									ITEM CHAR(04) COLLATE DATABASE_DEFAULT NULL, 
									QTDE INT, 
									VALOR_ICMS NUMERIC(14,2), 
									VALOR_CUPOM NUMERIC(14,2), 
									NUMERO_CUPOM_FISCAL VARCHAR(8) COLLATE DATABASE_DEFAULT NULL, 
									NF_NUMERO CHAR(15) COLLATE DATABASE_DEFAULT NULL,
									SERIE_NF CHAR(06) COLLATE DATABASE_DEFAULT NULL, 
									NUMERO_MODELO_FISCAL CHAR(03) COLLATE DATABASE_DEFAULT NULL, 
									ID_EQUIPAMENTO VARCHAR(20) COLLATE DATABASE_DEFAULT NULL, 
									ID_EQUIPAMENTO_SAT INT ,
									NUMERO_FISCAL_VENDA CHAR(15) COLLATE DATABASE_DEFAULT NULL,
									SERIE_NF_SAIDA CHAR(06) COLLATE DATABASE_DEFAULT NULL,
									LANCAMENTO_CAIXA CHAR(07) COLLATE DATABASE_DEFAULT NULL,
									DATA DATETIME NULL,
									CHAVE_NFE_ORIGEM VARCHAR(44) COLLATE DATABASE_DEFAULT NULL --#2#
								  ) 
		SET NOCOUNT ON
		
		IF @DATA_LIMITE IS NULL
			SET @DATA_LIMITE = DATEADD(DAY, -45, CONVERT(VARCHAR, GETDATE(), 112))
		
		IF ISNULL(@TICKET,'') <> ''
		BEGIN
			INSERT INTO @VENDAORIGEM
				SELECT	C.CODIGO_FILIAL, C.TICKET, A.TERMINAL, C.DATA_VENDA, C.PRODUTO, C.ITEM, C.QTDE,
						ROUND( CASE	WHEN C.ALIQUOTA > 0 
									THEN ((C.PRECO_LIQUIDO * C.QTDE) - (C.PRECO_LIQUIDO * C.QTDE * C.FATOR_DESCONTO_VENDA)) * (C.ALIQUOTA / 100) 
									ELSE 0 END, 2, 1) AS VALOR_ICMS,
						(C.PRECO_LIQUIDO * @QTDE) AS VALOR_CUPOM, 
						B.NUMERO_CUPOM_FISCAL,
						NULL AS NF_NUMERO,
						NULL AS SERIE_NF,
						CAST('' AS CHAR(3)) AS NUMERO_MODELO_FISCAL,
						B.ID_EQUIPAMENTO, 
						NULL AS ID_EQUIPAMENTO_SAT,
						ISNULL(B.NUMERO_FISCAL_VINCULADA, B.NUMERO_FISCAL_VENDA) AS NUMERO_FISCAL_VENDA,
						ISNULL(B.SERIE_NF_VINCULADA, B.SERIE_NF_SAIDA) AS SERIE_NF_SAIDA,
						B.LANCAMENTO_CAIXA, DATA,
						NULL AS CHAVE_NFE_ORIGEM --#2#
				FROM	LOJA_VENDA A
						INNER JOIN	LOJA_VENDA_PGTO B 
								ON	A.CODIGO_FILIAL_PGTO = B.CODIGO_FILIAL 
									AND A.TERMINAL_PGTO = B.TERMINAL 
									AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA 
									AND B.DATA > = @DATA_LIMITE     
						INNER JOIN	LOJA_VENDA_PRODUTO C 
								ON	A.CODIGO_FILIAL = C.CODIGO_FILIAL
									AND A.TICKET = C.TICKET 
									AND A.DATA_VENDA = C.DATA_VENDA   
				WHERE	A.CODIGO_FILIAL = @CODIGO_FILIAL
						AND A.TICKET = @TICKET
						AND A.DATA_VENDA = @DATA_VENDA
						AND C.PRODUTO = @PRODUTO
						AND C.QTDE >=  @QTDE
						AND C.PRECO_LIQUIDO = @PRECO_LIQUIDO
						AND C.COR_PRODUTO = @COR_PRODUTO
						AND B.VENDA_FINALIZADA = 1 
						AND A.DATA_VENDA > = @DATA_LIMITE 
						AND NOT EXISTS	(
										SELECT	CODIGO_FILIAL_ORIGEM 
										FROM	DBO.LOJA_VENDA_TROCA_ORIGEM F 
										WHERE	C.CODIGO_FILIAL = F.CODIGO_FILIAL_ORIGEM 
												AND C.TICKET = F.TICKET_ORIGEM
												AND C.DATA_VENDA = F.DATA_VENDA_ORIGEM 
												AND C.ITEM = F.ITEM_ORIGEM 
												AND F.CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL
										)
				ORDER BY	ISNULL(A.CODIGO_CLIENTE, A.CPF_CGC_ECF) DESC, C.QTDE,
							CASE WHEN C.DATA_VENDA = CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 112)) THEN 1  ELSE 0 END,
							A.DATA_VENDA DESC, A.DATA_DIGITACAO 						
		END

		IF ISNULL(@TICKET,'') = '' OR @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @VENDAORIGEM
				SELECT TOP 10 
						C.CODIGO_FILIAL, C.TICKET, A.TERMINAL, C.DATA_VENDA, C.PRODUTO, C.ITEM, C.QTDE,
						ROUND( CASE	WHEN C.ALIQUOTA > 0 
									THEN ((C.PRECO_LIQUIDO * C.QTDE) - (C.PRECO_LIQUIDO * C.QTDE * C.FATOR_DESCONTO_VENDA)) * (C.ALIQUOTA / 100) 
									ELSE 0 END, 2, 1) AS VALOR_ICMS,
						(C.PRECO_LIQUIDO * @QTDE) AS VALOR_CUPOM,
						B.NUMERO_CUPOM_FISCAL,
						NULL AS NF_NUMERO,
						NULL AS SERIE_NF,
						CAST('' AS CHAR(3)) AS NUMERO_MODELO_FISCAL,
						B.ID_EQUIPAMENTO, 
						NULL AS ID_EQUIPAMENTO_SAT,
						ISNULL(B.NUMERO_FISCAL_VINCULADA, B.NUMERO_FISCAL_VENDA) AS NUMERO_FISCAL_VENDA,
						ISNULL(B.SERIE_NF_VINCULADA, B.SERIE_NF_SAIDA) AS SERIE_NF_SAIDA,
						B.LANCAMENTO_CAIXA,
						DATA,
						NULL AS CHAVE_NFE_ORIGEM --#2#
				FROM	LOJA_VENDA A
						INNER JOIN	LOJA_VENDA_PGTO B 
								ON	A.CODIGO_FILIAL_PGTO = B.CODIGO_FILIAL 
									AND A.TERMINAL_PGTO = B.TERMINAL 
									AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA 
									AND B.DATA > = @DATA_LIMITE 
						INNER JOIN	LOJA_VENDA_PRODUTO C 
								ON	A.CODIGO_FILIAL = C.CODIGO_FILIAL
									AND A.TICKET = C.TICKET 
									AND A.DATA_VENDA = C.DATA_VENDA  
				WHERE	A.CODIGO_FILIAL = @CODIGO_FILIAL
						AND C.PRODUTO = @PRODUTO
						AND C.QTDE >=  @QTDE
						AND C.PRECO_LIQUIDO = @PRECO_LIQUIDO
						AND C.COR_PRODUTO = @COR_PRODUTO
						AND B.VENDA_FINALIZADA = 1 
						AND A.DATA_VENDA > = @DATA_LIMITE
						AND (ISNULL(A.CODIGO_CLIENTE, A.CPF_CGC_ECF) = @CODIGO_CLIENTE OR A.CODIGO_CLIENTE IS NULL) 
						AND NOT EXISTS	(
										SELECT	CODIGO_FILIAL_ORIGEM 
										FROM	DBO.LOJA_VENDA_TROCA_ORIGEM F 
										WHERE	C.CODIGO_FILIAL = F.CODIGO_FILIAL_ORIGEM 
												AND C.TICKET = F.TICKET_ORIGEM
												AND C.DATA_VENDA = F.DATA_VENDA_ORIGEM 
												AND C.ITEM = F.ITEM_ORIGEM 
												AND F.CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL
										)
				ORDER  BY	ISNULL(A.CODIGO_CLIENTE, A.CPF_CGC_ECF) DESC, C.QTDE,
							CASE WHEN C.DATA_VENDA = CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 112)) THEN 1 ELSE 0 END,
							A.DATA_VENDA DESC, A.DATA_DIGITACAO
		END
	
		
		SET NOCOUNT OFF
	
	 	
		-- INICIO - #PRODSHOP-6943#
		-- NFC-e / NF-e
		SELECT	B.CODIGO_FILIAL, TICKET, B.TERMINAL, DATA_VENDA, PRODUTO, ITEM , QTDE ,
				VALOR_ICMS, VALOR_CUPOM, ISNULL(NUMERO_CUPOM_FISCAL,0) AS NUMERO_CUPOM_FISCAL,
				CASE WHEN ISNULL(G.STATUS_NFE,'') = '5' THEN ISNULL(G.NF_NUMERO,'') ELSE '' END AS NF_NUMERO,
				CASE WHEN ISNULL(G.STATUS_NFE,'') = '5' THEN ISNULL(G.SERIE_NF,'') ELSE '' END AS SERIE_NF,
				ISNULL(ENF.NUMERO_MODELO_FISCAL,'') AS NUMERO_MODELO_FISCAL,
				CASE WHEN ISNULL(B.ID_EQUIPAMENTO,'0') = 0 THEN '0' ELSE ISNULL(B.ID_EQUIPAMENTO,'0') END AS ID_EQUIPAMENTO_SAT ,'0' AS ID_EQUIPAMENTO,
				G.CHAVE_NFE AS CHAVE_NFE_ORIGEM --#2#
		FROM	@VENDAORIGEM B
				INNER JOIN	(
							LOJA_NOTA_FISCAL G (NOLOCK)
							INNER JOIN	SERIES_NF SNF (NOLOCK)
									ON	SNF.SERIE_NF = G.SERIE_NF
							INNER JOIN	CTB_ESPECIE_SERIE ENF (NOLOCK)
									ON	ENF.ESPECIE_SERIE = SNF.ESPECIE_SERIE
							)
							ON	B.NUMERO_FISCAL_VENDA = G.NF_NUMERO
								AND B.CODIGO_FILIAL = G.CODIGO_FILIAL
								AND B.SERIE_NF_SAIDA = G.SERIE_NF
								AND G.EMISSAO >= @DATA_LIMITE
		WHERE	G.STATUS_NFE = '5'

		UNION

		-- SAT
		SELECT	B.CODIGO_FILIAL, TICKET, B.TERMINAL, DATA_VENDA, PRODUTO, ITEM , QTDE ,
				VALOR_ICMS, VALOR_CUPOM,ISNULL(NUMERO_CUPOM_FISCAL,0) AS NUMERO_CUPOM_FISCAL,
				--CASE WHEN ISNULL(K.STATUS_CFE,'') = '5' THEN ISNULL(K.CF_NUMERO,'') ELSE '' END AS NF_NUMERO,
				'' AS NF_NUMERO,
				--CASE WHEN ISNULL(K.STATUS_CFE,'') = '5' THEN ISNULL(K.SERIE_NF,'') ELSE '' END AS SERIE_NF,
				''  SERIE_NF,
				ISNULL(ENF.NUMERO_MODELO_FISCAL,'') AS NUMERO_MODELO_FISCAL,
				ISNULL(K.ID_EQUIPAMENTO,'0') AS ID_EQUIPAMENTO_SAT , '0' AS ID_EQUIPAMENTO,
				'' AS CHAVE_NFE_ORIGEM --#2#
		FROM	@VENDAORIGEM B
				INNER JOIN	( 
							LOJA_CF_SAT K (NOLOCK)
							INNER JOIN	SERIES_NF SSAT (NOLOCK)
									ON	SSAT.SERIE_NF = K.SERIE_NF
							INNER JOIN	CTB_ESPECIE_SERIE ENF (NOLOCK)
									ON	ENF.ESPECIE_SERIE = SSAT.ESPECIE_SERIE
							)
							ON	B.CODIGO_FILIAL = K.CODIGO_FILIAL
								AND B.TERMINAL = K.TERMINAL
								AND B.LANCAMENTO_CAIXA = K.LANCAMENTO_CAIXA
								AND B.DATA = K.EMISSAO
								AND K.EMISSAO >= @DATA_LIMITE
		WHERE	K.STATUS_CFE = '5'

		-- PRODSHOP-10042 - In�cio
		UNION		
		
		-- ECF
		SELECT	CODIGO_FILIAL, TICKET, TERMINAL, DATA_VENDA, PRODUTO, ITEM, QTDE,
				VALOR_ICMS, VALOR_CUPOM, ISNULL(NUMERO_CUPOM_FISCAL, 0) AS NUMERO_CUPOM_FISCAL,				
				'' AS NF_NUMERO, ''  SERIE_NF, '2D' AS NUMERO_MODELO_FISCAL,
				'0' AS ID_EQUIPAMENTO_SAT, ID_EQUIPAMENTO AS ID_EQUIPAMENTO,
				'' AS CHAVE_NFE_ORIGEM
		FROM	@VENDAORIGEM B
		WHERE	ISNULL(ID_EQUIPAMENTO,'') <> ''
		-- PRODSHOP-10042 - Fim
		
		-- #PRODSHOP-6943# -- COMENTADO TRECHO ABAIXO E SUBSTITUIDO POR UNION ACIMA

	  --SELECT B.CODIGO_FILIAL, TICKET, B.TERMINAL, DATA_VENDA, PRODUTO, ITEM , QTDE , 
			-- VALOR_ICMS, VALOR_CUPOM, NUMERO_CUPOM_FISCAL, 
			-- CASE WHEN ISNULL(G.STATUS_NFE, ISNULL(K.STATUS_CFE,'')) = 5 THEN ISNULL(G.NF_NUMERO,'') ELSE '' END AS NF_NUMERO,
			-- CASE WHEN ISNULL(G.STATUS_NFE, ISNULL(K.STATUS_CFE,'')) = 5 THEN ISNULL(G.SERIE_NF,'') ELSE '' END AS SERIE_NF,
			-- ISNULL(ENF.NUMERO_MODELO_FISCAL, ISNULL(ESAT.NUMERO_MODELO_FISCAL,'')) AS NUMERO_MODELO_FISCAL,
			-- B.ID_EQUIPAMENTO, K.ID_EQUIPAMENTO AS ID_EQUIPAMENTO_SAT,
			-- G.CHAVE_NFE AS CHAVE_NFE_ORIGEM --#2#
		 --FROM @VENDAORIGEM B
		 --LEFT JOIN ( LOJA_NOTA_FISCAL G (NOLOCK) 
			--		 INNER JOIN SERIES_NF SNF (NOLOCK) 
			--			ON SNF.SERIE_NF = G.SERIE_NF
			--		 INNER JOIN CTB_ESPECIE_SERIE ENF (NOLOCK) 
			--			ON ENF.ESPECIE_SERIE = SNF.ESPECIE_SERIE)
			--ON B.NUMERO_FISCAL_VENDA = G.NF_NUMERO
		 --  AND B.CODIGO_FILIAL = G.CODIGO_FILIAL 
		 --  AND B.SERIE_NF_SAIDA = G.SERIE_NF
		 --  AND G.EMISSAO >= @DATA_LIMITE
		 --  AND G.STATUS_NFE = 5 
		 --LEFT JOIN ( LOJA_CF_SAT K (NOLOCK) 
			--		 INNER JOIN SERIES_NF SSAT (NOLOCK) 
			--			ON SSAT.SERIE_NF = K.SERIE_NF
			--		 INNER JOIN CTB_ESPECIE_SERIE ESAT (NOLOCK) 
			--			ON ESAT.ESPECIE_SERIE = SSAT.ESPECIE_SERIE)
			--ON B.CODIGO_FILIAL = K.CODIGO_FILIAL 
		 --  AND B.TERMINAL = K.TERMINAL 
		 --  AND B.LANCAMENTO_CAIXA = K.LANCAMENTO_CAIXA	
		 --  AND B.DATA = K.EMISSAO 
		 --  AND K.EMISSAO >= @DATA_LIMITE 
		 --  AND K.STATUS_CFE = 5
	--#1#
	--FIM - #PRODSHOP-6943#
	
   END