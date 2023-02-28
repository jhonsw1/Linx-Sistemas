IF NOT EXISTS(SELECT object_id FROM SYS.OBJECTS WHERE OBJECTS.NAME = 'SP_HR_CRM_ATUALIZA_CADASTRO_CLIENTE' AND objects.type = 'P')
BEGIN
	EXEC('CREATE PROCEDURE [dbo].[SP_HR_CRM_ATUALIZA_CADASTRO_CLIENTE](
@CODIGO_CLIENTE VARCHAR(14), @NOME_CLIENTE VARCHAR(40), @FILIAL VARCHAR(25),
@CPF_CNPJ VARCHAR(14), @PF_PJ INT, @PONTUALIDADE VARCHAR(25),
@CODIGO_CONTATO CHAR(8), @TIPO_VAREJO VARCHAR(25), @ENDERECO VARCHAR(90),
@RG_IE VARCHAR(19), @CEP VARCHAR(9), @TIPO_LOGRADOURO VARCHAR(10),
@NUMERO VARCHAR(10), @BAIRRO VARCHAR(25), @CIDADE VARCHAR(35),
@UF CHAR(2), @PAIS VARCHAR(40), @COMPLEMENTO VARCHAR(35),
@DDDTELEFONE CHAR(4), @TELEFONE VARCHAR(10), @ANIVERSARIO DATETIME,
@OBSERVACAO VARCHAR(MAX), @SEXO CHAR(1), @TIPO_TELEFONE CHAR(1),
@EMAIL VARCHAR(100), @ULTIMA_COMPRA DATETIME, @ESTADO_CIVIL TINYINT,
@PROFISSAO VARCHAR(40), @DDD_CELULAR VARCHAR(4), @CELULAR VARCHAR(10),
@LIMITE_CREDITO NUMERIC(14,2), @DATA_CADASTRAMENTO DATETIME, @VENDEDOR CHAR(4)
)
AS
BEGIN
DECLARE @PJ_PF_LINX BIT
if ISNULL(@codigo_cliente,'''') = ''''
BEGIN
return
END
SET @PJ_PF_LINX = CONVERT(BIT,CASE WHEN @PF_PJ IN (0,2) THEN 0 ELSE 1 END)
SET @ANIVERSARIO = CASE WHEN @ANIVERSARIO = ''19000101'' THEN NULL ELSE @ANIVERSARIO END
SET @ULTIMA_COMPRA = CASE WHEN @ULTIMA_COMPRA = ''19000101'' THEN NULL ELSE @ULTIMA_COMPRA END
IF NOT EXISTS (SELECT 1 FROM FILIAIS WHERE FILIAL= @FILIAL)
BEGIN
SET @FILIAL = (SELECT TOP 1 B.FILIAL FROM LOJA_VENDA A
INNER JOIN FILIAIS B ON A.CODIGO_FILIAL =B.COD_FILIAL WHERE DATA_VENDA >=GETDATE()-10)
END
SET @TELEFONE = ISNULL(@TELEFONE,'''')
SET @VENDEDOR = ISNULL((SELECT TOP 1 VENDEDOR FROM LOJA_VENDEDORES WHERE VENDEDOR=@VENDEDOR),NULL)
SET @TIPO_VAREJO = ISNULL((SELECT TOP 1 TIPO_VAREJO FROM CLIENTE_VAR_TIPOS WHERE TIPO_VAREJO=@TIPO_VAREJO),''CLIENTES VAREJO'')

IF NOT EXISTS(SELECT TOP 1 CODIGO_CLIENTE FROM CLIENTES_VAREJO WHERE CODIGO_CLIENTE = @CODIGO_CLIENTE)
BEGIN
INSERT INTO CLIENTES_VAREJO(
CODIGO_CLIENTE, CLIENTE_VAREJO, FILIAL,
CPF_CGC, PF_PJ, PONTUALIDADE,
CODIGO_CONTATO, TIPO_VAREJO, ENDERECO,
RG_IE, CEP, TIPO_LOGRADOURO,
NUMERO, BAIRRO, CIDADE,
UF, PAIS, COMPLEMENTO,
DDD, TELEFONE, ANIVERSARIO,
OBS, SEXO, TIPO_TELEFONE,
EMAIL, ULTIMA_COMPRA, ESTADO_CIVIL,
PROFISSAO, DDD_CELULAR, CELULAR,
LIMITE_CREDITO, CADASTRAMENTO, VENDEDOR , DATA_CRM
)
VALUES(
@CODIGO_CLIENTE, RTRIM(LTRIM(@NOME_CLIENTE)), @FILIAL,
@CPF_CNPJ, @PJ_PF_LINX, @PONTUALIDADE,
@CODIGO_CONTATO, @TIPO_VAREJO, @ENDERECO,
@RG_IE, @CEP, @TIPO_LOGRADOURO,
@NUMERO, @BAIRRO, @CIDADE,
@UF, isnull(@PAIS,''BRASIL''), @COMPLEMENTO,
@DDDTELEFONE, @TELEFONE, @ANIVERSARIO,
@OBSERVACAO, @SEXO, @TIPO_TELEFONE,
@EMAIL, @ULTIMA_COMPRA, @ESTADO_CIVIL,
@PROFISSAO, @DDD_CELULAR, @CELULAR,
@LIMITE_CREDITO, @DATA_CADASTRAMENTO, @VENDEDOR , GETDATE()
)
end
else
begin
UPDATE CLIENTES_VAREJO SET
CLIENTE_VAREJO =RTRIM(LTRIM(@NOME_CLIENTE)),
FILIAL =@FILIAL,
PF_PJ =@PJ_PF_LINX,
CODIGO_CONTATO =@CODIGO_CONTATO,
TIPO_VAREJO =@TIPO_VAREJO,
ENDERECO =@ENDERECO,
RG_IE =@RG_IE,
CEP =@CEP,
TIPO_LOGRADOURO =@TIPO_LOGRADOURO,
NUMERO =@NUMERO,
BAIRRO =@BAIRRO,
CIDADE =@CIDADE,
UF =@UF,
PAIS =isnull(@PAIS,''BRASIL''),
COMPLEMENTO =@COMPLEMENTO,
DDD =@DDDTELEFONE,
TELEFONE =@TELEFONE,
ANIVERSARIO =@ANIVERSARIO,
SEXO =@SEXO,
EMAIL =@EMAIL,
DDD_CELULAR =@DDD_CELULAR,
CELULAR =@CELULAR,
CADASTRAMENTO =@DATA_CADASTRAMENTO,
PONTUALIDADE = @PONTUALIDADE,
DATA_CRM =GETDATE()
WHERE CPF_CGC = @CPF_CNPJ
END
END
	')
END 

