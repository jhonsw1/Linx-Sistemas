if exists (select 1 from sys.PROCEDURES where name = 'LX_WS_USP')
begin
  drop procedure [DBO].LX_WS_USP 
end  

