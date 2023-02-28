CREATE PROCEDURE [DBO].[GSM_SURVEY_CODE] (@CODIGO AS NUMERIC(30, 6)) 
AS 
    DECLARE @SURVEY_CODE TABLE 
      ( 
         CODE      NUMERIC(30, 6), 
         RESTO     INT, 
         SIMBOLO   CHAR(1), 
         SEQUENCIA INT IDENTITY 
      ) 

    INSERT @SURVEY_CODE 
           (CODE) 
    VALUES (@CODIGO) 

  BEGIN 
      DECLARE @CODE NUMERIC(30, 6) 
      DECLARE @RESULT NUMERIC(30, 6) 

      WHILE (SELECT CAST(CODE / 32 AS NUMERIC(30, 6)) 
             FROM   @SURVEY_CODE 
             WHERE  RESTO IS NULL) >= 32 
        BEGIN 
            SELECT @CODE = CAST(CODE AS NUMERIC(30, 6)) 
            FROM   @SURVEY_CODE 
            WHERE  RESTO IS NULL 

            SELECT @RESULT = CAST(CODE / 32 AS NUMERIC(30, 6)) 
            FROM   @SURVEY_CODE 
            WHERE  RESTO IS NULL 

            UPDATE @SURVEY_CODE 
            SET    RESTO = CAST(( @CODE % 32 ) AS INT) 
            WHERE  CODE = @CODE 

            UPDATE A 
            SET    SIMBOLO = B.SYMBOL 
            FROM   @SURVEY_CODE A 
                   INNER JOIN SYMBOL32 B 
                           ON A.RESTO = B.DEPARA 
            WHERE  CAST(A.CODE AS NUMERIC(30, 6)) = @CODE 

            INSERT @SURVEY_CODE 
                   (CODE) 
            VALUES (@RESULT) 
        END 

      SELECT @CODE = CAST(CODE AS NUMERIC(30, 6)) 
      FROM   @SURVEY_CODE 
      WHERE  RESTO IS NULL 

      SELECT @RESULT = CAST(CODE / 32 AS NUMERIC(30, 6)) 
      FROM   @SURVEY_CODE 
      WHERE  RESTO IS NULL 

      UPDATE @SURVEY_CODE 
      SET    RESTO = CAST(( @CODE % 32 ) AS INT) 
      WHERE  CODE = @CODE 

      INSERT @SURVEY_CODE 
             (CODE, 
              RESTO) 
      VALUES (@RESULT, 
              @RESULT / 1 ) 

      UPDATE A 
      SET    SIMBOLO = B.SYMBOL 
      FROM   @SURVEY_CODE A 
             INNER JOIN SYMBOL32 B 
                     ON A.RESTO = B.DEPARA 
      WHERE  A.SIMBOLO IS NULL 

      SELECT * 
      FROM   @SURVEY_CODE 

      RETURN 
  END 