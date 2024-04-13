		include "sysvars.inc"
		
; START OF YOUR CODE

main:	jr main

; START OF DISPLAY FILE, only the bytes needed

dfile:	db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76
		zx81text "%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO%D%E%M%ODEMO"
		db $76

vars:	db 128					; overwitten after load by "jp(hl)"

last:
