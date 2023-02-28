
if exists (select 1 from sys.PROCEDURES where name = 'LX_CALL_CLIENTES_VAREJO_DOCUMENTO')
begin
  drop procedure [DBO].LX_CALL_CLIENTES_VAREJO_DOCUMENTO 
end  

