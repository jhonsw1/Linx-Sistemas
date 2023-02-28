IF NOT EXISTS( SELECT 1 from sys.objects where name ='LX_MOBI_SALE')

BEGIN
	EXEC('
CREATE PROCEDURE [dbo].[LX_MOBI_SALE] @PPEDIDO               INT, 
                                      @PCODIGO_FILIAL_ORIGEM CHAR(6), 
                                      @TERMINAL              CHAR(3) 
AS 
  BEGIN 
      SET nocount ON 

      DECLARE @ENTREGA INT 

      SELECT TOP 1 @ENTREGA = entregue 
      FROM   loja_pedido 
      WHERE  pedido = @PPEDIDO 
             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

      IF @ENTREGA IS NOT NULL 
        BEGIN 
            IF @ENTREGA = 1 
              BEGIN 
                  SELECT Cast(1 AS BIT) AS BSUCESS, 
                         ticket, 
                         data_venda 
                  FROM   loja_pedido_venda 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                  UNION 
                  SELECT Cast(status AS BIT) AS BSUCESS, 
                         ticket, 
                         data_venda 
                  FROM   loja_venda_showroomer 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial = @PCODIGO_FILIAL_ORIGEM 
              END 
            ELSE 
              BEGIN 
                  BEGIN TRANSACTION man_venda 

                  DECLARE @TB_TICKET TABLE 
                    ( 
                       ticket CHAR(8) 
                    ) 
                  DECLARE @TB_NF_NUMERO TABLE 
                    ( 
                       nf_numero CHAR(15) 
                    ) 
                  DECLARE @PERIOD_CASH TABLE 
                    ( 
                       cashoperator CHAR(4), 
                       period       CHAR(2), 
                       status       INT 
                    ) 
                  DECLARE @TICKET CHAR(8) 
                  DECLARE @DATA_VENDA DATETIME 
                  DECLARE @VALOR_ATUAL VARCHAR(100) 
                  DECLARE @NF_NUMERO CHAR(15) 
                  DECLARE @SERIE_NF CHAR(6) 
                  DECLARE @LANCAMENTO_CAIXA CHAR(7) 
                  DECLARE @CAIXA_VENDEDOR CHAR(4) 
                  DECLARE @PERIOD_TERMINAL CHAR(03) 

                  --SET @CAIXA_VENDEDOR = (SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''COD_GERENTE_LOJA'')   
                  SET @CAIXA_VENDEDOR = (SELECT TOP 1 valor_atual 
                                         FROM   parametros_loja 
                                         WHERE  parametro = ''COD_GERENTE_LOJA'' 
                                                AND codigo_filial = 
                                                    @PCODIGO_FILIAL_ORIGEM) 

                  --#4#   
                  IF Isnull(@TERMINAL, '''') = '''' 
                    BEGIN 
                        SELECT ''#TERMINAL N√ÉO DEFINIDO - ( LINXPOS )'' AS 
                               ERRORMESSAGE 
                        ; 

                        RETURN 
                    END 

                  SET @DATA_VENDA = Cast(CONVERT(VARCHAR, Getdate(), 112) AS 
                                         DATETIME) 

                  -- BUSCA O VALOR ATUAL     
                  SELECT @VALOR_ATUAL = valor_atual 
                  FROM   parametros_loja 
                  WHERE  parametro = ''SEQUENCIA_TICKET'' 
                         AND codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                  --SET @SERIE_NF = (SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''SERIE_NF_VENDA'') 
                  SET @SERIE_NF = (SELECT TOP 1 valor_atual 
                                   FROM   parametros_loja 
                                   WHERE  parametro = ''SERIE_NF_VENDA'' 
                                          AND codigo_filial = 
                                              @PCODIGO_FILIAL_ORIGEM) 

                  --#4#    
                  INSERT INTO @PERIOD_CASH 
                  EXEC Lx_lj_status_terminal 
                    @PCODIGO_FILIAL_ORIGEM, 
                    @TERMINAL, 
                    @DATA_VENDA, 
                    0 

                  SELECT @PERIOD_TERMINAL = period 
                  FROM   @PERIOD_CASH 

                  INSERT INTO @TB_TICKET 
                  EXEC Sp_getnextticket 
                    @PCODIGO_FILIAL_ORIGEM, 
                    @VALOR_ATUAL, 
                    1, 
                    NULL 

                  SELECT @TICKET = ticket 
                  FROM   @TB_TICKET 

                  DECLARE @FILIAL VARCHAR(25) 

                  SELECT @FILIAL = filial 
                  FROM   lojas_varejo 
                  WHERE  codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                  SET @LANCAMENTO_CAIXA = (SELECT 
                  dbo.Fn_getnextpaymentsequence(@PCODIGO_FILIAL_ORIGEM, 
                  @TERMINAL, 
                                          @DATA_VENDA)) 

                  -- Inicio Customizado 
                  EXEC Sp_hr_vincula_promocao_ticket 
                    @CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM, 
                    @DATA_VENDA = @DATA_VENDA, 
                    @TICKET = @TICKET, 
                    @PEDIDO = @PPEDIDO 

                  -- Adicionado tratamento para ajustar frete gr·tis  
                  DECLARE @DESCONTO    NUMERIC(13, 2) =0, 
                          @BASEFRETE   NUMERIC(13, 2)=0, 
                          @FRETEGRATIS NUMERIC(13, 2)=0, 
                          @FRETETOTAL  NUMERIC(13, 2)=0, 
                          @VALORTOTAL  NUMERIC(13, 2)=0 

                  SELECT @BASEFRETE = CONVERT(NUMERIC(13, 2), 
                                      Isnull(valor_atual, ''0'') 
                                      ) 
                  FROM   parametros 
                  WHERE  parametro = ''HR_CAMPANHA_FRETE'' 

                  SELECT @FRETEGRATIS = Isnull(Sum(Isnull(frete, 0)), 0) 
                  FROM   loja_pedido_entrega 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND ( Upper(opcao_entrega) LIKE ''%"METHODID":"1"%'' 
                                OR Upper(opcao_entrega) LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  SELECT @FRETETOTAL = Isnull(Sum(Isnull(frete, 0)), 0) 
                  FROM   loja_pedido_entrega 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                  SELECT @VALORTOTAL = Isnull(Sum(Isnull(valor_total, 0)), 0) 
                  FROM   loja_pedido 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                  UPDATE loja_pedido 
                  SET    desconto = Isnull(@DESCONTO, 0), 
                         frete = CASE 
                                   WHEN valor_total >= @BASEFRETE THEN 
                                   @FRETETOTAL - @FRETEGRATIS 
                                   ELSE @FRETETOTAL 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND valor_total > 0 

                  UPDATE loja_pedido_entrega 
                  SET    frete = CASE 
                                   WHEN @VALORTOTAL >= @BASEFRETE THEN 0 
                                   ELSE frete 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND @VALORTOTAL > 0 
                         AND ( Upper(opcao_entrega) LIKE ''%"METHODID":"1"%'' 
                                OR Upper(opcao_entrega) LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  UPDATE loja_pedido_entrega_lista 
                  SET    frete = CASE 
                                   WHEN @VALORTOTAL >= @BASEFRETE THEN 0 
                                   ELSE frete 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND @VALORTOTAL > 0 
                         AND ( Upper(CONVERT(VARCHAR(max), opcao_entrega)) LIKE 
                               ''%"METHODID":"1"%'' 
                                OR Upper(CONVERT(VARCHAR(max), opcao_entrega)) 
                                   LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  -- Fim - Customizado  
                  BEGIN try 
                      IF Object_id(''TEMPDB..#TMP_TOTAL_ENTREGA_FUTURA'') IS NOT 
                         NULL 
                        DROP TABLE #tmp_total_entrega_futura --#5#       

                      --#5#       
                      SELECT pedido, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 1 THEN 
                                   A.preco_liquido * qtde 
                                   ELSE 0 
                                 END) AS VALOR_TOTAL_ENTREGA_FUTURA, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 0 THEN 
                                   A.preco_liquido * qtde 
                                   ELSE 0 
                                 END) AS VALOR_TOTAL_PRESENCIAL, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 0 THEN qtde 
                                   ELSE 0 
                                 END) AS QTDE_TOTAL_PRESENCIAL, 
                             indica_entrega_futura 
                      INTO   #tmp_total_entrega_futura 
                      FROM   loja_pedido_produto A WITH (nolock) 
                      WHERE  pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                      GROUP  BY pedido, 
                                indica_entrega_futura 

                      INSERT INTO loja_venda_pgto 
                                  (codigo_filial, 
                                   terminal, 
                                   lancamento_caixa, 
                                   cod_forma_pgto, 
                                   caixa_vendedor, 
                                   digitacao, 
                                   data, 
                                   total_venda, 
                                   periodo_fechamento, 
                                   data_para_transferencia, 
                                   lx_status_venda, 
                                   venda_finalizada,-- #9#  
                                   desconto_pgto) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             cod_forma_pgto, 
                             A.vendedor, 
                             Getdate(), 
                             @DATA_VENDA, 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             @PERIOD_TERMINAL, 
                             Getdate(), 
                             1, 
                             1,--#9#  
                             (SELECT Sum(X.desconto_pgto) 
                              FROM   dbo.loja_pedido_pgto X 
                              WHERE  X.pedido = @PPEDIDO 
                                     AND X.codigo_filial_origem = 
                                         @PCODIGO_FILIAL_ORIGEM 
                             ) 
                      FROM   loja_pedido A 
                             LEFT JOIN #tmp_total_entrega_futura B 
                                    ON A.pedido = B.pedido 
                      WHERE  A.pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND B.indica_entrega_futura = 0 

                      -- SE N√ÉO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                      IF( @@ROWCOUNT = 0 ) 
                        BEGIN 
                            INSERT INTO loja_venda_pgto 
                                        (codigo_filial, 
                                         terminal, 
                                         lancamento_caixa, 
                                         cod_forma_pgto, 
                                         caixa_vendedor, 
                                         digitacao, 
                                         data, 
                                         total_venda, 
                                         periodo_fechamento, 
                                         data_para_transferencia, 
                                         lx_status_venda, 
                                         venda_finalizada -- #9#  
                            ) 
                            SELECT @PCODIGO_FILIAL_ORIGEM, 
                                   @TERMINAL, 
                                   @LANCAMENTO_CAIXA, 
                                   cod_forma_pgto, 
                                   A.vendedor, 
                                   Getdate(), 
                                   @DATA_VENDA, 
                                   0, 
                                   @PERIOD_TERMINAL, 
                                   Getdate(), 
                                   1, 
                                   1 -- #9#  
                            FROM   loja_pedido A WITH (nolock) 
                            WHERE  A.pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        END 

                      INSERT INTO loja_venda 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   codigo_desconto, 
                                   codigo_cliente, 
                                   periodo, 
                                   data_digitacao, 
                                   vendedor, 
                                   operacao_venda, 
                                   codigo_tab_preco, 
                                   comissao, 
                                   desconto, 
                                   qtde_total, 
                                   valor_tiket, 
                                   valor_pago, 
                                   valor_venda_bruta, 
                                   valor_troca, 
                                   qtde_troca_total, 
                                   ticket_impresso, 
                                   terminal, 
                                   gerente_loja, 
                                   gerente_periodo, 
                                   codigo_filial_pgto, 
                                   terminal_pgto, 
                                   lancamento_caixa, 
                                   periodo_fechamento, 
                                   data_para_transferencia, 
                                   valor_frete, 
                                   cpf_cgc_ecf, 
                                   nsu_acumulo_fidelidade, 
                                   lx_venda_origem) 
                      SELECT codigo_filial_origem, 
                             @TICKET, 
                             @DATA_VENDA, 
                             NULL, 
                             codigo_cliente, 
                             NULL, 
                             Getdate(), 
                             vendedor, 
                             operacao_venda, 
                             codigo_tab_preco, 
                             NULL, 
                             ( valor_total_presencial - Cast( 
                               B.valor_total_presencial * 
                               ( 1 - 
                               Isnull(A.desconto, 0.00) / A.valor_total 
                               ) 
                                                          AS 
                                                          NUMERIC(14, 2) 
                                                        ) ), 
                             qtde_total_presencial, 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             valor_total_presencial, 
                             0, 
                             0, 
                             0, 
                             @TERMINAL, 
                             @CAIXA_VENDEDOR 
                             --,(SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''COD_GERENTE_PERIODO'')   
                             , 
                             (SELECT TOP 1 valor_atual 
                              FROM   parametros_loja 
                              WHERE  parametro = ''COD_GERENTE_PERIODO'' 
                                     AND codigo_filial = @PCODIGO_FILIAL_ORIGEM) 
                             --#5#     
                             , 
                             codigo_filial_origem, 
                             @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PERIOD_TERMINAL, 
                             Getdate(), 
                             0, 
                             cpf_cgc_ecf, 
                             A.nsu_fidelidade, 
                             2 
                      FROM   loja_pedido A 
                             LEFT JOIN #tmp_total_entrega_futura B 
                                    ON A.pedido = B.pedido 
                      WHERE  A.pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND indica_entrega_futura = 0 

                      -- SE N√ÉO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                      IF( @@ROWCOUNT = 0 ) 
                        BEGIN 
                            INSERT INTO loja_venda 
                                        (codigo_filial, 
                                         ticket, 
                                         data_venda, 
                                         codigo_desconto, 
                                         codigo_cliente, 
                                         periodo, 
                                         data_digitacao, 
                                         vendedor, 
                                         operacao_venda, 
                                         codigo_tab_preco, 
                                         comissao, 
                                         desconto, 
                                         qtde_total, 
                                         valor_tiket, 
                                         valor_pago, 
                                         valor_venda_bruta, 
                                         valor_troca, 
                                         qtde_troca_total, 
                                         ticket_impresso, 
                                         terminal, 
                                         gerente_loja, 
                                         gerente_periodo, 
                                         codigo_filial_pgto, 
                                         terminal_pgto, 
                                         lancamento_caixa, 
                                         periodo_fechamento, 
                                         data_para_transferencia, 
                                         valor_frete, 
                                         cpf_cgc_ecf, 
                                         nsu_acumulo_fidelidade, 
                                         lx_venda_origem) 
                            SELECT codigo_filial_origem, 
                                   @TICKET, 
                                   @DATA_VENDA, 
                                   NULL, 
                                   codigo_cliente, 
                                   NULL, 
                                   Getdate(), 
                                   vendedor, 
                                   operacao_venda, 
                                   codigo_tab_preco, 
                                   0.00, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   @TERMINAL, 
                                   @CAIXA_VENDEDOR, 
                                   (SELECT TOP 1 valor_atual 
                                    FROM   parametros_loja 
                                    WHERE  parametro = ''COD_GERENTE_PERIODO'' 
                                           AND codigo_filial = 
                                               @PCODIGO_FILIAL_ORIGEM) 
                                   --#5#         
                                   , 
                                   codigo_filial_origem, 
                                   @TERMINAL, 
                                   @LANCAMENTO_CAIXA, 
                                   @PERIOD_TERMINAL, 
                                   Getdate(), 
                                   0, 
                                   cpf_cgc_ecf, 
                                   A.nsu_fidelidade, 
                                   2 
                            FROM   loja_pedido A WITH (nolock) 
                            WHERE  A.pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        END 

                      INSERT INTO loja_venda_produto 
                                  (ticket, 
                                   codigo_filial, 
                                   data_venda, 
                                   item, 
                                   codigo_barra, 
                                   produto, 
                                   cor_produto, 
                                   tamanho, 
                                   qtde, 
                                   preco_liquido, 
                                   desconto_item, 
                                   data_para_transferencia, 
                                   fator_desconto_venda, 
                                   fator_venda_liq, 
                                   id_vendedor, 
                                   aliquota, 
                                   valor_total, 
                                   qtde_cancelada, 
                                   idpromocao 
                      --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE       
                      ) 
                      SELECT @TICKET, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             @DATA_VENDA, 
                             CASE 
                               WHEN A.item < 10 THEN ''000'' + Cast(A.item AS CHAR 
                                                     ( 
                                                     1 )) 
                               WHEN A.item < 100 THEN ''00'' + Cast(A.item AS CHAR 
                                                      ( 
                                                      2 )) 
                               WHEN A.item < 1000 THEN ''0'' + Cast(A.item AS CHAR 
                                                       ( 
                                                       3 )) 
                               ELSE Cast(A.item AS CHAR(4)) 
                             END, 
                             A.codigo_barra, 
                             A.produto, 
                             A.cor_produto, 
                             A.tamanho, 
                             CASE 
                               WHEN A.cancelado = 1 THEN 0 
                               ELSE A.qtde 
                             END, 
                             A.preco_liquido, 
                             A.desconto_item, 
                             Getdate(), 
                             0.1000, 
                             0.90000, 
                             A.id_vendedor, 
                             A.aliquota, 
                             preco_liquido AS VALOR_TOTAL, 
                             --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE       
                             CASE 
                               WHEN A.cancelado = 0 THEN 0 
                               ELSE A.qtde 
                             END           AS QTDE_CANCELADA, 
                             0             AS ID_PROMOCAO 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido B 
                               ON A.pedido = B.pedido 
                                  AND A.codigo_filial_origem = 
                                      B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.indica_entrega_futura = 0 
                             AND B.tipo_pedido != 99 

                      INSERT INTO loja_pedido_venda 
                                  (pedido, 
                                   codigo_filial_origem, 
                                   item, 
                                   ticket, 
                                   codigo_filial, 
                                   data_venda, 
                                   item_venda, 
                                   data_para_transferencia) 
                      SELECT @PPEDIDO, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             item, 
                             @TICKET, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             @DATA_VENDA, 
                             CASE 
                               WHEN item < 10 THEN ''000'' + Cast(item AS CHAR(1)) 
                               WHEN item < 100 THEN ''00'' + Cast(item AS CHAR(2)) 
                               WHEN item < 1000 THEN ''0'' + Cast(item AS CHAR(3)) 
                               ELSE Cast(item AS CHAR(4)) 
                             END, 
                             Getdate() 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido B 
                               ON A.codigo_filial_origem = 
                                  B.codigo_filial_origem 
                                  AND A.pedido = B.pedido 
                      WHERE  a.pedido = @PPEDIDO 
                             AND a.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND indica_entrega_futura = 0 
                             AND B.tipo_pedido != 99 

                      IF EXISTS (SELECT * 
                                 FROM   information_schema.tables 
                                 WHERE  table_name = N''LOJA_VENDA_SHOWROOMER'') 
                        BEGIN 
                            INSERT INTO loja_venda_showroomer 
                                        (codigo_filial, 
                                         ticket, 
                                         data_venda, 
                                         id_b2c, 
                                         pedido, 
                                         status, 
                                         vale_produto_gerado, 
                                         valor_pago, 
                                         caixa_vendedor) 
                            SELECT @PCODIGO_FILIAL_ORIGEM, 
                                   @TICKET, 
                                   @DATA_VENDA, 
                                   '''', 
                                   @PPEDIDO, 
                                   1, 
                                   Ltrim(Rtrim(@PCODIGO_FILIAL_ORIGEM)) + ''-'' 
                                   + Ltrim(Rtrim(@TERMINAL)) + ''-'' 
                                   + Ltrim(Rtrim(@LANCAMENTO_CAIXA)) + ''-'' + 
                                   ''01'', 
                                   Cast(A.valor_total_entrega_futura * (1 
                                   - Isnull 
                                   ( 
                                   desconto, 
                                   0.00) / 
                                   valor_total) 
                                   AS NUMERIC(14, 2)) 
                                   + Isnull(B.frete, 0.00) AS VALOR_PAGO, 
                                   B.vendedor 
                            FROM   #tmp_total_entrega_futura A 
                                   INNER JOIN loja_pedido B 
                                           ON A.pedido = B.pedido 
                            WHERE  B.pedido = @PPEDIDO 
                                   AND B.codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                                   AND indica_entrega_futura = 1 
                        END 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora, 
                                   finalizacao, 
                                   rede_controladora) 
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             parcela, 
                             A.codigo_administradora, 
                             tipo_pgto, 
                             valor, 
                             vencimento, 
                             numero_titulo, 
                             moeda, 
                             agencia, 
                             banco, 
                             conta_corrente, 
                             numero_aprovacao_cartao, 
                             parcelas_cartao, 
                             data_hora_tef, 
                             CASE 
                               WHEN tipo_pgto IN ( ''Y'', ''W'' ) THEN 
                               ''OMS-'' + numero_titulo + ''-'' + C.channel_id 
                               WHEN tipo_pgto = ''>'' THEN A.cheque_cartao 
                               ELSE Ltrim(Rtrim(@PCODIGO_FILIAL_ORIGEM)) + ''-'' 
                                    + Ltrim(Rtrim(@TERMINAL)) + ''-'' 
                                    + Ltrim(Rtrim(@LANCAMENTO_CAIXA)) + ''-'' 
                                    + Ltrim(Rtrim(parcela)) 
                             END, 
                             troco,--#14#  
                             Getdate(), 
                             /*InÌcio do tratamento #15#*/ 
                             CASE 
                               WHEN A.codigo_administradora IS NOT NULL 
                                    AND B.cod_credenciadora IS NULL THEN ''999'' 
                               WHEN A.codigo_administradora IS NOT NULL 
                                    AND B.cod_credenciadora IS NOT NULL THEN 
                               B.cod_credenciadora 
                               ELSE NULL 
                             END AS COD_CREDENCIADORA, 
                             A.finalizacao, 
                             B.rede_controladora 
                      FROM   loja_pedido_pgto A 
                             INNER JOIN loja_pedido C 
                                     ON A.pedido = C.pedido 
                                        AND A.codigo_filial_origem = 
                                            C.codigo_filial_origem 
                             LEFT JOIN administradoras_cartao B 
                                    ON A.codigo_administradora = 
                                       B.codigo_administradora 
                      /*Fim do tratamento #15#*/ 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      -- Inicio Customizado 
                      DECLARE @PARCELA INT 

                  /* HERING - AJUSTADO PARA INCLUIR PARCELA DE SHOWROOMING E FRETE NO CASO DE VENDAS SHOWROOMING */
                      /* Parcela ShowRooming */ 
                      SELECT @PARCELA = Isnull(Max(A.parcela), 0) 
                      FROM   loja_pedido_pgto A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND Isnumeric(A.parcela) = 1 

                      SET @PARCELA = Isnull(@PARCELA, 0) 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora) --#15#  
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             RIGHT(''00'' 
                                   + CONVERT(VARCHAR(2), Rtrim(Ltrim(@PARCELA + 
                                   Row_number() 
                                   OVER( 
                                   ORDER BY 
                                   B.seq_entrega ASC)))), 2), 
                             NULL                                             AS 
                             CODIGO_ADMINISTRADORA 
                             , 
                             ''Y''                                              AS 
                             TIPO_PGTO, 
                             Cast(( B.valor_total * ( 1 - 
                                    Isnull(A.desconto, 0.00) 
                                    / 
                                    A.valor_total 
                                                    ) ) 
                                  AS 
                                  NUMERIC( 
                                  14, 2)) * -1, 
                             A.data, 
                             B.id_pedido_origem                               AS 
                             NUMERO_TITULO 
                             , 
                             ''R$'' 
                             AS MOEDA, 
                             NULL                                             AS 
                             AGENCIA 
                             , 
                             NULL 
                             AS BANCO, 
                             NULL                                             AS 
                             CONTA_CORRENTE, 
                             B.id_pedido_origem                               AS 
                             NUMERO_APROVACAO_CARTAO, 
                             0                                                AS 
                             PARCELAS_CARTAO, 
                             NULL                                             AS 
                             DATA_HORA_TEF 
                             , 
                             ''OMS-'' + B.id_pedido_origem + ''-'' + A.channel_id 
                             AS CHEQUE_CARTAO, 
                             0.00                                             AS 
                             TROCO 
                             , 
                             Getdate() 
                             AS 
                             DATA_PARA_TRANSFERENCIA, 
                             NULL                                             AS 
                             COD_CREDENCIADORA 
                      FROM   loja_pedido A 
                             INNER JOIN loja_pedido_entrega B 
                                     ON A.pedido = B.pedido 
                                        AND A.codigo_filial_origem = 
                                            B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.lx_pedido_origem = 5 

                      /* Parcela Frete */ 
                      SELECT @PARCELA = Max(A.parcela) 
                      FROM   loja_venda_parcelas A 
                      WHERE  A.lancamento_caixa = @LANCAMENTO_CAIXA 
                             AND A.codigo_filial = @PCODIGO_FILIAL_ORIGEM 
                             AND A.terminal = @TERMINAL 
                             AND Isnumeric(A.parcela) = 1 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora) --#15#  
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             RIGHT(''00'' 
                                   + CONVERT(VARCHAR(2), Rtrim(Ltrim(@PARCELA + 
                                   Row_number() 
                                   OVER( 
                                   ORDER BY 
                                   B.seq_entrega ASC)))), 2), 
                             NULL                                             AS 
                             CODIGO_ADMINISTRADORA 
                             , 
                             ''W''                                              AS 
                             TIPO_PGTO, 
                             B.frete * -1, 
                             A.data, 
                             B.id_pedido_origem                               AS 
                             NUMERO_TITULO 
                             , 
                             ''R$'' 
                             AS MOEDA, 
                             NULL                                             AS 
                             AGENCIA 
                             , 
                             NULL 
                             AS BANCO, 
                             NULL                                             AS 
                             CONTA_CORRENTE, 
                             B.id_pedido_origem                               AS 
                             NUMERO_APROVACAO_CARTAO, 
                             0                                                AS 
                             PARCELAS_CARTAO, 
                             NULL                                             AS 
                             DATA_HORA_TEF 
                             , 
                             ''OMS-'' + B.id_pedido_origem + ''-'' + A.channel_id 
                             AS CHEQUE_CARTAO, 
                             0.00                                             AS 
                             TROCO 
                             , 
                             Getdate() 
                             AS 
                             DATA_PARA_TRANSFERENCIA, 
                             NULL                                             AS 
                             COD_CREDENCIADORA 
                      FROM   loja_pedido A 
                             INNER JOIN loja_pedido_entrega B 
                                     ON A.pedido = B.pedido 
                                        AND A.codigo_filial_origem = 
                                            B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.lx_pedido_origem = 5 

                      -- Fim Customizado 
                      INSERT INTO loja_venda_vendedores 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   id_vendedor, 
                                   vendedor, 
                                   comissao, 
                                   data_para_transferencia, 
                                   tipo_vendedor) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             Isnull((SELECT TOP 1 id_vendedor 
                                     FROM   loja_pedido_produto 
                                     WHERE  pedido = @PPEDIDO 
                                            AND codigo_filial_origem = 
                                                @PCODIGO_FILIAL_ORIGEM 
                                            AND indica_entrega_futura = 0), 0.00 
                             ), 
                             (SELECT vendedor 
                              FROM   loja_pedido 
                              WHERE  pedido = @PPEDIDO 
                                     AND codigo_filial_origem = 
                                         @PCODIGO_FILIAL_ORIGEM 
                             ), 
                             NULL, 
                             Getdate(), 
                             1 

                      /*Alimenta a tabela LOJA_VENDA_PROMOCAO*/ 
                      INSERT INTO loja_venda_promocao 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   id_promocao, 
                                   item, 
                                   desc_promocao, 
                                   campanha, 
                                   preco_unitario, 
                                   valor_desconto, 
                                   id_beneficio, 
                                   versao_mapa, 
                                   qtde, 
                                   base_calculo) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.id_promocao, 
                             A.item, 
                             A.desc_promocao, 
                             A.campanha, 
                             A.preco_unitario, 
                             A.valor_desconto, 
                             A.id_beneficio, 
                             A.versao_mapa, 
                             A.qtde, 
                             A.base_calculo 
                      FROM   loja_pedido_venda_promocao A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      /*INSERT LOJA_VENDA_PROMOCAO_CUPOM  */ 
                      INSERT INTO loja_venda_promocao_cupom 
                                  (codigo_filial, 
                                   ticket, 
                                   data_hora, 
                                   id_promocao, 
                                   codigo_cupom, 
                                   prefixo_cupom, 
                                   terminal, 
                                   status_cupom, 
                                   mensagem_retorno, 
                                   data_para_transferencia, 
                                   data_venda, 
                                   voucher_number, 
                                   coupon_id) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             data_pedido, 
                             id_promocao, 
                             Substring(voucher_number, 1, 10), 
                             Substring(coupon_id, 1, 5), 
                             @TERMINAL, 
                             status_cupom, 
                             mensagem_retorno, 
                             Getdate(), 
                             data_pedido, 
                             voucher_number, 
                             coupon_id 
                      FROM   loja_pedido_venda_promocao_cupom 
                      WHERE  codigo_filial = @PCODIGO_FILIAL_ORIGEM 
                             AND pedido = @PPEDIDO 
                             AND terminal = @TERMINAL 

                      /*INSERT INTO  LOJA_GIFT_TRANSACAO */ 
                      INSERT INTO loja_gift_transacao 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   numero_cartao, 
                                   cnpj, 
                                   tipo_requisicao, 
                                   valor, 
                                   pin, 
                                   codigo_transacao, 
                                   data_hora_transacao, 
                                   nsu, 
                                   nsu_host, 
                                   pedido) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.numero_cartao, 
                             A.cnpj, 
                             A.tipo_requisicao, 
                             A.valor, 
                             A.pin, 
                             A.nsu, 
                             A.data_hora_transacao, 
                             a.nsu, 
                             a.nsu, 
                             A.pedido 
                      FROM   loja_pedido_gift_transacao A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                      /*INSERT LOJA_vENDA_TROCA_TICKET  */ 
                      INSERT INTO loja_venda_troca_ticket 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   codigo_barra, 
                                   preco_liquido, 
                                   item, 
                                   desconto_item, 
                                   fator_desconto_venda, 
                                   data_para_transferencia) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.codigo_barra, 
                             A.preco_liquido, 
                             A.item, 
                             A.desconto_item, 
                             c.fator_desconto_venda, 
                             Getdate() 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido_venda B 
                               ON A.pedido = B.pedido 
                                  AND A.codigo_filial_origem = 
                                      B.codigo_filial_origem 
                                  AND A.item = B.item 
                             JOIN loja_venda_produto C 
                               ON B.ticket = C.ticket 
                                  AND B.data_venda = C.data_venda 
                                  AND C.item = B.item_venda 
                                  AND B.codigo_filial_origem = C.codigo_filial 
                      WHERE  A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.pedido = @PPEDIDO 
                             AND embrulha_presente = 1 

                      EXEC Lx_recalcula_comissao 
                        @PCODIGO_FILIAL_ORIGEM, 
                        @TICKET, 
                        @DATA_VENDA 

                      UPDATE loja_pedido 
                      SET    entregue = 1 
                      WHERE  pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      -- RAFAEL FERREIRA - #10#  
                      DECLARE @COLUM VARCHAR(20), 
                              @TABLE VARCHAR(20) 

                      SET @TABLE =''LOJA_PEDIDO'' 
                      SET @COLUM=''SITUACAO_OMS'' 

                      -- SHELL WILKERSON - #11# INICIO  
                      IF EXISTS (SELECT 1 
                                 FROM   loja_pedido_produto 
                                 WHERE  pedido = @PPEDIDO 
                                        AND codigo_filial_origem = 
                                            @PCODIGO_FILIAL_ORIGEM 
                                        AND indica_entrega_futura = 1) 
                         AND EXISTS (SELECT 1 
                                     FROM   information_schema.columns 
                                     WHERE  column_name = @COLUM 
                                            AND table_name = @TABLE) 
                        BEGIN 
                            EXEC( 
            '' UPDATE  LOJA_PEDIDO     SET   SITUACAO_OMS = 3     WHERE  PEDIDO='' 
                  + 
                  @PPEDIDO + ''     AND   CODIGO_FILIAL_ORIGEM='' + '''''''' + 
                  @PCODIGO_FILIAL_ORIGEM +''''''''+''     '') 
              -- RAFAEL FERREIRA - #10# FIM  
              END 

                      -- SHELL WILKERSON - #11# FIM  
                      IF EXISTS (SELECT 1 
                                 FROM   loja_pedido 
                                 WHERE  pedido = @PPEDIDO 
                                        AND codigo_filial_origem = 
                                            @PCODIGO_FILIAL_ORIGEM 
                                        AND desconto IS NULL) 
                        BEGIN 
                            UPDATE loja_pedido 
                            SET    desconto = 0.00 
                            WHERE  pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        --#9#  
                        END 

                      COMMIT TRANSACTION man_venda 

                      DECLARE @isValid BIT 

                      EXEC Lx_mob_validavalorespedido 
                        @PEDIDO=@PPEDIDO, 
                        @CODIGO_FILIAL_ORIGEM =@PCODIGO_FILIAL_ORIGEM, 
                        @PedidoValido = @isValid output 

                      IF( @isValid = 1 ) 
                        BEGIN 
                            SELECT Cast(1 AS BIT) AS BSUCESS, 
                                   @TICKET        AS TICKET, 
                                   @DATA_VENDA    AS DATA_VENDA, 
                                   0              AS ERRORNUMBER, 
                                   ''''             AS ERRORMESSAGE 
                        END 
                      ELSE 
                        BEGIN 
                            SELECT Cast(0 AS BIT) AS BSUCESS, 
                                   @TICKET        AS TICKET, 
                                   @DATA_VENDA    AS DATA_VENDA, 
                                   0              AS ERRORNUMBER, 
''Existem divergencias entre valores do pedido , itens do pedido e pagamento do pedido.Por favor verifique''
               AS ERRORMESSAGE 
END 
END try 

    BEGIN catch 
        ROLLBACK TRANSACTION man_venda 

        SELECT Cast(0 AS BIT)  AS BSUCESS, 
               @TICKET         AS TICKET, 
               @DATA_VENDA     AS DATA_VENDA, 
               Error_number()  AS ERRORNUMBER, 
               Error_message() AS ERRORMESSAGE; 
    END catch; 
END 
END 
END')
END
ELSE
   BEGIN 
	EXEC ('
	ALTER PROCEDURE [dbo].[LX_MOBI_SALE] @PPEDIDO               INT, 
                                      @PCODIGO_FILIAL_ORIGEM CHAR(6), 
                                      @TERMINAL              CHAR(3) 
AS 
  BEGIN 
      SET nocount ON 

      DECLARE @ENTREGA INT 

      SELECT TOP 1 @ENTREGA = entregue 
      FROM   loja_pedido 
      WHERE  pedido = @PPEDIDO 
             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

      IF @ENTREGA IS NOT NULL 
        BEGIN 
            IF @ENTREGA = 1 
              BEGIN 
                  SELECT Cast(1 AS BIT) AS BSUCESS, 
                         ticket, 
                         data_venda 
                  FROM   loja_pedido_venda 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                  UNION 
                  SELECT Cast(status AS BIT) AS BSUCESS, 
                         ticket, 
                         data_venda 
                  FROM   loja_venda_showroomer 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial = @PCODIGO_FILIAL_ORIGEM 
              END 
            ELSE 
              BEGIN 
                  BEGIN TRANSACTION man_venda 

                  DECLARE @TB_TICKET TABLE 
                    ( 
                       ticket CHAR(8) 
                    ) 
                  DECLARE @TB_NF_NUMERO TABLE 
                    ( 
                       nf_numero CHAR(15) 
                    ) 
                  DECLARE @PERIOD_CASH TABLE 
                    ( 
                       cashoperator CHAR(4), 
                       period       CHAR(2), 
                       status       INT 
                    ) 
                  DECLARE @TICKET CHAR(8) 
                  DECLARE @DATA_VENDA DATETIME 
                  DECLARE @VALOR_ATUAL VARCHAR(100) 
                  DECLARE @NF_NUMERO CHAR(15) 
                  DECLARE @SERIE_NF CHAR(6) 
                  DECLARE @LANCAMENTO_CAIXA CHAR(7) 
                  DECLARE @CAIXA_VENDEDOR CHAR(4) 
                  DECLARE @PERIOD_TERMINAL CHAR(03) 

                  --SET @CAIXA_VENDEDOR = (SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''COD_GERENTE_LOJA'')   
                  SET @CAIXA_VENDEDOR = (SELECT TOP 1 valor_atual 
                                         FROM   parametros_loja 
                                         WHERE  parametro = ''COD_GERENTE_LOJA'' 
                                                AND codigo_filial = 
                                                    @PCODIGO_FILIAL_ORIGEM) 

                  --#4#   
                  IF Isnull(@TERMINAL, '''') = '''' 
                    BEGIN 
                        SELECT ''#TERMINAL N√ÉO DEFINIDO - ( LINXPOS )'' AS 
                               ERRORMESSAGE 
                        ; 

                        RETURN 
                    END 

                  SET @DATA_VENDA = Cast(CONVERT(VARCHAR, Getdate(), 112) AS 
                                         DATETIME) 

                  -- BUSCA O VALOR ATUAL     
                  SELECT @VALOR_ATUAL = valor_atual 
                  FROM   parametros_loja 
                  WHERE  parametro = ''SEQUENCIA_TICKET'' 
                         AND codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                  --SET @SERIE_NF = (SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''SERIE_NF_VENDA'') 
                  SET @SERIE_NF = (SELECT TOP 1 valor_atual 
                                   FROM   parametros_loja 
                                   WHERE  parametro = ''SERIE_NF_VENDA'' 
                                          AND codigo_filial = 
                                              @PCODIGO_FILIAL_ORIGEM) 

                  --#4#    
                  INSERT INTO @PERIOD_CASH 
                  EXEC Lx_lj_status_terminal 
                    @PCODIGO_FILIAL_ORIGEM, 
                    @TERMINAL, 
                    @DATA_VENDA, 
                    0 

                  SELECT @PERIOD_TERMINAL = period 
                  FROM   @PERIOD_CASH 

                  INSERT INTO @TB_TICKET 
                  EXEC Sp_getnextticket 
                    @PCODIGO_FILIAL_ORIGEM, 
                    @VALOR_ATUAL, 
                    1, 
                    NULL 

                  SELECT @TICKET = ticket 
                  FROM   @TB_TICKET 

                  DECLARE @FILIAL VARCHAR(25) 

                  SELECT @FILIAL = filial 
                  FROM   lojas_varejo 
                  WHERE  codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                  SET @LANCAMENTO_CAIXA = (SELECT 
                  dbo.Fn_getnextpaymentsequence(@PCODIGO_FILIAL_ORIGEM, 
                  @TERMINAL, 
                                          @DATA_VENDA)) 

                  -- Inicio Customizado 
                  EXEC Sp_hr_vincula_promocao_ticket 
                    @CODIGO_FILIAL = @PCODIGO_FILIAL_ORIGEM, 
                    @DATA_VENDA = @DATA_VENDA, 
                    @TICKET = @TICKET, 
                    @PEDIDO = @PPEDIDO 

                  -- Adicionado tratamento para ajustar frete gr·tis  
                  DECLARE @DESCONTO    NUMERIC(13, 2) =0, 
                          @BASEFRETE   NUMERIC(13, 2)=0, 
                          @FRETEGRATIS NUMERIC(13, 2)=0, 
                          @FRETETOTAL  NUMERIC(13, 2)=0, 
                          @VALORTOTAL  NUMERIC(13, 2)=0 

                  SELECT @BASEFRETE = CONVERT(NUMERIC(13, 2), 
                                      Isnull(valor_atual, ''0'') 
                                      ) 
                  FROM   parametros 
                  WHERE  parametro = ''HR_CAMPANHA_FRETE'' 

                  SELECT @FRETEGRATIS = Isnull(Sum(Isnull(frete, 0)), 0) 
                  FROM   loja_pedido_entrega 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND ( Upper(opcao_entrega) LIKE ''%"METHODID":"1"%'' 
                                OR Upper(opcao_entrega) LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  SELECT @FRETETOTAL = Isnull(Sum(Isnull(frete, 0)), 0) 
                  FROM   loja_pedido_entrega 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                  SELECT @VALORTOTAL = Isnull(Sum(Isnull(valor_total, 0)), 0) 
                  FROM   loja_pedido 
                  WHERE  pedido = @PPEDIDO 
                         AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                  UPDATE loja_pedido 
                  SET    desconto = Isnull(@DESCONTO, 0), 
                         frete = CASE 
                                   WHEN valor_total >= @BASEFRETE THEN 
                                   @FRETETOTAL - @FRETEGRATIS 
                                   ELSE @FRETETOTAL 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND valor_total > 0 

                  UPDATE loja_pedido_entrega 
                  SET    frete = CASE 
                                   WHEN @VALORTOTAL >= @BASEFRETE THEN 0 
                                   ELSE frete 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND @VALORTOTAL > 0 
                         AND ( Upper(opcao_entrega) LIKE ''%"METHODID":"1"%'' 
                                OR Upper(opcao_entrega) LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  UPDATE loja_pedido_entrega_lista 
                  SET    frete = CASE 
                                   WHEN @VALORTOTAL >= @BASEFRETE THEN 0 
                                   ELSE frete 
                                 END 
                  WHERE  codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                         AND pedido = @PPEDIDO 
                         AND @VALORTOTAL > 0 
                         AND ( Upper(CONVERT(VARCHAR(max), opcao_entrega)) LIKE 
                               ''%"METHODID":"1"%'' 
                                OR Upper(CONVERT(VARCHAR(max), opcao_entrega)) 
                                   LIKE 
                                   ''%"METHOD":"ENTREGA NORMAL"%'' ) 

                  -- Fim - Customizado  
                  BEGIN try 
                      IF Object_id(''TEMPDB..#TMP_TOTAL_ENTREGA_FUTURA'') IS NOT 
                         NULL 
                        DROP TABLE #tmp_total_entrega_futura --#5#       

                      --#5#       
                      SELECT pedido, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 1 THEN 
                                   A.preco_liquido * qtde 
                                   ELSE 0 
                                 END) AS VALOR_TOTAL_ENTREGA_FUTURA, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 0 THEN 
                                   A.preco_liquido * qtde 
                                   ELSE 0 
                                 END) AS VALOR_TOTAL_PRESENCIAL, 
                             Sum(CASE 
                                   WHEN A.indica_entrega_futura = 0 THEN qtde 
                                   ELSE 0 
                                 END) AS QTDE_TOTAL_PRESENCIAL, 
                             indica_entrega_futura 
                      INTO   #tmp_total_entrega_futura 
                      FROM   loja_pedido_produto A WITH (nolock) 
                      WHERE  pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                      GROUP  BY pedido, 
                                indica_entrega_futura 

                      INSERT INTO loja_venda_pgto 
                                  (codigo_filial, 
                                   terminal, 
                                   lancamento_caixa, 
                                   cod_forma_pgto, 
                                   caixa_vendedor, 
                                   digitacao, 
                                   data, 
                                   total_venda, 
                                   periodo_fechamento, 
                                   data_para_transferencia, 
                                   lx_status_venda, 
                                   venda_finalizada,-- #9#  
                                   desconto_pgto) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             cod_forma_pgto, 
                             A.vendedor, 
                             Getdate(), 
                             @DATA_VENDA, 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             @PERIOD_TERMINAL, 
                             Getdate(), 
                             1, 
                             1,--#9#  
                             (SELECT Sum(X.desconto_pgto) 
                              FROM   dbo.loja_pedido_pgto X 
                              WHERE  X.pedido = @PPEDIDO 
                                     AND X.codigo_filial_origem = 
                                         @PCODIGO_FILIAL_ORIGEM 
                             ) 
                      FROM   loja_pedido A 
                             LEFT JOIN #tmp_total_entrega_futura B 
                                    ON A.pedido = B.pedido 
                      WHERE  A.pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND B.indica_entrega_futura = 0 

                      -- SE N√ÉO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                      IF( @@ROWCOUNT = 0 ) 
                        BEGIN 
                            INSERT INTO loja_venda_pgto 
                                        (codigo_filial, 
                                         terminal, 
                                         lancamento_caixa, 
                                         cod_forma_pgto, 
                                         caixa_vendedor, 
                                         digitacao, 
                                         data, 
                                         total_venda, 
                                         periodo_fechamento, 
                                         data_para_transferencia, 
                                         lx_status_venda, 
                                         venda_finalizada -- #9#  
                            ) 
                            SELECT @PCODIGO_FILIAL_ORIGEM, 
                                   @TERMINAL, 
                                   @LANCAMENTO_CAIXA, 
                                   cod_forma_pgto, 
                                   A.vendedor, 
                                   Getdate(), 
                                   @DATA_VENDA, 
                                   0, 
                                   @PERIOD_TERMINAL, 
                                   Getdate(), 
                                   1, 
                                   1 -- #9#  
                            FROM   loja_pedido A WITH (nolock) 
                            WHERE  A.pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        END 

                      INSERT INTO loja_venda 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   codigo_desconto, 
                                   codigo_cliente, 
                                   periodo, 
                                   data_digitacao, 
                                   vendedor, 
                                   operacao_venda, 
                                   codigo_tab_preco, 
                                   comissao, 
                                   desconto, 
                                   qtde_total, 
                                   valor_tiket, 
                                   valor_pago, 
                                   valor_venda_bruta, 
                                   valor_troca, 
                                   qtde_troca_total, 
                                   ticket_impresso, 
                                   terminal, 
                                   gerente_loja, 
                                   gerente_periodo, 
                                   codigo_filial_pgto, 
                                   terminal_pgto, 
                                   lancamento_caixa, 
                                   periodo_fechamento, 
                                   data_para_transferencia, 
                                   valor_frete, 
                                   cpf_cgc_ecf, 
                                   nsu_acumulo_fidelidade, 
                                   lx_venda_origem) 
                      SELECT codigo_filial_origem, 
                             @TICKET, 
                             @DATA_VENDA, 
                             NULL, 
                             codigo_cliente, 
                             NULL, 
                             Getdate(), 
                             vendedor, 
                             operacao_venda, 
                             codigo_tab_preco, 
                             NULL, 
                             ( valor_total_presencial - Cast( 
                               B.valor_total_presencial * 
                               ( 1 - 
                               Isnull(A.desconto, 0.00) / A.valor_total 
                               ) 
                                                          AS 
                                                          NUMERIC(14, 2) 
                                                        ) ), 
                             qtde_total_presencial, 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             Cast(B.valor_total_presencial * ( 1 - 
                                  Isnull(A.desconto, 0.00) / A.valor_total ) 
                                  AS 
                                  NUMERIC(14, 2)), 
                             valor_total_presencial, 
                             0, 
                             0, 
                             0, 
                             @TERMINAL, 
                             @CAIXA_VENDEDOR 
                             --,(SELECT TOP 1 VALOR_ATUAL FROM PARAMETROS_LOJA WHERE PARAMETRO = ''COD_GERENTE_PERIODO'')   
                             , 
                             (SELECT TOP 1 valor_atual 
                              FROM   parametros_loja 
                              WHERE  parametro = ''COD_GERENTE_PERIODO'' 
                                     AND codigo_filial = @PCODIGO_FILIAL_ORIGEM) 
                             --#5#     
                             , 
                             codigo_filial_origem, 
                             @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PERIOD_TERMINAL, 
                             Getdate(), 
                             0, 
                             cpf_cgc_ecf, 
                             A.nsu_fidelidade, 
                             2 
                      FROM   loja_pedido A 
                             LEFT JOIN #tmp_total_entrega_futura B 
                                    ON A.pedido = B.pedido 
                      WHERE  A.pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND indica_entrega_futura = 0 

                      -- SE N√ÉO CONSEGUIU INSERIR ITENS COM INDICA ENTREGA FUTURA IGUAL A 0, ALIMENTA A TABELA COM OS DADOS IGUAL A ZERO.
                      IF( @@ROWCOUNT = 0 ) 
                        BEGIN 
                            INSERT INTO loja_venda 
                                        (codigo_filial, 
                                         ticket, 
                                         data_venda, 
                                         codigo_desconto, 
                                         codigo_cliente, 
                                         periodo, 
                                         data_digitacao, 
                                         vendedor, 
                                         operacao_venda, 
                                         codigo_tab_preco, 
                                         comissao, 
                                         desconto, 
                                         qtde_total, 
                                         valor_tiket, 
                                         valor_pago, 
                                         valor_venda_bruta, 
                                         valor_troca, 
                                         qtde_troca_total, 
                                         ticket_impresso, 
                                         terminal, 
                                         gerente_loja, 
                                         gerente_periodo, 
                                         codigo_filial_pgto, 
                                         terminal_pgto, 
                                         lancamento_caixa, 
                                         periodo_fechamento, 
                                         data_para_transferencia, 
                                         valor_frete, 
                                         cpf_cgc_ecf, 
                                         nsu_acumulo_fidelidade, 
                                         lx_venda_origem) 
                            SELECT codigo_filial_origem, 
                                   @TICKET, 
                                   @DATA_VENDA, 
                                   NULL, 
                                   codigo_cliente, 
                                   NULL, 
                                   Getdate(), 
                                   vendedor, 
                                   operacao_venda, 
                                   codigo_tab_preco, 
                                   0.00, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   0, 
                                   @TERMINAL, 
                                   @CAIXA_VENDEDOR, 
                                   (SELECT TOP 1 valor_atual 
                                    FROM   parametros_loja 
                                    WHERE  parametro = ''COD_GERENTE_PERIODO'' 
                                           AND codigo_filial = 
                                               @PCODIGO_FILIAL_ORIGEM) 
                                   --#5#         
                                   , 
                                   codigo_filial_origem, 
                                   @TERMINAL, 
                                   @LANCAMENTO_CAIXA, 
                                   @PERIOD_TERMINAL, 
                                   Getdate(), 
                                   0, 
                                   cpf_cgc_ecf, 
                                   A.nsu_fidelidade, 
                                   2 
                            FROM   loja_pedido A WITH (nolock) 
                            WHERE  A.pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        END 

                      INSERT INTO loja_venda_produto 
                                  (ticket, 
                                   codigo_filial, 
                                   data_venda, 
                                   item, 
                                   codigo_barra, 
                                   produto, 
                                   cor_produto, 
                                   tamanho, 
                                   qtde, 
                                   preco_liquido, 
                                   desconto_item, 
                                   data_para_transferencia, 
                                   fator_desconto_venda, 
                                   fator_venda_liq, 
                                   id_vendedor, 
                                   aliquota, 
                                   valor_total, 
                                   qtde_cancelada, 
                                   idpromocao 
                      --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE       
                      ) 
                      SELECT @TICKET, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             @DATA_VENDA, 
                             CASE 
                               WHEN A.item < 10 THEN ''000'' + Cast(A.item AS CHAR 
                                                     ( 
                                                     1 )) 
                               WHEN A.item < 100 THEN ''00'' + Cast(A.item AS CHAR 
                                                      ( 
                                                      2 )) 
                               WHEN A.item < 1000 THEN ''0'' + Cast(A.item AS CHAR 
                                                       ( 
                                                       3 )) 
                               ELSE Cast(A.item AS CHAR(4)) 
                             END, 
                             A.codigo_barra, 
                             A.produto, 
                             A.cor_produto, 
                             A.tamanho, 
                             CASE 
                               WHEN A.cancelado = 1 THEN 0 
                               ELSE A.qtde 
                             END, 
                             A.preco_liquido, 
                             A.desconto_item, 
                             Getdate(), 
                             0.1000, 
                             0.90000, 
                             A.id_vendedor, 
                             A.aliquota, 
                             preco_liquido AS VALOR_TOTAL, 
                             --GRAVANDO O VALOR_TOTAL COM O PRECO_LIQUIDO VENDAS MOBILE       
                             CASE 
                               WHEN A.cancelado = 0 THEN 0 
                               ELSE A.qtde 
                             END           AS QTDE_CANCELADA, 
                             0             AS ID_PROMOCAO 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido B 
                               ON A.pedido = B.pedido 
                                  AND A.codigo_filial_origem = 
                                      B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.indica_entrega_futura = 0 
                             AND B.tipo_pedido != 99 

                      INSERT INTO loja_pedido_venda 
                                  (pedido, 
                                   codigo_filial_origem, 
                                   item, 
                                   ticket, 
                                   codigo_filial, 
                                   data_venda, 
                                   item_venda, 
                                   data_para_transferencia) 
                      SELECT @PPEDIDO, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             item, 
                             @TICKET, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             @DATA_VENDA, 
                             CASE 
                               WHEN item < 10 THEN ''000'' + Cast(item AS CHAR(1)) 
                               WHEN item < 100 THEN ''00'' + Cast(item AS CHAR(2)) 
                               WHEN item < 1000 THEN ''0'' + Cast(item AS CHAR(3)) 
                               ELSE Cast(item AS CHAR(4)) 
                             END, 
                             Getdate() 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido B 
                               ON A.codigo_filial_origem = 
                                  B.codigo_filial_origem 
                                  AND A.pedido = B.pedido 
                      WHERE  a.pedido = @PPEDIDO 
                             AND a.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND indica_entrega_futura = 0 
                             AND B.tipo_pedido != 99 

                      IF EXISTS (SELECT * 
                                 FROM   information_schema.tables 
                                 WHERE  table_name = N''LOJA_VENDA_SHOWROOMER'') 
                        BEGIN 
                            INSERT INTO loja_venda_showroomer 
                                        (codigo_filial, 
                                         ticket, 
                                         data_venda, 
                                         id_b2c, 
                                         pedido, 
                                         status, 
                                         vale_produto_gerado, 
                                         valor_pago, 
                                         caixa_vendedor) 
                            SELECT @PCODIGO_FILIAL_ORIGEM, 
                                   @TICKET, 
                                   @DATA_VENDA, 
                                   '''', 
                                   @PPEDIDO, 
                                   1, 
                                   Ltrim(Rtrim(@PCODIGO_FILIAL_ORIGEM)) + ''-'' 
                                   + Ltrim(Rtrim(@TERMINAL)) + ''-'' 
                                   + Ltrim(Rtrim(@LANCAMENTO_CAIXA)) + ''-'' + 
                                   ''01'', 
                                   Cast(A.valor_total_entrega_futura * (1 
                                   - Isnull 
                                   ( 
                                   desconto, 
                                   0.00) / 
                                   valor_total) 
                                   AS NUMERIC(14, 2)) 
                                   + Isnull(B.frete, 0.00) AS VALOR_PAGO, 
                                   B.vendedor 
                            FROM   #tmp_total_entrega_futura A 
                                   INNER JOIN loja_pedido B 
                                           ON A.pedido = B.pedido 
                            WHERE  B.pedido = @PPEDIDO 
                                   AND B.codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                                   AND indica_entrega_futura = 1 
                        END 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora, 
                                   finalizacao, 
                                   rede_controladora) 
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             parcela, 
                             A.codigo_administradora, 
                             tipo_pgto, 
                             valor, 
                             vencimento, 
                             numero_titulo, 
                             moeda, 
                             agencia, 
                             banco, 
                             conta_corrente, 
                             numero_aprovacao_cartao, 
                             parcelas_cartao, 
                             data_hora_tef, 
                             CASE 
                               WHEN tipo_pgto IN ( ''Y'', ''W'' ) THEN 
                               ''OMS-'' + numero_titulo + ''-'' + C.channel_id 
                               WHEN tipo_pgto = ''>'' THEN A.cheque_cartao 
                               ELSE Ltrim(Rtrim(@PCODIGO_FILIAL_ORIGEM)) + ''-'' 
                                    + Ltrim(Rtrim(@TERMINAL)) + ''-'' 
                                    + Ltrim(Rtrim(@LANCAMENTO_CAIXA)) + ''-'' 
                                    + Ltrim(Rtrim(parcela)) 
                             END, 
                             troco,--#14#  
                             Getdate(), 
                             /*InÌcio do tratamento #15#*/ 
                             CASE 
                               WHEN A.codigo_administradora IS NOT NULL 
                                    AND B.cod_credenciadora IS NULL THEN ''999'' 
                               WHEN A.codigo_administradora IS NOT NULL 
                                    AND B.cod_credenciadora IS NOT NULL THEN 
                               B.cod_credenciadora 
                               ELSE NULL 
                             END AS COD_CREDENCIADORA, 
                             A.finalizacao, 
                             B.rede_controladora 
                      FROM   loja_pedido_pgto A 
                             INNER JOIN loja_pedido C 
                                     ON A.pedido = C.pedido 
                                        AND A.codigo_filial_origem = 
                                            C.codigo_filial_origem 
                             LEFT JOIN administradoras_cartao B 
                                    ON A.codigo_administradora = 
                                       B.codigo_administradora 
                      /*Fim do tratamento #15#*/ 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      -- Inicio Customizado 
                      DECLARE @PARCELA INT 

                  /* HERING - AJUSTADO PARA INCLUIR PARCELA DE SHOWROOMING E FRETE NO CASO DE VENDAS SHOWROOMING */
                      /* Parcela ShowRooming */ 
                      SELECT @PARCELA = Isnull(Max(A.parcela), 0) 
                      FROM   loja_pedido_pgto A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND Isnumeric(A.parcela) = 1 

                      SET @PARCELA = Isnull(@PARCELA, 0) 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora) --#15#  
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             RIGHT(''00'' 
                                   + CONVERT(VARCHAR(2), Rtrim(Ltrim(@PARCELA + 
                                   Row_number() 
                                   OVER( 
                                   ORDER BY 
                                   B.seq_entrega ASC)))), 2), 
                             NULL                                             AS 
                             CODIGO_ADMINISTRADORA 
                             , 
                             ''Y''                                              AS 
                             TIPO_PGTO, 
                             Cast(( B.valor_total * ( 1 - 
                                    Isnull(A.desconto, 0.00) 
                                    / 
                                    A.valor_total 
                                                    ) ) 
                                  AS 
                                  NUMERIC( 
                                  14, 2)) * -1, 
                             A.data, 
                             B.id_pedido_origem                               AS 
                             NUMERO_TITULO 
                             , 
                             ''R$'' 
                             AS MOEDA, 
                             NULL                                             AS 
                             AGENCIA 
                             , 
                             NULL 
                             AS BANCO, 
                             NULL                                             AS 
                             CONTA_CORRENTE, 
                             B.id_pedido_origem                               AS 
                             NUMERO_APROVACAO_CARTAO, 
                             0                                                AS 
                             PARCELAS_CARTAO, 
                             NULL                                             AS 
                             DATA_HORA_TEF 
                             , 
                             ''OMS-'' + B.id_pedido_origem + ''-'' + A.channel_id 
                             AS CHEQUE_CARTAO, 
                             0.00                                             AS 
                             TROCO 
                             , 
                             Getdate() 
                             AS 
                             DATA_PARA_TRANSFERENCIA, 
                             NULL                                             AS 
                             COD_CREDENCIADORA 
                      FROM   loja_pedido A 
                             INNER JOIN loja_pedido_entrega B 
                                     ON A.pedido = B.pedido 
                                        AND A.codigo_filial_origem = 
                                            B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.lx_pedido_origem = 5 

                      /* Parcela Frete */ 
                      SELECT @PARCELA = Max(A.parcela) 
                      FROM   loja_venda_parcelas A 
                      WHERE  A.lancamento_caixa = @LANCAMENTO_CAIXA 
                             AND A.codigo_filial = @PCODIGO_FILIAL_ORIGEM 
                             AND A.terminal = @TERMINAL 
                             AND Isnumeric(A.parcela) = 1 

                      INSERT INTO loja_venda_parcelas 
                                  (terminal, 
                                   lancamento_caixa, 
                                   codigo_filial, 
                                   parcela, 
                                   codigo_administradora, 
                                   tipo_pgto, 
                                   valor, 
                                   vencimento, 
                                   numero_titulo, 
                                   moeda, 
                                   agencia, 
                                   banco, 
                                   conta_corrente, 
                                   numero_aprovacao_cartao, 
                                   parcelas_cartao, 
                                   data_hora_tef, 
                                   cheque_cartao, 
                                   troco,--#14#  
                                   data_para_transferencia, 
                                   cod_credenciadora) --#15#  
                      SELECT @TERMINAL, 
                             @LANCAMENTO_CAIXA, 
                             @PCODIGO_FILIAL_ORIGEM, 
                             RIGHT(''00'' 
                                   + CONVERT(VARCHAR(2), Rtrim(Ltrim(@PARCELA + 
                                   Row_number() 
                                   OVER( 
                                   ORDER BY 
                                   B.seq_entrega ASC)))), 2), 
                             NULL                                             AS 
                             CODIGO_ADMINISTRADORA 
                             , 
                             ''W''                                              AS 
                             TIPO_PGTO, 
                             B.frete * -1, 
                             A.data, 
                             B.id_pedido_origem                               AS 
                             NUMERO_TITULO 
                             , 
                             ''R$'' 
                             AS MOEDA, 
                             NULL                                             AS 
                             AGENCIA 
                             , 
                             NULL 
                             AS BANCO, 
                             NULL                                             AS 
                             CONTA_CORRENTE, 
                             B.id_pedido_origem                               AS 
                             NUMERO_APROVACAO_CARTAO, 
                             0                                                AS 
                             PARCELAS_CARTAO, 
                             NULL                                             AS 
                             DATA_HORA_TEF 
                             , 
                             ''OMS-'' + B.id_pedido_origem + ''-'' + A.channel_id 
                             AS CHEQUE_CARTAO, 
                             0.00                                             AS 
                             TROCO 
                             , 
                             Getdate() 
                             AS 
                             DATA_PARA_TRANSFERENCIA, 
                             NULL                                             AS 
                             COD_CREDENCIADORA 
                      FROM   loja_pedido A 
                             INNER JOIN loja_pedido_entrega B 
                                     ON A.pedido = B.pedido 
                                        AND A.codigo_filial_origem = 
                                            B.codigo_filial_origem 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.lx_pedido_origem = 5 

                      -- Fim Customizado 
                      INSERT INTO loja_venda_vendedores 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   id_vendedor, 
                                   vendedor, 
                                   comissao, 
                                   data_para_transferencia, 
                                   tipo_vendedor) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             Isnull((SELECT TOP 1 id_vendedor 
                                     FROM   loja_pedido_produto 
                                     WHERE  pedido = @PPEDIDO 
                                            AND codigo_filial_origem = 
                                                @PCODIGO_FILIAL_ORIGEM 
                                            AND indica_entrega_futura = 0), 0.00 
                             ), 
                             (SELECT vendedor 
                              FROM   loja_pedido 
                              WHERE  pedido = @PPEDIDO 
                                     AND codigo_filial_origem = 
                                         @PCODIGO_FILIAL_ORIGEM 
                             ), 
                             NULL, 
                             Getdate(), 
                             1 

                      /*Alimenta a tabela LOJA_VENDA_PROMOCAO*/ 
                      INSERT INTO loja_venda_promocao 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   id_promocao, 
                                   item, 
                                   desc_promocao, 
                                   campanha, 
                                   preco_unitario, 
                                   valor_desconto, 
                                   id_beneficio, 
                                   versao_mapa, 
                                   qtde, 
                                   base_calculo) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.id_promocao, 
                             A.item, 
                             A.desc_promocao, 
                             A.campanha, 
                             A.preco_unitario, 
                             A.valor_desconto, 
                             A.id_beneficio, 
                             A.versao_mapa, 
                             A.qtde, 
                             A.base_calculo 
                      FROM   loja_pedido_venda_promocao A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      /*INSERT LOJA_VENDA_PROMOCAO_CUPOM  */ 
                      INSERT INTO loja_venda_promocao_cupom 
                                  (codigo_filial, 
                                   ticket, 
                                   data_hora, 
                                   id_promocao, 
                                   codigo_cupom, 
                                   prefixo_cupom, 
                                   terminal, 
                                   status_cupom, 
                                   mensagem_retorno, 
                                   data_para_transferencia, 
                                   data_venda, 
                                   voucher_number, 
                                   coupon_id) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             data_pedido, 
                             id_promocao, 
                             Substring(voucher_number, 1, 10), 
                             Substring(coupon_id, 1, 5), 
                             @TERMINAL, 
                             status_cupom, 
                             mensagem_retorno, 
                             Getdate(), 
                             data_pedido, 
                             voucher_number, 
                             coupon_id 
                      FROM   loja_pedido_venda_promocao_cupom 
                      WHERE  codigo_filial = @PCODIGO_FILIAL_ORIGEM 
                             AND pedido = @PPEDIDO 
                             AND terminal = @TERMINAL 

                      /*INSERT INTO  LOJA_GIFT_TRANSACAO */ 
                      INSERT INTO loja_gift_transacao 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   numero_cartao, 
                                   cnpj, 
                                   tipo_requisicao, 
                                   valor, 
                                   pin, 
                                   codigo_transacao, 
                                   data_hora_transacao, 
                                   nsu, 
                                   nsu_host, 
                                   pedido) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.numero_cartao, 
                             A.cnpj, 
                             A.tipo_requisicao, 
                             A.valor, 
                             A.pin, 
                             A.nsu, 
                             A.data_hora_transacao, 
                             a.nsu, 
                             a.nsu, 
                             A.pedido 
                      FROM   loja_pedido_gift_transacao A 
                      WHERE  A.pedido = @PPEDIDO 
                             AND A.codigo_filial = @PCODIGO_FILIAL_ORIGEM 

                      /*INSERT LOJA_vENDA_TROCA_TICKET  */ 
                      INSERT INTO loja_venda_troca_ticket 
                                  (codigo_filial, 
                                   ticket, 
                                   data_venda, 
                                   codigo_barra, 
                                   preco_liquido, 
                                   item, 
                                   desconto_item, 
                                   fator_desconto_venda, 
                                   data_para_transferencia) 
                      SELECT @PCODIGO_FILIAL_ORIGEM, 
                             @TICKET, 
                             @DATA_VENDA, 
                             A.codigo_barra, 
                             A.preco_liquido, 
                             A.item, 
                             A.desconto_item, 
                             c.fator_desconto_venda, 
                             Getdate() 
                      FROM   loja_pedido_produto A 
                             JOIN loja_pedido_venda B 
                               ON A.pedido = B.pedido 
                                  AND A.codigo_filial_origem = 
                                      B.codigo_filial_origem 
                                  AND A.item = B.item 
                             JOIN loja_venda_produto C 
                               ON B.ticket = C.ticket 
                                  AND B.data_venda = C.data_venda 
                                  AND C.item = B.item_venda 
                                  AND B.codigo_filial_origem = C.codigo_filial 
                      WHERE  A.codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 
                             AND A.pedido = @PPEDIDO 
                             AND embrulha_presente = 1 

                      EXEC Lx_recalcula_comissao 
                        @PCODIGO_FILIAL_ORIGEM, 
                        @TICKET, 
                        @DATA_VENDA 

                      UPDATE loja_pedido 
                      SET    entregue = 1 
                      WHERE  pedido = @PPEDIDO 
                             AND codigo_filial_origem = @PCODIGO_FILIAL_ORIGEM 

                      -- RAFAEL FERREIRA - #10#  
                      DECLARE @COLUM VARCHAR(20), 
                              @TABLE VARCHAR(20) 

                      SET @TABLE =''LOJA_PEDIDO'' 
                      SET @COLUM=''SITUACAO_OMS'' 

                      -- SHELL WILKERSON - #11# INICIO  
                      IF EXISTS (SELECT 1 
                                 FROM   loja_pedido_produto 
                                 WHERE  pedido = @PPEDIDO 
                                        AND codigo_filial_origem = 
                                            @PCODIGO_FILIAL_ORIGEM 
                                        AND indica_entrega_futura = 1) 
                         AND EXISTS (SELECT 1 
                                     FROM   information_schema.columns 
                                     WHERE  column_name = @COLUM 
                                            AND table_name = @TABLE) 
                        BEGIN 
                            EXEC( 
            '' UPDATE  LOJA_PEDIDO     SET   SITUACAO_OMS = 3     WHERE  PEDIDO='' 
                  + 
                  @PPEDIDO + ''     AND   CODIGO_FILIAL_ORIGEM='' + '''''''' + 
                  @PCODIGO_FILIAL_ORIGEM +''''''''+''     '') 
              -- RAFAEL FERREIRA - #10# FIM  
              END 

                      -- SHELL WILKERSON - #11# FIM  
                      IF EXISTS (SELECT 1 
                                 FROM   loja_pedido 
                                 WHERE  pedido = @PPEDIDO 
                                        AND codigo_filial_origem = 
                                            @PCODIGO_FILIAL_ORIGEM 
                                        AND desconto IS NULL) 
                        BEGIN 
                            UPDATE loja_pedido 
                            SET    desconto = 0.00 
                            WHERE  pedido = @PPEDIDO 
                                   AND codigo_filial_origem = 
                                       @PCODIGO_FILIAL_ORIGEM 
                        --#9#  
                        END 

                      COMMIT TRANSACTION man_venda 

                      DECLARE @isValid BIT 

                      EXEC Lx_mob_validavalorespedido 
                        @PEDIDO=@PPEDIDO, 
                        @CODIGO_FILIAL_ORIGEM =@PCODIGO_FILIAL_ORIGEM, 
                        @PedidoValido = @isValid output 

                      IF( @isValid = 1 ) 
                        BEGIN 
                            SELECT Cast(1 AS BIT) AS BSUCESS, 
                                   @TICKET        AS TICKET, 
                                   @DATA_VENDA    AS DATA_VENDA, 
                                   0              AS ERRORNUMBER, 
                                   ''''             AS ERRORMESSAGE 
                        END 
                      ELSE 
                        BEGIN 
                            SELECT Cast(0 AS BIT) AS BSUCESS, 
                                   @TICKET        AS TICKET, 
                                   @DATA_VENDA    AS DATA_VENDA, 
                                   0              AS ERRORNUMBER, 
''Existem divergencias entre valores do pedido , itens do pedido e pagamento do pedido.Por favor verifique''
               AS ERRORMESSAGE 
END 
END try 

    BEGIN catch 
        ROLLBACK TRANSACTION man_venda 

        SELECT Cast(0 AS BIT)  AS BSUCESS, 
               @TICKET         AS TICKET, 
               @DATA_VENDA     AS DATA_VENDA, 
               Error_number()  AS ERRORNUMBER, 
               Error_message() AS ERRORMESSAGE; 
    END catch; 
END 
END 
END')
END