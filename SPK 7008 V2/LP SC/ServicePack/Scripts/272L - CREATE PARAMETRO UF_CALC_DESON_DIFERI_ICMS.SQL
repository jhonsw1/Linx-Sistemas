IF NOT EXISTS(SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'UF_CALC_DESON_DIFERI_ICMS')
INSERT INTO PARAMETROS(
						PARAMETRO, 
						DESC_PARAMETRO, 
						PENULT_ATUALIZACAO, 
						ULT_ATUALIZACAO, 
						TIPO_DADO, 
						VALOR_DEFAULT, 
						VALOR_ATUAL, 
						GLOBAL, 
						ENVIA_PARA_LOJA, 
						PERMITE_POR_LOJA, 
						PERMITE_POR_TERMINAL, 
						PERMITE_ALTERAR_NA_LOJA, 
						PERMITE_ALTERAR_NO_TERMINAL,
						NOTA_PROGRAMADOR
					)
			VALUES
					(
						'UF_CALC_DESON_DIFERI_ICMS',
						'Lista de UFs cujo cálculo de vICMSDeson e vICMSDif deve ser com acréscimo de ICMS não embutido.',
						'20191109',
						'20191109',
						'C',
						'RJ',
						'RJ',
						0,
						1,
						0,
						0,
						0,
						0,
						'Lista de UFs cujo cálculo de vICMSDeson e vICMSDif deve ser a partir de valor hipotético, que é acrescido do ICMS que não estava previamente embutido no preço da mercadoria.'
					)