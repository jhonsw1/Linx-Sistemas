IF NOT EXISTS ( SELECT 1 FROM SYS.OBJECTS WHERE NAME ='SP_HR_CRM_LIMPA_PROMOCAO_CLIENTE')
	BEGIN
		EXEC('

				create PROCEDURE [dbo].[SP_HR_CRM_LIMPA_PROMOCAO_CLIENTE](@CPF_CLIENTE VARCHAR(20))      
				AS      
				BEGIN  
				 /* verifica se ja existe a tabela do motor de promoção */  
				 IF EXISTS ( SELECT 1 FROM SYS.objects WHERE objects.name = ''HR_PROMOCAO_CLIENTE'')  
				  BEGIN  
				  DELETE FROM HR_PROMOCAO_CLIENTE WHERE CPF_CLIENTE = @CPF_CLIENTE AND TIPO = ''E''  
				  END  
  
				END
		')
	END
ELSE 
	BEGIN
		EXEC('
			ALTER PROCEDURE [dbo].[SP_HR_CRM_LIMPA_PROMOCAO_CLIENTE](@CPF_CLIENTE VARCHAR(20))      
				AS      
				BEGIN  
				 /* verifica se ja existe a tabela do motor de promoção */  
				 IF EXISTS ( SELECT 1 FROM SYS.objects WHERE objects.name = ''HR_PROMOCAO_CLIENTE'')  
				  BEGIN  
				  DELETE FROM HR_PROMOCAO_CLIENTE WHERE CPF_CLIENTE = @CPF_CLIENTE AND TIPO = ''E''  
				  END  
  
				END
		')
end