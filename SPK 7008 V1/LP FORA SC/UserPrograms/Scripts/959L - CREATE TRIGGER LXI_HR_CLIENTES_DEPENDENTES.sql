IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[LXU_HR_CLIENTES_DEPENDENTES]'))
EXEC dbo.sp_executesql @statement = N'
CREATE trigger [dbo].[LXU_HR_CLIENTES_DEPENDENTES] on [dbo].[HR_CLIENTES_DEPENDENTES] for UPDATE NOT FOR REPLICATION as
begin
	declare  @numrows int, @nullcnt int, @validcnt int, @errno int, @errmsg varchar(255)
	select @numrows = @@rowcount
	/*---LINX-UPDATE---------------------------------------------------------------------------------------*/
	IF NOT UPDATE(DATA_PARA_TRANSFERENCIA)
	BEGIN
		UPDATE  HR_CLIENTES_DEPENDENTES SET  DATA_PARA_TRANSFERENCIA = GETDATE() FROM  HR_CLIENTES_DEPENDENTES, INSERTED WHERE  HR_CLIENTES_DEPENDENTES.CODIGO_CLIENTE = INSERTED.CODIGO_CLIENTE and HR_CLIENTES_DEPENDENTES.ID_DEPENDENTE = INSERTED.ID_DEPENDENTE  
	END
	/*-----------------------------------------------------------------------------------------------------*/
	
	return
	error:
             raiserror(@errmsg, 18, 1)
		rollback transaction
end
' 