

Declare @codigofilial char(6)

select top 1 @codigofilial=codigo_filial from loja_venda order by DATA_VENDA desc


if exists (
select VALOR_ATUAL from parametros where (VALOR_ATUAL = 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'http://servicehub.linx.com.br/api/v1/LinxServiceApi' OR  VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi') and parametro = 'peela_url')
begin 
	update parametros set VALOR_ATUAL ='http://servicehub.linx.com.br/api/v1/LinxServiceApi/GiftService' where  parametro = 'peela_url'
end

if exists (
select VALOR_ATUAL from PARAMETROS_LOJA where (VALOR_ATUAL = 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'http://servicehub.linx.com.br/api/v1/LinxServiceApi' or VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi') and parametro = 'peela_url' and CODIGO_FILIAL= @codigofilial)
begin 
	update PARAMETROS_LOJA set VALOR_ATUAL ='http://servicehub.linx.com.br/api/v1/LinxServiceApi/GiftService' where  parametro = 'peela_url' and CODIGO_FILIAL = @codigofilial
end

if exists (
select VALOR_ATUAL from PARAMETROS_LOJA_TERMINAL where (VALOR_ATUAL = 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'http://servicehub.linx.com.br/api/v1/LinxServiceApi' or VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi/' or VALOR_ATUAL =
'https://servicehub.linx.com.br/api/v1/LinxServiceApi') and parametro = 'peela_url' and CODIGO_FILIAL= @codigofilial)
begin 
	update PARAMETROS_LOJA_TERMINAL set VALOR_ATUAL ='http://servicehub.linx.com.br/api/v1/LinxServiceApi/GiftService' where  parametro = 'peela_url' and CODIGO_FILIAL=@codigofilial
end