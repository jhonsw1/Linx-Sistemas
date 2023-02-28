
CREATE trigger [dbo].[LXD_PARAMETROS] on [dbo].[PARAMETROS] for DELETE NOT FOR REPLICATION as

begin
  declare  @delPARAMETRO varchar(25),
           @errno   int,
           @errmsg  varchar(255)
		   
	If APP_NAME() like ('%Microsoft SQL Server Management Studio%')
	Begin 
		   select @errno  = 30002,
		   @errmsg ='Nao e possivel excluir parametro!'

		   GoTo Error
	End 
	
	
    delete PARAMETROS_LOJA_TERMINAL
      from PARAMETROS_LOJA_TERMINAL,deleted
      where
        PARAMETROS_LOJA_TERMINAL.PARAMETRO = deleted.PARAMETRO

    delete PARAMETROS_LOJA
      from PARAMETROS_LOJA,deleted
      where
        PARAMETROS_LOJA.PARAMETRO = deleted.PARAMETRO

    return
error:
    raiserror(@errmsg, 18, 1)
    rollback transaction
end 