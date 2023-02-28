CREATE FUNCTION FX_RETORNAR_ENDERECO_ENTREGA_OMS(@CODIGO_FILIAL CHAR(6), @NF_NUMERO CHAR(15), @SERIENF CHAR(6))  
 RETURNS @DADOSENTREGA TABLE  
(  
 CNPJ_ENTREGA      CHAR(14),  
 CPF_ENTREGA          CHAR(11),  
 LOGRADOURO_ENTREGA  VARCHAR(90),  
 NRO_ENTREGA          VARCHAR(10),  
 COMPLEMENTO_ENTREGA  VARCHAR(60),  
 BAIRRO_ENTREGA         VARCHAR(35),  
 COD_MUN_ENTREGA      VARCHAR(10),  
 MUN_ENTREGA          VARCHAR(35),  
 UF            CHAR(2),  
 -------------------  
 -- INÍCIO - #01# --  
 -------------------  
 CEP                     VARCHAR(9),  
 --------------  
 -- FIM #01# --  
 --------------   
 -------------------  
 -- INÍCIO - #02# --  
 -------------------  
 DDD                  VARCHAR(5),  
 TELEFONE             VARCHAR(10),   
 --------------  
 -- FIM #02# --  
 --------------   
  
 --------------  
 -- INICIO #03# --  
 --------------   
 CPF_CGC      VARCHAR(19)  
 --------------  
 -- FIM #03# --  
 --------------   
)  
  
AS   
-- POSSP-4342 - Gilvano Santos  - #05# - (22/09/2020) - Inclusão da validações do venda delivery  
-- DM# 101571 - Fabio/Artuzo	- #04# - (19/11/2018) - Inclusão de validações de valores nulos ( refatorar )
-- SEM DEMANDA - ANDRÉ ARTUZO	- #03# - (14/09/2018) - ADICIONADO CAMPO CPF_CGC E ALTERAÇÃO DOS CAMPOS NRO_ENTREGA.  
-- SEM DEMANDA - MAYDSON HEDLUND - #02# - (10/09/2018) - ADICIONADO CAMPO DDD E TELEFONE.  
-- SEM DEMANDA - MAYDSON HEDLUND - #01# - (10/09/2018) - ADICIONADO CAMPO CEP.  
  
BEGIN   
  
 DECLARE @TERMINAL             CHAR(3)  
 DECLARE @LANCAMENTO_CAIXA     CHAR(7)  
 DECLARE @TICKET               CHAR(8)  
 DECLARE @CODIGO_FILIAL_ORIGEM CHAR(6)  
 DECLARE @PEDIDO               INT  
 DECLARE @DATA_VENDA           DATETIME  
 DECLARE @ITEM_ENDERECO        CHAR(18)  
 DECLARE @CPF_CGC              VARCHAR(14)  
 DECLARE @PF_PJ                BIT  
 DECLARE @CODIGO_CLIENTE       VARCHAR(14)  
 DECLARE @ENDERECO             VARCHAR(90)  
 DECLARE @ENDERECO_COMPLETO    VARCHAR(90)  
 DECLARE @NROENTREGA           VARCHAR(10)  
 DECLARE @CPLENTREGA           VARCHAR(60)  
 DECLARE @BAIRROENTREGA       VARCHAR(35)  
 DECLARE @CODMUNENTREGA       VARCHAR(10)  
 DECLARE @MUNENTREGA           VARCHAR(35)  
 DECLARE @UF                   CHAR(2)  
 -------------------  
 -- INÍCIO - #01# --  
 -------------------  
 DECLARE @CEP                  VARCHAR(9)  
 --------------  
 -- FIM #01# --  
 --------------  
 -------------------  
 -- INÍCIO - #02# --  
 -------------------  
 DECLARE @DDD                  VARCHAR(5)  
 DECLARE @TELEFONE             VARCHAR(10)   
 --------------  
 -- FIM #02# --  
 --------------   
 DECLARE @POS                  INT  
 DECLARE @TAM                  INT  
 DECLARE @POSREAL              INT  
 DECLARE @TB_ENDERECO          TABLE (ENDERECO VARCHAR(90))  
   
 SELECT @TERMINAL = TERMINAL, @LANCAMENTO_CAIXA = LANCAMENTO_CAIXA    
 FROM LOJA_VENDA_PGTO PGTO   
 WHERE PGTO.NUMERO_FISCAL_VENDA = @NF_NUMERO AND  
   PGTO.SERIE_NF_SAIDA    = @SERIENF AND  
   PGTO.CODIGO_FILIAL    = @CODIGO_FILIAL  
 
  --Inicio - #5#
 if @LANCAMENTO_CAIXA is null
 begin
	--NF-e Vinculada
	 SELECT @TERMINAL = TERMINAL, @LANCAMENTO_CAIXA = LANCAMENTO_CAIXA    
	 FROM LOJA_VENDA_PGTO PGTO  (nolock) 
	 WHERE PGTO.NUMERO_FISCAL_VINCULADA = @NF_NUMERO AND  
	   PGTO.SERIE_NF_VINCULADA = @SERIENF AND  
	   PGTO.CODIGO_FILIAL = @CODIGO_FILIAL  
 end
  --Fim - #5#

 SELECT @TICKET = TICKET ,@DATA_VENDA = DATA_VENDA, @CODIGO_CLIENTE = CODIGO_CLIENTE  
 FROM LOJA_VENDA   
 WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND  
   TERMINAL   = @TERMINAL AND  
   LANCAMENTO_CAIXA = @LANCAMENTO_CAIXA  
     
 SELECT TOP 1 @PEDIDO = PEDIDO, @CODIGO_FILIAL_ORIGEM = CODIGO_FILIAL_ORIGEM   
 FROM LOJA_PEDIDO_VENDA      
 WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND  
   TICKET   = @TICKET AND  
   DATA_VENDA = @DATA_VENDA  
 
--Inicio - #5#
 IF @PEDIDO IS NULL /*#04# */
 Begin
    --GOTO RETORNO_NULO
	SELECT TOP 1  @ITEM_ENDERECO = ITEM_ENDERECO  
	 FROM LOJA_VENDA_ENTREGA (nolock)     
	 WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND  
	   TICKET   = @TICKET AND  
	   DATA_VENDA = @DATA_VENDA AND
	   ITEM_ENDERECO > 0

	 IF @ITEM_ENDERECO IS NULL 
	  GOTO RETORNO_NULO
 END
 ELSE
 BEGIN
	SELECT @ITEM_ENDERECO = ITEM_ENDERECO  
	 FROM LOJA_PEDIDO_ENTREGA (nolock)  
	 WHERE CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL_ORIGEM AND   
	   PEDIDO = @PEDIDO AND   
	   SEQ_ENTREGA = 1  
 
	 IF @ITEM_ENDERECO IS NULL /*#04# */
	  GOTO RETORNO_NULO 
 END
  --Fim - #5#
 
--SELECT @ITEM_ENDERECO = ITEM_ENDERECO  
-- FROM LOJA_PEDIDO_ENTREGA  
-- WHERE CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL_ORIGEM AND   
--   PEDIDO = @PEDIDO AND   
--   SEQ_ENTREGA = 1  
 
-- IF @ITEM_ENDERECO IS NULL /*Ajuste temporário #04# */
--  GOTO RETORNO_NULO 
 
 SELECT  @ENDERECO      = CLI_ENDERECO.ENDERECO,   
   @NROENTREGA    = '',  
   @CPLENTREGA    = CLI_ENDERECO.COMPLEMENTO,  
   @BAIRROENTREGA = CLI_ENDERECO.BAIRRO,  
   @CODMUNENTREGA = '',  
   @MUNENTREGA    = CLI_ENDERECO.CIDADE,  
   @UF            = CLI_ENDERECO.UF,  
   @CPF_CGC       = CLI_VAREJO.CPF_CGC,  
   @PF_PJ     = CLI_VAREJO.PF_PJ,  
   -------------------  
   -- INÍCIO - #01# --  
   -------------------  
   @CEP           = CLI_ENDERECO.CEP,  
   ----------------  
   -- FIM - #01# --  
   ----------------     
   -------------------  
   -- INÍCIO - #02# --  
   -------------------  
   @DDD           = CLI_ENDERECO.DDD,  
   @TELEFONE      = CLI_ENDERECO.TELEFONE  
   ----------------  
   -- FIM - #02# --  
   ----------------  
  
 FROM CLIENTE_VAR_ENDERECOS CLI_ENDERECO  
 INNER JOIN CLIENTES_VAREJO CLI_VAREJO ON  
   CLI_ENDERECO.CODIGO_CLIENTE = CLI_VAREJO.CODIGO_CLIENTE  
 WHERE CLI_ENDERECO.CODIGO_CLIENTE = @CODIGO_CLIENTE AND  
   ITEM_ENDERECO = @ITEM_ENDERECO  
   
 insert into @TB_ENDERECO  
 values (@ENDERECO)  
  
  
 select  @ENDERECO_COMPLETO = ISNULL(ENDERECO, '') from @TB_ENDERECO  
 SET @TAM = LEN(@ENDERECO_COMPLETO + '|') - 1  
 SET @POS = CHARINDEX(',',REVERSE(@ENDERECO_COMPLETO))  
 IF (@POS > 0)  
 BEGIN  
  SET @POSREAL = @TAM - @POS + 1  
  SELECT @ENDERECO = RTRIM(LTRIM(SUBSTRING(@ENDERECO_COMPLETO, 1, @POSREAL - 1))), @NROENTREGA=  RTRIM(LTRIM(SUBSTRING(@ENDERECO_COMPLETO, @POSREAL + 1, @TAM - @POSREAL)))  
 END  
 ELSE  
  SELECT @ENDERECO = RTRIM(LTRIM(@ENDERECO)), @NROENTREGA = NULL    --#3#  
  
  SELECT TOP 1 @CODMUNENTREGA = LCF_LX_MUNICIPIO.COD_MUNICIPIO_IBGE  
   FROM   LCF_LX_MUNICIPIO (NOLOCK)  
   INNER JOIN LCF_LX_UF U (NOLOCK)  
   ON U.ID_UF = LCF_LX_MUNICIPIO.ID_UF  
   WHERE  U.UF = @UF  
   AND DBO.Fx_replace_caracter_especial_nfe(DEFAULT, DESC_MUNICIPIO) = DBO.Fx_replace_caracter_especial_nfe(DEFAULT, @MUNENTREGA)  
  
   INSERT INTO @DADOSENTREGA(CNPJ_ENTREGA, CPF_ENTREGA, LOGRADOURO_ENTREGA,NRO_ENTREGA, COMPLEMENTO_ENTREGA, BAIRRO_ENTREGA, COD_MUN_ENTREGA, MUN_ENTREGA, UF, CEP, DDD, TELEFONE, CPF_CGC)  
         SELECT CASE WHEN @PF_PJ = 0 THEN  @CPF_CGC ELSE NULL END  ,   
                CASE WHEN @PF_PJ = 1 THEN  @CPF_CGC ELSE NULL END,  
                @ENDERECO,   
                @NROENTREGA,   
                @CPLENTREGA,  
                @BAIRROENTREGA,   
                @CODMUNENTREGA,   
                @MUNENTREGA,   
                @UF,   
                   -------------------  
                   -- INÍCIO - #01# --  
                   -------------------  
       @CEP,  
       ----------------  
                   -- FIM - #01# --  
                   ----------------  
                   -------------------  
       -- INÍCIO - #02# --  
       -------------------  
       @DDD,  
       @TELEFONE,  
       ----------------  
       -- FIM - #02# --  
       ----------------  
  
         -----------------  
          -- INICIO #03# --  
       -----------------   
       @CPF_CGC  
      --------------  
               -- FIM #03# --  
               --------------   
     RETURN  
     
     
     RETORNO_NULO: /*Ajuste temporário #04# */
      INSERT INTO @DADOSENTREGA(CNPJ_ENTREGA, CPF_ENTREGA, LOGRADOURO_ENTREGA,NRO_ENTREGA, COMPLEMENTO_ENTREGA, BAIRRO_ENTREGA, COD_MUN_ENTREGA, MUN_ENTREGA, UF, CEP, DDD, TELEFONE, CPF_CGC)  
       SELECT CASE WHEN @PF_PJ = 0 THEN  @CPF_CGC ELSE NULL END  ,   
                CASE WHEN @PF_PJ = 1 THEN  @CPF_CGC ELSE NULL END,  
                @ENDERECO,   
                @NROENTREGA,   
                @CPLENTREGA,  
                @BAIRROENTREGA,   
                @CODMUNENTREGA,   
                @MUNENTREGA,   
                @UF,   
                   -------------------  
                   -- INÍCIO - #01# --  
                   -------------------  
       @CEP,  
       ----------------  
                   -- FIM - #01# --  
                   ----------------  
                   -------------------  
       -- INÍCIO - #02# --  
       -------------------  
       @DDD,  
       @TELEFONE,  
       ----------------  
       -- FIM - #02# --  
       ----------------  
  
         -----------------  
          -- INICIO #03# --  
       -----------------   
       @CPF_CGC  
      --------------  
               -- FIM #03# --  
               --------------   
    RETURN
END
