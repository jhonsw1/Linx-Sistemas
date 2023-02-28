IF EXISTS(SELECT 1 FROM PARAMETROS WHERE PARAMETRO = 'QRLINX_HABILITA')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM PARAMETROS_LOJA WHERE PARAMETRO = 'QRLINX_HABILITA' AND VALOR_ATUAL = '.T.')
		AND EXISTS (SELECT 1 FROM PARAMETROS_LOJA_TERMINAL WHERE PARAMETRO like 'QRLINX_POS_ID%' AND ISNULL(VALOR_ATUAL,'') != '')
	BEGIN
		IF EXISTS (SELECT 1 FROM PARAMETROS_LOJA WHERE PARAMETRO = 'QRLINX_HABILITA')
			UPDATE PARAMETROS_LOJA SET VALOR_ATUAL = '.T.' WHERE PARAMETRO = 'QRLINX_HABILITA'
		ELSE
			INSERT INTO PARAMETROS_LOJA (PARAMETRO, CODIGO_FILIAL, VALOR_ATUAL, PERMITE_ALTERAR_NA_LOJA, DATA_PARA_TRANSFERENCIA)
			SELECT TOP 1 'QRLINX_HABILITA' AS PARAMETRO, CODIGO_FILIAL, '.T.' AS VALOR_ATUAL, 1, GETDATE()
			FROM PARAMETROS_LOJA_TERMINAL WHERE PARAMETRO like 'QRLINX_POS_ID%' AND ISNULL(VALOR_ATUAL,'') != ''
	END
END