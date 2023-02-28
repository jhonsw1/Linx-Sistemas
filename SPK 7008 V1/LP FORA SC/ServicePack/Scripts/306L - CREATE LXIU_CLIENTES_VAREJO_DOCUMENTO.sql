CREATE trigger [dbo].[LXIU_CLIENTES_VAREJO_DOCUMENTO] 
on [dbo].CLIENTES_VAREJO_DOCUMENTO
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
/* FILIAIS R/1242 CLIENTES_VAREJO ON CHILD UPDATE RESTRICT */
  if
    update(CODIGO_FILIAL)
  begin
    select @nullcnt = 0
    select @validcnt = count(*)
      from inserted,LOJAS_VAREJO
     where
           inserted.CODIGO_FILIAL = LOJAS_VAREJO.codigo_filial
    if @validcnt + @nullcnt != @numrows
    begin
      select @errno  = 30007,
             @errmsg = 'Impossível Atualizar  #CLIENTES_VAREJO_DOCUMENTO #porque #LOJAS_VAREJO #não existe.'
      goto error
    end
  end
/* FILIAIS R/1242 CLIENTES_VAREJO ON CHILD UPDATE RESTRICT */
  if
    update(CODIGO_CLIENTE)
  begin
    select @nullcnt = 0
    select @validcnt = count(*)
      from inserted,CLIENTES_VAREJO
     where
           inserted.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE   
    if @validcnt + @nullcnt != @numrows
    begin
      select @errno  = 30007,
             @errmsg = 'Impossível Atualizar  #CLIENTES_VAR_DOCUMENTO #porque #CLIENTES_VAREJO #não existe.'
      goto error
    end
  end
/*---LINX-UPDATE---------------------------------------------------------------------------------------*/
IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)
BEGIN
	UPDATE 	CLIENTES_VAREJO_DOCUMENTO 
	SET 	CLIENTES_VAREJO_DOCUMENTO.DATA_PARA_TRANSFERENCIA = GETDATE()
	FROM 	CLIENTES_VAREJO_DOCUMENTO, INSERTED
	WHERE 	CLIENTES_VAREJO_DOCUMENTO.CODIGO_CLIENTE = INSERTED.CODIGO_CLIENTE 
    AND (CLIENTES_VAREJO_DOCUMENTO.DATA_PARA_TRANSFERENCIA IS NULL OR CLIENTES_VAREJO_DOCUMENTO.DATA_PARA_TRANSFERENCIA <> INSERTED.DATA_PARA_TRANSFERENCIA)
END
/*-----------------------------------------------------------------------------------------------------*/
  return
error:
    raiserror (@errmsg, 16, 1)
    rollback transaction
end
