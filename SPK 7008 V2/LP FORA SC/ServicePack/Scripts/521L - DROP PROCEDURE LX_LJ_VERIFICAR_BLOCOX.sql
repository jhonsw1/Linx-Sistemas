if exists (select 1 from sys.objects where name = 'LX_LJ_VERIFICAR_BLOCOX')

begin
  drop procedure [DBO].[LX_LJ_VERIFICAR_BLOCOX] 
end  