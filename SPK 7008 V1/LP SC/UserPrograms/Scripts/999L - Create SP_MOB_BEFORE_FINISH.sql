IF NOT EXISTS ( SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'SP_MOB_BEFORE_FINISH')
	BEGIN
		EXEC('

CREATE PROCEDURE [dbo].[SP_MOB_BEFORE_FINISH] (@CODIGOFILIAL VARCHAR(6) = NULL, @DATAPEDIDO DATETIME, @PEDIDO INT)  
  AS  
  BEGIN  
  
  -- Daniel Martins - 20200629 - Adicionado campo frete_gratis na @tbl_final
    SET NOCOUNT ON  
    
   declare @CPF_CLIENTE varchar(20)
 
  if @CPF_CLIENTE is null and @pedido is not null
  select @CPF_CLIENTE = CLIENTES_VAREJO.CPF_CGC
  from LOJA_PEDIDO (nolock)
  inner join CLIENTES_VAREJO (nolock) on CLIENTES_VAREJO.CODIGO_CLIENTE = LOJA_PEDIDO.CODIGO_CLIENTE
  where CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL and PEDIDO = @PEDIDO

  ---- Desconto de funcionario tipo_cliente ajuste no item   
  DECLARE @OPERACAO_VENDA VARCHAR(10)    
  SELECT @OPERACAO_VENDA = RTRIM(VALOR_ATUAL)     
  FROM PARAMETROS_LOJA WHERE PARAMETRO = ''OPERACAO_VENDA'' 
  and CODIGO_FILIAL = @CODIGOFILIAL    
   
    /* Remover Valor da Personalização para calculo do desconto da operação de venda por tipo de cliente */
    UPDATE LOJA_PEDIDO_PRODUTO
    set DESCONTO_ITEM = DESCONTO_ITEM + convert(numeric(14,2),substring(DADOS_ADICIONAIS,CHARINDEX(''"cost":'',DADOS_ADICIONAIS)+7,CHARINDEX(''"type":'',DADOS_ADICIONAIS)-CHARINDEX(''"cost":'',DADOS_ADICIONAIS)-8))
    ,HR_PRECO_PERSONALIZACAO = 0.00
    WHERE LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL    
    AND LOJA_PEDIDO_PRODUTO.PEDIDO = @PEDIDO       
    and (DADOS_ADICIONAIS is not null and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"type":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)<CHARINDEX(''"type":'',DADOS_ADICIONAIS))

    /* Efetua desconto da operação de venda para o cliente */
    UPDATE LOJA_PEDIDO_PRODUTO SET  DESCONTO_ITEM  =   
  CASE WHEN ((PRECO_LIQUIDO)*(LOJA_OPERACAO_CLIENTE.DESCONTO_VENDA /100)) > DESCONTO_ITEM THEN   
  ((PRECO_LIQUIDO)*(LOJA_OPERACAO_CLIENTE.DESCONTO_VENDA /100))   
  ELSE  
    DESCONTO_ITEM  
  END  
    FROM LOJA_PEDIDO_PRODUTO    
  INNER JOIN  LOJA_PEDIDO ON LOJA_PEDIDO_PRODUTO.PEDIDO=LOJA_PEDIDO.PEDIDO   
    AND LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM=LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM  
  INNER JOIN CLIENTES_VAREJO ON CLIENTES_VAREJO.CODIGO_CLIENTE = LOJA_PEDIDO.CODIGO_CLIENTE    
  INNER JOIN LOJA_OPERACAO_CLIENTE ON LOJA_OPERACAO_CLIENTE.OPERACAO_VENDA = @OPERACAO_VENDA    
    AND LOJA_OPERACAO_CLIENTE.TIPO_VAREJO = CLIENTES_VAREJO.TIPO_VAREJO    
  WHERE LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL    
    AND LOJA_PEDIDO.PEDIDO = @PEDIDO               
   
    DECLARE @TBL_FINAL TABLE (
  ID_PROMOCAO INT
    ,DATA_INICIO DATETIME
    ,DATA_FIM DATETIME
    ,MESG VARCHAR(MAX)
    ,DESCONTOPROM NUMERIC(14,2)
    ,TIPO INT
    ,GERA_TICKET BIT
    ,QUANTIDADE_VOUCHER INT
    ,VALIDADE_VOUCHER DATETIME
    ,TIPO_VOUCHER INT /*3= VALOR / 4= PORCENTAGEM*/
    ,VALOR_VOUCHER NUMERIC(14,2)
    ,TEXTO_CAMPANHA VARCHAR(MAX)
    ,CODIGO_VOUCHER VARCHAR(20)
    ,TIPO_GATILHO_RESGATE INT
    ,VALOR_GATILHO_RESGATE NUMERIC(18,2)
 ,BRINDE bit
 ,FRETE_GRATIS BIT
  )

  UPDATE LOJA_PEDIDO_PRODUTO SET PRECO_LIQUIDO = PRECO_LIQUIDO - DESCONTO_ITEM WHERE PEDIDO = @PEDIDO AND CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL   
  
  
  BEGIN TRY 
   INSERT INTO @TBL_FINAL (ID_PROMOCAO, DATA_INICIO, DATA_FIM, MESG, DESCONTOPROM, TIPO, GERA_TICKET, QUANTIDADE_VOUCHER, VALIDADE_VOUCHER, TIPO_VOUCHER, VALOR_VOUCHER, TEXTO_CAMPANHA, CODIGO_VOUCHER, TIPO_GATILHO_RESGATE, VALOR_GATILHO_RESGATE,brinde, FRETE_GRATIS)  
   EXEC SP_HR_PROMOCAO @CODIGO_FILIAL = @CODIGOFILIAL, @PEDIDO = @PEDIDO, @DATA_VENDA = @DATAPEDIDO, @CPF_CLIENTE = @CPF_CLIENTE
  END TRY
  BEGIN CATCH
   INSERT INTO @TBL_FINAL (ID_PROMOCAO, DATA_INICIO, DATA_FIM, MESG, DESCONTOPROM, TIPO, GERA_TICKET, QUANTIDADE_VOUCHER)  
   EXEC SP_HR_PROMOCAO @CODIGO_FILIAL = @CODIGOFILIAL, @PEDIDO = @PEDIDO, @DATA_VENDA = @DATAPEDIDO, @CPF_CLIENTE = @CPF_CLIENTE
  END CATCH

    UPDATE LOJA_PEDIDO_PRODUTO SET PRECO_LIQUIDO = PRECO_LIQUIDO + DESCONTO_ITEM WHERE PEDIDO = @PEDIDO AND CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL     


    /* Acrescenta Valor da Personalização novamente */
    UPDATE LOJA_PEDIDO_PRODUTO
    set DESCONTO_ITEM = DESCONTO_ITEM - convert(numeric(14,2),substring(DADOS_ADICIONAIS,CHARINDEX(''"cost":'',DADOS_ADICIONAIS)+7,CHARINDEX(''"type":'',DADOS_ADICIONAIS)-CHARINDEX(''"cost":'',DADOS_ADICIONAIS)-8))
    WHERE LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL    
    AND LOJA_PEDIDO_PRODUTO.PEDIDO = @PEDIDO       
    and (DADOS_ADICIONAIS is not null and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"type":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)<CHARINDEX(''"type":'',DADOS_ADICIONAIS))
   
    /* Colocar valor da personalização para calculo correto do motor de promocao no PDV */
    UPDATE LOJA_PEDIDO_PRODUTO
    set HR_PRECO_PERSONALIZACAO = convert(numeric(14,2),substring(DADOS_ADICIONAIS,CHARINDEX(''"cost":'',DADOS_ADICIONAIS)+7,CHARINDEX(''"type":'',DADOS_ADICIONAIS)-CHARINDEX(''"cost":'',DADOS_ADICIONAIS)-8))
    WHERE LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL    
    AND LOJA_PEDIDO_PRODUTO.PEDIDO = @PEDIDO       
    and (DADOS_ADICIONAIS is not null and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"type":'',DADOS_ADICIONAIS)>0 and CHARINDEX(''"cost":'',DADOS_ADICIONAIS)<CHARINDEX(''"type":'',DADOS_ADICIONAIS))
  
  --- Desconto de funcionario Ajuste no valor total loja_pedido_entrega
  update a set a.valor_total = c.TOTAL
  FROM LOJA_PEDIDO_ENTREGA A
  inner join loja_pedido b
  on a.CODIGO_FILIAL_ORIGEm = b.CODIGO_FILIAL_ORIGEM and a.PEDIDO = b.PEDIDO
  inner join ( SELECT CODIGO_FILIAL_ORIGEM,PEDIDO,SEQ_ENTREGA, SUM(QTDE*(PRECO_LIQUIDO-DESCONTO_ITEM)) AS TOTAL FROM  LOJA_PEDIDO_PRODUTO   
  WHERE LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL   
  AND LOJA_PEDIDO_PRODUTO.PEDIDO = @PEDIDO
  group by CODIGO_FILIAL_ORIGEM,PEDIDO,SEQ_ENTREGA) c
  on a.CODIGO_FILIAL_ORIGEM = c.CODIGO_FILIAL_ORIGEM and a.PEDIDO = c.PEDIDO and a.seq_entrega = c.seq_entrega
  where a.PEDIDO = @PEDIDO  and a.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL  

  DECLARE @DESCONTO NUMERIC(13,2) =0, @BASEFRETE NUMERIC(13,2)=0, @FRETEGRATIS NUMERIC(13,2)=0, @FRETETOTAL NUMERIC(13,2)=0, @VALORTOTAL NUMERIC(13,2)=0  
       
  SELECT @BASEFRETE   = CONVERT(NUMERIC(13,2),ISNULL(VALOR_ATUAL,''0'')) FROM PARAMETROS WHERE PARAMETRO = ''HR_CAMPANHA_FRETE''        
  SELECT @FRETEGRATIS = ISNULL(SUM(ISNULL(FRETE,0)),0) FROM LOJA_PEDIDO_ENTREGA WHERE PEDIDO =@PEDIDO AND CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL AND (upper(OPCAO_ENTREGA) LIKE ''%"METHODID":"1"%'' or upper(OPCAO_ENTREGA) LIKE ''%"METHOD":"ENTREGA NORMAL"%'')
  SELECT @FRETETOTAL  = ISNULL(SUM(ISNULL(FRETE,0)),0)FROM LOJA_PEDIDO_ENTREGA WHERE PEDIDO =@PEDIDO AND CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL      
  SELECT @VALORTOTAL  = ISNULL(SUM(ISNULL(VALOR_TOTAL,0)),0) FROM LOJA_PEDIDO WHERE PEDIDO =@PEDIDO AND CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL   
    
    SELECT @DESCONTO = SUM(DESCONTOPROM) FROM @TBL_FINAL  
    WHERE CONVERT(DATE,@DATAPEDIDO) >= DATA_INICIO AND CONVERT(DATE,@DATAPEDIDO) <=DATA_FIM  
   
    UPDATE LOJA_PEDIDO SET DESCONTO =ISNULL(@DESCONTO,0),   
    FRETE = CASE WHEN VALOR_TOTAL >= @BASEFRETE THEN @FRETETOTAL-@FRETEGRATIS ELSE @FRETETOTAL END   
    WHERE CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL AND PEDIDO =@PEDIDO AND VALOR_TOTAL > 0  
  
    UPDATE LOJA_PEDIDO_ENTREGA SET FRETE = CASE WHEN @VALORTOTAL >= @BASEFRETE THEN 0 ELSE FRETE END   
    WHERE CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL AND PEDIDO =@PEDIDO AND @VALORTOTAL >0 AND (UPPER(OPCAO_ENTREGA) LIKE ''%"METHODID":"1"%'' OR UPPER(OPCAO_ENTREGA) LIKE ''%"METHOD":"ENTREGA NORMAL"%'')

    UPDATE LOJA_PEDIDO_ENTREGA_LISTA SET FRETE = CASE WHEN @VALORTOTAL >= @BASEFRETE THEN 0 ELSE FRETE END   
    WHERE CODIGO_FILIAL_ORIGEM =@CODIGOFILIAL AND PEDIDO =@PEDIDO AND @VALORTOTAL >0 AND (UPPER(CONVERT(VARCHAR(MAX),OPCAO_ENTREGA)) LIKE ''%"METHODID":"1"%'' OR UPPER(CONVERT(VARCHAR(MAX),OPCAO_ENTREGA)) LIKE ''%"METHOD":"ENTREGA NORMAL"%'')
   
   UPDATE B SET B.VALOR_TOTAL = A.VALOR_TOTAL FROM LOJA_PEDIDO A 
   INNER JOIN LOJA_PEDIDO_ENTREGA_LISTA B
   ON A.PEDIDO = B.PEDIDO AND A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
   WHERE A.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL AND A.PEDIDO = @PEDIDO 

   
   UPDATE B SET B.VALOR_TOTAL = A.VALOR_TOTAL FROM LOJA_PEDIDO A 
   INNER JOIN LOJA_PEDIDO_ENTREGA B
   ON A.PEDIDO = B.PEDIDO AND A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM
   WHERE A.CODIGO_FILIAL_ORIGEM = @CODIGOFILIAL AND A.PEDIDO = @PEDIDO 
    SET NOCOUNT OFF  
  
  END') END