
;==============================================================================
;
; Error. Called with error code and error color. Never exits.
; Input
;   d0.l=error code
;   d1.w=error color
;
;==============================================================================

errorScreen
	nop
	bra			errorScreen
