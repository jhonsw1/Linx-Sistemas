Create PROCEDURE LX_CancelInvoice (@StoreCode char(6), @FiscalNumber char(15), @FiscalSeries char(6), @CancelDate datetime)  
AS  
-- 28/01/2020 - Wendel Crespigio - issue - MODASP-10350 - #5# - Passou a validar o status_nfe antes de dar update caso não esteja com status 49 \ 59\70 nao será zerado os itens.
-- 23/07/2018 - Wendel Crespigio - ID - 85548 #4# - tratamento para cancelamento de nota fiscal com serie para nao cancelar a mesma nota com serie diferente.   
-- 10/08/2017 - Fillipi Ramos    - ID 27509 - #3# - Tratamento para excluir nota na tabela LOJA_VENDA_PGTO quando a mesma for inutilizada.  
-- 10/03/2016 - Wendel Crespigio - ID 1350 - #2# - Correção problema ao cancelar uma nota fiscal de apuração de IPI.  
-- 29/01/2016 - Edson Filenti    - id 840 - Inclusão do campo VALOR_RATEIO_FRETE no processo de cancelamento do item.  
  
BEGIN  
SET NOCOUNT ON  
  
BEGIN TRANSACTION  

 UPDATE  
  LOJA_NOTA_FISCAL SET QTDE_CANCELADA = QTDE_TOTAL, QTDE_TOTAL = 0, VALOR_CANCELADO = VALOR_TOTAL, VALOR_TOTAL = 0,  
 VALOR_TOTAL_ITENS = 0, DESCONTO = 0, ENCARGO = 0, FRETE = 0, SEGURO = 0,  
 DATA_CANCELAMENTO = @CancelDate, NOTA_CANCELADA = 1, VALOR_IMPOSTO_AGREGAR = 0  
 WHERE CODIGO_FILIAL = @StoreCode AND NF_NUMERO = @FiscalNumber AND SERIE_NF = @FiscalSeries  
 and STATUS_NFE in ('49','59','70') and LOG_STATUS_NFE =0 -- #5#

  UPDATE A SET A.QTDE_ITEM = 0, A.VALOR_ITEM = 0, A.PRECO_UNITARIO = 0, A.PORCENTAGEM_ITEM_RATEIO = 0,   
  A.DESCONTO_ITEM = 0, A.VALOR_ENCARGOS = 0, A.VALOR_DESCONTOS = 0,  A.VALOR_RATEIO_FRETE = 0  
  FROM LOJA_NOTA_FISCAL_ITEM A ,LOJA_NOTA_FISCAL B
  WHERE A.CODIGO_FILIAL = @StoreCode AND A.NF_NUMERO = @FiscalNumber AND A.SERIE_NF = @FiscalSeries
  AND B.STATUS_NFE in ('49','59','70') AND B.LOG_STATUS_NFE =0 --#5#
  
 UPDATE  A SET TAXA_IMPOSTO = 0, VALOR_IMPOSTO = 0, BASE_IMPOSTO = 0  
  from LOJA_NOTA_FISCAL_IMPOSTO A ,LOJA_NOTA_FISCAL B
  WHERE A.CODIGO_FILIAL = @StoreCode AND A.NF_NUMERO = @FiscalNumber AND A.SERIE_NF = @FiscalSeries  
  AND B.STATUS_NFE in ('49','59','70') AND B.LOG_STATUS_NFE =0 --#5#
    
  UPDATE LOJA_VENDA_PGTO SET NUMERO_FISCAL_IPI = NULL , SERIE_NF_IPI = NULL --#2#  
  WHERE NUMERO_FISCAL_IPI = @FISCALNUMBER AND SERIE_NF_IPI = @FISCALSERIES and CODIGO_FILIAL = @StoreCode --#2#  
   
 --#3#  
 UPDATE LOJA_VENDA_PGTO SET NUMERO_FISCAL_TROCA = NULL, SERIE_NF_ENTRADA = NULL --#4#    
  WHERE  NUMERO_FISCAL_TROCA = @FISCALNUMBER  
  and SERIE_NF_ENTRADA = @FISCALSERIES --#4#  
  
 COMMIT TRAN  
  
 SET NOCOUNT OFF  
END  