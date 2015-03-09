
;==============================================================================
;
; Error. Called with error code and error color. Never exits.
; Input
;   d0.l=error code
;   d1.w=error color
;
;==============================================================================

errorScreen
	lea			_custom,a6
.forever
	moveq		#-1,d2
.loop
	move.w		d2,d3
	and.w		d1,d3
	move.w		d3,color(a6)
	dbf			d2,.loop

	bra.s		.forever
