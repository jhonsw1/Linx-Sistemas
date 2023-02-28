Create Function [DBO].[FX_NUMERO] (@STRING varchar(20))
Returns BigInt As
Begin
	Declare @MAX BIGint, @CARAC char(1), @NUM varchar(20)
	Set @MAX = (Select Len(@STRING))
	Set @NUM = ''
	While @MAX > 0
		Begin
			Set @CARAC = (Select Right(Left(@STRING, Len(@STRING) - @MAX + 1), 1))
			If @CARAC <> ''
			Begin
				If IsNumeric(@CARAC) = 1
				Begin
					Set @NUM = @NUM + @CARAC
				End
			End
			Set @MAX = @MAX - 1
		End
		Return CONVERT(BIGINT, @NUM)
End
