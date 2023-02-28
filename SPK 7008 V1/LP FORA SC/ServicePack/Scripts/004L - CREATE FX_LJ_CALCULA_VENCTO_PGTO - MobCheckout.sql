CREATE FUNCTION [dbo].[FX_LJ_CALCULA_VENCTO_PGTO] (@CODFILIAL AS VARCHAR(06), @TERMINAL AS VARCHAR(03), @TipoPGTO as char(02),  @OperVenda as char(03), @dtVencto2 varchar(20) = '' )
RETURNS datetime
begin
	DECLARE @bValidaDia bit, @dtVencto datetime

	set @bValidaDia = 0

	IF @TipoPGTO IS NULL
		RETURN NULL

	IF @OperVenda IS NULL
		RETURN NULL

	if len(@dtVencto2) > 0
		set @dtVencto = cast(@dtVencto2 as datetime)

	IF @dtVencto IS NULL
	BEGIN
		SELECT TOP 1 @dtVencto = (
						case when B.TIPO_A_VISTA = 0 then
						( case when cast((A.DIAS_VENCIMENTO / 30 ) as int) = (A.DIAS_VENCIMENTO / 30 ) and isnull(A.DIAS_VENCIMENTO, 0) > 0
							   then ( case when c.VENC_RELATIVO IS NOT NULL
										   then DATEADD(MONTH, (A.DIAS_VENCIMENTO / 30 ), c.VENC_RELATIVO) +(A.DIAS_VENCIMENTO % 30 )
						   else DATEADD(MONTH, (A.DIAS_VENCIMENTO / 30 ), getdate()) + (A.DIAS_VENCIMENTO % 30 ) end )
				  else getdate() + A.DIAS_VENCIMENTO end )
		else getdate() end )
		FROM LOJA_FORMAS_PARCELAS A
		INNER JOIN TIPOS_PGTO B ON A.TIPO_PGTO = B.TIPO_PGTO 
		INNER JOIN LOJA_FORMAS_PGTO C ON A.COD_FORMA_PGTO = C.COD_FORMA_PGTO
		LEFT JOIN LOJA_OPERACOES_PGTOS D ON A.COD_FORMA_PGTO = D.COD_FORMA_PGTO
		WHERE D.OPERACAO_VENDA = @OperVenda and A.TIPO_PGTO = @TipoPGTO
		AND ISNULL(C.ATIVAR_EM, DATEADD(D, -1, getdate())) <= getdate()
		AND ISNULL(C.DESATIVAR_EM, DATEADD(D, 1, getdate())) >= getdate()
	END
	
	if @dtVencto is not null
	begin 
		set @dtVencto = cast(@dtVencto as date) 


		SELECT @bValidaDia = case when RTRIM(LTRIM(VALOR_ATUAL)) = '.T.' THEN 1 ELSE 0 END 
		FROM [dbo].[W_PARAMETROS_LOJA_TERMINAL]
		WHERE CODIGO_FILIAL = @CODFILIAL AND TERMINAL = @TERMINAL AND PARAMETRO = 'joga_para_segunda'


		IF @bValidaDia = 1 AND @dtVencto is not null
		BEGIN
			SET @dtVencto = ( CASE WHEN DATEPART(dw, @dtVencto) = 1 THEN @dtVencto + 1
								   WHEN DATEPART(dw, @dtVencto) = 7 THEN @dtVencto + 2
							  ELSE @dtVencto END	 )
		END
	end

	RETURN @dtVencto
end
