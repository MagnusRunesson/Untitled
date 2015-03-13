
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


;==============================================================================
;
; Wrapper for collision maps
; Input
;   d0.w=resource slot index
; Output
;   a0.l=pointer to resource
;
;==============================================================================

resourceLoadCollisionMap
	bsr			resourceLoadStaticFile
	rts

resourceResetCollisionMap
	; not needed for static resources
	rts