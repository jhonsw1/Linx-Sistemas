if exists(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LX_CONFIG_BLOCOX')
	begin 
		update LX_CONFIG_BLOCOX set DATA_INICIO = '20201001' 
	end
