		include "../zx81.inc"
		include "../model1k_lowres.inc"
		
; START OF YOUR CODE

bytecol	equ 5
lines 	equ 5*8

main:	ld ix, hr
end:	jr end

; hires display
hr:		ld b, 3
hr0:	djnz hr0				; delay

		ld hl, screen
		ld de, bytecol
topline:ld bc, $8000+lines
		inc b					; always one topline
		ld a, 192-lines 		; all the lines
		sub b 					; minus top
		ld (notend+1), a		; set bottom lines
		
		call delay
		
hr1: 	call lbuf2
		djnz hr1				; dont show B toplines
		
notend:	ld b, 0					; B is set for bottom

hr2:	ld a, h 
		ld i, a					; set high byte
		ld a, l 				; preload low byte
		call $8000+lbuf 		; display the line
		add hl, de				; calculate next line
		dec c 					; decrease line count 
		jp nz, hr2				; do all lines
		
hr3:	call lbuf2 				; like top, fill screen with empty lines
		djnz hr3
		
		call $0292				; fixed end of screen
		call $0220				
		ld ix, hr				; set ix for interrupt
		jp $02a4
		
lbuf: 	ld r, a 
		defs 5, 0
		defs 32-5, $40
delay:	ret nc					; to make 207 T-states
		
lbuf2: 	ld d, 3
lb2:	ex (sp), hl
		ex (sp), hl
		dec d
		jp nz, lb2
		nop 
		ret

dfile:	db CH_NEWLINE
		db CH_SPACE,CH_SPACE,CH_SPACE
score:	db CH_0,CH_0,CH_0,CH_0,CH_0,CH_SPACE
lives:	db CH_0,CH_SPACE
		db CH_N,CH_A,CH_M,CH_E,CH_SPACE
hiscore:db CH_0,CH_0,CH_0,CH_0,CH_0,CH_NEWLINE
		db CH_NEWLINE,$e9
		
		;defs $100 - ($ & $ff) - 9

		;defs $100 - ($ & $ff) - 9

screen:	db $ff,$ff,$ff,$ff,$ff
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $80,$00,$00,$00,$01
		db $ff,$ff,$ff,$ff,$ff

vars:	db 128

last:
