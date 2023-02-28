CREATE TRIGGER [DBO].[LXI_LOJA_NOTA_FISCAL_IMPOSTO] ON [DBO].[LOJA_NOTA_FISCAL_IMPOSTO] FOR INSERT NOT FOR REPLICATION AS 
-- INSERT Trigger On LOJA_NOTA_FISCAL_IMPOSTO
Begin
	Declare	@numrows	Int,
		@nullcnt	Int,
		@validcnt	Int,
		@insCODIGO_FILIAL char(6), 
		@insNF_NUMERO char(15), 
		@insSERIE_NF char(6), 
		@insID_IMPOSTO tinyint, 
		@insSUB_ITEM_TAMANHO int, 
		@insITEM_IMPRESSAO char(4), 
		@errno   Int,
		@errmsg  varchar(255)
		
	Select @numrows = @@rowcount

-- LOJA_NOTA_FISCAL - Child Insert Restrict
	IF	UPDATE(CODIGO_FILIAL) OR 
		UPDATE(NF_NUMERO) OR 
		UPDATE(SERIE_NF)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJA_NOTA_FISCAL
		WHERE	INSERTED.CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL AND 
			INSERTED.NF_NUMERO = LOJA_NOTA_FISCAL.NF_NUMERO AND 
			INSERTED.SERIE_NF = LOJA_NOTA_FISCAL.SERIE_NF

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL_IMPOSTO #porque #LOJA_NOTA_FISCAL #não existe.'
			GoTo Error
		End
	End

-- CTB_LX_IMPOSTO_TIPO - Child Insert Restrict
	IF	UPDATE(ID_IMPOSTO)

	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, CTB_LX_IMPOSTO_TIPO
		WHERE	INSERTED.ID_IMPOSTO = CTB_LX_IMPOSTO_TIPO.ID_IMPOSTO

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL_IMPOSTO #porque #CTB_LX_IMPOSTO_TIPO #não existe.'
			GoTo Error
		End
	End

	return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End