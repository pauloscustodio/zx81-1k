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
NUM_RANDOM_MOVES	equ 10
NUM_DOTS			equ 121

DISTANCE_UP			equ -rowsize
DISTANCE_DOWN 		equ rowsize
DISTANCE_LEFT		equ -1
DISTANCE_RIGHT		equ 1

; use the sysvars as variable area
RSEED 				equ $4000	; word
PRINCE_ADDR			equ $4002	; word

OLD_ADDR			equ $4004	; word
NEW_ADDR			equ $4006	; word
DELTA_POS			equ $4008	; word

DOTS_TO_EAT			equ $400a	; byte
DELAY_TIME			equ $400b	; byte

; cannot use DFILE, $400c

GHOST1_ADDR			equ $400e	; word
GHOST1_SAVED_CHAR	equ $4010	; byte
GHOST1_RANDOM_MOVES	equ $4011	; byte

GHOST2_ADDR			equ $4012	; word
GHOST2_SAVED_CHAR	equ $4014	; byte
GHOST2_RANDOM_MOVES	equ $4015	; byte

SHORTEST_DISTANCE	equ $4016 	; word
SHORTEST_NEW_ADDR	equ $4018 	; word 


; OUT: A=random number
RANDOM:	push hl
		ld hl, (RSEED)			; point into ROM
		inc hl					; next random number
		ld a, h
		and $1f					; keep within ROM space
		ld h, a
		ld (RSEED), hl			; store new pointer
		ld a, (hl)
		ld hl, FRAMES
		xor (hl)				; more randomness
		pop hl
		ret 
		
; IN: DE-distance to move
CHECK_GHOST_MOVE:
		ld hl, (GHOST1_ADDR)
		add hl, de					; new position
		ld (NEW_ADDR), hl
		ld a, (hl)
		cp X 
		ret z						; wall
		cp CH_GHOST			
		ret z 						; other ghost
		cp CH_PRINCE
		jp z, POP_PRINCE_DIED		; killed prince

		ld de, (PRINCE_ADDR)
		and a
		sbc hl, de
		jr nc, distance_positive
		
		ld a, h
		cpl
		ld h, a
		
		ld a, l
		cpl
		ld l, a
		inc hl
distance_positive:
		ld de, (SHORTEST_DISTANCE)
		and a
		sbc hl, de					; C if new_dist < old_dist
		ret nc
		
		add hl, de
		ld (SHORTEST_DISTANCE), hl
		ld hl, (NEW_ADDR)
		ld (SHORTEST_NEW_ADDR), hl
		
		ret
		

; increment score
INC_SCORE:
		push hl
		push af
		ld hl, score+5				; 1 position behind score
		jr skip_digit
add_ten:
		ld (hl), CH_0				; set to "0"
skip_digit:		
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
		jr next_board
end_fill:
		xor a
		ld (board+6*DISTANCE_DOWN+8), a
		ld hl, board+7*DISTANCE_DOWN+7
		ld (hl+), a
		ld (hl+), a
		ld (hl+), a

		ld a, NUM_DOTS
		ld (DOTS_TO_EAT), a
		
; setup prince
		ld hl, board + (13*DISTANCE_DOWN) + 8
		ld (PRINCE_ADDR), hl
		ld (HL), CH_PRINCE
		
; setup ghosts		
		ld hl, board + (7*DISTANCE_DOWN) + 7
		ld (GHOST1_ADDR), hl
		ld (HL), CH_GHOST
		inc hl
		inc hl
		ld (GHOST2_ADDR), hl
		ld (HL), CH_GHOST
		xor a
		ld (GHOST1_SAVED_CHAR), A
		ld (GHOST2_SAVED_CHAR), A
		ld a, NUM_RANDOM_MOVES
		ld (GHOST1_RANDOM_MOVES), A
		ld (GHOST2_RANDOM_MOVES), A

; Start Game
game_loop:

; Move prince
		ld a, $fb				; port QWERT
		in a, ($fe)
		rra						; bit 0 - Q
		ld de, DISTANCE_UP		; move up
		jr nc, MOVE_PRINCE
		ld a, $fd 				; port ASDFG
		in a, ($fe)
		rra						; bit 0 - A
		ld de, DISTANCE_DOWN	; move down
		jr nc, MOVE_PRINCE
		ld a, $df 				; port YUIOP
		in a, ($fe)
		rra						; bit 0 - P
		ld de, DISTANCE_RIGHT	; move right
		jr nc, MOVE_PRINCE
		rra						; bit 1 - Q
		ld de, DISTANCE_LEFT	; move left
		jr nc, MOVE_PRINCE
		jr END_MOVE_PRINCE

		
; MOVE PRINCE
; In: DE: distance in screen bytes
MOVE_PRINCE:
		ld hl, (PRINCE_ADDR)
		add hl, de
		ld (NEW_ADDR), hl
		
		ld a, (hl)				; character at new position
		cp X 					; wall
		jr z, END_MOVE_PRINCE	; no move
		cp CH_GHOST				; ghost
		jr z, PRINCE_DIED
		cp CH_DOT				; dot
		call z, INC_SCORE
		
		ld (hl), CH_PRINCE		; draw new prince
		ld hl, (PRINCE_ADDR)
		ld (hl), CH_SPACE		; delete old prince
		
		ld hl, (NEW_ADDR)		; move coords
		ld (PRINCE_ADDR), hl 	; new position
		jr END_MOVE_PRINCE
		
POP_PRINCE_DIED:
		pop hl 					; remove return address
PRINCE_DIED:
		ld hl, (PRINCE_ADDR)
		ld (hl), CH_X+CH_INV	; death mark
		jp main					; jump back to main
		
END_MOVE_PRINCE:
		
; MOVE GHOSTS

; swap ghosts
		ld hl, (GHOST1_ADDR)
		ld de, (GHOST2_ADDR)
		ld (GHOST1_ADDR),de
		ld (GHOST2_ADDR),hl

		ld hl, (GHOST1_SAVED_CHAR)
		ld de, (GHOST2_SAVED_CHAR)
		ld (GHOST1_SAVED_CHAR),de
		ld (GHOST2_SAVED_CHAR),hl

; check for kill and best move
		ld hl, $ffff
		ld (SHORTEST_DISTANCE), hl
		
		ld de, DISTANCE_UP		; check up
		call CHECK_GHOST_MOVE
		
		ld de, DISTANCE_RIGHT
		call CHECK_GHOST_MOVE
		
		ld de, DISTANCE_DOWN
		call CHECK_GHOST_MOVE
		
		ld de, DISTANCE_LEFT
		call CHECK_GHOST_MOVE

		ld a, (SHORTEST_DISTANCE+1)
		inc a
		jr nz, check_random_move		; ghost can move

; ghost cannot move
		ld a, NUM_RANDOM_MOVES
		ld (GHOST1_RANDOM_MOVES), a
		jr END_MOVE_GHOST
		
; random move?
check_random_move:
		ld a, (GHOST1_RANDOM_MOVES)
		and a
		jr z, MOVE_GHOST
		dec a
		ld (GHOST1_RANDOM_MOVES), a
		
; Pseudo-random number into A
		call RANDOM
		rra
		ld de, DISTANCE_UP
		jr c, MOVE_GHOST_RANDOM
		rra 
		ld de, DISTANCE_DOWN
		jr c, MOVE_GHOST_RANDOM
		rra 
		ld de, DISTANCE_LEFT
		jr c, MOVE_GHOST_RANDOM
		ld de, DISTANCE_RIGHT
		
MOVE_GHOST_RANDOM:
		ld hl, (GHOST1_ADDR)
		add hl, de
		ld (SHORTEST_NEW_ADDR), hl
		
		
MOVE_GHOST:
		ld hl, (SHORTEST_NEW_ADDR)
		
		ld a, (hl)				; character at new position
		cp X 					; wall
		jr z, END_MOVE_GHOST	; no move
		cp CH_GHOST				; other ghost
		jr z, END_MOVE_GHOST	; no move
		
		ld a, (GHOST1_SAVED_CHAR) ; delete old ghost
		ld hl, (GHOST1_ADDR)
		ld (hl), a
		
		ld hl, (SHORTEST_NEW_ADDR)	; draw new ghost, save char under
		ld a, (hl)
		ld (GHOST1_SAVED_CHAR), a
		ld (hl), CH_GHOST

		ld hl, (SHORTEST_NEW_ADDR)	; move coords
		ld (GHOST1_ADDR), hl
		

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
		db CH_T,CH_O,CH_SPACE,CH_S,CH_T,CH_A,CH_R,CH_T
		db CH_NEWLINE
		
vars:	db 128					; overwitten after load by "jp(hl)"

last:
