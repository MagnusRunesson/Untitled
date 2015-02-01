
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
; Set which frame of a sprite animation that should be shown
;
; d0=Sprite ID
; d1=Frame index
;
;==============================================================================

rendSetSpriteFrame:
	rts


;==============================================================================
;
; Load a tile bank into VRAM
;
; d0=file ID of tile bank file to load into VRAM
;
;==============================================================================

rendLoadTileBank:
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	
	_get_workmem_ptr	TilebankMem,a0
	bsr					fileLoad
	
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

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	movem.l			a0-a6/d0-d7,-(sp)
	
	_get_workmem_ptr	TilemapMem,a0
	bsr					fileLoad

	_get_workmem_ptr	TilemapMem,a0
	_get_workmem_ptr	TilebankMem,a1
	_get_workmem_ptr	BitplaneMem,a5

	addq.l			#2,a0		; don't care about header for now

	moveq			#32-1,d7	; d7=y dbra
.yloop
	moveq			#64-1,d6	; d6=x dbra
.xloop

	moveq			#0,d0
	move.w			(a0)+,d0

	move.l			a1,a2
	mulu			#8*4,d0
	add.l			d0,a2


	move.l			a5,a4
	moveq			#8-1,d5
.drawLoop
	move.b			(a2)+,(a4)
	move.b			(a2)+,64(a4)
	move.b			(a2)+,128(a4)
	move.b			(a2)+,192(a4)
	add.l			#256,a4
	dbf				d5,.drawLoop

	addq.l			#1,a5
	dbf				d6,.xloop

	add.l			#(7*256)+192,a5
	dbf				d7,.yloop

	movem.l			(sp)+,a0-a6/d0-d7
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
	movem.l			a0-a6/d0-d7,-(sp)

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	_get_workmem_ptr	TilemapMem,a0
	jsr			fileLoad

	movem.l			(sp)+,a0-a6/d0-d7
	rts

