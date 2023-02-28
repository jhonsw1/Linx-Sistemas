CREATE PROCEDURE LX_RETORNA_PRODUTO_CONTROLE_SALDO (@FILIAL AS VARCHAR (25),  @IDENTIFICADOR_AGRUP AS VARCHAR(15) = NULL)
AS
BEGIN

 DECLARE @INFO_PRODUTO_DETALHE  TABLE
(
    FILIAL VARCHAR(25), 
    PRODUTO VARCHAR(12), 
    COR_PRODUTO VARCHAR(10),
	TAMANHO  SMALLINT,
	CODIGO_ITEM  VARCHAR(50),
	MEDIA_BASE_IMPOSTO NUMERIC(14,2),
	BASE_IMPOSTO_ULT_NOTA NUMERIC(14,2),
	MEDIA_VALOR_UN_ICMS_SUBSTITUTO NUMERIC(14,2),
	VALOR_UN_ICMS_SUBSTITUTO_ULT_NOTA NUMERIC(14,2),
	ID_IMPOSTO TINYINT,
	DATA_FECHAMENTO DATETIME
)

			 
INSERT INTO @INFO_PRODUTO_DETALHE (FILIAL, PRODUTO, COR_PRODUTO,TAMANHO,CODIGO_ITEM,MEDIA_BASE_IMPOSTO,BASE_IMPOSTO_ULT_NOTA, MEDIA_VALOR_UN_ICMS_SUBSTITUTO, VALOR_UN_ICMS_SUBSTITUTO_ULT_NOTA,ID_IMPOSTO, DATA_FECHAMENTO)
SELECT A.FILIAL, A.ITEM AS PRODUTO, A.COR_ITEM AS COR_PRODUTO, A.TAMANHO, 
CASE 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 0 THEN LTRIM(RTRIM(A.ITEM)) 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 1 THEN LTRIM(RTRIM(A.ITEM)) + LTRIM(RTRIM(A.COR_ITEM)) 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 2 THEN LTRIM(RTRIM(A.ITEM)) + LTRIM(RTRIM(A.COR_ITEM)) +  LTRIM(RTRIM(C.GRADE)) 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 3 AND ISNULL(@IDENTIFICADOR_AGRUP,'') <> '' THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), @IDENTIFICADOR_AGRUP))) + LTRIM(RTRIM(A.ITEM))
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 4 AND ISNULL(@IDENTIFICADOR_AGRUP,'') <> '' THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), @IDENTIFICADOR_AGRUP))) + LTRIM(RTRIM(A.ITEM)) + LTRIM(RTRIM(A.COR_ITEM)) 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 5 AND ISNULL(@IDENTIFICADOR_AGRUP,'') <> '' THEN LTRIM(RTRIM(CONVERT(VARCHAR(10), @IDENTIFICADOR_AGRUP))) + LTRIM(RTRIM(A.ITEM)) + LTRIM(RTRIM(A.COR_ITEM)) + LTRIM(RTRIM(C.GRADE)) 
	WHEN ISNULL(DBO.FX_PARAMETRO_LOJA('AGRUPAMENTO_NF', B.CODIGO_FILIAL), '0')  = 6 THEN LTRIM(RTRIM(A.ITEM)) +  LTRIM(RTRIM(C.GRADE)) 
ELSE LTRIM(RTRIM(A.ITEM)) 
END AS CODIGO_ITEM,
ISNULL(MEDIA_BASE_IMPOSTO,0),
ISNULL(BASE_IMPOSTO_ULT_NOTA,0),
ISNULL(VALOR_UN_ICMS_SUBSTITUTO,0),
ISNULL(VALOR_UN_ICMS_SUBSTITUTO_ULT_NOTA,0),
ID_IMPOSTO, DATA_FECHAMENTO
FROM CONTROLE_SALDO_ST A
INNER JOIN LOJAS_VAREJO B
	    ON A.FILIAL = B.FILIAL AND
           A.FILIAL = @FILIAL
INNER JOIN 
		(SELECT PRODUTO, COR_PRODUTO, TAMANHO, GRADE
		 FROM	PRODUTOS_BARRA 
		 GROUP BY PRODUTO, COR_PRODUTO, TAMANHO, GRADE
		) C
		ON C.PRODUTO = A.ITEM AND
		   C.COR_PRODUTO = A.COR_ITEM AND
		   C.TAMANHO = A.TAMANHO
 
 SELECT * FROM @INFO_PRODUTO_DETALHE order by DATA_FECHAMENTO desc
END