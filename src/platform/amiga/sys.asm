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
