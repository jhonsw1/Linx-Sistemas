IF EXISTS (SELECT 1
           FROM   sys.OBJECTS
           WHERE  NAME = 'Sp_verifyexchangesource')
  DROP PROCEDURE [DBO].[Sp_verifyexchangesource] 
