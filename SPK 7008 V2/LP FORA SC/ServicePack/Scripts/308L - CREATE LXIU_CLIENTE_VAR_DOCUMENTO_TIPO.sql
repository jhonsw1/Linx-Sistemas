CREATE trigger [dbo].[LXIU_CLIENTE_VAR_DOCUMENTO_TIPO] 
on [dbo].CLIENTE_VAR_DOCUMENTO_TIPO
  for UPDATE,INSERT NOT FOR REPLICATION
  as
/* UPDATE trigger on CLIENTES_VAREJO */
begin
  declare  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insCODIGO_CLIENTE varchar(14),
           @delCODIGO_CLIENTE varchar(14),
           @errno   int,
           @errmsg  varchar(255)
  select @numrows = @@rowcount
  if
    update(ID)
  begin
    if exists (select * from inserted , CLIENTES_VAREJO_DOCUMENTO where inserted.ID = CLIENTES_VAREJO_DOCUMENTO.ID)
    begin
      select @errno  = 30007,
             @errmsg = 'Impossível Atualizar  #CLIENTE_VAR_DOCUMENTO_TIPO #porque existem registro em #CLIENTES_VAREJO_DOCUMENTO.'
      goto error
    end
  end
/*---LINX-UPDATE---------------------------------------------------------------------------------------*/
IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)
BEGIN
	UPDATE 	CLIENTE_VAR_DOCUMENTO_TIPO 
	SET 	CLIENTE_VAR_DOCUMENTO_TIPO.DATA_PARA_TRANSFERENCIA = GETDATE()
	FROM 	CLIENTE_VAR_DOCUMENTO_TIPO, INSERTED
	WHERE 	CLIENTE_VAR_DOCUMENTO_TIPO.id = INSERTED.id 
    AND (CLIENTE_VAR_DOCUMENTO_TIPO.DATA_PARA_TRANSFERENCIA IS NULL OR CLIENTE_VAR_DOCUMENTO_TIPO.DATA_PARA_TRANSFERENCIA <> INSERTED.DATA_PARA_TRANSFERENCIA)
END
/*-----------------------------------------------------------------------------------------------------*/
  return
error:
    raiserror (@errmsg, 16, 1)
    rollback transaction
end
