if exists (select 1 from sys.objects where name = 'sp_BarcodeQuery')

begin
  drop procedure [DBO].[sp_BarcodeQuery] 
end  