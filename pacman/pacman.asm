;------------------------------------------------------------------------------
; ZX81 pacman
; Copyright (C) Paulo Custodio, 2024
; License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
;------------------------------------------------------------------------------

		include "../zx81.inc"
		include "../sysvars1k_lowres.inc"
		
JP_HL				equ $e9
X					equ CH_XXXX
_					equ CH_____
rowsize				equ 18
CH_PRINCE			equ CH_O
CH_GHOST			equ CH_HHHH
END_MARKER			equ $40		; no-op (ld b,b) that shows a blank on screen
INIT_DELAY			equ 10
NUM_RANDOM_MOVES	equ 5

; use the sysvars as variable area
RSEED 				equ $4000	; word
PRINCE_POS			equ $4002	; word

OLD_ADDR			equ $4004	; word
NEW_ADDR			equ $4006	; word
DELTA_POS			equ $4008	; word

DOTS_TO_EAT			equ $400a	; byte
DELAY_TIME			equ $400b	; byte

; cannot use DFILE, $400c

GHOST1_POS			equ $400e	; word
GHOST1_SAVED_CHAR	equ $4010	; byte
GHOST1_RANDOM_MOVES	equ $4011	; byte

GHOST2_POS			equ $4012	; word
GHOST2_SAVED_CHAR	equ $4014	; byte
GHOST2_RANDOM_MOVES	equ $4015	; byte


; increment score
INC_SCORE_10:
		push hl
		push af
		ld hl, score+4				; last score digit
		jr next_digit
		
INC_SCORE_1:
		push hl
		push af
		ld hl, score+5				; 1 position behind score
		jr next_digit
		
add_ten:
		ld (hl), CH_0				; set to "0"
next_digit:
		dec hl						; previous digit
		inc (hl)					; increment it
		ld a, (hl)					; get digit
		cp CH_9+1					; > "9"?
		jr z, add_ten

		ld a, (DOTS_TO_EAT)
		dec a
		ld (DOTS_TO_EAT), a
		
		pop af
		pop hl
		ret


; SCREEN address
; input BC = row/col
; output HL = address
SCREEN_ADDR:
		push af
		push de
		
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
		
		pop de
		pop af
		ret


; delta in four directions
SCREEN_UP:
		ld de, -rowsize
		ld bc, $ff00
		ret

SCREEN_DOWN:
		ld de, rowsize
		ld bc, $0100
		ret

SCREEN_LEFT:
		ld de, -1
		ld bc, $00ff
		ret

SCREEN_RIGHT:
		ld de, 1
		ld bc, $0001
		ret
		

; MAIN PROPGRAM
main:
		
; show "PRESS ENTER" messsage
		ld hl, press_enter_message
		ld (hl), CH_NEWLINE		; show the message
		
; wait for enter key

; wait for a single key press (key up, key down)
WAIT_KEYPRESS:
		ld a, (LAST_K)
		inc a 					; test keypress
		jr nz, WAIT_KEYPRESS	; A was not $ff, a key is pressed
		
wait_key_down:
		ld bc, (LAST_K)			; get key data in BC
		ld a, c					; copy port to A
		inc a					; test keypress
		jr z, wait_key_down		; A was $ff, no key is pressed
		call KEY_DECODE

		cp KEY_NEWLINE
		jr nz, WAIT_KEYPRESS
		
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

; init level
		ld a, INIT_DELAY
		ld (DELAY_TIME), a
		
; NEXT LEVEL
next_level:
		ld a, (DELAY_TIME)
		cp 2
		jr c, no_level_change
		dec a
		ld (DELAY_TIME), a
no_level_change:

; setup board
; add dots to all spaces, then whipe ghosts home and add stars
		ld hl, board-1
		ld e, -5				; number of dots to eat -4 at ghost home -1 at prince start
next_board:
		inc hl
		ld a, (hl)				; get character
		cp X					; wall
		jr z, next_board
		cp CH_NEWLINE			; newline
		jr z, next_board
		cp END_MARKER			; end of board marker
		jr z, end_fill
		ld (hl), CH_DOT
		inc e
		jr next_board
end_fill:
		ld a, e
		ld (DOTS_TO_EAT), a
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
		call SCREEN_ADDR
		ld (HL), CH_PRINCE
		
; setup ghosts		
		ld bc, (7<<8) + 7
		ld (GHOST1_POS), bc
		call SCREEN_ADDR
		ld (HL), CH_GHOST
		inc bc
		inc bc
		ld (GHOST2_POS), bc
		call SCREEN_ADDR
		ld (HL), CH_GHOST
		xor a
		ld (GHOST1_SAVED_CHAR), A
		ld (GHOST2_SAVED_CHAR), A

; Start Game
game_loop:

; Move prince
		ld bc, (LAST_K)			; read keyboard
		ld a, b
		inc a
		jp z, END_MOVE_PRINCE
		
		call KEY_DECODE			; pressed key into A

		call SCREEN_UP
		cp KEY_Q
		jr z, MOVE_PRINCE
		cp KEY_7
		jr z, MOVE_PRINCE
		
		call SCREEN_DOWN
		cp KEY_A
		jr z, MOVE_PRINCE
		cp KEY_6
		jr z, MOVE_PRINCE
		
		call SCREEN_LEFT
		cp KEY_O
		jr z, MOVE_PRINCE
		cp KEY_5
		jr z, MOVE_PRINCE
		
		call SCREEN_RIGHT
		cp KEY_P
		jr z, MOVE_PRINCE
		cp KEY_8
		jr nz, END_MOVE_PRINCE

; MOVE PRINCE
; In: DE: distance in screen bytes
;     BC: distance in coords
MOVE_PRINCE:
		ld (DELTA_POS), bc		; save delta-position
		
		ld bc, (PRINCE_POS)
		call SCREEN_ADDR
		ld (OLD_ADDR), hl
		add hl, de
		ld (NEW_ADDR), hl
		
		ld a, (hl)				; character at new position
		cp X 					; wall
		jr z, END_MOVE_PRINCE	; no move
		cp CH_GHOST				; ghost
		jr z, PRINCE_DIED
		cp CH_DOT				; dot
		call z, INC_SCORE_1
		cp CH_MULT				; apple
		call z, INC_SCORE_10
		
		ld (hl), CH_PRINCE		; draw new prince
		ld hl, (OLD_ADDR)
		ld (hl), CH_SPACE		; delete old prince
		
		ld hl, (PRINCE_POS)		; move coords
		ld bc, (DELTA_POS)		; delta position
		ld a, h
		add a, b 
		ld h, a
		
		ld a, l 
		add a, c 
		ld l, a
		
		ld (PRINCE_POS), hl
		jr END_MOVE_PRINCE
		
PRINCE_DIED:
		ld hl, (OLD_ADDR)
PRINCE_EATEN:
		ld (hl), CH_X+CH_INV	; death mark
		jp main					; jump back to main
		
END_MOVE_PRINCE:
		
; MOVE GHOSTS

; swap ghosts
		ld hl, (GHOST1_POS)
		ld de, (GHOST2_POS)
		ld (GHOST1_POS),de
		ld (GHOST2_POS),hl

		ld hl, (GHOST1_SAVED_CHAR)
		ld de, (GHOST2_SAVED_CHAR)
		ld (GHOST1_SAVED_CHAR),de
		ld (GHOST2_SAVED_CHAR),hl

; random move?
		ld a, (GHOST1_RANDOM_MOVES)
		and a
		jr z, COMPUTE_MOVE
		dec a
		ld (GHOST1_RANDOM_MOVES), a
		
; Pseudo-random number into A
		ld hl, (RSEED)			; point into ROM
		inc hl					; next random number
		ld a, h
		and $1f					; keep within ROM space
		ld h, a
		ld (RSEED), hl			; store new pointer
		ld a, (hl)
		ld hl, FRAMES
		xor (hl)				; more randomness

		rra
		jr c, MOVE_GHOST_UP
		rra 
		jr c, MOVE_GHOST_DOWN
		rra 
		jr c, MOVE_GHOST_LEFT
		jr MOVE_GHOST_RIGHT
		
; computed move
COMPUTE_MOVE:
		ld hl, (GHOST1_POS)
		ld de, (PRINCE_POS)
		
		ld a, h					; delta-row to h
		sub d 
		ld h, a
		jr nc, row_positive
		neg
row_positive:
		ld d, a					; abs(delta-row) to d
		
		ld a, l					; delta-col to l
		sub e 
		ld l, a
		jr nc, col_positive
		neg
col_positive:
		ld e, a					; abs(delta-col) to e
		
		cp d
		jr nc, move_col			; abs(delta-col) >= abs(delta-row)

move_row:
		ld a, h
		rra
		jr c, MOVE_GHOST_UP		; delta-row < 0
		jr MOVE_GHOST_DOWN

move_col:
		ld a, l
		rra
		jr c, MOVE_GHOST_LEFT		; delta-row < 0
		jr MOVE_GHOST_RIGHT


MOVE_GHOST_UP:
		call SCREEN_UP
		jr MOVE_GHOST

MOVE_GHOST_DOWN:
		call SCREEN_DOWN
		jr MOVE_GHOST
		
MOVE_GHOST_LEFT:
		call SCREEN_LEFT
		jr MOVE_GHOST
		
MOVE_GHOST_RIGHT:
		call SCREEN_RIGHT
		
; In: DE: distance in screen bytes
;     BC: distance in coords
MOVE_GHOST:
		ld (DELTA_POS), bc		; save delta-position
		
		ld bc, (GHOST1_POS)
		call SCREEN_ADDR
		ld (OLD_ADDR), hl
		add hl, de
		ld (NEW_ADDR), hl
		
		ld a, (hl)				; character at new position
		cp X 					; wall
		jr z, END_MOVE_GHOST	; no move
		cp CH_GHOST				; other ghost
		jr z, END_MOVE_GHOST	; no move
		
		cp CH_PRINCE			; prince
		jp z, PRINCE_EATEN
		
		ld a, (GHOST1_SAVED_CHAR) ; delete old ghost
		ld hl, (OLD_ADDR)
		ld (hl), a
		
		ld hl, (NEW_ADDR)		; draw new ghost, save char under
		ld a, (hl)
		ld (GHOST1_SAVED_CHAR), a
		ld (hl), CH_GHOST

END_MOVE_GHOST:

; delay, faster as level increases

		ld a, (DELAY_TIME)		; wait x/50 seconds
		ld b, a 

		ld hl, FRAMES
		ld a, (HL)
		sub b
wait_delay_b:
		cp (hl)
		jr nz, wait_delay_b
		
		
; check if end of dots
		ld a, (DOTS_TO_EAT)
		and a
		jp z, next_level
		
		
		jp game_loop


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
		db END_MARKER
press_enter_message:
		db CH_NEWLINE
		db CH_P,CH_R,CH_E,CH_S,CH_S,CH_SPACE
		db CH_E,CH_N,CH_T,CH_E,CH_R,CH_SPACE
		db CH_T,CH_O,CH_SPACE
		db CH_S,CH_T,CH_A,CH_R,CH_T
		db CH_NEWLINE
		
vars:	db 128					; overwitten after load by "jp(hl)"

last:
