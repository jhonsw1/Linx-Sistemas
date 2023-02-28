CREATE PROCEDURE dbo.LX_WS_OLE_VALID (@RETORNO VARCHAR(255) = 'OK' OUTPUT)
AS
BEGIN
/*
DECLARE @RETORNO VARCHAR(500)
EXEC LX_WS_OLE_VALID @RETORNO OUTPUT
SELECT @RETORNO
*/

if not exists (SELECT value_in_use FROM sys.configurations where name='OLE AUTOMATION PROCEDURES' and value_in_use = 1) 
begin
    SET @RETORNO =  'ATENCAO: NECESSARIO HABILITAR Os procedimentos de automacao OLE do SQL Server'+char(13)+char(10)+'EXECUTE VIA SCRIPT:'+char(13)+char(10)+'sp_configure [show advanced options], 1;  '+char(13)+char(10)+'GO  '+char(13)+char(10)+' RECONFIGURE;  '+char(13)+char(10)+'GO  '+char(13)+char(10)+'sp_configure [Ole Automation Procedures], 1;  '+char(13)+char(10)+'GO  '+char(13)+char(10)+'RECONFIGURE;  '+char(13)+char(10)+'GO   '
    GOTO RETORNO
end
else
    BEGIN
        SET @RETORNO = 'OK'
    END

if (SELECT count(*) as total
    FROM master.sys.database_permissions [dp] 
    JOIN master.sys.system_objects [so] ON dp.major_id = so.object_id
    JOIN master.sys.sysusers [usr] ON usr.uid = dp.grantee_principal_id 
    AND usr.name = system_user
    WHERE permission_name = 'EXECUTE' 
    AND (so.name = 'sp_OACreate'
      OR so.name = 'sp_OADestroy'
      OR so.name = 'sp_OAGetErrorInfo'
      OR so.name = 'sp_OAGetProperty'
      OR so.name = 'sp_OAMethod'
      OR so.name = 'sp_OAStop'
      OR so.name = 'sp_OASetProperty')) < 7 and IS_SRVROLEMEMBER ('sysadmin')  <> 1 
--if IS_SRVROLEMEMBER ('sysadmin')  <> 1
  begin
      SET @RETORNO = 
        'CONCEDER OS DIREITOS (sp_OACreate, sp_OADestroy, sp_OAGetErrorInfo, sp_OAGetProperty, sp_OAMethod, sp_OASetProperty, sp_OAStop) AO USUARIO'+char(13)+char(10)+
        'SCRIPT:'+char(13)+char(10)+
        'GRANT EXECUTE ON master..sp_OACreate to ['+system_user+']'+char(13)+char(10)
      --   SET @RETORNO = 'ERRO: Necessario incluir o usuario ['+system_user+'] ao grupo sysadmin no banco de dados'
        GOTO RETORNO
  end

GOTO RETORNO

END

RETORNO:
    RETURN  

