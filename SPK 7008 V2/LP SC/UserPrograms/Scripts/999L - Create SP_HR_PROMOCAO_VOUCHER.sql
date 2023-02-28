
if not exists ( select 1 from sys.objects where name ='SP_HR_PROMOCAO_VOUCHER')
BEGIN
EXEC
  ('CREATE PROCEDURE [dbo].[SP_HR_PROMOCAO_VOUCHER] @CODIGO_FILIAL VARCHAR(6) = NULL, @DATA DATETIME, @TICKET CHAR(8), @PEDIDO INT ,  @CPF_CLIENTE   VARCHAR(20) = NULL,    @FORMA_ENTREGA VARCHAR(50) = '''' ,  @CUPOM varchar(20) = NULL
  AS  
  BEGIN  
   -- Daniel Martins - 20200629 - Alterada Chamada do SP_HR_PROMOCAO para que passe o parametro de cupom
   EXEC SP_HR_PROMOCAO @CODIGO_FILIAL, @TICKET, @DATA , @PEDIDO,  @CPF_CLIENTE, @FORMA_ENTREGA, @CUPOM
   
  END') 
  END