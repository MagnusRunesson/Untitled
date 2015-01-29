;==============================================================================
;
; Structures
;
;==============================================================================
;
; Renderer sprite information
;
;	rsreset
;sRendSprite_TileID:			rs.l	1
;sRendSprite_FileID:			rs.w	1
;sRendSprite_Size:			rs.b	1

;
; Constants
;
rend_num_sprites		= 80
hw_sprite_byte_size		= 8


;
; CPU Memory map
;
	setso				platform_renderer_start
VarVsync				so.l 	1										; Vertical sync counter
VarHsync				so.l	1										; Horizontal sync counter
VarNextSpriteAddress	so.l	1										; The address where the last loaded sprite tiles was loaded to
VarLockedSpriteAddress	so.l	1										; Locked address where we can free tiles to
VarNextSpriteSlot		so.l	1										; Next available sprite index in our sprite tables
VarLockedSpriteSlot		so.l	1										; Locked sprite index for free
VarHWSprites			so.b	hw_sprite_byte_size*rend_num_sprites	; This will never be greater than $280. The hardware sprite attribute size won't change and there will never be more than 80 sprites.
	clrso

;
; VRAM memory map
;
VRAM_MapTiles_Start				= $0000
VRAM_SpriteTiles_Start			= $b800		; This one goes down when allocated, so it should be the same as another VRAM tag
VRAM_SpriteAttributes_Start		= $b800		; There are requirements as to what this address can be! (Only the top 6 bits are used when in 40 cell mode, top 7 bits when in 32 cell mode)
VRAM_HScroll_Start				= $bc00		; There are requirements as to what this address can be! (Only the top 6 bits are used.)
VRAM_TileMap0_Start				= $c000
VRAM_TileMap1_Start				= $e000


;
; Convert a regular integer value into a VRAM address
; and move that converted address into a register
;
; Usage:
; move_vram_addr	$a000,d0		; Convert $a000 to $60000002 (or whatever it becomes) and move that into d0
;
move_vram_addr	MACRO
	move.l		#((((\1)&$3fff)<<16)+(((\1)>>14)&3))|(1<<30),\2
	ENDM


;==============================================================================
;
; Initialize the VDP and CPU states of the renderer
;
;==============================================================================
rendInit:
	move.l		#0,(VarNextSpriteSlot)
	move.l		#0,(VarLockedSpriteSlot)
	move.l		#VRAM_SpriteTiles_Start,(VarNextSpriteAddress)
	move.l		#VRAM_SpriteTiles_Start,(VarLockedSpriteAddress)

	; Clear all mirror sprites
	move.l		#0,d0
	move.l		#(hw_sprite_byte_size*rend_num_sprites/4)-1,d1
	move.l		#VarHWSprites,a0

.clear_loop:
	move.l  	d0,(a0)+
	dbra    	d1,.clear_loop

	jsr			InitVDP


;	move.l		#$00C00004,a0
;	move.w		#$8F02,(a0)
;	move_vram_addr	VRAM_HScroll_Start,(a0)
;
;	move.l		#$00C00000,a0
;
;	move		#240,d0			; Write 240 scan lines of data
;	move		#0,d1
;
;.hscoll_loop:
;	move.w		d1,(a0)			; Write to plane A hscroll table
;	move.w		d1,(a0)			; Write to plane B hscroll table
;	add			#1,d1
;	and			#$1f,d1
;	dbra		d0,.hscoll_loop

	rts


;==============================================================================
;
; WaitVsync
;
;==============================================================================
rendWaitVSync:
	; Read initial value
	move.l		(VarVsync),d0			; Read value from VarVsync into D0

.loop:
	; Read current value and see if it has changed
	move.l		(VarVsync),d1			; Read value from VarVsync into D1
	cmp.l		d0,d1					; Compare D0 and D1

	; No change means jump. Change means fall through.
	beq			.loop					; If result is 0 the value has not been changed
										; so jump back to 1

	rts									; Return to caller


;==============================================================================
;
; Set scroll position for both horizontal scroll (X) and vertical scroll (Y)
;
; d0=X scroll
; d1=Y scroll
;
;==============================================================================
rendSetScrollXY:
	and			#511,d0
	and			#511,d1
	muls		#-1,d0
	add			#512,d0

	; Setup CPU registers and VDP auto increment register
	move.l		#$00C00000,a0		; Throughout all my code I'll use A4
	move.l		#$00C00004,a1		; for the VDP data port and A5 for the
	move.w		#$8F02,(a1)			; Disable autoincrement

	; Set horizontal scroll
	move_vram_addr	VRAM_HScroll_Start,(a1)
	move.w		d0,(a0)
	move.w		d0,(a0)

	; Set vertical scroll
	move.l		#$40000010,(a1)		; Point the VDP data port to the vertical scroll table
	move.w		d1,(a0)
	move.w		d1,(a0)

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
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; Create the number of longs to copy, based in the number of tiles from the file
	move.w		(a0)+,d1
	lsl			#5-2,d1		; We should shift up 5 bits because each tile is
							; 32 bytes, but we should also shift down 2 bits
							; because we copy 4 bytes per copy

	; Now create the VRAM offset
	move_vram_addr		VRAM_MapTiles_Start,d0

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			_rendCopyToVRAM

	rts


;==============================================================================
;
; Loads a sprite into memory. Both allocates a sprite attribute slot and load
; the sprite tiles into VRAM.
;
; Input
;	d0=file ID of tile bank file to load into VRAM
;	d1=file ID of the sprite file that configures
;
; Output
;	d0=Sprite handle
;
;==============================================================================
rendLoadSprite:
	; Setup a stack frame and store some stuffs
	stack_alloc		16
	stack_write.l	d3,0
	stack_write.l	d1,4

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr				fileLoad
	; a0 is the return address from fileLoad

	; Load the number of tiles to copy from the bank data
	move.w			(a0)+,d1
	lsl				#5,d1		; Now we have the byte size of the
								; tiles that should be loaded

	; Find VRAM address to load the tiles to
	move.l			(VarNextSpriteAddress),d0
	sub.l			d1,d0
	move.l			d0,(VarNextSpriteAddress)
	; d0 is now the VRAM address to load the sprite tiles to

	stack_write.l	d0,8
	stack_write.l	d1,12
	jsr				_rendIntegerToVRAMAddress
	stack_read.l	d1,12

	lsr				#2,d1		; d1 is the size of the tiles in bytes, but it
								; should be the size in longs for _rendCopyToVRAM

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr				_rendCopyToVRAM
	stack_read.l	d0,8

	; Fetch the next available sprite slot
	move.l			(VarNextSpriteSlot),d1
	move.l			d1,d3

	; And allocate one
	add.l			#1,(VarNextSpriteSlot)

	; Find address of sprite attributes mirror and renderer sprite data
	mulu			#hw_sprite_byte_size,d1
	add.l			#VarHWSprites,d1
	move.l			d1,a0
	; Now a0 points to somewhere in the sprite attributes mirror table

	; d0 still points to the VRAM address, in bytes, that the tiles
	; was copied to. Lets convert that into a tile ID and store in
	; the sprite hw mirror table.
	lsr				#5,d0

	; d0=Tile ID of the sprite tile bank where the data was loaded to
	; a0=Address of the sprite hw attribute table mirror for the sprite that was allocated
	jsr				_rendSetSpriteTileID_Address

	; Load the sprite information file to get the dimensions of the sprite
	; Read the file ID from the stack
	stack_read.l	d0,4

	; Retain the address to the sprite mirror table for this sprite
	stack_write.l	a0,4

	; d0=File ID of the sprite information file
	jsr				fileLoad
	; d0 is now the size of the sprites file
	; a0 is the address to the sprite information

	move.b			(a0)+,d0	; Fetch sprite width in pixels
	move.b			(a0)+,d1	; Fetch sprite height in pixels
	lsr				#3,d0		; Convert width from pixels to tiles
	lsr				#3,d1		; Convert height from pixels to tiles

	; Also, on the Mega Drive, the width and size are defined from 0-3,
	; where 0 means 1 tile wide, and 3 means 4 tiles wide) So we need
	; to subtract one from the tile dimensions
	sub				#1,d0
	sub				#1,d1

	; Fetch the sprite mirror table address
	stack_read.l	a0,4

	; d0=Sprite width, in tiles
	; d1=Sprite height, in tiles
	; a0=Sprite mirror table address
	jsr				_rendSetSpriteDimensions_Address

	; Set sprite coordinates
	move.l			#0,d0
	move.l			#0,d1
	jsr				_rendSetSpritePosition_Address

	move.l			d3,d0		; d3 is the sprite slot ID
	jsr				_rendCopySpriteToVRAM_Index

	; Sprite 0 is always rendered. But if this sprite isn't sprite 0 then
	; it needs to be added to the linked list of sprites to render
	cmp.l			#0,d3
	beq				.already_connected

	move.l			d3,d0		; d3 is the sprite slot ID
	jsr				_rendAddSprite_Index

.already_connected:

	; Put the sprite slot ID into d0 as the return value
	move.l			d3,d0

	; Clear up stack frame and be happy
	stack_read.l	d3,0
	stack_free		16
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
	push		d3
	push		d1					; Push X coordinate to stack

	move.l		d0,d3				; Retain the sprite slot index in d3
	mulu		#8,d0				; Calculate the byte offset to the sprite data

	;
	move.l		#VarHWSprites,d1	; Get base address to the sprite mirror table
	add			d0,d1				; Add the offset to the sprite index before d0
	move.l		d1,a0				; We want to address it

	; a0 is now the address to the sprite slot in the sprite mirror table
	; d0 is garbage
	; d1 is garbage
	; d2 is the Y position
	pop			d0					; Pop X coordinate from stack
	move.l		d2,d1
	jsr			_rendSetSpritePosition_Address

	; Refresh data in VRAM
	move.l		d3,d0
	jsr			_rendCopySpriteToVRAM_Index

	pop			d3
	rts


;==============================================================================
;
; Load a tile map into VRAM
;
; d0=file ID of tile bank file to load into VRAM
; d1=Which slot to store the map in.
;		Slot #0 - Background layer (behind sprites)
;		Slot #1 - Foreground layer (in front of sprites)
;
;==============================================================================
rendLoadTileMap:
	;
	push		d2
	push		d3

	; Push the slot ID onto the stack
	push		d1

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; Read the width and height of the tile map and calculate how many
	; longs to copy to get the entire tile map from file to VRAM
	move.b		(a0)+,d0
	move.b		(a0)+,d1

	; Retain width and height in register d2 and d3
	clr			d2
	clr			d3
	move.b		d0,d2
	move.b		d1,d3

	mulu		d0,d1
	lsr			#1,d1

	; Now fetch the slot argument and convert to a VRAM destination address
	pop			d0
	lsl			#2,d0		; Multiply by 4 because we read longs from a1
	lea			.SlotAddresses,a1
	add.l		d0,a1
	move.l		(a1),d0

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			_rendCopyToVRAM

	; Set hardware register to match the loaded width and height
	move.w		#$9000,d0

	; Check width
	cmp.b		#64,d2
	beq			.width_64

	cmp.b		#128,d2
	beq			.width_128

	bra			.check_height

.width_64:
	or.w		#$0001,d0
	bra			.check_height

.width_128:
	or.w		#$0001,d0

	; Check height of map
.check_height:

	cmp.b		#64,d3
	beq			.height_64

	cmp.b		#128,d3
	beq			.height_128

.height_64:
	or.w		#$0010,d0
	bra			.set_dimensions

.height_128:
	or.w		#$0010,d0

.set_dimensions:
	move.w		d0,($00C00004)

	pop			d3
	pop			d2

	rts

.SlotAddresses:
	dc.l		$40000003
	dc.l		$60000003	; Untested destination address


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
	; Push the slot index onto the stack
	move.l		d1,-(sp)

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; How many longs to copy
	move.l		#32/4,d1

	; Now fetch the slot argument and convert to a CRAM destination address
	move.l		(sp)+,d0
	lsl			#2,d0		; Multiply by 4 because we read longs from a1
	lea			.SlotAddresses,a1
	add.l		d0,a1
	move.l		(a1),d0

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			_rendCopyToVRAM

	rts

.SlotAddresses:
	dc.l		$C0000000	; Slot index 0
	dc.l		$C0200000	; Slot index 1 - untested
	dc.l		$C0400000	; Slot index 2 - untested
	dc.l		$C0600000	; Slot index 3 - untested


;==============================================================================
;
; General copy from CPU to VRAM subroutine
;
; a0=source addres
; d0=destination offset
; d1=size to copy
;
;==============================================================================
_rendCopyToVRAM:
	move.l		#$00C00004,a1

    move.w  	#$8F02,(a1)				; Set autoincrement (register 15) to 2
    move.l  	d0,(a1)					; Point data port to start of VRAM

	move.l		#$00C00000,a1

	sub.l		#1,d1

.1:
	move.l  	(a0)+,(a1)				; Move long word from patterns into VDP
										; port and increment A0 by 4
	dbra    	d1,.1					; If D1 is not zero decrement and jump
										; back to 1
    
    rts									; Return to caller


;==============================================================================
;
; Set the tile ID of a sprite in the hw mirror table
;
; Input
;	d0 = new tile ID
;	a0 = the address of the sprite to modify
;
;==============================================================================
_rendSetSpriteTileID_Address:
	move.w		4(a0),d1
	and.w		#$07ff,d0		; Binary: 0000 0111 1111 1111
	and.w		#$f800,d1		; Binary: 1111 1000 0000 0000
	or.w		d0,d1
	move.w		d1,4(a0)
	rts


;==============================================================================
;
; Set the width and height of a sprite in the hw mirror table
;
; Input
;	d0 = width, in tiles
;	d1 = height, in tiles
;	a0 = the address of the sprite to modify
;
;==============================================================================
_rendSetSpriteDimensions_Address:
	push		d2
	move.b		#0,d2
	or			d1,d2
	lsl			#2,d0
	or			d0,d2
	move.b		d2,2(a0)
	pop			d2
	rts


;==============================================================================
;
; Set the X and Y coordinate of a sprite into the mirror table
;
; Input
;	d0 = X position, in pixels. 0 is left most pixel on screen
;	d1 = Y position, in pixels. 0 is top line on screen
;	a0 = the address of the sprite to modify
;
;==============================================================================
_rendSetSpritePosition_Address:
	add.l		#$80,d0
	add.l		#$80,d1
	move.w		d1,(a0)
	move.w		d0,6(a0)
	rts


;==============================================================================
;
; Add sprite with index d0 to the render list.
;
; Input
;	d0 = The sprite slot ID that should be added to the render list
;
;==============================================================================
_rendAddSprite_Index:
	push		d2
	move.l		d0,d2				; Retain the sprite slot index in d2

	sub.l		#1,d0				; We actually want to modify
									; the sprite BEFORE this
	mulu		#8,d0				; Calculate the byte offset to the sprite data

	;
	move.l		#VarHWSprites,d1	; Get base address to the sprite mirror table
	add			d0,d1				; Add the offset to the sprite index before d0
	move.l		d1,a0				; We want to address it

	; a0 is now the address to the sprite slot in the sprite mirror table
	; d2 is the sprite index

	move.b		d2,3(a0)

	; Refresh data in VRAM
	move.l		d2,d0
	sub			#1,d0
	jsr			_rendCopySpriteToVRAM_Index

	pop			d2
	rts


;==============================================================================
;
; Copy the sprite mirror table entry from CPU RAM to VRAM
;
; Input
;	d0 = Sprite entry index. Allowed range is 0-79
;
;==============================================================================
_rendCopySpriteToVRAM_Index:
	push		d0

	move.l		#VRAM_SpriteAttributes_Start,d1
	mulu		#8,d0
	add.l		d1,d0
	jsr			_rendIntegerToVRAMAddress
	; Now d0 is the destination address in VRAM

	move.l		#$00C00004,a0
	move.w		#$8F02,(a0)			; Set autoincrement (register 15) to 2
	move.l		d0,(a0)				; Set destination address in VRAM

	; Get the source address
	pop			d0
	mulu		#8,d0
	add.l		#VarHWSprites,d0
	move.l		d0,a0
	; Now a0 is the source

	; Data write register
	move.l		#$00C00000,a1

	; Copy the sprite settings
	move.l		(a0)+,(a1)
	move.l		(a0)+,(a1)

	rts


;==============================================================================
;
; Translate a regular integer to a Mega Drive VRAM address
;
; Input:
; d0 = original address
;
; Output:
; d0 = Mega Drive "scrambled" address
;
; Source bits look like this
; A31 A30 A29 A28 A27 A26 A25 A24 A23 A22 A21 A20 A19 A18 A17 A16
; A15 A14 A13 A12 A11 A10 A09 A08 A07 A06 A05 A04 A03 A02 A01 A00
;
; Destination bits look like this
; CD1 CD0 A13 A12 A11 A10 A09 A08 A07 A06 A05 A04 A03 A02 A01 A00
;   0   0   0   0   0   0   0   0   0   0   0 CD2   0   0 A15 A14
;
; So only the bottom 16 bits of the source are used, and they are
; shuffled around. Then a mask is added on top of that to indicate
; a VRAM write.
;
;==============================================================================
_rendIntegerToVRAMAddress:
	move.l	d0,d1
	and.l	#$3fff,d0
	lsr.l	#7,d1		; Shift 14 bits right, but since it isn't possible to shift
	lsr.l	#7,d1		; more than 8 bits at a time I do two instructions instead
	lsl.l	#8,d0		; Shift 16 bits to the left
	lsl.l	#8,d0
	and.l	#3,d1
	or.l	d1,d0
	or.l	#$40000000,d0
	rts





;==============================================================================
;
; Helper routines
;
;==============================================================================
InitVDP:
	moveq		#18,d0						; 24 registers, but we set only 18
	lea			VDPRegs,a0					; start address of register values
	move.l		#$00C00004,a4				; The VDP control register
	clr.l		d5

.loop:
	move.w		(a0)+,d5					; load lower byte (register value)
	move.w		d5,(a4)						; write register
	dbra		d0,.loop					; loop

	rts										; Jump back to caller

VDPRegs:
	dc.w		$8004						; Reg.  0: Enable Hint, HV counter stop
	dc.w		$8174						; Reg.  1: Enable display, enable Vint, enable DMA, V28 mode (PAL & NTSC)
	dc.b		$82							; Reg.  2: Plane A tile map
	dc.b		VRAM_TileMap0_Start>>10
	dc.w		$8340						; Reg.  3: Window is at $10000 (disable)
	dc.b		$84							; Reg.  4: Plane B tile map
	dc.b		VRAM_TileMap1_Start>>13
	dc.b		$85							; Reg.  5: Sprite attribute table
	dc.b		VRAM_SpriteAttributes_Start>>9
	dc.w		$8600						; Reg.  6: always zero
	dc.w		$8700						; Reg.  7: Background color: palette 0, color 0
	dc.w		$8800						; Reg.  8: always zero
	dc.w		$8900						; Reg.  9: always zero
	dc.w		$8a00						; Reg. 10: Hint timing
	dc.w		$8b08						; Reg. 11: Enable Eint, full scroll
	dc.w		$8c81						; Reg. 12: Disable Shadow/Highlight, no interlace, 40 cell mode
	dc.b		$8d							; Reg. 13: Horizontal scroll table
	dc.b		VRAM_HScroll_Start>>10
	dc.w		$8e00						; Reg. 14: always zero
	dc.w		$8f00						; Reg. 15: no autoincrement
	dc.w		$9000						; Reg. 16: Scroll 32V and 32H
	dc.w		$9100						; Reg. 17: Set window X position/size to 0
	dc.w		$9200						; Reg. 18: Set window Y position/size to 0
	dc.w		$9300						; Reg. 19: DMA counter low
	dc.w		$9400						; Reg. 20: DMA counter high
	dc.w		$9500						; Reg. 21: DMA source address low
	dc.w		$9600						; Reg. 22: DMA source address mid
	dc.w		$9700						; Reg. 23: DMA source address high, DMA mode ?
