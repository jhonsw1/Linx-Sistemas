CREATE Procedure [dbo].[LX_GERA_NFE] @NotaFiscal varchar(9), @SerieNota varchar(3), @FilialNota varchar(25), @VersaoXML varchar(10), @SEFAZ bit = 0  , @APP_VERSAO varchar(20) = NULL
As  

-- DM 58430	- Diego Moreno - #3# - (20/09/2017) - Adequacao NFE 4.00. Melhoria para atender ao layout 4.0.
-- 04/05/2016 - FILLIPI RAMOS - #2# ID 2228 - Adicionado mais um parâmetro para o preenchimento do verproc
-- 19/09/2014 - VICTOR KAJIYAMA - #1# TP 6519314 - Preparação para compatibilidade SQL Server 2012
-- 28/08/2014 - FILENTI  - ALTERAÇÕES PARA LAYOUT 3.10

Declare @ErrNo Int, @ErrMsg VarChar(255)  
  
if (@VersaoXML Not In ('1.10', '2.00', '3.10','4.00'))  
Begin  
 Set @ErrNo = 30002  
   
 If (@VersaoXML Is Null)  
  Set @ErrMsg = 'A versão do XML da NFe deve ser passada no quarto parâmetro.'  
 Else If (@VersaoXML Not In ('1.10', '2.00', '3.10','4.00'))  
  Set @ErrMsg = 'O valor "' + rTrim(@VersaoXML) + '" para a versão do XML da NFe não é válido. Seu valor só pode ser "1.10" ou "2.00".'  
   
 GoTo Error  
End  
  
If (@VersaoXML = '1.10')  
Begin  
 If @SEFAZ = 1  
  Execute LX_GERA_NFE_SEFAZ @NotaFiscal, @SerieNota, @FilialNota  
 Else  
  Execute LX_GERA_NFE_IT @NotaFiscal, @SerieNota, @FilialNota  
End  
Else If (@VersaoXML = '2.00')  
Begin  
 If @SEFAZ = 1  
  Execute LX_GERA_NFE_SEFAZ_2_00 @NotaFiscal, @SerieNota, @FilialNota  
 Else  
  Execute LX_GERA_NFE_IT_2_00 @NotaFiscal, @SerieNota, @FilialNota  
End  
Else If (@VersaoXML = '3.10')  
Begin  
 If @SEFAZ = 1  
  Execute LX_GERA_NFE_SEFAZ_3_10 @NotaFiscal, @SerieNota, @FilialNota, 0, @APP_VERSAO  
 Else  
  Execute LX_GERA_NFE_SEFAZ_3_10 @NotaFiscal, @SerieNota, @FilialNota , 0, @APP_VERSAO 
End 
Else If (@VersaoXML = '4.00')  
--#3# INICIO
Begin  
 If @SEFAZ = 1  
  Execute LX_GERA_NFE_SEFAZ_4_00 @NotaFiscal, @SerieNota, @FilialNota, 0, @APP_VERSAO  
 Else  
  Execute LX_GERA_NFE_SEFAZ_4_00 @NotaFiscal, @SerieNota, @FilialNota , 0, @APP_VERSAO 
End 
--#3# FIM
Return  
  
Error:  
 --RaisError @ErrNo @ErrMsg   #1#
 	RAISERROR (@ERRMSG, @ERRNO, 1) -- #1#
