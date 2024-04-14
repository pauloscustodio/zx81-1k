		include "../zx81.inc"
		include "../sysvars1k_lowres.inc"
		
JP_HL		equ $e9
X			equ CH_XXXX
_			equ CH_____
rowsize		equ 18
CH_PRINCE	equ CH_O
CH_GHOST	equ CH_HHHH

; use the sysvars as variable area
SEED 		equ $4000
PRINCE_POS	equ $4002
GHOST1_POS	equ $4004
GHOST2_POS	equ $4008
GHOST1_SAVED_CHAR	equ $400a
GHOST2_SAVED_CHAR	equ $400b

; wait for a single key press (key up, key down)
; input -
; output: A = keypress, 0 if no key
; uses all registers
WAIT_KEYPRESS:
		ld a, (LASTK)
		inc a 					; test keypress
		jr nz, WAIT_KEYPRESS	; A was not $ff, a key is pressed
		
wait_key_down:
		ld bc, (LASTK)			; get key data in BC
		ld a, c					; copy port to A
		inc a					; test keypress
		jr z, wait_key_down		; A was $ff, no key is pressed
		jp KEY_DECODE


; Pseudo-random number into A
RANDOM:	ld hl, (SEED)			; point into ROM
		inc hl					; next random number
		ld a, h
		and $1f					; keep within ROM space
		ld h, a
		ld (SEED), hl			; store new pointer
		ld a, (hl)
		ld hl, FRAMES
		xor (hl)				; more randomness
		ret
		

; delay B 1/50 seconds
; uses all registers
DELAY_B:
		ld hl, FRAMES
		ld a, (HL)
		sub b
wait_delay_b:
		cp (hl)
		jr nz, wait_delay_b
		ret


; increment score
INC_SCORE:
		ld hl, score+5				; 1 position behind score
		db 17						; trick to skip next opcode
add_ten:ld (hl), 28					; set to "0"
		dec hl						; previous digit
		inc (hl)					; increment it
		ld a, (hl)					; get digit
		cp 38						; > "9"?
		jr z, add_ten
		ret


; SCREEN position
; input BC = row/col
; output HL = address
SCREEN_POS:
		ld a, b					; row
		add a, a				; row*2
		ld l, a
		add a, a				; row*4
		add a, a				; row*8
		add a, a				; row*16
		add a, l				; row*18
		add a, c				; row*18+col
		ld l, a
		ld h, 0
		ld de, board
		add hl, de
		ret


; MAIN PROPGRAM
main:
		
; show "PRESS ENTER" messsage
		ld hl, press_enter_message
		ld (hl), CH_NEWLINE		; show the message
		
; wait for enter key
wait_enter:
		call WAIT_KEYPRESS	 	; keypress -> A
		cp KEY_NEWLINE
		jr nz, wait_enter
		
; remove "PRESS ENTER" messsage
		ld hl, press_enter_message
		ld (hl), JP_HL			; "jp (hl)"

; copy score to highscore if greater
		ld hl, score-1
		ld de, hiscore-1
		ld bc, 6					; length+1
same_score:
		dec c						; shorten length to copy
		inc de 						; goto next digit
		inc hl 
		ld a, (de)
		cp (hl)
		jr z, same_score			; while equal
		call c, $0a6e				; LDIR

; init score to zeros
		xor a
		ld hl, score
reset_score:
		ld (hl), 28					; "0"
		inc hl
		cp (hl)
		jr nz, reset_score

; setup board
; add dots to all spaces, then whipe ghosts home and add stars
		ld hl, board-1
next_board:
		inc hl
		ld a, (hl)				; get character
		cp X					; wall
		jr z, next_board
		cp CH_NEWLINE			; newline
		jr z, next_board
		cp CH_P					; "P" of message after board
		jr z, end_fill
		ld (hl), CH_DOT
		jr next_board
end_fill:
		ld a, CH_MULT
		ld (board+1*rowsize+1), a
		ld (board+1*rowsize+15), a
		ld (board+13*rowsize+1), a
		ld (board+13*rowsize+15), a
		xor a
		ld (board+6*rowsize+8), a
		ld hl, board+7*rowsize+7
		ld (hl+), a
		ld (hl+), a
		ld (hl+), a
		
; setup prince
		ld bc, (13<<8) + 8
		ld (PRINCE_POS), bc
		call SCREEN_POS
		ld (HL), CH_PRINCE
		
; setup ghosts		
		ld bc, (7<<8) + 7
		ld (GHOST1_POS), bc
		call SCREEN_POS
		ld (HL), CH_GHOST
		inc bc
		inc bc
		ld (GHOST2_POS), bc
		call SCREEN_POS
		ld (HL), CH_GHOST
		xor a
		ld (GHOST1_SAVED_CHAR), A
		ld (GHOST2_SAVED_CHAR), A


		ld b, 5*50				; wait 5 seconds
		call DELAY_B
		
		jp main
		
; START OF DISPLAY FILE, only the bytes needed

dfile:	db CH_NEWLINE
score:	db CH_0,CH_0,CH_0,CH_0,CH_0
		db CH_SPACE,CH_P,CH_A,CH_C,CH_M,CH_A,CH_N,CH_SPACE
hiscore:db CH_0,CH_0,CH_0,CH_0,CH_0
		db CH_NEWLINE

		db CH_NEWLINE
board:	db X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,CH_NEWLINE
		db X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,CH_NEWLINE
		db X,_,X,X,X,_,X,_,X,_,X,_,X,X,X,_,X,CH_NEWLINE
		db X,_,_,_,_,_,X,_,X,_,X,_,_,_,_,_,X,CH_NEWLINE
		db X,_,X,_,X,X,X,_,X,_,X,X,X,_,X,_,X,CH_NEWLINE
		db X,_,X,_,X,_,_,_,_,_,_,_,X,_,X,_,X,CH_NEWLINE
		db X,_,X,_,X,_,X,X,_,X,X,_,X,_,X,_,X,CH_NEWLINE
		db X,_,_,_,_,_,X,_,_,_,X,_,_,_,_,_,X,CH_NEWLINE
		db X,_,X,_,X,_,X,X,X,X,X,_,X,_,X,_,X,CH_NEWLINE
		db X,_,X,_,X,_,_,_,_,_,_,_,X,_,X,_,X,CH_NEWLINE
		db X,_,X,_,X,X,X,_,X,_,X,X,X,_,X,_,X,CH_NEWLINE
		db X,_,_,_,_,_,X,_,X,_,X,_,_,_,_,_,X,CH_NEWLINE
		db X,_,X,X,X,_,X,_,X,_,X,_,X,X,X,_,X,CH_NEWLINE
		db X,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,X,CH_NEWLINE
		db X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,CH_NEWLINE
press_enter_message:
		db CH_NEWLINE
		db CH_P,CH_R,CH_E,CH_S,CH_S,CH_SPACE
		db CH_E,CH_N,CH_T,CH_E,CH_R,CH_SPACE
		db CH_T,CH_O,CH_SPACE
		db CH_S,CH_T,CH_A,CH_R,CH_T
		db CH_NEWLINE
		
vars:	db 128					; overwitten after load by "jp(hl)"

last:
