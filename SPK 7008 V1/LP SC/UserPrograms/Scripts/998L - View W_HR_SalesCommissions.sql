IF EXISTS ( SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'W_HR_SalesCommissions')
BEGIN
	DROP VIEW W_HR_SalesCommissions
END

exec('
CREATE VIEW [dbo].[W_HR_SalesCommissions] 
AS 
  SELECT A.codigo_filial, 
         A.ticket, 
         A.data_venda, 
         A.codigo_cliente, 
         E.filial, 
         C.vendedor, 
         D.vendedor_apelido, 
         D.nome_vendedor, 
         D.codigo_filial              AS CODIGO_FILIAL_VENDEDOR, 
         Sum(Isnull(F.qtde_venda, 0)) AS PECAS_PRODUTO, 
         Sum(Isnull(F.qtde_troca, 0)) AS PECAS_TROCA, 
         Sum(Isnull(CASE 
                      WHEN F.valor < 0 THEN 0.00 
                      ELSE F.valor 
                    END, 0.00))       AS VALOR_VENDA_BRUTA, 
         Sum(Isnull(CASE 
                      WHEN F.valor > 0 THEN 0.00 
                      ELSE Abs(F.valor) 
                    END, 0.00))       AS VALOR_TROCA, 
         Sum(Isnull(CASE 
                      WHEN F.valor < 0 THEN F.valor 
                      ELSE Isnull(F.valor * ( 1 - CASE 
                                                    WHEN A.valor_venda_bruta = 
                                                         0.00 THEN 
                                                    0.00 
                                                    ELSE ( A.valor_venda_bruta - 
                                                           A.valor_troca - 
                                                           A.valor_pago ) / 
                                                         A.valor_venda_bruta 
                                                  END ), 0.00) 
                    END, 0.00))       AS VALOR_VENDA, 
         Sum(CASE 
               WHEN F.valor < 0 THEN 0.00 
               ELSE Isnull(F.valor * CASE 
                                       WHEN A.valor_venda_bruta = 0 THEN 1.00 
                                       ELSE ( A.valor_pago / 
                                            A.valor_venda_bruta ) 
                                     END, 0.00) 
             END)                     AS VALOR_LIQUIDO_VENDA, 
         0                            AS VENDA_SHOWROOMING 
  FROM   loja_venda A 
         INNER JOIN loja_venda_pgto B 
                 ON A.codigo_filial_pgto = B.codigo_filial 
                    AND A.terminal_pgto = B.terminal 
                    AND A.lancamento_caixa = B.lancamento_caixa 
         INNER JOIN loja_venda_vendedores C 
                 ON A.codigo_filial = C.codigo_filial 
                    AND A.ticket = C.ticket 
                    AND A.data_venda = C.data_venda 
         INNER JOIN loja_vendedores D 
                 ON C.vendedor = D.vendedor 
         INNER JOIN lojas_varejo E 
                 ON A.codigo_filial = E.codigo_filial 
         LEFT JOIN (SELECT A.codigo_filial, 
                           A.ticket, 
                           A.data_venda, 
                           A.item, 
                           A.id_vendedor, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE CONVERT(NUMERIC(14, 2), A.qtde / 
                                  CONVERT(NUMERIC(14, 2), 
                                  Count(B.vendedor))) 
                           END                        AS QTDE, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE A.qtde * A.preco_liquido / Count(B.vendedor) 
                           END                        AS VALOR, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE CONVERT(NUMERIC(14, 2), A.qtde / 
                                  CONVERT(NUMERIC(14, 2), 
                                  Count(B.vendedor))) 
                           END                        AS QTDE_VENDA, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 1 
                             ELSE CONVERT(NUMERIC(14, 2), 1 / 
                                  CONVERT(NUMERIC(14, 2), Count(B.vendedor))) 
                           END                        AS QTDE_ITENS, 
                           CONVERT(NUMERIC(14, 2), 0) AS QTDE_TROCA 
                    FROM   loja_venda_produto A 
                           LEFT JOIN loja_venda_vendedores B 
                                  ON A.codigo_filial = B.codigo_filial 
                                     AND A.ticket = B.ticket 
                                     AND A.data_venda = B.data_venda 
                                     AND A.id_vendedor = B.id_vendedor 
                    WHERE  ( A.item_excluido = 0 
                              OR A.item_excluido IS NULL ) 
                           AND A.qtde_cancelada = 0 
                    GROUP  BY A.codigo_filial, 
                              A.ticket, 
                              A.data_venda, 
                              A.item, 
                              A.id_vendedor, 
                              A.qtde, 
                              A.preco_liquido 
                    UNION 
                    SELECT A.codigo_filial, 
                           A.ticket, 
                           A.data_venda, 
                           A.item, 
                           A.id_vendedor, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE CONVERT(NUMERIC(14, 2), A.qtde / 
                                  CONVERT(NUMERIC(14, 2), 
                                  Count(B.vendedor))) * 
                                  -1 
                           END                        AS QTDE, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE A.qtde * A.preco_liquido / Count(B.vendedor) * 
                                  -1 
                           END                        AS VALOR, 
                           CONVERT(NUMERIC(14, 2), 0) AS QTDE_VENDA, 
                           CONVERT(NUMERIC(14, 2), 0) AS QTDE_ITENS, 
                           CASE Count(B.vendedor) 
                             WHEN 0 THEN 0 
                             ELSE CONVERT(NUMERIC(14, 2), A.qtde / 
                                  CONVERT(NUMERIC(14, 2), 
                                  Count(B.vendedor))) * 
                                  -1 
                           END                        AS QTDE_TROCA 
                    FROM   loja_venda_troca A 
                           LEFT JOIN loja_venda_vendedores B 
                                  ON A.codigo_filial = B.codigo_filial 
                                     AND A.ticket = B.ticket 
                                     AND A.data_venda = B.data_venda 
                                     AND A.id_vendedor = B.id_vendedor 
                    WHERE  ( A.item_excluido = 0 
                              OR A.item_excluido IS NULL ) 
                           AND A.qtde_cancelada = 0 
                    GROUP  BY A.codigo_filial, 
                              A.ticket, 
                              A.data_venda, 
                              A.item, 
                              A.id_vendedor, 
                              A.qtde, 
                              A.preco_liquido) F 
                ON C.codigo_filial = F.codigo_filial 
                   AND C.ticket = F.ticket 
                   AND C.data_venda = F.data_venda 
                   AND C.id_vendedor = F.id_vendedor 
  WHERE  A.data_hora_cancelamento IS NULL 
         AND A.qtde_total > 0 
  GROUP  BY A.codigo_filial, 
            A.ticket, 
            A.data_venda, 
            A.codigo_cliente, 
            E.filial, 
            C.vendedor, 
            D.vendedor_apelido, 
            D.nome_vendedor, 
            D.comissao, 
            D.codigo_filial 
  UNION ALL 
  SELECT loja_venda_showroomer.codigo_filial AS CODIGO_FILIAL, 
         loja_venda_showroomer.ticket        AS TICKET, 
         loja_venda_showroomer.data_venda, 
         loja_pedido.codigo_cliente, 
         filiais.filial, 
         loja_vendedores.vendedor, 
         loja_vendedores.vendedor_apelido, 
         loja_vendedores.nome_vendedor, 
         loja_venda_showroomer.codigo_filial AS CODIGO_FILIAL_VENDEDOR, 
         loja_pedido.qtde_total              AS PECAS_PRODUTO, 
         0                                   AS PECAS_TROCA, 
         loja_venda_showroomer.valor_pago    AS VALOR_VENDA_BRUTA, 
         0                                   AS VALOR_TROCA, 
         loja_venda_showroomer.valor_pago    AS VALOR_VENDA, 
         loja_venda_showroomer.valor_pago    AS VALOR_LIQUIDO_VENDA, 
         1                                   AS VENDA_SHOWROOMING 
  FROM   loja_pedido 
         INNER JOIN loja_venda_showroomer 
                 ON loja_pedido.codigo_filial_origem = 
                    loja_venda_showroomer.codigo_filial 
                    AND loja_pedido.pedido = loja_venda_showroomer.pedido 
         INNER JOIN filiais 
                 ON loja_pedido.codigo_filial_origem = filiais.cod_filial 
         INNER JOIN loja_vendedores 
                 ON loja_vendedores.vendedor = loja_pedido.vendedor 
  WHERE  loja_pedido.lx_pedido_origem = 5 
         AND loja_pedido.tipo_pedido = 1 
         AND loja_pedido.cancelado = 0 
         AND loja_pedido.entregue = 1 
         AND loja_pedido.situacao_oms = 3 
         AND EXISTS(SELECT 1 
                    FROM   loja_venda_showroomer lvs 
                           INNER JOIN loja_venda lv 
                                   ON lv.codigo_filial = lvs.codigo_filial 
                                      AND lv.ticket = lvs.ticket 
                                      AND lv.data_venda = lvs.data_venda 
                    WHERE  loja_pedido.pedido = LVS.pedido 
                           AND loja_pedido.codigo_filial_origem = 
                               lvs.codigo_filial 
                           AND lv.data_hora_cancelamento IS NULL)')