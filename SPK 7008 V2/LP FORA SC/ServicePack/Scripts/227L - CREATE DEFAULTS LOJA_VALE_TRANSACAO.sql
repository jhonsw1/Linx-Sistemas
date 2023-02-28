IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_VALE_TRANSACAO' AND COLUMN_NAME = 'TRANSACAO_INICIADA' AND COLUMN_DEFAULT IS NULL)
	EXEC SP_BINDEFAULT 'DEFAULT_0', 'LOJA_VALE_TRANSACAO.TRANSACAO_INICIADA'

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_VALE_TRANSACAO' AND COLUMN_NAME = 'TRANSACAO_CONCLUIDA' AND COLUMN_DEFAULT IS NULL)
	EXEC SP_BINDEFAULT 'DEFAULT_0', 'LOJA_VALE_TRANSACAO.TRANSACAO_CONCLUIDA'

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOJA_VALE_TRANSACAO' AND COLUMN_NAME = 'ENVIADA_OMNI' AND COLUMN_DEFAULT IS NULL)
	EXEC SP_BINDEFAULT 'DEFAULT_0', 'LOJA_VALE_TRANSACAO.ENVIADA_OMNI'