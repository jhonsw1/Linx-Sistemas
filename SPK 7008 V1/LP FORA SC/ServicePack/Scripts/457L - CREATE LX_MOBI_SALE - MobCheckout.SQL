CREATE PROCEDURE [DBO].[LX_MOBI_SALE] @PPEDIDO INT,
    @PCODIGO_FILIAL_ORIGEM              CHAR(6),
    @TERMINAL                           CHAR(3) AS
    BEGIN
        SET NOCOUNT ON
        DECLARE
            @ENTREGA INT
            SELECT
                   TOP 1 @ENTREGA = ENTREGUE
            FROM
                   LOJA_PEDIDO
            WHERE
                   PEDIDO                   = @PPEDIDO
                   AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM IF @ENTREGA IS NOT NULL BEGIN IF @ENTREGA = 1 BEGIN
            SELECT
                   CAST(1 AS BIT) AS BSUCESS
                 , TICKET
                 , DATA_VENDA
            FROM
                   LOJA_PEDIDO_VENDA
            WHERE
                   PEDIDO                   = @PPEDIDO
                   AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
            UNION
            SELECT
                   CAST(STATUS AS BIT) AS BSUCESS
                 , TICKET
                 , DATA_VENDA
            FROM
                   LOJA_VENDA_SHOWROOMER
            WHERE
                   PEDIDO            = @PPEDIDO
                   AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
     END ELSE BEGIN BEGIN TRY --INICIO DO TRY CATCH
     BEGIN TRANSACTION MAN_VENDA DECLARE @TB_TICKET TABLE ( TICKET CHAR(8) ) DECLARE @TB_NF_NUMERO TABLE ( NF_NUMERO CHAR(15) ) DECLARE @PERIOD_CASH TABLE ( CASHOPERATOR CHAR(4), PERIOD CHAR(2), STATUS INT ) DECLARE @TICKET CHAR(8) DECLARE @DATA_VENDA DATETIME DECLARE @VALOR_ATUAL VARCHAR(100) DECLARE @NF_NUMERO CHAR(15) DECLARE @SERIE_NF CHAR(6) DECLARE @LANCAMENTO_CAIXA CHAR(7) DECLARE @CAIXA_VENDEDOR CHAR(4) DECLARE @PERIOD_TERMINAL CHAR(03) DECLARE @ISVALID BIT SET @CAIXA_VENDEDOR =
     (
            SELECT
                   TOP 1 VALOR_ATUAL
            FROM
                   PARAMETROS_LOJA
            WHERE
                   PARAMETRO         = 'COD_GERENTE_LOJA'
                   AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
     )
     --#4#
     IF ISNULL(@TERMINAL, '') = '' BEGIN
            SELECT
                   '#TERMINAL NÃƑO DEFINIDO - ( LINXPOS )' AS ERRORMESSAGE
            ;
            
            RETURN
        END
        SET @DATA_VENDA = CAST(CONVERT(VARCHAR, GETDATE(), 112) AS DATETIME)
        -- BUSCA O VALOR ATUAL
        SELECT
               @VALOR_ATUAL = VALOR_ATUAL
        FROM
               PARAMETROS_LOJA
        WHERE
               PARAMETRO         = 'SEQUENCIA_TICKET'
               AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM SET @SERIE_NF =
               (
                      SELECT
                             TOP 1 VALOR_ATUAL
                      FROM
                             PARAMETROS_LOJA
                      WHERE
                             PARAMETRO         = 'SERIE_NF_VENDA'
                             AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
               )
        --#4#
        INSERT INTO @PERIOD_CASH EXEC LX_LJ_STATUS_TERMINAL @PCODIGO_FILIAL_ORIGEM
             , @TERMINAL
             , @DATA_VENDA
             , 0
        SELECT
               @PERIOD_TERMINAL = PERIOD
        FROM
               @PERIOD_CASH
        INSERT INTO @TB_TICKET EXEC SP_GETNEXTTICKET @PCODIGO_FILIAL_ORIGEM
             , @VALOR_ATUAL
             , 1
             , NULL
        SELECT
               @TICKET = TICKET
        FROM
               @TB_TICKET DECLARE @FILIAL VARCHAR(25)
        SELECT
               @FILIAL = FILIAL
        FROM
               LOJAS_VAREJO
        WHERE
               CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM SET @LANCAMENTO_CAIXA =
               (
                      SELECT
                             DBO.FN_GETNEXTPAYMENTSEQUENCE(@PCODIGO_FILIAL_ORIGEM, @TERMINAL, @DATA_VENDA)
               )
               IF OBJECT_ID('TEMPDB..#TMP_TOTAL_ENTREGA_FUTURA') IS NOT NULL
        DROP TABLE #TMP_TOTAL_ENTREGA_FUTURA --#5#
                   IF OBJECT_ID('TEMPDB..#TMP_LOJA_PEDIDO_PRODUTO') IS NOT NULL
        DROP TABLE #TMP_LOJA_PEDIDO_PRODUTO
        --#5#
        SELECT
                 PEDIDO
               , SUM
                          (
                                   CASE
                                            WHEN A.INDICA_ENTREGA_FUTURA          = 1
                                                     AND ISNULL(QTDE_DEVOLVIDA,0) = 0
                                                     THEN A.PRECO_LIQUIDO * QTDE
                                                     ELSE 0
                                   END
                          )
                 AS VALOR_TOTAL_ENTREGA_FUTURA
               , SUM
                          (
                                   CASE
                                            WHEN A.INDICA_ENTREGA_FUTURA          = 0
                                                     AND ISNULL(QTDE_DEVOLVIDA,0) = 0
                                                     THEN A.PRECO_LIQUIDO * QTDE
                                                     ELSE 0
                                   END
                          )
                 AS VALOR_TOTAL_PRESENCIAL
               , SUM
                          (
                                   CASE
                                            WHEN A.INDICA_ENTREGA_FUTURA          = 0
                                                     AND ISNULL(QTDE_DEVOLVIDA,0) = 0
                                                     THEN QTDE
                                                     ELSE 0
                                   END
                          )
                 AS QTDE_TOTAL_PRESENCIAL
               , SUM
                          (
                                   CASE
                                            WHEN A.INDICA_ENTREGA_FUTURA          = 0
                                                     AND ISNULL(QTDE_DEVOLVIDA,0) > 0
                                                     THEN A.PRECO_LIQUIDO * QTDE_DEVOLVIDA
                                                     ELSE 0
                                   END
                          )
                 AS VALOR_TROCA_PRESENCIAL
               , SUM
                          (
                                   CASE
                                            WHEN A.INDICA_ENTREGA_FUTURA          = 0
                                                     AND ISNULL(QTDE_DEVOLVIDA,0) > 0
                                                     THEN QTDE_DEVOLVIDA
                                                     ELSE 0
                                   END
                          )
                 AS QTDE_TROCA_PRESENCIAL
               , INDICA_ENTREGA_FUTURA
        INTO
                 #TMP_TOTAL_ENTREGA_FUTURA
        FROM
                 LOJA_PEDIDO_PRODUTO A WITH (NOLOCK)
        WHERE
                 PEDIDO                   = @PPEDIDO
                 AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
        GROUP BY
                 PEDIDO
               , INDICA_ENTREGA_FUTURA
        SELECT
               CODIGO_FILIAL_ORIGEM
             , PEDIDO
             , ITEM
             , ID_VENDEDOR
             , CODIGO_BARRA
             , PRODUTO
             , COR_PRODUTO
             , TAMANHO
             , QTDE
             , QTDE_VENDA
             , QTDE_TERCEIRO
             , QTDE_DEVOLVIDA
             , PRECO_LIQUIDO
             , DESCONTO_ITEM
             , CANCELADO
             , DATA_PARA_TRANSFERENCIA
             , INDICA_ENTREGA_FUTURA
             , DATA_ENTREGA
             , DATA_INCLUSAO
             , INDICA_ITEM_ECOMMERCE
             , DESCR_PRODUTO
             , UNIDADE
             , SITUACAO_TRIBUTARIA
             , ALIQUOTA
             , DECIMAIS_QTDE
             , DECIMAIS_PREC_UNIT
             , LX_HASH
             , EMBRULHA_PRESENTE
             , SEQ_ENTREGA
             , DADOS_ADICIONAIS
             , OUTRAS_DESPESAS
        INTO
               #TMP_LOJA_PEDIDO_PRODUTO
        FROM
               LOJA_PEDIDO_PRODUTO WITH (NOLOCK)
        WHERE
               PEDIDO                   = @PPEDIDO
               AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
        INSERT INTO LOJA_VENDA_PGTO
               (CODIGO_FILIAL
                    , TERMINAL
                    , LANCAMENTO_CAIXA
                    , COD_FORMA_PGTO
                    , CAIXA_VENDEDOR
                    , DIGITACAO
                    , DATA
                    , TOTAL_VENDA
                    , PERIODO_FECHAMENTO
                    , DATA_PARA_TRANSFERENCIA
                    , LX_STATUS_VENDA
                    , VENDA_FINALIZADA
                    , -- #9#
                      DESCONTO_PGTO
               )
        SELECT
                  @PCODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL
                , @TERMINAL              AS TERMINAL
                , @LANCAMENTO_CAIXA      AS LANCAMENTO_CAIXA
                , A.COD_FORMA_PGTO       AS COD_FORMA_PGTO
                , A.VENDEDOR             AS CAIXA_VENDEDOR
                , GETDATE()              AS DIGITACAO
                , @DATA_VENDA            AS DATA
                , CASE
                            WHEN A.LX_PEDIDO_ORIGEM = 4
                                      THEN A.VALOR_TOTAL - ISNULL(A.DESCONTO, 0.00) -  ISNULL(C.DESCONTO_PGTO,0.00)
                                      ELSE (CAST(B.VALOR_TOTAL_PRESENCIAL * (1 - ISNULL(A.DESCONTO, 0.00) / A.VALOR_TOTAL) AS NUMERIC(14,2)) - ISNULL(B.VALOR_TROCA_PRESENCIAL,0.00)) - ISNULL(C.DESCONTO_PGTO,0.00)
                  END              AS TOTAL_VENDA
                , @PERIOD_TERMINAL AS PERIODO_FECHAMENTO
                , GETDATE()        AS DATA_PARA_TRANSFERENCIA
                , 1                AS LX_STATUS_VENDA
                , 1                AS VENDA_FINALIZADA
                , --#9#
                  ISNULL(C.DESCONTO_PGTO,0.00) AS DESCONTO_PGTO
        FROM
                  LOJA_PEDIDO A
                  LEFT JOIN
                            #TMP_TOTAL_ENTREGA_FUTURA B
                            ON
                                      A.PEDIDO = B.PEDIDO
                  LEFT JOIN
                            (
                                     SELECT
                                              PEDIDO
                                            , CODIGO_FILIAL_ORIGEM
                                            , SUM(DESCONTO_PGTO) AS DESCONTO_PGTO
                                     FROM
                                              LOJA_PEDIDO_PGTO C
                                     WHERE
                                              PEDIDO                   = @PPEDIDO
                                              AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
                                     GROUP BY
                                              PEDIDO
                                            , CODIGO_FILIAL_ORIGEM
                            )
                            C
                            ON
                                      A.PEDIDO                   = C.PEDIDO
                                      AND A.CODIGO_FILIAL_ORIGEM = C.CODIGO_FILIAL_ORIGEM
        WHERE
                  A.PEDIDO                    = @PPEDIDO
                  AND A.CODIGO_FILIAL_ORIGEM  = @PCODIGO_FILIAL_ORIGEM
                  AND B.INDICA_ENTREGA_FUTURA = 0
                  -- SE NÃƑO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                  IF( @@ROWCOUNT = 0 ) BEGIN
        INSERT INTO LOJA_VENDA_PGTO
               (CODIGO_FILIAL
                    , TERMINAL
                    , LANCAMENTO_CAIXA
                    , COD_FORMA_PGTO
                    , CAIXA_VENDEDOR
                    , DIGITACAO
                    , DATA
                    , TOTAL_VENDA
                    , PERIODO_FECHAMENTO
                    , DATA_PARA_TRANSFERENCIA
                    , LX_STATUS_VENDA
                    , VENDA_FINALIZADA -- #9#
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL
             , @TERMINAL              AS TERMINAL
             , @LANCAMENTO_CAIXA      AS LANCAMENTO_CAIXA
             , COD_FORMA_PGTO         AS COD_FORMA_PGTO
             , A.VENDEDOR             AS CAIXA_VENDEDOR
             , GETDATE()              AS DIGITACAO
             , @DATA_VENDA            AS DATA
             , 0                      AS TOTAL_VENDA
             , @PERIOD_TERMINAL       AS PERIODO_FECHAMENTO
             , GETDATE()              AS DATA_PARA_TRANSFERENCIA
             , 1                      AS LX_STATUS_VENDA
             , 1                      AS VENDA_FINALIZADA-- #9#
        FROM
               LOJA_PEDIDO A WITH (NOLOCK)
        WHERE
               A.PEDIDO                 = @PPEDIDO
               AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
 END
        INSERT INTO LOJA_VENDA
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , CODIGO_DESCONTO
                    , CODIGO_CLIENTE
                    , PERIODO
                    , DATA_DIGITACAO
                    , VENDEDOR
                    , OPERACAO_VENDA
                    , CODIGO_TAB_PRECO
                    , COMISSAO
                    , DESCONTO
                    , QTDE_TOTAL
                    , VALOR_TIKET
                    , VALOR_PAGO
                    , VALOR_VENDA_BRUTA
                    , VALOR_TROCA
                    , QTDE_TROCA_TOTAL
                    , TICKET_IMPRESSO
                    , TERMINAL
                    , GERENTE_LOJA
                    , GERENTE_PERIODO
                    , CODIGO_FILIAL_PGTO
                    , TERMINAL_PGTO
                    , LANCAMENTO_CAIXA
                    , PERIODO_FECHAMENTO
                    , DATA_PARA_TRANSFERENCIA
                    , VALOR_FRETE
                    , CPF_CGC_ECF
                    , NSU_ACUMULO_FIDELIDADE
                    , LX_VENDA_ORIGEM
					, ID_INTERMEDIADOR
               )
        SELECT
                  A.CODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL
                , @TICKET                AS TICKET
                , @DATA_VENDA            AS DATA_VENDA
                , NULL                   AS CODIGO_DESCONTO
                , CODIGO_CLIENTE         AS CODIGO_CLIENTE
                , NULL                   AS PERIODO
                , GETDATE()              AS DATA_DIGITACAO
                , VENDEDOR
                , OPERACAO_VENDA
                , CODIGO_TAB_PRECO AS CODIGO_TAB_PRECO
                , NULL             AS COMISSAO
                , CASE
                            WHEN A.LX_PEDIDO_ORIGEM = 4 
                                      THEN  ISNULL(A.DESCONTO, 0.00)
                                      ELSE ( VALOR_TOTAL_PRESENCIAL - CAST(B.VALOR_TOTAL_PRESENCIAL * (1 - ISNULL(A.DESCONTO, 0.00) / A.VALOR_TOTAL) AS NUMERIC(14,2)) )
                  END                   AS DESCONTO
                , QTDE_TOTAL_PRESENCIAL AS QTDE_TOTAL
                , CASE
                            WHEN A.LX_PEDIDO_ORIGEM = 4
                                      THEN A.VALOR_TOTAL -  ISNULL(A.DESCONTO, 0.00)
                                      ELSE CAST(B.VALOR_TOTAL_PRESENCIAL * (1 - ISNULL(A.DESCONTO, 0.00) / A.VALOR_TOTAL) AS NUMERIC(14,2)) - B.VALOR_TROCA_PRESENCIAL
                  END AS VALOR_TIKET
                , --VALOR_TROCA_PRESENCIAL JÁ É O VALOR LIQUIDO DA TROCA (DESC E ACRESC)
                  CASE
                            WHEN A.LX_PEDIDO_ORIGEM = 4
                                     THEN A.VALOR_TOTAL -  ISNULL(A.DESCONTO, 0.00)
                                      ELSE (CAST(B.VALOR_TOTAL_PRESENCIAL * (1 - ISNULL(A.DESCONTO, 0.00) / A.VALOR_TOTAL) AS NUMERIC(14,2)) - ISNULL(B.VALOR_TROCA_PRESENCIAL,0.00)) - ISNULL(C.DESCONTO_PGTO,0.00)
                  END                      AS VALOR_PAGO
                , VALOR_TOTAL_PRESENCIAL   AS VALOR_VENDA_BRUTA
                , B.VALOR_TROCA_PRESENCIAL AS VALOR_TROCA
                , B.QTDE_TROCA_PRESENCIAL  AS QTDE_TROCA_TOTAL
                , 0                        AS TICKET_IMPRESSO
                , @TERMINAL
                , @CAIXA_VENDEDOR
                  --,(SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = 'COD_GERENTE_PERIODO')
                , (
                         SELECT
                                TOP 1 VALOR_ATUAL
                         FROM
                                PARAMETROS_LOJA
                         WHERE
                                PARAMETRO         = 'COD_GERENTE_PERIODO'
                                AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
                  ) --#5#
                , A.CODIGO_FILIAL_ORIGEM
                , @TERMINAL
                , @LANCAMENTO_CAIXA
                , @PERIOD_TERMINAL
                , GETDATE()
                , 0
                , CPF_CGC_ECF
                , A.NSU_FIDELIDADE
                , 2
				,A.ID_INTERMEDIADOR
        FROM
                  LOJA_PEDIDO A
                  LEFT JOIN
                            #TMP_TOTAL_ENTREGA_FUTURA B
                            ON
                                      A.PEDIDO = B.PEDIDO
                  LEFT JOIN
                            (
                                     SELECT
                                              PEDIDO
                                            , CODIGO_FILIAL_ORIGEM
                                            , SUM(DESCONTO_PGTO) AS DESCONTO_PGTO
                                     FROM
                                              LOJA_PEDIDO_PGTO C
                                     WHERE
                                              PEDIDO                   = @PPEDIDO
                                              AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
                                     GROUP BY
                                              PEDIDO
                                            , CODIGO_FILIAL_ORIGEM
                            )
                            C
                            ON
                                      A.PEDIDO                   = C.PEDIDO
                                      AND A.CODIGO_FILIAL_ORIGEM = C.CODIGO_FILIAL_ORIGEM
        WHERE
                  A.PEDIDO                   = @PPEDIDO
                  AND A.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
                  AND INDICA_ENTREGA_FUTURA  = 0
                  -- SE NÃƑO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                  IF( @@ROWCOUNT = 0 ) BEGIN
        INSERT INTO LOJA_VENDA
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , CODIGO_DESCONTO
                    , CODIGO_CLIENTE
                    , PERIODO
                    , DATA_DIGITACAO
                    , VENDEDOR
                    , OPERACAO_VENDA
                    , CODIGO_TAB_PRECO
                    , COMISSAO
                    , DESCONTO
                    , QTDE_TOTAL
                    , VALOR_TIKET
                    , VALOR_PAGO
                    , VALOR_VENDA_BRUTA
                    , VALOR_TROCA
                    , QTDE_TROCA_TOTAL
                    , TICKET_IMPRESSO
                    , TERMINAL
                    , GERENTE_LOJA
                    , GERENTE_PERIODO
                    , CODIGO_FILIAL_PGTO
                    , TERMINAL_PGTO
                    , LANCAMENTO_CAIXA
                    , PERIODO_FECHAMENTO
                    , DATA_PARA_TRANSFERENCIA
                    , VALOR_FRETE
                    , CPF_CGC_ECF
                    , NSU_ACUMULO_FIDELIDADE
                    , LX_VENDA_ORIGEM
					, ID_INTERMEDIADOR
               )
        SELECT
               CODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
             , NULL
             , CODIGO_CLIENTE
             , NULL
             , GETDATE()
             , VENDEDOR
             , OPERACAO_VENDA
             , CODIGO_TAB_PRECO
             , 0.00
             , 0
             , 0
             , 0
             , 0
             , 0
             , 0
             , 0
             , 0
             , @TERMINAL
             , @CAIXA_VENDEDOR
             , (
                      SELECT
                             TOP 1 VALOR_ATUAL
                      FROM
                             PARAMETROS_LOJA
                      WHERE
                             PARAMETRO         = 'COD_GERENTE_PERIODO'
                             AND CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
               )
               --#5#
             , CODIGO_FILIAL_ORIGEM
             , @TERMINAL
             , @LANCAMENTO_CAIXA
             , @PERIOD_TERMINAL
             , GETDATE()
             , 0
             , CPF_CGC_ECF
             , A.NSU_FIDELIDADE
             , 2
			 , A.ID_INTERMEDIADOR
        FROM
               LOJA_PEDIDO A WITH (NOLOCK)
        WHERE
               A.PEDIDO                 = @PPEDIDO
               AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
 END
        INSERT INTO LOJA_VENDA_PRODUTO
               (TICKET
                    , CODIGO_FILIAL
                    , DATA_VENDA
                    , ITEM
                    , CODIGO_BARRA
                    , PRODUTO
                    , COR_PRODUTO
                    , TAMANHO
                    , QTDE
                    , PRECO_LIQUIDO
                    , DESCONTO_ITEM
                    , DATA_PARA_TRANSFERENCIA
                    , FATOR_DESCONTO_VENDA
                    , FATOR_VENDA_LIQ
                    , ID_VENDEDOR
                    , ALIQUOTA
                    , VALOR_TOTAL
                    , QTDE_CANCELADA
                    , IDPROMOCAO
                      --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE
               )
        SELECT
               @TICKET                AS TICKET
             , @PCODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL
             , @DATA_VENDA            AS DATA_VENDA
             , CASE
                      WHEN A.ITEM < 10
                             THEN '000' + CAST(A.ITEM AS CHAR(1))
                      WHEN A.ITEM < 100
                             THEN '00' + CAST(A.ITEM AS CHAR(2))
                      WHEN A.ITEM < 1000
                             THEN '0' + CAST(A.ITEM AS CHAR(3))
                             ELSE CAST(A.ITEM AS       CHAR(4))
               END            AS ITEM
             , A.CODIGO_BARRA AS CODIGO_BARRA
             , A.PRODUTO      AS PRODUTO
             , A.COR_PRODUTO  AS COR_PRODUTO
             , A.TAMANHO      AS TAMANHO
             , CASE
                      WHEN A.CANCELADO = 1
                             THEN 0
                             ELSE A.QTDE
               END             AS QTDE
             , A.PRECO_LIQUIDO AS PRECO_LIQUIDO
             , A.DESCONTO_ITEM AS DESCONTO_ITEM
             , GETDATE()       AS DATA_PARA_TRANSFERENCIA
             , 0.1000          AS FATOR_DESCONTO_VENDA
             , 0.90000         AS FATOR_VENDA_LIQ
             , A.ID_VENDEDOR   AS ID_VENDEDOR
             , A.ALIQUOTA      AS ALIQUOTA
             , PRECO_LIQUIDO   AS VALOR_TOTAL
             , --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE
               CASE
                      WHEN A.CANCELADO = 0
                             THEN 0
                             ELSE A.QTDE
               END AS QTDE_CANCELADA
             , 0   AS ID_PROMOCAO
        FROM
               #TMP_LOJA_PEDIDO_PRODUTO A
               JOIN
                      LOJA_PEDIDO B
                      ON
                             A.PEDIDO                   = B.PEDIDO
                             AND A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
        WHERE
               A.PEDIDO                       = @PPEDIDO
               AND A.CODIGO_FILIAL_ORIGEM     = @PCODIGO_FILIAL_ORIGEM
               AND A.INDICA_ENTREGA_FUTURA    = 0
               AND B.TIPO_PEDIDO             != 99
               AND ISNULL(A.QTDE_DEVOLVIDA,0) = 0
        INSERT INTO LOJA_VENDA_TROCA
               ( TICKET
                    , CODIGO_FILIAL
                    , ITEM
                    , DATA_VENDA
                    , CODIGO_BARRA
                    , PRODUTO
                    , COR_PRODUTO
                    , TAMANHO
                    , QTDE
                    , PRECO_LIQUIDO
                    , DESCONTO_ITEM
                    , QTDE_CANCELADA
                    , CUSTO
                    , FATOR_DESCONTO_VENDA
                    , IPI
                    , ID_VENDEDOR
                    , DATA_PARA_TRANSFERENCIA
                    , ITEM_EXCLUIDO
                    , NAO_MOVIMENTA_ESTOQUE
                    , INDICA_ENTREGA_FUTURA
                    , ORIGEM_OMS
               )
        SELECT
               @TICKET                AS TICKET
             , @PCODIGO_FILIAL_ORIGEM AS CODIGO_FILIAL
             , CASE
                      WHEN A.ITEM < 10
                             THEN '000' + CAST(A.ITEM AS CHAR(1))
                      WHEN A.ITEM < 100
                             THEN '00' + CAST(A.ITEM AS CHAR(2))
                      WHEN A.ITEM < 1000
                             THEN '0' + CAST(A.ITEM AS CHAR(3))
                             ELSE CAST(A.ITEM AS       CHAR(4))
               END            AS ITEM
             , @DATA_VENDA    AS DATA_VENDA
             , A.CODIGO_BARRA AS CODIGO_BARRA
             , A.PRODUTO      AS PRODUTO
             , A.COR_PRODUTO  AS COR_PRODUTO
             , A.TAMANHO      AS TAMANHO
             , CASE
                      WHEN A.CANCELADO = 1
                             THEN 0
                             ELSE A.QTDE_DEVOLVIDA
               END                       AS QTDE
             , PRECO_LIQUIDO             AS PRECO_LIQUIDO
             , ISNULL(A.DESCONTO_ITEM,0) AS DESCONTO_ITEM
             , CASE
                      WHEN A.CANCELADO = 1
                             THEN QTDE_DEVOLVIDA
                             ELSE 0
               END    AS QTDE_CANCELADA
             , 0.00   AS CUSTO
             , 0.1000 AS FATOR_DESCONTO_VENDA
             , 0.00   AS IPI
             , CASE
                      WHEN ISNULL(A.ID_VENDEDOR,1) = 0
                             THEN 1
                             ELSE A.ID_VENDEDOR
               END       AS ID_VENDEDOR
             , GETDATE() AS DATA_PARA_TRANSFERENCIA
             , 0         AS ITEM_EXCLUIDO
             , 0         AS NAO_MOVIMENTA_ESTOQUE
             , 0         AS INDICA_ENTREGA_FUTURA
             , 0         AS ORIGEM_OMS
        FROM
               #TMP_LOJA_PEDIDO_PRODUTO A
               JOIN
                      LOJA_PEDIDO B
                      ON
                             A.PEDIDO                   = B.PEDIDO
                             AND A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
        WHERE
               A.PEDIDO                       = @PPEDIDO
               AND A.CODIGO_FILIAL_ORIGEM     = @PCODIGO_FILIAL_ORIGEM
               AND A.INDICA_ENTREGA_FUTURA    = 0
               AND B.TIPO_PEDIDO             != 99
               AND ISNULL(A.QTDE_DEVOLVIDA,0) > 0
        INSERT INTO LOJA_PEDIDO_VENDA
               (PEDIDO
                    , CODIGO_FILIAL_ORIGEM
                    , ITEM
                    , TICKET
                    , CODIGO_FILIAL
                    , DATA_VENDA
                    , ITEM_VENDA
                    , DATA_PARA_TRANSFERENCIA
               )
        SELECT
               @PPEDIDO
             , @PCODIGO_FILIAL_ORIGEM
             , ITEM
             , @TICKET
             , @PCODIGO_FILIAL_ORIGEM
             , @DATA_VENDA
             , CASE
                      WHEN ITEM < 10
                             THEN '000' + CAST(ITEM AS CHAR(1))
                      WHEN ITEM < 100
                             THEN '00' + CAST(ITEM AS CHAR(2))
                      WHEN ITEM < 1000
                             THEN '0' + CAST(ITEM AS CHAR(3))
                             ELSE CAST(ITEM AS       CHAR(4))
               END
             , GETDATE()
        FROM
               #TMP_LOJA_PEDIDO_PRODUTO A
               JOIN
                      LOJA_PEDIDO B
                      ON
                             A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
                             AND A.PEDIDO           = B.PEDIDO
        WHERE
               A.PEDIDO                   = @PPEDIDO
               AND A.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
               AND INDICA_ENTREGA_FUTURA  = 0
               AND B.TIPO_PEDIDO         != 99 IF EXISTS
               (
                      SELECT *
                      FROM
                             INFORMATION_SCHEMA.TABLES
                      WHERE
                             TABLE_NAME = N'LOJA_VENDA_SHOWROOMER'
               )
               BEGIN
        INSERT INTO LOJA_VENDA_SHOWROOMER
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , ID_B2C
                    , PEDIDO
                    , STATUS
                    , VALE_PRODUTO_GERADO
                    , VALOR_PAGO
                    , CAIXA_VENDEDOR
               )
        SELECT
                   @PCODIGO_FILIAL_ORIGEM
                 , @TICKET
                 , @DATA_VENDA
                 , ''
                 , @PPEDIDO
                 , 1
                 , LTRIM(RTRIM(@PCODIGO_FILIAL_ORIGEM)) + '-' + LTRIM(RTRIM(@TERMINAL)) + '-' + LTRIM(RTRIM(@LANCAMENTO_CAIXA)) + '-' + '01'
                 , CAST(A.VALOR_TOTAL_ENTREGA_FUTURA * (1 - ISNULL(DESCONTO, 0.00) / VALOR_TOTAL) AS NUMERIC(14,2)) + ISNULL(B.FRETE, 0.00) AS VALOR_PAGO
                 , B.VENDEDOR
        FROM
                   #TMP_TOTAL_ENTREGA_FUTURA A
                   INNER JOIN
                              LOJA_PEDIDO B
                              ON
                                         A.PEDIDO = B.PEDIDO
        WHERE
                   B.PEDIDO                   = @PPEDIDO
                   AND B.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
                   AND INDICA_ENTREGA_FUTURA  = 1
END
        INSERT INTO LOJA_VENDA_PARCELAS
               (TERMINAL
                    , LANCAMENTO_CAIXA
                    , CODIGO_FILIAL
                    , PARCELA
                    , CODIGO_ADMINISTRADORA
                    , TIPO_PGTO
                    , VALOR
                    , VENCIMENTO
                    , NUMERO_TITULO
                    , MOEDA
                    , AGENCIA
                    , BANCO
                    , CONTA_CORRENTE
                    , NUMERO_APROVACAO_CARTAO
                    , PARCELAS_CARTAO
                    , DATA_HORA_TEF
                    , CHEQUE_CARTAO
                    , TROCO
                    , --#14#
                      DATA_PARA_TRANSFERENCIA
                    , COD_CREDENCIADORA
                    , FINALIZACAO
                    , REDE_CONTROLADORA
               )
        SELECT
                   @TERMINAL
                 , @LANCAMENTO_CAIXA
                 , @PCODIGO_FILIAL_ORIGEM
                 , PARCELA
                 , A.CODIGO_ADMINISTRADORA
                 , TIPO_PGTO
                 ,  CASE WHEN C.LX_PEDIDO_ORIGEM = 4  AND TIPO_PGTO = 'Y' THEN C.VALOR_TOTAL -  ISNULL(C.DESCONTO, 0.00) ELSE VALOR END AS  VALOR
                 , VENCIMENTO
                 , NUMERO_TITULO
                 , MOEDA
                 , AGENCIA
                 , BANCO
                 , CONTA_CORRENTE
                 , NUMERO_APROVACAO_CARTAO
                 , PARCELAS_CARTAO
                 , DATA_HORA_TEF
                 , CASE
                              WHEN TIPO_PGTO IN ('Y'
                                               , 'W')
                                         THEN 'OMS-' + NUMERO_TITULO + '-' + C.CHANNEL_ID
                              WHEN TIPO_PGTO ='>'
                                         THEN A.CHEQUE_CARTAO
                                         ELSE LTRIM(RTRIM(@PCODIGO_FILIAL_ORIGEM)) + '-' + LTRIM(RTRIM(@TERMINAL)) + '-' + LTRIM(RTRIM(@LANCAMENTO_CAIXA)) + '-' + LTRIM(RTRIM(PARCELA))
                   END
                 , TROCO
                 , --#14#
                   GETDATE()
                 ,
                   /*INÍCIO DO TRATAMENTO #15#*/
                   CASE
                              WHEN A.CODIGO_ADMINISTRADORA   IS NOT NULL
                                         AND B.COD_CREDENCIADORA IS NULL
                                         THEN '999'
                              WHEN A.CODIGO_ADMINISTRADORA       IS NOT NULL
                                         AND B.COD_CREDENCIADORA IS NOT NULL
                                         THEN B.COD_CREDENCIADORA
                                         ELSE NULL
                   END AS COD_CREDENCIADORA
                 , A.FINALIZACAO
                 , B.REDE_CONTROLADORA
        FROM
                   LOJA_PEDIDO_PGTO A
                   INNER JOIN
                              LOJA_PEDIDO C
                              ON
                                         A.PEDIDO                   = C.PEDIDO
                                         AND A.CODIGO_FILIAL_ORIGEM = C.CODIGO_FILIAL_ORIGEM
                   LEFT JOIN
                              ADMINISTRADORAS_CARTAO B
                              ON
                                         A.CODIGO_ADMINISTRADORA = B.CODIGO_ADMINISTRADORA
                   /*FIM DO TRATAMENTO #15#*/
        WHERE
                   A.PEDIDO                   = @PPEDIDO
                   AND A.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM IF( @@ROWCOUNT = 0 ) BEGIN
        INSERT INTO LOJA_VENDA_PARCELAS
               (TERMINAL
                    , LANCAMENTO_CAIXA
                    , CODIGO_FILIAL
                    , PARCELA
                    , CODIGO_ADMINISTRADORA
                    , TIPO_PGTO
                    , VALOR
                    , VENCIMENTO
                    , NUMERO_TITULO
                    , MOEDA
                    , AGENCIA
                    , BANCO
                    , CONTA_CORRENTE
                    , NUMERO_APROVACAO_CARTAO
                    , PARCELAS_CARTAO
                    , DATA_HORA_TEF
                    , CHEQUE_CARTAO
                    , TROCO
                    , --#14#
                      DATA_PARA_TRANSFERENCIA
                    , COD_CREDENCIADORA
                    , FINALIZACAO
                    , REDE_CONTROLADORA
               )
        SELECT
               @TERMINAL
             , @LANCAMENTO_CAIXA
             , @PCODIGO_FILIAL_ORIGEM
             , '01'
             , NULL
             , 'D'
             , 0
             , DATEADD(MONTH, 1, GETDATE())
             , NULL
             , 'R$'
             , NULL
             , NULL
             , NULL
             , NULL
             , 0
             , NULL
             , LTRIM(RTRIM(@PCODIGO_FILIAL_ORIGEM)) + '-' + LTRIM(RTRIM(@TERMINAL)) + '-' + LTRIM(RTRIM(@LANCAMENTO_CAIXA)) + '-01'
             , 0
             , GETDATE()
             , NULL
             , NULL
             , NULL
 END
        INSERT INTO LOJA_VENDA_VENDEDORES
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , ID_VENDEDOR
                    , VENDEDOR
                    , COMISSAO
                    , DATA_PARA_TRANSFERENCIA
                    , TIPO_VENDEDOR
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
             , ISNULL(
               (
                      SELECT
                             TOP 1 ID_VENDEDOR
                      FROM
                             #TMP_LOJA_PEDIDO_PRODUTO
                      WHERE
                             PEDIDO                    = @PPEDIDO
                             AND CODIGO_FILIAL_ORIGEM  = @PCODIGO_FILIAL_ORIGEM
                             AND INDICA_ENTREGA_FUTURA = 0
               )
               , 0.00)
             , (
                      SELECT
                             VENDEDOR
                      FROM
                             LOJA_PEDIDO
                      WHERE
                             PEDIDO                   = @PPEDIDO
                             AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
               )
             , NULL
             , GETDATE()
             , 1
        /*ALIMENTA A TABELA LOJA_VENDA_PROMOCAO*/
        INSERT INTO LOJA_VENDA_PROMOCAO
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , ID_PROMOCAO
                    , ITEM
                    , DESC_PROMOCAO
                    , CAMPANHA
                    , PRECO_UNITARIO
                    , VALOR_DESCONTO
                    , ID_BENEFICIO
                    , VERSAO_MAPA
                    , QTDE
                    , BASE_CALCULO
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
             , A.ID_PROMOCAO
             , A.ITEM
             , A.DESC_PROMOCAO
             , A.CAMPANHA
             , A.PRECO_UNITARIO
             , A.VALOR_DESCONTO
             , A.ID_BENEFICIO
             , A.VERSAO_MAPA
             , A.QTDE
             , A.BASE_CALCULO
        FROM
               LOJA_PEDIDO_VENDA_PROMOCAO A
        WHERE
               A.PEDIDO                   = @PPEDIDO
               AND A.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
        /*INSERT LOJA_VENDA_PROMOCAO_CUPOM  */
        INSERT INTO LOJA_VENDA_PROMOCAO_CUPOM
               ( CODIGO_FILIAL
                    , TICKET
                    , DATA_HORA
                    , ID_PROMOCAO
                    , CODIGO_CUPOM
                    , PREFIXO_CUPOM
                    , TERMINAL
                    , STATUS_CUPOM
                    , MENSAGEM_RETORNO
                    , DATA_PARA_TRANSFERENCIA
                    , DATA_VENDA
                    , VOUCHER_NUMBER
                    , COUPON_ID
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , DATA_PEDIDO
             , ID_PROMOCAO
             , SUBSTRING(VOUCHER_NUMBER,1,10)
             , SUBSTRING(COUPON_ID,1,5)
             , @TERMINAL
             , STATUS_CUPOM
             , MENSAGEM_RETORNO
             , GETDATE()
             , DATA_PEDIDO
             , VOUCHER_NUMBER
             , COUPON_ID
        FROM
               LOJA_PEDIDO_VENDA_PROMOCAO_CUPOM
        WHERE
               CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
               AND PEDIDO    = @PPEDIDO
               AND TERMINAL  = @TERMINAL
        /*INSERT INTO  LOJA_GIFT_TRANSACAO */
        INSERT INTO LOJA_GIFT_TRANSACAO
               ( CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , NUMERO_CARTAO
                    , CNPJ
                    , TIPO_REQUISICAO
                    , VALOR
                    , PIN
                    , CODIGO_TRANSACAO
                    , DATA_HORA_TRANSACAO
                    , NSU
                    , NSU_HOST
                    , PEDIDO
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
             , A.NUMERO_CARTAO
             , A.CNPJ
             , A.TIPO_REQUISICAO
             , A.VALOR
             , A.PIN
             , A.NSU
             , A.DATA_HORA_TRANSACAO
             , A.NSU
             , A.NSU
             , A.PEDIDO
        FROM
               LOJA_PEDIDO_GIFT_TRANSACAO A
        WHERE
               A.PEDIDO            = @PPEDIDO
               AND A.CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM
        /*INSERT LOJA_VENDA_TROCA_TICKET  */
        INSERT INTO LOJA_VENDA_TROCA_TICKET
               (CODIGO_FILIAL
                    , TICKET
                    , DATA_VENDA
                    , CODIGO_BARRA
                    , PRECO_LIQUIDO
                    , ITEM
                    , DESCONTO_ITEM
                    , FATOR_DESCONTO_VENDA
                    , DATA_PARA_TRANSFERENCIA
               )
        SELECT
               @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
             , A.CODIGO_BARRA
             , A.PRECO_LIQUIDO
             , A.ITEM
             , A.DESCONTO_ITEM
             , C.FATOR_DESCONTO_VENDA
             , GETDATE()
        FROM
               #TMP_LOJA_PEDIDO_PRODUTO A
               JOIN
                      LOJA_PEDIDO_VENDA B
                      ON
                             A.PEDIDO                   = B.PEDIDO
                             AND A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
                             AND A.ITEM                 = B.ITEM
               JOIN
                      LOJA_VENDA_PRODUTO C
                      ON
                             B.TICKET                   = C.TICKET
                             AND B.DATA_VENDA           = C.DATA_VENDA
                             AND C.ITEM                 = B.ITEM_VENDA
                             AND B.CODIGO_FILIAL_ORIGEM = C.CODIGO_FILIAL
        WHERE
               A.CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
               AND A.PEDIDO           = @PPEDIDO
               AND EMBRULHA_PRESENTE  =1 EXEC LX_RECALCULA_COMISSAO @PCODIGO_FILIAL_ORIGEM
             , @TICKET
             , @DATA_VENDA
        UPDATE
               LOJA_PEDIDO
        SET    ENTREGUE = 1
        WHERE
               PEDIDO                   = @PPEDIDO
               AND CODIGO_FILIAL_ORIGEM = @PCODIGO_FILIAL_ORIGEM
               -- RAFAEL FERREIRA - #10#
               DECLARE @COLUM VARCHAR(20)
             , @TABLE         VARCHAR(20)
        SET    @TABLE ='LOJA_PEDIDO'
        SET    @COLUM ='SITUACAO_OMS'
               -- SHELL WILKERSON - #11# INICIO
               IF EXISTS
               (
                      SELECT
                             1
                      FROM
                             #TMP_LOJA_PEDIDO_PRODUTO
                      WHERE
                             PEDIDO                    = @PPEDIDO
                             AND CODIGO_FILIAL_ORIGEM  = @PCODIGO_FILIAL_ORIGEM
                             AND INDICA_ENTREGA_FUTURA = 1
               )
               AND EXISTS
               (
                      SELECT
                             1
                      FROM
                             INFORMATION_SCHEMA.COLUMNS
                      WHERE
                             COLUMN_NAME    = @COLUM
                             AND TABLE_NAME = @TABLE
               )
               BEGIN EXEC('UPDATE LOJA_PEDIDO SET SITUACAO_OMS = 3 WHERE  PEDIDO=' + @PPEDIDO +'AND	 CODIGO_FILIAL_ORIGEM=' +'''' + @PCODIGO_FILIAL_ORIGEM +''''+'	') -- RAFAEL FERREIRA - #10# FIM
 END
 -- SHELL WILKERSON - #11# FIM
 IF EXISTS
 (
        SELECT
               1
        FROM
               LOJA_PEDIDO
        WHERE
               PEDIDO                  =@PPEDIDO
               AND CODIGO_FILIAL_ORIGEM=@PCODIGO_FILIAL_ORIGEM
               AND DESCONTO      IS NULL
 )
 BEGIN
        UPDATE
               LOJA_PEDIDO
        SET    DESCONTO =0.00
        WHERE
               PEDIDO                   = @PPEDIDO
               AND CODIGO_FILIAL_ORIGEM =@PCODIGO_FILIAL_ORIGEM --#9#
 END COMMIT TRANSACTION MAN_VENDA
SET    @ISVALID              = 1 EXEC LX_MOB_VALIDAVALORESPEDIDO @PEDIDO=@PPEDIDO
     , @CODIGO_FILIAL_ORIGEM =@PCODIGO_FILIAL_ORIGEM
     , @PEDIDOVALIDO         = @ISVALID OUTPUT IF(@ISVALID =1) BEGIN
        SELECT
               CAST(1 AS BIT) AS BSUCESS
             , @TICKET        AS TICKET
             , @DATA_VENDA    AS DATA_VENDA
             , 0              AS ERRORNUMBER
             , ''             AS ERRORMESSAGE
 END ELSE                        BEGIN
        SELECT
               CAST(0 AS BIT)                                                                                             AS BSUCESS
             , @TICKET                                                                                                    AS TICKET
             , @DATA_VENDA                                                                                                AS DATA_VENDA
             , 0                                                                                                          AS ERRORNUMBER
             , 'EXISTEM DIVERGENCIAS ENTRE VALORES DO PEDIDO , ITENS DO PEDIDO E PAGAMENTO DO PEDIDO.POR FAVOR VERIFIQUE' AS ERRORMESSAGE
 END
END TRY BEGIN CATCH ROLLBACK TRANSACTION MAN_VENDA
        SELECT
               CAST(0 AS BIT)  AS BSUCESS
             , @TICKET         AS TICKET
             , @DATA_VENDA     AS DATA_VENDA
             , ERROR_NUMBER()  AS ERRORNUMBER
             , ERROR_MESSAGE() AS ERRORMESSAGE
        ;
    
    END CATCH;
END
END
END 
