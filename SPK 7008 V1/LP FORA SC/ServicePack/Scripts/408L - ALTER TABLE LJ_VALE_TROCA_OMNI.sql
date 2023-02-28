if exists( select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LJ_VALE_TROCA_OMNI' and COLUMN_NAME = 'NSU_CLIENTE' and CHARACTER_MAXIMUM_LENGTH < 48)
begin
	alter table LJ_VALE_TROCA_OMNI 
	alter column NSU_CLIENTE varchar(48) not null
end

if exists( select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'LJ_VALE_TROCA_OMNI' and COLUMN_NAME = 'NSU_HOST' and CHARACTER_MAXIMUM_LENGTH < 48)
begin
	alter table LJ_VALE_TROCA_OMNI 
	alter column NSU_HOST varchar(48) not null
end