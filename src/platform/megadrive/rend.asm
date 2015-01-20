;==============================================================================
;
; Structures
;
;==============================================================================
;
; Renderer sprite information
;
	rsreset
sRendSprite_TileID:			rs.l	1
sRendSprite_FileID:			rs.w	1
sRendSprite_Size:			rs.b	1

;
; Constants
;
rend_num_sprites		= 80


;
; Memory map
;
	setso				platform_renderer_start
VarVsync				so.l 	1									; Vertical sync counter
VarHsync				so.l	1									; Horizontal sync counter
VarNextSpriteAddress	so.l	1									; The address where the last loaded sprite tiles was loaded to
VarLockedSpriteAddress	so.l	1									; Locked address where we can free tiles to
VarNextSpriteSlot		so.l	1									; Next available sprite index in our sprite tables
VarLockedSpriteSlot		so.l	1									; Locked sprite index for free
VarHWSprites			so.b	8*rend_num_sprites					; This will never be greater than $280. The hardware sprite attribute size won't change and there will never be more than 80 sprites.
VarRendSprites			so.b	sRendSprite_Size*rend_num_sprites	; Our local table of sprites that holds information about which tile a sprite was loaded to, etc..
	clrso

move_vram_addr	MACRO
	move.l		#((((\1)&$3fff)<<16)+(((\1)>>14)&3))|(1<<30),\2
	ENDM

push			MACRO
	move.l		\1,-(sp)
	ENDM

pop				MACRO
	move.l		(sp)+,\1
	ENDM

rendInit:
	move.l		#0,(VarNextSpriteSlot)
	move.l		#0,(VarLockedSpriteSlot)
	move.l		#$a000,(VarNextSpriteAddress)
	move.l		#$a000,(VarLockedSpriteAddress)

	jsr			InitVDP
	jsr			LoadSprites
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
	; Setup CPU registers and VDP auto increment register
	move.l		#$00C00000,a0		; Throughout all my code I'll use A4
	move.l		#$00C00004,a1		; for the VDP data port and A5 for the
	move.w		#$8F00,(a1)			; Disable autoincrement

	; Set horizontal scroll
	move.l		#$50000003,(a1)		; Point the VDP data port to the horizontal scroll table
	move.w		d0,(a0)

	; Set vertical scroll
	move.l		#$40000010,(a1)		; Point the VDP data port to the vertical scroll table
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
	;move.l		d1,-(sp)
	;move.l		#VRAM_MapTiles_Start,d0
	;jsr		_rendIntegerToVRAMAddress
	;move.l		(sp)+,d1

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			_rendCopyToVRAM

	rts


;==============================================================================
;
; Load a tile bank into VRAM
;
; d0=file ID of tile bank file to load into VRAM
;
;==============================================================================
rendLoadSprite:
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; Load the number of tiles to copy from the bank data
	move.w		(a0)+,d1
	lsl			#5,d1		; Now we have the byte size of the
							; tiles that should be loaded

	; Find VRAM address to load the tiles to
	move.l		(VarNextSpriteAddress),d0
	sub.l		d1,d0

	; Retain the new address for future uses
	move.l		d0,(VarNextSpriteAddress)

	push		d1
	jsr			_rendIntegerToVRAMAddress
	pop			d1

	;move.l		#$a000,d0
	;jsr			_rendIntegerToVRAMAddress	; We should normally push a0 to the
											; stack since it is a scratch register,
											; but this sub routine is nice to
											; the scratch registers.
	;move_vram_addr		$a000,d0
	;move.l		(VarNextSpriteAddress),d0


	lsr			#2,d1		; d1 is the size of the tiles in bytes, but it
							; should be the size in longs for _rendCopyToVRAM

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			_rendCopyToVRAM

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
	; Push the slot ID onto the stack
	move.l		d1,-(sp)

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; d0 is set to the size of the file but _rendCopyToVRAM expect it to be in d1
	move.l		#64*32/2,d1		; How many longs to copy

	; Now fetch the slot argument and convert to a VRAM destination address
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
	dc.l		$40000003
	dc.l		$60000002	; Untested destination address


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

	move.l		d1,d0

.1:
	move.l  	(a0)+,(a1)				; Move long word from patterns into VDP
										; port and increment A0 by 4
	dbra    	d0,.1					; If D0 is not zero decrement and jump
										; back to 1
    
    rts									; Return to caller



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
	;dc.w		$8240						; Reg.  2: Plane A is at $10000 (disable)
	dc.w		$8230						; Reg.  2: Plane A is at $C000
	dc.w		$8340						; Reg.  3: Window is at $10000 (disable)
	;dc.w		$8440						; Reg.  4: Plane B is at $10000 (disable?)
	dc.w		$8407						; Reg.  4: Plane B is at $E000
	;dc.w		$8430						; Reg.  4: Plane B is at $C000
	dc.w		$8570						; Reg.  5: Sprite attribute table is at $E000
	dc.w		$8600						; Reg.  6: always zero
	dc.w		$8700						; Reg.  7: Background color: palette 0, color 0
	dc.w		$8800						; Reg.  8: always zero
	dc.w		$8900						; Reg.  9: always zero
	dc.w		$8a00						; Reg. 10: Hint timing
	dc.w		$8b08						; Reg. 11: Enable Eint, full scroll
	dc.w		$8c81						; Reg. 12: Disable Shadow/Highlight, no interlace, 40 cell mode
	dc.w		$8d34						; Reg. 13: Hscroll is at $D000
	dc.w		$8e00						; Reg. 14: always zero
	dc.w		$8f00						; Reg. 15: no autoincrement
	dc.w		$9001						; Reg. 16: Scroll 32V and 32H
	dc.w		$9100						; Reg. 17: Set window X position/size to 0
	dc.w		$9200						; Reg. 18: Set window Y position/size to 0
	dc.w		$9300						; Reg. 19: DMA counter low
	dc.w		$9400						; Reg. 20: DMA counter high
	dc.w		$9500						; Reg. 21: DMA source address low
	dc.w		$9600						; Reg. 22: DMA source address mid
	dc.w		$9700						; Reg. 23: DMA source address high, DMA mode ?



LoadSprites:
	move.l		#$00C00000,a4
	move.l		#$00C00004,a5

	move.w		#$8F02,(a5)			; Set autoincrement (register 15) to 2
	move.l		#$60000003,(a5)
	lea			SpriteSetting,a0

	move.l		(a0)+,(a4)			; Sprite setting should be 0 (1x1 sprite, tile index 4, no more sprites)
	move.l		(a0)+,(a4)			; Sprite setting should be 0 (1x1 sprite, tile index 4, no more sprites)

	rts
	
SpriteSetting:
	dc.w		$0080
	dc.w		$0500
	dc.w		$04fc
	dc.w		$0080
