CREATE FUNCTION [DBO].[FN_NOTAS_REFERENCIADAS]  (@NOTAFISCAL CHAR(15), @SERIENOTA CHAR(6), @CODIGO_FILIAL CHAR(6))

RETURNS @LOJA_VENDA_ORIGEM TABLE
(
	CHAVE_NFE				VARCHAR(44),
	CHAVEACESSO				varchar(44), 
	FILIAL					VARCHAR(40),              
	NF						CHAR(15),
	SERIE					CHAR(6),
	ORIGEM_ENTRADA_SAIDA	VARCHAR(1)
)

AS
BEGIN 

--- POSSP-5095 - GILVANO SANTOS - #8# - 21/12/2021 - LinxPOS - Tratamento quando não conseguir referenciar Troca (Performance) 



DECLARE @CODIGO_FILIAL_FILTRO CHAR(6), @NUMERO_FISCAL_VINCULADA CHAR(15), @SERIE_NF_VINCULADA CHAR(6),@TERMINAL CHAR(3), @LANCAMENTO_CAIXA CHAR(7)
		SELECT	@CODIGO_FILIAL_FILTRO = CODIGO_FILIAL,
				@NUMERO_FISCAL_VINCULADA = NUMERO_FISCAL_VINCULADA,
				@SERIE_NF_VINCULADA = SERIE_NF_VINCULADA, 
				@TERMINAL= TERMINAL,
				@LANCAMENTO_CAIXA = LANCAMENTO_CAIXA
		FROM	LOJA_VENDA_PGTO 
		WHERE	CODIGO_FILIAL = @CODIGO_FILIAL AND
				NUMERO_FISCAL_VINCULADA = @NOTAFISCAL AND
				SERIE_NF_VINCULADA = @SERIENOTA


INSERT INTO @LOJA_VENDA_ORIGEM(CHAVE_NFE, CHAVEACESSO, FILIAL, NF, SERIE, ORIGEM_ENTRADA_SAIDA)
SELECT CHAVE_NFE,
         CHAVEACESSO,
         FILIAL,
         NF,
         SERIE,
         ORIGEM_ENTRADA_SAIDA
  FROM   (
         -- NOTA COMPLEMENTAR DE SAIDA
         SELECT DISTINCT CHAVE_NFE = CASE
                                       WHEN D.CHAVE_NFE IS NULL THEN NULL
                                       ELSE D.CHAVE_NFE
                                     END,
                         CHAVEACESSO = (SELECT TOP 1 Substring(M.COD_MUNICIPIO_IBGE, 1, 2)
                                        FROM   LCF_LX_MUNICIPIO M (NOLOCK)
                                               INNER JOIN LCF_LX_UF U (NOLOCK)
                                                       ON U.ID_UF = M.ID_UF
                                        WHERE  U.UF = F.UF
                                               AND M.DESC_MUNICIPIO = DBO.Fx_replace_caracter_especial_nfe(DEFAULT, F.CIDADE))
                                       + Substring(CONVERT(CHAR(10), B.EMISSAO, 112), 3, 4)
                                       + Rtrim(F.CGC_CPF)
                                       + (SELECT RIGHT('0'+Rtrim(ES.NUMERO_MODELO_FISCAL), 2)
                                                 + CASE WHEN SN.COD_SERIE_SINTEGRA IS NOT NULL THEN RIGHT('00'+Rtrim(CASE WHEN SN.COD_SERIE_SINTEGRA = 'U' OR SN.COD_SERIE_SINTEGRA = 'UN' THEN '0' ELSE SN.COD_SERIE_SINTEGRA END), 3) ELSE RIGHT('00'+Rtrim(CASE WHEN SN.SERIE_NF = 'U' OR SN.SERIE_NF = 'UN' THEN '0' ELSE SN.SERIE_NF END), 3) END
                                          FROM   SERIES_NF SN (NOLOCK)
                                                 INNER JOIN CTB_ESPECIE_SERIE ES (NOLOCK)
                                                         ON SN.ESPECIE_SERIE = ES.ESPECIE_SERIE
                                          WHERE  SERIE_NF = B.SERIE_NF)
                                       + RIGHT('00000000'+Rtrim(B.NF_NUMERO_REFERENCIADA), 9),
                         E.FILIAL,
                         C.NF_NUMERO AS NF, -- #4#
						 C.SERIE_NF  AS SERIE, -- #4#
                         'S'         AS ORIGEM_ENTRADA_SAIDA
         FROM   LOJA_NOTA_FISCAL_ITEM A (NOLOCK)
                LEFT JOIN LOJA_NOTA_FISCAL B (NOLOCK)
                       ON B.NF_NUMERO = A.NF_NUMERO
                          AND B.SERIE_NF = A.SERIE_NF
                          AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
                LEFT JOIN LOJA_NOTA_FISCAL C (NOLOCK)
                       ON C.NF_NUMERO = A.NF_NUMERO
                          AND C.SERIE_NF = A.SERIE_NF
                          AND C.CODIGO_FILIAL = A.CODIGO_FILIAL
                LEFT JOIN LOJA_NOTA_FISCAL D
                       ON D.NF_NUMERO = C.NF_NUMERO_REFERENCIADA
                          AND D.SERIE_NF = C.SERIE_NF_REFERENCIADA
                          AND D.CODIGO_FILIAL = C.CODIGO_FILIAL
                LEFT JOIN LOJAS_VAREJO E
                       ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
                LEFT JOIN CADASTRO_CLI_FOR F
                       ON E.FILIAL = F.NOME_CLIFOR
         WHERE  A.NF_NUMERO IS NOT NULL
                AND C.TIPO_ORIGEM = 15
                AND C.RECEBIMENTO = 0
         UNION ALL
         -- NOTA COMPLEMENTAR DE ENTRADA
         SELECT DISTINCT CHAVE_NFE = CASE
                                       WHEN D.CHAVE_NFE IS NULL THEN NULL
                                       ELSE D.CHAVE_NFE
                                     END,
                         CHAVEACESSO = (SELECT TOP 1 Substring(M.COD_MUNICIPIO_IBGE, 1, 2)
                                        FROM   LCF_LX_MUNICIPIO M (NOLOCK)
                                               INNER JOIN LCF_LX_UF U (NOLOCK)
                                                       ON U.ID_UF = M.ID_UF
                                        WHERE  U.UF = F.UF
                                               AND M.DESC_MUNICIPIO = DBO.Fx_replace_caracter_especial_nfe(DEFAULT, F.CIDADE))
                                       + Substring(CONVERT(CHAR(10), B.EMISSAO, 112), 3, 4)
                                       + Rtrim(F.CGC_CPF)
                                       + (SELECT RIGHT('0'+Rtrim(ES.NUMERO_MODELO_FISCAL), 2)
                                                 + CASE WHEN SN.COD_SERIE_SINTEGRA IS NOT NULL THEN RIGHT('00'+Rtrim(CASE WHEN SN.COD_SERIE_SINTEGRA = 'U' OR SN.COD_SERIE_SINTEGRA = 'UN' THEN '0' ELSE SN.COD_SERIE_SINTEGRA END), 3) ELSE RIGHT('00'+Rtrim(CASE WHEN SN.SERIE_NF = 'U' OR SN.SERIE_NF = 'UN' THEN '0' ELSE SN.SERIE_NF END), 3) END
                                          FROM   SERIES_NF SN (NOLOCK)
                                                 INNER JOIN CTB_ESPECIE_SERIE ES (NOLOCK)
                                                         ON SN.ESPECIE_SERIE = ES.ESPECIE_SERIE
                                          WHERE  SERIE_NF = B.SERIE_NF)
                                       + RIGHT('00000000'+Rtrim(B.NF_NUMERO), 9),
                         Isnull(CONVERT(VARCHAR(40), H.NOME_CLIFOR), G.CLIENTE_VAREJO) AS FILIAL,
                         A.NF_NUMERO                                                   AS NF, -- #4#
						 A.SERIE_NF                                                    AS SERIE, -- #4#
                         'E'                                                           AS ORIGEM_ENTRADA_SAIDA
         FROM   LOJA_NOTA_FISCAL_ITEM A (NOLOCK)
                LEFT JOIN LOJA_NOTA_FISCAL B (NOLOCK)
                       ON B.NF_NUMERO = A.NF_NUMERO
                          AND B.SERIE_NF = A.SERIE_NF
                          AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
                LEFT JOIN LOJA_NOTA_FISCAL C (NOLOCK)
                       ON C.NF_NUMERO = A.NF_NUMERO
                          AND C.SERIE_NF = A.SERIE_NF
                          AND C.CODIGO_FILIAL = A.CODIGO_FILIAL
                LEFT JOIN LOJA_NOTA_FISCAL D
                       ON D.NF_NUMERO = C.NF_NUMERO_REFERENCIADA
                          AND D.SERIE_NF = C.SERIE_NF_REFERENCIADA
                          AND D.CODIGO_FILIAL = C.CODIGO_FILIAL
                LEFT JOIN LOJAS_VAREJO E
                       ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
                LEFT JOIN CADASTRO_CLI_FOR F
                       ON E.FILIAL = F.NOME_CLIFOR
                LEFT JOIN CLIENTES_VAREJO G (NOLOCK)
                       ON B.CODIGO_CLIENTE = G.CODIGO_CLIENTE
                LEFT JOIN CADASTRO_CLI_FOR H (NOLOCK)
                       ON B.COD_CLIFOR = H.COD_CLIFOR
         WHERE  A.NF_NUMERO IS NOT NULL
                AND C.TIPO_ORIGEM = 15
                AND C.RECEBIMENTO = 1 
		 --#3# - INICIO
		 UNION ALL 
		 -- NOTA DE DEVOLUÇÃO POR FORNECEDOR/TRÂNSITO
		  SELECT DISTINCT CHAVE_NFE = CASE
						  WHEN A.CHAVE_NFE_REF IS NULL THEN NULL
							  ELSE A.CHAVE_NFE_REF
						  END,
				CHAVEACESSO = CHAVEACESSO_REF,
				E.FILIAL    AS FILIAL,
				B.NF_NUMERO AS NF, -- #4#
				B.SERIE_NF  AS SERIE, -- #4#
				'S'         AS ORIGEM_ENTRADA_SAIDA
		 FROM   LOJA_NOTA_FISCAL_REFERENCIADA_ITEM A (NOLOCK)
			   INNER JOIN LOJA_NOTA_FISCAL B (NOLOCK)
					   ON B.NF_NUMERO = A.NF_NUMERO
						  AND B.SERIE_NF = A.SERIE_NF
						  AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
			   LEFT JOIN LOJAS_VAREJO E
					  ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
			   LEFT JOIN CADASTRO_CLI_FOR F
					  ON E.FILIAL = F.NOME_CLIFOR
		 WHERE  A.TIPO_ORIGEM = 3 
		 --#3# - FIM
         -- #2# - INÍCIO
         UNION ALL
         -- NOTA DE DEVOLUÇÃO PARA RESERVAS/CONSIGNAÇÕES
		 SELECT DISTINCT CHAVE_NFE = CASE
							  WHEN A.CHAVE_NFE_REF IS NULL THEN NULL
							  ELSE A.CHAVE_NFE_REF
							END,
				CHAVEACESSO = CHAVEACESSO_REF,
				E.FILIAL    AS FILIAL,
				B.NF_NUMERO AS NF, -- #4#
				B.SERIE_NF  AS SERIE, -- #4#
				'E'         AS ORIGEM_ENTRADA_SAIDA
		 FROM   LOJA_NOTA_FISCAL_REFERENCIADA_ITEM A (NOLOCK) -- #5#
			   INNER JOIN LOJA_NOTA_FISCAL B (NOLOCK)
					   ON B.NF_NUMERO = A.NF_NUMERO
						  AND B.SERIE_NF = A.SERIE_NF
						  AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
			   LEFT JOIN LOJAS_VAREJO E
					  ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
			   LEFT JOIN CADASTRO_CLI_FOR F
					  ON E.FILIAL = F.NOME_CLIFOR
		 WHERE  A.TIPO_ORIGEM = 9 
         -- #2# - FIM
		 UNION ALL
		 --#6# - INICIO - NOTAS DE DEVOLUÇAÕ (CONSUMÍVEIS) REFERÊNCIA MANUAL VIA TELA. 
		  SELECT DISTINCT CHAVE_NFE = CASE
							  WHEN A.CHAVE_NFE_REF IS NULL THEN NULL
							  ELSE A.CHAVE_NFE_REF
							END,
				CHAVEACESSO = CHAVEACESSO_REF,
				E.FILIAL    AS FILIAL,
				B.NF_NUMERO AS NF, -- #4#
				B.SERIE_NF  AS SERIE, -- #4#
				'S'         AS ORIGEM_ENTRADA_SAIDA
		 FROM   LOJA_NOTA_FISCAL_REFERENCIADA_ITEM A (NOLOCK) -- #5#
			   INNER JOIN LOJA_NOTA_FISCAL B (NOLOCK)
					   ON B.NF_NUMERO = A.NF_NUMERO
						  AND B.SERIE_NF = A.SERIE_NF
						  AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
			   LEFT JOIN LOJAS_VAREJO E
					  ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
			   LEFT JOIN CADASTRO_CLI_FOR F
					  ON E.FILIAL = F.NOME_CLIFOR
		 WHERE  A.TIPO_ORIGEM = 0
		 AND A.CODIGO_FILIAL = @CODIGO_FILIAL -- #8#
		 AND A.NF_NUMERO = @NOTAFISCAL -- #8#
		 AND A.SERIE_NF = @SERIENOTA -- #8#

		 union all
		 SELECT DISTINCT CHAVE_NFE = CASE
							  WHEN A.CHAVE_NFE_REF IS NULL THEN NULL
							  ELSE A.CHAVE_NFE_REF
							END,
				CHAVEACESSO = CHAVEACESSO_REF,
				E.FILIAL    AS FILIAL,
				B.NF_NUMERO AS NF, -- #4#
				B.SERIE_NF  AS SERIE, -- #4#
				'E'         AS ORIGEM_ENTRADA_SAIDA
		 FROM   LOJA_NOTA_FISCAL_REFERENCIADA_ITEM A (NOLOCK) -- #5#
			   INNER JOIN LOJA_NOTA_FISCAL B (NOLOCK)
					   ON B.NF_NUMERO = A.NF_NUMERO
						  AND B.SERIE_NF = A.SERIE_NF
						  AND B.CODIGO_FILIAL = A.CODIGO_FILIAL
			   LEFT JOIN LOJAS_VAREJO E
					  ON B.CODIGO_FILIAL = E.CODIGO_FILIAL
			   LEFT JOIN CADASTRO_CLI_FOR F
					  ON E.FILIAL = F.NOME_CLIFOR
		 WHERE  A.TIPO_ORIGEM = 0
		 AND A.CODIGO_FILIAL = @CODIGO_FILIAL -- #8#
		 AND A.NF_NUMERO = @NOTAFISCAL -- #8#
		 AND A.SERIE_NF = @SERIENOTA -- #8#

		 --#6# - FIM
		 --#7# INICIO
		 UNION ALL
		 SELECT ISNULL(C.CHAVE_CFE, D.CHAVE_NFE) AS CHAVE_NFE, 
			   NULL AS CHAVEACESSO,
			   E.FILIAL,
			   B.NF_NUMERO AS NF, 
			   B.SERIE_NF  AS SERIE,
			   'S'         AS ORIGEM_ENTRADA_SAIDA
		 FROM LOJA_VENDA_PGTO A
		 INNER JOIN LOJA_NOTA_FISCAL B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL 
			AND B.SERIE_NF = A.SERIE_NF_VINCULADA AND B.NF_NUMERO = A.NUMERO_FISCAL_VINCULADA
		 LEFT JOIN LOJA_CF_SAT C ON A.CODIGO_FILIAL = C.CODIGO_FILIAL AND A.LANCAMENTO_CAIXA = C.LANCAMENTO_CAIXA 
			AND A.TERMINAL = C.TERMINAL AND A.GUID_VENDA_SAT = C.GUID_VENDA_SAT
		 LEFT JOIN LOJA_NOTA_FISCAL D ON A.CODIGO_FILIAL = D.CODIGO_FILIAL 
			AND D.SERIE_NF = A.SERIE_NF_SAIDA AND D.NF_NUMERO = A.NUMERO_FISCAL_VENDA
		 INNER JOIN LOJAS_VAREJO E ON A.CODIGO_FILIAL = E.CODIGO_FILIAL 
		 WHERE A.CODIGO_FILIAL = @CODIGO_FILIAL_FILTRO AND 
			   A.NUMERO_FISCAL_VINCULADA = @NUMERO_FISCAL_VINCULADA AND 
			   A.SERIE_NF_VINCULADA = @SERIE_NF_VINCULADA	AND 
			   A.TERMINAL = @TERMINAL AND 
			   A.LANCAMENTO_CAIXA = @LANCAMENTO_CAIXA AND 
			B.TIPO_ORIGEM = 1 AND B.RECEBIMENTO = 0 AND (C.STATUS_CFE = 5 OR D.STATUS_NFE = 5)
		 --#7# FIM
         ) AS NOTA_RELACIONADA
	RETURN 
END


