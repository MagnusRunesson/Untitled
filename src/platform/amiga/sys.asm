entryPoint:
	lea			_custom,a2
	; move.w		#DMAF_ALL,dmacon(a2)
	move.w		#DMAF_ALL|DMAF_MASTER,dmacon(a2)

	
	
	move.w		#(DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_BLITTER|DMAF_MASTER),dmacon(a2)
	move.w		#$7FFF,intena(a5)
	
	
	
	bsr			rendInit

	bsr			trackdiskInit

	jsr			main(pc)
	
	; teardown
	
	rts


