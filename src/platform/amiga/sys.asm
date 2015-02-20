;==============================================================================
;
; Amiga entry point
; Will orchestrate game system initialization and tear down, and restore of
; Amiga-OS when runned from file
;
;==============================================================================

sysEntryPoint
    
    ; Initialization
	lea			_custom,a2
	
	move.w		#DMAF_ALL|DMAF_MASTER,dmacon(a2)	
	move.w		#(DMAF_SETCLR|DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER|DMAF_DISK),dmacon(a2)
	move.w		#$7FFF,intena(a2)
	
	bsr			rendInit
	bsr			trackdiskInit
	bsr			resourceInit
	
	; Main loop
	jsr			main(pc)
	
	; Tear down, and restore of Amiga-OS
	
	rts

;==============================================================================
;
; Error screen. For now simple colorcycling. d0 masks color
;
;==============================================================================
sysError
	lea			_custom,a6
.forever
	moveq		#-1,d1
.loop
	move.w		d1,d2
	and.w		d0,d2
	move.w		d2,color(a6)
	dbf			d1,.loop

	bra.s		.forever
