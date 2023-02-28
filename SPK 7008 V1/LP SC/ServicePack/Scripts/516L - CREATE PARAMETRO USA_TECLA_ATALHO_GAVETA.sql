IF NOT EXISTS (SELECT PARAMETRO FROM PARAMETROS WHERE PARAMETRO = 'USA_TECLA_ATALHO_GAVETA')
BEGIN

INSERT INTO PARAMETROS(PARAMETRO , PENULT_ATUALIZACAO ,VALOR_DEFAULT, ULT_ATUALIZACAO ,VALOR_ATUAL, DESC_PARAMETRO ,TIPO_DADO, RANGE_VALOR_ATUAL, GLOBAL, NOTA_PROGRAMADOR ,ESCOPO ,POR_USUARIO_OK, PERMITE_POR_EMPRESA ,ENVIA_PARA_LOJA, PERMITE_POR_LOJA, PERMITE_POR_TERMINAL, PERMITE_ALTERAR_NA_LOJA, PERMITE_ALTERAR_NO_TERMINAL, ENVIA_PARA_REPRESENTANTE, PERMITE_POR_REPRESENTANTE, PERMITE_ALTERAR_NO_REPRESENTANTE, DATA_PARA_TRANSFERENCIA)
VALUES ('USA_TECLA_ATALHO_GAVETA',GETDATE(), '.F.' ,GETDATE(),'.F.' ,'Habilita o uso da tecla de atalho F10 para abertura da gaveta', 'L' ,'', 0 ,'parametro criado p/ ambiente de loja'  , 0  ,0  , 0 ,1 ,1,0 , 0 ,0, 0 ,0,0,GETDATE())

END