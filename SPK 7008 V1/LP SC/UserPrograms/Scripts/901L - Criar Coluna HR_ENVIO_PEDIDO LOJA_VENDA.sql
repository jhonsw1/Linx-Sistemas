IF not exists (SELECT 1 FROM SYS.tables A
			   INNER JOIN SYS.columns B
			   ON A.object_id = B.object_id
			   WHERE A.name ='loja_venda' AND B.name ='hr_envio_pedido')
exec(' ALTER TABLE LOJA_VENDA ADD HR_ENVIO_PEDIDO DATETIME')


