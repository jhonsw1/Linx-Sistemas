   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              �DRIVER=winspool
DEVICE=Generic / Text Only
OUTPUT=USB001
ORIENTATION=0
PAPERSIZE=1
ASCII=0
COPIES=1
DEFAULTSOURCE=7
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=2
COLLATE=1
                                      ?  '  winspool  Generic / Text Only  USB001                                                   �Generic / Text Only              � 4C�  �4d   X  X  A4                                                            ����                DINU"   4  ��s�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Courier New                    sTITULO=Etiqueta Termica / Generica Direta [modelo Linx E Do Cliente]
CRIADOR=Sa
PADRAO=S
PUBLICO=N
FAVORITOS=
               recno()                        eval(xDetalhe_Etiqueta+'()')                                    Courier New                    Courier New                    dataenvironment                aTop = 260
Left = 181
Width = 526
Height = 356
DataSource = .NULL.
Name = "Dataenvironment"
                                XPROCEDURE Init
if !used('vtmp_tabelas_preco_barra_00')
	=f_msg(['Mensagem do Init do Report:' +chr(13)+'Tabela Tempor�ria N�o Foi Gerado...','Aten��o..'])
	Return .f.
endif

if type('oprel_xFuncEXE')='U'
	=f_msg(['Mensagem do Init do Report:' +chr(13)+'Fun��o a Imprimir N�o Foi Ainda Selecionada...','Aten��o..'])
	Return .f.
else
	Public xDetalhe_Etiqueta
	xDetalhe_Etiqueta = oprel_xFuncEXE
endif

sele vtmp_tabelas_preco_barra_00
INDEX ON codigo_tab_preco+produto+cor_produto+STR(tamanho)+codigo_barra TAG iBarras

ENDPROC
PROCEDURE Destroy
Release xDetalhe_Etiqueta
ENDPROC
                        ���    �  �                        b�   %   ^      �     }          �  U  ~+ %�C� vtmp_tabelas_preco_barra_00�
��� �e ��C�X 'Mensagem do Init do Report:' +chr(13)+'Tabela Tempor�ria N�o Foi Gerado...','Aten��o..'�  �� B�-�� �" %�C� oprel_xFuncEXEb� U��4�p ��C�c 'Mensagem do Init do Report:' +chr(13)+'Fun��o a Imprimir N�o Foi Ainda Selecionada...','Aten��o..'�  �� B�-�� �P� 7� � T� �� �� � F� �  & �� � � C� Z� ���	 � U
  F_MSG XDETALHE_ETIQUETA OPREL_XFUNCEXE VTMP_TABELAS_PRECO_BARRA_00 CODIGO_TAB_PRECO PRODUTO COR_PRODUTO TAMANHO CODIGO_BARRA IBARRAS
  <�  � U  XDETALHE_ETIQUETA Init,     �� Destroy=    ��1 �Qq A "q � q � A r 3 q 1                               4  M      )   �                                                        cursor                        7Top = 13
Left = 15
Height = 268
Width = 184
Alias = "v_tabelas_preco_barra_00"
Database = c:\docume~1\eduard~1.fal\config~1\temp\visuallinx6.01\lx_temp.dbc
CursorSource = "v_tabelas_preco_barra_00"
Name = "Cursor1"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         �DRIVER=winspool
DEVICE=Generic / Text Only
OUTPUT=USB001
ORIENTATION=0
PAPERSIZE=1
ASCII=0
COPIES=1
DEFAULTSOURCE=7
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=2
COLLATE=1
                                      ?  '  winspool  Generic / Text Only  USB001                                                   �Generic / Text Only              � 4C�  �4d   X  X  A4                                                            ����                DINU"   4  ��s�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Courier New                    sTITULO=Etiqueta Termica / Generica Direta [modelo Linx E Do Cliente]
CRIADOR=Sa
PADRAO=S
PUBLICO=N
FAVORITOS=
               recno()                        eval(xDetalhe_Etiqueta+'()')                                    Courier New                    Courier New                    dataenvironment                aTop = 526
Left = 192
Width = 526
Height = 356
DataSource = .NULL.
Name = "Dataenvironment"
                                hPROCEDURE Destroy
Release xDetalhe_Etiqueta
ENDPROC
PROCEDURE Init
SET STEP ON 

if !used('vtmp_tabelas_preco_barra_00')
	=f_msg(['Mensagem do Init do Report:' +chr(13)+'Tabela Tempor�ria N�o Foi Gerado...','Aten��o..'])
	Return .f.
endif

if type('oprel_xFuncEXE')='U'
	=f_msg(['Mensagem do Init do Report:' +chr(13)+'Fun��o a Imprimir N�o Foi Ainda Selecionada...','Aten��o..'])
	Return .f.
else
	Public xDetalhe_Etiqueta
	xDetalhe_Etiqueta = oprel_xFuncEXE
endif

sele vtmp_tabelas_preco_barra_00
INDEX ON codigo_tab_preco+produto+cor_produto+STR(tamanho)+codigo_barra TAG iBarras

ENDPROC
        ���                                ��   %   d      �     �          �  U  
  <�  � U  XDETALHE_ETIQUETA� G1 �+ %�C� vtmp_tabelas_preco_barra_00�
��� �e ��C�X 'Mensagem do Init do Report:' +chr(13)+'Tabela Tempor�ria N�o Foi Gerado...','Aten��o..'�  �� B�-�� �" %�C� oprel_xFuncEXEb� U��:�p ��C�c 'Mensagem do Init do Report:' +chr(13)+'Fun��o a Imprimir N�o Foi Ainda Selecionada...','Aten��o..'�  �� B�-�� �V� 7� � T� �� �� � F� �  & �� � � C� Z� ���	 � U
  F_MSG XDETALHE_ETIQUETA OPREL_XFUNCEXE VTMP_TABELAS_PRECO_BARRA_00 CODIGO_TAB_PRECO PRODUTO COR_PRODUTO TAMANHO CODIGO_BARRA IBARRAS Destroy,     �� InitM     ��1 q 2 a �Qq A "q � q � A r 2                       ,         G   ]      )                                                    cursor                        GTop = 13
Left = 15
Height = 268
Width = 184
Alias = "v_tabelas_preco_barra_00"
Database = c:\docume~1\eduard~1.fal\config~1\temp\visuallinx6.01\lx_temp.dbc
CursorSource = "v_tabelas_preco_barra_00"
Name = "Cursor1"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   