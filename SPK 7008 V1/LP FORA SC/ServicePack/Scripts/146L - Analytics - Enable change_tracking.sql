------ GERA OS SCRIPTS PARA EXECUÇÃO DAS TABELAS QUE ESTÃO TRACKEADA
if not exists (select * from sys.objects where name = 'LX_ANALYTICS')
begin
	return
end;

declare	@table_name sysname, @schema sysname, @sql varchar(max)

begin try 
	begin tran
	-- lista as tabelas que ainda não foram para o cortex(amazon)
	declare cur_table cursor for 
		select tabela, sch_name, cmdEnable
		from	dbo.tb_cmdtracking
	open cur_table
	fetch next from cur_table into	@table_name, @schema, @sql
	while @@fetch_status = 0
	begin
		if not exists (select * from sys.change_tracking_tables where object_id = object_id(@schema + '.' + @table_name)) --Valida se não existe change_tracking antes de ativar
			exec (@sql)
		
	   fetch next from cur_table into	@table_name, @schema, @sql
	end
	close cur_table
	deallocate cur_table;

	delete cmd
	from	sys.change_tracking_tables as ct
	inner join sys.tables as tb  on ct.object_id = tb.object_id
	inner join sys.schemas as sc on tb.schema_id = sc.schema_id
	inner join dbo.tb_cmdtracking as cmd on tb.name = cmd.tabela and sc.name = cmd.sch_name
	
	commit tran
end try
begin catch

	declare @ErrorMessage  nvarchar(4000), @ErrorSeverity int, @ErrorState int

	select	@ErrorMessage = error_message(), @ErrorSeverity = error_severity(),	@ErrorState = error_state()
	
	if @@trancount > 0 rollback tran
	
	raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState)
end catch