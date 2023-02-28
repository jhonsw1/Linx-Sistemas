if not exists (SELECT
		*
	FROM sys.objects
	WHERE name = 'FC_HR_PROMOCAO_PRE')
EXEC dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[FC_HR_PROMOCAO_PRE] (@CODIGOFILIAL VARCHAR(6) = NULL, @DATAPEDIDO DATETIME, @PEDIDO INT ,@PROMOCAO VARCHAR(50) =''QUANTO MAIS BASICO MELHOR'')       
RETURNS @PROMOCAO_DESCONTO TABLE (      
  PROMOCAO varchar(30),      
  DATA_INICIO datetime,      
  DATA_FIM datetime,      
  DESCONTOPROM numeric(14, 2),      
  GERAPEDIDO int,      
  MESG varchar(150)      
)      
AS      
BEGIN      
  INSERT INTO @PROMOCAO_DESCONTO      
    SELECT      
      PROMOCAO,      
      MIN(DATA_INICIO) AS DATA_INICIO,      
      MAX(DATA_FIM) AS DATA_FIM,      
      SUM(DESCONTOPROM) AS DESCONTOPROM,      
      MAX(GERAPEDIDO) AS GERAPEDIDO,      
      ISNULL(RTRIM(MAX(COMBOA)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBOA)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBOB)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBOB)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBOC)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBOC)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBOX)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBOX)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO0)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO0)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO1)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO1)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO2)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO2)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO3)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO3)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO4)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO4)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO5)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO5)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO6)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO6)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO7)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO7)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO8)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO8)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO9)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO9)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO10)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO10)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO11)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO11)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO12)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO12)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO13)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO13)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO14)), '''') + CASE      
        WHEN ISNULL(RTRIM(MAX(COMBO14)), '''') != '''' THEN CHAR(10) + CHAR(13)      
        ELSE ''''      
      END +      
      ISNULL(RTRIM(MAX(COMBO15)) + CHAR(10) + CHAR(13), '''') AS MSG      
      
    FROM (      
    -- COMBO FEMININO 1 ID_PROMOCAO = 10                            
SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBOA))      
        ELSE ''''      
      END AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 29.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBOA =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 1 Feminino desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 29.99)))))      
                ELSE '' ''      
              END      
      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 10      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    UNION ALL      
      
    -- COMBO FEMININO 2 ID_PROMOCAO = 11                                                            
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBOB))      
    ELSE ''''      
      END AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 29.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBOB =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 2 Feminino desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 29.99)))))      
                ELSE '' ''      
              END      
      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 11      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
    -- COMBO FEMININO 3 ID_PROMOCAO = 12                                                                                
    UNION ALL      
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBOC))      
        ELSE ''''      
      END AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 39.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBOC =      
              CASE      
           WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 3 Feminino desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 39.99)))))      
                ELSE '' ''      
              END      
      
      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 12      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
    -- COMBO MASCULINO 1 -- ID_PROMOCAO = 13                            
    UNION ALL      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBOX))      
        ELSE ''''      
      END AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 29.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBOX =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 1 Masculino  desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 29.99)))))      
                ELSE '' ''      
              END      
      
      
      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 13      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
      
    UNION ALL      
    -- COMBO MASCULINO 2 -- ID_PROMOCAO = 14                            
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO0))      
        ELSE ''''      
      END AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 24.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO0 =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 2 Masculino  desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 24.99)))))      
                ELSE '' ''      
              END      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 14      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    UNION ALL      
      
      
    -- COMBO MASCULINO 3 ID_PROMOCAO = 15                            
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO1))      
        ELSE ''''      
      END AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 39.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO1 =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo 3 Masculino  desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 39.99)))))      
                ELSE '' ''      
              END      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 15      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
    UNION ALL      
      
    -- COMBO Polo Masculina ID_PROMOCAO = 16                            
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170814''),      
      DATA_FIM = CONVERT(datetime, ''20180815''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CASE      
      WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO2))      
        ELSE ''''      
      END AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 2 THEN SUM(VALOR) - (SUM(QTDE) * 49.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO2 =      
              CASE      
                WHEN SUM(QTDE) >= 2 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Polo Masculina  desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 49.99)))))      
                ELSE '' ''      
              END      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 16      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170814''      
    AND B.DATA <= ''20180815''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
    UNION ALL      
      
    -- Combo Basico Kids                       
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20170921''),      
      DATA_FIM = CONVERT(datetime, ''20171227''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO2))      
        ELSE ''''      
      END AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 24.99)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO2 =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo Basico Kids desc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 24.99)))))      
                ELSE '' ''      
              END      
      
      
      
      
      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 18      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20170921''      
    AND B.DATA <= ''20171227''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
      
    -- Mix de Verão                  
    UNION ALL      
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20171030''),      
      DATA_FIM = CONVERT(datetime, ''20171231''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,     
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO3))      
        ELSE ''''      
      END AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 2 THEN CONVERT(int, SUM(qtde) / 2) * 20.00      
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO3 =      
              CASE      
                WHEN SUM(QTDE) >= 2 THEN ''R$ '' + CONVERT(varchar(8), CONVERT(int, CONVERT(int, SUM(qtde) / 2) * 20.00)) + '' Combo Mix de Verão''      
                ELSE '' ''      
              END      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 24      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20171030''      
    AND B.DATA <= ''20171231''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
    UNION ALL      
      
    -- Promoçõe Nova Moda        
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20171208''),      
      DATA_FIM = CONVERT(datetime, ''20171227''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO4))      
        ELSE ''''      
      END AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
    CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN CONVERT(int, QTDE / 3) > 0 THEN VALOR - (CONVERT(int, QTDE / 3) * 99.99) -      
          ((QTDE % 3) * preco_liquido)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = DESCONTO_ITEM,      
      COMBO4 = ''Qtde(s) Combo Moda feminino: '' + CONVERT(varchar(10), CONVERT(int, QTDE / 3))      
    FROM (SELECT      
      MIN(PRECO_LIQUIDO-DESCONTO_ITEM) AS preco_liquido,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO  A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO_PRODUTO B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND A.PEDIDO = B.PEDIDO      
    LEFT JOIN HR_LOJA_PROMOCAO_LOJAS      
      ON HR_LOJA_PROMOCAO_LOJAS.ID_PROMOCAO = 29      
      AND HR_LOJA_PROMOCAO_LOJAS.CODIGO_FILIAL = @CODIGOFILIAL      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO =      
                        CASE      
                          WHEN HR_LOJA_PROMOCAO_LOJAS.CODIGO_FILIAL IS NOT NULL THEN 29      
                          ELSE 27      
                        END      
      AND C.PRODUTO = B.PRODUTO      
      AND C.COR_PRODUTO = B.COR_PRODUTO      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND A.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND A.DATA >= ''20171208''      
    AND A.DATA <= ''20171227''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    AND NOT EXISTS (SELECT      
      *      
    FROM CLIENTES_VAREJO C (NOLOCK)      
    WHERE C.CODIGO_CLIENTE = A.CODIGO_CLIENTE      
    AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
      
    UNION ALL      
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20171208''),      
      DATA_FIM = CONVERT(datetime, ''20171227''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO5))      
        ELSE ''''      
      END AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN CONVERT(int, QTDE / 3) > 0 THEN VALOR - (CONVERT(int, QTDE / 3) * 99.99) -      
          ((QTDE % 3) * preco_liquido)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = DESCONTO_ITEM,      
      COMBO5 = ''Qtde(s) Combo Moda Masculino: '' + CONVERT(varchar(10), CONVERT(int, QTDE / 3))      
    FROM (SELECT      
      MIN(PRECO_LIQUIDO-DESCONTO_ITEM) AS preco_liquido,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO  A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO_PRODUTO B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 28      
      AND C.PRODUTO = B.PRODUTO      
      AND C.COR_PRODUTO = B.COR_PRODUTO      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND A.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND A.DATA >= ''20171208''      
    AND A.DATA <= ''20171227''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    AND NOT EXISTS (SELECT      
      *      
    FROM CLIENTES_VAREJO C (NOLOCK)      
    WHERE C.CODIGO_CLIENTE = A.CODIGO_CLIENTE      
    AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
          
          
    UNION ALL      
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20171212''),      
      DATA_FIM = CONVERT(datetime, ''20171227''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CONVERT(varchar(50), '''') AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO5))      
        ELSE ''''      
      END AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN CONVERT(int, QTDE / 3) > 0 THEN VALOR - (CONVERT(int, QTDE / 3) * 149.97) -      
          ((QTDE % 3) * preco_liquido)      
        ELSE 0      
      END),      
      DESCONTO_ITEM = DESCONTO_ITEM,      
      COMBO5 = ''Qtde(s) Combo Blusa Feminina Moda: '' + CONVERT(varchar(10), CONVERT(int, QTDE / 3))      
    FROM (SELECT      
      MIN(PRECO_LIQUIDO-DESCONTO_ITEM) AS preco_liquido,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR      
    FROM LOJA_PEDIDO  A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO_PRODUTO B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM      
      AND A.PEDIDO = B.PEDIDO      
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 30      
      AND C.PRODUTO = B.PRODUTO      
      AND C.COR_PRODUTO = B.COR_PRODUTO      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND A.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND A.DATA >= ''20171212''      
    AND A.DATA <= ''20171227''      
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    AND NOT EXISTS (SELECT      
      *      
    FROM CLIENTES_VAREJO C (NOLOCK)      
    WHERE C.CODIGO_CLIENTE = A.CODIGO_CLIENTE      
    AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
   HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
      
     UNION ALL          
          
    SELECT          
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),          
      DATA_INICIO = CONVERT(datetime, ''20171215''),          
      DATA_FIM = CONVERT(datetime, ''20180109''),          
      DESCONTOPROM =          
                    CASE          
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)          
                      ELSE 0          
                    END,          
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,          
      0 AS GERAPEDIDO,          
      CONVERT(varchar(50), '''') AS COMBOA,          
      CONVERT(varchar(50), '''') AS COMBOB,          
      CONVERT(varchar(50), '''') AS COMBOC,          
      CONVERT(varchar(50), '''') AS COMBOX,          
      CONVERT(varchar(50), '''') AS COMBO0,          
      CONVERT(varchar(50), '''') AS COMBO1,          
      CONVERT(varchar(50), '''') AS COMBO2,          
      CONVERT(varchar(50), '''') AS COMBO3,          
      CONVERT(varchar(50), '''') AS COMBO4,          
      CASE          
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO5))          
        ELSE ''''          
      END AS COMBO5,          
      CONVERT(varchar(50), '''') AS COMBO6,          
      CONVERT(varchar(50), '''') AS COMBO7,          
      CONVERT(varchar(50), '''') AS COMBO8,          
      CONVERT(varchar(50), '''') AS COMBO9,          
      CONVERT(varchar(50), '''') AS COMBO10,          
      CONVERT(varchar(50), '''') AS COMBO11,          
      CONVERT(varchar(50), '''') AS COMBO12,          
      CONVERT(varchar(50), '''') AS COMBO13,          
      CONVERT(varchar(50), '''') AS COMBO14,          
      CONVERT(varchar(50), '''') AS COMBO15          
    FROM (SELECT          
      DESCONTOPROM = (CASE          
        WHEN CONVERT(int, QTDE / 2) > 0 THEN VALOR - (CONVERT(int, QTDE / 2) * 99.99) -          
          ((QTDE % 2) * preco_liquido)          
        ELSE 0          
      END),          
      DESCONTO_ITEM = DESCONTO_ITEM,          
      COMBO5 = ''Qtde(s) Combo Vestido: '' + CONVERT(varchar(10), CONVERT(int, QTDE / 2))          
    FROM (SELECT          
      MIN(PRECO_LIQUIDO-DESCONTO_ITEM) AS preco_liquido,          
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,          
      SUM(QTDE) AS QTDE,          
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR          
    FROM LOJA_PEDIDO  A (NOLOCK)          
    INNER JOIN LOJA_PEDIDO_PRODUTO B (NOLOCK)          
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM             
      AND A.PEDIDO = B.PEDIDO          
    INNER JOIN HR_LOJA_PROMOCAO_LOJAS ON HR_LOJA_PROMOCAO_LOJAS.ID_PROMOCAO = 31        
     AND HR_LOJA_PROMOCAO_LOJAS.CODIGO_FILIAL = @CODIGOFILIAL        
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C          
      ON C.ID_PROMOCAO = 31          
      AND C.PRODUTO = B.PRODUTO          
      AND C.COR_PRODUTO = B.COR_PRODUTO          
    WHERE QTDE <> 0          
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL          
    AND A.DATA = @DATAPEDIDO           
    AND A.PEDIDO = @PEDIDO          
    AND A.DATA >= ''20171215''              
    and A.DATA <= ''20180109''        
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''          
    AND NOT EXISTS (SELECT          
      *          
    FROM CLIENTES_VAREJO C (NOLOCK)          
    WHERE C.CODIGO_CLIENTE = A.CODIGO_CLIENTE          
    AND TIPO_VAREJO LIKE ''FUNCIONARIO%''    
        
        
    )          
    HAVING SUM(QTDE) > 0) AS GG          
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL          
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''          
        
     UNION ALL      
      
    SELECT      
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),      
      DATA_INICIO = CONVERT(datetime, ''20180113''),      
      DATA_FIM = CONVERT(datetime, ''20180215''),      
      DESCONTOPROM =      
                    CASE      
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)      
                      ELSE 0      
                    END,      
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,      
      0 AS GERAPEDIDO,      
      CONVERT(varchar(50), '''') AS COMBOA,      
      CONVERT(varchar(50), '''') AS COMBOB,      
      CONVERT(varchar(50), '''') AS COMBOC,      
      CONVERT(varchar(50), '''') AS COMBOX,      
      CONVERT(varchar(50), '''') AS COMBO0,      
      CONVERT(varchar(50), '''') AS COMBO1,      
      CONVERT(varchar(50), '''') AS COMBO2,      
      CASE      
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO3))      
        ELSE ''''      
      END AS COMBO3,      
      CONVERT(varchar(50), '''') AS COMBO4,      
      CONVERT(varchar(50), '''') AS COMBO5,      
      CONVERT(varchar(50), '''') AS COMBO6,      
      CONVERT(varchar(50), '''') AS COMBO7,      
      CONVERT(varchar(50), '''') AS COMBO8,      
      CONVERT(varchar(50), '''') AS COMBO9,      
      CONVERT(varchar(50), '''') AS COMBO10,      
      CONVERT(varchar(50), '''') AS COMBO11,      
      CONVERT(varchar(50), '''') AS COMBO12,      
      CONVERT(varchar(50), '''') AS COMBO13,      
      CONVERT(varchar(50), '''') AS COMBO14,      
      CONVERT(varchar(50), '''') AS COMBO15      
    FROM (SELECT      
      DESCONTOPROM = (CASE      
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) * 0.10     
        ELSE 0      
      END),      
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),      
      COMBO3 =      
              CASE      
                WHEN SUM(QTDE) >= 3 THEN ''R$ '' + CONVERT(varchar(8), SUM(VALOR) * 0.10) + '' Combo Preços Remarcados''      
                ELSE '' ''      
              END      
    FROM (SELECT      
      A.PRODUTO,      
      PRECO_LIQUIDO,      
      DESCONTO_ITEM,      
      SUM(QTDE) AS QTDE,      
      SUM(QTDE * (PRECO_LIQUIDO-DESCONTO_ITEM)) AS VALOR      
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)      
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)      
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM     
      AND B.DATA = B.DATA      
      AND A.PEDIDO = B.PEDIDO      
    LEFT JOIN HR_LOJA_PROMOCAO_PRODUTOS C      
      ON C.ID_PROMOCAO = 32      
      AND C.PRODUTO = A.PRODUTO      
      AND C.COR_PRODUTO = A.COR_PRODUTO      
 INNER JOIN PRODUTO_CORES D ON D.PRODUTO = A.PRODUTO    
        AND D.COR_PRODUTO = A.COR_PRODUTO    
      AND NOT EXISTS (SELECT      
        *      
      FROM CLIENTES_VAREJO C (NOLOCK)      
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE      
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')      
    WHERE QTDE <> 0      
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL      
    AND B.DATA = @DATAPEDIDO       
    AND A.PEDIDO = @PEDIDO      
    AND B.DATA >= ''20180113''         
    AND(C.ID_PROMOCAO IS NOT NULL OR D.COTA_VENDA NOT IN (317, 417, 517, 617, 118, 218, 318, 418 ))    
    and A.PRODUTO != ''8900''    
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''              
    and a.CODIGO_FILIAL_ORIGEM in(    
          ''125'',       
          ''117'',       
          ''198'',      
          ''114'',       
          ''11'',    
          ''25'',    
          ''182'',    
          ''9'',    
          ''209'')    
        
    GROUP BY A.PRODUTO,      
             PRECO_LIQUIDO,      
             DESCONTO_ITEM      
    HAVING SUM(QTDE) > 0) AS GG      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL      
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''          
      
    
    
    ------------- 10 mais Antigos    
        
    UNION ALL    
    
    SELECT    
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),    
      DATA_INICIO = CONVERT(datetime, ''20180117''),    
      DATA_FIM = CONVERT(datetime, ''20180228''),    
      DESCONTOPROM =    
                    CASE    
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)    
                      ELSE 0    
                    END,    
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,    
      0 AS GERAPEDIDO,    
      CONVERT(varchar(50), '''') AS COMBOA,    
      CONVERT(varchar(50), '''') AS COMBOB,    
      CONVERT(varchar(50), '''') AS COMBOC,    
      CONVERT(varchar(50), '''') AS COMBOX,    
      CONVERT(varchar(50), '''') AS COMBO0,    
      CONVERT(varchar(50), '''') AS COMBO1,    
      CONVERT(varchar(50), '''') AS COMBO2,    
      CONVERT(varchar(50), '''') AS COMBO3,     
      CONVERT(varchar(50), '''') AS COMBO4,    
      CONVERT(varchar(50), '''') AS COMBO5,    
     CASE    
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO6))    
        ELSE ''''    
      END AS COMBO6,    
      CONVERT(varchar(50), '''') AS COMBO7,    
      CONVERT(varchar(50), '''') AS COMBO8,    
      CONVERT(varchar(50), '''') AS COMBO9,    
      CONVERT(varchar(50), '''') AS COMBO10,    
      CONVERT(varchar(50), '''') AS COMBO11,    
      CONVERT(varchar(50), '''') AS COMBO12,    
      CONVERT(varchar(50), '''') AS COMBO13,    
      CONVERT(varchar(50), '''') AS COMBO14,    
      CONVERT(varchar(50), '''') AS COMBO15    
    FROM (SELECT    
      DESCONTOPROM = (CASE    
        WHEN SUM(QTDE) >= 3 THEN  CONVERT(numeric(8,2), SUM(QTDE * (PRECO_LIQUIDO-DESCONTO_ITEM)) * 0.10)    
        ELSE 0    
      END),    
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),    
      COMBO6 =    
              CASE    
                WHEN SUM(QTDE) >= 3 THEN ''R$ '' + CONVERT(varchar(10), CONVERT(numeric(8,2), SUM(QTDE * (PRECO_LIQUIDO-DESCONTO_ITEM) * 0.10))) + '' Desconto 10 extra''    
                ELSE '' ''    
              END    
    FROM (SELECT    
      A.PRODUTO,    
      PRECO_LIQUIDO,    
      DESCONTO_ITEM,    
      SUM(QTDE) AS QTDE,    
      SUM(QTDE * (PRECO_LIQUIDO-DESCONTO_ITEM)) AS VALOR    
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)    
    INNER JOIN LOJA_PEDIDO  B (NOLOCK)    
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM   
      AND B.DATA = B.DATA    
      AND A.PEDIDO = B.PEDIDO    
    INNER JOIN HR_LOJA_PROMOCAO_LOJAS L ON B.CODIGO_FILIAL_ORIGEM=L.CODIGO_FILIAL AND L.ID_PROMOCAO =40    
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C    
      ON C.ID_PROMOCAO = 40    
      AND C.PRODUTO = A.PRODUTO    
      AND C.COR_PRODUTO = A.COR_PRODUTO    
    WHERE QTDE <> 0    
    AND B.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL    
    AND B.DATA = @DATAPEDIDO     
    AND A.PEDIDO = @PEDIDO    
    AND B.DATA >= ''20180117''    
    AND B.DATA <= ''20180228''    
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''    
    GROUP BY A.PRODUTO,    
             PRECO_LIQUIDO,    
             DESCONTO_ITEM    
    ) AS GG    
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL    
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''    
    
 UNION ALL     
    
    SELECT          
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),          
      DATA_INICIO = CONVERT(datetime, ''20180126''),          
      DATA_FIM = CONVERT(datetime, ''20180424''),          
      DESCONTOPROM =          
                    CASE          
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)          
                      ELSE 0          
                    END,          
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,          
      0 AS GERAPEDIDO,          
      CONVERT(varchar(50), '''') AS COMBOA,          
      CONVERT(varchar(50), '''') AS COMBOB,          
      CONVERT(varchar(50), '''') AS COMBOC,          
      CONVERT(varchar(50), '''') AS COMBOX,          
      CONVERT(varchar(50), '''') AS COMBO0,          
      CONVERT(varchar(50), '''') AS COMBO1,          
      CONVERT(varchar(50), '''') AS COMBO2,          
      CONVERT(varchar(50), '''') AS COMBO3,          
      CONVERT(varchar(50), '''') AS COMBO4,          
      CONVERT(varchar(50), '''') AS COMBO5,          
      CONVERT(varchar(50), '''') AS COMBO6,          
      CASE          
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO7))          
        ELSE ''''          
      END AS COMBO7,            
      CONVERT(varchar(50), '''') AS COMBO8,          
      CONVERT(varchar(50), '''') AS COMBO9,          
      CONVERT(varchar(50), '''') AS COMBO10,          
      CONVERT(varchar(50), '''') AS COMBO11,          
      CONVERT(varchar(50), '''') AS COMBO12,          
      CONVERT(varchar(50), '''') AS COMBO13,          
      CONVERT(varchar(50), '''') AS COMBO14,          
      CONVERT(varchar(50), '''') AS COMBO15          
    FROM (SELECT          
      DESCONTOPROM = (CASE          
        WHEN CONVERT(int, QTDE / 3) > 0 THEN VALOR - (CONVERT(int, QTDE / 3) * 119.97) -          
          ((QTDE % 3) * preco_liquido)          
        ELSE 0          
      END),          
      DESCONTO_ITEM = DESCONTO_ITEM,          
      COMBO7 = ''Qtde(s) Combo 4DJT..: '' + CONVERT(varchar(10), CONVERT(int, QTDE / 3))          
    FROM (SELECT          
      MIN(PRECO_LIQUIDO-DESCONTO_ITEM) AS preco_liquido,          
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,          
      SUM(QTDE) AS QTDE,          
      SUM(QTDE * PRECO_LIQUIDO-DESCONTO_ITEM) AS VALOR          
    FROM LOJA_PEDIDO  A (NOLOCK)          
    INNER JOIN LOJA_PEDIDO_PRODUTO B (NOLOCK)          
      ON A.CODIGO_FILIAL_ORIGEM= B.CODIGO_FILIAL_ORIGEM         
      AND A.DATA = A.DATA          
      AND A.PEDIDO = B.PEDIDO          
    INNER JOIN HR_LOJA_PROMOCAO_LOJAS ON HR_LOJA_PROMOCAO_LOJAS.ID_PROMOCAO = 41        
     AND HR_LOJA_PROMOCAO_LOJAS.CODIGO_FILIAL = @CODIGOFILIAL        
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C          
      ON C.ID_PROMOCAO = 41          
      AND C.PRODUTO = B.PRODUTO          
      AND C.COR_PRODUTO = B.COR_PRODUTO          
    WHERE QTDE <> 0          
    AND A.CODIGO_FILIAL_ORIGEM= @CODIGOFILIAL          
    AND A.DATA = @DATAPEDIDO           
    AND A.PEDIDO = @PEDIDO          
    AND A.DATA >= ''20180126''              
    and A.DATA <= ''20180424''        
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''          
    AND NOT EXISTS (SELECT          
      *          
    FROM CLIENTES_VAREJO C (NOLOCK)          
    WHERE C.CODIGO_CLIENTE = A.CODIGO_CLIENTE          
    AND TIPO_VAREJO LIKE ''FUNCIONARIO%''    
    )          
    HAVING SUM(QTDE) > 0) AS GG          
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL          
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''          
        
 UNION ALL  
      
     SELECT        
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),        
      DATA_INICIO = CONVERT(datetime, ''20180207''),        
      DATA_FIM = CONVERT(datetime, ''20180815''),        
      DESCONTOPROM =        
                    CASE        
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)        
                      ELSE 0        
                    END,        
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,        
      0 AS GERATICKET,        
      CONVERT(varchar(50), '''') AS COMBOA,        
      CONVERT(varchar(50), '''') AS COMBOB,        
      CONVERT(varchar(50), '''') AS COMBOC,                
      CONVERT(varchar(50), '''') AS COMBOX,        
      CONVERT(varchar(50), '''') AS COMBO0,        
      CONVERT(varchar(50), '''') AS COMBO1,        
      CONVERT(varchar(50), '''') AS COMBO2,        
      CONVERT(varchar(50), '''') AS COMBO3,        
      CONVERT(varchar(50), '''') AS COMBO4,        
      CONVERT(varchar(50), '''') AS COMBO5,        
      CONVERT(varchar(50), '''') AS COMBO6,   
      CONVERT(varchar(50), '''') AS COMBO7,        
        CASE        
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO8))        
        ELSE ''''        
      END AS COMBO8,         
      CONVERT(varchar(50), '''') AS COMBO9,        
      CONVERT(varchar(50), '''') AS COMBO10,        
      CONVERT(varchar(50), '''') AS COMBO11,        
      CONVERT(varchar(50), '''') AS COMBO12,        
      CONVERT(varchar(50), '''') AS COMBO13,        
      CONVERT(varchar(50), '''') AS COMBO14,        
      CONVERT(varchar(50), '''') AS COMBO15        
    FROM (SELECT        
      DESCONTOPROM = (CASE        
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 39.99)        
        ELSE 0        
      END),        
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),        
      COMBO8 =        
              CASE        
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo ML Fem - R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 39.99)))))        
                ELSE '' ''        
              END                                
    FROM (SELECT        
      A.PRODUTO,        
      PRECO_LIQUIDO,        
      DESCONTO_ITEM,        
      SUM(QTDE) AS QTDE,        
      SUM(QTDE * PRECO_LIQUIDO) AS VALOR        
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)        
    INNER JOIN LOJA_PEDIDO B (NOLOCK)        
      ON A.CODIGO_FILIAL_ORIGEM  = B.CODIGO_FILIAL_ORIGEM              
      AND A.PEDIDO  = B.PEDIDO        
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C        
      ON C.ID_PROMOCAO = 45        
      AND C.PRODUTO = A.PRODUTO        
      AND C.COR_PRODUTO = A.COR_PRODUTO        
      AND NOT EXISTS (SELECT        
        *        
      FROM CLIENTES_VAREJO C (NOLOCK)        
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE        
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')        
    WHERE QTDE <> 0        
    AND A.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL          
    AND A.PEDIDO = @PEDIDO        
    AND B.DATA >= ''20180207''        
    AND B.DATA <= ''20180815''        
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''        
    GROUP BY A.PRODUTO,        
             PRECO_LIQUIDO,        
             DESCONTO_ITEM        
    HAVING SUM(QTDE) > 0) AS GG        
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL        
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''   
       
  UNION ALL  
      
     SELECT        
      PROMOCAO = ISNULL(@PROMOCAO, ''QUANTO MAIS BASICO MELHOR''),        
      DATA_INICIO = CONVERT(datetime, ''20180207''),        
      DATA_FIM = CONVERT(datetime, ''20180815''),        
      DESCONTOPROM =        
                    CASE    
                      WHEN SUM(DESCONTOPROM) > 0 THEN SUM(DESCONTOPROM)        
                      ELSE 0        
                    END,        
      SUM(DESCONTO_ITEM) AS DESCONTO_ITEM,        
      0 AS GERATICKET,        
      CONVERT(varchar(50), '''') AS COMBOA,        
      CONVERT(varchar(50), '''') AS COMBOB,        
      CONVERT(varchar(50), '''') AS COMBOC,                
      CONVERT(varchar(50), '''') AS COMBOX,        
      CONVERT(varchar(50), '''') AS COMBO0,        
      CONVERT(varchar(50), '''') AS COMBO1,        
      CONVERT(varchar(50), '''') AS COMBO2,        
      CONVERT(varchar(50), '''') AS COMBO3,        
      CONVERT(varchar(50), '''') AS COMBO4,        
      CONVERT(varchar(50), '''') AS COMBO5,        
      CONVERT(varchar(50), '''') AS COMBO6,        
      CONVERT(varchar(50), '''') AS COMBO7,        
      CONVERT(varchar(50), '''') AS COMBO8,   
        CASE        
        WHEN SUM(DESCONTOPROM) > 0 THEN RTRIM(MAX(COMBO9))        
        ELSE ''''        
      END AS COMBO9,                       
      CONVERT(varchar(50), '''') AS COMBO10,        
      CONVERT(varchar(50), '''') AS COMBO11,        
      CONVERT(varchar(50), '''') AS COMBO12,        
      CONVERT(varchar(50), '''') AS COMBO13,        
      CONVERT(varchar(50), '''') AS COMBO14,        
      CONVERT(varchar(50), '''') AS COMBO15        
    FROM (SELECT        
      DESCONTOPROM = (CASE        
        WHEN SUM(QTDE) >= 3 THEN SUM(VALOR) - (SUM(QTDE) * 39.99)        
        ELSE 0        
      END),        
      DESCONTO_ITEM = SUM(DESCONTO_ITEM),        
      COMBO9 =        
              CASE        
                WHEN SUM(QTDE) >= 3 THEN '''' + CONVERT(varchar(5), CONVERT(int, SUM(QTDE))) + '' PC(s) Combo ML Masc R$'' + RTRIM(CONVERT(varchar(12), CONVERT(numeric(9, 2), (SUM(VALOR) - (SUM(QTDE) * 39.99)))))        
                ELSE '' ''        
              END                                
    FROM (SELECT        
      A.PRODUTO,        
      PRECO_LIQUIDO,        
      DESCONTO_ITEM,        
      SUM(QTDE) AS QTDE,        
      SUM(QTDE * PRECO_LIQUIDO) AS VALOR        
    FROM LOJA_PEDIDO_PRODUTO A (NOLOCK)        
    INNER JOIN LOJA_PEDIDO B (NOLOCK)        
      ON A.CODIGO_FILIAL_ORIGEM  = B.CODIGO_FILIAL_ORIGEM              
      AND A.PEDIDO  = B.PEDIDO        
    INNER JOIN HR_LOJA_PROMOCAO_PRODUTOS C        
      ON C.ID_PROMOCAO = 46       
      AND C.PRODUTO = A.PRODUTO        
      AND C.COR_PRODUTO = A.COR_PRODUTO        
      AND NOT EXISTS (SELECT        
        *        
      FROM CLIENTES_VAREJO C (NOLOCK)        
      WHERE C.CODIGO_CLIENTE = B.CODIGO_CLIENTE        
      AND TIPO_VAREJO LIKE ''FUNCIONARIO%'')        
    WHERE QTDE <> 0        
    AND A.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL          
    AND A.PEDIDO = @PEDIDO        
    AND B.DATA >= ''20180207''        
    AND B.DATA <= ''20180815''        
    AND @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''        
    GROUP BY A.PRODUTO,        
             PRECO_LIQUIDO,        
             DESCONTO_ITEM        
    HAVING SUM(QTDE) > 0) AS GG        
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR'') AS GERAL        
    WHERE @PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
         
    ) AS FINAL      
      
    WHERE PROMOCAO = ''QUANTO MAIS BASICO MELHOR''      
    GROUP BY PROMOCAO      
  RETURN      
END'    
    

