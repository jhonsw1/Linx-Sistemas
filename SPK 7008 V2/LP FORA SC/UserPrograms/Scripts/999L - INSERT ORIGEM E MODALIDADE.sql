IF NOT EXISTS( SELECT 1 FROM HR_VENDA_TIPO_MODALIDADE )
	BEGIN
		EXEC('
	
insert into HR_VENDA_TIPO_MODALIDADE(ID_TIPO_MODALIDADE,DESC_TIPO_MODALIDADE,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''1'',''WHATSAPP'',''2020-09-03 00:00:00'',''0'') 
insert into HR_VENDA_TIPO_MODALIDADE(ID_TIPO_MODALIDADE,DESC_TIPO_MODALIDADE,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''2'',''VENDA NORMAL'',''2020-09-03 00:00:00'',''0'') 
insert into HR_VENDA_TIPO_MODALIDADE(ID_TIPO_MODALIDADE,DESC_TIPO_MODALIDADE,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''3'',''PARCEIROS - RAPPI'',''2020-09-03 00:00:00'',''0'') 

insert into HR_VENDA_TIPO_ORIGEM(ID_TIPO_ORIGEM,DESC_TIPO_ORIGEM,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''1'',''OMNI SMART'',''2020-09-03 00:00:00'',''0'') 
insert into HR_VENDA_TIPO_ORIGEM(ID_TIPO_ORIGEM,DESC_TIPO_ORIGEM,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''2'',''LINX MOBILE'',''2020-09-03 00:00:00'',''0'') 
insert into HR_VENDA_TIPO_ORIGEM(ID_TIPO_ORIGEM,DESC_TIPO_ORIGEM,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''3'',''OMNI'',''2020-09-03 00:00:00'',''0'') 
insert into HR_VENDA_TIPO_ORIGEM(ID_TIPO_ORIGEM,DESC_TIPO_ORIGEM,DATA_PARA_TRANSFERENCIA,INATIVO)  VALUES  (''4'',''LINXPOS'',''2020-09-03 00:00:00'',''0'') ')
END