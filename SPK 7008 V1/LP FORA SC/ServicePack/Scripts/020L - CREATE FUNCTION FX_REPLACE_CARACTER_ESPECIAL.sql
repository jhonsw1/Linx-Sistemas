CREATE FUNCTION [DBO].[FX_REPLACE_CARACTER_ESPECIAL](@Conteudo varchar(1000))  
	   
RETURNS VARCHAR(1000)  
  
AS  

-- 23/06/2017 - Wendel Crespigio -#2# - replace(@Conteudo, 'Í', 'I').
-- 25/09/2012 - DANIEL GONCALVES - #1# INCLUIDO ALGUNS REPLACES PARA A TABELA DE IRREGULARIDADE.
-- 24/04/2008 - PADIAL - FUNÇÃO PARA RETORNAR CONTEUDO DA STRING SEM CARACTER ESPECIAL  
  
BEGIN  
 
 select @Conteudo = replace(@Conteudo, 'nº', 'Nro')  
 select @Conteudo = replace(@Conteudo, '- ', '_') 
 select @Conteudo = replace(@Conteudo, ' -', '_')  
 select @Conteudo = replace(@Conteudo, ' _', '_')  
 select @Conteudo = replace(@Conteudo, '.', '_')  
 select @Conteudo = replace(@Conteudo, ',', '_')  
 select @Conteudo = replace(@Conteudo, '(', '_')  
 select @Conteudo = replace(@Conteudo, ')', '_')  
 select @Conteudo = replace(@Conteudo, '"', '_')  
 select @Conteudo = replace(@Conteudo, '/', '_')  
 select @Conteudo = replace(@Conteudo, '''', '_')  
 select @Conteudo = replace(@Conteudo, '+', '_')  
 select @Conteudo = replace(@Conteudo, '-', '_')  
 select @Conteudo = replace(@Conteudo, '*', '_')  
 select @Conteudo = replace(@Conteudo, '%', '_')  
 select @Conteudo = replace(@Conteudo, '&', '_')   
 select @Conteudo = replace(@Conteudo, 'Ç', 'C')  
 select @Conteudo = replace(@Conteudo, 'Ã', 'A')  
 select @Conteudo = replace(@Conteudo, 'Õ', 'O')  
 select @Conteudo = replace(@Conteudo, 'Á', 'A')  
 select @Conteudo = replace(@Conteudo, 'É', 'E')  
 select @Conteudo = replace(@Conteudo, 'Ó', 'O')  
 select @Conteudo = replace(@Conteudo, 'Ü', 'U')  
 select @Conteudo = replace(@Conteudo, 'Ú', 'U')  
 select @Conteudo = replace(@Conteudo, 'Ê', 'E')  
 select @Conteudo = replace(@Conteudo, 'Â', 'A')  
 select @Conteudo = replace(@Conteudo, 'Ô', 'O')  
 select @Conteudo = replace(@Conteudo, '?', '_')  
 select @Conteudo = replace(@Conteudo, '!', '_')
 select @Conteudo = replace(@Conteudo, 'Í', 'I') 
 select @Conteudo = replace(@Conteudo, 'í', 'i') 
 
RETURN rtrim(UPPER(@Conteudo))  
END