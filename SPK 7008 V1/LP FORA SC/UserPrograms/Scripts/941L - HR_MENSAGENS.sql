IF Object_id('DBO.HR_MENSAGENS', 'U') IS NULL
  BEGIN
     CREATE TABLE DBO.HR_MENSAGENS(
		ID_MENSAGEM		INT		 NOT NULL,
		INICIO			DATETIME NOT NULL,
		FIM				DATETIME NOT NULL ,
		MENSAGEM		TEXT,
		CODIGO_FILIAL	VARCHAR(6),
		DATA_PARA_TRANSFERENCIA DATETIME
		CONSTRAINT [XPKHR_MENSAGENS] PRIMARY KEY NONCLUSTERED 
		(
			[ID_MENSAGEM] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
		) ON [PRIMARY]
  END