if not exists (select * from sys.objects where name = 'LX_ANALYTICS')
begin
	return
end;

if not exists(select * from sys.objects where name = 'tb_cmdtracking')
begin
	create table dbo.tb_cmdtracking (	sch_name sysname, tabela sysname, id int, cmdDisable varchar(max), cmdEnable varchar(max)
										constraint xpktb_cmdtracking primary key(tabela, sch_name))
end;

delete dbo.tb_cmdtracking --Limpa informação angiga.

insert	dbo.tb_cmdtracking (sch_name, tabela, id, cmdDisable, cmdEnable)
select	sc.name, tb.name, tb.object_id,
		' alter table ['  + sc.name + '].[' + tb.name + '] disable change_tracking' as cmdDisable,
		' alter table ['  + sc.name + '].[' + tb.name + '] enable change_tracking' as cmdEnable
from	sys.change_tracking_tables as ct
inner join sys.tables as tb  on ct.object_id = tb.object_id
inner join sys.schemas as sc on tb.schema_id = sc.schema_id
where	not exists (select sch_name, tabela from dbo.tb_cmdtracking cmd where tb.name = cmd.tabela and sc.name = cmd.sch_name)


-- lista as tabelas que ainda não foram para o cortex(amazon)
declare	@table_name sysname, @schema sysname, @sql varchar(max)
declare cur_table cursor for 
	select tabela, sch_name, cmdDisable
	from	dbo.tb_cmdtracking
open cur_table
fetch next from cur_table into	@table_name, @schema, @sql
while @@fetch_status = 0
begin
	if exists (select * from sys.change_tracking_tables where object_id = object_id(@schema + '.' + @table_name))
		exec (@sql)
   fetch next from cur_table into	@table_name, @schema, @sql
end
close cur_table
deallocate cur_table;
