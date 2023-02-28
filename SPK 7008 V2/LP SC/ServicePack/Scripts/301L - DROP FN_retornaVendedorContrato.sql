if exists (SELECT * FROM sys.objects WHERE type IN ('FN', 'IF', 'TF') and name='fn_retornaVendedorContrato')
    drop function [dbo].[fn_retornaVendedorContrato]
