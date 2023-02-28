create Procedure LX_VENDAS_IDENTIFICADAS_PAF_NFCe @CNPJ varchar (14) ,@PERIODO VARCHAR(7), @FILIAL VARCHAR(200),
		@VERSAO_APLICATIVO char(03), @PRINCIPAL_EXE VARCHAR(30)

AS
--04/11/2021 - Gilvano Santos - Criação de Procedure para novo registros do menu fiscal VENDAS_IDENTIFICADAS_CPF_CNPJ PAF NFCe 2021.

/*
Z1 Identificação do usuário do PAF-ECF  1º registro (único)
Z2 Identificação da empresa desenvolvedora do PAF-ECF  2º registro (único) 
Z3 Identificação do PAF-ECF 3º registro (único) 
Z4 Totalização de vendas a CPF/CNPJ Vendas a CPF/CNPJ
Z9 Totalização de registros Penúltimo registro (único) 
EAD Assinatura digital  Último registro (único) 
*/
               

SET NOCOUNT ON 
BEGIN 
	Declare @datainicial datetime,@datafinal datetime

	if len(@PERIODO) < 7
		Begin 
			set @datainicial = '20000101'
			set @datafinal   = '20301231'
		end		 
	else
		Begin 
		set @datainicial = Convert(char(8),Right(@PERIODO,4) + Left(@PERIODO,2)+'01',112)
		set @datafinal   = Replace(Convert(varchar(8),DATEADD(d, -DAY(@datainicial),DATEADD(m,1,@datainicial)),112),'/','') 
		set @datainicial = Convert(char(8),@datainicial,112)
		set @datafinal   = Convert(char(8),@datafinal,112)
	end ;

	IF object_id('TEMPDB..#VENDAS_IDENTIFICADAS_CPFCNPJ') IS NOT NULL
	Begin 
		DROP TABLE #VENDAS_IDENTIFICADAS_CPFCNPJ
	end ;

	CREATE TABLE #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO  CHAR(3) COLLATE DATABASE_DEFAULT  NULL,
												REGISTRO VARCHAR(400) COLLATE DATABASE_DEFAULT null, 
												LIMITE int ,
												TERMINAL char (3));

   --Z1 IDENTIFICAÇÃO DO USUÁRIO DO PAF-ECF: --------------------------------------------------------------------------------------------------------------
	INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 	Select  DISTINCT  1 AS TIPO,
			'Z1'                                                                                                      +
            RIGHT(REPLICATE(' ', 14) + RTRIM(REPLACE(REPLACE(REPLACE((rtrim(ltrim(isnull(CGC_CPF,'')))  ), '.', ''), '-', ''), '/', '')), 14) +
			RIGHT(REPLICATE(' ', 14) + REPLACE(CAST(rtrim(ltrim(isnull(RG_IE,''))) as VARCHAR),'.',''), 14)         +  
			Left(REPLACE(CAST(rtrim(ltrim(isnull(IM,''))) as VARCHAR),'.','') + REPLICATE(' ', 14) ,14)             +                                              
		    left(REPLACE(isnull(RAZAO_SOCIAL,''),'.','')  +  replicate(' ',50),50)  ,                                                         
			94 AS LIMITE               ,
			'001' AS TERMINAL 
			FROM dbo.CADASTRO_CLI_FOR WHERE NOME_CLIFOR = @FILIAL ;						
			
	--Z2 IDENTIFICAÇÃO DA EMPRESA DESENVOLVEDORA DO PAF-ECF------------------------------------------------------------------------------------------------
	INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 	Select  DISTINCT  2 AS TIPO,
			'Z2' +
			RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(rtrim(ltrim(SH_CNPJ)) as VARCHAR),'.','0'), 14)  +                                                         
			left(REPLACE(CAST(rtrim(ltrim(SH_IE)) as VARCHAR),'.','') + REPLICATE(' ', 14)  , 14)   +                                                         
			left(REPLACE(CAST(rtrim(ltrim(SH_IM)) as VARCHAR),'.','') + REPLICATE(' ', 14)  , 14)    +                                                         
			left(SH_RAZAO_SOCIAL + REPLICATE(' ', 50)   , 50) ,       
	        94 AS LIMITE, 
			'001' TERMINAL 
	 FROM dbo.LJ_ID_PAF_ECF 
	 --WHERE VERSAO_APLICATIVO = '7.5';
	 WHERE VERSAO_APLICATIVO = @VERSAO_APLICATIVO AND UPPER(PRINCIPAL_EXE) = UPPER(@PRINCIPAL_EXE);	

	--Z3  IDENTIFICAÇÃO DO PAF-ECF ------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 	Select  DISTINCT  3 AS TIPO,
			'Z3'               +
			upper(left(REPLACE(CAST(rtrim(ltrim(LAUDO_PAF_ECF)) as VARCHAR),'.','')+ REPLICATE(' ', 10) , 10))   +  
			upper(left(REPLACE(CAST(rtrim(ltrim(NOME_COMERCIAL)) as VARCHAR),'.','')+ REPLICATE(' ', 50) , 50))   +  
			@VERSAO_APLICATIVO + '       ',
			72,
			001
			FROM dbo.LJ_ID_PAF_ECF 
	        --WHERE VERSAO_APLICATIVO = '7.5';
			WHERE VERSAO_APLICATIVO = @VERSAO_APLICATIVO AND UPPER(PRINCIPAL_EXE) = UPPER(@PRINCIPAL_EXE);
    
	--Z4 Totalização de vendas a CPF/CNPJ --------------------------------------------------------------------------------------------------------------
	declare @primeiro as varchar(8) ,@ultimo as varchar(8)
	
	select @primeiro =replace(CONVERT(VARCHAR, DATA_HORA_EMISSAO - DAY(DATA_HORA_EMISSAO) + 1, 112),'/','') ,
		   @ultimo = replace(Convert(varchar(10),DATEADD(d, -DAY(DATA_HORA_EMISSAO),DATEADD(m,1,DATA_HORA_EMISSAO)),112),'/','') 
		   From dbo.LOJA_NOTA_FISCAL L
		   INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
		   INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
				Where E.NUMERO_MODELO_FISCAL IN ('65') 
				and VALOR_TOTAL is not null
				and convert(char(8),L.EMISSAO,112) between @datainicial and @datafinal 
				and isnull(CODIGO_CLIENTE,'') <>''
				Group by CODIGO_CLIENTE,DATA_HORA_EMISSAO,
				CONVERT(VARCHAR, DATA_HORA_EMISSAO - DAY(DATA_HORA_EMISSAO) + 1, 112) ,
				convert(varchar(10),DATEADD(d, -DAY(DATA_HORA_EMISSAO),DATEADD(m,1,DATA_HORA_EMISSAO)),112)


	if isnull(@CNPJ,'') <> ''  
	Begin 
		INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 		SELECT	DISTINCT  4 AS TIPO,
				'Z4' +
				RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(ltrim(rtrim(H.CPF_CGC)) as VARCHAR),'.',''), 14) +  
				RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(SUM(L.VALOR_TOTAL) as VARCHAR),'.',''), 14) +
				@primeiro + @ultimo + 
				replace(rtrim(ltrim(Convert(char(10),getdate(),112))),'/','')                              +
				replace(right(convert(char(20),getdate(),113),8),':',''),
				60,
				001
		FROM LOJA_NOTA_FISCAL L
		INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
		INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
		INNER JOIN CLIENTES_VAREJO H ON H.CODIGO_CLIENTE = L.CODIGO_CLIENTE
		INNER JOIN LOJAS_VAREJO C ON L.CODIGO_FILIAL = C.CODIGO_FILIAL
		INNER JOIN FILIAIS D ON C.FILIAL = D.FILIAL
		WHERE e.NUMERO_MODELO_FISCAL = '65'
		and convert(char(8),L.EMISSAO,112) between @datainicial and @datafinal 
		AND D.FILIAL = @FILIAL
		AND ltrim(rtrim(H.CPF_CGC)) = ltrim(rtrim(@CNPJ)) 
		and L.CODIGO_CLIENTE IS NOT NULL 
		group by H.CPF_CGC
    end 
	Else 
	Begin 
		INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 		SELECT	DISTINCT  4 AS TIPO,
				'Z4' +
				RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(ltrim(rtrim(H.CPF_CGC)) as VARCHAR),'.',''), 14) +  
				RIGHT(REPLICATE('0', 14) +  REPLACE(CAST(SUM(L.VALOR_TOTAL) as VARCHAR),'.',''), 14) +
				@primeiro + @ultimo + 
				replace(rtrim(ltrim(Convert(char(10),getdate(),112))),'/','')                              +
				replace(right(convert(char(20),getdate(),113),8),':',''),
				60,
				001
		FROM LOJA_NOTA_FISCAL L
		INNER JOIN SERIES_NF S ON S.SERIE_NF = L.SERIE_NF
		INNER JOIN CTB_ESPECIE_SERIE E ON E.ESPECIE_SERIE = S.ESPECIE_SERIE
		INNER JOIN CLIENTES_VAREJO H ON H.CODIGO_CLIENTE = L.CODIGO_CLIENTE
		INNER JOIN LOJAS_VAREJO C ON L.CODIGO_FILIAL = C.CODIGO_FILIAL
		INNER JOIN FILIAIS D ON C.FILIAL = D.FILIAL
		WHERE e.NUMERO_MODELO_FISCAL = '65'
		and convert(char(8),L.EMISSAO,112) between @datainicial and @datafinal
		AND D.FILIAL = @FILIAL
		and L.CODIGO_CLIENTE IS NOT NULL 
		group by H.CPF_CGC
   end ;

   -- Z9 - TOTALIZAÇÃO DO ARQUIVO -------------------------------------------------------------------------------------------------------------------------
	Declare @QuantReg as int
	select @QuantReg = Count(*) from #VENDAS_IDENTIFICADAS_CPFCNPJ where tipo = 4

	INSERT INTO #VENDAS_IDENTIFICADAS_CPFCNPJ (TIPO, REGISTRO, LIMITE, TERMINAL ) 
 	Select  DISTINCT  5 AS TIPO,
			'Z9' +
			convert(varchar,isnull(SH_CNPJ,'00000000000000')) +
			convert(varchar,left(REPLACE(CAST(SH_IE as VARCHAR),'.','') + REPLICATE(' ', 14), 14)) +
			RIGHT(REPLICATE('0', 6) +  REPLACE(CAST(@QuantReg as VARCHAR),'.',''), 6),
			36,
			001
			FROM dbo.LJ_ID_PAF_ECF 
	        WHERE VERSAO_APLICATIVO = @VERSAO_APLICATIVO AND UPPER(PRINCIPAL_EXE) = UPPER(@PRINCIPAL_EXE);
	End ;

select REGISTRO from #VENDAS_IDENTIFICADAS_CPFCNPJ order by tipo;