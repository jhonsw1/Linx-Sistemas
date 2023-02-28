Create Procedure [dbo].[LX_VERIFICA_NUMBER_DADOS_CADASTRO] @NotaFiscal varchar(15), @SerieNota varchar(9)

as
-- DM 58430	- Diego Moreno - #3# - (20/09/2017) - Adequacao NFE 4.00. Melhoria para atender ao layout 4.0.
-- 04/05/2016 - FILLIPI RAMOS - #2# ID 2228 - Adicionado mais um parÃ¢metro para o preenchimento do verproc
-- 19/09/2014 - VICTOR KAJIYAMA - #1# TP 6519314 - PreparaÃ§Ã£o para compatibilidade SQL Server 2012
-- 28/08/2014 - FILENTI  - ALTERAÃ‡Ã•ES PARA LAYOUT 3.10

Declare @QuantNFE Int


select @QuantNFE= count(*) from DADOS_CADASTRO_XML_NFE where NF_SAIDA = @NotaFiscal +'AA' and SERIE_NF =@SerieNota

if @QuantNFE >0
    begin
		update dados_cadastro_xml_nfe set NF_SAIDA = RTRIM(LTRIM(NF_SAIDA))+'AA' where SERIE_NF <> @SerieNota and NF_SAIDA =@NotaFiscal
		update dados_cadastro_xml_nfe set NF_SAIDA = replace(RTRIM(LTRIM(NF_SAIDA))+'AA','AA','') where SERIE_NF = @SerieNota and NF_SAIDA =RTRIM(LTRIM(@NotaFiscal))+'AA'
	end


select @QuantNFE= count(*) from DADOS_CADASTRO_XML_NFE where NF_SAIDA = @NotaFiscal


if @QuantNFE >1
begin
	update dados_cadastro_xml_nfe set NF_SAIDA = RTRIM(LTRIM(NF_SAIDA))+'AA' where  NF_SAIDA =@NotaFiscal and SERIE_NF <> @SerieNota
end
