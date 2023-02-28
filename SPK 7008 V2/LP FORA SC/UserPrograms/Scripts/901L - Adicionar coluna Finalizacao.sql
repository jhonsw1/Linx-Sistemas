IF NOT EXISTS ( SELECT 1 FROM SYS.TABLES A
				 INNER JOIN SYS.COLUMNS B 
				 ON A.OBJECT_ID = B.OBJECT_ID 
				 WHERE A.NAME ='LOJA_PEDIDO_PGTO' and b.name = 'FINALIZACAO')
	begin 
		exec (' alter table loja_pedido_pgto add finalizacao varchar(20)')
	end