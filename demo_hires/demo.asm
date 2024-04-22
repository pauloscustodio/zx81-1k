		include "../zx81.inc"
		include "../model1k_lowres.inc"
		
; START OF YOUR CODE

lrlines equ 3
bytecol	equ 8
hrlines equ 5*bytecol

; Fill space so that hr starts between $4040 and $407f

lbuf: 	ld r, a 				; T=9
		defs 8, 0				; T=8*4		display 8 chars
		defs 32-8, $40			; T=24*4 	no-op, shows a blank
delay:	ret nz					; T=11		to make 207 T-states
								; T=148
		
;--- T=169
lbuf2: 	ld d, 2					; T=7
lb2:	ex (sp), hl				; T=19*2
		ex (sp), hl				; T=19*2
		dec d					; T=4*2
		jp nz, lb2				; T=10*2
		ex (sp), hl				; T=19
		ex (sp), hl				; T=19
		ret						; T=10
								; T=169
;---

; lowres display

;--- 212 T-states
hr:		ld hl, dfile+$8000		; T=10
		ld bc, (lrlines<<8)+1	; T=10
		ld a, $1e 				; T=7
		ld i, a 				; T=9
		ld a, $fb 				; T=7
		call $02b5				; T=17+9+7+4+4+32*4
								; T=212
;---

		ld b, 11				; delay to outline hires display
hr0:	djnz hr0
		
; hires display

		ld hl, hrscreen			; T=10
		ld de, bytecol			; T=10
		ld b, hrlines			; T=7
		and a 					; T=4, clear zero flag
		
;--- 207 T-states
hr2:	ld a, h 				; T=4
		ld i, a					; T=9 		set high byte
		ld a, l 				; T=4  		preload low byte
		call lbuf+$8000 		; T=17+148 	display the line
		add hl, de				; T=11		calculate next line
		dec b 					; T=4		decrease line count 
		jp nz, hr2				; T=10 		do all lines
								; T=207
;---
		
;--- 207 T-states
		ld b, 192-hrlines-lrlines*8-1	; T=7
hr1: 	call lbuf2				; T=17+169
		dec b 					; T=4
		jp nz, hr1				; T=10 		dont show B toplines
								; T=207
;---

		call $0292				; fixed end of screen
		call $0220				
		ld ix, hr				; set ix for interrupt
		jp $02a4
		

main:	ld ix, hr
end:	jr end



dfile:	db CH_NEWLINE
		db CH_0,CH_0,CH_0,CH_0,CH_0,CH_SPACE
		db CH_T,CH_E,CH_S,CH_T,CH_SPACE
		db CH_0,CH_0,CH_0,CH_0,CH_0,CH_NEWLINE
		db CH_NEWLINE
		db CH_NEWLINE, $e9
		
		defs $100 - ($ & $ff) - 9

hrscreen:	
		db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $80,$00,$00,$00,$00,$00,$00,$01
		db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

vars:	db 128

last:
