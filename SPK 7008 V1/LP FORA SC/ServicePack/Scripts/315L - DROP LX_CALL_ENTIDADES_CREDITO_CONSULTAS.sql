if exists (select 1 from sys.PROCEDURES where name = 'LX_CALL_ENTIDADES_CREDITO_CONSULTAS')
begin
  drop procedure [DBO].LX_CALL_ENTIDADES_CREDITO_CONSULTAS 
end  
