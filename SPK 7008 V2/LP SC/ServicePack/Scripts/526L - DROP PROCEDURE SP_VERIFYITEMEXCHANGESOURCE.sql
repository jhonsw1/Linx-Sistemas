if exists (select 1 from sys.objects where name = 'SP_VERIFYITEMEXCHANGESOURCE')
begin
  drop procedure [DBO].SP_VERIFYITEMEXCHANGESOURCE 
end  