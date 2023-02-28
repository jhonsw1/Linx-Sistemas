FUNCTION f_strZero
	LPARAMETERS XVALOR, xZeros

	LOCAL xSoma, xRet

	xSoma = val('1'+repl('0',xZeros))
	xRet = right(alltrim(str(xSoma+XVALOR,xZeros+1)),xZeros)

	RETURN xRet
	
ENDFUNC 