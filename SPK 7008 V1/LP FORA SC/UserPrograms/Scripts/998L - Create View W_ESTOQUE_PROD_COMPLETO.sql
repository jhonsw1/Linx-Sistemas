IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME ='W_ESTOQUE_PROD_COMPLETO')
 BEGIN
  EXEC('
CREATE VIEW [dbo].[W_ESTOQUE_PROD_COMPLETO] AS
SELECT A.FILIAL,
A.PRODUTO,
A.COR_PRODUTO,
D.TAMANHO as ORDEM_TAMANHO,
B.GRADE,
D.GRADE as TAMANHO,
d.CODIGO_BARRA,    
  ESTOQUE = CASE D.TAMANHO    
   WHEN 1 THEN ES1  WHEN 2 THEN ES2  WHEN 3 THEN ES3  WHEN 4 THEN ES4    
   WHEN 5 THEN ES5  WHEN 6 THEN ES6  WHEN 7 THEN ES7  WHEN 8 THEN ES8    
   WHEN 9 THEN ES9  WHEN 10 THEN ES10 WHEN 11 THEN ES11 WHEN 12 THEN ES12    
   WHEN 13 THEN ES13 WHEN 14 THEN ES14 WHEN 15 THEN ES15 WHEN 16 THEN ES16    
   WHEN 17 THEN ES17 WHEN 18 THEN ES18 WHEN 19 THEN ES19 WHEN 20 THEN ES20    
   WHEN 21 THEN ES21 WHEN 22 THEN ES22 WHEN 23 THEN ES23 WHEN 24 THEN ES24    
   WHEN 25 THEN ES25 WHEN 26 THEN ES26 WHEN 27 THEN ES27 WHEN 28 THEN ES28    
   WHEN 29 THEN ES29 WHEN 30 THEN ES30 WHEN 31 THEN ES31 WHEN 32 THEN ES32    
   WHEN 33 THEN ES33 WHEN 34 THEN ES34 WHEN 35 THEN ES35 WHEN 36 THEN ES36    
   WHEN 37 THEN ES37 WHEN 38 THEN ES38 WHEN 39 THEN ES39 WHEN 40 THEN ES40    
   WHEN 41 THEN ES41 WHEN 42 THEN ES42 WHEN 43 THEN ES43 WHEN 44 THEN ES44    
   WHEN 45 THEN ES45 WHEN 46 THEN ES46 WHEN 47 THEN ES47 WHEN 48 THEN ES48  ELSE 0 END    
 FROM  ESTOQUE_PRODUTOS A (nolock)   
INNER JOIN PRODUTOS B (nolock) ON B.PRODUTO=A.PRODUTO    
INNER JOIN PRODUTOS_BARRA D (nolock) ON D.PRODUTO = A.PRODUTO AND D.COR_PRODUTO = A.COR_PRODUTO  ')
END