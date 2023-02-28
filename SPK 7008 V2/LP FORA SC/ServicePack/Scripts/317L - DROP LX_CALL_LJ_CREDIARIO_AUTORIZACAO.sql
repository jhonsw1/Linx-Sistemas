if exists (select 1 from sys.PROCEDURES where name = 'LX_CALL_LJ_CREDIARIO_AUTORIZACAO')
begin
  drop procedure [DBO].LX_CALL_LJ_CREDIARIO_AUTORIZACAO 
end  

