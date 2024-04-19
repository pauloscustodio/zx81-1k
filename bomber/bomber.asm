;------------------------------------------------------------------------------
; ZX81 pacman
; Copyright (C) Paulo Custodio, 2024
; License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
;------------------------------------------------------------------------------

		include "../zx81.inc"
		include "../sysvars1k_lowres.inc"
		
JP_HL				equ $e9
X					equ CH_EEXX
_					equ CH_____
PLANE1				equ CH__X_X
PLANE2				equ CH___XX
BUILDING			equ CH_H
CEILING				equ CH_A
BOMB				equ CH____X
rowsize				equ 33
border				equ 3
max_height			equ 10
INIT_DELAY			equ 5

; use the sysvars as variable area
PLANE_ADDR			equ $4000 	; word
BOMB_ADDR			equ $4002	; word
DELAY_TIME			equ $4004	; byte


; OUT: A=random number
RANDOM:	push hl
RSEED:	ld hl, 0				; point into ROM
		inc hl					; next random number
		ld a, h
		and $1f					; keep within ROM space
		ld h, a
		ld (RSEED+1), hl		; store new pointer
		ld a, (hl)
		ld hl, FRAMES
		xor (hl)				; more randomness
		pop hl
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

		pop af
		pop hl
		ret


; MAIN
main:

; show "PRESS KEY" messsage
		ld hl, press_enter_message
		ld (hl), CH_NEWLINE		; show the message
		
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
		ld (hl), CH_0				; "0"
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

; setup level
		ld hl, -1
		ld (BOMB_ADDR), hl
		ld hl, sky
		ld (PLANE_ADDR), hl

; CLEAR SCREEN

		dec hl
clear_next:
		inc hl
		ld a, (hl)
		cp CH_NEWLINE
		jr z, clear_next
		cp X
		jr z, end_clear_screen
		ld (hl), CH_SPACE
		jr clear_next
end_clear_screen:


; draw buildings
DRAW_BUILDINGS:
		ld hl, earth-rowsize+border
		ld b, rowsize-1-2*border
next_building:
		call RANDOM
		and $07					; 0-7
		inc a					; 1-8
		push hl 
		ld de, -rowsize
next_store:
		ld (hl), BUILDING
		add hl, de
		dec a
		jr nz, next_store
		ld (hl), CEILING
		
		pop hl
		inc hl
		djnz next_building

; GAME LOOP

game_loop:

; move the bomb, if any
		ld hl, (BOMB_ADDR)
		ld a, h
		inc a
		jr z, move_plane
		
; move bomb
		ld de, rowsize
		ld (hl), CH_SPACE
		add hl, de
		ld a, (hl)
		cp X
		jr z, end_of_bomb
		cp CH_SPACE
		call nz, INC_SCORE
		ld (hl), BOMB
		ld (BOMB_ADDR), hl
		jr move_plane
		
end_of_bomb:
		ld hl, -1
		ld (BOMB_ADDR), hl
		
move_plane:		
		ld hl, (PLANE_ADDR)
		ld (hl+), PLANE1
		ld (hl), PLANE2
		
; check for bomb drop
		ld a, (BOMB_ADDR+1)
		inc a
		jr nz, do_delay
		
		ld a, (LAST_K)
		inc a
		jr z, do_delay
		
		ld de, rowsize
		add hl, de
		ld a, (hl)
		cp X
		jr z, do_delay
		
		ld (BOMB_ADDR), hl		; drop bomb
		ld (hl), BOMB
		
; delay
do_delay:
		ld a, (DELAY_TIME)
		ld b, a
		ld hl, FRAMES
		ld a, (HL)
		sub b
wait_delay:
		cp (hl)
		jr nz, wait_delay

; move plane
		ld hl, (PLANE_ADDR)
		inc hl
		inc hl 
		ld a, (hl)
		cp CH_NEWLINE
		jr z, plane_next_row
		cp BUILDING
		jp z, main
		cp CEILING
		jp z, main
		
		ld (hl-), PLANE2
		ld (hl-), PLANE1
		ld (hl+), CH_SPACE
		jr store_plane_pos
		
plane_next_row:
		dec hl
		ld (hl-), CH_SPACE
		ld (hl), CH_SPACE
		inc hl
		inc hl
		inc hl
		
		ld a, (hl)
		cp X
		jp z, next_level

		ld (hl+), PLANE1
		ld (hl-), PLANE2
		
store_plane_pos:		
		
		ld (PLANE_ADDR), hl
		jp game_loop
		

; START OF DISPLAY FILE, only the bytes needed

dfile:	db CH_NEWLINE
score:	db CH_0,CH_0,CH_0,CH_0,CH_0
		db CH_SPACE,CH_B,CH_O,CH_M,CH_B,CH_E,CH_R,CH_SPACE
hiscore:db CH_0,CH_0,CH_0,CH_0,CH_0
		db CH_NEWLINE

		db CH_NEWLINE
sky:	db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
earth:	db X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,CH_NEWLINE
press_enter_message:
		db CH_NEWLINE
		db CH_P,CH_R,CH_E,CH_S,CH_S,CH_SPACE
		db CH_E,CH_N,CH_T,CH_E,CH_R,CH_SPACE
		db CH_T,CH_O,CH_SPACE,CH_S,CH_T,CH_A,CH_R,CH_T
		db CH_NEWLINE

vars:	db 128					; overwitten after load by "jp(hl)"

last:
