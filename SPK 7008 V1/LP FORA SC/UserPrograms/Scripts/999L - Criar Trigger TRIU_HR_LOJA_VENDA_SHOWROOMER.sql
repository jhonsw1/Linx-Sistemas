IF NOT EXISTS( SELECT 1 FROM SYS.triggers WHERE name ='TRIU_HR_LOJA_VENDA_SHOWROOMER')
EXEC
('
CREATE trigger [dbo].[TRIU_HR_LOJA_VENDA_SHOWROOMER] 
on [dbo].[LOJA_VENDA_SHOWROOMER]  
for INSERT,UPDATE 
NOT FOR REPLICATION  
as    

-- 02-07-2021 #4# - João Max -Melhorado para considerar apenas quando tiver valor de troca
-- 10-03-2020 #3# - João Max -Ajusado para Criar tipo de pagmento T para vendas de showrooming sem condi��o de pagamento
-- 18-20-2020     - Daniel   -Trigger criada para inserir hora de envio do pedido no Loja_venda
-- 06-02-2020     - João Max -Ajustado para atualizar dados dos clientes para resolver problema nas subidas dos pedidos
begin     

UPDATE D SET D.HR_ENVIO_PEDIDO = DATEADD(MINUTE,convert(int,c.VALOR_ATUAL),D.DATA_DIGITACAO) 
 FROM INSERTED A
  INNER JOIN LOJA_VENDA D
   ON A.CODIGO_FILIAL = D.CODIGO_FILIAL AND A.TICKET = D.TICKET and A.DATA_VENDA = D.DATA_VENDA
  LEFT JOIN W_PARAMETROS_LOJA C       
   ON C.PARAMETRO =''HR_TEMPO_CANCEL_SHOWR'' and c.CODIGO_FILIAL = a.CODIGO_FILIAL
  where d.HR_ENVIO_PEDIDO is null and c.VALOR_ATUAL is not NULL and isnumeric(c.VALOR_ATUAL)=1


/* 20191218 - João Max Deggau - HERING - Ajuste campos do cliente para pedido SHOWROOMING e PICKUP */  
  if exists(select top 1 1 from INSERTED lvs 
   inner join loja_Venda lv on lv.CODIGO_FILIAL = lvs.CODIGO_FILIAL
         and lv.TICKET = lvs.TICKET
         and lv.DATA_VENDA = lvs.DATA_VENDA
   inner join LOJA_VENDA_PGTO LVP on lv.CODIGO_FILIAL = LVP.CODIGO_FILIAL
         and lv.LANCAMENTO_CAIXA = LVP.LANCAMENTO_CAIXA
         and lv.TERMINAL = LVP.TERMINAL
   )
  begin 
   
   update cv
   set 
   INATIVO_PARA_CRM = isnull(cv.INATIVO_PARA_CRM,0) /* Se tiver nulo coloca 0 (zero) */
   ,SEXO = case when isnull(cv.sexo,'')='' then ''I'' else cv.SEXO end /* se tiver em branco ou nulo coloca I - Indefinido */
   ,STATUS = isnull(cv.STATUS,1)
   ,TIPO_LOGRADOURO = case when isnull(cv.TIPO_LOGRADOURO,'')='' and ltrim(rtrim(ISNULL(cv.ENDERECO,'')))!='' then substring(rtrim(ltrim(cv.ENDERECO)),1,1) else cv.SEXO end /* Se tiver em branco ou nulo coloca a primeira letra do endere�o */
   ,TELEFONE = case when isnull(cv.TELEFONE,'')='' and isnull(cv.CELULAR,'')!='' and isnull(cv.DDD_CELULAR,'')!='' then cv.CELULAR else cv.TELEFONE end /* Se TELEFONE estiver vazio coloca o celular */
   ,DDD = case when isnull(cv.TELEFONE,'')='' and isnull(cv.CELULAR,'')!='' and isnull(cv.DDD_CELULAR,'')!='' then cv.DDD_CELULAR else cv.DDD end /* Se TELEFONE estiver vazio coloca o ddd do celular */
   from INSERTED lvs 
   inner join loja_Venda lv on lv.CODIGO_FILIAL = lvs.CODIGO_FILIAL
       and lv.TICKET = lvs.TICKET
       and lv.DATA_VENDA = lvs.DATA_VENDA
   inner join loja_venda_pgto lvp on lv.CODIGO_FILIAL = lvp.CODIGO_FILIAL
       and lv.LANCAMENTO_CAIXA = lvp.LANCAMENTO_CAIXA
       and lv.TERMINAL = lvp.TERMINAL
   inner join CLIENTES_VAREJO cv on cv.CODIGO_CLIENTE = lv.CODIGO_CLIENTE
   where 
   (
    (cv.INATIVO_PARA_CRM is null)
   or (isnull(cv.sexo,'')='')
   or (cv.status is null)
   or (isnull(cv.TIPO_LOGRADOURO,'')='' and ltrim(rtrim(ISNULL(cv.ENDERECO,'')))!='')
   or (isnull(cv.TELEFONE,'')='' and isnull(cv.CELULAR,'')!='' and isnull(cv.DDD_CELULAR,'')!='')
   )
  END



  /* #3# - se nao existe pagamento e o valor da troca é igual ao valor negativo quando tem um showrooming associado a venda. Insere uma parcela TROCA com valor zerado para ajustar subida de pedido OMS sem pagamento*/
  if exists(select top 1 1 from LOJA_VENDA lv
                INNER JOIN INSERTED lvs on lv.CODIGO_FILIAL = lvs.CODIGO_FILIAL
                    and lv.TICKET = lvs.TICKET
                    and lv.DATA_VENDA = lvs.DATA_VENDA
                left join LOJA_VENDA_PARCELAS lvp on lv.CODIGO_FILIAL = lvp.CODIGO_FILIAL
                    and lv.LANCAMENTO_CAIXA = lvp.LANCAMENTO_CAIXA
                    and lv.TERMINAL = lvp.TERMINAL 
                    and not (lvp.TIPO_PGTO = ''Y'' and VALOR <=  0.00)
                where lvp.LANCAMENTO_CAIXA is null
                AND DATA_HORA_CANCELAMENTO IS NULL
                and lv.VALOR_TROCA = lv.VALOR_PAGO * -1
				AND lv.VALOR_TROCA >0 /* #4# */
                )
  begin 
   insert into LOJA_VENDA_PARCELAS (CODIGO_FILIAL,TERMINAL,LANCAMENTO_CAIXA,PARCELA,CODIGO_ADMINISTRADORA,TIPO_PGTO,VALOR,VENCIMENTO,NUMERO_TITULO,MOEDA,AGENCIA,BANCO,CONTA_CORRENTE,NUMERO_APROVACAO_CARTAO,PARCELAS_CARTAO
        , VALOR_CANCELADO,CHEQUE_CARTAO,NUMERO_LOTE,FINALIZACAO,BAIXA,REDE_CONTROLADORA,COTACAO,VALOR_MOEDA ,TROCO, DATA_HORA_TEF, DATA_PARA_TRANSFERENCIA, CHEQUE_DIGITO, ID_DOCUMENTO_ECF, ID_PLANO_FINANCIAMENTO, VALOR_PARCELA_FINANC
        , VALOR_TAC, NSU_CANCELAMENTO, COD_CREDENCIADORA)
  select CODIGO_FILIAL                 = lv.CODIGO_FILIAL
        , TERMINAL                      = lv.TERMINAL_PGTO
        , LANCAMENTO_CAIXA              = lv.LANCAMENTO_CAIXA
        /* Monta Regra da Parcela */
        , PARCELA                       = right(''00''+convert(varchar(2),isnull((
                                            select max(convert(int,case when isnumeric(rtrim(parcela)+''E0'')=0 then 0 else rtrim(PARCELA) end)) 
                                            from LOJA_VENDA_PARCELAS x where lv.CODIGO_FILIAL = x.CODIGO_FILIAL
                                                and lv.LANCAMENTO_CAIXA = x.LANCAMENTO_CAIXA
                                                and lv.TERMINAL = x.TERMINAL 
                                            ),0)+1),2)
        , CODIGO_ADMINISTRADORA         = null
        , TIPO_PGTO                     = ''D'' /* DINHEIRO */
        , VALOR                         = 0.00 /* Sempre valor zerado */
        , VENCIMENTO                    = convert(date,getdate())
        , NUMERO_TITULO                 = lv.TICKET
        , MOEDA                         = ''R$''
        , AGENCIA                       = null
        , BANCO                         = null
        , CONTA_CORRENTE                = null
        , NUMERO_APROVACAO_CARTAO       = lv.TICKET
        , PARCELAS_CARTAO               = 0
        , VALOR_CANCELADO               = 0
        , CHEQUE_CARTAO                 = lv.TICKET
        , NUMERO_LOTE                   = null
        , FINALIZACAO                   = null
        , BAIXA                         = 0
        , REDE_CONTROLADORA             = null
        , COTACAO                       = 1
        , VALOR_MOEDA                   = 0
        , TROCO                         = 0
        , DATA_HORA_TEF                 = null
        , DATA_PARA_TRANSFERENCIA       = GETDATE()
        , CHEQUE_DIGITO                 = null
        , ID_DOCUMENTO_ECF              = null
        , ID_PLANO_FINANCIAMENTO        = null
        , VALOR_PARCELA_FINANC          = null
        , VALOR_TAC                     = 0
        , NSU_CANCELAMENTO              = null
        , COD_CREDENCIADORA             = null
   from LOJA_VENDA lv                  
    INNER JOIN INSERTED lvs on lv.CODIGO_FILIAL = lvs.CODIGO_FILIAL
        and lv.TICKET = lvs.TICKET
        and lv.DATA_VENDA = lvs.DATA_VENDA
    left join LOJA_VENDA_PARCELAS lvp on lv.CODIGO_FILIAL = lvp.CODIGO_FILIAL
        and lv.LANCAMENTO_CAIXA = lvp.LANCAMENTO_CAIXA
        and lv.TERMINAL = lvp.TERMINAL 
        and not (lvp.TIPO_PGTO = ''Y'' and VALOR <=  0.00)
    where lvp.LANCAMENTO_CAIXA is null
    AND DATA_HORA_CANCELAMENTO IS NULL 
    and lv.VALOR_TROCA = lv.VALOR_PAGO * -1
  end
  /* Fim - #3# - se nao existe pagamento e o valor da troca é igual ao valor negativo quando tem um showrooming associado a venda. Insere uma parcela TROCA com valor zerado para ajustar subida de pedido OMS sem pagamento*/

END')