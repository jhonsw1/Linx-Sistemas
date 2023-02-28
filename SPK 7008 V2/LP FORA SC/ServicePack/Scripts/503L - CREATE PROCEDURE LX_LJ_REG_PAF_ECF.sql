CREATE PROCEDURE [dbo].[LX_LJ_REG_PAF_ECF] 
	  (@FILIAL            VARCHAR(25), 
	   @CODIGO_FILIAL     VARCHAR(06), 
	   @CODIGO_TAB_PRECO  VARCHAR(2), 
	   @DT_INICIAL        DATETIME, 
	   @DT_FINAL          DATETIME, 
	   @BUILD_BUFFER      VARCHAR(250), 
	   @TERMINAL          VARCHAR(03), 
	   @MOSTRA_TICKET     INT, 
	   @LOCALSAIDA_ICMS   NUMERIC(12, 2), 
	   @LOCALUF           VARCHAR(02), 
	   @ECF_PrinterID     VARCHAR(03), 
	   @PrinterName       VARCHAR(20), 
	   @ModeloECF         VARCHAR(20), 
	   @SerialNumber      VARCHAR(20), 
	   @Version_APP       VARCHAR(10), 
	   @ProductFilter     VARCHAR(800), 
	   @Verifica_Reducao  CHAR(1)) 
AS 
--12/12/2021 - Gilvano Santos #POSSP-6879# - Alteração de tamanho do parametro @ProductFilter de 500 para 800 caracteres
--16/04/2019 - Diego Moreno - #15# - Alteração prevista para o PAF ECF 2019 - COrreção dos registros J1 e J2.
--27/05/2017 - Roberto Beda - #14# - Correção para considerar alteração na tabela PRODUTOS por linha e não para o cadastro todo.
--27/05/2017 - Diego Moreno - #13# - Correção na compatibilidade da collation das tabelas temporárias e a collation das tabelas físicas (COLLATE DATABASE_DEFAULT).
--24/04/2017 - Diego Moreno - TIPO_EMISSAO_NFE = 9 AND STATUS_NFE = 1 and LOG_STATUS_NFE = 0 - DM 29149\29153\29464 - Melhoria para que ao gerar os registros J1 e J2 notas provenientes de saidas de mercadorias constem no arquivo.
														 -- Melhoria para notas de NFCE sem cliente estejam no arquivo.
														 -- Melhoria para que NFCE emitidas em contingência OFF-LINE (TIPO_EMISSAO_NFE = 9 AND STATUS_NFE = 1 and LOG_STATUS_NFE = 0) estejam no arquivo.
--27/03/2017 - Giedson Silva - DM8577(Tarefa: 6239) - Bloco X - #11# - Alteração para exibir o código de barra na geração dos registros PAF para atender a geração do XML de Estoque para o Bloco X. 
--			 - CODIGO_PRODUTO = CODIGO_BARRA na tabela LJ_ESTOQUE_PAF_ECF
--10/03/2017 - Vívian Domingues  - #10#- DM 6442 - TAREFA 4941 - Geração dos registros F e J2.
--22/12/2016 - Eder Silva	     - #9# - DM 15767 - Tratamento no nome levado para o campo MARCA.  
--25/11/2016 - Wendel Crespigio  - #8# - DM12505 - Melhoria para cliente do Maranhão MA \ PI\ ES.
--08/09/2016 - Eder Silva        - #7# - DM8438 - Melhorar performance na geração do arquivo. Sugestão do Crispim separar os updates da tabela #PRODUTOSP2 que gera o Registro 'P2'.
--05/08/2016 - Gerson Prado      - #6# - DM4216 - Inserir Collate na criação das tabelas temporárias.
--06/06/2016 - Wendel Crespigio sem demanda Caracteres especiais no script 
--02/06/2016 - Eder Silva        - #5# - Inclusão do código CEST na descrição dos produtos nos registros D3 e D4
--24/02/2016 - Giedson Silva     - #4# - Melhoria na performance da Query - Verificação da Tabela de Preços - Registro P2.
--14/08/2015 - Diego Moreno	     - #3# - Correção na verificação de linhas da CLASSIF_FISCAL_IMPOSTO
--14/08/2015 - Roberto Beda      - #2# - Inscrição estadual e inscrição municipal são campos alfanuméricos e devem ser formatados com brancos à direita.
--14/08/2015 - Roberto Beda      - #1# - Correção da indicação de modificação no banco (estava acrescentando '?', quando deveria substituir espaços por '?').
--26/06/2015 Wendel Crespigio    - Criação da Procedure com as novas tabelas necessarias para o PAF ECF 2015.

  BEGIN 
      DECLARE @MFAdicional      CHAR(01), 
              @TipoECF          CHAR(07), 
              @TituloDAV        CHAR(30), 
              @strDTInicial365  VARCHAR(10), 
              @strDT_INICIAL    VARCHAR(10), 
              @strDT_FINAL      VARCHAR(10), 
              @CGC_CPF          VARCHAR(14), 
              @RAZAO_SOCIAL     VARCHAR(90), 
              @RG_IE            VARCHAR(19), 
              @IM               VARCHAR(15), 
              @UF               CHAR(2), 
              @CNPJ_Arredondar  char(14), 
              @RazaoArredondar  char(150),
		      @HASH_TAB_PRODUTO CHAR(1),
		      @HASH_TAB_CLASSIF_FISCAL_IMPOSTO   CHAR(1), 
		      @HASH_TAB_PRODUTOS_PRECO_COR       CHAR(1), 
		      @HASH_TAB_PRODUTOS_PRECOS          CHAR(1),
		      @HASH_TAB_PRODUTO_CORES            CHAR(1), 
			  @HASH_TAB_PRODUTO_BARRA            CHAR(1),
			  @COUNT                             INT, --#10#
			  @COUNT_LINE                        INT  --#10#

      if ( Isnull(@DT_INICIAL, '') = '' 
            or Isnull(@DT_FINAL, '') = '' ) 
        Begin 
            set @DT_INICIAL = '20150101' 
            set @DT_FINAL   = '20171231' 
        end 

      Select @strDTInicial365 = Convert(varchar(10), Dateadd(YEAR, -1, @DT_INICIAL), 112) 
      Select @strDT_INICIAL = Convert(varchar(10), @DT_INICIAL, 112) 
      Select @strDT_FINAL = Convert(varchar(10), @DT_FINAL, 112); 

      Select @CNPJ_Arredondar = VALOR_ATUAL 
      from   PARAMETROS 
      where  PARAMETRO = 'CNPJ_ARREDONDAR' 

      Select @RazaoArredondar = VALOR_ATUAL 
      from   PARAMETROS 
      where  PARAMETRO = 'RS_ARREDONDAR' 

      SET @MFAdicional = ' ' 
      SET @TipoECF = 'ECF-IF ' 
      SET @TituloDAV = 'ORCAMENTO' 

      if isnull(@Verifica_Reducao, '') = '' 
        begin             
          --set @Verifica_Reducao = 0   --#7#
			set @Verifica_Reducao = '0' --#7#
        end 

      DELETE FROM LJ_REG_PAF_ECF_TEMP 
      WHERE  TERMINAL = @TERMINAL 

      IF Object_id('TEMPDB..#LJ_REG_PAF_ECF_PRODUTO') IS NOT NULL 
        BEGIN 
            DROP TABLE #LJ_REG_PAF_ECF_PRODUTO 
        END 

      CREATE TABLE #LJ_REG_PAF_ECF_PRODUTO 
        ( 
           PRODUTO              VARCHAR(12) COLLATE DATABASE_DEFAULT NOT NULL  PRIMARY KEY(PRODUTO), 
           DESC_PRODUTO         VARCHAR(40) COLLATE DATABASE_DEFAULT, 
           DESC_PROD_NF         VARCHAR(40) COLLATE DATABASE_DEFAULT, 
           GRADE                VARCHAR(25) COLLATE DATABASE_DEFAULT, 
           LX_HASH              VARBINARY(16), 
           UNIDADE              CHAR(5)     COLLATE DATABASE_DEFAULT, 
           CLASSIF_FISCAL       CHAR(10)    COLLATE DATABASE_DEFAULT, 
           VARIA_PRECO_COR      BIT, 
           VARIA_PRECO_TAM      BIT, 
           ARREDONDA            BIT, 
           INDICADOR_CFOP       TINYINT, 
           PONTEIRO_PRECO_TAM   CHAR(48) COLLATE DATABASE_DEFAULT 
        ) 

      EXECUTE ( 'INSERT INTO #LJ_REG_PAF_ECF_PRODUTO (PRODUTO,DESC_PRODUTO, DESC_PROD_NF, GRADE, LX_HASH,UNIDADE,
	             CLASSIF_FISCAL, VARIA_PRECO_COR,VARIA_PRECO_TAM,ARREDONDA, INDICADOR_CFOP,PONTEIRO_PRECO_TAM) SELECT PRODUTO,        DESC_PRODUTO,        DESC_PROD_NF,        GRADE,        LX_HASH,        UNIDADE,        CLASSIF_FISCAL,        VARIA_PRECO_COR,        VARIA_PRECO_TAM,        ARREDONDA,        INDICADOR_CFOP,        PONTEIRO_PRECO_TAM FROM   dbo.PRODUTOS A WHERE  A.INATIVO = 0' ); 

      IF Object_id('TEMPDB..#LJ_ESTOQUE_PAF_ECF') IS NOT NULL 
        BEGIN 
            DROP TABLE #LJ_ESTOQUE_PAF_ECF 
        END 

      CREATE TABLE #LJ_ESTOQUE_PAF_ECF 
        ( 
           CODIGO_FILIAL        char(6)      COLLATE DATABASE_DEFAULT , 
           CODIGO_PRODUTO       varchar (25) COLLATE DATABASE_DEFAULT ,--#11#
           CNPJ_ESTABELECIMENTO varchar (14) COLLATE DATABASE_DEFAULT , 
           DESCRICAO_PRODUTO    varchar (50) COLLATE DATABASE_DEFAULT , 
           DESCRICAO_UNIDADE    varchar (6)  COLLATE DATABASE_DEFAULT , 
           SALDO_ESTOQUE        int, 
           LX_HASH              varbinary (16),
		   DATA_PAF_ECF		    DATE
        ) 

      EXECUTE ( 'INSERT INTO #LJ_ESTOQUE_PAF_ECF(CODIGO_FILIAL,CODIGO_PRODUTO,CNPJ_ESTABELECIMENTO,DESCRICAO_PRODUTO,DESCRICAO_UNIDADE ,SALDO_ESTOQUE ,LX_HASH, DATA_PAF_ECF)    SELECT CODIGO_FILIAL,CODIGO_PRODUTO,CNPJ_ESTABELECIMENTO,DESCRICAO_PRODUTO,DESCRICAO_UNIDADE ,SALDO_ESTOQUE ,LX_HASH, DATA_PAF_ECF     FROM LJ_ESTOQUE_PAF_ECF A WHERE LEN(CODIGO_PRODUTO) > 0 ' + @ProductFilter ) 

      CREATE TABLE #LJ_PRODUTO_BARRA 
        ( 
           PRODUTO      VARCHAR(12) COLLATE DATABASE_DEFAULT NOT NULL, 
           COR_PRODUTO  VARCHAR(10) COLLATE DATABASE_DEFAULT, 
           TAMANHO      TINYINT, 
           GRADE        VARCHAR(08) COLLATE DATABASE_DEFAULT, 
           CODIGO_BARRA VARCHAR(25) COLLATE DATABASE_DEFAULT, 
           TIPO_COD_BAR tinyint, 
           LX_HASH      VARBINARY(16) 
        ); 

      IF @MOSTRA_TICKET = 1 
        INSERT INTO #LJ_PRODUTO_BARRA 
                    (PRODUTO, 
                     COR_PRODUTO, 
                     TAMANHO, 
                     GRADE, 
                     CODIGO_BARRA, 
                     TIPO_COD_BAR, 
                     LX_HASH) 
        SELECT A.PRODUTO, 
               A.COR_PRODUTO, 
               A.TAMANHO, 
               B.GRADE, 
               B.CODIGO_BARRA, 
               A.TIPO_COD_BAR, 
               A.LX_HASH 
        FROM   dbo.PRODUTOS_BARRA A 
               INNER JOIN (SELECT A.PRODUTO, 
                                  A.COR_PRODUTO, 
                                  A.TAMANHO, 
                                  Max(A.GRADE)        AS GRADE, 
                                  Max(A.CODIGO_BARRA) AS CODIGO_BARRA 
                           FROM   dbo.PRODUTOS_BARRA A 
                                  INNER JOIN #LJ_REG_PAF_ECF_PRODUTO B 
                                          ON A.PRODUTO = B.PRODUTO 
                           WHERE  A.INATIVO = 0 
                           GROUP  BY A.PRODUTO, 
                                     A.COR_PRODUTO, 
                                     A.TAMANHO) AS B 
                       ON A.PRODUTO = B.PRODUTO 
                          AND A.COR_PRODUTO = B.COR_PRODUTO 
                          AND A.TAMANHO = B.TAMANHO 
                          AND A.CODIGO_BARRA = B.CODIGO_BARRA 
      ELSE 
        INSERT INTO #LJ_PRODUTO_BARRA 
                    (PRODUTO, 
                     COR_PRODUTO, 
                     TAMANHO, 
                     GRADE, 
                     CODIGO_BARRA, 
                     LX_HASH) 
        SELECT A.PRODUTO, 
               A.COR_PRODUTO, 
               A.TAMANHO, 
               B.GRADE, 
               B.CODIGO_BARRA, 
               A.LX_HASH 
        FROM   dbo.PRODUTOS_BARRA A 
               INNER JOIN (SELECT A.PRODUTO, 
                                  A.COR_PRODUTO, 
                                  A.TAMANHO, 
                                  Max(A.GRADE)        AS GRADE, 
                                  Max(A.CODIGO_BARRA) AS CODIGO_BARRA 
                           FROM   dbo.PRODUTOS_BARRA A 
                                  INNER JOIN #LJ_REG_PAF_ECF_PRODUTO B 
                                          ON A.PRODUTO = B.PRODUTO 
                           WHERE  A.TIPO_COD_BAR != 1 
                                  AND A.INATIVO = 0 
                           GROUP  BY A.PRODUTO, 
                                     A.COR_PRODUTO, 
                                     A.TAMANHO) AS B 
                       ON A.PRODUTO = B.PRODUTO 
                          AND A.COR_PRODUTO = B.COR_PRODUTO 
                          AND A.TAMANHO = B.TAMANHO 
                          AND A.CODIGO_BARRA = B.CODIGO_BARRA; 

      SELECT @CGC_CPF = RIGHT(Replicate('0', 14) 
                              + Rtrim(Replace(Replace(Replace(( CGC_CPF ), '.', ''), '-', ''), '/', '')), 14), 
             @RAZAO_SOCIAL = Rtrim(Ltrim(RAZAO_SOCIAL)), 
             @RG_IE = Rtrim(Ltrim(RG_IE)), 
             @IM = Rtrim(Ltrim(IM)), 
             @UF = Rtrim(Ltrim(UF)) 
      FROM   CADASTRO_CLI_FOR 
      WHERE  NOME_CLIFOR = @FILIAL; 

---REGISTRO A2 ---------------------------------------------------------------------------------------------------------------------------------------------------   
  Print 'A2' 
      Begin 
          INSERT INTO LJ_REG_PAF_ECF_TEMP 
                      (TIPO, 
                       REGISTRO, 
                       LIMITE, 
                       TERMINAL) 
          SELECT TIPO, 
                 'A2' + DATA + REPLACE(PAGAMENTO, ' ', HASHS) + TIPODOC		--	#1#
                 + RIGHT(Replicate('0', 12) + Replace(Cast(Sum(A.VALOR) AS VARCHAR), '.', ''), 12) AS REGISTRO, 
                 LIMITE, 
                 TERMINAL 
          from   (SELECT 2                                                         AS TIPO, 
                         LEFT(Ltrim(Rtrim(upper(A.MEIO_PAGAMENTO))) + Replicate(' ', 25), 25)                            AS PAGAMENTO, 
                         Replace(CONVERT(CHAR(8), A.DATA_MOVIMENTO, 112), '/', '') AS DATA, 
                         '3'                                                       AS TIPODOC, 
                         CASE 
                           WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.CODIGO_FILIAL + A.NF_NUMERO 
                                                             + A.SERIE_NF + Cast(A.SEQUENCIAL AS VARCHAR) 
                                                             + A.DENOMINACAO_DOCUMENTO 
                                                             + CONVERT(VARCHAR, A.DATA_MOVIMENTO, 112) 
                                                             + A.MEIO_PAGAMENTO + Cast(VALOR AS VARCHAR) 
                                                             + Cast(A.NOTA_CANCELADA AS VARCHAR) 
                                                             + Cast(A.NF_VENDA_CF AS VARCHAR)) THEN ' ' ELSE '?' END  AS HASHS, 
                         A.VALOR, 
                         48            AS LIMITE, 
                         @TERMINAL     AS TERMINAL 
                  From   dbo.LOJA_NOTA_FISCAL_PAGAMENTO A 
                         inner join LOJA_NOTA_FISCAL B
						 on A.NF_NUMERO = b.NF_NUMERO
						 and A.SERIE_NF = b.SERIE_NF 
						 and A.CODIGO_FILIAL = B.CODIGO_FILIAL
						 INNER JOIN SERIES_NF C
						 ON B.SERIE_NF = C.SERIE_NF
    					 INNER JOIN CTB_ESPECIE_SERIE D
						  ON C.ESPECIE_SERIE = D.ESPECIE_SERIE 
                  WHERE  A.NOTA_CANCELADA = 0 
                         AND NF_VENDA_CF = 0 
                         AND A.CODIGO_FILIAL = @CODIGO_FILIAL 
						 AND CONVERT(Varchar,( DATA_MOVIMENTO ), 112) Between @strDT_INICIAL And @strDT_FINAL 
						 AND ISNULL(A.MEIO_PAGAMENTO,'') <> ''
						 AND (D.NUMERO_MODELO_FISCAL IN ('2','02','2D') OR (D.NUMERO_MODELO_FISCAL IN ('55','65') AND B.STATUS_NFE =5))
						 GROUP  BY A.DATA_MOVIMENTO, A.MEIO_PAGAMENTO, A.VALOR, A.LX_HASH, A.CODIGO_FILIAL,  A.NF_NUMERO, A.SERIE_NF, 
                         A.SEQUENCIAL, A.DENOMINACAO_DOCUMENTO, A.NOTA_CANCELADA, A.NF_VENDA_CF 
                 UNION ALL 
                  SELECT 2                                     AS TIPO, 
                         CASE 
                           WHEN PAGAMENTO = '' THEN '                         ' 
                           ELSE LEFT(Ltrim(Rtrim(upper(PAGAMENTO))) + Replicate(' ', 25), 25) 
                         END                                   AS PAGAMENTO,-- Wendel Crespigio Verificado juntamente com Rodrigo da Polimig homologação do PAF 2015        
                         CONVERT(VARCHAR(8), DATA_FISCAL, 112) AS DATA, 
                         CASE 
                           WHEN DENOMINACAO_DOCUMENTO = 'CF' THEN '1' 
                           ELSE '2' 
                         END                                   AS TIPODOC, 
                         CASE 
                           WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + SERIE_ECF + A.MF_ADICIONAL 
                                                             + Cast(USUARIO_ECF AS VARCHAR) + A.COO 
                                                             + PARCELA + MODELO_ECF + A.CCF + A.GNF + PAGAMENTO 
                                                             + Cast(VALOR_PAGO AS VARCHAR) + ESTORNO_PGTO 
                                                             + Cast(VALOR_ESTORNADO AS VARCHAR)) 
                                AND B.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + B.CODIGO_FILIAL 
                                                                 + Cast(B.ID_DOCUMENTO_ECF AS VARCHAR) 
                                                                 + ID_EQUIPAMENTO + B.MF_ADICIONAL 
                                                                 + ISNULL(MODELO, '') 
                                                                 + Cast(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR) 
                                                                 + Cast(ISNULL(B.CCF, 0) AS VARCHAR) 
                                                                 + Cast(ISNULL(B.COO, 0) AS VARCHAR) 
                                                                 + CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126) 
                                                                 + Cast(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR) 
                                                                 + Cast(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR) 
                                                                 + ISNULL(TIPO_DESCONTO_SUBTOTAL, '') 
                                                                 + Cast(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR) 
                                                                 + Cast(CANCELADO AS VARCHAR) 
                                                                 + Cast(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR) 
                                                                 + ISNULL(ORDEM_DESC_ACRESC, '') 
                                                                 + ISNULL(NOME_CLIENTE, '') 
                                                                 + ISNULL(CPF_CNPJ_CLIENTE, '') 
                                                                 + Cast(ISNULL(B.GNF, 0) AS VARCHAR) 
                                                                 + Cast(ISNULL(GRG, 0) AS VARCHAR) 
                                                                 + Cast(ISNULL(CDC, 0) AS VARCHAR) 
                                                                 + DENOMINACAO_DOCUMENTO 
                                                                 + CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126) 
                                                                 + ISNULL(CNPJ_CREDENCIADORA, '') + TIPO_ECF 
                                                                 + ISNULL(MARCA, '') 
                                                                 + Cast(ISNULL(VALOR_TROCO_TEF, '0') AS VARCHAR) 
                                                                 + ISNULL(TITULO, '') 
                                                                 + ISNULL(CNPJ_ARREDONDAR, ''))THEN ' '  ELSE '?'  END AS HASHS,	--	#1#
                         VALOR_PAGO                            AS VALOR, 
                         48                                    AS LIMITE, 
                         @TERMINAL                             AS TERMINAL 
                  FROM   dbo.LJ_ECF_PAGAMENTO A 
                         INNER JOIN LJ_DOCUMENTO_ECF B 
                                 ON A.CODIGO_FILIAL = B.CODIGO_FILIAL 
                                    AND A.ID_DOCUMENTO_ECF = B.ID_DOCUMENTO_ECF 
									  
                  WHERE  CONVERT(Varchar,( DATA_FISCAL ), 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL 
                         AND CANCELADO = 0 
                         AND A.CODIGO_FILIAL = @CODIGO_FILIAL
						 AND ISNULL(PAGAMENTO,'') <> ''
                  GROUP  BY DATA_FISCAL, PAGAMENTO, DENOMINACAO_DOCUMENTO, VALOR_PAGO, SERIE_ECF, A.MF_ADICIONAL, Cast(USUARIO_ECF AS VARCHAR), 
                            A.COO, PARCELA, MODELO_ECF, A.CCF, A.GNF, PAGAMENTO, Cast(VALOR_PAGO AS VARCHAR), ESTORNO_PGTO, Cast(VALOR_ESTORNADO AS VARCHAR), 
                            B.CODIGO_FILIAL, Cast(B.ID_DOCUMENTO_ECF AS VARCHAR), ID_EQUIPAMENTO, B.MF_ADICIONAL + ISNULL(MODELO, ''), Cast(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR), 
                            Cast(ISNULL(B.CCF, 0) AS VARCHAR), Cast(ISNULL(B.COO, '0') AS VARCHAR), CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126), 
                            Cast(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR), Cast(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR), 
                            ISNULL(TIPO_DESCONTO_SUBTOTAL, ''), Cast(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR), Cast(CANCELADO AS VARCHAR), 
                            Cast(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR), ISNULL(ORDEM_DESC_ACRESC, ''), 
                            ISNULL(NOME_CLIENTE, ''), ISNULL(CPF_CNPJ_CLIENTE, ''),  Cast(ISNULL(B.GNF, 0) AS VARCHAR), 
                            Cast(ISNULL(GRG, 0) AS VARCHAR),  Cast(ISNULL(CDC, 0) AS VARCHAR), DENOMINACAO_DOCUMENTO, 
                            CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126), ISNULL(CNPJ_CREDENCIADORA, ''), 
                            TIPO_ECF, ISNULL(MARCA, ''), Cast(ISNULL(VALOR_TROCO_TEF, '0') AS VARCHAR), ISNULL(TITULO, ''), ISNULL(CNPJ_ARREDONDAR, ''), 
                            A.LX_HASH, B.LX_HASH, B.MF_ADICIONAL, B.MODELO, 
                            B.COO) A 
          GROUP  BY TIPO, LIMITE, TERMINAL, TIPODOC, DATA, PAGAMENTO, HASHS 
     end 
 
--P2------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Print 'P2' 
-- REGISTRO P2 - Mercadorias e Serviços 
--IF @Verifica_Reducao = 0   --#7#
  IF @Verifica_Reducao = '0' --#7#

  BEGIN 

		IF Object_id('TEMPDB..#PRODUTOSP2') IS NOT NULL 
        BEGIN 
            DROP TABLE #PRODUTOSP2 
        END 

		CREATE TABLE #PRODUTOSP2 (  PRODUTO	       VARCHAR (12) COLLATE DATABASE_DEFAULT ,
								COR_PRODUTO	       VARCHAR (10) COLLATE DATABASE_DEFAULT,
								GRADE	           VARCHAR (8)  COLLATE DATABASE_DEFAULT,
								CODIGO_PRODUTO     VARCHAR (25) COLLATE DATABASE_DEFAULT,
								TAMANHO	           INT	       ,
								TIPO_COD_BAR	   TINYINT     ,	
								CODIGO_BARRA	   VARCHAR (25) COLLATE DATABASE_DEFAULT,
								DESC_PROD          VARCHAR (50) COLLATE DATABASE_DEFAULT, 
								UNIDADE            VARCHAR (6)  COLLATE DATABASE_DEFAULT,
								INDICADOR_CFOP     VARCHAR (11) COLLATE DATABASE_DEFAULT,
								CLASSIF_FISCAL     VARCHAR (10) COLLATE DATABASE_DEFAULT, 
								ALIQUOTA           VARCHAR (8)  COLLATE DATABASE_DEFAULT,
							  --PRECO_UNIT         NUMERIC (14,2),
								PRECO1             NUMERIC (14,2),
								PRECO2             NUMERIC (14,2),
								PRECO3             NUMERIC (14,2),
								PRECO4             NUMERIC (14,2),
								PONTEIRO_PRECO_TAM VARCHAR(48) COLLATE DATABASE_DEFAULT, 
								ATUALIZADO BIT NOT NULL DEFAULT 0,
								HASH_TAB_PRODUTO CHAR(1),
								HASH_TAB_CLASSIF_FISCAL_IMPOSTO CHAR(1),
								HASH_TAB_PRODUTOS_PRECO_COR CHAR(1),
								HASH_TAB_PRODUTOS_PRECO CHAR(1),
								HASH_TAB_PRODUTO_CORES CHAR(1),
								HASH_TAB_PRODUTO_BARRA CHAR(1) ) -- #7#

-- INSERT DOS PRODUTOS DA FUNCTION 
INSERT INTO #PRODUTOSP2 (PRODUTO	     ,
						 COR_PRODUTO	 ,
						 GRADE	         ,
						 CODIGO_PRODUTO  ,
						 TAMANHO	     ,
						 TIPO_COD_BAR 	 ,
						 CODIGO_BARRA  	 						
						 ) SELECT PRODUTO ,COR_PRODUTO ,GRADE,CODIGO_PRODUTO,TAMANHO,TIPO_COD_BAR,CODIGO_BARRA 
						 FROM dbo.FX_LINXPOS_PROD (@CODIGO_FILIAL) -- Wendel Chamada da function 


SET @HASH_TAB_PRODUTO = ''
--Calcula hash da tabela 

UPDATE #PRODUTOSP2
	SET HASH_TAB_PRODUTO =  CASE WHEN P.PRODUTO IS NULL THEN '?'
							ELSE
								CASE WHEN P.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + P.PRODUTO + P.DESC_PROD_NF + P.UNIDADE + CAST(ISNULL(P.INDICADOR_CFOP, 0) AS VARCHAR) + P.CLASSIF_FISCAL + CAST(P.VARIA_PRECO_COR AS VARCHAR) + CAST(P.VARIA_PRECO_TAM AS VARCHAR)  + P.PONTEIRO_PRECO_TAM  + 	CAST(P.ARREDONDA AS VARCHAR)) THEN '' ELSE '?' END
							END
FROM #PRODUTOSP2 P2
LEFT JOIN PRODUTOS P
ON P2.PRODUTO = P.PRODUTO

--SELECT  @HASH_TAB_PRODUTO = CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + PRODUTO + DESC_PROD_NF + UNIDADE + CAST(ISNULL(INDICADOR_CFOP, 0) AS VARCHAR) + CLASSIF_FISCAL + CAST(VARIA_PRECO_COR AS VARCHAR) + CAST(VARIA_PRECO_TAM AS VARCHAR)  + PONTEIRO_PRECO_TAM  + 	CAST(ARREDONDA AS VARCHAR)) THEN '' ELSE '?' END  FROM PRODUTOS
--WHERE  LX_HASH <> HASHBYTES('MD5', @BUILD_BUFFER + PRODUTO + DESC_PROD_NF + UNIDADE + CAST(ISNULL(INDICADOR_CFOP, 0) AS VARCHAR) + CLASSIF_FISCAL + CAST(VARIA_PRECO_COR AS VARCHAR) + CAST(VARIA_PRECO_TAM AS VARCHAR)  + PONTEIRO_PRECO_TAM  + 	CAST(ARREDONDA AS VARCHAR))


SET @HASH_TAB_PRODUTO_BARRA = ''
--Calcula hash da tabela 
SELECT  @HASH_TAB_PRODUTO_BARRA = CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + 	CODIGO_BARRA +	PRODUTO+	COR_PRODUTO+	CAST(TAMANHO AS VARCHAR) +	GRADE +	CAST(ISNULL(TIPO_COD_BAR, 0) AS VARCHAR)) THEN '' ELSE '?' END  FROM PRODUTOS_BARRA 
WHERE  LX_HASH <> HASHBYTES('MD5', @BUILD_BUFFER + 	CODIGO_BARRA +	PRODUTO+	COR_PRODUTO+	CAST(TAMANHO AS VARCHAR) +	GRADE +	CAST(ISNULL(TIPO_COD_BAR, 0) AS VARCHAR) )


--UPDATE DADOS DE PRODUTOS
  UPDATE A SET           A.DESC_PROD      = B.DESC_PROD_NF,
                         A.UNIDADE        = B.UNIDADE,
						 A.INDICADOR_CFOP = B.INDICADOR_CFOP,
						 A.CLASSIF_FISCAL = B.CLASSIF_FISCAL,
						 A.PONTEIRO_PRECO_TAM = B.PONTEIRO_PRECO_TAM
						 from #PRODUTOSP2 A
						 INNER JOIN DBO.PRODUTOS B
						 ON A.PRODUTO = B.PRODUTO

-- UPDATE PARA ALIQUOTA
		UPDATE #PRODUTOSP2 SET ALIQUOTA = CASE A.ALIQUOTA 
                               WHEN 0 THEN 'I0000' 
                               WHEN -1 THEN 'F0000' 
                               WHEN -2 THEN 'N0000' 
                               ELSE CASE A.ID_IMPOSTO WHEN 14 THEN 'S' ELSE 'T' END 
                               + RIGHT(Replicate('0', 4) + CONVERT(VARCHAR, CONVERT(INT, A.ALIQUOTA * 100)), 4) END                                        
                               FROM   CLASSIF_FISCAL_IMPOSTO A 
                                      INNER JOIN dbo.LOJAS_VAREJO B 
                                            ON A.CODIGO_FILIAL = B.CODIGO_FILIAL 
		                              INNER JOIN #PRODUTOSP2 C
											ON C.CLASSIF_FISCAL BETWEEN A.CLASSIF_FISCAL_INICIAL AND A.CLASSIF_FISCAL_FINAL	   
                                    WHERE   A.UF = @LocalUF 
                                          AND  B.FILIAL = @FILIAL 


SELECT @HASH_TAB_CLASSIF_FISCAL_IMPOSTO = CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CLASSIF_FISCAL_INICIAL + CLASSIF_FISCAL_FINAL + UF + CAST(ID_IMPOSTO AS VARCHAR) + CAST(ALIQUOTA AS VARCHAR) + CODIGO_FILIAL) THEN '' ELSE '?' END FROM CLASSIF_FISCAL_IMPOSTO
 
-- #7# - Início
-- Update para Precos
	--UPDATE #PRODUTOSP2 SET PRECO1 = ISNULL(E.PRECO1, CASE WHEN A.VARIA_PRECO_COR  = 1 THEN D.PRECO1 ELSE C.PRECO1 END), 
 --                      PRECO2 = ISNULL(E.PRECO2, CASE WHEN A.VARIA_PRECO_COR  = 1 THEN D.PRECO2 ELSE C.PRECO2 END),    
 --                      PRECO3 = ISNULL(E.PRECO3, CASE WHEN A.VARIA_PRECO_COR  = 1 THEN D.PRECO3 ELSE C.PRECO3 END), 
	--				   PRECO4 = ISNULL(E.PRECO4, CASE WHEN A.VARIA_PRECO_COR  = 1 THEN D.PRECO4 ELSE C.PRECO4 END)                                           
 --                      FROM   dbo.PRODUTOS A 
 --                      INNER JOIN dbo.PRODUTO_CORES B 
 --                           ON A.PRODUTO          = B.PRODUTO 
 --                      INNER JOIN dbo.PRODUTOS_PRECOS C 
 --                           ON A.PRODUTO          = C.PRODUTO 
 --                           AND C.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO--#4#
 --                      LEFT JOIN dbo.PRODUTOS_PRECO_COR D 
 --                           ON C.CODIGO_TAB_PRECO = D.CODIGO_TAB_PRECO  
 --                           AND C.PRODUTO        = D.PRODUTO 
 --                           AND B.COR_PRODUTO    = D.COR_PRODUTO 
 --                           AND C.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO--#4#
 --                      LEFT JOIN dbo.PRODUTOS_PRECO_FILIAL E 
 --                           ON C.CODIGO_TAB_PRECO = E.CODIGO_TAB_PRECO 
	--	                    AND B.PRODUTO         = E.PRODUTO 
	--		                AND B.COR_PRODUTO     = E.COR_PRODUTO
	--		                AND C.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO--#4#
	--		                AND E.FILIAL = @FILIAL--#4#
 --                      INNER JOIN  #PRODUTOSP2 F
	--				        ON A.PRODUTO           = F.PRODUTO 

	-- #7# -  UPDATE 1
	UPDATE A
		SET A.PRECO1 = CASE WHEN ISNULL(B.PRECO1,0) <> 0 THEN B.PRECO1 END, 
			A.PRECO2 = CASE WHEN ISNULL(B.PRECO2,0) <> 0 THEN B.PRECO2 END,   
			A.PRECO3 = CASE WHEN ISNULL(B.PRECO3,0) <> 0 THEN B.PRECO3 END, 
			A.PRECO4 = CASE WHEN ISNULL(B.PRECO4,0) <> 0 THEN B.PRECO4 END,
			A.ATUALIZADO = 1	   
		FROM #PRODUTOSP2 A
		INNER JOIN DBO.PRODUTOS_PRECO_FILIAL B 
			ON B.PRODUTO = A.PRODUTO  
		   AND B.COR_PRODUTO = A.COR_PRODUTO
		WHERE ATUALIZADO = 0
		   AND B.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO
		   AND B.FILIAL = @FILIAL

	-- #7# -  UPDATE 2
	UPDATE A
		SET A.PRECO1 = CASE WHEN ISNULL(C.PRECO1,0) <> 0 THEN C.PRECO1 END, 
			A.PRECO2 = CASE WHEN ISNULL(C.PRECO2,0) <> 0 THEN C.PRECO2 END,    
			A.PRECO3 = CASE WHEN ISNULL(C.PRECO3,0) <> 0 THEN C.PRECO3 END, 
			A.PRECO4 = CASE WHEN ISNULL(C.PRECO4,0) <> 0 THEN C.PRECO4 END,
			A.ATUALIZADO = 1
		FROM #PRODUTOSP2 A
		INNER JOIN DBO.PRODUTOS B 
			ON A.PRODUTO = B.PRODUTO 
		INNER JOIN DBO.PRODUTOS_PRECO_COR C
			ON A.PRODUTO = C.PRODUTO 
			AND A.COR_PRODUTO = C.COR_PRODUTO
			AND C.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO
		WHERE B.VARIA_PRECO_COR = 1 
			AND ATUALIZADO = 0		

	-- #7# -  UPDATE 3
	UPDATE A
		SET A.PRECO1 = ISNULL(B.PRECO1, A.PRECO1), 
			A.PRECO2 = ISNULL(B.PRECO2, A.PRECO2),    
			A.PRECO3 = ISNULL(B.PRECO3, A.PRECO3), 
			A.PRECO4 = ISNULL(B.PRECO4, A.PRECO4),
			A.ATUALIZADO = 1
		FROM #PRODUTOSP2 A
		INNER JOIN DBO.PRODUTOS_PRECOS B 
			ON A.PRODUTO = B.PRODUTO 
		   AND B.CODIGO_TAB_PRECO = @CODIGO_TAB_PRECO
		WHERE ATUALIZADO = 0		   
-- #7# - Fim

SET @HASH_TAB_PRODUTOS_PRECO_COR =''
SET @HASH_TAB_PRODUTOS_PRECOS =''
SET @HASH_TAB_PRODUTO_CORES  =''
SET @HASH_TAB_PRODUTO_BARRA = ''


--SELECT @HASH_TAB_PRODUTOS_PRECO_FILIAL = CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + 
SELECT @HASH_TAB_PRODUTOS_PRECO_COR    = MAX(CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_TAB_PRECO + PRODUTO + COR_PRODUTO +  CAST(ISNULL(PRECO1, 0) AS VARCHAR) +	CAST(ISNULL(PRECO2, 0) AS VARCHAR) + CAST(ISNULL(PRECO3, 0) AS VARCHAR) + CAST(ISNULL(PRECO4, 0) AS VARCHAR) ) THEN '' ELSE '?' END) FROM PRODUTOS_PRECO_COR
SELECT @HASH_TAB_PRODUTOS_PRECOS       = MAX(CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_TAB_PRECO + PRODUTO + CAST(ISNULL(PRECO1, 0) AS VARCHAR) +  CAST(ISNULL(PRECO2, 0) AS VARCHAR)  + CAST(ISNULL(PRECO3, 0) AS VARCHAR) +	CAST(ISNULL(PRECO4, 0) AS VARCHAR) ) THEN '' ELSE '?' END) FROM PRODUTOS_PRECOS 
SELECT @HASH_TAB_PRODUTO_CORES         = MAX(CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + PRODUTO +	COR_PRODUTO + DESC_COR_PRODUTO ) THEN '' ELSE '?' END) FROM PRODUTO_CORES 
SELECT @HASH_TAB_PRODUTO_BARRA         = MAX(CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_BARRA +	PRODUTO+	COR_PRODUTO+	CAST(TAMANHO AS VARCHAR) +	GRADE +	CAST(ISNULL(TIPO_COD_BAR, 0) AS VARCHAR)) THEN '' ELSE '?' END) FROM PRODUTOS_BARRA 

--GERAÇÃO DO REGISTRO PARA O ARQUIVOS DO PAF.

      INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL )  
      SELECT  3 AS TIPO, 
				 'P2'                                                                                                                  +
				 RIGHT(Replicate('0', 14) + Rtrim(Replace(Replace(Replace(ISNULL(@CGC_CPF, ''), '.', ''), '-', ''), '/', '')), 14)     +
				 LEFT(Rtrim(Replace(Replace(Replace(ISNULL(CODIGO_BARRA, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ',14), 14) +--#11#
				 LEFT(Rtrim(Replace(Replace(Replace(ISNULL(DESC_PROD, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ',50), 50)      +
--				 RTRIM(LTRIM(@HASH_TAB_PRODUTO + @HASH_TAB_CLASSIF_FISCAL_IMPOSTO + @HASH_TAB_PRODUTOS_PRECO_COR +@HASH_TAB_PRODUTOS_PRECOS +@HASH_TAB_PRODUTO_CORES)) +	--	#1#
				 REPLACE(LEFT(Rtrim(Replace(Replace(Replace(ISNULL(UNIDADE, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ',6), 6), ' ',	-- #1#
				 --CASE WHEN RTRIM(LTRIM(@HASH_TAB_PRODUTO + @HASH_TAB_CLASSIF_FISCAL_IMPOSTO + @HASH_TAB_PRODUTOS_PRECO_COR +@HASH_TAB_PRODUTOS_PRECOS +@HASH_TAB_PRODUTO_CORES + @HASH_TAB_PRODUTO_BARRA)) = '' THEN ' ' ELSE '?' END) +	--	#1#
				 CASE WHEN RTRIM(LTRIM(HASH_TAB_PRODUTO + @HASH_TAB_CLASSIF_FISCAL_IMPOSTO + @HASH_TAB_PRODUTOS_PRECO_COR +@HASH_TAB_PRODUTOS_PRECOS +@HASH_TAB_PRODUTO_CORES + @HASH_TAB_PRODUTO_BARRA)) = '' THEN ' ' ELSE '?' END) +	--	#1#
			     'A'                                                                                                                   +
				 CASE ISNULL(INDICADOR_CFOP, 11) WHEN 10 THEN 'P' ELSE 'T' END                                                         +
			     ISNULL(ALIQUOTA, 'T' + RIGHT('0000' + CONVERT(VARCHAR, CONVERT(INT, @LOCALSAIDA_ICMS * 100)), 4))                     +
				 RIGHT(REPLICATE('0', 12) + CONVERT(VARCHAR, CONVERT(INT, ISNULL(CASE SUBSTRING(PONTEIRO_PRECO_TAM, TAMANHO, 1) WHEN 1 THEN PRECO1 WHEN 2 THEN PRECO2 WHEN 3 THEN PRECO3 WHEN 4 THEN PRECO4 END, 0) * 100), 12), 12) AS REGISTRO,
				 105, @TERMINAL 
				 FROM #PRODUTOSP2

END 

  /*  ELSE  
    BEGIN 
      INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL )  
      SELECT  
        3 AS TIPO, 
        'P2' +  
        @CGC_CPF                                                       + 
        ( CASE WHEN @MOSTRA_TICKET = 2 THEN CONVERT(CHAR(14), RTRIM(A.PRODUTO) + RTRIM(F.COR_PRODUTO) + RTRIM(F.TAMANHO)) 
        ELSE CONVERT(CHAR(14), A.PRODUTO) END )                        + 
        CONVERT(CHAR(50), A.DESC_PROD_NF)                              + 
        REPLACE(CONVERT(CHAR(6), A.UNIDADE), ' ',  
        CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.PRODUTO + A.DESC_PRODUTO + A.DESC_PROD_NF)  
            AND D.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + D.CODIGO_TAB_PRECO + D.PRODUTO + CONVERT(CHAR(20), D.PRECO1) + CONVERT(CHAR(20), D.PRECO2) + CONVERT(CHAR(20), D.PRECO3) + CONVERT(CHAR(20), D.PRECO4))  
            AND ISNULL(G.HASH_VALIDO_IMPOSTO, 1) = 1 
            AND H.LX_HASH = LX_HASH_E    
            AND I.LX_HASH = LX_HASH_C THEN ' ' ELSE '?' END)          + 
        'A'                                                             + 
        CASE ISNULL(A.INDICADOR_CFOP, 11) WHEN 10 THEN 'P' ELSE 'T' END + 
        ISNULL(G.ALIQUOTA, 'T' + RIGHT('0000' + CONVERT(VARCHAR, CONVERT(INT, @LOCALSAIDA_ICMS * 100)), 4)) + 
        RIGHT(REPLICATE('0', 12) + CONVERT(VARCHAR, CONVERT(INT, ISNULL(CASE SUBSTRING(A.PONTEIRO_PRECO_TAM, F.TAMANHO, 1) WHEN 1 THEN D.PRECO1 WHEN 2 THEN D.PRECO2 WHEN 3 THEN D.PRECO3 WHEN 4 THEN D.PRECO4 END, 0) * 100), 12), 12) 
        AS REGISTRO, 
        105, @TERMINAL 
      FROM 
        #LJ_REG_PAF_ECF_PRODUTO A 
        INNER JOIN ( SELECT  A.PRODUTO,E.FILIAL, C.CODIGO_TAB_PRECO, B.COR_PRODUTO, 
                    LX_HASH_E         = HASHBYTES('MD5', @BUILD_BUFFER + E.CODIGO_TAB_PRECO + E.FILIAL  +  E.PRODUTO + E.COR_PRODUTO +  CAST(ISNULL(E.PRECO1, 0) AS VARCHAR) + CAST(ISNULL(E.PRECO2, 0) AS VARCHAR) + CAST(ISNULL(E.PRECO3, 0) AS VARCHAR) + CAST(ISNULL(E.PRECO4, 0) AS VARCHAR)), 
              LX_HASH_C         = HASHBYTES('MD5', @BUILD_BUFFER + C.CODIGO_TAB_PRECO + C.PRODUTO + CAST(ISNULL(C.PRECO1, 0) AS VARCHAR) + CAST(ISNULL(C.PRECO2, 0) AS VARCHAR) + CAST(ISNULL(C.PRECO3, 0) AS VARCHAR) + CAST(ISNULL(C.PRECO4, 0) AS VARCHAR)), 
              PRECO1            = ISNULL(E.PRECO1,            CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO1            ELSE C.PRECO1            END),  
              PRECO2            = ISNULL(E.PRECO2,            CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO2            ELSE C.PRECO2            END),  
              PRECO3            = ISNULL(E.PRECO3,            CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO3            ELSE C.PRECO3            END),  
              PRECO4            = ISNULL(E.PRECO4,            CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO4            ELSE C.PRECO4            END),  
              PRECO_LIQUIDO1    = ISNULL(E.PRECO_LIQUIDO1,    CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO_LIQUIDO1    ELSE C.PRECO_LIQUIDO1    END),  
              PRECO_LIQUIDO2    = ISNULL(E.PRECO_LIQUIDO2,    CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO_LIQUIDO2    ELSE C.PRECO_LIQUIDO2    END),  
              PRECO_LIQUIDO3    = ISNULL(E.PRECO_LIQUIDO3,    CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO_LIQUIDO3    ELSE C.PRECO_LIQUIDO3    END),  
              PRECO_LIQUIDO4    = ISNULL(E.PRECO_LIQUIDO4,    CASE WHEN A.VARIA_PRECO_COR = 1 THEN D.PRECO_LIQUIDO4    ELSE C.PRECO_LIQUIDO4    END),  
              PROMOCAO_DESCONTO = ISNULL(E.PROMOCAO_DESCONTO, CASE WHEN VARIA_PRECO_COR   = 1 THEN D.PROMOCAO_DESCONTO ELSE C.PROMOCAO_DESCONTO END),  
              INICIO_PROMOCAO   = ISNULL(E.INICIO_PROMOCAO,   CASE WHEN VARIA_PRECO_COR   = 1 THEN D.INICIO_PROMOCAO   ELSE C.INICIO_PROMOCAO   END),  
              FIM_PROMOCAO      = ISNULL(E.FIM_PROMOCAO,      CASE WHEN VARIA_PRECO_COR   = 1 THEN D.FIM_PROMOCAO      ELSE C.FIM_PROMOCAO      END), 
              C.LIMITE_DESCONTO, C.LX_HASH   
        FROM dbo.PRODUTOS A  
        INNER JOIN dbo.PRODUTO_CORES B  
          ON A.PRODUTO           = B.PRODUTO  
        INNER JOIN dbo.PRODUTOS_PRECOS C  
          ON A.PRODUTO           = C.PRODUTO  
        LEFT JOIN dbo.PRODUTOS_PRECO_COR D  
          ON C.CODIGO_TAB_PRECO  = D.CODIGO_TAB_PRECO  
          AND C.PRODUTO          = D.PRODUTO  
          AND B.COR_PRODUTO      = D.COR_PRODUTO  
        LEFT JOIN dbo.PRODUTOS_PRECO_FILIAL E  
          ON C.CODIGO_TAB_PRECO  = E.CODIGO_TAB_PRECO  
          AND B.PRODUTO          = E.PRODUTO  
          AND B.COR_PRODUTO      = E.COR_PRODUTO ) D -- ANTIGA VIEW W_LJ_PRECO_PRODUTO -- 
          ON A.PRODUTO           = D.PRODUTO 
        INNER JOIN dbo.PRODUTOS E 
            ON A.PRODUTO           = E.PRODUTO 
        INNER JOIN #LJ_PRODUTO_BARRA F  
          ON  A.PRODUTO          = E.PRODUTO  
          AND D.COR_PRODUTO      = F.COR_PRODUTO  
        INNER JOIN dbo.PRODUTOS_PRECO_FILIAL H 
          ON H.CODIGO_TAB_PRECO  = D.CODIGO_TAB_PRECO 
          AND H.PRODUTO          = E.PRODUTO 
          AND H.COR_PRODUTO      = F.COR_PRODUTO  
          AND H.FILIAL           = D.FILIAL 
        INNER JOIN dbo.PRODUTOS_PRECOS I 
          ON  I.CODIGO_TAB_PRECO =  D.CODIGO_TAB_PRECO  
          AND I.PRODUTO          = E.PRODUTO 
          INNER JOIN dbo.PRODUTOS_PRECO_COR J 
          ON J.PRODUTO           = E.PRODUTO  
          AND J.CODIGO_TAB_PRECO = D.CODIGO_TAB_PRECO  
          AND J.COR_PRODUTO      = F.COR_PRODUTO  
        LEFT JOIN  
          (  SELECT  
              REPLACE(A.CLASSIF_FISCAL_INICIAL, '.', '') AS CLASSIF_FISCAL_INICIAL,  
              REPLACE(A.CLASSIF_FISCAL_FINAL, '.', '')   AS CLASSIF_FISCAL_FINAL,  
              A.UF, A.CODIGO_FILIAL, B.FILIAL,  
              CASE A.ALIQUOTA WHEN 0 THEN 'I0000'  
                      WHEN -1 THEN  'F0000'  
                      WHEN -2 THEN  'N0000'  
              ELSE  
                CASE A.ID_IMPOSTO WHEN 14 THEN 'S' ELSE 'T' END +  
                RIGHT(REPLICATE('0', 4) + CONVERT(VARCHAR, CONVERT(INT, A.ALIQUOTA * 100)), 4)  
              END AS ALIQUOTA,  
              CONVERT(BIT, CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CONVERT(CHAR(10), A.ID_IMPOSTO) +  
              CONVERT(CHAR(10), A.ALIQUOTA)) THEN 1 ELSE 0 END) AS HASH_VALIDO_IMPOSTO  
            FROM  
              dbo.CLASSIF_FISCAL_IMPOSTO A  
              LEFT JOIN dbo.LOJAS_VAREJO B ON A.CODIGO_FILIAL = B.CODIGO_FILIAL 
            WHERE ( A.UF = @LocalUF OR A.UF IS NULL OR A.UF = '' ) 
            AND ( B.FILIAL = @FILIAL OR A.CODIGO_FILIAL IS NULL AND A.CODIGO_FILIAL = '' )) G  
          ON A.CLASSIF_FISCAL BETWEEN G.CLASSIF_FISCAL_INICIAL  
            AND G.CLASSIF_FISCAL_FINAL 
            LEFT JOIN dbo.LJ_PRODUTO_IMPOSTO L 
          ON L.PRODUTO       = E.PRODUTO  
          AND L.CODIGO_FILIAL  = G.CODIGO_FILIAL 
      WHERE D.CODIGO_TAB_PRECO   = @CODIGO_TAB_PRECO  
      AND ( D.FILIAL = @FILIAL OR D.FILIAL IS NULL ) 
    END 
  END  ; 
   
  */ 
--REGISTRO E2 ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Print 'Registro E2'    
   --IF @Verifica_Reducao = 0   --#7#
	 IF @Verifica_Reducao = '0' --#7#

        Begin 
            IF @MOSTRA_TICKET = 1 
              BEGIN 
                  INSERT INTO LJ_REG_PAF_ECF_TEMP 
                              (TIPO, 
                               REGISTRO, 
                               LIMITE, 
                               TERMINAL) 
                  Select 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     AS TIPO, 
                         'E2' 
                         + RIGHT(Replicate('0', 14) + Rtrim(Replace(Replace(Replace(ISNULL(CNPJ_ESTABELECIMENTO, ''), '.', ''), '-', ''), '/', '')), 14) 
                         + RIGHT(Replicate('0', 14) + LEFT(Rtrim(Replace(Replace(Replace(ISNULL(CODIGO_PRODUTO, ''), '.', ''), '-', ''), '/', '')),14), 14)--#11#
                         + left(Rtrim(Replace(Replace(Replace(ISNULL(DESCRICAO_PRODUTO, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ', 50), 50) 
                         + REPLACE(left(Rtrim(Replace(Replace(Replace(ISNULL(DESCRICAO_UNIDADE, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ', 6), 6), ' ', 
						   CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL + CNPJ_ESTABELECIMENTO + CODIGO_PRODUTO + DESCRICAO_PRODUTO + DESCRICAO_UNIDADE + Cast(SALDO_ESTOQUE AS VARCHAR)) THEN ' ' ELSE '?' END)	--	#1# 
						 + Case When Left(SALDO_ESTOQUE, 1) ='-' Then '-' + RIGHT(Replicate('0', 9) + Rtrim(Replace(Replace(Replace(ISNULL(SALDO_ESTOQUE, 0), '.', ''), '-', ''), '/', '')), 9) Else '+' + RIGHT(Replicate('0', 9) + Rtrim(Replace(Replace(Replace(ISNULL(SALDO_ESTOQUE, 0), '.', ''), '-', ''), '/', '')), 9) End as Registro, 
                         96, 
                         @TERMINAL 
                  From   #LJ_ESTOQUE_PAF_ECF 
                  where  CODIGO_FILIAL = @CODIGO_FILIAL; 
              END; 
            ELSE 
              BEGIN 
                  INSERT INTO LJ_REG_PAF_ECF_TEMP 
                              (TIPO, 
                               REGISTRO, 
                               LIMITE, 
                               TERMINAL) 
                  Select 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     AS TIPO, 
                         'E2' 
                         + RIGHT(Replicate('0', 14) + Rtrim(Replace(Replace(Replace(ISNULL(CNPJ_ESTABELECIMENTO, ''), '.', ''), '-', ''), '/', '')), 14) 
                         + RIGHT(Replicate('0', 14) + LEFT(Rtrim(Replace(Replace(Replace(ISNULL(CODIGO_PRODUTO, ''), '.', ''), '-', ''), '/', '')),14), 14)--#11#
                         + left(Rtrim(Replace(Replace(Replace(ISNULL(DESCRICAO_PRODUTO, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ', 50), 50) 
                         + REPLACE(left(Rtrim(Replace(Replace(Replace(ISNULL(DESCRICAO_UNIDADE, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ', 6), 6), ' ',	--	#1#
                           CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL + CNPJ_ESTABELECIMENTO + CODIGO_PRODUTO + DESCRICAO_PRODUTO + DESCRICAO_UNIDADE + Cast(SALDO_ESTOQUE AS VARCHAR)) THEN ' ' ELSE '?' END)	--	#1#
                         + Case When Left(SALDO_ESTOQUE, 1) ='-' Then '-' + RIGHT(Replicate('0', 9) + Rtrim(Replace(Replace(Replace(ISNULL(SALDO_ESTOQUE, 0), '.', ''), '-', ''), '/', '')), 9) Else '+' + RIGHT(Replicate('0', 9) + Rtrim(Replace(Replace(Replace(ISNULL(SALDO_ESTOQUE, 0), '.', ''), '-', ''), '/', '')), 9) End as Registro, 
                         96, 
                         @TERMINAL 
                  From   #LJ_ESTOQUE_PAF_ECF 
                  where  CODIGO_FILIAL = @CODIGO_FILIAL; 
              END 
        End; 

--REGISTRO E3 ------------------------------------------------------------------------------------------------------------------------------------------------------------   
Print 'Registro E3' 
      BEGIN 
          INSERT INTO LJ_REG_PAF_ECF_TEMP 
                      (TIPO, 
                       REGISTRO, 
                       LIMITE, 
                       TERMINAL) 
          SELECT TOP 1 5                                                             AS TIPO, 
                       'E3' + CONVERT(CHAR(20), ID_EQUIPAMENTO) 
                       + MF_ADICIONAL + TIPO_ECF                        
                       + ISNULL(CONVERT(CHAR(20), CASE WHEN LEN(MARCA) >6 AND  LEFT(MARCA,6) = 'DARUMA' THEN 'DARUMA AUTOMACAO' ELSE MARCA END),'')   --#9#
                       + REPLACE(CONVERT(CHAR(20), MODELO), ' ', CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL + ID_EQUIPAMENTO + MF_ADICIONAL + TIPO_ECF + MARCA + MODELO + CONVERT(VARCHAR, DATA_HORA_CUPOM, 126))THEN ' ' ELSE '?' END)	--	#1#
                       + CONVERT(VARCHAR(8), DATA_HORA_CUPOM, 112) 
                       + Replace(CONVERT(VARCHAR(8), DATA_HORA_CUPOM, 108), ':', '') as REGISTRO, 
                       84, 
                       @TERMINAL 
          From   dbo.LJ_ESTOQUE_PAF_ECF_CUPOM 
          Where  --CONVERT(Varchar, ( DATA_HORA_CUPOM ), 112) Between @strDT_INICIAL And @strDT_FINAL 
                 --And 
				 CODIGO_FILIAL = @CODIGO_FILIAL 
      End 


--REGISTRO D2 ---------------------------------------------------------------------------------------------------------------------------------------------------------------   
Print 'Registro D2' 

      INSERT INTO LJ_REG_PAF_ECF_TEMP 
                  (TIPO, 
                   REGISTRO, 
                   LIMITE, 
                   TERMINAL) 
      SELECT 6                                                                                                                      as TIPO, 
             'D2' 
             + RIGHT(Replicate('0', 14) + Rtrim(Replace(Replace(Replace(ISNULL(@CGC_CPF, ''), '.', ''), '-', ''), '/', '')), 14) 
             + LEFT(Rtrim(Replace(Replace(Replace(ISNULL(Rtrim(Ltrim(ID_EQUIPAMENTO_DAV)), ''), '.', ''), '-', ''), '/', ''))+Replicate(' ', 20) , 20) 
             + ISNULL(MF_ADICIONAL, ' ') 
             + left(Replace(Rtrim(Ltrim(TIPO_ECF)), ' ', '') + '       ', 7) 
             + left(Replace(Rtrim(Ltrim(isnull(MARCA, ''))), ' ', '') + '                    ', 20) 
             + REPLACE(left(Replace(Rtrim(Ltrim(isnull(MODELO, ''))), ' ', '') + '                    ', 20), ' ',	--	#1#
               CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL_ORIGEM + CAST(PEDIDO AS VARCHAR) + ISNULL(CNPJ_ESTABELECIMENTO ,@CGC_CPF) + ISNULL(ID_EQUIPAMENTO_DAV, '')
					+ ISNULL(MF_ADICIONAL, '') + TIPO_ECF + ISNULL(MARCA, '') + ISNULL(MODELO, '') + CAST(ISNULL(COO_DAV, '0') AS VARCHAR) 
					+ ISNULL(SEQUENCIAL_PRE_VENDA, '') + CONVERT(VARCHAR, ISNULL(DATA, 0), 126) + TITULO_DAV + CAST(ISNULL(VALOR_TOTAL,'0') AS VARCHAR) + CAST(ISNULL(DESCONTO,'0') AS VARCHAR)  
					+ CAST(ISNULL(COO_VENDA,'0') AS VARCHAR) + CAST(ISNULL(SEQ_ECF_CF_DAV,'0') AS VARCHAR) + ISNULL(IDENTIFICACAO_CLIENTE,'') + ISNULL(CPF_CGC_ECF,''))  THEN ' ' ELSE '?' END)	--	#1#
             + RIGHT(Replicate('0', 9) + ISNULL(CONVERT(VARCHAR, RTRIM(LTRIM(COO_DAV))), '0'), 9) 
             + right(Replicate('0', 13) +ISNULL(CONVERT(VARCHAR,RTRIM(LTRIM(SEQUENCIAL_PRE_VENDA))),'0') , 13)
             + CONVERT(VARCHAR, ISNULL(DATA, Getdate()), 112) 
             + 'ORCAMENTO                     ' 
             + RIGHT(Replicate('0', 8)  + ISNULL(CONVERT(VARCHAR, CONVERT(INT, (VALOR_TOTAL - DESCONTO) * 100)), 0), 8) 
             + RIGHT(Replicate('0', 9)  + ISNULL(CONVERT(VARCHAR, RTRIM(LTRIM(COO_VENDA))), '0'), 9) 
             + CASE WHEN A.ENTREGUE = 0 THEN '000' ELSE  RIGHT(Replicate('0', 3)  + ISNULL(CONVERT(VARCHAR, RTRIM(LTRIM(SEQ_ECF_CF_DAV))), '0'), 3) END
			 + left(Rtrim(Replace(Replace(Replace(ISNULL(IDENTIFICACAO_CLIENTE, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ', 40), 40)  
             + RIGHT(Replicate('0', 14)  + ISNULL(CONVERT(VARCHAR, RTRIM(LTRIM(CPF_CGC_ECF))), '0'), 14)  as Registro, 
             212, 
             @TERMINAL 
      FROM   LOJA_PEDIDO A
      Where  CONVERT(Varchar, ( data ), 112) Between @strDT_INICIAL And @strDT_FINAL 
             AND CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL 
			 AND A.LX_TIPO_PRE_VENDA = 2 -- SOMENTE DAV, Não leva Pré venda

		 
--REGISTRO D3-------------------------------------------------------------------------------------------------------------------------------------------------- 
print 'D3' 

	--#5# - Início
	SELECT DISTINCT B.PRODUTO              
	INTO   #ProdutosCestD3
	FROM   dbo.LOJA_PEDIDO A 
		   INNER JOIN dbo.LOJA_PEDIDO_PRODUTO B ON A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM AND A.PEDIDO = B.PEDIDO 
	WHERE  CONVERT(Varchar,(data), 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL AND A.LX_TIPO_PRE_VENDA = 2


	create table #DescrProdutosCestD3
	( PRODUTO varchar(25) COLLATE DATABASE_DEFAULT,    --#6#
	  DESCRICAO varchar(200) COLLATE DATABASE_DEFAULT) --#6# 


	DECLARE @Produto VARCHAR(25)

	SELECT TOP 1 @Produto = PRODUTO FROM #ProdutosCestD3
	  
	WHILE @@ROWCOUNT <> 0 
	BEGIN 
		insert #DescrProdutosCestD3
		EXEC LX_LJ_PAF_DETALHE_PRODUTO @PRODUTO, @FILIAL
		     
		DELETE #ProdutosCestD3 WHERE PRODUTO = @Produto
		SET @Produto = ''
		
		SELECT TOP 1 @Produto = PRODUTO from #ProdutosCestD3
	END
	DROP TABLE #ProdutosCestD3
	--#5# - Fim

      INSERT INTO LJ_REG_PAF_ECF_TEMP 
                  (TIPO, 
                   REGISTRO, 
                   LIMITE, 
                   TERMINAL) 
      SELECT 7    as TIPO, 
             'D3' 
             + RIGHT(Replicate('0', 13) + Rtrim(Ltrim(ISNULL(SEQUENCIAL_PRE_VENDA, '0'))), 13) 
             + ISNULL(Replace(CONVERT(CHAR(8), DATA_INCLUSAO, 112), '/', ''), '') 
             + RIGHT(Replicate('0', 3) + ISNULL(CONVERT(VARCHAR, ITEM), '0'), 3) 
             + CASE WHEN @MOSTRA_TICKET = 1 THEN CONVERT(CHAR(14), CODIGO_BARRA) WHEN @MOSTRA_TICKET = 2 THEN CONVERT(CHAR(14), Rtrim(B.PRODUTO) + Rtrim(COR_PRODUTO) + Rtrim(TAMANHO)) ELSE CONVERT(CHAR(14), B.PRODUTO) END 
             --+ REPLACE(ISNULL( CONVERT(CHAR(100), DESCR_PRODUTO), ''), ' ',	--	#1# #5#
			 + REPLACE(ISNULL(CONVERT(CHAR(100),C.DESCRICAO), DESCR_PRODUTO), ' ',	--	#5#
               CASE WHEN A.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + A.CODIGO_FILIAL_ORIGEM + Cast(A.PEDIDO AS VARCHAR) + ISNULL(CNPJ_ESTABELECIMENTO,@CGC_CPF) + ISNULL(A.ID_EQUIPAMENTO_DAV,'') + ISNULL(A.MF_ADICIONAL, '' ) + A.TIPO_ECF + ISNULL(A.MARCA, '') + ISNULL(MODELO, '') + CAST(ISNULL(COO_DAV, '0') AS VARCHAR) + ISNULL(SEQUENCIAL_PRE_VENDA, '') + CONVERT(VARCHAR, ISNULL(DATA, '0'), 126) + TITULO_DAV + CAST(ISNULL(VALOR_TOTAL, 0) AS VARCHAR) + CAST(ISNULL(DESCONTO, 0) AS VARCHAR) + CAST(ISNULL(COO_VENDA, '0') AS VARCHAR)  + CAST(ISNULL(SEQ_ECF_CF_DAV, '0') AS VARCHAR) + ISNULL(IDENTIFICACAO_CLIENTE, '') + ISNULL(CPF_CGC_ECF, '')) 
			         AND B.LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + B.CODIGO_FILIAL_ORIGEM + Cast(B.PEDIDO AS VARCHAR) + Cast(B.ITEM AS VARCHAR) + CONVERT(VARCHAR, ISNULL(B.DATA_INCLUSAO, 0), 126) + B.CODIGO_BARRA + ISNULL(B.DESCR_PRODUTO, '') + Cast(ISNULL(B.QTDE, 0) AS VARCHAR) + ISNULL(B.UNIDADE, '') + Cast(ISNULL(B.PRECO_LIQUIDO, 0) AS VARCHAR) + Cast(ISNULL(B.DESCONTO_ITEM, 0) AS VARCHAR) + ISNULL(B.SITUACAO_TRIBUTARIA, '') + Cast(ISNULL(B.ALIQUOTA, 0) AS VARCHAR) + Cast(B.CANCELADO AS VARCHAR) + Cast(ISNULL(B.DECIMAIS_QTDE, 0) AS VARCHAR) + Cast(ISNULL(B.DECIMAIS_PREC_UNIT, 2) AS VARCHAR)) THEN ' ' ELSE '?' END)	--	#1#
             + RIGHT(Replicate('0', 7) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, QTDE * 100)), '0'), 7) 
             + ISNULL(CONVERT(CHAR(3), UNIDADE), 'UN') 
             + RIGHT(Replicate('0', 8) + replace(ISNULL(CONVERT(VARCHAR, CONVERT(INT, isnull(PRECO_LIQUIDO + DESCONTO_ITEM, 0) * 100)), '0'),'-','') , 8)
             + RIGHT(Replicate('0', 8) + Replace(CASE WHEN ISNULL(DESCONTO_ITEM, 0) > 0 THEN CONVERT(VARCHAR, Replace(ISNULL(DESCONTO_ITEM, '0'), '.', '')) ELSE '0' END, '-', ''), 8)
			 + RIGHT(Replicate('0', 8) + Replace(CASE WHEN ISNULL(DESCONTO_ITEM, 0) < 0 THEN CONVERT(VARCHAR, Replace(ISNULL(DESCONTO_ITEM, '0'), '.', '')) ELSE '0' END, '-', ''), 8) 
             + RIGHT(Replicate('0', 14) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, (QTDE * PRECO_LIQUIDO) * 100)), '0'), 14) 
             + CONVERT(VARCHAR, ISNULL( SITUACAO_TRIBUTARIA, '') ) 
             + CASE WHEN RTRIM(LTRIM(isnull(SITUACAO_TRIBUTARIA,''))) NOT IN ('T','S') then '0000' else RIGHT(Replicate('0', 4) + CONVERT(VARCHAR, CONVERT(INT, ISNULL(ALIQUOTA, @LOCALSAIDA_ICMS) * 100)), 4) end  
             + CASE WHEN B.CANCELADO = 1 THEN 'S' ELSE 'N' END 
             + CONVERT(VARCHAR, ISNULL(DECIMAIS_QTDE, 0)) 
             + CONVERT(VARCHAR, ISNULL(DECIMAIS_PREC_UNIT, 2)) AS REGISTRO, 
             196, 
             @TERMINAL 
      FROM   dbo.LOJA_PEDIDO A 
             INNER JOIN dbo.LOJA_PEDIDO_PRODUTO B 
                     ON A.CODIGO_FILIAL_ORIGEM = B.CODIGO_FILIAL_ORIGEM 
                        AND A.PEDIDO = B.PEDIDO 
			LEFT JOIN #DescrProdutosCestD3 C ON B.PRODUTO = C.PRODUTO --#5#
      Where  CONVERT(Varchar, ( data ), 112) Between @strDT_INICIAL And @strDT_FINAL
	                AND A.LX_TIPO_PRE_VENDA = 2 -- SOMENTE DAV, Não leva Pré venda ;   

--REGISTRO D4 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
print 'D4' 

--#5# - Início
	SELECT DISTINCT CODIGO_BARRA
	INTO   #ProdutosCestD4
	FROM   dbo.LOJA_PEDIDO_PRODUTO_LOG
	WHERE  CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL AND CONVERT(CHAR(8), DATA_HORA_ALTERACAO, 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL; 


	create table #DescrProdutosCestD4
	(CODIGO_BARRA varchar(25) COLLATE DATABASE_DEFAULT, --#6#
	  DESCRICAO VARCHAR(200) COLLATE DATABASE_DEFAULT)  --#6#


	DECLARE @CodigoBarra VARCHAR(200)

	SELECT TOP 1 @CodigoBarra = CODIGO_BARRA FROM #ProdutosCestD4
	  
	WHILE @@ROWCOUNT <> 0 
	BEGIN 
	 insert #DescrProdutosCestD4 
		
		exec LX_LJ_PAF_INFO_PRODUTO @CODIGOBARRA,@FILIAL
		
		     
		DELETE #ProdutosCestD4 WHERE CODIGO_BARRA = @CodigoBarra
		SET @CodigoBarra = ''
		
		SELECT TOP 1 @CodigoBarra = CODIGO_BARRA from #ProdutosCestD4
	END
	DROP TABLE #ProdutosCestD4
	--#5# - Fim

      INSERT INTO LJ_REG_PAF_ECF_TEMP 
                  (TIPO, 
                   REGISTRO, 
                   LIMITE, 
                   TERMINAL) 
      SELECT 8    as TIPO, 
             'D4' 
             + RIGHT(Replicate('0', 13) + Rtrim(Ltrim(ISNULL(SEQUENCIAL_PRE_VENDA, '0'))), 13) 
             + CONVERT(CHAR(8), DATA_HORA_ALTERACAO, 112) 
             + Replace( CONVERT(CHAR(8), DATA_HORA_ALTERACAO, 108), ':', '') 
             + CONVERT(VARCHAR, A.CODIGO_BARRA) 
             --+ REPLACE(CONVERT(CHAR(100), DESCR_PRODUTO, ' ', CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL_ORIGEM + SEQUENCIAL_PRE_VENDA + CONVERT(VARCHAR, DATA_HORA_ALTERACAO, 126) + CODIGO_BARRA + DESCR_PRODUTO + Cast(QTDE AS VARCHAR) + UNIDADE + Cast(PRECO_LIQUIDO AS VARCHAR) + Cast(DESCONTO_ITEM AS VARCHAR) + SITUACAO_TRIBUTARIA + Cast(ALIQUOTA AS VARCHAR) + Cast(CANCELADO AS VARCHAR) + Cast(DECIMAIS_QTDE AS VARCHAR) + Cast(DECIMAIS_PREC_UNIT AS VARCHAR) + TIPO_ALTERACAO) THEN ' ' ELSE '?' END)	--	#1# #5#
			 + REPLACE(CONVERT(CHAR(100), ISNULL(B.DESCRICAO, A.DESCR_PRODUTO)), ' ', CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL_ORIGEM + SEQUENCIAL_PRE_VENDA + CONVERT(VARCHAR, DATA_HORA_ALTERACAO, 126) + A.CODIGO_BARRA + DESCR_PRODUTO + Cast(QTDE AS VARCHAR) + UNIDADE + Cast(PRECO_LIQUIDO AS VARCHAR) + Cast(DESCONTO_ITEM AS VARCHAR) + SITUACAO_TRIBUTARIA + Cast(ALIQUOTA AS VARCHAR) + Cast(CANCELADO AS VARCHAR) + Cast(DECIMAIS_QTDE AS VARCHAR) + Cast(DECIMAIS_PREC_UNIT AS VARCHAR) + TIPO_ALTERACAO) THEN ' ' ELSE '?' END)	--	#1# #5#
             + RIGHT(Replicate('0', 7) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, QTDE * 100)), '0'), 7) 
             + CONVERT(CHAR(3), UNIDADE) 
             + RIGHT(Replicate('0', 8) + Replace(Cast(PRECO_LIQUIDO AS VARCHAR), '.', ''), 8)  + -- Wendel Crespigio - Conforme verificação com gerson a valor do preço liquido ja vem com o valor do desconto ou acrescimo deixei de fazer o calculo                                           
               Replace(RIGHT(Replicate('0', 8) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, CASE WHEN DESCONTO_ITEM > 0 THEN DESCONTO_ITEM ELSE 0 END * 100)), '0'), 8), '-', '') 
             + Replace(RIGHT(Replicate('0', 8) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, CASE WHEN DESCONTO_ITEM < 0 THEN Abs(DESCONTO_ITEM) ELSE 0 END * 100)), '0'), 8), '-', '') 
             + RIGHT(Replicate('0', 14) + ISNULL(CONVERT(VARCHAR, CONVERT(INT, (isnull(QTDE, 0) * isnull(PRECO_LIQUIDO, 0)) * 100)), '0'), 14) 
             + CONVERT(VARCHAR, SITUACAO_TRIBUTARIA) 
             + left(case when Len(rtrim(ltrim(ALIQUOTA))) = 1 then '0' + rtrim(ltrim(replace(convert(varchar,ALIQUOTA),'.',''))) + '00' else left(replace(CONVERT(VARCHAR, ALIQUOTA),'.','')+'0000', 4)end, 4) 
			 + CASE WHEN CANCELADO = 1 THEN 'S' ELSE 'N' END + CONVERT(VARCHAR, DECIMAIS_QTDE) 
             + CONVERT(VARCHAR, DECIMAIS_PREC_UNIT) 
             + CONVERT(VARCHAR, TIPO_ALTERACAO) AS REGISTRO, 
             200, 
             @TERMINAL 
      From   dbo.LOJA_PEDIDO_PRODUTO_LOG A
			 LEFT JOIN #DescrProdutosCestD4 B 
			 ON A.CODIGO_BARRA = B.CODIGO_BARRA  --#5#
      where  CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL 
            AND CONVERT(CHAR(8), DATA_HORA_ALTERACAO, 112) BETWEEN @STRDT_INICIAL AND @STRDT_FINAL; 

      

------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
print 'Registro Tipo H2' 

  /* 
   
  INSERT INTO LJ_REG_PAF_ECF_TEMP (TIPO, REGISTRO, LIMITE, TERMINAL )  
    SELECT  9 as TIPO, 
          'H2'                                                               + 
                Convert(varchar(14),ISNULL(CNPJ_CREDENCIADORA, ''))                +        
                Isnull(convert(varchar(20),ID_EQUIPAMENTO),'')                     + 
          MF_ADICIONAL                                                       + 
          RIGHT(REPLICATE(' ', 7) + RTRIM(LTRIM(ISNULL(TIPO_ECF, '0'))), 7)  + 
          RIGHT(REPLICATE(' ', 20) + RTRIM(LTRIM(ISNULL(MARCA, '0'))), 20)   + 
                RIGHT(REPLICATE(' ', 20) + RTRIM(LTRIM(ISNULL(MODELO, '0'))), 20)  + 
                --CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER + CODIGO_FILIAL +   CAST(ID_DOCUMENTO_ECF AS VARCHAR) +  ID_EQUIPAMENTO + MF_ADICIONAL +  ISNULL(MODELO, '') +CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR)+  CAST(ISNULL(CCF, 0) AS VARCHAR)+  CAST(ISNULL(COO, 0) AS VARCHAR)+  CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126)+  CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR)+  CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR)+  ISNULL(TIPO_DESCONTO_SUBTOTAL, '')+  CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR)+CAST(CANCELADO AS VARCHAR)+  CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR)+ISNULL(ORDEM_DESC_ACRESC, '')+  ISNULL(NOME_CLIENTE, '')+  ISNULL(CPF_CNPJ_CLIENTE, '')+CAST(ISNULL(GNF, 0) AS VARCHAR)+CAST(ISNULL(GRG, 0) AS VARCHAR)+  CAST(ISNULL(CDC, 0) AS VARCHAR)+DENOMINACAO_DOCUMENTO+  CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126)+ISNULL(CNPJ_CREDENCIADORA, '')+TIPO_ECF+  ISNULL(MARCA, '')+  CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR)+  ISNULL(TITULO, '')+  ISNULL(CNPJ_ARREDONDAR,''))  THEN '' ELSE '?' END +                 
          RIGHT(REPLICATE(' ', 9) + RTRIM(LTRIM(ISNULL(COO, '0'))), 9)       + 
          RIGHT(REPLICATE(' ', 9) + RTRIM(LTRIM(ISNULL(CCF, '0'))), 9)       + 
          RIGHT(REPLICATE('0', 13) +  REPLACE(CAST(SUM(isnull(VALOR_TROCO_TEF,0)) as VARCHAR),'.',''), 13) + 
          REPLACE(CONVERT(CHAR(8), DATA_HORA_EMISSAO , 112),'/','')          + 
          RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(isnull(CPF_CNPJ_CLIENTE,0) as VARCHAR),'.',''), 14) + 
                RIGHT(REPLICATE('0', 7) + RTRIM(LTRIM(ISNULL(TITULO, '0'))), 7)    + 
                ISNULL(@CNPJ_Arredondar,'') AS REGISTRO, 
          158,  
          @TERMINAL 
          From dbo.LJ_DOCUMENTO_ECF 
          Where CONVERT(Varchar,(DATA_HORA_EMISSAO), 112) Between @strDT_INICIAL And @strDT_FINAL 
          GROUP BY  Convert(varchar(14),ISNULL(CNPJ_CREDENCIADORA, '')),Convert(varchar(20),ID_EQUIPAMENTO),Convert(varchar(1),MF_ADICIONAL), 
          RIGHT(REPLICATE(' ', 7) + RTRIM(LTRIM(ISNULL(TIPO_ECF, '0'))), 7) ,RIGHT(REPLICATE(' ', 20) + RTRIM(LTRIM(ISNULL(MARCA, '0'))), 20) , 
                RIGHT(REPLICATE(' ', 20) + RTRIM(LTRIM(ISNULL(MODELO, '0'))), 20) , 
          RIGHT(REPLICATE(' ', 9) + RTRIM(LTRIM(ISNULL(COO, '0'))), 9) , 
          RIGHT(REPLICATE(' ', 9) + RTRIM(LTRIM(ISNULL(CCF, '0'))), 9) ,REPLACE(CONVERT(CHAR(8), DATA_HORA_EMISSAO , 112),'/','') , 
           RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(isnull(CPF_CNPJ_CLIENTE,0) as VARCHAR),'.',''), 14) , 
                RIGHT(REPLICATE('0', 7) + RTRIM(LTRIM(ISNULL(TITULO, '0'))), 7) ,LX_HASH,CODIGO_FILIAL,CAST(ID_DOCUMENTO_ECF AS VARCHAR),ID_EQUIPAMENTO , MF_ADICIONAL , 
          ISNULL(MODELO, '') ,CAST(ISNULL(NUMERO_USUARIO, 1) AS VARCHAR),  CAST(ISNULL(CCF, 0) AS VARCHAR), CAST(ISNULL(COO, 0) AS VARCHAR),   
          CONVERT(VARCHAR, DATA_HORA_EMISSAO, 126),  CAST(ISNULL(VALOR_SUBTOTAL, 0) AS VARCHAR), CAST(ISNULL(DESCONTO_SUBTOTAL, 0) AS VARCHAR), 
          ISNULL(TIPO_DESCONTO_SUBTOTAL, ''),CAST(ISNULL(VALOR_TOTAL_LIQ, 0) AS VARCHAR),CAST(CANCELADO AS VARCHAR),CAST(ISNULL(CANC_ACRESC_SUBTOTAL, 0) AS VARCHAR), 
          ISNULL(ORDEM_DESC_ACRESC, ''),ISNULL(NOME_CLIENTE, ''),ISNULL(CPF_CNPJ_CLIENTE, ''),CAST(ISNULL(GNF, 0) AS VARCHAR),CAST(ISNULL(GRG, 0) AS VARCHAR),CAST(ISNULL(CDC, 0) AS VARCHAR),DENOMINACAO_DOCUMENTO, 
          CONVERT(VARCHAR, ISNULL(DATA_FISCAL, 0), 126),ISNULL(CNPJ_CREDENCIADORA, ''),TIPO_ECF,ISNULL(MARCA, ''),  CAST(ISNULL(VALOR_TROCO_TEF, 0) AS VARCHAR),ISNULL(TITULO, ''),  ISNULL(CNPJ_ARREDONDAR,'') ; 
   
  */ 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- Geração do bloco R 
      EXEC LX_LJ_REG_ECF 
        @CODIGO_FILIAL, 
        @DT_INICIAL, 
        @DT_FINAL, 
        @BUILD_BUFFER, 
        @TERMINAL, 
        @ECF_PrinterID, 
        @PrinterName, 
        @ModeloECF, 
        @SerialNumber, 
        @Version_APP, 
        @Verifica_Reducao ,
		@LOCALUF

--- REGISTRO U1 --------------------------------------------------------------------------------------------------------------------------------------------------------- 
Declare @faltaLinha varchar(2)
SET @faltaLinha = ''

--VERIFICA SE AS LINHAS DA TABELA LJ_TABELAS_PAF SÃO CONFIAVEIS CASO NAO SEJA JA COLOCA ?
SELECT @faltaLinha = CASE WHEN LX_HASH = HASHBYTES('MD5', @BUILD_BUFFER +  CODIGO_FILIAL + 	NOME_TABELA + CAST(QTDE_LINHAS AS VARCHAR)) THEN '' ELSE  '?' END 
FROM LJ_TABELAS_PAF


--REGISTRO A2
IF @faltaLinha = ''
BEGIN 

if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'A2')
          begin 
			 SELECT @faltaLinha = case when ((select count(*) from LOJA_NOTA_FISCAL_PAGAMENTO WHERE CODIGO_FILIAL = @CODIGO_FILIAL ) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_NOTA_FISCAL_PAGAMENTO' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
			
			 IF @faltaLinha = ''
				BEGIN 
			        SELECT @faltaLinha = case when ((select count(*) from LOJA_NOTA_FISCAL WHERE CODIGO_FILIAL = @CODIGO_FILIAL  ) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_NOTA_FISCAL' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
			    end 
			  
			 IF @faltaLinha = ''
             BEGIN  	 
			   SELECT @faltaLinha = case when ((select count(*) from LJ_DOCUMENTO_ECF WHERE CODIGO_FILIAL = @CODIGO_FILIAL ) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_DOCUMENTO_ECF' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
             END  
         END 
-----------------------------------------------------------------------------------------------
--REGISTRO P2

if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'P2')
		  BEGIN 
				IF @faltaLinha = ''
				BEGIN 
					SELECT @faltaLinha = case when ((select count(*) from PRODUTOS) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'PRODUTOS' )) THEN '?' ELSE '' END 
                END
				
				IF @faltaLinha = ''
				BEGIN  
					SELECT @faltaLinha = case when ((select count(*) from CLASSIF_FISCAL_IMPOSTO WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'CLASSIF_FISCAL_IMPOSTO' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END	--	#3#
				END 

				IF @faltaLinha = ''
				BEGIN 
					SELECT @faltaLinha = case when ((select count(*) from PRODUTO_CORES) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'PRODUTO_CORES' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
                END 

				IF @faltaLinha = ''
				BEGIN 
					SELECT @faltaLinha = case when ((select count(*) from PRODUTOS_PRECOS) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'PRODUTOS_PRECOS' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
				END 

				IF @faltaLinha = ''
				BEGIN 
					SELECT @faltaLinha = case when ((select count(*) from PRODUTOS_PRECO_COR) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'PRODUTOS_PRECO_COR' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
				END 

				IF @faltaLinha = ''
				BEGIN 
					SELECT @faltaLinha = case when ((select count(*) from PRODUTOS_PRECO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'PRODUTOS_PRECO_FILIAL' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
				END
		  END 
--FINAL P2
-----------------------------------------------------------------------------------------------
--REGISTRO E2

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'E2')
		  BEGIN 
		   SELECT @faltaLinha = case when ((select count(*) from LJ_ESTOQUE_PAF_ECF WHERE CODIGO_FILIAL = @CODIGO_FILIAL ) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_ESTOQUE_PAF_ECF' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
end 
-----------------------------------------------------------------------------------------------
--REGISTRO E3

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'E3')
		  BEGIN 
		   SELECT @faltaLinha = case when ((select count(*) from LJ_ESTOQUE_PAF_ECF_CUPOM WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_ESTOQUE_PAF_ECF_CUPOM' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
end 

-----------------------------------------------------------------------------------------------
--REGISTRO D2

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'D2')
		  BEGIN 
		   SELECT @faltaLinha = case when ((select count(*) from LOJA_PEDIDO WHERE CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_PEDIDO' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
end 

-----------------------------------------------------------------------------------------------
--REGISTRO D3

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'D3')
		  BEGIN 
		   SELECT @faltaLinha = case when ((select count(*) from LOJA_PEDIDO_PRODUTO WHERE CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL ) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_PEDIDO_PRODUTO' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
end 

-----------------------------------------------------------------------------------------------
--REGISTRO D4

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,2) = 'D4')
		  BEGIN 
		   SELECT @faltaLinha = case when ((select count(*) from LOJA_PEDIDO_PRODUTO_LOG  WHERE CODIGO_FILIAL_ORIGEM = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_PEDIDO_PRODUTO_LOG' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END
End 		   


--REGISTROS R1
-----------------------------------------------------------------------------------------------
IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R01')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LOJA_IMPRESSORAS_FISCAIS WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_IMPRESSORAS_FISCAIS'  AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 

-----------------------------------------------------------------------------------------------
--REGISTRO R2

IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R02')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LOJA_CONTROLE_FISCAL WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LOJA_CONTROLE_FISCAL' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 


-----------------------------------------------------------------------------------------------
--REGISTRO R3
IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R03' )
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LJ_ECF_RZ_DETALHE WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_ECF_RZ_DETALHE' AND CODIGO_FILIAL = @CODIGO_FILIAL )) THEN '?' ELSE '' END 
		  END 
END 


-----------------------------------------------------------------------------------------------
--REGISTRO R4
IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R04')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LJ_DOCUMENTO_ECF WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_DOCUMENTO_ECF' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 

-----------------------------------------------------------------------------------------------
--REGISTRO R5
IF @faltaLinha = ''
BEGIN       
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R05')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LJ_ECF_ITEM WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_ECF_ITEM' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 

-----------------------------------------------------------------------------------------------
--REGISTRO R6
IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R06')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LJ_DOCUMENTO_ECF WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_DOCUMENTO_ECF' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 


-----------------------------------------------------------------------------------------------
--REGISTRO R7
IF @faltaLinha = ''
BEGIN 
if exists (select * from LJ_REG_PAF_ECF_TEMP where left(registro,3) = 'R07')
		  BEGIN 
			SELECT @faltaLinha = case when ((select count(*) from LJ_ECF_PAGAMENTO WHERE CODIGO_FILIAL = @CODIGO_FILIAL) <> (SELECT QTDE_LINHAS FROM LJ_TABELAS_PAF WHERE NOME_TABELA = 'LJ_ECF_PAGAMENTO' AND CODIGO_FILIAL = @CODIGO_FILIAL)) THEN '?' ELSE '' END 
		  END 
END 
--------------------------------------------------------------------------------------------------------------------------------------------------
--#10# - Início
--REGISTRO J1 
PRINT 'J1' 
	
INSERT INTO LJ_REG_PAF_ECF_TEMP 
			(TIPO, 
			REGISTRO, 
				LIMITE, 
			TERMINAL) 
SELECT 28    as TIPO, 
		'J1' 
		+ REPLICATE('0', 14 - LEN(LTRIM(RTRIM(F.CGC_CPF)))) + CAST(LTRIM(RTRIM(F.CGC_CPF)) AS varchar)
		+ Replace(CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112), '/', '')
		+ REPLICATE('0', 14 - LEN(REPLACE(L.VALOR_TOTAL_ITENS, '.', ''))) + CAST(REPLACE(L.VALOR_TOTAL_ITENS, '.', '') AS varchar) 
		+ REPLICATE('0', 13 - LEN(REPLACE(L.DESCONTO, '.', ''))) + CAST(REPLACE(L.DESCONTO, '.', '') AS varchar)
		+ 'V' 
		+ REPLICATE('0', 13 - LEN(REPLACE(L.ENCARGO, '.', ''))) + CAST(REPLACE(L.ENCARGO, '.', '') AS varchar) 
		+ 'V' 
		+ REPLICATE('0', 14 - LEN(REPLACE(L.VALOR_TOTAL, '.', ''))) + CAST(REPLACE(L.VALOR_TOTAL, '.', '') AS varchar)
		+ CASE WHEN L.NOTA_CANCELADA = 1 THEN 'S' ELSE 'N' END
		+ REPLICATE('0', 13) 
		+ CASE WHEN L.DESCONTO > 0 AND L.ENCARGO = 0 THEN 'D' --verificar item 12
			WHEN L.DESCONTO = 0 AND L.ENCARGO > 0 THEN 'A'
			ELSE ' ' END  
		+ REPLICATE(' ', 40 - LEN(LTRIM(RTRIM(ISNULL(C.CLIENTE_VAREJO, ''))))) + CAST(LTRIM(RTRIM(ISNULL(C.CLIENTE_VAREJO, ''))) AS varchar)
		+ REPLICATE('0', 14 - LEN(LTRIM(RTRIM(ISNULL(C.CPF_CGC, 0))))) + CAST(LTRIM(RTRIM(ISNULL(C.CPF_CGC, 0))) AS varchar)
		+ REPLICATE('0', 10 - LEN(CAST(LTRIM(RTRIM(L.NF_NUMERO)) AS NUMERIC))) + CAST(CAST(LTRIM(RTRIM(L.NF_NUMERO)) AS NUMERIC) AS VARCHAR)
		+ SUBSTRING(L.SERIE_NF, 1, 3)  
		+ REPLICATE('0', 44 -LEN(ISNULL(SUBSTRING(L.CHAVE_NFE, 1, 44), REPLICATE('0', 44)))) + (ISNULL(SUBSTRING(L.CHAVE_NFE, 1, 44), REPLICATE('0', 44)))
		+ CASE WHEN E.NUMERO_MODELO_FISCAL = '55' THEN '2' ELSE '3' END AS REGISTRO,
		207, 
		@TERMINAL
FROM LOJA_NOTA_FISCAL L
INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
INNER JOIN LOJAS_VAREJO I ON I.CODIGO_FILIAL = L.CODIGO_FILIAL 
INNER JOIN FILIAIS F ON F.FILIAL = I.FILIAL 
LEFT JOIN CLIENTES_VAREJO C ON C.CODIGO_CLIENTE = L.CODIGO_CLIENTE -- #12#
WHERE E.NUMERO_MODELO_FISCAL IN ('55', '65')
AND L.RECEBIMENTO = 0 --NOTA DE SAÍDA
AND L.CODIGO_FILIAL = @CODIGO_FILIAL
AND (L.STATUS_NFE IN (5,49) OR (L.TIPO_EMISSAO_NFE = 9 AND STATUS_NFE = 1 and LOG_STATUS_NFE = 0))  -- #12#
AND CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @STRDT_INICIAL AND @STRDT_FINAL
ORDER BY L.DATA_HORA_EMISSAO, L.NF_NUMERO;

--VERIFICACAO DA ALTERAÇÃO NO BANCO DE DADOS
IF @faltaLinha = ''
	BEGIN
		--VERIFICA AS SÉRIES UTILIZADAS EM NOTAS FISCAIS NA LOJA
		CREATE TABLE #TEMP_SERIES (ID INT, SERIE_NF CHAR(3))

		INSERT INTO #TEMP_SERIES(SERIE_NF, ID)
				(SELECT X.SERIE_NF, (ROW_NUMBER() over (order by X.SERIE_NF)) AS ID
					FROM 
					(SELECT DISTINCT L.SERIE_NF 
						FROM LOJA_NOTA_FISCAL L
						WHERE CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL
						AND L.CODIGO_FILIAL = @CODIGO_FILIAL) X)

		DECLARE @I INT,
			@TOTAL_SERIE INT,
			@J INT, 
			@Z INT,
			@TOTAL_NF INT,
			@RESULT INT,
			@SEQUENCIAL VARCHAR(12),
			@MAX_NF VARCHAR(12),
			@bContinue bit 
	
			SET @bContinue = 1
			SET @RESULT = 0
			SET @Z = 2
			SET @J = 1
			SET @I = 1
			SET @TOTAL_SERIE = (SELECT COUNT(*) FROM  #TEMP_SERIES)

		/***LOOP QUE VERIFICA SE FALTA ALGUMA NF EMITIDA***/
		WHILE ((@I <= @TOTAL_SERIE) AND @bContinue = 1)
			BEGIN
				/***TABELA TEMPORARIA QUE ARMAZENA TODAS AS NFS EMITIDAS PARA A LOJA - FILTRO POR SÉRIE***/
				CREATE TABLE #TEMP_SERIE_NF(ID INT, SERIE_NF CHAR(3), NF_NUMERO VARCHAR(12))

				INSERT INTO #TEMP_SERIE_NF(ID, SERIE_NF, NF_NUMERO)
				(SELECT DISTINCT (ROW_NUMBER() over (order by L.SERIE_NF)) AS ID,
							L.SERIE_NF, 
							L.NF_NUMERO
					FROM LOJA_NOTA_FISCAL L
					WHERE CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL
					AND L.CODIGO_FILIAL = @CODIGO_FILIAL
					AND L.SERIE_NF = (SELECT SERIE_NF FROM #TEMP_SERIES WHERE ID = @I) )


				/***TABELA TEMPORARIA DO SEQUENCIAL DAS SERIES***/
				CREATE TABLE #TEMP_SERIES_FILIAL (SERIES CHAR(3), SEQUENCIAL VARCHAR(12), FILIAL VARCHAR(30), CODIGO_FILIAL VARCHAR(6))
				INSERT INTO #TEMP_SERIES_FILIAL (SERIES, SEQUENCIAL, FILIAL, CODIGO_FILIAL)
					(SELECT F.SERIE_NF, 
						F.SEQUENCIAL, 
						F.FILIAL, 
						L.CODIGO_FILIAL
					FROM DBO.FATURAMENTO_SEQUENCIAIS F
					INNER JOIN DBO.LOJAS_VAREJO L ON L.FILIAL = F.FILIAL 
					WHERE L.CODIGO_FILIAL = @CODIGO_FILIAL
					AND F.SERIE_NF = (SELECT SERIE_NF FROM #TEMP_SERIES WHERE ID = @I) )

				SET @SEQUENCIAL = (SELECT SEQUENCIAL FROM #TEMP_SERIES_FILIAL)
				SET @MAX_NF = (SELECT MAX(SERIE_NF) FROM #TEMP_SERIE_NF)	
				SET @TOTAL_NF = (SELECT COUNT(*) FROM #TEMP_SERIE_NF)

				IF @SEQUENCIAL <> @MAX_NF
					BEGIN
						SET @bContinue = 0
						SET @faltaLinha = '?'
					END

				--LOOP QUE VERIFICA SE ESTÁ FALTANDO ALGUMA SÉRIE ENTRE AS NOTAS EMITIDAS
				WHILE ((@J <= @TOTAL_NF) and @bContinue = 1)
					BEGIN
					
						(SELECT @RESULT = SUM(K.NF_NUMERO_Z - K.NF_NUMERO_J) 
							FROM
							(SELECT CONVERT ( INT, F.NF_NUMERO) AS NF_NUMERO_J,
								(SELECT CONVERT(INT, F.NF_NUMERO)
									FROM #TEMP_SERIE_NF F 
									WHERE ID = @Z) AS NF_NUMERO_Z
									FROM #TEMP_SERIE_NF F 
							WHERE ID = @J) K)
					
						IF @RESULT > 1
							BEGIN
								SET @bContinue = 0
								SET @faltaLinha = '?'
							END
						
						SET @J = @J+1
						SET @Z = @Z+1
					
					END

			SET @I = @I+1
			
		END
	END

--#10# - Fim
--------------------------------------------------------------------------------------------------------------------------------------------------
--#10# - Início
--REGISTRO J2 

PRINT 'J2'


BEGIN
	/**********************************************************/
	/**CRIAÇÃO DA TABELA TEMPORÁRIA COM O PRÉ REGISTRO DA J2***/

	CREATE TABLE #TEMP_J2(TIPO NUMERIC, 
						NOME_REGISTRO VARCHAR(2),
						TIPO_NOTA VARCHAR(3),
						CNPJ_EMISSOR VARCHAR(14),
						DATA_EMISSAO_DOC VARCHAR(8),
						NUM_ITEM VARCHAR(3),
						COD_PRODUTO VARCHAR(14),
						REFERENCIA VARCHAR(12), 
						COR_PRODUTO VARCHAR(12),
						TAMANHO_PRODUTO VARCHAR(5),
						DESC_PRODUTO VARCHAR(100),
						QTDADE_ITEM VARCHAR(7),
						UNIDADE VARCHAR(3),
						VALOR_UNITARIO VARCHAR(8),
						DESCONTO VARCHAR(8), 
						ACRESCIMO VARCHAR(8),
						VALOR_TOTAL_LIQUIDO VARCHAR(14),
						TAXA_IMPOSTO NUMERIC(10, 2),
						TRIBUT_ICMS NUMERIC,
						NOTA_CANCELADA BIT, 
						TOTALIZADOR VARCHAR(7),
						CASAS_DECIMAIS_QTDADE CHAR(1),
						CADAS_DECIMAIS_VALOR_UNITARIO CHAR(1),
						NUMERO_NF VARCHAR(10), 
						SERIE_NF VARCHAR(3),
						CHAVE_NF VARCHAR(44),
						TIPO_DOCUMENTO CHAR(2), --#15#
						NUM_LINHA NUMERIC, 
						TERMINAL VARCHAR(3))

	INSERT INTO  #TEMP_J2 (TIPO , 
						NOME_REGISTRO ,
						TIPO_NOTA ,
						CNPJ_EMISSOR ,
						DATA_EMISSAO_DOC ,
						NUM_ITEM ,
						COD_PRODUTO ,
						REFERENCIA, 
						COR_PRODUTO,
						TAMANHO_PRODUTO,
						DESC_PRODUTO ,
						QTDADE_ITEM ,
						UNIDADE ,
						VALOR_UNITARIO ,
						DESCONTO , 
						ACRESCIMO ,
						VALOR_TOTAL_LIQUIDO ,
						TAXA_IMPOSTO ,
						I.TRIBUT_ICMS,
						NOTA_CANCELADA,
						TOTALIZADOR ,
						CASAS_DECIMAIS_QTDADE ,
						CADAS_DECIMAIS_VALOR_UNITARIO ,
						NUMERO_NF , 
						SERIE_NF ,
						CHAVE_NF ,
						TIPO_DOCUMENTO , --#15#
						NUM_LINHA , 
						TERMINAL )


				(SELECT 29    as TIPO,
					'J2' AS NOME_REGISTRO,
					CASE WHEN E.NUMERO_MODELO_FISCAL = '55' THEN 'COO' ELSE 'NF' END AS TIPO_NOTA,
					REPLICATE('0', 14 - LEN(LTRIM(RTRIM(F.CGC_CPF)))) + CAST(LTRIM(RTRIM(F.CGC_CPF)) AS varchar) AS CNPJ_EMISSOR,
					REPLACE(CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112), '/', '') AS DATA_EMISSAO_DOC,
					SUBSTRING(I.ITEM_IMPRESSAO,2, 4) AS NUM_ITEM,
					SUBSTRING(REPLACE(I.CODIGO_ITEM, '.', ''), 1, 14) AS COD_PRODUTO,
					LTRIM(RTRIM(REFERENCIA)) AS REFERENCIA, 
					SUBSTRING(REFERENCIA_ITEM,1, 5) AS COR_PRODUTO,
					LTRIM(RTRIM(SUBSTRING(REFERENCIA_ITEM,6, 10))) AS TAMANHO_PRODUTO, 
					SUBSTRING(LTRIM(RTRIM(I.DESCRICAO_ITEM)), 1, 100) + REPLICATE(' ', 100 - LEN(LTRIM(RTRIM(I.DESCRICAO_ITEM)))) AS DESC_PRODUTO,
					REPLICATE('0', 7 - LEN(REPLACE(I.QTDE_ITEM, '.', ''))) + CAST(REPLACE(I.QTDE_ITEM, '.', '') AS varchar) AS QTDADE_ITEM,
					SUBSTRING(I.UNIDADE,1, 3) AS UNIDADE,
					REPLICATE('0', 8 - LEN( REPLACE(CAST(I.PRECO_UNITARIO AS NUMERIC(10,2)),'.', ''))) + CAST(REPLACE(CAST(I.PRECO_UNITARIO AS NUMERIC(10,2)), '.', '') AS varchar) AS VALOR_UNITARIO,
					REPLICATE('0', 8 - LEN(REPLACE(I.VALOR_DESCONTOS, '.', ''))) + CAST(REPLACE(I.VALOR_DESCONTOS, '.', '') AS varchar) AS DESCONTO,
					REPLICATE('0', 8 - LEN(REPLACE(I.VALOR_ENCARGOS, '.', ''))) + CAST(REPLACE(I.VALOR_ENCARGOS, '.', '') AS VARCHAR) AS ACRESCIMO,
					REPLICATE('0', 14 - LEN(REPLACE(I.VALOR_ITEM, '.', ''))) + CAST(REPLACE(I.VALOR_ITEM, '.', '') AS VARCHAR) AS VALOR_TOTAL_LIQUIDO,
					H.TAXA_IMPOSTO,
					I.TRIBUT_ICMS,
					L.NOTA_CANCELADA, 
					CASE WHEN I.TRIBUT_ICMS = '30' AND L.NOTA_CANCELADA = 0 THEN 'I1'+ REPLICATE(' ', 7 - LEN('I1'))
						 WHEN I.TRIBUT_ICMS = '40' AND L.NOTA_CANCELADA = 0 THEN 'I1'+ REPLICATE(' ', 7 - LEN('I1'))
						 WHEN I.TRIBUT_ICMS = '41' AND L.NOTA_CANCELADA = 0 THEN 'N1' + REPLICATE(' ', 7 - LEN('N1'))
						 WHEN I.TRIBUT_ICMS = '50' AND L.NOTA_CANCELADA = 0 THEN 'N1' + REPLICATE(' ', 7 - LEN('N1'))
						 WHEN I.TRIBUT_ICMS = '60' AND L.NOTA_CANCELADA = 0 THEN 'F1' + REPLICATE(' ', 7 - LEN('F1'))
						 WHEN I.TRIBUT_ICMS = '103' AND L.NOTA_CANCELADA = 0 THEN 'I1'+ REPLICATE(' ', 7 - LEN('I1'))
						 WHEN I.TRIBUT_ICMS = '203' AND L.NOTA_CANCELADA = 0 THEN 'I1'+ REPLICATE(' ', 7 - LEN('I1'))
						 WHEN I.TRIBUT_ICMS = '300' AND L.NOTA_CANCELADA = 0 THEN 'I1'+ REPLICATE(' ', 7 - LEN('I1'))
						 WHEN I.TRIBUT_ICMS = '400' AND L.NOTA_CANCELADA = 0 THEN 'N1' + REPLICATE(' ', 7 - LEN('N1'))
						 WHEN I.TRIBUT_ICMS = '500' AND L.NOTA_CANCELADA = 0 THEN 'F1' + REPLICATE(' ', 7 - LEN('F1'))
						 WHEN I.TRIBUT_ICMS = '00'  AND L.NOTA_CANCELADA = 0  AND H.TAXA_IMPOSTO = '0.00' THEN '01T0000'
						 WHEN L.NOTA_CANCELADA = 1  THEN 'Can-T' + REPLICATE(' ', 7 - LEN('Can-T'))
					ELSE '' END AS TOTALIZADOR,
					'3' AS CASAS_DECIMAIS_QTDADE,
					'2' AS CADAS_DECIMAIS_VALOR_UNITARIO,
					REPLICATE('0', 10 - LEN(CAST(LTRIM(RTRIM(L.NF_NUMERO)) AS NUMERIC))) + CAST(CAST(LTRIM(RTRIM(L.NF_NUMERO)) AS NUMERIC) AS VARCHAR) AS NUMERO_NF,
					SUBSTRING(L.SERIE_NF, 1, 3) AS SERIE_NF,
					REPLICATE('0', 44 -LEN(ISNULL(SUBSTRING(L.CHAVE_NFE, 1, 44), REPLICATE('0', 44)))) + (ISNULL(SUBSTRING(L.CHAVE_NFE, 1, 44), REPLICATE('0', 44))) AS CHAVE_NF,
					CASE WHEN E.NUMERO_MODELO_FISCAL = '55' THEN '02' ELSE '03' END AS TIPO_DOCUMENTO, --#15#
					256 AS NUM_LINHA,
					@TERMINAL AS TERMINAL
					
				FROM LOJA_VENDA O
				INNER JOIN LOJA_VENDA_PGTO P ON P.CODIGO_FILIAL = O.CODIGO_FILIAL AND P.LANCAMENTO_CAIXA = O.LANCAMENTO_CAIXA AND P.TERMINAL = O.TERMINAL
				RIGHT JOIN LOJA_NOTA_FISCAL L ON L.NF_NUMERO = P.NUMERO_FISCAL_VENDA AND L.CODIGO_FILIAL = O.CODIGO_FILIAL AND L.CODIGO_CLIENTE = O.CODIGO_CLIENTE AND L.SERIE_NF = P.SERIE_NF_SAIDA 
				INNER JOIN LOJA_NOTA_FISCAL_ITEM I ON I.NF_NUMERO = L.NF_NUMERO AND I.SERIE_NF = L.SERIE_NF AND I.CODIGO_FILIAL = L.CODIGO_FILIAL
				INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
				INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
				INNER JOIN LOJAS_VAREJO G ON G.CODIGO_FILIAL = L.CODIGO_FILIAL 
				INNER JOIN FILIAIS F ON F.FILIAL = G.FILIAL
				LEFT JOIN CLIENTES_VAREJO C ON C.CODIGO_CLIENTE = L.CODIGO_CLIENTE --#12#
				INNER JOIN LOJA_NOTA_FISCAL_IMPOSTO H ON H.CODIGO_FILIAL = L.CODIGO_FILIAL AND H.SERIE_NF = L.SERIE_NF AND H.NF_NUMERO = L.NF_NUMERO
				WHERE E.NUMERO_MODELO_FISCAL IN ('55', '65')
				AND L.RECEBIMENTO = 0 --NOTA DE SAÍDA
				AND L.CODIGO_FILIAL = @CODIGO_FILIAL
				--AND L.STATUS_NFE IN (5,49)
				AND (L.STATUS_NFE IN (5,49) OR (L.TIPO_EMISSAO_NFE = 9 AND STATUS_NFE = 1 and LOG_STATUS_NFE = 0)) --#12#
				AND L.CODIGO_FILIAL = @CODIGO_FILIAL
				AND CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @STRDT_INICIAL AND @STRDT_FINAL)
		
	/***********************************************************************/
	/**CRIAÇÃO DE TABELA TEMPORÁRIA PARA ARMAZENAR OS TOTALIZADORES DA ECF**/

	CREATE TABLE #TABLE_TOTALIZADOR_TEMP(TOTALIZADOR_PARCIAL VARCHAR(7), ALIQUOTA NUMERIC(10,2), SEQUENCIAL NUMERIC, TIPO_NOTA VARCHAR(3), EXCLUIR CHAR(1))

	INSERT INTO  #TABLE_TOTALIZADOR_TEMP(TOTALIZADOR_PARCIAL, ALIQUOTA, SEQUENCIAL, TIPO_NOTA, EXCLUIR)
			(SELECT DISTINCT LEGENDA_TARIFA AS TOTALIZADOR_PACIAL, 
					CAST(SUBSTRING(LEGENDA_TARIFA, 4, 2) + '.' + SUBSTRING(LEGENDA_TARIFA, 6, 2) AS NUMERIC(4,2)) AS ALIQUOTA,
					(ROW_NUMBER() over (order by LEGENDA_TARIFA)) AS SEQUENCIAL,
					'COO' AS TIPO_DOCUMENTO,
					'N'
					FROM LOJA_CONTROLE_FISCAL_TARIFAS
						WHERE ID_EQUIPAMENTO = @SerialNumber	
						AND LEN(LTRIM(RTRIM(LEGENDA_TARIFA))) >3 
						AND DATA_FISCAL = (SELECT MAX(DATA_FISCAL) FROM LOJA_CONTROLE_FISCAL WHERE ID_EQUIPAMENTO = @SerialNumber) 
				)

    /*****************************************************************************************************/
	/**VERIFICA SE HÁ ALIQUOTA COM MAIS DE 1 TOTALIZADOR E CASO HAJA, IDENTIFICA ESSA INFORMAÇÃO NA TEMP**/

	CREATE TABLE #TEMP_PESQUISA(TOTALIZADOR_PARCIAL VARCHAR(7), ALIQUOTA NUMERIC(10,2), CODIGO VARCHAR(2), SEQUENCIAL NUMERIC, TIPO_NOTA VARCHAR(3), EXCLUIR CHAR(1))

	INSERT INTO #TEMP_PESQUISA (TOTALIZADOR_PARCIAL, ALIQUOTA, CODIGO, SEQUENCIAL, TIPO_NOTA, EXCLUIR)
				(SELECT T.TOTALIZADOR_PARCIAL,
						T.ALIQUOTA, 
						SUBSTRING(T.TOTALIZADOR_PARCIAL, 1, 2),
						T.SEQUENCIAL, 
						T.TIPO_NOTA, 
						T.EXCLUIR
					FROM #TABLE_TOTALIZADOR_TEMP T
					 WHERE T.ALIQUOTA IN (SELECT ALIQUOTA
											FROM  #TABLE_TOTALIZADOR_TEMP
											GROUP BY ALIQUOTA
											HAVING COUNT(ALIQUOTA) > 1))

	
	SET @COUNT = (SELECT COUNT(SEQUENCIAL) FROM #TEMP_PESQUISA WHERE SEQUENCIAL = (SELECT MAX(SEQUENCIAL) FROM #TEMP_PESQUISA))

	IF @COUNT <> 0
		BEGIN
			UPDATE  #TABLE_TOTALIZADOR_TEMP SET EXCLUIR = 'S' WHERE SEQUENCIAL IN (SELECT SEQUENCIAL FROM #TEMP_PESQUISA WHERE SEQUENCIAL IN (SELECT MAX(SEQUENCIAL) FROM #TEMP_PESQUISA GROUP BY ALIQUOTA))
		END

	/**********************************************************************/
	/**CRIAÇÃO DA TABELA TEMPORÁRIA QUE CONTÉM AS ALIQUOTAS DA NF-E/NFC-E**/

	CREATE TABLE #TEMP_ALIQUOTA_NF(ALIQUOTA NUMERIC(10,2))

	INSERT INTO #TEMP_ALIQUOTA_NF(ALIQUOTA)
			(SELECT DISTINCT	TAXA_IMPOSTO 
				FROM #TEMP_J2 
				WHERE TIPO_NOTA = 'NF'
				AND TOTALIZADOR = '')


    /******************************************************************************/
	/**INSERÇÃO DAS INFORMAÇÕES DA ALIQUOTA DA NF NA TEMP #TABLE_TOTALIZADOR_TEMP**/
	
	 SET @COUNT_LINE = (SELECT COUNT(*) FROM #TABLE_TOTALIZADOR_TEMP)

	INSERT INTO  #TABLE_TOTALIZADOR_TEMP(TOTALIZADOR_PARCIAL, ALIQUOTA, SEQUENCIAL, TIPO_NOTA, EXCLUIR)
		 (SELECT CASE WHEN (SELECT TOTALIZADOR_PARCIAL FROM #TABLE_TOTALIZADOR_TEMP P WHERE P.ALIQUOTA = F.ALIQUOTA AND EXCLUIR = 'N') IS NULL THEN '01T' + REPLICATE('0', 4 - LEN(LTRIM(RTRIM(REPLACE(CONVERT(VARCHAR, F.ALIQUOTA), '.', ''))))) + CAST(LTRIM(RTRIM(REPLACE(CONVERT(VARCHAR, F.ALIQUOTA), '.', ''))) AS varchar)
				ELSE REPLICATE('0', 2 -LEN(LTRIM(RTRIM(CAST((CAST(SUBSTRING((SELECT TOTALIZADOR_PARCIAL FROM #TABLE_TOTALIZADOR_TEMP P WHERE P.ALIQUOTA = F.ALIQUOTA AND EXCLUIR = 'N'), 1, 2) AS NUMERIC) + 1) AS VARCHAR))))) +
						(LTRIM(RTRIM(CAST((CAST(SUBSTRING((SELECT TOTALIZADOR_PARCIAL FROM #TABLE_TOTALIZADOR_TEMP P WHERE P.ALIQUOTA = F.ALIQUOTA AND EXCLUIR = 'N'), 1, 2) AS NUMERIC) + 1) AS VARCHAR)))) + 'T' +
						REPLICATE('0', 4 - LEN(LTRIM(RTRIM(REPLACE(CONVERT(VARCHAR, F.ALIQUOTA), '.', ''))))) + CAST(LTRIM(RTRIM(REPLACE(CONVERT(VARCHAR, F.ALIQUOTA), '.', ''))) AS varchar)
				END AS TOTALIZADOR, 
				ALIQUOTA,
				@COUNT_LINE + (ROW_NUMBER() over (order by f.aliquota)) AS SEQUENCIAL,
				'NF' AS TIPO_NOTA, 
				'N' AS EXCLUIR
			FROM #TEMP_ALIQUOTA_NF F)
 
	 --DELETO O TOTALIZADOR QUE NÃO SERÁ MAIS UTILIZADO
	 DELETE FROM #TABLE_TOTALIZADOR_TEMP WHERE EXCLUIR = 'S'


	/************************************************************************************************************/
	/**FAZER O JOIN ENTRE A TABELA #TEMP_J2  E A #TABLE_TOTALIZADOR_TEMP E APÓS, GRAVAR NA LJ_REG_PAF_ECF_TEMP **/
	INSERT INTO LJ_REG_PAF_ECF_TEMP 
				(TIPO, 
				REGISTRO, 
					LIMITE, 
				TERMINAL) 

	 SELECT J.TIPO,
			J.NOME_REGISTRO
			+ J.CNPJ_EMISSOR
			+ J.DATA_EMISSAO_DOC
			+ J.NUM_ITEM
			--+ CASE WHEN S.CODIGO_BARRA IS NULL THEN J.COD_PRODUTO #13#
			+ CASE WHEN S.CODIGO_BARRA COLLATE DATABASE_DEFAULT  IS NULL THEN J.COD_PRODUTO COLLATE DATABASE_DEFAULT --#13#
				ELSE LEFT(Rtrim(Replace(Replace(Replace(ISNULL(S.CODIGO_BARRA, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ',14), 14)--#11#		
			END
			+ LEFT(Rtrim(Replace(Replace(Replace(ISNULL(J.DESC_PRODUTO, ''), '.', ''), '-', ''), '/', '')) + Replicate(' ',100), 100)
			+ J.QTDADE_ITEM
			+ J.UNIDADE
			+ J.VALOR_UNITARIO
			+ J.DESCONTO
			+ J.ACRESCIMO
			+ J.VALOR_TOTAL_LIQUIDO
			+ CASE	WHEN J.TOTALIZADOR = '' AND P.ALIQUOTA IS NOT NULL THEN P.TOTALIZADOR_PARCIAL
					WHEN J.TOTALIZADOR <> '' THEN J.TOTALIZADOR
					WHEN J.TIPO_NOTA = 'COO' AND P.ALIQUOTA IS NULL THEN '01T' + REPLICATE('0', 4 - LEN(RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(REPLACE(J.TAXA_IMPOSTO, '.',''))), 1, 4))))) + RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(REPLACE(J.TAXA_IMPOSTO, '.',''))), 1, 4)))
				END
			+ J.CASAS_DECIMAIS_QTDADE
			+ J.CADAS_DECIMAIS_VALOR_UNITARIO
			+ J.NUMERO_NF
			+ J.SERIE_NF
			+ J.CHAVE_NF
			+ J.TIPO_DOCUMENTO AS REGISTRO, 
			J.NUM_LINHA,
			J.TERMINAL
	 FROM #TEMP_J2 J
	LEFT JOIN #TABLE_TOTALIZADOR_TEMP P ON P.ALIQUOTA = J.TAXA_IMPOSTO AND P.TIPO_NOTA = J.TIPO_NOTA
	LEFT JOIN #PRODUTOSP2 S ON LTRIM(RTRIM(S.PRODUTO)) COLLATE DATABASE_DEFAULT  = RTRIM(LTRIM(J.REFERENCIA)) COLLATE DATABASE_DEFAULT 
	AND S.COR_PRODUTO COLLATE DATABASE_DEFAULT = J.COR_PRODUTO COLLATE DATABASE_DEFAULT 
	AND S.GRADE COLLATE DATABASE_DEFAULT = J.TAMANHO_PRODUTO COLLATE DATABASE_DEFAULT 
	ORDER BY J.DATA_EMISSAO_DOC, J.NUMERO_NF;

	/********************************/
	/**DROPO AS TABELAS TEMPORÁRIAS**/
	DROP TABLE  #TEMP_J2 
	DROP TABLE  #TABLE_TOTALIZADOR_TEMP
	DROP TABLE  #TEMP_PESQUISA
	DROP TABLE  #TEMP_ALIQUOTA_NF

END

--VERIFICA SE HOUVE EXCLUSÃO DE INFORMAÇÃO NO BANCO DE DADOS
IF @faltaLinha = ''
	BEGIN
		DECLARE @I2 INT,
				@TOTAL_NFE2 INT,
				@J2 INT,
				@Z2 INT,
				@TOTAL_ITENS2 INT,
				@bContinue2 BIT,
				@DIF AS INT

				SET @I2 = 1
				SET @bContinue2 = 1
				SET @J2 = 1
				SET @Z2 = 2
				SET @DIF = 0

		--TEMPORARIA DAS NF'S
		CREATE TABLE #NFE(CODIGO_FILIAL VARCHAR(6), NF_NUMERO VARCHAR(12), SERIE_NF VARCHAR(3), QTDE_TOTAL INT, ID INT)
		INSERT INTO #NFE (CODIGO_FILIAL, NF_NUMERO, SERIE_NF, QTDE_TOTAL, ID)
				(SELECT L.CODIGO_FILIAL, 
						L.NF_NUMERO, 
						L.SERIE_NF,
						CONVERT(INT, L.QTDE_TOTAL) AS QTDE_TOTAL,
						(ROW_NUMBER() over (order by L.NF_NUMERO)) AS ID
				FROM LOJA_NOTA_FISCAL L
				INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
				INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
				WHERE L.CODIGO_FILIAL = @CODIGO_FILIAL
				AND E.NUMERO_MODELO_FISCAL IN ('55', '65')
				AND CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL)
		
		--TEMPORARIA DOS ITENS
		CREATE TABLE #ITENS_NFE(CODIGO_FILIAL VARCHAR(6), NF_NUMERO VARCHAR(12), SERIE_NF VARCHAR(3), ITEM_IMPRESSAO CHAR(4))
		INSERT INTO #ITENS_NFE (CODIGO_FILIAL, NF_NUMERO, SERIE_NF, ITEM_IMPRESSAO)
				(SELECT L.CODIGO_FILIAL, 
						L.NF_NUMERO, 
						L.SERIE_NF, 
						I.ITEM_IMPRESSAO
				FROM LOJA_NOTA_FISCAL L
				INNER JOIN LOJA_NOTA_FISCAL_ITEM I ON I.CODIGO_FILIAL = L.CODIGO_FILIAL AND L.NF_NUMERO = I.NF_NUMERO AND L.SERIE_NF = I.SERIE_NF
				INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
				INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
				WHERE L.CODIGO_FILIAL = @CODIGO_FILIAL
				AND CONVERT(CHAR(8), L.DATA_HORA_EMISSAO, 112) BETWEEN @strDT_INICIAL AND @strDT_FINAL
				AND E.NUMERO_MODELO_FISCAL IN ('55', '65'))

				SET @TOTAL_NFE2 = (SELECT COUNT(*) FROM #NFE)

				--LOOP QUE VERIFICA SE ESTÁ FALTANDO ALGUM ITEM ENTRE OS OUTROS
				WHILE ((@I2 <= @TOTAL_NFE2) AND @bContinue2 = 1)
					BEGIN

						CREATE TABLE #CONFERENCIA (ITEM_IMPRESSAO INT, ID INT)
						INSERT INTO #CONFERENCIA (ITEM_IMPRESSAO, ID) 
							(SELECT CONVERT(INT, ITEM_IMPRESSAO) AS ITEM,
									(ROW_NUMBER() over (order by ITEM_IMPRESSAO)) AS ID
								FROM #ITENS_NFE 
								WHERE NF_NUMERO = (SELECT NF_NUMERO FROM #NFE WHERE ID = @I2) 
								AND SERIE_NF = (SELECT SERIE_NF FROM #NFE WHERE ID = @I2))
						
							SELECT @TOTAL_ITENS2 = COUNT(*) FROM #CONFERENCIA

							WHILE ((@J2 <= @TOTAL_ITENS2 ) AND @bContinue2 = 1 AND @TOTAL_ITENS2 > 1)
								BEGIN
									IF EXISTS(SELECT ITEM_IMPRESSAO AS ITEM_Z2 FROM #CONFERENCIA WHERE ID = @Z2)
									BEGIN
										SELECT @DIF = SUM(X.ITEM_Z2 - X.ITEM_J2)
											FROM
											(SELECT ITEM_IMPRESSAO AS ITEM_J2,
													(SELECT ITEM_IMPRESSAO AS ITEM_Z2 FROM #CONFERENCIA WHERE ID = @Z2) AS ITEM_Z2
											FROM #CONFERENCIA 
											WHERE ID = @J2)X
						
											IF (@DIF > 1)
												BEGIN
													SET @faltaLinha = '?'
													SET @bContinue2 = 0
												END
										END

										SET @J2 = @J2+1
										SET @Z2 = @Z2+1
								
								END
								
						SET @I2 = @I2 + 1
						IF EXISTS(SELECT *FROM #CONFERENCIA)
							BEGIN
								DROP TABLE #CONFERENCIA	
							END	
					END

	END


--#10# - Fim
--------------------------------------------------------------------------------------------------------------------------------------------------
IF @faltaLinha = ''			--	#1#
	SET @faltaLinha = ' '	--	#1#

END 

INSERT INTO LJ_REG_PAF_ECF_TEMP 
                  (TIPO, 
                   REGISTRO, 
                   LIMITE, 
                   TERMINAL) 
      SELECT 1                                                                                                                                                                                    AS TIPO, 
             'U1' 
             + RIGHT(Replicate('0', 14) + Rtrim(Replace(Replace(Replace(ISNULL(D.CGC_CPF, ''), '.', ''), '-', ''), '/', '')), 14) 
             + CONVERT(CHAR(14), Rtrim(Replace(Replace(Replace(ISNULL(D.RG_IE, ''), '.', ''), '-', ''), '/', '')))	-- #2# 
             + CONVERT(CHAR(14), Rtrim(Replace(Replace(Replace(ISNULL(D.IM, ''), '.', ''), '-', ''), '/', '')))		-- #2#
             + Replace(CONVERT(CHAR(50), D.RAZAO_SOCIAL), ' ', @faltaLinha),	--	#1#
--			 + @faltaLinha AS REGISTRO, --	#1#
             94                                                                                                                                                                                   AS LIMITE, 
             @TERMINAL                                                                                                                                                                            AS TERMINAL 
      FROM   dbo.CADASTRO_CLI_FOR D 
      WHERE  D.NOME_CLIFOR = @FILIAL; 

IF RTRIM(LTRIM(ISNULL(@UF,@LOCALUF))) IN ('MA','ES','PI') --#8#
BEGIN 
      SELECT REGISTRO 
      FROM   LJ_REG_PAF_ECF_TEMP 
	  WHERE TERMINAL = @TERMINAL -- #8#
      ORDER  BY TIPO 
END
	
	ELSE

BEGIN 
      SELECT REGISTRO 
      FROM   LJ_REG_PAF_ECF_TEMP 
      ORDER  BY TIPO 
END

  END
