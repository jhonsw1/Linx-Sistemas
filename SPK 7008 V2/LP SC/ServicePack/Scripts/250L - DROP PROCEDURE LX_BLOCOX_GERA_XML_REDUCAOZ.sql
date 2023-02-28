if exists (select 1 from sys.objects where name = 'LX_BLOCOX_GERA_XML_REDUCAOZ')

begin
  drop procedure [DBO].[LX_BLOCOX_GERA_XML_REDUCAOZ] 
end  