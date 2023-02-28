if exists ( select  1 from parametros where PARAMETRO = 'PERG_ENVIA_NFE_SEFAZ') 
begin 	
update parametros set NOTA_PROGRAMADOR = 'DESATIVADO'  where PARAMETRO = 'PERG_ENVIA_NFE_SEFAZ'	
end 