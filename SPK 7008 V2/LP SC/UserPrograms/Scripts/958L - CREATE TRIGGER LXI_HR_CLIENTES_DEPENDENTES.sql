IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[LXI_HR_CLIENTES_DEPENDENTES]'))
EXEC dbo.sp_executesql @statement = N'
CREATE trigger [dbo].[LXI_HR_CLIENTES_DEPENDENTES] on [dbo].[HR_CLIENTES_DEPENDENTES] for INSERT NOT FOR REPLICATION as
begin
	declare  @numrows int, @nullcnt int, @validcnt int, @errno int, @errmsg varchar(255)
	select @numrows = @@rowcount
		UPDATE  HR_CLIENTES_DEPENDENTES SET  DATA_PARA_TRANSFERENCIA = GETDATE(), DATA_CADASTRO = GETDATE() FROM  HR_CLIENTES_DEPENDENTES, INSERTED WHERE  HR_CLIENTES_DEPENDENTES.CODIGO_CLIENTE = INSERTED.CODIGO_CLIENTE and HR_CLIENTES_DEPENDENTES.ID_DEPENDENTE = INSERTED.ID_DEPENDENTE  
	return
	error:
             raiserror(@errmsg, 18, 1)
		rollback transaction
end
'

