
;==============================================================================
;
; Wrapper for goc
; Input
;   d0.w=resource slot index
; Output
;   a0.l=pointer to resource
;
;==============================================================================

resourceLoadGoc
	bsr			resourceLoadStaticFile
	rts


