
;==============================================================================
;
; Gets pointer to workmem (pc-relative), using workmembegin as a "middle label"
;
; usage: 
;  \1 = workmem symbol to get
;  \2 = where to place the ptr
; example:
;  _get_workmem_ptr	BitplMem,a0 ; gets ptr to BitplaMem and places into 
;  register a0
;
;==============================================================================
_get_workmem_ptr	MACRO	\1 \2
	lea			workmembegin(pc),\2
	add.l		#(\1-workmembegin),\2
	ENDM

;==============================================================================
;
; Will set the border color to index 0 in the palette. Might get modified so 
; the color index is a parameter.
;
;==============================================================================
perf_start		MACRO
	move.w		#$0646,$DFF180
	ENDM

;==============================================================================
;
; Will set the border color to index 1 in the palette. Might get modified so 
; the color index is a parameter.
;
;==============================================================================
perf_stop		MACRO
	move.w		#$0000,$DFF180
	ENDM

