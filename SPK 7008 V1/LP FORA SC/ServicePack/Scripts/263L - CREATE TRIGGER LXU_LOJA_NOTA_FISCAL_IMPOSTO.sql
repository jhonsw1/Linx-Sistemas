CREATE TRIGGER [DBO].[LXU_LOJA_NOTA_FISCAL_IMPOSTO] ON [DBO].[LOJA_NOTA_FISCAL_IMPOSTO] FOR UPDATE NOT FOR REPLICATION AS   
-- UPDATE Trigger On LOJA_NOTA_FISCAL_IMPOSTO  
Begin  
 Declare @numrows Int,  
  @nullcnt Int,  
  @validcnt Int,  
  @insCODIGO_FILIAL char(6),   
  @insNF_NUMERO char(15),   
  @insSERIE_NF char(6),   
  @insID_IMPOSTO tinyint,   
  @insSUB_ITEM_TAMANHO int,   
  @insITEM_IMPRESSAO char(4),  
  @delCODIGO_FILIAL char(6),   
  @delNF_NUMERO char(15),   
  @delSERIE_NF char(6),   
  @delID_IMPOSTO tinyint,   
  @delSUB_ITEM_TAMANHO int,   
  @delITEM_IMPRESSAO char(4),  
  @errno   Int,  
  @errmsg  varchar(255),
  @executa_desoneracao bit = 1
  
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
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_IMPOSTO #porque #LOJA_NOTA_FISCAL #não existe.'  
   GoTo Error  
  End  
 End  
  
-- CTB_LX_IMPOSTO_TIPO - Child Update Restrict  
 IF UPDATE(ID_IMPOSTO)  
 Begin  
  SELECT @NullCnt = 0  
  SELECT @ValidCnt = count(*)  
  FROM Inserted, CTB_LX_IMPOSTO_TIPO  
  WHERE INSERTED.ID_IMPOSTO = CTB_LX_IMPOSTO_TIPO.ID_IMPOSTO  
  
  If @validcnt + @nullcnt != @numrows  
  Begin  
   Select @errno  = 30002,  
    @errmsg = 'Impossível Atualizar #LOJA_NOTA_FISCAL_IMPOSTO #porque #CTB_LX_IMPOSTO_TIPO #não existe.'  
   GoTo Error  
  End  
 End  
  
 ---LINX ETL----------------------------------------------------------------------------------------  
 UPDATE LOJA_NOTA_FISCAL   
 SET LX_STATUS_NOTA_FISCAL = 1, DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA    
 FROM INSERTED, LOJA_NOTA_FISCAL  
 WHERE INSERTED.CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL AND   
  INSERTED.NF_NUMERO = LOJA_NOTA_FISCAL.NF_NUMERO AND   
  INSERTED.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF AND  
  ISNULL(LOJA_NOTA_FISCAL.LX_STATUS_NOTA_FISCAL, 0 ) = 3  
  
 ---DATA PARA TRANSFERENCIA---------------------------------------------------------------------------  
 IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)  
 UPDATE  LOJA_NOTA_FISCAL_IMPOSTO  
 SET  DATA_PARA_TRANSFERENCIA = GETDATE()  
 FROM  LOJA_NOTA_FISCAL_IMPOSTO, INSERTED  
 WHERE LOJA_NOTA_FISCAL_IMPOSTO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL AND   
   LOJA_NOTA_FISCAL_IMPOSTO.NF_NUMERO = INSERTED.NF_NUMERO AND   
   LOJA_NOTA_FISCAL_IMPOSTO.SERIE_NF = INSERTED.SERIE_NF AND   
   LOJA_NOTA_FISCAL_IMPOSTO.ID_IMPOSTO = INSERTED.ID_IMPOSTO AND   
   LOJA_NOTA_FISCAL_IMPOSTO.SUB_ITEM_TAMANHO = INSERTED.SUB_ITEM_TAMANHO AND   
   LOJA_NOTA_FISCAL_IMPOSTO.ITEM_IMPRESSAO = INSERTED.ITEM_IMPRESSAO  
   AND (INSERTED.DATA_PARA_TRANSFERENCIA Is Null   
   OR LOJA_NOTA_FISCAL_IMPOSTO.DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA)   
 -----------------------------------------------------------------------------------------------------  
  
 return  
Error:  
 raiserror(@errmsg, 18, 1)  
 rollback transaction  
End  