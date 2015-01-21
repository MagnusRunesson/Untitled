	; usage: 
;  \1 = workmem symbol to get
;  \2 = where to place the ptr
; example:
;  _get_workmem_ptr	BitplMem,a0 ; gets ptr to BitplaMem and places into register a0
_get_workmem_ptr	MACRO	\1 \2
	lea			workmembegin(pc),\2
	add.l		#(\1-workmembegin),\2
	ENDM