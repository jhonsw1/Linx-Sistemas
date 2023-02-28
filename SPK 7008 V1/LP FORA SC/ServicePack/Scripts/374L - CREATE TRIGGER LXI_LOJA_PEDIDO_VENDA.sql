CREATE TRIGGER [dbo].[LXI_LOJA_PEDIDO_VENDA] ON [dbo].[LOJA_PEDIDO_VENDA] FOR INSERT NOT FOR REPLICATION AS 
--MODASP-7000 - #1# - Osvaldir Junior (24/10/2019) - Tratamento para Trocas na Pre venda
-- INSERT Trigger On LOJA_PEDIDO_VENDA
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
		@errno   Int,
		@errmsg  varchar(255)

	Select @numrows = @@rowcount

-- LOJA_PEDIDO_PRODUTO - Child Insert Restrict
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
				@errmsg = 'Impossível Incluir #LOJA_PEDIDO_VENDA #porque #LOJA_PEDIDO_PRODUTO #não existe.'
			GoTo Error
		End
	End

	return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End



