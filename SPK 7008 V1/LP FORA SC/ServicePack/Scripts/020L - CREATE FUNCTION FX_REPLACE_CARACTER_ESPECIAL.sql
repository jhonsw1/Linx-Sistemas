CREATE FUNCTION [DBO].[FX_REPLACE_CARACTER_ESPECIAL](@Conteudo varchar(1000))  
	   
RETURNS VARCHAR(1000)  
  
AS  

-- 23/06/2017 - Wendel Crespigio -#2# - replace(@Conteudo, '�', 'I').
-- 25/09/2012 - DANIEL GONCALVES - #1# INCLUIDO ALGUNS REPLACES PARA A TABELA DE IRREGULARIDADE.
-- 24/04/2008 - PADIAL - FUN��O PARA RETORNAR CONTEUDO DA STRING SEM CARACTER ESPECIAL  
  
BEGIN  
 
 select @Conteudo = replace(@Conteudo, 'n�', 'Nro')  
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
 select @Conteudo = replace(@Conteudo, '�', 'C')  
 select @Conteudo = replace(@Conteudo, '�', 'A')  
 select @Conteudo = replace(@Conteudo, '�', 'O')  
 select @Conteudo = replace(@Conteudo, '�', 'A')  
 select @Conteudo = replace(@Conteudo, '�', 'E')  
 select @Conteudo = replace(@Conteudo, '�', 'O')  
 select @Conteudo = replace(@Conteudo, '�', 'U')  
 select @Conteudo = replace(@Conteudo, '�', 'U')  
 select @Conteudo = replace(@Conteudo, '�', 'E')  
 select @Conteudo = replace(@Conteudo, '�', 'A')  
 select @Conteudo = replace(@Conteudo, '�', 'O')  
 select @Conteudo = replace(@Conteudo, '?', '_')  
 select @Conteudo = replace(@Conteudo, '!', '_')
 select @Conteudo = replace(@Conteudo, '�', 'I') 
 select @Conteudo = replace(@Conteudo, '�', 'i') 
 
RETURN rtrim(UPPER(@Conteudo))  
END