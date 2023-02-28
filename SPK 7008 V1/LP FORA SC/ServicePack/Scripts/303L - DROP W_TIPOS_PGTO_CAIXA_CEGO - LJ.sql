--BASE DE LOJA
IF EXISTS (SELECT * FROM sys.views where name ='w_tipos_pgto_caixa_cego')
	drop VIEW dbo.w_tipos_pgto_caixa_cego

