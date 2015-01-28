	
	; include		"hardware/custom.i"
	; include		"hardware/dmabits.i"
	; include		"exec_lib.i"
	; include		"graphics_lib.i"
	


	
;==============================================================================
;
; WaitVsync
;
;==============================================================================

rendWaitVSync:
	
	; More information: http://eab.abime.net/showthread.php?t=51928
	
.1	btst	#0,(_custom+vposr+1)
	beq		.1
.2	btst	#0,(_custom+vposr+1)
	bne		.2
	
	rts



;==============================================================================
;
; Set scroll position for both horizontal scroll (X) and vertical scroll (Y)
;
; d0=X scroll
; d1=Y scroll
;
;==============================================================================

rendSetScrollXY:
	rts


;==============================================================================
;
; Set the screen coordinate of a sprite given its ID
;
; Input
;	d0 = Sprite ID
;	d1 = X position. 0 is leftmost pixel on screen, negative allowed
;	d2 = Y position. 0 is topmost pixel on screen, negative allowed
;
;==============================================================================

rendSetSpritePosition:
	rts


;==============================================================================
;
; Load a tile bank into VRAM
;
; d0=file ID of tile bank file to load into VRAM
;
;==============================================================================

rendLoadTileBank:
	rts


;==============================================================================
;
; Load a tile map from disk into VRAM
;
; d0=file ID of tile bank file to load into VRAM
; d1=Which slot to store the map in.
;		Slot #0 - Background layer (behind sprites)
;		Slot #1 - Foreground layer (in front of sprites)
;
;==============================================================================

rendLoadTileMap:
	rts


;==============================================================================
;
; Load a sprite from disk to VRAM. This function is responsible for allocating
; VRAM for the sprite and return some form of handle back to the game so the
; game have a way to modify sprite properties such as position.
;
; Men fanken vet hur. :/
;
; d0=File ID
;
;==============================================================================

rendLoadSprite:
	rts


;==============================================================================
;
; Load a palette map into CRAM
;
; d0=file ID of palette file to load into CRAM
; d1=Which slot index to store the palette in
;	Allowed slot indices are 0 to 3 inclusive
;
;==============================================================================

rendLoadPalette:
	rts
