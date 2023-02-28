CREATE FUNCTION [dbo].[FN_RETORNAVENDEDORCONTRATO] (@idContrato int)
	RETURNS varchar(120)
	AS
	BEGIN
	/*******************************************************************************
	-- Funcao:   Retorna vendedor - LOJA E RETAGUARDA
	-- Empresa:  Linx - 
	-- Autor:    CARLOS MEGASULT - KATUXA
	-- Data:     01/08/2019
	-- Ex		 select dbo.[fn_retornaVendedorContrato](1108) as retorno

	********************************************************************************/
		declare @retorno varchar(120),@vendedor varchar(25)
		set @retorno=''
		declare cur_mov cursor for 
			select distinct  case when isnull(d.VENDEDOR_APELIDO,'') = '' then d.NOME_VENDEDOR else d.VENDEDOR_APELIDO end as VENDEDOR 
				FROM LOJA_VENDA_PARCELAS  a with (nolock)
				JOIN LOJA_VENDA  b with (nolock) on a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.TERMINAL = b.TERMINAL
				JOIN LOJA_VENDA_VENDEDORES c with (nolock) on b.TICKET = c.TICKET and b.CODIGO_FILIAL = c.CODIGO_FILIAL
				JOIN LOJA_VENDEDORES  d with (nolock) on c.VENDEDOR = d.VENDEDOR
				WHERE a.TIPO_PGTO='#' 
				AND A.NUMERO_TITULO=ltrim(rtrim(cast(@idContrato as varchar(20))))
			open cur_mov 
			fetch next from cur_mov into  @VENDEDOR
			while @@fetch_status = 0
			begin
				set @retorno = @retorno + LTRIM(RTRIM(@vendedor))+'/'
				fetch next from cur_mov into  @VENDEDOR
			end
			close cur_mov
			deallocate cur_mov
		RETURN @retorno
END
