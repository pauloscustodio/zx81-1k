; Model 1K hires - page 50 of reference book

		include "../zx81.inc"
		
lrlines equ 3
bytecol	equ 8
hrlines equ 8*8

		org $4009
		
; program starts here, both BASIC and machine code
; the initialization also repairs any possible 48k bug

basic:	ex af, af'				; delay any possible interrupt
		ld h, b 				; preset $40 48k bugfix
		jr init0				; continue where room
		
		db 236, 212, 28			; BASIC over dfile data/GOTO USR 0
		db 126,143,0,18			; short form for $4009, decimal places ignored
		
eline:	dw last					; last stored byte on tape
chadd:	dw last-1
xptr:	dw 0
stkbot:	dw last 
stkend: dw last 
breg:	db 0
mem:	dw 0
		db $80, 0, 0, 0

; all above reusable after loading

lastk:	db $ff,$ff,$ff			; used by zx81
margin:	db 55					; used by zx81

nxtlin:	dw basic				; where BASIC starts executing

init0:	ld ix, hr 				; hr lowbyte bit 5 reset 
								; lowbyte over flagx which resets bit 5 on load
								; hr must be at an adress between $xx40 and $xx6f
		ld e, l 				; DE now $xx.L 
taddr:	dw 0 					; used on load, only unharmful code
		ld b, 1024>>8			; copy > 1k code
frames:	db $16+1, $c0			; after load: ld d, $c0
								; highbyte muts have bit 7 set
coords:	ldir 					; DE now $c0.L = HL+$8000; fix 48k bugfix 
prcc:	jp main 				; continue to main program 

cdflag:	db $40					; used by zx81

; Fill space so that hr starts between $4040 and $407f

;--- T=148
lbuf: 	ld r, a 				; T=9
		defs 8, 0				; T=8*4		display 8 chars
		defs 32-8, $40			; T=24*4 	no-op, shows a blank
delay:	ret nz					; T=11		to make 207 T-states
								; T=148
;---

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
		ld bc, +(lrlines<<8)+1	; T=10
		ld a, $1e 				; T=7				I reg for chars
		ld i, a 				; T=9
		ld a, $fb 				; T=7
		call $02b5				; T=17+9+7+4+4+32*4	show lowres screen
								; T=212
;---

; hires display

		ld b, 12				; delay to outline hires display
hr0:	djnz hr0

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

; MAIN program		

main:	ld ix, hr
end:	jr end

; lowres display

dfile:	db CH_NEWLINE
		db CH_0,CH_0,CH_0,CH_0,CH_0,CH_SPACE
		db CH_T,CH_E,CH_S,CH_T,CH_SPACE
		db CH_0,CH_0,CH_0,CH_0,CH_0,CH_NEWLINE
		db CH_NEWLINE
		db CH_NEWLINE, $e9
		
		defs $100 - ($ & $ff) - 9

; hires display

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
