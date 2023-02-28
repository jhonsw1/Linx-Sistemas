if not exists ( select 1 from sys.triggers where name ='TRU_HR_LOJA_VENDA')

begin
	exec('
CREATE trigger [dbo].[TRU_HR_LOJA_VENDA] on [dbo].[LOJA_VENDA]  for UPDATE NOT FOR REPLICATION  as    
-- Daniel 25-11-2019 Trigger criada para tratar promo��o de cliente unico e exclusivo
-- Daniel 29-06-2020 Alterada Trigger para considerar tamb�m o ID_TIPO_PROMOCAO 14 - Promo��o de Cupom
-- Daniel 29-09-2020 Alterada para preencher informacao de ID_TIPO_ORIGEM e ID_TIPO_MODALIDADE no LOJA_VENDA


begin    
      

 IF UPDATE(TICKET_IMPRESSO) OR UPDATE (DATA_HORA_CANCELAMENTO)
 BEGIN    
    
 INSERT INTO HR_PROMOCAO_CLIENTE ( ID_PROMOCAO,CPF_CLIENTE,DATA_HORA,TIPO)
 SELECT 
 HR_VENDA_PROMOCAO.ID_PROMOCAO,
 CLIENTES_VAREJO.CPF_CGC AS CPF_CLIENTE,
 HR_VENDA_PROMOCAO.DATA_PARA_TRANSFERENCIA AS DATA_HORA,
 TIPO =''U''
 FROM INSERTED
 INNER JOIN HR_VENDA_PROMOCAO
 ON HR_VENDA_PROMOCAO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL 
 AND HR_VENDA_PROMOCAO.TICKET = INSERTED.TICKET
 AND HR_VENDA_PROMOCAO.DATA_VENDA = INSERTED.DATA_VENDA
 INNER JOIN HR_PROMOCAO
 ON HR_VENDA_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO.ID_PROMOCAO 
 INNER JOIN CLIENTES_VAREJO
 ON INSERTED.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
 WHERE TICKET_IMPRESSO =1 
 AND DATA_HORA_CANCELAMENTO IS NULL 
 AND HR_PROMOCAO.ID_TIPO_PROMOCAO in(''5'',''14'' )
 AND NOT EXISTS(SELECT top 1 1 FROM HR_PROMOCAO_CLIENTE x WHERE x.TIPO =''U'' and x.cpf_cliente = CLIENTES_VAREJO.CPF_CGC and x.id_promocao = HR_PROMOCAO.ID_PROMOCAO)

 DELETE HR_PROMOCAO_CLIENTE
 FROM INSERTED
 INNER JOIN HR_VENDA_PROMOCAO
 ON HR_VENDA_PROMOCAO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL 
 AND HR_VENDA_PROMOCAO.TICKET = INSERTED.TICKET
 AND HR_VENDA_PROMOCAO.DATA_VENDA = INSERTED.DATA_VENDA
 INNER JOIN HR_PROMOCAO
 ON HR_VENDA_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO.ID_PROMOCAO 
 INNER JOIN CLIENTES_VAREJO
 ON INSERTED.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
 INNER JOIN HR_PROMOCAO_CLIENTE
 ON  HR_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO_CLIENTE.ID_PROMOCAO AND CLIENTES_VAREJO.CPF_CGC = HR_PROMOCAO_CLIENTE.CPF_CLIENTE
 WHERE DATA_HORA_CANCELAMENTO IS NOT NULL AND HR_PROMOCAO.ID_TIPO_PROMOCAO = 9 AND HR_PROMOCAO_CLIENTE.TIPO =''U''

 if exists ( SELECT 1 FROM INSERTED A
  INNER JOIN LOJA_PEDIDO_VENDA B
  ON A.CODIGO_FILIAL = B.CODIGO_FILIAL_ORIGEM AND A.TICKET = b.TICKET
  INNER JOIN LOJA_PEDIDO C
  ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND B.PEDIDO = C.PEDIDO 
  WHERE C.TIPO_PEDIDO =''27'' ) 
   BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
   
  

  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE B.COD_FORMA_PGTO IN(''ZB'',''ZD'',''ZE'',''ZG'',''ZH'',''ZL'',''ZM'',''ZO'',''ZT'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END       
  
  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE c.TIPO_PGTO IN(''B'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 3 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 

   if not exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE c.TIPO_PGTO IN(''B'') or B.COD_FORMA_PGTO IN(''ZB'',''ZD'',''ZE'',''ZG'',''ZH'',''ZL'',''ZM'',''ZO'',''ZT'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
     
  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE B.COD_FORMA_PGTO IN(''CS'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END  


   IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_PEDIDO_VENDA C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND A.DATA_VENDA = C.DATA_VENDA AND A.TICKET = C.TICKET
   inner join loja_pedido d 
   on a.CODIGO_FILIAL = d.CODIGO_FILIAL_ORIGEM and c.PEDIDO = d.PEDIDO
   where D.LX_PEDIDO_ORIGEM =''4'')
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 3 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
   
   
   IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_PEDIDO_VENDA C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND A.DATA_VENDA = C.DATA_VENDA AND A.TICKET = C.TICKET
   inner join loja_pedido d 
   on a.CODIGO_FILIAL = d.CODIGO_FILIAL_ORIGEM and c.PEDIDO = d.PEDIDO
   where D.LX_TIPO_PRE_VENDA =''1'')
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 


    IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_VENDA_SHOWROOMER C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL AND A.TICKET = C.TICKET AND A.DATA_VENDA = C.DATA_VENDA
   INNER JOIN LOJA_PEDIDO D
   ON A.CODIGO_FILIAL = D.CODIGO_FILIAL_ORIGEM AND C.PEDIDO = D.PEDIDO
   WHERE D.LX_PEDIDO_ORIGEM IN(''3'',''5'')
   )
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END
   
 


 END    
 -----------------------------------------------------------------------------------------------------------------       
end

--------------------------------------------------------------------------------')
END
 ELSE 
	BEGIN 
	 EXEC ('alter trigger [dbo].[TRU_HR_LOJA_VENDA] on [dbo].[LOJA_VENDA]  for UPDATE NOT FOR REPLICATION  as    
-- Daniel 25-11-2019 Trigger criada para tratar promo��o de cliente unico e exclusivo
-- Daniel 29-06-2020 Alterada Trigger para considerar tamb�m o ID_TIPO_PROMOCAO 14 - Promo��o de Cupom
-- Daniel 29-09-2020 Alterada para preencher informacao de ID_TIPO_ORIGEM e ID_TIPO_MODALIDADE no LOJA_VENDA


begin    
      

 IF UPDATE(TICKET_IMPRESSO) OR UPDATE (DATA_HORA_CANCELAMENTO)
 BEGIN    
    
 INSERT INTO HR_PROMOCAO_CLIENTE ( ID_PROMOCAO,CPF_CLIENTE,DATA_HORA,TIPO)
 SELECT 
 HR_VENDA_PROMOCAO.ID_PROMOCAO,
 CLIENTES_VAREJO.CPF_CGC AS CPF_CLIENTE,
 HR_VENDA_PROMOCAO.DATA_PARA_TRANSFERENCIA AS DATA_HORA,
 TIPO =''U''
 FROM INSERTED
 INNER JOIN HR_VENDA_PROMOCAO
 ON HR_VENDA_PROMOCAO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL 
 AND HR_VENDA_PROMOCAO.TICKET = INSERTED.TICKET
 AND HR_VENDA_PROMOCAO.DATA_VENDA = INSERTED.DATA_VENDA
 INNER JOIN HR_PROMOCAO
 ON HR_VENDA_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO.ID_PROMOCAO 
 INNER JOIN CLIENTES_VAREJO
 ON INSERTED.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
 WHERE TICKET_IMPRESSO =1 
 AND DATA_HORA_CANCELAMENTO IS NULL 
 AND HR_PROMOCAO.ID_TIPO_PROMOCAO in(''5'',''14'' )
 AND NOT EXISTS(SELECT top 1 1 FROM HR_PROMOCAO_CLIENTE x WHERE x.TIPO =''U'' and x.cpf_cliente = CLIENTES_VAREJO.CPF_CGC and x.id_promocao = HR_PROMOCAO.ID_PROMOCAO)

 DELETE HR_PROMOCAO_CLIENTE
 FROM INSERTED
 INNER JOIN HR_VENDA_PROMOCAO
 ON HR_VENDA_PROMOCAO.CODIGO_FILIAL = INSERTED.CODIGO_FILIAL 
 AND HR_VENDA_PROMOCAO.TICKET = INSERTED.TICKET
 AND HR_VENDA_PROMOCAO.DATA_VENDA = INSERTED.DATA_VENDA
 INNER JOIN HR_PROMOCAO
 ON HR_VENDA_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO.ID_PROMOCAO 
 INNER JOIN CLIENTES_VAREJO
 ON INSERTED.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
 INNER JOIN HR_PROMOCAO_CLIENTE
 ON  HR_PROMOCAO.ID_PROMOCAO = HR_PROMOCAO_CLIENTE.ID_PROMOCAO AND CLIENTES_VAREJO.CPF_CGC = HR_PROMOCAO_CLIENTE.CPF_CLIENTE
 WHERE DATA_HORA_CANCELAMENTO IS NOT NULL AND HR_PROMOCAO.ID_TIPO_PROMOCAO = 9 AND HR_PROMOCAO_CLIENTE.TIPO =''U''

 if exists ( SELECT 1 FROM INSERTED A
  INNER JOIN LOJA_PEDIDO_VENDA B
  ON A.CODIGO_FILIAL = B.CODIGO_FILIAL_ORIGEM AND A.TICKET = b.TICKET
  INNER JOIN LOJA_PEDIDO C
  ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND B.PEDIDO = C.PEDIDO 
  WHERE C.TIPO_PEDIDO =''27'' ) 
   BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
   
  

  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE B.COD_FORMA_PGTO IN(''ZB'',''ZD'',''ZE'',''ZG'',''ZH'',''ZL'',''ZM'',''ZO'',''ZT'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END       
  
  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE c.TIPO_PGTO IN(''B'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 3 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 

   if not exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE c.TIPO_PGTO IN(''B'') or B.COD_FORMA_PGTO IN(''ZB'',''ZD'',''ZE'',''ZG'',''ZH'',''ZL'',''ZM'',''ZO'',''ZT'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
     
  if exists ( SELECT 1 from INSERTED a 
  inner join loja_venda_pgto b
  on a.CODIGO_FILIAL = b.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = b.LANCAMENTO_CAIXA and a.TERMINAL = b.TERMINAL
  inner join LOJA_VENDA_PARCELAS c
  on a.CODIGO_FILIAL = c.CODIGO_FILIAL and a.LANCAMENTO_CAIXA = c.LANCAMENTO_CAIXA and a.TERMINAL = c.TERMINAL
  WHERE B.COD_FORMA_PGTO IN(''CS'') ) 
   BEGIN 
  UPDATE B SET id_tipo_modalidade = 1 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END  


   IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_PEDIDO_VENDA C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND A.DATA_VENDA = C.DATA_VENDA AND A.TICKET = C.TICKET
   inner join loja_pedido d 
   on a.CODIGO_FILIAL = d.CODIGO_FILIAL_ORIGEM and c.PEDIDO = d.PEDIDO
   where D.LX_PEDIDO_ORIGEM =''4'')
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 3 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 
   
   
   IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_PEDIDO_VENDA C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL_ORIGEM AND A.DATA_VENDA = C.DATA_VENDA AND A.TICKET = C.TICKET
   inner join loja_pedido d 
   on a.CODIGO_FILIAL = d.CODIGO_FILIAL_ORIGEM and c.PEDIDO = d.PEDIDO
   where D.LX_TIPO_PRE_VENDA =''1'')
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END 


    IF exists(
   SELECT 1 FROM INSERTED A
   INNER JOIN LOJA_VENDA_SHOWROOMER C
   ON A.CODIGO_FILIAL = C.CODIGO_FILIAL AND A.TICKET = C.TICKET AND A.DATA_VENDA = C.DATA_VENDA
   INNER JOIN LOJA_PEDIDO D
   ON A.CODIGO_FILIAL = D.CODIGO_FILIAL_ORIGEM AND C.PEDIDO = D.PEDIDO
   WHERE D.LX_PEDIDO_ORIGEM IN(''3'',''5'')
   )
       BEGIN 
  UPDATE B SET ID_TIPO_ORIGEM = 2 FROM INSERTED A
  INNER JOIN LOJA_VENDA B
  ON A.TICKET = B.TICKET AND A.DATA_VENDA = B.DATA_VENDA AND A.CODIGO_FILIAL = B.CODIGO_FILIAL
   END
   
 


 END    
 -----------------------------------------------------------------------------------------------------------------       
end

--------------------------------------------------------------------------------')
END

    