CREATE Trigger [dbo].[LXU_LOJA_VENDA_PRODUTO] on [dbo].[LOJA_VENDA_PRODUTO] for UPDATE NOT FOR REPLICATION as  
--TP4629098 - #2# - Diego Moreno (23/12/2014) - Tratamento para evitar bloqueios DeadLock.
--21/08/2013 - #01# - Inclusao de tratamento para deadlock /Inclusão do NOLOCK - Tratamento de deadlock
/* UPDATE trigger on LOJA_VENDA_PRODUTO */  
/* default body for LXU_LOJA_VENDA_PRODUTO */  
begin  
  declare  @numrows int,  
           @nullcnt int,  
           @validcnt int,  
           @insTICKET char(8),   
           @insCODIGO_FILIAL char(6),   
           @insDATA_VENDA datetime,   
           @insITEM char(4),  
           @delTICKET char(8),   
           @delCODIGO_FILIAL char(6),   
           @delDATA_VENDA datetime,   
           @delITEM char(4),  
           @errno   int,  
           @errmsg  varchar(255)  
  
  select @numrows = @@rowcount  
  
-- Bloqueio Estoque PA ------------------------------------------------------------------------------------------  
 IF UPDATE(DATA_VENDA) OR   
  UPDATE(QTDE)  
    
 BEGIN  
  --Verifica Bloqueio por Contagem  
  IF EXISTS ( SELECT Inserted.DATA_VENDA  
    FROM Inserted   
     JOIN LOJAS_VAREJO (nolock) ON   -- #2#
      LOJAS_VAREJO.CODIGO_FILIAL = Inserted.CODIGO_FILIAL  
     JOIN ESTOQUE_PRODUTOS WITH(NOLOCK) ON   -- #2#
      ESTOQUE_PRODUTOS.FILIAL=LOJAS_VAREJO.FILIAL AND   
      ESTOQUE_PRODUTOS.PRODUTO=Inserted.PRODUTO AND   
      ESTOQUE_PRODUTOS.COR_PRODUTO=Inserted.COR_PRODUTO   
    WHERE Inserted.DATA_VENDA < ESTOQUE_PRODUTOS.DATA_AJUSTE )  
  
   AND   
   EXISTS ( SELECT Deleted.DATA_VENDA  
    FROM Deleted   
     JOIN LOJAS_VAREJO (nolock) ON   --#2#
      LOJAS_VAREJO.CODIGO_FILIAL = Deleted.CODIGO_FILIAL  
     JOIN ESTOQUE_PRODUTOS WITH(NOLOCK)ON    -- #2#
      ESTOQUE_PRODUTOS.FILIAL=LOJAS_VAREJO.FILIAL AND   
      ESTOQUE_PRODUTOS.PRODUTO=Deleted.PRODUTO AND   
      ESTOQUE_PRODUTOS.COR_PRODUTO=Deleted.COR_PRODUTO   
    WHERE Deleted.DATA_VENDA < ESTOQUE_PRODUTOS.DATA_AJUSTE )  
  
  BEGIN  
   Select  @errno=30002,  
    @errmsg='Não é possível alterar Movimentacao de Estoque anterior ao ajuste!'  
   GoTo Error  
  END  
 END  
 -----------------------------------------------------------------------------------------------------------------  
  
/* PRODUTO_CORES R/1618 LOJA_VENDA_PRODUTO ON CHILD UPDATE RESTRICT */  
  if  
    update(PRODUTO) or  
    update(COR_PRODUTO)  
  begin  
    select @nullcnt = 0  
    select @validcnt = count(*)  
      from inserted,PRODUTO_CORES  
     where  
           inserted.PRODUTO = PRODUTO_CORES.PRODUTO and  
           inserted.COR_PRODUTO = PRODUTO_CORES.COR_PRODUTO  
    select @nullcnt = count(*) from inserted where  
      inserted.PRODUTO is null and  
      inserted.COR_PRODUTO is null  
    if @validcnt + @nullcnt != @numrows  
    begin  
      select @errno  = 30007,  
             @errmsg = 'Impossível atualizar  "LOJA_VENDA_PRODUTO" porque "PRODUTO_CORES" não existe.'  
      goto error  
    end  
  end  
  
/* PRODUTOS_BARRA PRODUTOS_BARRA LOJA_VENDA_PRODUTO ON CHILD UPDATE RESTRICT */  
  if  
    update(CODIGO_BARRA)  
  begin  
    select @nullcnt = 0  
    select @validcnt = count(*)  
      from inserted,PRODUTOS_BARRA  
     where  
           inserted.CODIGO_BARRA = PRODUTOS_BARRA.CODIGO_BARRA  
      
    if @validcnt + @nullcnt != @numrows  
    begin  
      select @errno  = 30007,  
             @errmsg = 'Impossível atualizar  "LOJA_VENDA_PRODUTO" porque "PRODUTOS_BARRA" não existe.'  
      goto error  
    end  
  end  
  
/* LOJA_VENDA LOJA_VENDA LOJA_VENDA_PRODUTO ON CHILD UPDATE RESTRICT */  
  if  
    update(CODIGO_FILIAL) or  
    update(TICKET) or  
    update(DATA_VENDA)  
  begin  
    select @nullcnt = 0  
    select @validcnt = count(*)  
      from inserted,LOJA_VENDA  
     where  
           inserted.CODIGO_FILIAL = LOJA_VENDA.CODIGO_FILIAL and  
           inserted.TICKET = LOJA_VENDA.TICKET and  
           inserted.DATA_VENDA = LOJA_VENDA.DATA_VENDA  
      
    if @validcnt + @nullcnt != @numrows  
    begin  
      select @errno  = 30007,  
             @errmsg = 'Impossível atualizar  "LOJA_VENDA_PRODUTO" porque "LOJA_VENDA" não existe.'  
      goto error  
    end  
  end  
  
  
  
/*---LINX---------------------------------------------------------------------------------------------*/  
  
 UPDATE Loja_Venda_Produto SET Produto=Produtos_Barra.Produto,   
  Cor_Produto=Produtos_Barra.Cor_Produto, Tamanho=Produtos_Barra.Tamanho  
 FROM Inserted, Produtos_Barra, Loja_Venda_Produto  
 WHERE Inserted.Codigo_Barra=Produtos_Barra.Codigo_Barra AND  
  Loja_Venda_Produto.Ticket=Inserted.Ticket AND  
  Loja_Venda_Produto.Codigo_Filial=Inserted.Codigo_Filial AND  
  Loja_Venda_Produto.Data_VEnda=Inserted.Data_VEnda AND  
  
  Loja_Venda_Produto.Produto=Inserted.Produto AND  
  Loja_Venda_Produto.Cor_Produto=Inserted.Cor_Produto AND  
  (Inserted.Produto IS NULL OR Inserted.Cor_Produto IS NULL OR Inserted.Tamanho IS NULL)  
  
/*----------------------------------------------------------------------------------------------------*/  
  
/*---LINX-FATOR DESCONTO------------------------------------------------------------------------------*/  
  
UPDATE  LOJA_VENDA_PRODUTO   
SET FATOR_DESCONTO_VENDA=1.*(VALOR_VENDA_BRUTA-VALOR_TROCA-VALOR_PAGO)/VALOR_VENDA_BRUTA,  
 FATOR_VENDA_LIQ=1.*(Valor_Pago)/(Valor_Venda_Bruta),  
 DATA_PARA_TRANSFERENCIA=LOJA_VENDA_PRODUTO.DATA_PARA_TRANSFERENCIA  
FROM Loja_Venda, INSERTED   
WHERE Loja_Venda.Codigo_Filial=INSERTED.Codigo_Filial AND Loja_Venda.Ticket=INSERTED.Ticket AND Loja_Venda.Data_Venda=INSERTED.Data_Venda AND  
 Valor_Venda_Bruta <> 0 AND  
 INSERTED.TICKET=LOJA_VENDA_PRODUTO.TICKET AND  
 INSERTED.CODIGO_FILIAL=LOJA_VENDA_PRODUTO.CODIGO_FILIAL AND  
 INSERTED.DATA_VENDA=LOJA_VENDA_PRODUTO.DATA_VENDA AND  
 INSERTED.ITEM=LOJA_VENDA_PRODUTO.ITEM AND   
 LOJA_VENDA.VALOR_VENDA_BRUTA IS NOT NULL AND LOJA_VENDA.VALOR_VENDA_BRUTA<>0 AND  
 (CONVERT(NUMERIC(14,2),INSERTED.FATOR_DESCONTO_VENDA*VALOR_VENDA_BRUTA)<>(Valor_Venda_Bruta-Valor_Troca-Valor_Pago) OR  
  CONVERT(NUMERIC(14,2),INSERTED.FATOR_VENDA_LIQ*VALOR_VENDA_BRUTA)<>Valor_Pago OR  
  INSERTED.FATOR_DESCONTO_VENDA IS NULL OR INSERTED.FATOR_VENDA_LIQ IS NULL)  
  
/*----------------------------------------------------------------------------------------------------*/  
  
/*---LINX-ESTOQUE---------------------------------------------------------------------------------------*/  
IF UPDATE(CODIGO_FILIAL) OR UPDATE(PRODUTO) OR UPDATE(COR_PRODUTO) OR UPDATE(TAMANHO) OR UPDATE(QTDE)  
BEGIN  
  
    DECLARE cursor_estoque CURSOR  
    FOR  
      SELECT Produto, Cor_Produto, Filial,  
 Data_Venda,CONVERT(NUMERIC(14,2),SUM(Qtde*Custo)),CONVERT(NUMERIC(14,2),SUM(Qtde*Preco_Liquido)),CONVERT(NUMERIC(14,2),SUM(Qtde*Desconto_Item)),CONVERT(INT,COUNT(TICKET)),  
 SUM(CASE Tamanho WHEN 1 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 2 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 3 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 4 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 5 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 6 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 7 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 8 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 9 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 10 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 11 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 12 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 13 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 14 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 15 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 16 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 17 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 18 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 19 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 20 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 21 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 22 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 23 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 24 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 25 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 26 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 27 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 28 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 29 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 30 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 31 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 32 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 33 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 34 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 35 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 36 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 37 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 38 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 39 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 40 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 41 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 42 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 43 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 44 THEN Qtde ELSE 0 END),  
 SUM(CASE Tamanho WHEN 45 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 46 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 47 THEN Qtde ELSE 0 END),SUM(CASE Tamanho WHEN 48 THEN Qtde ELSE 0 END)  
     FROM Inserted, Lojas_Varejo (nolock) -- #2#
     WHERE Inserted.Codigo_Filial=Lojas_Varejo.Codigo_Filial And Inserted.Nao_Movimenta_Estoque = 0   
     GROUP BY Produto, Cor_Produto, Filial, Data_Venda  
     UNION   
     SELECT Produto, Cor_Produto, Filial,  
 Data_Venda,CONVERT(NUMERIC(14,2),SUM(Qtde*Custo)),CONVERT(NUMERIC(14,2),SUM(Qtde*Preco_Liquido)),CONVERT(NUMERIC(14,2),SUM(Qtde*Desconto_Item)),CONVERT(INT,COUNT(TICKET)),  
 SUM(CASE Tamanho WHEN 1 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 2 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 3 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 4 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 5 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 6 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 7 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 8 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 9 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 10 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 11 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 12 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 13 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 14 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 15 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 16 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 17 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 18 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 19 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 20 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 21 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 22 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 23 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 24 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 25 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 26 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 27 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 28 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 29 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 30 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 31 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 32 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 33 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 34 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 35 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 36 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 37 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 38 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 39 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 40 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 41 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 42 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 43 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 44 THEN Qtde ELSE 0 END)*-1,  
 SUM(CASE Tamanho WHEN 45 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 46 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 47 THEN Qtde ELSE 0 END)*-1,SUM(CASE Tamanho WHEN 48 THEN Qtde ELSE 0 END)*-1  
     FROM Deleted, Lojas_Varejo (nolock) --#2#
     WHERE Deleted.Codigo_Filial=Lojas_Varejo.Codigo_Filial And Deleted.Nao_Movimenta_Estoque = 0   
     GROUP BY Produto, Cor_Produto, Filial,Data_Venda  
    ORDER BY 9  
  
    OPEN cursor_estoque  
  
    DECLARE @cProduto Char(12), @cCor_Produto Char(10), @cFilial VarChar(25), @nEstoque Int,  
     @Data_Venda DateTime, @Custo Numeric(14,2), @Venda Numeric(14,2), @Desconto Numeric(14,2), @Tickets Int,  
       @nEs1  Int, @nEs2  Int, @nEs3  Int, @nEs4  Int, @nEs5  Int, @nEs6  Int, @nEs7  Int, @nEs8  Int,  
            @nEs9  Int, @nEs10 Int, @nEs11 Int, @nEs12 Int, @nEs13 Int, @nEs14 Int, @nEs15 Int, @nEs16 Int,  
            @nEs17 Int, @nEs18 Int, @nEs19 Int, @nEs20 Int, @nEs21 Int, @nEs22 Int, @nEs23 Int, @nEs24 Int,   
            @nEs25 Int, @nEs26 Int, @nEs27 Int, @nEs28 Int, @nEs29 Int, @nEs30 Int, @nEs31 Int, @nEs32 Int,   
            @nEs33 Int, @nEs34 Int, @nEs35 Int, @nEs36 Int, @nEs37 Int, @nEs38 Int, @nEs39 Int, @nEs40 Int,   
            @nEs41 Int, @nEs42 Int, @nEs43 Int, @nEs44 Int, @nEs45 Int, @nEs46 Int, @nEs47 Int, @nEs48 Int  
  
    FETCH NEXT FROM cursor_estoque INTO @cProduto,@cCor_Produto,@cFilial,@Data_Venda,@Custo,@Venda,@Desconto,@Tickets,  
                            @nEs1,  @nEs2,  @nEs3,  @nEs4,  @nEs5,  @nEs6,  @nEs7,  @nEs8,  @nEs9,  @nEs10, @nEs11, @nEs12,   
                            @nEs13, @nEs14, @nEs15, @nEs16, @nEs17, @nEs18, @nEs19, @nEs20, @nEs21, @nEs22, @nEs23, @nEs24,   
                            @nEs25, @nEs26, @nEs27, @nEs28, @nEs29, @nEs30, @nEs31, @nEs32, @nEs33, @nEs34, @nEs35, @nEs36,   
                            @nEs37, @nEs38, @nEs39, @nEs40, @nEs41, @nEs42, @nEs43, @nEs44, @nEs45, @nEs46, @nEs47, @nEs48  
  
    WHILE (@@Fetch_Status = 0)  
      BEGIN  
          
        SELECT @nEstoque = @nEs1 + @nEs2 + @nEs3 + @nEs4 + @nEs5 + @nEs6 + @nEs7 + @nEs8 + @nEs9 + @nEs10 + @nEs11 + @nEs12 +   
                  @nEs13 + @nEs14 + @nEs15 + @nEs16 + @nEs17 + @nEs18 + @nEs19 + @nEs20 + @nEs21 + @nEs22 + @nEs23 + @nEs24 +   
                  @nEs25 + @nEs26 + @nEs27 + @nEs28 + @nEs29 + @nEs30 + @nEs31 + @nEs32 + @nEs33 + @nEs34 + @nEs35 + @nEs36 +   
                  @nEs37 + @nEs38 + @nEs39 + @nEs40 + @nEs41 + @nEs42 + @nEs43 + @nEs44 + @nEs45 + @nEs46 + @nEs47 + @nEs48  
  
  
  IF (SELECT COUNT(*) FROM estoque_produtos WHERE PRODUTO=@cProduto AND COR_PRODUTO=@cCor_Produto AND FILIAL=@cFilial) > 0  
   UPDATE ESTOQUE_PRODUTOS  
   SET ESTOQUE = ESTOQUE - @nEstoque,   
              ULTIMA_SAIDA = GETDATE(),  
              ES1 =ES1  - @nES1,  ES2 =ES2  - @nES2,  ES3 =ES3  - @nES3,  
              ES4 =ES4  - @nES4,  ES5 =ES5  - @nES5,  ES6 =ES6  - @nES6,  
              ES7 =ES7  - @nES7,  ES8 =ES8  - @nES8,  ES9 =ES9  - @nES9,  
              ES10=ES10 - @nES10, ES11=ES11 - @nES11, ES12=ES12 - @nES12,   
              ES13=ES13 - @nES13, ES14=ES14 - @nES14, ES15=ES15 - @nES15,  
              ES16=ES16 - @nES16, ES17=ES17 - @nES17, ES18=ES18 - @nES18,  
              ES19=ES19 - @nES19, ES20=ES20 - @nES20, ES21=ES21 - @nES21,  
              ES22=ES22 - @nES22, ES23=ES23 - @nES23, ES24=ES24 - @nES24,  
              ES25=ES25 - @nES25, ES26=ES26 - @nES26, ES27=ES27 - @nES27,  
              ES28=ES28 - @nES28, ES29=ES29 - @nES29, ES30=ES30 - @nES30,  
              ES31=ES31 - @nES31, ES32=ES32 - @nES32, ES33=ES33 - @nES33,  
              ES34=ES34 - @nES34, ES35=ES35 - @nES35, ES36=ES36 - @nES36,  
              ES37=ES37 - @nES37, ES38=ES38 - @nES38, ES39=ES39 - @nES39,  
              ES40=ES40 - @nES40, ES41=ES41 - @nES41, ES42=ES42 - @nES42,  
              ES43=ES43 - @nES43, ES44=ES44 - @nES44, ES45=ES45 - @nES45,  
              ES46=ES46 - @nES46, ES47=ES47 - @nES47, ES48=ES48 - @nES48  
   FROM estoque_produtos  
   WHERE PRODUTO=@cProduto AND COR_PRODUTO=@cCor_Produto AND FILIAL=@cFilial  
   ELSE  
   INSERT INTO Estoque_Produtos (Produto,Cor_Produto,Filial,Estoque, ULTIMA_SAIDA,  
    Es1,  Es2,  Es3,  Es4,  Es5,  Es6,  Es7,  Es8,  Es9,  Es10, Es11, Es12, Es13, Es14, Es15, Es16,    
    Es17, Es18, Es19, Es20, Es21, Es22, Es23, Es24, Es25, Es26, Es27, Es28, Es29, Es30, Es31, Es32,  
    Es33, Es34, Es35, Es36, Es37, Es38, Es39, Es40, Es41, Es42, Es43, Es44, Es45, Es46, Es47, Es48)  
   VALUES(@cProduto, @cCor_Produto, @cFilial, @nEstoque*-1, GETDATE(),  
    @nEs1*-1,  @nEs2*-1,@nEs3*-1,  @nEs4*-1,@nEs5*-1,  @nEs6*-1,@nEs7*-1,  @nEs8*-1,  
    @nEs9*-1,  @nEs10*-1,@nEs11*-1, @nEs12*-1,@nEs13*-1, @nEs14*-1,@nEs15*-1, @nEs16*-1,  
    @nEs17*-1, @nEs18*-1,@nEs19*-1, @nEs20*-1,@nEs21*-1, @nEs22*-1,@nEs23*-1, @nEs24*-1,  
    @nEs25*-1, @nEs26*-1,@nEs27*-1, @nEs28*-1,@nEs29*-1, @nEs30*-1,@nEs31*-1, @nEs32*-1,  
    @nEs33*-1, @nEs34*-1,@nEs35*-1, @nEs36*-1,@nEs37*-1, @nEs38*-1,@nEs39*-1, @nEs40*-1,  
    @nEs41*-1, @nEs42*-1,@nEs43*-1, @nEs44*-1,@nEs45*-1, @nEs46*-1,@nEs47*-1, @nEs48*-1)  
  
           IF @@ROWCOUNT = 0  
    BEGIN  
             select @errno  = 30002,  
                    @errmsg = 'Operacao cancelada. Nao foi possivel atualizar "ESTOQUE_PRODUTOS".'  
             goto error  
           END  
  
  
        FETCH NEXT FROM cursor_estoque INTO @cProduto, @cCor_Produto, @cFilial,@Data_Venda,@Custo,@Venda,@Desconto,@Tickets,  
                            @nEs1,  @nEs2,  @nEs3,  @nEs4,  @nEs5,  @nEs6,  @nEs7,  @nEs8,  @nEs9,  @nEs10, @nEs11, @nEs12,   
                            @nEs13, @nEs14, @nEs15, @nEs16, @nEs17, @nEs18, @nEs19, @nEs20, @nEs21, @nEs22, @nEs23, @nEs24,   
                            @nEs25, @nEs26, @nEs27, @nEs28, @nEs29, @nEs30, @nEs31, @nEs32, @nEs33, @nEs34, @nEs35, @nEs36,   
                            @nEs37, @nEs38, @nEs39, @nEs40, @nEs41, @nEs42, @nEs43, @nEs44, @nEs45, @nEs46, @nEs47, @nEs48  
      END  
  
  
    CLOSE cursor_estoque  
    DEALLOCATE cursor_estoque  
END  

  
/*---LINX-UPDATE---------------------------------------------------------------------------------------------------------------------*/  

    update A set IPI =  0 
		from LOJA_VENDA_PRODUTO A , Produtos B ,INSERTED
		WHERE A.produto =B.produto
		AND   B.TRIBUT_ORIGEM =0
		AND   A.IPI > 0
		AND   A.DATA_VENDA = INSERTED.DATA_VENDA
		AND   A.TICKET = INSERTED.TICKET
  
/*-----------------------------------------------------------------------------------------------------------------------------------*/  

IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)  
BEGIN  
 UPDATE  LOJA_VENDA_PRODUTO   
 SET  DATA_PARA_TRANSFERENCIA = GETDATE()  
 FROM  LOJA_VENDA_PRODUTO, INSERTED  
 WHERE  LOJA_VENDA_PRODUTO.TICKET = INSERTED.TICKET and  
        LOJA_VENDA_PRODUTO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL and  
        LOJA_VENDA_PRODUTO.DATA_VENDA = INSERTED.DATA_VENDA and  
        LOJA_VENDA_PRODUTO.ITEM = INSERTED.ITEM   
  AND (INSERTED.DATA_PARA_TRANSFERENCIA IS NULL   
  OR LOJA_VENDA_PRODUTO.DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA)  
END  
/*-----------------------------------------------------------------------------------------------------------------------------------*/  
  return  
error:  
	raiserror(@errmsg, 18, 1)
    rollback transaction  
end  

--------------------------------------------------------------------------------
