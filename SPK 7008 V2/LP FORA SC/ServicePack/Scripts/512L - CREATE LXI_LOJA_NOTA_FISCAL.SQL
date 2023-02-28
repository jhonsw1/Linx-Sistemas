CREATE TRIGGER [dbo].[LXI_LOJA_NOTA_FISCAL] ON [dbo].[LOJA_NOTA_FISCAL] 
WITH ENCRYPTION 
FOR INSERT NOT FOR REPLICATION AS 

-- INSERT Trigger On LOJA_NOTA_FISCAL
-- WENDEL CRESPIGIO  - #1# - (07/02/2022) - PRODSHOP-10572 - NAO PERMITIR DE FORMA ALGUMA NFC-E DESVINCULADAS DE VENDAS SEJAM AUTORIZADAS , TRIGGER PASSOU A SER CRIPTOGRAFADA.
Begin
	Declare	@numrows	Int,
		@nullcnt	Int,
		@validcnt	Int,
		@insCODIGO_FILIAL char(6), 
		@insNF_NUMERO char(15), 
		@insSERIE_NF char(6), 
		@errno   Int,
		@errmsg  varchar(255)

	Select @numrows = @@rowcount

-- LOJAS_VAREJO - Child Insert Restrict
	IF	UPDATE(CODIGO_FILIAL)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJAS_VAREJO
		WHERE	INSERTED.CODIGO_FILIAL = LOJAS_VAREJO.CODIGO_FILIAL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL #porque #LOJAS_VAREJO #não existe.'
			GoTo Error
		End
	End

-- CLIENTES_VAREJO - Child Insert Restrict
	IF	UPDATE(CODIGO_CLIENTE)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, CLIENTES_VAREJO
		WHERE	INSERTED.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE

		SELECT @NullCnt = count(*)
		FROM Inserted 
		WHERE	INSERTED.CODIGO_CLIENTE IS NULL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL #porque #CLIENTES_VAREJO #não existe.'
			GoTo Error
		End
	End

-- LOJAS_VAREJO - Child Insert Restrict
	IF	UPDATE(COD_CLIFOR)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, CADASTRO_CLI_FOR
		WHERE	INSERTED.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR

		SELECT @NullCnt = count(*)
		FROM Inserted 
		WHERE	INSERTED.COD_CLIFOR IS NULL

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL #porque #CADASTRO_CLI_FOR #não existe.'
			GoTo Error
		End
	End

-- LOJAS_NATUREZA_OPERACAO - Child Insert Restrict
	IF	UPDATE(NATUREZA_OPERACAO_CODIGO)
	Begin
		SELECT @NullCnt = 0
		SELECT @ValidCnt = count(*)
		FROM Inserted, LOJAS_NATUREZA_OPERACAO
		WHERE	INSERTED.NATUREZA_OPERACAO_CODIGO = LOJAS_NATUREZA_OPERACAO.NATUREZA_OPERACAO_CODIGO

		If @validcnt + @nullcnt != @numrows
		Begin
			Select	@errno  = 30002,
				@errmsg = 'Impossível Incluir #LOJA_NOTA_FISCAL #porque #LOJAS_NATUREZA_OPERACAO #não existe.'
			GoTo Error
		End
	End

------------------------------------------------------------------------------------------------------------------------------------------
--#1# INICIO - NOTAS NAO VINCULADAS A VENDAS NAO SERAO MAIS AUTORIZADAS NO SISTEMA.

IF UPDATE(STATUS_NFE)
BEGIN 
	IF EXISTS (SELECT 1 FROM DBO.LOJA_NOTA_FISCAL A     (NOLOCK)
                     INNER JOIN DBO.SERIES_NF B         (NOLOCK)
                             ON A.SERIE_NF = B.SERIE_NF
                     INNER JOIN DBO.CTB_ESPECIE_SERIE C (NOLOCK)
                             ON C.ESPECIE_SERIE  = B.ESPECIE_SERIE
                     LEFT JOIN LOJA_VENDA_PGTO D        (NOLOCK)
					         ON  A.NF_NUMERO     = D.NUMERO_FISCAL_VENDA
							 AND A.SERIE_NF      = D.SERIE_NF_SAIDA 
							 AND A.CODIGO_FILIAL = D.CODIGO_FILIAL 
                     INNER JOIN INSERTED 
					         ON A.NF_NUMERO      = INSERTED.NF_NUMERO 
							 AND A.SERIE_NF      = INSERTED.SERIE_NF
							 AND A.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL 
					WHERE C.NUMERO_MODELO_FISCAL = '65'
							AND A.STATUS_NFE NOT IN (59,49,70)
						    AND INSERTED.STATUS_NFE = 5
							AND D.NUMERO_FISCAL_VENDA IS NULL)
	BEGIN 
		UPDATE A SET STATUS_NFE =52 , LOG_STATUS_NFE =0 FROM LOJA_NOTA_FISCAL A , INSERTED 
			WHERE A.NF_NUMERO =INSERTED.NF_NUMERO 
			AND   A.SERIE_NF = INSERTED.SERIE_NF 
			AND   A.CODIGO_FILIAL =INSERTED.CODIGO_FILIAL 
	END 
END 
-- #1# FIM
----------------------------------------------------------------------------------------------------------------------------------
Return
Error:
	raiserror(@errmsg, 18, 1)
	rollback transaction
End
