CREATE PROCEDURE [dbo].[CREATE_ORDER_ID_OMS](@CodigoFilialParam Varchar(6), @NumeroPedido Int, @SeqEntrega Tinyint)  
      As  
BEGIN  
   
Declare @DataAtual DateTime,  
            @DiaAtual int,  
            @MesAtual int,  
            @AnoAtual int,  
            @DiaC char(1),  
            @MesC char(1),  
            @AnoC char(1),                      
            @CodigoFilial varchar(6)  
   
Select @DataAtual = getdate(), @DiaAtual = DATEPART(dd, @DataAtual), @MesAtual = DATEPART(mm, @DataAtual), @AnoAtual = DATEPART(yy, @DataAtual)  
   
SELECT @DiaC = CASE @DiaAtual  
                  WHEN 1 THEN  '1'  
                  WHEN 2 THEN  '2'  
                  WHEN 3 THEN  '3'  
                  WHEN 4 THEN  '4'  
                  WHEN 5 THEN  '5'  
                  WHEN 6 THEN  '6'  
                  WHEN 7 THEN  '7'  
                  WHEN 8 THEN  '8'  
                  WHEN 9 THEN  '9'  
                  WHEN 10 THEN 'A'  
                  WHEN 11 THEN 'B'  
                  WHEN 12 THEN 'C'  
                  WHEN 13 THEN 'D'  
                  WHEN 14 THEN 'E'  
                  WHEN 15 THEN 'F'  
                  WHEN 16 THEN 'G'  
                  WHEN 17 THEN 'H'  
                  WHEN 18 THEN 'I'  
                  WHEN 19 THEN 'J'  
                  WHEN 20 THEN 'K'  
                  WHEN 21 THEN 'L'  
                  WHEN 22 THEN 'M'  
                  WHEN 23 THEN 'N'  
                  WHEN 24 THEN 'O'  
                  WHEN 25 THEN 'P'  
                  WHEN 26 THEN 'Q'  
                  WHEN 27 THEN 'R'  
                  WHEN 28 THEN 'S'  
                  WHEN 29 THEN 'T'  
                  WHEN 30 THEN 'U'  
                  WHEN 31 THEN 'V'  
            END  
   
SELECT @MesC = CASE @MesAtual  
                  WHEN 1      THEN  '1'  
                  WHEN 2      THEN  '2'  
                  WHEN 3      THEN  '3'  
                  WHEN 4      THEN  '4'  
                  WHEN 5      THEN  '5'  
                  WHEN 6      THEN  '6'  
                  WHEN 7      THEN  '7'  
                  WHEN 8      THEN  '8'  
                  WHEN 9      THEN  '9'  
                  WHEN 10 THEN 'A'  
                  WHEN 11 THEN 'B'  
                  WHEN 12 THEN 'C'  
            END  
   
SELECT @AnoC = CASE @AnoAtual  
                  WHEN 2017 THEN '0'  
                  WHEN 2018 THEN '1'  
                  WHEN 2019 THEN '2'  
                  WHEN 2020 THEN '3'  
                  WHEN 2021 THEN '4'  
                  WHEN 2022 THEN '5'  
                  WHEN 2023 THEN '6'  
                  WHEN 2024 THEN '7'  
                  WHEN 2025 THEN '8'  
                  WHEN 2026 THEN '9'  
                  WHEN 2027 THEN 'A'  
                  WHEN 2028 THEN 'B'  
                  WHEN 2029 THEN 'C'  
                  WHEN 2030 THEN 'D'  
                  WHEN 2031 THEN 'E'  
                  WHEN 2032 THEN 'F'  
                  WHEN 2033 THEN 'G'  
                  WHEN 2034 THEN 'H'  
                  WHEN 2035 THEN 'I'  
                  WHEN 2036 THEN 'J'  
                  WHEN 2037 THEN 'K'  
                  WHEN 2038 THEN 'L'  
                  WHEN 2039 THEN 'M'  
                  WHEN 2040 THEN 'N'  
                  WHEN 2041 THEN 'O'  
                  WHEN 2042 THEN 'P'  
                  WHEN 2043 THEN 'Q'  
                  WHEN 2044 THEN 'R'  
                  WHEN 2045 THEN 'S'  
                  WHEN 2046 THEN 'T'  
                  WHEN 2047 THEN 'U'  
                  WHEN 2048 THEN 'V'  
                  WHEN 2049 THEN 'W'  
                  WHEN 2050 THEN 'X'  
                  WHEN 2051 THEN 'Y'  
                  WHEN 2052 THEN 'Z'  
            END  
   
      Set @CodigoFilial = Case When DATALENGTH(LTRIM(RTRIM(@CodigoFilialParam))) < 6  
                                          Then LTRIM(RTRIM(@CodigoFilialParam)) + '.'  
                                          Else LTRIM(RTRIM(@CodigoFilialParam)) End  
   
--      RETURN(@CodigoFilial + @AnoC + @MesC + @DiaC + RIGHT('00' + CAST(@NumeroPedido AS VARCHAR), 3))     -- Linha corrigida  
   
-- Transforma @NumeroPedido e @SeqEntrega em um número de base 26 (todas das letras do alfabeto)  
DECLARE @BASE AS TINYINT, @NUMERO AS INT, @RESULTADO AS VARCHAR(100), @CHARINI AS CHAR  
DECLARE @PARTE1 AS INT, @PARTE2 AS INT  
   
SET @CHARINI = 'A'  
SET @BASE = 26  
SET @RESULTADO = ''  
   
SET @NUMERO = @NumeroPedido % 1000 -- (pega os três últimos dígitos)  
SET @NUMERO = @NUMERO * 10 + @SeqEntrega  
   
SET @PARTE1 = @NUMERO % @BASE  
SET @PARTE2 = @NUMERO / @BASE  
   
SET @RESULTADO = CHAR(ASCII(@CHARINI) + @PARTE1)  
   
WHILE @PARTE2 > 0  
BEGIN  
       SET @PARTE1 = @PARTE2 % @BASE  
       SET @PARTE2 = @PARTE2 / @BASE  
       SET @RESULTADO = CHAR(ASCII(@CHARINI) + @PARTE1) + @RESULTADO  
END  
    
SELECT @CodigoFilial + @AnoC + @MesC + @DiaC + RIGHT('AA' + @RESULTADO, 3)  
  
END  
   