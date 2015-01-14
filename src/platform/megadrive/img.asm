; a0 = Pointer to image data to load
imgLoad:
	; Load tile bank first
	move	#0,d0				; Since I don't know how to fetch a word and clear the top bits I do this first
	move.w	(a0)+,d0			; Fetch file ID of the tile bank and load it
	move	#0,d1				; Destination address in VRAM
	move.l	a0,-(sp)
	jsr		rendLoadTileBank
	move.l	(sp)+,a0

	; Load map
	move.w	(a0)+,d0			; Fetch file ID of the tile bank and load it
	move	#0,d1				; #0 is the background layer
	move.l	a0,-(sp)
	jsr		rendLoadTileMap
	move.l	(sp)+,a0

	; Load palette
	move.w	(a0)+,d0			; Fetch file ID of the tile bank and load it
	move	#0,d1				; #0 is the background palette
	move.l	a0,-(sp)
	jsr		rendLoadPalette
	move.l	(sp)+,a0

	rts
