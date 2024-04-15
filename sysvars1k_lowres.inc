; example from reference book p.7

; 12 bytes from $4000 to $400B free

		org $4009
		
; no use of ROM routines, so system variables may be overwritten
basic:	ld h, dfile>>8			; highbyte of dfile/basic line number
		jr init1				; continue/basic line length

		db 236, 212, 28			; BASIC over dfile data/GOTO USR 0
		db 126,143,0,18			; short form for $4009, decimal places ignored

eline:	dw last					; last stored byte on tape
chadd:	dw last-1
		db 0,0,0,0,0,0			; x not usable
breg:	db 0					; x before loading
mem:	dw 0					; x overwritten on load

init1:	ld l, dfile&$ff			; lowbyte of dfile
		jr init2
		
lastk:	db $ff,$ff,$ff
margin:	db 55

nxtlin:	dw basic				; where BASIC starts executing

flagx:	equ init2+2
init2:	ld (basic+3), hl		; repair dfile pointer

		ld l, vars&$ff			; lsb of end of screen
		dw 0					; x used by zx81 (T-ADDR)
		ld h, vars>>8			; msb of end of screen
		
frames:	db $37, $e9				; after load, frames decremented -> ld (hl), "jp(hl)"

		xor a 
		ex af, af'				; delay interrupts
		jp main
		
cdflag:	db 64					; SLOW mode

; DO NOT CHANGE SYSVARS ABOVE
