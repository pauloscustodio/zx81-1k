;------------------------------------------------------------------------------
; ZX81 constants
; Copyright (C) Paulo Custodio, 2024
; License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
;------------------------------------------------------------------------------

; ZX81 System Variables

ERR_NO		equ $4000
FLAGS		equ $4001
ERR_SP		equ $4002
RAMTOP		equ $4004
MODE		equ $4006
PPC			equ $4007
VERSN		equ $4009
E_PPC		equ $400a
D_FILE		equ $400c
DF_CC		equ $400e
VARS		equ $4010
DEST		equ $4012
E_LINE		equ $4014
CH_ADD		equ $4016
X_PTR		equ $4018
STKBOT		equ $401a
STKEND		equ $401c
BREG		equ $401e
MEM			equ $401f
FREE1		equ $4021
DF_SZ		equ $4022
S_TOP		equ $4023
LAST_K		equ $4025
DEBOUNCE	equ $4027
MARGIN		equ $4028
NXTLIN		equ $4029
OLDPPC		equ $402b
FLAGX		equ $402d
STRLEN		equ $402e
T_ADDR		equ $4030
SEED		equ $4032
FRAMES		equ $4034
COORDS_X	equ $4036
COORDS_Y	equ $4037
PR_CC		equ $4038
S_POSN_COL	equ $4039
S_POSN_ROW	equ $403a
CDFLAG		equ $403b
PRBUFF		equ $403c
MEMBOT		equ $405d
FREE2		equ $407b
PROG		equ $407d

; ZX81 character codes

CH_INV		equ $80

CH_____		equ $00
CH_X___		equ $01
CH__X__		equ $02
CH_XX__		equ $03
CH___X_		equ $04
CH_X_X_		equ $05
CH__XX_		equ $06
CH_XXX_		equ $07
CH_HHHH		equ $08
CH___HH		equ $09
CH_HH__		equ $0a
CH_XXXX		equ $80
CH__XXX		equ $81
CH_X_XX		equ $82
CH___XX		equ $83
CH_XX_X		equ $84
CH__X_X		equ $85
CH_X__X		equ $86
CH____X		equ $87
CH_EEEE		equ $88
CH_XXEE		equ $89
CH_EEXX		equ $8a

CH_SPACE	equ $00
CH_DQUOTE	equ $0b
CH_POUND	equ $0c
CH_DOLLAR	equ $0d
CH_COLON	equ $0e
CH_QUEST	equ $0f
CH_LPAREN	equ $10
CH_RPAREN	equ $11
CH_GT		equ $12
CH_LT		equ $13
CH_EQ		equ $14
CH_PLUS		equ $15
CH_MINUS	equ $16
CH_MULT		equ $17
CH_DIV		equ $18
CH_SEMICOLON equ $19
CH_COMMA	equ $1a
CH_DOT		equ $1b
CH_0		equ $1c
CH_1		equ $1d
CH_2		equ $1e
CH_3		equ $1f
CH_4		equ $20
CH_5		equ $21
CH_6		equ $22
CH_7		equ $23
CH_8		equ $24
CH_9		equ $25
CH_A		equ $26
CH_B		equ $27
CH_C		equ $28
CH_D		equ $29
CH_E		equ $2a
CH_F		equ $2b
CH_G		equ $2c
CH_H		equ $2d
CH_I		equ $2e
CH_J		equ $2f
CH_K		equ $30
CH_L		equ $31
CH_M		equ $32
CH_N		equ $33
CH_O		equ $34
CH_P		equ $35
CH_Q		equ $36
CH_R		equ $37
CH_S		equ $38
CH_T		equ $39
CH_U		equ $3a
CH_V		equ $3b
CH_W		equ $3c
CH_X		equ $3d
CH_Y		equ $3e
CH_Z		equ $3f

CH_RND			equ $40
CH_INKEY_DOLLAR	equ $41
CH_PI			equ $42
CH_UP			equ $70
CH_DOWN			equ $71
CH_LEFT			equ $72
CH_RIGHT		equ $73
CH_GRAPHICS		equ $74
CH_EDIT			equ $75
CH_NEWLINE		equ $76
CH_RUBOUT		equ $77
CH_KL_MODE		equ $78
CH_FUNCTION		equ $79
CH_NUMBER		equ $7e
CH_CURSOR		equ $7f
CH_DDQUOTE		equ $c0
CH_AT			equ $c1
CH_TAB			equ $c2
CH_CODE			equ $c4
CH_VAL			equ $c5
CH_LEN			equ $c6
CH_SIN			equ $c7
CH_COS			equ $c8
CH_TAN			equ $c9
CH_ASN			equ $ca
CH_ACS			equ $cb
CH_ATN			equ $cc
CH_LN			equ $cd
CH_EXP			equ $ce
CH_INT			equ $cf
CH_SQR			equ $d0
CH_SGN			equ $d1
CH_ABS			equ $d2
CH_PEEK			equ $d3
CH_USR			equ $d4
CH_STR_DOLLAR	equ $d5
CH_CHR_DOLLAR	equ $d6
CH_NOT			equ $d7
CH_POWER		equ $d8
CH_OR			equ $d9
CH_AND			equ $da
CH_LE			equ $db
CH_GE			equ $dc
CH_NE			equ $dd
CH_THEN			equ $de
CH_TO			equ $df
CH_STEP			equ $e0
CH_LPRINT		equ $e1
CH_LLIST		equ $e2
CH_STOP			equ $e3
CH_SLOW			equ $e4
CH_FAST			equ $e5
CH_NEW			equ $e6
CH_SCROLL		equ $e7
CH_CONT			equ $e8
CH_DIM			equ $e9
CH_REM			equ $ea
CH_FOR			equ $eb
CH_GOTO			equ $ec
CH_GOSUB		equ $ed
CH_INPUT		equ $ee
CH_LOAD			equ $ef
CH_LIST			equ $f0
CH_LET			equ $f1
CH_PAUSE		equ $f2
CH_NEXT			equ $f3
CH_POKE			equ $f4
CH_PRINT		equ $f5
CH_PLOT			equ $f6
CH_RUN			equ $f7
CH_SAVE			equ $f8
CH_RAND			equ $f9
CH_IF			equ $fa
CH_CLS			equ $fb
CH_UNPLOT		equ $fc
CH_CLEAR		equ $fd
CH_RETURN		equ $fe
CH_COPY			equ $ff

; ZX81 keyboard codes 

NO_KEY		equ 0

KEY_Z		equ 1
KEY_X		equ 2
KEY_C		equ 3
KEY_V		equ 4

KEY_A		equ 5
KEY_S		equ 6
KEY_D		equ 7
KEY_F		equ 8
KEY_G		equ 9

KEY_Q		equ 10
KEY_W		equ 11
KEY_E		equ 12
KEY_R		equ 13
KEY_T		equ 14

KEY_1		equ 15
KEY_2		equ 16
KEY_3		equ 17
KEY_4		equ 18
KEY_5		equ 19

KEY_0		equ 20
KEY_9		equ 21
KEY_8		equ 22
KEY_7		equ 23
KEY_6		equ 24

KEY_P		equ 25
KEY_O		equ 26
KEY_I		equ 27
KEY_U		equ 28
KEY_Y		equ 29

KEY_NEWLINE	equ 30
KEY_L		equ 31
KEY_K		equ 32
KEY_J		equ 33
KEY_H		equ 34

KEY_SPACE	equ 35
KEY_DOT		equ 36
KEY_M		equ 37
KEY_N		equ 38
KEY_B		equ 39

; ZX81 ROM routines

SCAN_KEYBOARD	equ $02bb
KEY_DECODE		equ $07bd
