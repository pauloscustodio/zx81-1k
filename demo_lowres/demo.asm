		include "../zx81.inc"
		include "../model1k_lowres.inc"
		
; START OF YOUR CODE

main:	jr main

; START OF DISPLAY FILE, only the bytes needed

dfile:	db CH_NEWLINE
		db CH_D,CH_E,CH_M,CH_O
		db CH_NEWLINE

vars:	db 128					; overwitten after load by "jp(hl)"

last:
