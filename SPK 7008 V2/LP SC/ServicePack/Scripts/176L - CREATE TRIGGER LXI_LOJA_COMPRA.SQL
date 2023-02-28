CREATE Trigger [dbo].[LXI_LOJA_COMPRA] On [dbo].[LOJA_COMPRA] For INSERT NOT FOR REPLICATION As 
-- INSERT Trigger On LOJA_COMPRA
Begin

-- 27/04/2017 - WENDEL CRESPIGIO - DM 14446 - #2# Devido o Cadastro de FILIAIS e LOJAS_VAREJO poder exister com o código diferentes, a trigger estava barrando a importação, adicionado no verificador um OR para se existir na LOJAS_VAREJO OU FILIAIS.
-- 26/04/2017 - WENDEL CRESPIGIO - DM 14446 - #1# Devido o Cadastro de FILIAIS e LOJAS_VAREJO poder exister com o código diferentes, a trigger estava barrando a importação, adicionado no verificador um OR para se existir na LOJAS_VAREJO OU FILIAIS.
	
	Declare	@numrows	Int,
		@nullcnt	Int,
		@validcnt	Int,
		@insPEDIDO char(8) , 
		@errno   Int,
		@errmsg  varchar(255)

	Select @numrows = @@rowcount
	
--LOJA_COMPRA_STATUS - Child Insert Restrict
	IF	UPDATE(STATUS_COMPRA)

	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJA_COMPRA_STATUS
		WHERE	INSERTED.STATUS_COMPRA = LOJA_COMPRA_STATUS.STATUS_COMPRA

		SELECT @NullCnt = count(*)
		FROM Inserted 
		WHERE	INSERTED.STATUS_COMPRA IS NULL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_COMPRA #porque #LOJA_COMPRA_STATUS #não existe.'
			GoTo Error
		End
	End

--LOJAS_VAREJO - Child Insert Restrict
	IF	UPDATE(CODIGO_FILIAL_ENTREGA)

	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJAS_VAREJO, FILIAIS 
		WHERE LOJAS_VAREJO.FILIAL = FILIAIS.FILIAL 
		AND	INSERTED.CODIGO_FILIAL_ENTREGA = LOJAS_VAREJO.CODIGO_FILIAL 

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_COMPRA #porque #LOJAS_VAREJO #não existe.'
			GoTo Error
		End
	End

--CLIENTES_VAREJO - Child Insert Restrict
	IF	UPDATE(CODIGO_CLIENTE_FORNECEDOR)

	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, CLIENTES_VAREJO
		WHERE	INSERTED.CODIGO_CLIENTE_FORNECEDOR = CLIENTES_VAREJO.CODIGO_CLIENTE

		SELECT @NullCnt = count(*)
		FROM Inserted 
		WHERE	INSERTED.CODIGO_CLIENTE_FORNECEDOR IS NULL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_COMPRA #porque #CLIENTES_VAREJO #não existe.'
			GoTo Error
		End
	End

--LOJAS_VAREJO - Child Insert Restrict
	IF	UPDATE(CODIGO_FILIAL_FRANQUEADOR)

	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJAS_VAREJO, FILIAIS
		WHERE	LOJAS_VAREJO.FILIAL = FILIAIS.FILIAL 
		AND INSERTED.CODIGO_FILIAL_FRANQUEADOR = LOJAS_VAREJO.CODIGO_FILIAL -- #2# 

		SELECT @NullCnt = count(*)
		FROM Inserted 
		WHERE	INSERTED.CODIGO_FILIAL_FRANQUEADOR IS NULL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_COMPRA #porque #LOJAS_VAREJO #não existe.'
			GoTo Error
		End
	End
	
	return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End
