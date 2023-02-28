if exists(select 1 FROM PARAMETROS_LOJA WHERE PARAMETRO IN ('PEELA_URL') AND ISNULL(VALOR_ATUAL,'') != '')
	AND NOT exists(select 1 FROM PARAMETROS_LOJA WHERE PARAMETRO IN ('SERV_HUB_GIFT_PARTNER') AND ISNULL(VALOR_ATUAL,'') != '') 
BEGIN

	declare @PARAMETRO varchar(25), @CODIGO_FILIAL char(06), @VALOR_ATUAL varchar(100), @PERMITE_ALTERAR_NA_LOJA int

	Declare curParametrosHub Cursor Fast_Forward 
	For 
	SELECT 'PEELA_URL' AS PARAMETRO,
			CODIGO_FILIAL,
			CASE WHEN VALOR_ATUAL LIKE '%GIVEX%' THEN 'Givex'
					WHEN VALOR_ATUAL LIKE '%TODO%' THEN 'Todo'
					WHEN VALOR_ATUAL LIKE '%NAPSE%' THEN 'Napse'
					WHEN VALOR_ATUAL LIKE '%PEELA%' THEN 'Peela'
			ELSE '' END VALOR_ATUAL,
			1 AS PERMITE_ALTERAR_NA_LOJA
	FROM PARAMETROS_LOJA 
	WHERE PARAMETRO IN ('PEELA_URL')

	Open curParametrosHub
	Fetch Next From curParametrosHub Into @PARAMETRO, @CODIGO_FILIAL, @VALOR_ATUAL, @PERMITE_ALTERAR_NA_LOJA
	While @@FETCH_STATUS = 0
	Begin
		IF EXISTS( SELECT 1 FROM PARAMETROS_LOJA WHERE PARAMETRO = @PARAMETRO AND CODIGO_FILIAL = @CODIGO_FILIAL)
		BEGIN
			IF NOT EXISTS( SELECT 1 FROM PARAMETROS_LOJA WHERE PARAMETRO = 'SERV_HUB_GIFT_PARTNER' AND CODIGO_FILIAL = @CODIGO_FILIAL)
			BEGIN
				INSERT INTO PARAMETROS_LOJA (PARAMETRO, CODIGO_FILIAL, VALOR_ATUAL, PERMITE_ALTERAR_NA_LOJA)
				VALUES ('SERV_HUB_GIFT_PARTNER', @CODIGO_FILIAL, @VALOR_ATUAL, @PERMITE_ALTERAR_NA_LOJA)
			END
			ELSE
			BEGIN
				UPDATE PARAMETROS_LOJA SET VALOR_ATUAL = @VALOR_ATUAL
				WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND PARAMETRO = 'SERV_HUB_GIFT_PARTNER'
			END
		END

		Fetch Next From curParametrosHub Into @PARAMETRO, @CODIGO_FILIAL, @VALOR_ATUAL, @PERMITE_ALTERAR_NA_LOJA
	end
	Close curParametrosHub
	Deallocate curParametrosHub

	---ATUALIZANDO PARAMETRO
	UPDATE PARAMETROS_LOJA SET 
		VALOR_ATUAL =
			CASE
				--HOMOG 
					WHEN VALOR_ATUAL = 'https://hfllinxintegracaowebservicenapse-hom.azurewebsites.net/gift/NapseGiftService.asmx' 
						THEN 'https://hfllinxintegracaogiftwebapi-hom.azurewebsites.net/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'http://linxgiftservicesstg.azurewebsites.net/givex/gift/GiftService.asmx' 
						THEN 'https://hfllinxintegracaogiftwebapi-hom.azurewebsites.net/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'https://hfllinxintegracaowebservicegivex-hom.azurewebsites.net/gift/GivexGiftService.asmx'  
					THEN 'https://hfllinxintegracaogiftwebapi-hom.azurewebsites.net/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'https://hfllinxintegracaowebservicetodo-hom.azurewebsites.net/gift/TodoGiftService.asmx'
					THEN 'https://hfllinxintegracaogiftwebapi-hom.azurewebsites.net/LinxServiceApi/'

					--PROD					
					WHEN VALOR_ATUAL = 'http://servicehub.linx.com.br/givex/gift/GivexGiftService.asmx'
					THEN 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'http://servicehub.linx.com.br/Todo/gift/TodoGiftService.asmx'
					THEN 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'https://servicehub.linx.com.br/napse/Gift/NapseGiftService.asmx'
					THEN 'http://servicehub.linx.com.br/api/v1/LinxServiceApi/'

					WHEN VALOR_ATUAL = 'https://frontend-givex.azurefd.net/gift/GivexGiftService.asmx'
					THEN 'https://frontend-givex.azurefd.net/LinxServiceApi/'

			ELSE VALOR_ATUAL END 
	WHERE PARAMETRO IN ('PEELA_URL') AND ISNULL(VALOR_ATUAL,'') != '' 
END
