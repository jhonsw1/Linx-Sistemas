CREATE PROCEDURE [DBO].[LX_LJ_PROD_ICMS_PAF_NFCE] @CodigoFilial VARCHAR(6), @StringBufer varchar(100)
AS
SET NOCOUNT ON 

BEGIN

declare @Tipo_Oper int, @intIndicadorCFOP int, @strDestinationCode varchar(100), @filial varchar(25), 
@PRODUTO VARCHAR(12), @TributOrigem varchar(100), @intCFOP int, @strItemType char(1), @CFOPMIDEVENDA varchar(30), @NatSaida varchar(7),
@UF CHAR(2)

select @CFOPMIDEVENDA = isnull(b.VALOR_ATUAL, a.VALOR_ATUAL) 
from PARAMETROS a
left join PARAMETROS_LOJA b on a.PARAMETRO = b.PARAMETRO and b.CODIGO_FILIAL = @CodigoFilial
where a.PARAMETRO =  'CFOP_MIDE_VENDA';

SELECT @Tipo_Oper = A.CTB_TIPO_OPERACAO, @NatSaida = A.NATUREZA_SAIDA
FROM LOJAS_NATUREZA_OPERACAO A 
LEFT JOIN CTB_LX_TIPO_OPERACAO B ON A.CTB_TIPO_OPERACAO = B.CTB_TIPO_OPERACAO 
WHERE A.INATIVO = 0 AND B.INATIVO = 0 AND A.NATUREZA_OPERACAO_CODIGO = @CFOPMIDEVENDA
ORDER BY A.NATUREZA_OPERACAO_CODIGO;

select @filial = A.FILIAL,  @UF = C.UF
From LOJAS_VAREJO A
INNER JOIN FILIAIS B ON A.FILIAL = B.FILIAL
INNER JOIN CADASTRO_CLI_FOR C ON B.FILIAL = C.NOME_CLIFOR
where A.CODIGO_FILIAL = @CodigoFilial;

INSERT INTO LJ_PROD_ICMS_PAF_NFCE WITH(XLOCK ROWLOCK)
	(CODIGO_FILIAL, ID_EXCECAO_IMPOSTO, PRODUTO, TAXA_IMPOSTO, TRIBUT_ICMS, PONTUACAO, LX_HASH)
SELECT B.CODIGO_FILIAL, B.ID_EXCECAO_IMPOSTO, B.PRODUTO, B.TAXA_IMPOSTO, B.TRIBUT_ICMS, B.PONTOS,
		HASHBYTES('MD5', @StringBufer)
FROM (	
      SELECT a.CODIGO_FILIAL,
             A.ID_EXCECAO_IMPOSTO,
			 A.PRODUTO,
			 A.TAXA_IMPOSTO,
			 A.TRIBUT_ICMS,
			 A.PONTOS,
			 row_number() over (PARTITION BY A.PRODUTO order by A.PRODUTO, A.PONTOS) [CONTADOR]
      FROM 
      (		
			SELECT				  
				  
				  A.ID_EXCECAO_IMPOSTO, 
				  PONTOS = 
                  CASE WHEN A.INDICADOR_CFOP = E.INDICADOR_CFOP THEN 1 ELSE 0 END + 
				  CASE WHEN A.UF_FILIAL IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN A.INDICADOR_FISCAL_TERCEIRO = 8 THEN 1 ELSE 0 END +
                  CASE WHEN A.CTB_TIPO_OPERACAO = @Tipo_Oper THEN 1 ELSE 0 END + 
                  CASE WHEN A.CODIGO_FISCAL_OPERACAO = @CFOPMIDEVENDA THEN 1 ELSE 0 END + 
                  CASE WHEN A.NATUREZA_SAIDA = @NatSaida THEN 15 ELSE 0 END + 
                  CASE WHEN A.PRODUTO = E.PRODUTO AND g.CODIGO_ITEM is null THEN 15 ELSE 0 END + 
				  CASE WHEN E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM  THEN 10 ELSE 0 END +  
				  CASE WHEN G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM THEN 10 ELSE 0 END +
                  CASE WHEN A.TRIBUT_ORIGEM = E.TRIBUT_ORIGEM THEN 1 ELSE 0 END + 
                  CASE WHEN A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO AND g.CODIGO_ITEM is null THEN 10 ELSE 0 END + 
                  CASE WHEN A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO AND g.CODIGO_ITEM != null THEN 10 ELSE 0 END + 
                  CASE WHEN (H.COD_FILIAL IS NOT NULL AND A.COD_FILIAL = H.COD_FILIAL) THEN 20 ELSE 0 END,
				  E.PRODUTO,
				  i.CODIGO_FILIAL,
				  C.TAXA_IMPOSTO,
				  A.TRIBUT_ICMS
            FROM 
            CTB_EXCECAO_IMPOSTO A
			INNER JOIN CTB_EXCECAO_IMPOSTO_ITEM C ON A.ID_EXCECAO_IMPOSTO = C.ID_EXCECAO_IMPOSTO AND C.ID_IMPOSTO = 1
            INNER JOIN CADASTRO_CLI_FOR B ON B.NOME_CLIFOR = @filial AND ISNULL(A.UF_FILIAL, B.UF) = B.UF
			LEFT JOIN FILIAIS H ON B.NOME_CLIFOR = H.FILIAL 
            LEFT JOIN LOJAS_VAREJO I ON H.FILIAL = I.FILIAL
            LEFT JOIN PRODUTOS E ON A.PRODUTO = E.PRODUTO  
            LEFT JOIN CADASTRO_ITEM_FISCAL G ON G.CODIGO_ITEM = E.PRODUTO AND G.INATIVO = 0   
            WHERE
                  (isnull(A.DT_INICIO_VIGENCIA,'') = '' OR A.DT_INICIO_VIGENCIA <= convert(char(10), getdate(), 112) ) AND 
				  (isnull(A.DT_FIM_VIGENCIA,'') = '' OR A.DT_FIM_VIGENCIA >= convert(char(10), getdate(), 112) )       AND  
				  (A.INATIVO = 0 OR A.INATIVO IS NULL)
                  AND A.NOME_CLIFOR IS NULL
                  AND (A.INDICADOR_FISCAL_TERCEIRO = 8 OR A.INDICADOR_FISCAL_TERCEIRO IS NULL )
                  AND (A.PRODUTO = E.PRODUTO OR A.PRODUTO IS NULL)
                  AND (A.EXCLUSIVO_CADASTRO = 0 OR A.EXCLUSIVO_CADASTRO IS NULL)
                  AND (A.CTB_TIPO_OPERACAO = @Tipo_Oper OR A.CTB_TIPO_OPERACAO IS NULL)
                  AND (A.INDICADOR_CFOP = e.INDICADOR_CFOP OR A.INDICADOR_CFOP IS NULL)
                  AND (A.TRIBUT_ORIGEM = e.TRIBUT_ORIGEM OR A.TRIBUT_ORIGEM IS NULL)
                  AND (A.CODIGO_FISCAL_OPERACAO = @CFOPMIDEVENDA OR A.CODIGO_FISCAL_OPERACAO IS NULL)
                  AND A.APLICA_SAIDA = 1
                  AND (A.NATUREZA_SAIDA = @NatSaida OR A.NATUREZA_SAIDA IS NULL)
                  AND (A.ID_EXCECAO_GRUPO = E.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO = G.ID_EXCECAO_GRUPO OR A.ID_EXCECAO_GRUPO IS NULL)
                  and ( A.UF = B.UF OR A.UF IS NULL)
				  AND (I.CODIGO_FILIAL = @CodigoFilial OR I.CODIGO_FILIAL IS NULL)
                  AND (A.COD_FILIAL = H.COD_FILIAL OR A.COD_FILIAL IS NULL)
                  AND ( 
						(E.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM ) OR 
						(G.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INI AND A.CLASSIF_FISCAL_FIM) OR 
						A.CLASSIF_FISCAL_INI IS NULL OR A.CLASSIF_FISCAL_FIM IS NULL
					)
		) A
) B
WHERE CONTADOR = 1

IF NOT EXISTS( SELECT TOP 1 1 FROM LJ_PROD_ICMS_PAF_NFCE WHERE PRODUTO IS NULL)
BEGIN

	INSERT LJ_PROD_ICMS_PAF_NFCE WITH(XLOCK ROWLOCK)
		(CODIGO_FILIAL, ID_EXCECAO_IMPOSTO, PRODUTO, TAXA_IMPOSTO, TRIBUT_ICMS, PONTUACAO, LX_HASH)
	SELECT @CodigoFilial, 0, NULL, ICMS_SAIDA, '00', 0 , HASHBYTES('MD5', @StringBufer)
	FROM UNIDADES_FEDERACAO_ICMS WHERE UF = @UF AND UF_DESTINO = @UF;
END


UPDATE DBO.LJ_PROD_ICMS_PAF_NFCE  WITH(XLOCK ROWLOCK) 
	SET LX_HASH = HASHBYTES('MD5', @StringBufer + CODIGO_FILIAL + CAST(ID_EXCECAO_IMPOSTO AS VARCHAR) + ISNULL(PRODUTO,'') + ISNULL(TRIBUT_ICMS,'') + 
				 CAST(ISNULL(TAXA_IMPOSTO,0) AS VARCHAR)
				 )
WHERE
	CODIGO_FILIAL = @CodigoFilial
	AND CONVERT(CHAR(10) , DATA_PAF_NFCE, 112 ) = CONVERT(CHAR(10) , GETDATE(), 112);


END