   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=1
PAPERSIZE=9
COLOR=2
                           Courier New                    _TITULO=Estoque De Produto Por Cor E Filial
CRIADOR=Usr_linx
PADRAO=N
PUBLICO=S
FAVORITOS=
                                   Curcadguia.pais                Curcadguia.cidade              %dtoc(date()) + ' - ' + time() + 'hs.'                                                          Times New Roman                'Pg: ' + alltrim(str(_pageno))                                                                 Times New Roman                "Cadastro de Guias por Cidade"                                  BankGothic Lt BT               'LinxPOS Manager'              Tahoma                         %'Cia Hering Store - ' + main.p_filial                           BankGothic Lt BT               curcadguia.cidade              Tahoma                          proper(Curcadguia.nome_vendedor)                                                               Tahoma                         =(Curcadguia.vendedor)+'-'+proper(Curcadguia.vendedor_apelido)                                                                   Tahoma                         proper(Curcadguia.agencia_guia)                                                                Tahoma                         Curcadguia.cgc_cpf             Tahoma                         Curcadguia.comissao            Tahoma                         "Guia Turismo Comercial"       Courier New                    	"Empresa"                      Courier New                    	"Ag�ncia"                      Courier New                    "CPF/ CNPJ"                    Courier New                    
"Comiss�o"                     Courier New                    	"Cidade:"                      Tahoma                         curcadguia.pais                                               Tahoma                         "Pa�s"                         Tahoma                         Curcadguia.telefone                                           Tahoma                         Curcadguia.ddd                                                Tahoma                         Curcadguia.celular                                            Tahoma                         Curcadguia.ddd_celular                                        Tahoma                         
"Telefone"                     Courier New                    	"Celular"                      Courier New                    Courier New                    Times New Roman                Times New Roman                BankGothic Lt BT               Tahoma                         Tahoma                         Tahoma                         Courier New                    dataenvironment                �Top = 139
Left = 636
Width = 326
Height = 353
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                     �PROCEDURE Init
IF !hfundofixohering.pageFrame.ActivePage=4
	messagebox("Ative a p�gina de Cadastro e Guias para Visualizar este Relatorio!!!",64+0,"Atenc�o")
	RETURN .f.
ENDIF


SELECT curcadguia
INDEX on pais+cidade TAG icid

ENDPROC
               ����    |  |                         B   %         3     #          �  U  �  %��  � � �
��| �] ��C�D Ative a p�gina de Cadastro e Guias para Visualizar este Relatorio!!!�@� Atenc�o�x�� B�-�� � F� � & �� � ��� � U  HFUNDOFIXOHERING	 PAGEFRAME
 ACTIVEPAGE
 CURCADGUIA PAIS CIDADE ICID Init,     ��1 ��q A s !2                       �       )   |                                  