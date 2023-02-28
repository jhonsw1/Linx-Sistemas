CREATE  VIEW [dbo].[W_LOJA_RESERVA_VERTICAL] AS
SELECT A.FILIAL,A.NUMERO_RESERVA ,A.PRODUTO,A.COR_PRODUTO,C.ORDEM AS ORDEM_TAMANHO,C.GRADE,C.TAMANHO,  ISNULL(D.CODIGO_BARRA,'') AS CODIGO_BARRA, A.PRECO1, A.PRECO2,
		RESERVA = CASE C.ORDEM
			WHEN 1  THEN EN1	WHEN 2  THEN EN2	WHEN 3  THEN EN3	WHEN 4  THEN EN4
			WHEN 5  THEN EN5	WHEN 6  THEN EN6	WHEN 7  THEN EN7	WHEN 8  THEN EN8
			WHEN 9  THEN EN9	WHEN 10 THEN EN10	WHEN 11 THEN EN11	WHEN 12 THEN EN12
			WHEN 13 THEN EN13	WHEN 14 THEN EN14	WHEN 15 THEN EN15	WHEN 16 THEN EN16
			WHEN 17 THEN EN17	WHEN 18 THEN EN18	WHEN 19 THEN EN19	WHEN 20 THEN EN20
			WHEN 21 THEN EN21	WHEN 22 THEN EN22	WHEN 23 THEN EN23	WHEN 24 THEN EN24
			WHEN 25 THEN EN25	WHEN 26 THEN EN26	WHEN 27 THEN EN27	WHEN 28 THEN EN28
			WHEN 29 THEN EN29	WHEN 30 THEN EN30	WHEN 31 THEN EN31	WHEN 32 THEN EN32
			WHEN 33 THEN EN33	WHEN 34 THEN EN34	WHEN 35 THEN EN35	WHEN 36 THEN EN36
			WHEN 37 THEN EN37	WHEN 38 THEN EN38	WHEN 39 THEN EN39	WHEN 40 THEN EN40
			WHEN 41 THEN EN41	WHEN 42 THEN EN42	WHEN 43 THEN EN43	WHEN 44 THEN EN44
			WHEN 45 THEN EN45	WHEN 46 THEN EN46	WHEN 47 THEN EN47	WHEN 48 THEN EN48  ELSE 0 END
	FROM 	LOJA_RESERVA_PRODUTO A
		JOIN PRODUTOS B ON B.PRODUTO=A.PRODUTO
		JOIN (
	SELECT GRADE, CASE WHEN TAMANHO_1 IS NULL OR TAMANHO_1 = '' THEN '---' ELSE TAMANHO_1 END AS TAMANHO, 1 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=1
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_2 IS NULL OR TAMANHO_2 = '' THEN '---' ELSE TAMANHO_2 END AS TAMANHO, 2 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=2
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_3 IS NULL OR TAMANHO_3 = '' THEN '---' ELSE TAMANHO_3 END AS TAMANHO, 3 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=3
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_4 IS NULL OR TAMANHO_4 = '' THEN '---' ELSE TAMANHO_4 END AS TAMANHO, 4 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=4
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_5 IS NULL OR TAMANHO_5 = '' THEN '---' ELSE TAMANHO_5 END AS TAMANHO, 5 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=5
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_6 IS NULL OR TAMANHO_6 = '' THEN '---' ELSE TAMANHO_6 END AS TAMANHO, 6 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=6
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_7 IS NULL OR TAMANHO_7 = '' THEN '---' ELSE TAMANHO_7 END AS TAMANHO, 7 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=7
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_8 IS NULL OR TAMANHO_8 = '' THEN '---' ELSE TAMANHO_8 END AS TAMANHO, 8 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=8
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_9 IS NULL OR TAMANHO_9 = '' THEN '---' ELSE TAMANHO_9 END AS TAMANHO, 9 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=9
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_10 IS NULL OR TAMANHO_10 = '' THEN '---' ELSE TAMANHO_10 END AS TAMANHO, 10 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=10
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_11 IS NULL OR TAMANHO_11 = '' THEN '---' ELSE TAMANHO_11 END AS TAMANHO, 11 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=11
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_12 IS NULL OR TAMANHO_12 = '' THEN '---' ELSE TAMANHO_12 END AS TAMANHO, 12 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=12
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_13 IS NULL OR TAMANHO_13 = '' THEN '---' ELSE TAMANHO_13 END AS TAMANHO, 13 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=13
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_14 IS NULL OR TAMANHO_14 = '' THEN '---' ELSE TAMANHO_14 END AS TAMANHO, 14 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=14
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_15 IS NULL OR TAMANHO_15 = '' THEN '---' ELSE TAMANHO_15 END AS TAMANHO, 15 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=15
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_16 IS NULL OR TAMANHO_16 = '' THEN '---' ELSE TAMANHO_16 END AS TAMANHO, 16 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=16
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_17 IS NULL OR TAMANHO_17 = '' THEN '---' ELSE TAMANHO_17 END AS TAMANHO, 17 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=17
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_18 IS NULL OR TAMANHO_18 = '' THEN '---' ELSE TAMANHO_18 END AS TAMANHO, 18 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=18
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_19 IS NULL OR TAMANHO_19 = '' THEN '---' ELSE TAMANHO_19 END AS TAMANHO, 19 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=19
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_20 IS NULL OR TAMANHO_20 = '' THEN '---' ELSE TAMANHO_20 END AS TAMANHO, 20 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=20
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_21 IS NULL OR TAMANHO_21 = '' THEN '---' ELSE TAMANHO_21 END AS TAMANHO, 21 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=21
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_22 IS NULL OR TAMANHO_22 = '' THEN '---' ELSE TAMANHO_22 END AS TAMANHO, 22 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=22
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_23 IS NULL OR TAMANHO_23 = '' THEN '---' ELSE TAMANHO_23 END AS TAMANHO, 23 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=23
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_24 IS NULL OR TAMANHO_24 = '' THEN '---' ELSE TAMANHO_24 END AS TAMANHO, 24 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=24
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_25 IS NULL OR TAMANHO_25 = '' THEN '---' ELSE TAMANHO_25 END AS TAMANHO, 25 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=25
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_26 IS NULL OR TAMANHO_26 = '' THEN '---' ELSE TAMANHO_26 END AS TAMANHO, 26 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=26
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_27 IS NULL OR TAMANHO_27 = '' THEN '---' ELSE TAMANHO_27 END AS TAMANHO, 27 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=27
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_28 IS NULL OR TAMANHO_28 = '' THEN '---' ELSE TAMANHO_28 END AS TAMANHO, 28 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=28
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_29 IS NULL OR TAMANHO_29 = '' THEN '---' ELSE TAMANHO_29 END AS TAMANHO, 29 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=29
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_30 IS NULL OR TAMANHO_30 = '' THEN '---' ELSE TAMANHO_30 END AS TAMANHO, 30 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=30
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_31 IS NULL OR TAMANHO_31 = '' THEN '---' ELSE TAMANHO_31 END AS TAMANHO, 31 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=31
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_32 IS NULL OR TAMANHO_32 = '' THEN '---' ELSE TAMANHO_32 END AS TAMANHO, 32 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=32
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_33 IS NULL OR TAMANHO_33 = '' THEN '---' ELSE TAMANHO_33 END AS TAMANHO, 33 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=33
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_34 IS NULL OR TAMANHO_34 = '' THEN '---' ELSE TAMANHO_34 END AS TAMANHO, 34 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=34
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_35 IS NULL OR TAMANHO_35 = '' THEN '---' ELSE TAMANHO_35 END AS TAMANHO, 35 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=35
	UNION ALL
	SELECT GRADE, CASE WHEN TAMANHO_36 IS NULL OR TAMANHO_36 = '' THEN '---' ELSE TAMANHO_36 END AS TAMANHO, 36 AS ORDEM FROM   PRODUTOS_TAMANHOS  WHERE NUMERO_TAMANHOS>=36) AS C ON C.GRADE=B.GRADE
	INNER JOIN (SELECT PRODUTO,COR_PRODUTO,GRADE,MAX(CODIGO_BARRA) AS CODIGO_BARRA  
	FROM PRODUTOS_BARRA  WHERE CODIGO_BARRA IS NOT NULL
GROUP BY PRODUTO,COR_PRODUTO,GRADE) AS D 	ON A.PRODUTO = D.PRODUTO AND A.COR_PRODUTO =D.COR_PRODUTO AND C.TAMANHO =D.GRADE
	WHERE    (EN1 > 0 OR  EN2	> 0 OR  EN3		> 0 OR EN4 > 0 OR
			  EN5 > 0 OR  EN6	> 0 OR  EN7		> 0 OR EN8 > 0 OR
			  EN9 > 0 OR  EN10	> 0 OR  EN11	> 0 OR EN12> 0 OR
			  EN13> 0 OR  EN14	> 0 OR  EN15	> 0 OR EN16> 0 OR
			  EN17> 0 OR  EN18	> 0 OR  EN19	> 0 OR EN20> 0 OR
			  EN21> 0 OR  EN22	> 0 OR  EN23	> 0 OR EN24> 0 OR
			  EN25> 0 OR  EN26	> 0 OR  EN27	> 0 OR EN28> 0 OR
			  EN29> 0 OR  EN30	> 0 OR  EN31	> 0 OR EN32> 0 OR
			  EN33> 0 OR  EN34	> 0 OR  EN35	> 0 OR EN36> 0 )
			  AND C.TAMANHO <> '---' 
