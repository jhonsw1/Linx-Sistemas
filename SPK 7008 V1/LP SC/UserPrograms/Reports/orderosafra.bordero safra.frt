   �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              �DRIVER=winspool
DEVICE=\\bnsvher550\BNIPHER018
OUTPUT=IP_10.21.5.63
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=7
PRINTQUALITY=600
DUPLEX=1
YRESOLUTION=600
TTOPTION=4
COLLATE=0
                                   s  +  winspool  \\bnsvher550\BNIPHER018 tIP_10.21.5.63 018 rosoft Document Imaging Writer Port:                                �\\bnsvher550\BNIPHER018          � �  	         X  X                                                                                       ⤗� �       Lexmark X644e                   BNIPHER018                       6  Lexmark X644e R 2                 ��  2                          	     	� �  s)   & 2 , = 6   A >  ⤗�  �  �X      X          �                                                                                                                                                                                                    
   
   
                                                                                                                                                                                                                                                                                                                                                                                                                                       	                                                                                                                            s�                         ⤗�                           Courier New                    _TITULO=Estoque De Produto Por Cor E Filial
CRIADOR=Usr_linx
PADRAO=N
PUBLICO=S
FAVORITOS=
                                   "VENDA"                        Tahoma                         "NOME"                         Tahoma                         "Total dos cheques :"          Tahoma                         "P�gina: " + transform(_pageno)                                 Tahoma                         %dtoc(date()) + ' - ' + time() + 'hs.'                           Times New Roman                'Cia. Hering'                  Courier New                    'GUIA DE CUST�DIA DE CHEQUE'                                    Courier New                    CUR_BORDERO.DATA               "@E"                           Tahoma                         	"AGENCIA"                      Tahoma                         "CHEQUE"                       Tahoma                         
"DEP�SITO"                     Tahoma                         "VALOR"                        Tahoma                         "CPF"                          Tahoma                         "BANCO"                        Tahoma                         'AG�NCIA '+XAGENCIA            Courier New                    'Loja '+main.p_filial          Courier New                    'C/C  '+XCONTA                 Courier New                    CUR_BORDERO.CLIENTE_VAREJO                                      Tahoma                         CUR_BORDERO.CPF_CGC            Tahoma                         CUR_BORDERO.BANCO              Tahoma                         CUR_BORDERO.AGENCIA            Tahoma                         CUR_BORDERO.NUMERO_TITULO      Tahoma                         CUR_BORDERO.VALOR              Tahoma                         CUR_BORDERO.VALOR              Tahoma                         CUR_BORDERO.VALOR              Tahoma                         CUR_BORDERO.VENCIMENTO         "@E"                           Tahoma                         Courier New                    Tahoma                         Tahoma                         Tahoma                         Times New Roman                Courier New                    Tahoma                         Courier New                    dataenvironment                �Top = 39
Left = 620
Width = 617
Height = 485
AutoOpenTables = .F.
AutoCloseTables = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                     bPROCEDURE Init
PUBLIC XAGENCIA,XCONTA 

XAGENCIA =Borderosafra.TXtAgencia.Value
XCONTA 	 =Borderosafra.TXTCodigoCedente.Value


****UNION ALL ;
****SELECT DATA,CLIENTE_VAREJO,VENCIMENTO,CPF_CGC,BANCO,AGENCIA,CONTA_CORRENTE,NUMERO_TITULO,VALOR FROM curChecksCMC7ValidosVista ;


SELECT curChecksCMC7ValidosPre
SELECT DATA,CLIENTE_VAREJO,VENCIMENTO,CPF_CGC,BANCO,AGENCIA,CONTA_CORRENTE,NUMERO_TITULO,VALOR FROM curChecksCMC7ValidosPre ;
INTO CURSOR CUR_BORDERO

SELECT CUR_BORDERO
Index on BANCO+AGENCIA+CONTA_CORRENTE Tag iop
GO TOP



ENDPROC
PROCEDURE Destroy
SELECT MAIN.P_FILIAL AS FILIAL,DTOS(DATE()) AS DATA_GERACAO,XAGENCIA AS AGENCIA, ;
XCONTA AS CONTA_CORRENTE,DTOC(DATA) AS DATA_VENDA,CLIENTE_VAREJO AS NOME,;
CPF_CGC AS CPF,BANCO AS BANCO_CHEQUE,AGENCIA AS AG_CHEQUE,CONTA_CORRENTE AS CONTA_CHEQUE,;
NUMERO_TITULO AS CHEQUE,DTOC(VENCIMENTO) AS DATA_DEPOSITO,STR(VALOR,15,2) AS VALOR ;
FROM CUR_BORDERO ;
INTO CURSOR CUR_EXPORTAR

SELECT CUR_EXPORTAR

IF MESSAGEBOX('Deseja Exportar para o EXCEL?',4+32+256,'Aten��o!!!') = 6	
	COPY TO GETFILE("xls") XLS 
ENDIF




ENDPROC
                              ����    |  |                        ��   %   �      #               �  U  �  7�  � � T�  �� � � �� T� �� � � �� F� �d o� curChecksCMC7ValidosPre�� ��� ���	 ���
 ��� ��� ��� ��� ��� ���� CUR_BORDERO� F� � & �� � � ��� � #)� U  XAGENCIA XCONTA BORDEROSAFRA
 TXTAGENCIA VALUE TXTCODIGOCEDENTE CURCHECKSCMC7VALIDOSPRE DATA CLIENTE_VAREJO
 VENCIMENTO CPF_CGC BANCO AGENCIA CONTA_CORRENTE NUMERO_TITULO VALOR CUR_BORDERO IOP� o� CUR_BORDERO��  � �Q� �CC$��Q� �� �Q� �� �Q� �C� *�Q�	 ��
 �Q� �� �Q� �� �Q� �� �Q� �� �Q� �� �Q� �C� *�Q� �C� ��Z�Q� ��� CUR_EXPORTAR� F� �B %�C� Deseja Exportar para o EXCEL?�$�
 Aten��o!!!�x���� (�C� xls���� � U  MAIN P_FILIAL FILIAL DATA_GERACAO XAGENCIA AGENCIA XCONTA CONTA_CORRENTE DATA
 DATA_VENDA CLIENTE_VAREJO NOME CPF_CGC CPF BANCO BANCO_CHEQUE	 AG_CHEQUE CONTA_CHEQUE NUMERO_TITULO CHEQUE
 VENCIMENTO DATA_DEPOSITO VALOR CUR_BORDERO CUR_EXPORTAR Init,     �� Destroy�    ��1 � 21w Br aQ 5 Vr "A 5                       *     
   H  W      )   |                         