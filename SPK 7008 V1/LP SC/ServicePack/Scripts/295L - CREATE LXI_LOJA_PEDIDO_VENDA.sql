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

-- Valida em LOJA_VENDA_PRODUTO e em LOJA_VENDA_TROCA
  if 
     update(CODIGO_FILIAL) or 
     update(TICKET) or 
     update(DATA_VENDA) or
     update(ITEM_VENDA)
  begin
    select @nullcnt = 0
    
	select @validcnt = count(*)
	from
	(select inserted.CODIGO_FILIAL, inserted.TICKET, inserted.DATA_VENDA, inserted.ITEM_VENDA
		from inserted,LOJA_VENDA_PRODUTO
     where 
           inserted.CODIGO_FILIAL = LOJA_VENDA_PRODUTO.CODIGO_FILIAL AND
           inserted.TICKET = LOJA_VENDA_PRODUTO.TICKET AND
           inserted.DATA_VENDA = LOJA_VENDA_PRODUTO.DATA_VENDA AND
           inserted.ITEM_VENDA = LOJA_VENDA_PRODUTO.ITEM
    union
      select inserted.CODIGO_FILIAL, inserted.TICKET, inserted.DATA_VENDA, inserted.ITEM_VENDA
      from inserted,LOJA_VENDA_TROCA
     where 
           inserted.CODIGO_FILIAL = LOJA_VENDA_TROCA.CODIGO_FILIAL AND
           inserted.TICKET = LOJA_VENDA_TROCA.TICKET AND
           inserted.DATA_VENDA = LOJA_VENDA_TROCA.DATA_VENDA AND
           inserted.ITEM_VENDA = LOJA_VENDA_TROCA.ITEM) A

    select @nullcnt = count(*) from inserted where
      inserted.CODIGO_FILIAL is null or
      inserted.TICKET is null or
      inserted.DATA_VENDA is null or
      inserted.ITEM_VENDA is null
    
	if @validcnt + @nullcnt < @numrows
    begin
      select @errno  = 30002,
             @errmsg = 'Impossível Incluir #LOJA_PEDIDO_VENDA #porque #LOJA_VENDA_PRODUTO # ou #LOJA_VENDA_TROCA #não existe.'
      goto error
    end
  end

	return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End
