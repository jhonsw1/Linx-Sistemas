if exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOJI DAS CRUZES' ) and 
    not exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOGI DAS CRUZES' )
	begin 
		update LOJA_LX_CIDADES_DDD set cidade = 'MOGI DAS CRUZES' where cidade = 'MOJI DAS CRUZES'
	end

if exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOJI-MIRIM') and
	not exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOGI MIRIM')
	begin
		update LOJA_LX_CIDADES_DDD set cidade = 'MOGI MIRIM' where cidade = 'MOJI-MIRIM'
	end

if exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOGI-GUACU') and
	not exists(select 1 from LOJA_LX_CIDADES_DDD where cidade = 'MOGI GUACU')
	begin
		update LOJA_LX_CIDADES_DDD set cidade = 'MOGI GUACU' where cidade = 'MOGI-GUACU'
	end