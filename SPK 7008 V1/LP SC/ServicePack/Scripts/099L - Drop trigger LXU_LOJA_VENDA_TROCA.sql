IF EXISTS (SELECT * FROM sys.OBJECTS WHERE  NAME = 'LXU_LOJA_VENDA_TROCA' and type = 'TR')
begin 
   DROP TRIGGER [DBO].[LXU_LOJA_VENDA_TROCA] 
end