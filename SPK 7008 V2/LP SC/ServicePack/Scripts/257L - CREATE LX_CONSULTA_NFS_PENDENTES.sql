CREATE PROCEDURE [DBO].[Lx_consulta_nfs_pendentes](@CODIGO_FILIAL AS VARCHAR(8),  @QTDE_DIAS AS INT)
WITH ENCRYPTION
AS
  -- 16/08/2019 - Fillipi Ramos    - MODASP-4990- #5# - Criação da coluna para Ordenação de Processamento das notas.
  -- 06/02/2017 - Wendel Crespigio - #4# - Tratamento Demanda 61410 para nao mais considerar notas modelo 55 com status de nao enviada Status 1 status log 0 somente sera considerada notas enviadas para a SEFAZ
  -- 15/08/2017 - Fillipi Ramos    - #3# - Tratamento para respeitar o parametro EMISSAO_DE_NFE, para não trazer notas no modelo 55 quando o parametro estiver como .F.
  -- 12/08/2016 - DIEGO MORENO     - #2# - CORREÇÃO NOS FILTROS  	
  -- 04/08/2016 - DIEGO MORENO     - #1# - MELHORIA NO WHERE PARA AS CONSULTAS DE NFE PARA QUE A PROCEDURE BUSQUE APENAS NOTAS COM O STATUS QUE VIABILIZE A CONSULTA NO MID DE NFE.

BEGIN
--Inicio - #3#
declare @P_Emite_nfe bit 

SELECT @P_Emite_nfe = case when VALOR_ATUAL = '.T.' then 1 else 0 end 
FROM   W_PARAMETROS_LOJA
WHERE  PARAMETRO = 'EMISSAO_DE_NFE' and CODIGO_FILIAL = @CODIGO_FILIAL
--Fim - #3# 

     INSERT INTO DBO.LX_NFS_PENDENTES
                  (CODIGO_FILIAL,
                   FILIAL,
                   NF_NUMERO,
                   SERIE_NF,
                   LJ_LX_ID_ACAO_PDV,
                   CHAVE_NFE,
                   NUMERO_MODELO_FISCAL,
                   EMAIL_NFE,
                   URL_ENVIO,
                   HOSTNAME,
                   DTHORA_ULT_CONSULTA, 
				   ORDEM_EXECUCAO) --VENDAS QUE DEVEM SER AUTORIZADAS #5#
      SELECT R.CODIGO_FILIAL,
             R.FILIAL,
             R.NF_NUMERO,
             R.SERIE_NF,
             R.LJ_LX_ID_ACAO_PDV,
             R.CHAVE_NFE,
             R.NUMERO_MODELO_FISCAL,
             R.EMAIL_NFE,
             R.URL_ENVIO,
             R.HOSTNAME,
             R.DTHORA_ULT_CONSULTA,
			 ORDEM_EXECUCAO
      FROM   (SELECT LV.CODIGO_FILIAL,
                     LV.FILIAL,
                     LOJA_NOTA_FISCAL.NF_NUMERO,
                     LOJA_NOTA_FISCAL.SERIE_NF,
                     Isnull(LOJA_NOTA_FISCAL.CHAVE_NFE, '')CHAVE_NFE,
                     L.NUMERO_MODELO_FISCAL,
                     Isnull(CASE
                              WHEN Len(Rtrim(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CLIENTES_VAREJO.EMAIL))) = 0 THEN NULL
                              WHEN L.NUMERO_MODELO_FISCAL = '65' THEN Rtrim(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO)
                              ELSE
                                CASE
                                  WHEN Len(Rtrim(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CLIENTES_VAREJO.EMAIL))) <= 60 THEN Rtrim(COALESCE(LOJA_NOTA_FISCAL_XML.EMAIL_RETORNO, CLIENTES_VAREJO.EMAIL))
                                  ELSE NULL
                                END
                            END, '')                       AS EMAIL_NFE,
                     CASE
                       WHEN L.NUMERO_MODELO_FISCAL = '55' THEN ''
                       ELSE
                         CASE
                           WHEN L.NUMERO_MODELO_FISCAL = '65' THEN
                             CASE
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '52'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 'I'
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '52'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 'I'
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '42'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 'C'
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '42'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 'C'
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '1'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 'A'
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '2'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 'R'
                               ELSE NULL
                             END
                         END
                     END                                   AS LJ_LX_ID_ACAO_PDV,
                     Isnull(LOJA_NOTA_FISCAL.URL_ENVIO, '')AS URL_ENVIO,
                     Host_name()                           HOSTNAME,
                     Getdate()                             DTHORA_ULT_CONSULTA,
					CASE
                       WHEN L.NUMERO_MODELO_FISCAL = '55' THEN ''
                       ELSE
                         CASE
                           WHEN L.NUMERO_MODELO_FISCAL = '65' THEN
                             CASE
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '52'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 2
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '52'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 2
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '42'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 1
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '42'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 1
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '1'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '0' THEN 3
                               WHEN LOJA_NOTA_FISCAL.STATUS_NFE = '2'
                                    AND LOJA_NOTA_FISCAL.LOG_STATUS_NFE = '99' THEN 4
                               ELSE 5
                             END
                         END
                     END as  ORDEM_EXECUCAO						
              FROM   dbo.LOJA_NOTA_FISCAL (NOLOCK)
                     INNER JOIN dbo.SERIES_NF C (NOLOCK)
                             ON dbo.LOJA_NOTA_FISCAL.SERIE_NF = C.SERIE_NF
                     INNER JOIN dbo.CTB_ESPECIE_SERIE L (NOLOCK)
                             ON C.ESPECIE_SERIE = L.ESPECIE_SERIE
                     INNER JOIN dbo.LOJAS_VAREJO LV (NOLOCK)
                             ON LV.CODIGO_FILIAL = LOJA_NOTA_FISCAL.CODIGO_FILIAL
                     LEFT JOIN dbo.CLIENTES_VAREJO CLIENTES_VAREJO (NOLOCK)
                            ON LOJA_NOTA_FISCAL.CODIGO_CLIENTE = CLIENTES_VAREJO.CODIGO_CLIENTE
                     LEFT JOIN dbo.LOJA_NOTA_FISCAL_XML (NOLOCK)
                            ON LOJA_NOTA_FISCAL.CODIGO_FILIAL = LOJA_NOTA_FISCAL_XML.CODIGO_FILIAL
                               AND LOJA_NOTA_FISCAL.NF_NUMERO = LOJA_NOTA_FISCAL_XML.NF_NUMERO
                               AND LOJA_NOTA_FISCAL.SERIE_NF = LOJA_NOTA_FISCAL_XML.SERIE_NF
              WHERE  ( 	LOJA_NOTA_FISCAL.CODIGO_FILIAL = @CODIGO_FILIAL 
							AND LOJA_NOTA_FISCAL.STATUS_NFE NOT IN (2,4,5,49,59,70) and log_status_nfe <> 99 --#2#
							and ((L.NUMERO_MODELO_FISCAL = '55' and @P_Emite_nfe = 1 
							and LOJA_NOTA_FISCAL.STATUS_NFE <> 1 ) --#4#
							or L.NUMERO_MODELO_FISCAL = '65') --#3#
					) --#1#
                     AND LOJA_NOTA_FISCAL.DATA_HORA_EMISSAO BETWEEN Getdate() - @QTDE_DIAS AND Dateadd(MINUTE, -10, Getdate()))R
      WHERE  R.NF_NUMERO NOT IN (SELECT LNP.NF_NUMERO
                                 FROM   dbo.LX_NFS_PENDENTES LNP
                                 WHERE  R.CODIGO_FILIAL = LNP.CODIGO_FILIAL
                                        AND R.NF_NUMERO = LNP.NF_NUMERO
                                        AND R.SERIE_NF = LNP.SERIE_NF) -- CONSULTA AS NFS PENDENTES PARA O HOSTNAME DO SERVICO
      SELECT *
      FROM   DBO.LX_NFS_PENDENTES
      WHERE  HOSTNAME = Host_name()
             AND LJ_LX_ID_ACAO_PDV IS NOT NULL
      ORDER  BY ORDEM_EXECUCAO asc,				
				NF_NUMERO DESC,
                NUMERO_MODELO_FISCAL
  END 