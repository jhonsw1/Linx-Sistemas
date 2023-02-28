if exists (select 1 from sys.objects where name = 'lx_BarcodeQueryExchange')

begin
  drop procedure [DBO].[lx_BarcodeQueryExchange] 
end  