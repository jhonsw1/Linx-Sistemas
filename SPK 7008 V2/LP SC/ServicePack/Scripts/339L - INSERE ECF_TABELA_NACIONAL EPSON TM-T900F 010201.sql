IF NOT EXISTS (SELECT * FROM ECF_TABELA_NACIONAL WHERE MARCAMODELOECF = 'EPSON TM-T900F' AND VERSAOECF = '010201')
	BEGIN
		INSERT INTO ECF_TABELA_NACIONAL	(IDMARCA,IDMODELO,IDVERSAO,MARCAECF,MODELOECF,VERSAOECF,MARCAMODELOECF)
		VALUES ('15','11','03','EPSON','TM-T900F','010201','EPSON TM-T900F')
	END;