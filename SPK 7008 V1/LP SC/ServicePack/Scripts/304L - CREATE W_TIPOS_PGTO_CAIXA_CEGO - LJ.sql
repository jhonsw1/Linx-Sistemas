--BASE DE LOJA
create view dbo.w_tipos_pgto_caixa_cego 
	as
	/*******************************************************************************
	-- Funcao:   w_tipos_pgto_caixa_cego - LOJA 
	-- Empresa:  MEGASULT - 
	-- Autor:    CARLOS MEGASULT - KATUXA
	-- Data:     27/05/2019
	-- Ex		 select * from w_tipos_pgto_caixa_cego

	********************************************************************************/
	SELECT A.DESC_TIPO_PGTO AS DESC_TIPO_PGTO,  A.TIPO_PGTO,	   COD_REPORT,
		   A.TIPO_PGTO AS COD_PGTO_ADM,
		   null as CODIGO_ADMINISTRADORA
	FROM (
			SELECT DISTINCT 
				   TIPO_PGTO,
				   DESC_TIPO_PGTO,
				   CASE WHEN TIPO_PGTO IN ('A','I','B','N','Z') THEN 'CRD'
						WHEN TIPO_PGTO IN ('K','E') THEN 'DEB'
						WHEN TIPO_PGTO IN ('C','P') THEN 'CHQ'
						WHEN TIPO_PGTO IN ('D') THEN 'DIN'
						WHEN TIPO_PGTO IN ('V') THEN 'V.CLI'
						WHEN TIPO_PGTO IN ('R') THEN 'V.PRD'
						WHEN TIPO_PGTO IN ('F') THEN 'V.FUN'
						WHEN TIPO_PGTO IN ('#') THEN 'CREDI'
				   ELSE 'OUTROS' END AS COD_REPORT
			FROM TIPOS_PGTO A
			WHERE TIPO_PGTO NOT IN ('^','O','U','<')
			AND A.INATIVO = 0
			UNION ALL
			SELECT LTRIM(RTRIM(TIPO_LANCAMENTO_CAIXA)) AS TIPO_PGTO,DESC_LANC_CAIXA AS DESC_TIPO_PGTO,'L'+LTRIM(RTRIM(TIPO_LANCAMENTO_CAIXA)) AS COD_REPORT
			FROM LOJA_CAIXA_TIPOS 
			WHERE INDICADOR_MOV_CAIXA IN ('R','E') AND INATIVO=0 AND LEN(TIPO_LANCAMENTO_CAIXA)=2 and isnull(TIPO_FISCAL,0) > 0
	) A

