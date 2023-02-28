-- Inclusão de Parâmetros 

IF NOT EXISTS(SELECT parametro 
              FROM   parametros 
              WHERE  parametro = 'QRLINX_CHANNEL')
  INSERT INTO dbo.parametros 
              (parametro, 
               penult_atualizacao, 
               valor_default, 
               ult_atualizacao, 
               valor_atual, 
               desc_parametro, 
               tipo_dado, 
               range_valor_atual, 
               global, 
               escopo, 
               por_usuario_ok, 
               nota_programador, 
               permite_por_empresa, 
               envia_para_loja, 
               permite_por_loja, 
               permite_por_terminal, 
               permite_alterar_na_loja, 
               permite_alterar_no_terminal, 
               envia_para_representante, 
               permite_por_representante, 
               permite_alterar_no_representante) 
  VALUES      ('QRLINX_CHANNEL', 
               Getdate(), 
               '', 
               Getdate(), 
               '', 
				'Identificacao do PDV no QRLINX', 
				'C', 
				'', 
				'0', 
				'0', 
				'0', 
				'', 
				'1', 
				'1', 
				'1', 
				'0', 
				'0', 
				'0', 
				'0', 
				'0', 
				'0' ) 
