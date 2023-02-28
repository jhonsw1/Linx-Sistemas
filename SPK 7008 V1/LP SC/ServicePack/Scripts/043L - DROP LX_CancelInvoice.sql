IF EXISTS (SELECT 1
           FROM   sys.OBJECTS
           WHERE  NAME = 'LX_CancelInvoice')
  DROP PROCEDURE [DBO].[LX_CancelInvoice]