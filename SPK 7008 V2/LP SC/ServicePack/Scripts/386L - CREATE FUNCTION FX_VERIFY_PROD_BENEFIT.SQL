Create Function [dbo].[FX_Verify_Prod_Benefit]( @CodInteiro  Varchar(50),@Delimitador Char(1)) 

Returns @PROD_BENEFIT Table ( 
			Produto   Varchar(50), 
			Cor       Varchar(50), 
			Tamanho   Varchar(50), 
			Descricao Varchar(200), 
			CodBarra  Varchar(50))

-- Wendel Crespigio 05/06/2020 - Criação da Function que retorna Produto /Cor /Tamanho /Código de Barras independente do que for passado a ela, 
-- os separadores que identificam a Cor e o Produto devem ser passados como o segundo parâmetro @Delimitador;
As
  Begin 
      If Isnull(@Delimitador, '') = '' 
        Begin 
            Set @Delimitador ='_' 
        End ;

      Declare @PosProduto Int, 
              @Produto    Varchar(50), 
              @POSCor     Int, 
              @PosTamanho Int, 
              @COR        Varchar(50), 
              @Tamanho    Varchar(50), 
              @Resta      Varchar(50), 
              @Descricao  Varchar(200)  ; 

      If Exists(Select Top 1 1 
                From   PRODUTOS (Nolock) A 
                       Left Join PRODUTOS_BARRA (Nolock) B 
                              On A.PRODUTO = B.produto 
                       Left Join PRODUTO_CORES (Nolock) C 
                              On A.PRODUTO = C.PRODUTO 
                                 And B.COR_PRODUTO = C.COR_PRODUTO 
                Where  Rtrim(Ltrim(B.CODIGO_BARRA)) = Rtrim(Ltrim(@CodInteiro))) 
        Begin 
            Insert Into @PROD_BENEFIT 
            Select Distinct B.PRODUTO, 
                            C.DESC_COR_PRODUTO, 
                            B.GRADE, 
                            A.DESC_PRODUTO, 
                            B.CODIGO_BARRA 
            From   PRODUTOS (Nolock)A 
                   Left Join PRODUTOS_BARRA (Nolock) B 
                          ON A.PRODUTO = B.PRODUTO 
                   Left Join PRODUTO_CORES (Nolock) C 
                          ON A.PRODUTO = C.PRODUTO 
                             And B.COR_PRODUTO = C.COR_PRODUTO 
            Where  Rtrim(Ltrim(B.CODIGO_BARRA)) = Rtrim(Ltrim(@CodInteiro)) 
            Return ;
        End ;

      Select @PosProduto = Charindex (@Delimitador, @CodInteiro) - 1 ;
      
      IF @PosProduto > 0 
        Begin 
            Select @Produto = LEFT(@CodInteiro, @PosProduto) 
            Select @Resta = Substring(@CodInteiro, Len(@Produto) + 2, Len(@CodInteiro)) 
        End 
      Else 
        Begin 
            SET @Produto = @CodInteiro 
           
            Insert Into @PROD_BENEFIT 
            Select Distinct B.PRODUTO, 
                            C.DESC_COR_PRODUTO, 
                            B.GRADE, 
                            A.DESC_PRODUTO, 
                            B.CODIGO_BARRA 
            From   PRODUTOS (nolock)A 
                   Left Join PRODUTOS_BARRA (Nolock) B 
                          ON A.PRODUTO = B.PRODUTO 
                   Left Join PRODUTO_CORES (Nolock) C 
                          ON A.PRODUTO = C.PRODUTO 
                             And B.COR_PRODUTO = C.COR_PRODUTO 
            Where  Rtrim(Ltrim(A.PRODUTO)) = Rtrim(Ltrim(@Produto)) 
            Return ;
        End ;

      Select @POSCor = Charindex (@Delimitador, @Resta) ;

     
      If @POSCor > 0 
        Begin 
            Select @COR = LEFT(@Resta, @POSCor - 1) 
            Select @Tamanho = Substring(@Resta, Len(@COR) + 2, Len(@Resta)) 
        
        End 
      Else 
        Begin 
            Select @COR = Substring (@CodInteiro, @PosProduto + 2,Len(@CodInteiro)) 
        End ; 

      IF     @Produto Is Not Null 
         AND @COR     Is Not Null
         AND @Tamanho Is Not Null 
        Begin 
            Insert Into @PROD_BENEFIT 
            Select Distinct B.produto, 
                            C.DESC_COR_PRODUTO, 
                            B.GRADE, 
                            A.DESC_PRODUTO, 
                            B.CODIGO_BARRA 
            From   Produtos (Nolock)A 
                   Left Join Produtos_barra (Nolock) B 
                          ON A.PRODUTO = B.PRODUTO 
                   Left Join PRODUTO_CORES (Nolock) C 
                          ON A.PRODUTO = C.PRODUTO 
                             And B.COR_PRODUTO = C.COR_PRODUTO 
            Where  Rtrim(Ltrim(A.PRODUTO)) = Rtrim(Ltrim(@Produto)) 
                   And CONVERT(VARCHAR, B.TAMANHO) = @Tamanho 
                   And B.COR_PRODUTO = @COR 
            Return; 
        End ;

      IF @Produto		Is Not Null
         And @COR		Is Not Null 
         And @Tamanho	Is Null 
        Begin 
            Insert Into @PROD_BENEFIT 
            Select Distinct B.PRODUTO, 
                            C.DESC_COR_PRODUTO, 
                            B.GRADE, 
                            A.DESC_PRODUTO, 
                            B.CODIGO_BARRA 
            From   Produtos (Nolock)A 
                   Left Join PRODUTOS_BARRA (Nolock) B 
                          ON A.PRODUTO = B.PRODUTO 
                   Left Join PRODUTO_CORES (Nolock) C 
                          ON A.PRODUTO = C.PRODUTO 
                             And B.COR_PRODUTO = C.COR_PRODUTO 
            Where  Rtrim(Ltrim(A.PRODUTO)) = Rtrim(Ltrim(@Produto)) 
                   And b.COR_PRODUTO = @COR 
            Return; 
        End;
      Return;
  End;