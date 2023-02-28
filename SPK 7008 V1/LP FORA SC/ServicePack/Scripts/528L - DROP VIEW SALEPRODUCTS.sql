
-- 06/05/2022 - FERNANDO MARINHO - PRODSHOP-12405 
IF EXISTS (SELECT 1
           FROM   sys.OBJECTS
           WHERE  NAME = 'SaleProducts'
		   )
 
 DROP VIEW [DBO].[SaleProducts] 