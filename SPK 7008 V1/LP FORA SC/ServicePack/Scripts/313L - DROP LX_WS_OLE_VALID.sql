if exists (select 1 from sys.PROCEDURES where name = 'LX_WS_OLE_VALID')
begin
  drop procedure [DBO].LX_WS_OLE_VALID 
end  
