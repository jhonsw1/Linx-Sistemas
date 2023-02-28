IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME ='SP_FECHA_LOJA_HERING')
	BEGIN
		EXEC('
CREATE PROCEDURE [dbo].[SP_FECHA_LOJA_HERING] (@CODIGO_FILIAL VARCHAR(6), @DATALOJA datetime = null)      
      
AS      
SET NOCOUNT ON      
      
BEGIN

DECLARE @DATAATUAL as datetime, @STATUSLOJA varchar(20)

SELECT @DATAATUAL=max(DATA_VENDA) FROM LOJA_VENDA where codigo_filial = @CODIGO_FILIAL and (DATA_VENDA <= convert(date,getdate()-1) or DATA_VENDA = @DATALOJA)

DECLARE CUR_FECHA CURSOR LOCAL FOR 
SELECT DISTINCT A.CODIGO_FILIAL,A.DATA_VENDA
FROM LOJA_VENDA A (NOLOCK)
LEFT JOIN  LOJA_CAIXA_FECHADO_HERING B ON A.CODIGO_FILIAL =B.CODIGO_FILIAL AND DATA_VENDA = B.DATA_LOJA and a.CODIGO_FILIAL = @CODIGO_FILIAL
WHERE (DATA_VENDA  >= CONVERT(DATE,GETDATE()-31) and DATA_VENDA < CONVERT(DATE,GETDATE()) OR DATA_VENDA = @DATALOJA) AND b.CODIGO_FILIAL is null 

DECLARE  @CODFILIAL VARCHAR(6), @DATAVENDA DATETIME 
OPEN CUR_FECHA

FETCH NEXT FROM CUR_FECHA INTO @CODFILIAL,@DATAVENDA
WHILE @@FETCH_STATUS = 0
BEGIN

  	    INSERT INTO LOJA_CAIXA_FECHADO_HERING(FILIAL,CODIGO_FILIAL,CAIXA_FECHADO,DATA_LOJA,DATA_PARA_TRANSFERENCIA,ULTIMO_NFCE,ULTIMO_SAT,QTDE_TICKET,QTDE_SAT,QTDE_NFCE,QTDE_CCF,VALOR_BRUTO)
		SELECT B.FILIAL,B.COD_FILIAL,1,DATA,GETDATE(),A.ULTIMO_NFCE,A.ULTIMO_SAT,A.QTDE_TICKET,A.QTDE_SAT,A.QTDE_NFCE,A.QTDE_CCF,A.VALOR_BRUTO 
		FROM FX_HR_BUSCA_VALOR_FECHAMENTO_CAIXA (@CODFILIAL, @DATAVENDA) A JOIN FILIAIS B ON A.CODIGO_FILIAL = B.COD_FILIAL

FETCH NEXT FROM CUR_FECHA INTO @CODFILIAL,@DATAVENDA
END
CLOSE CUR_FECHA
DEALLOCATE CUR_FECHA

 ------
SET @STATUSLOJA =''CaixaAberto''

SELECT @STATUSLOJA = ''CaixaFechado'' FROM LOJA_CAIXA_FECHADO_HERING  WHERE DATA_LOJA = @DATAATUAL

SELECT @STATUSLOJA

END')
end