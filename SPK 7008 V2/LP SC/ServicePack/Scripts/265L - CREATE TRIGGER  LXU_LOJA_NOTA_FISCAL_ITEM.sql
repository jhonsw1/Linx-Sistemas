CREATE TRIGGER [DBO].[LXU_LOJA_NOTA_FISCAL_ITEM] ON [DBO].[LOJA_NOTA_FISCAL_ITEM] FOR UPDATE NOT FOR REPLICATION AS   
-- UPDATE Trigger On LOJA_NOTA_FISCAL_ITEM  
Begin  
 Declare @numrows Int,  
  @nullcnt Int,  
  @validcnt Int,  
  @insCODIGO_FILIAL char(6),   
  @insNF_NUMERO char(15),   
  @insSERIE_NF char(6),   
  @insSUB_ITEM_TAMANHO int,   
  @insITEM_IMPRESSAO char(4),  
  @delCODIGO_FILIAL char(6),   
  @delNF_NUMERO char(15),   
  @delSERIE_NF char(6),   
  @delSUB_ITEM_TAMANHO int,   
  @delITEM_IMPRESSAO char(4),  
  @errno   Int,  
  @errmsg  varchar(255),
  @qtd_item int  
  
 Select @numrows = @@rowcount  
  
-- LOJA_NOTA_FISCAL - Child Update Restrict  
 IF UPDATE(CODIGO_FILIAL) OR   
  UPDATE(NF_NUMERO) OR   
  UPDATE(SERIE_NF)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, LOJA_NOTA_FISCAL  
  WHERE INSERTED.CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL AND   
   INSERTED.NF_NUMERO = LOJA_NOTA_FISCAL.NF_NUMERO AND   
   INSERTED.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #LOJA_NOTA_FISCAL #não existe.'  
   GoTo Error  
  End  
 End  
  
-- TRIBUT_ORIGEM - Child Update Restrict  
 IF UPDATE(TRIBUT_ORIGEM)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, TRIBUT_ORIGEM  
  WHERE INSERTED.TRIBUT_ORIGEM = TRIBUT_ORIGEM.TRIBUT_ORIGEM  
  
  SELECT @NullCnt = count(*)  
  FROM Inserted   
  WHERE INSERTED.TRIBUT_ORIGEM IS NULL  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #TRIBUT_ORIGEM #não existe.'  
   GoTo Error  
  End  
 End  
  
-- TRIBUT_ICMS - Child Update Restrict  
 IF UPDATE(TRIBUT_ICMS)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, TRIBUT_ICMS  
  WHERE INSERTED.TRIBUT_ICMS = TRIBUT_ICMS.TRIBUT_ICMS  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #TRIBUT_ICMS #não existe.'  
   GoTo Error  
  End  
 End  
  
-- CTB_LX_NATUREZAS_OPERACAO - Child Update Restrict  
 IF UPDATE(CODIGO_FISCAL_OPERACAO)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, CTB_LX_NATUREZAS_OPERACAO  
  WHERE INSERTED.CODIGO_FISCAL_OPERACAO = CTB_LX_NATUREZAS_OPERACAO.CODIGO_FISCAL_OPERACAO  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #CTB_LX_NATUREZAS_OPERACAO #não existe.'  
   GoTo Error  
  End  
 End  
  
-- CLASSIF_FISCAL - Child Update Restrict  
 IF UPDATE(CLASSIF_FISCAL)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, CLASSIF_FISCAL  
  WHERE INSERTED.CLASSIF_FISCAL = CLASSIF_FISCAL.CLASSIF_FISCAL  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #CLASSIF_FISCAL #não existe.'  
   GoTo Error  
  End  
 End  
  
-- CTB_LX_INDICADOR_CFOP - Child Update Restrict  
 IF UPDATE(INDICADOR_CFOP)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, CTB_LX_INDICADOR_CFOP  
  WHERE INSERTED.INDICADOR_CFOP = CTB_LX_INDICADOR_CFOP.INDICADOR_CFOP  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #CTB_LX_INDICADOR_CFOP #não existe.'  
   GoTo Error  
  End  
 End  
  
-- CTB_EXCECAO_IMPOSTO - Child Update Restrict  
 IF UPDATE(ID_EXCECAO_IMPOSTO)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, CTB_EXCECAO_IMPOSTO  
  WHERE INSERTED.ID_EXCECAO_IMPOSTO = CTB_EXCECAO_IMPOSTO.ID_EXCECAO_IMPOSTO  
  
  SELECT @NullCnt = count(*)  
  FROM Inserted   
  WHERE INSERTED.ID_EXCECAO_IMPOSTO IS NULL  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_ITEM #porque #CTB_EXCECAO_IMPOSTO #não existe.'  
   GoTo Error  
  End  
 End  
  
 ---LINX ETL-------------------------------------------------------------------------------------  
 UPDATE LOJA_NOTA_FISCAL   
 SET LX_STATUS_NOTA_FISCAL = 1, DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA    
 FROM Inserted, LOJA_NOTA_FISCAL  
 WHERE INSERTED.CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL AND   
  INSERTED.NF_NUMERO = LOJA_NOTA_FISCAL.NF_NUMERO AND   
  INSERTED.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF AND  
  ISNULL(LOJA_NOTA_FISCAL.LX_STATUS_NOTA_FISCAL,0) = 3  
    
  
 ---DATA PARA TRANSFERENCIA---------------------------------------------------------------------------  
 IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)  
 UPDATE  LOJA_NOTA_FISCAL_ITEM  
 SET  DATA_PARA_TRANSFERENCIA = GETDATE()  
 FROM  LOJA_NOTA_FISCAL_ITEM, INSERTED  
 WHERE LOJA_NOTA_FISCAL_ITEM.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL AND   
   LOJA_NOTA_FISCAL_ITEM.NF_NUMERO = INSERTED.NF_NUMERO AND   
   LOJA_NOTA_FISCAL_ITEM.SERIE_NF = INSERTED.SERIE_NF AND   
   LOJA_NOTA_FISCAL_ITEM.SUB_ITEM_TAMANHO = INSERTED.SUB_ITEM_TAMANHO AND   
   LOJA_NOTA_FISCAL_ITEM.ITEM_IMPRESSAO = INSERTED.ITEM_IMPRESSAO  
   AND (INSERTED.DATA_PARA_TRANSFERENCIA Is Null   
   OR LOJA_NOTA_FISCAL_ITEM.DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA)   
 -----------------------------------------------------------------------------------------------------  
  
 return  
Error:  
 raiserror(@errmsg, 18, 1)  
 rollback transaction  
End  