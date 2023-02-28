if exists (select 1 from sys.PROCEDURES where name = 'LX_QUERY_ENTIDADES_CREDITO_CONSULTAS')
begin
  drop procedure [DBO].LX_QUERY_ENTIDADES_CREDITO_CONSULTAS 
end  

