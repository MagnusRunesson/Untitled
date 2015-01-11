; a0 = Pointer to image data to load
imgLoad:
	; Load tile bank first
	move	#0,d0				; Since I don't know how to fetch a word and clear the top bits I do this first
	move.w	(a0)+,d0			; Fetch file ID of the tile bank and load it
	move	#0,d1				; Destination address in VRAM
	jsr		rendLoadTileBank

	; Load map

	; Load palette
	rts
