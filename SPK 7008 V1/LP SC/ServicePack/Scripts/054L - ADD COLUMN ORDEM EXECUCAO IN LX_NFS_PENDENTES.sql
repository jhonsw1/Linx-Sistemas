IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LX_NFS_PENDENTES' AND COLUMN_NAME = 'ORDEM_EXECUCAO' )
	ALTER TABLE LX_NFS_PENDENTES ADD ORDEM_EXECUCAO int 