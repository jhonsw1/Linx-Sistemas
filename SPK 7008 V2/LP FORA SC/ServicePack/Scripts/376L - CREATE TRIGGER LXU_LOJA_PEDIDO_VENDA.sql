CREATE TRIGGER [dbo].[LXU_LOJA_PEDIDO_VENDA] ON [dbo].[LOJA_PEDIDO_VENDA] FOR UPDATE NOT FOR REPLICATION AS 
--MODASP-7000 - #1# - Osvaldir Junior (24/10/2019) - Tratamento para Trocas na Pre venda
-- UPDATE Trigger On LOJA_PEDIDO_VENDA
Begin
	Declare	@numrows	Int,
		@nullcnt	Int,
		@validcnt	Int,
		@insPEDIDO int  , 
		@insCODIGO_FILIAL_ORIGEM char(6)  , 
		@insITEM int  , 
		@insTICKET char(8)  , 
		@insCODIGO_FILIAL char(6)  , 
		@insDATA_VENDA datetime  , 
		@insITEM_VENDA char(4) ,
		@delPEDIDO int  , 
		@delCODIGO_FILIAL_ORIGEM char(6)  , 
		@delITEM int  , 
		@delTICKET char(8)  , 
		@delCODIGO_FILIAL char(6)  , 
		@delDATA_VENDA datetime  , 
		@delITEM_VENDA char(4) ,
		@errno   Int,
		@errmsg  varchar(255)

	Select @numrows = @@rowcount



-- LOJA_PEDIDO_PRODUTO - Child Update Restrict
	IF	UPDATE(CODIGO_FILIAL_ORIGEM) OR 
		UPDATE(PEDIDO) OR 
		UPDATE(ITEM)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJA_PEDIDO_PRODUTO
		WHERE	INSERTED.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO_PRODUTO.CODIGO_FILIAL_ORIGEM AND 
			INSERTED.PEDIDO = LOJA_PEDIDO_PRODUTO.PEDIDO AND 
			INSERTED.ITEM = LOJA_PEDIDO_PRODUTO.ITEM

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Atualizar #LOJA_PEDIDO_VENDA #porque #LOJA_PEDIDO_PRODUTO #não existe.'
			GoTo Error
		End
	End
	
/*---LINX-ETL---------------------------------------------------------------------------------------*/
	UPDATE LOJA_PEDIDO
	SET LX_STATUS_PEDIDO = 1, DATA_PARA_TRANSFERENCIA = INSERTED.DATA_PARA_TRANSFERENCIA 
	FROM INSERTED,LOJA_PEDIDO
	WHERE
	   INSERTED.CODIGO_FILIAL_ORIGEM = LOJA_PEDIDO.CODIGO_FILIAL_ORIGEM AND
	   INSERTED.PEDIDO = LOJA_PEDIDO.PEDIDO AND
	   ISNULL(LOJA_PEDIDO.LX_STATUS_PEDIDO , 0 ) = 3


	return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End



