IF EXISTS (SELECT 1
           FROM   sys.OBJECTS
           WHERE  NAME = 'LX_LJ_INFO_PRODUTO')
  DROP PROCEDURE [DBO].[LX_LJ_INFO_PRODUTO] 