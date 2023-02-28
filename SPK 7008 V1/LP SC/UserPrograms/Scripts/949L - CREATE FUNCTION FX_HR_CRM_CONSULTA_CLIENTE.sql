IF EXISTS 
(
SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FX_HR_CRM_CONSULTA_CLIENTE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')
)
BEGIN
	DROP FUNCTION [dbo].[FX_HR_CRM_CONSULTA_CLIENTE]
END
BEGIN
	EXEC 
('
CREATE FUNCTION [dbo].[FX_HR_CRM_CONSULTA_CLIENTE](@CODIGO_FILIAL CHAR(6), @CPF VARCHAR(19)) 

--- HERING - Mandicaju - 20220713 - Função ajustada para fixar +30 minutos o delay para consulta no CRM, ou ver no parametro HR_DELAY_BUSCA_CLI_PDV

 RETURNS @CLIENTE_RETORNO TABLE(      
  CODIGO_FILIAL CHAR(6),      
  CNPJ_LOJA VARCHAR(19),      
  CODIGO_CLIENTE VARCHAR(14),      
  CPF VARCHAR(19),      
  ATUALIZA_CRM BIT 
 )      
 BEGIN      
       
  DECLARE @CNPJ VARCHAR(19),      
    @CODIGO_CLIENTE VARCHAR(14),
    @DATA_PARA_TRANSFERENCIA   DATETIME,      
	@DELAY_BUSCA_CLIENTE INT,
	@DELAY_BUSCA_CLIENTE_PARAMETRO VARCHAR(20)

	SET @DELAY_BUSCA_CLIENTE_PARAMETRO = dbo.FX_PARAMETRO_LOJA (''HR_DELAY_BUSCA_CLI_PDV'', @CODIGO_FILIAL)
	IF isnull(@DELAY_BUSCA_CLIENTE_PARAMETRO, '''') != '''' AND ISNUMERIC(REPLACE(REPLACE(RTRIM(@DELAY_BUSCA_CLIENTE_PARAMETRO),''+'',''A''),''-'',''A'') + ''.0E0'') = 1
	SET @DELAY_BUSCA_CLIENTE = CONVERT(INT, REPLACE(REPLACE(RTRIM(@DELAY_BUSCA_CLIENTE_PARAMETRO),''+'',''A''),''-'',''A''))
     
	IF @DELAY_BUSCA_CLIENTE IS NULL
	SET @DELAY_BUSCA_CLIENTE = 30

  SELECT @CNPJ = CGC_CPF      
  FROM FILIAIS (NOLOCK)        
  WHERE COD_FILIAL = @CODIGO_FILIAL      
        
  SELECT @CODIGO_CLIENTE = MIN(CODIGO_CLIENTE), --#1#
  @DATA_PARA_TRANSFERENCIA=MAX(CASE WHEN ISNULL(DATA_PARA_TRANSFERENCIA, GETDATE()) < GETDATE() THEN DATA_PARA_TRANSFERENCIA END) --#1#
  FROM CLIENTES_VAREJO (NOLOCK)
  WHERE CLIENTES_VAREJO.CPF_CGC = @CPF
        
  INSERT INTO @CLIENTE_RETORNO(      
   CODIGO_FILIAL,      
   CNPJ_LOJA,      
   CODIGO_CLIENTE,      
   CPF,      
   ATUALIZA_CRM      
  )      
  VALUES(@CODIGO_FILIAL,      
   @CNPJ,      
   @CODIGO_CLIENTE,      
   @CPF,      
   CASE WHEN DATEDIFF(minute,ISNULL(@DATA_PARA_TRANSFERENCIA,GETDATE()-30),GETDATE()) > @DELAY_BUSCA_CLIENTE THEN 1 ELSE 0 END      
  )      
        
  RETURN       
 END
 ')
END