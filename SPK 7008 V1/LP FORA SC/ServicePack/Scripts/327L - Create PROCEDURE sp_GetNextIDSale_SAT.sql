Create Procedure [dbo].[sp_GetNextIDSale_SAT] (@strFilial varchar(25), @bUpdate bit = 1)  
As  
--21/11/2019 - Wendel Crespigio - MODASP-4860 - Tratamento para quando o Sequêncial do SAT voltar ou recebeu um sequêncial antigo, causando problema nas vendas que já estão no ERP.

Begin   
Set Nocount On  
Begin Transaction 
	Declare @intSequencial Int
 	Set     @intSequencial = 0
 
 /* Antigo
 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 SELECT @intSequencial = ISNULL(SEQUENCIA_VENDA_SAT,0) + 1  
		FROM LOJAS_VAREJO (UPDLOCK)  
		WHERE CODIGO_FILIAL = @strFilial  
  
	 WHILE EXISTS(SELECT 1 FROM LOJA_CF_SAT (NOLOCK) WHERE CODIGO_FILIAL = @strFilial AND ID_LOJA_CF_SAT = @intSequencial)  
		select @intSequencial = MAX(ID_LOJA_CF_SAT)+1 FROM LOJA_CF_SAT (NOLOCK) WHERE CODIGO_FILIAL = @strFilial  
  
	IF @bUpdate = 1  
		UPDATE LOJAS_VAREJO WITH (UPDLOCK) SET SEQUENCIA_VENDA_SAT = @intSequencial WHERE CODIGO_FILIAL = @strFilial  
        SELECT @intSequencial AS SEQUENCIAL  
 */
  
--Novo forma de adquirir o Sequêncial do SAT não sendo necessário receber o sequêncial existente no ERP. ---------------------------------------------------------------------------
      Declare @DataInicio    as DateTime 
      Declare @DataAtual     as DateTime2 
      Declare @DataAtualFim  as DateTime2 

      Set @DataInicio   = '20191121 00:00:00:000' 
      Set @dataatual    = Cast(Getdate() As Date) 
      Set @dataAtualFim = Dateadd(ns, -100, Dateadd(s, 86400, @DataAtual)) 

-- Retorno --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       Select @intSequencial ='1' + RIGHT('000'+CONVERT(Varchar, Datediff(Day, @DataInicio, @dataAtualFim)), 4) + LEFT(Datediff(Millisecond, @DataAtual, Getdate()), 5) 

       Waitfor Delay '00:00:01' 
  
  Commit Transaction
  Select @intSequencial AS SEQUENCIAL

  Set Nocount Off 
End 
