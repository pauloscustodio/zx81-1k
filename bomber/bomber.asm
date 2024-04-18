;------------------------------------------------------------------------------
; ZX81 pacman
; Copyright (C) Paulo Custodio, 2024
; License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
;------------------------------------------------------------------------------

		include "../zx81.inc"
		include "../sysvars1k_lowres.inc"
		
X					equ CH_EEXX
_					equ CH_____
PLANE1				equ CH__X_X
PLANE2				equ CH___XX
BUILDING			equ CH_H
CEILING				equ CH_A
delay_frames		equ 5
rowsize				equ 33

; use the sysvars as variable area
PLANE_ADDR			equ $4000 ; word


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

; clear screen
CLEAR_SCREEN:
		ld hl, sky
		ld (PLANE_ADDR), hl
		dec hl
clear_next:
		inc hl
		ld a, (hl)
		cp CH_NEWLINE
		jr z, clear_next
		cp X
		ret z
		ld (hl), CH_SPACE
		jr clear_next

; draw buildings
DRAW_BUILDINGS:
		ld hl, earth-rowsize+4
		ld b, 32-8
next_building:
		call RANDOM
		and $0f
		inc a
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
		ret 

; MAIN
main:

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

; wait for key


		call CLEAR_SCREEN
		call DRAW_BUILDINGS
next_plane:
		ld hl, (PLANE_ADDR)
		ld (hl+), PLANE1
		ld (hl+), PLANE2
		
; delay
		ld hl, FRAMES
		ld a, (HL)
		sub delay_frames
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
		jr z, main
		cp CEILING
		jr z, main
		
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
		jr z, main

		ld (hl+), PLANE1
		ld (hl-), PLANE2
		
store_plane_pos:		
		
		ld (PLANE_ADDR), hl
		jr next_plane
		
end:  	jr end

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
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
		db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,CH_NEWLINE
earth:	db X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,CH_NEWLINE
		

vars:	db 128					; overwitten after load by "jp(hl)"

last:
