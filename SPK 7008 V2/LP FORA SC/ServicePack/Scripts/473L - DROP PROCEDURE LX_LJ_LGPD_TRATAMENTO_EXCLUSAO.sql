-- POSSP-5737 - Roberto Beda - (23/06/2021) - Mudan�a na ordem de execu��o
-- POSSP-5698 - Gilvano Santos - (20/06/2021) - LGPD (elimina��o e anonimiza��o)
IF EXISTS (SELECT 1 FROM   sys.OBJECTS WHERE  NAME = 'LX_LJ_LGPD_TRATAMENTO_EXCLUSAO')
begin
  DROP PROCEDURE [DBO].[LX_LJ_LGPD_TRATAMENTO_EXCLUSAO] 
end  