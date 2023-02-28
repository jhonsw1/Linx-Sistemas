IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'W_HR_LOJA_PROMOCAO_LOJAS')
  BEGIN
	EXEC('CREATE VIEW dbo.W_HR_LOJA_PROMOCAO_LOJAS  
		AS  
			SELECT A.ID_PROMOCAO,CONVERT(VARCHAR(253),B.DESCRICAO) AS DESC_PROMOCAO, A.CODIGO_FILIAL, A.DATA_INICIO AS INICIO, A.DATA_FIM AS FIM,
			 REGRA AS DETALHE_PROMOCAO
			FROM HR_PROMOCAO_LOJAS A  
			  INNER JOIN HR_PROMOCAO B ON A.ID_PROMOCAO = B.ID_PROMOCAO  
			WHERE INATIVO = 0')

  END