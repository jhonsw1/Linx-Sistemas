IF EXISTS (SELECT 1
           FROM   sys.OBJECTS
           WHERE  NAME = 'W_IMPRESSAO_NFE_LOG')
  DROP VIEW [DBO].[W_IMPRESSAO_NFE_LOG] 