
;==============================================================================
;
; Consts
;
;==============================================================================

_rend_sprite_max_count_				equ		(80)



;==============================================================================
;
; Structures
;
;==============================================================================

							rsreset
__RendSpritePosX			rs.w	1
__RendSpritePosY			rs.w	1
__RendSpriteFrame			rs.w	1
__RendSpriteResourceId		rs.w	1
__RendSpriteBankResourceId	rs.w	1
;__RendSpriteFlags			rs.w	1
__RendSpriteSizeof			rs.b	0

							rsreset
__RendScrollX				rs.w	1
__RendScrollY				rs.w	1
__RendNextSprite			rs.w	1
__RendSpriteCopperPointer	rs.l	1
__RendVarsSizeof			rs.b	0

_RendVars
	dcb.b	__RendVarsSizeof

_RendSprites
	dcb.b	_rend_sprite_max_count_*__RendSpriteSizeof

	cnop	0,2
	

;==============================================================================
;
; Macros
;
;==============================================================================

_wait_blit	MACRO

	btst.b		#DMAB_BLTDONE-8,dmaconr(a6)
.waitBlit
	btst.b		#DMAB_BLTDONE-8,dmaconr(a6)
	bne.s		.waitBlit
	
	ENDM

;==============================================================================
;
; Init
;
;==============================================================================

rendInit:
	pushm		d2-d7/a2-a6

	lea			_custom,a2

	_get_workmem_ptr BitplaneMem,a0
	subq.l		#2,a0
	bsr			_setupBitplanePointers
	
	
	
	lea			Copper(pc),a0
	move.l		a0,cop1lc(a2)
	move.w		d0,copjmp1(a2)

	; RendVars defaults
	lea			_RendVars(pc),a0
	move.w		#0,__RendScrollX(a0)
	move.w		#0,__RendScrollY(a0)
	move.w		#0,__RendNextSprite(a0)

	popm		d2-d7/a2-a6
	rts

_rendSetupSpritePointers
	pushm		d0-d7/a2-a6

	lea 		_ResSpriteMemPool(pc),a3
	move.l		__ResMemPoolBottomOfMem(a3),a0
	add.l		#512*2,a0

	lea 		Copper_sprpt+2(pc),a1
	move.l		a0,d0
	swap.w		d0
	move.w		d0,(a1)
	swap.w		d0
	move.w		d0,4(a1)
	
	lea			72(a0),a0
	addq		#8,a1
	move.l		a0,d0
	swap.w		d0
	move.w		d0,(a1)
	swap.w		d0
	move.w		d0,4(a1)

	lea			SpriteBlank(pc),a0
	move.l		a0,d0
	addq		#8,a1
	moveq		#6-1,d1
.spriteLoop
	swap.w		d0
	move.w		d0,(a1)
	swap.w		d0
	move.w		d0,4(a1)
	addq		#8,a1
	dbf			d1,.spriteLoop

	popm		d0-d7/a2-a6
	rts


;==============================================================================
;
; Setup bitplane pointers
; a0=pointers to bitplanes
;
;==============================================================================

_setupBitplanePointers
	move.l		a0,d0
	lea			Copper_bplpt(pc),a0	
	moveq		#4-1,d1
.bplconLoop
	swap.w		d0
	move.w		d0,2(a0)
	swap.w		d0
	move.w		d0,6(a0)
	add.l		#64,d0
	add.l		#8,a0	
	dbra		d1,.bplconLoop

	rts

;==============================================================================
;
; Load a tile bank into CRAM
;
; d0=file ID of tile bank file to load into CRAM
;
;==============================================================================

rendLoadTileBank:
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	
	_get_workmem_ptr	TilebankMem,a0
	bsr					fileLoad
	
	rts

;==============================================================================
;
; Load a tile map into memory
;
; d0=file ID of tile bank file to load into VRAM
; d1=Which slot to store the map in.
;		Slot #0 - Background layer (behind sprites)
;		Slot #1 - Foreground layer (in front of sprites)
;
;==============================================================================

rendLoadTileMap:

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	pushm			a0-a6/d0-d7
	
	_get_workmem_ptr	TilemapMem,a0
	bsr					fileLoad

	_get_workmem_ptr	TilemapMem,a0
	_get_workmem_ptr	TilebankMem,a1
	_get_workmem_ptr	BitplaneMem,a5

	addq.l			#2,a0		; don't care about header for now

	moveq			#64-1,d7	; d7=y dbra
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

	popm			a0-a6/d0-d7
	rts


;==============================================================================
;
; Load a sprite into memory. Both allocates a sprite attribute slot and load 
; the sprite tiles into CRAM.
;
; Input
;	d0=file ID of tile bank file to load into VRAM
;	d1=file ID of the sprite file that configures
;
; Output
;	d0=Sprite handle
;
;==============================================================================

rendLoadSprite
	pushm		d2-d7/a2-a7

	; a2=Rend vars struct
	; d7=Sprite handle (return value)
	lea			_RendVars(pc),a2
	move.w		__RendNextSprite(a2),d7			
	
	; Check if this sprite available
	cmp.w		#_rend_sprite_max_count_,d7
	beq			.noSpriteAvailable

	; Update __RendNextSprite variable
	; d2=Next sprite handle	
	move.w		d7,d2							
	addq		#1,d2
	move.w		d2,__RendNextSprite(a2)

	; a3=Sprite struct pointer
	lea			_RendSprites(pc),a3
	move.w		d7,d2
	mulu.w		#__RendSpriteSizeof,d2
	add.l		d2,a3

	; Default values for sprite
	move.w		#0,__RendSpritePosX(a3)
	move.w		#0,__RendSpritePosY(a3)
	move.w		#0,__RendSpriteFrame(a3)

	; Load sprite bank
	move.l		d1,d2					; Backup file id of sprite file in d2
	bsr			resourceLoadSpriteBank
	move.w		d0,__RendSpriteBankResourceId(a3)

	move.l		d2,d0					; file id back into d0
	bsr			resourceLoadSprite
	move.w		d0,__RendSpriteResourceId(a3)

	; Return sprite handle
	moveq		#0,d0
	move.w		d7,d0

	popm		d2-d7/a2-a7
	rts

.noSpriteAvailable
	move.w		#$00f0,d0
	jmp			sysError(pc)



;==============================================================================
;
; Load a palette map into CRAM
;
; d0=file ID of palette file to load into CRAM
; d1=Which slot index to store the palette in
;	Allowed slot indices are 0 to 3 inclusive
;   Amiga actually retarget slot 2 to slot 0, and slot 3 to slot 1
;
;==============================================================================

rendLoadPalette:
	pushm		a0-a6/d0-d7

	move.l		d1,d3
	
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	_get_workmem_ptr	PaletteMem,a0
	jsr			fileLoad(pc)

	_get_workmem_ptr	PaletteMem,a0
	lea			Copper_color+2(pc),a1
	and.l		#$01,d3					; For now, Amiga retarget slot to slot 0 and 1
	lsl.l		#6,d3
	;mulu		#16*4,d3
	add.l		d3,a1

	moveq		#16-1,d0
.loop
	move.w		(a0)+,d1
	move.w		d1,d2
	move.w		d1,d3
	and.w		#$00F0,d1
	and.w		#$0F00,d2
	and.w		#$000F,d3	
	ror.w		#8,d2
	rol.w		#8,d3
	or.w		d2,d1
	or.w		d3,d1

	move.w		d1,(a1)
	addq.l		#4,a1
	dbf			d0,.loop


	popm		a0-a6/d0-d7
	rts

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

	; Probably not the right place for this code
	pushm	a0-a1
	lea		_RendVars,a0
	lea 	Copper_sprpt+2(pc),a1
	move.l	a1,__RendSpriteCopperPointer(a0)
	popm	a0-a1

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
	pushm		d2-d3

	; Update RendVars
	lea			_RendVars(pc),a0
	move.w		d0,__RendScrollX(a0)
	move.w		d1,__RendScrollY(a0)

	subq.l		#2,a0					; make up for ddfstrt

	move.l		d0,d2

	subq.l		#1,d0
	and.l		#$fffffff0,d0			; d0=x scroll high bits (bpl ptr)
	asr.l		#3,d0

	neg.w		d2
	and.l		#$0f,d2					; d2=x scroll low bits (bplcon0 bits)
	move.l		d2,d3
	rol.w		#4,d3
	or.w		d3,d2	

	lsl.l		#8,d1					; d1=y scroll (bpl ptr)

	_get_workmem_ptr BitplaneMem,a0
	add.l		d0,a0
	add.l		d1,a0
	bsr 		_setupBitplanePointers
	
	lea			Copper_bplcon1+2,a0
	move.w		(a0),d0
	and.w		#$ff00,d0
	or.w		d2,d0
	move.w		d0,(a0)

	popm		d2-d3
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
	; a0=Sprite struct pointer
	lea			_RendSprites(pc),a0
	mulu.w		#__RendSpriteSizeof,d0
	add.l		d0,a0

	; Update position
	move.w		d1,__RendSpritePosX(a0)
	move.w		d2,__RendSpritePosY(a0)

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
	; a0=Sprite struct pointer
	lea			_RendSprites(pc),a0
	mulu.w		#__RendSpriteSizeof,d0
	add.l		d0,a0

	move.w		d1,__RendSpriteFrame(a0)
	rts



;==============================================================================
;
; Set the draw order of our sprites. The table should contain sprite handles
; in the order they should be drawn. That means that the sprite handle that
; appear first in this table should be drawn first to the screen. The second
; sprite that appears in the table should be dawn on top of the previous one.
;
; Input
;	a0 = address to table of draw orders. Each entry should be 1 byte
;	d0 = the number of entries in the table.
;
;==============================================================================
rendSetSpriteDrawOrder:
	pushm		d2-d7/a2-a6

	lea			_custom,a6

	; Move inbound parameters to registers that wont be destroyed by calls to 
	; sub routines
	; a3=address to table of draw orders
	; d2=number of sprites to draw
	move.l		d0,d2
	move.l		a0,a3

	;subq		#1,d2
.loop
	; d0=Sprite handle
	moveq		#0,d0
	move.b		(a3)+,d0

	; a2=Sprite struct pointer
	lea			_RendSprites(pc),a2
	mulu		#__RendSpriteSizeof,d0
	add.l		d0,a2

	; Get resource for sprite bank, put it in a1
	move.w		__RendSpriteBankResourceId(a2),d0
	bsr			resourceGetSpriteBank
	move.l		a0,a1

	; Get resource for sprite , leave it in a0
	move.w		__RendSpriteResourceId(a2),d0
	bsr			resourceGetSprite


	; d0=Sprite flags
	move.b		spritefile_struct_flags(a0),d0
	;moveq		#0,d3
	;moveq		#0,d4
	;move.w		__RendSpritePosX(a2),d3
	;move.w		__RendSpritePosY(a2),d4
	btst		#spritefile_flag_isspriteb_bit,d0

	bne			.drawBSprite

.drawASprite	
	bsr			_drawBob	
	bra			.continue

.drawBSprite
	bsr			_drawSprite

	; continue
.continue
	dbf			d2,.loop

	; exit
	popm		d2-d7/a2-a6
	rts


;==============================================================================
;
; Draw hardware sprite
;
; Input
;	a0 = resource for sprite
;	a1 = resource for sprite bank
;   a2=Sprite struct pointer
;
;==============================================================================

_drawSprite
	pushm		d2-d7/a2-a5

	lea			_RendVars,a3
	move.l		__RendSpriteCopperPointer(a3),a4

	move.l		a1,d0
	swap.w		d0
	move.w		d0,(a4)
	swap.w		d0
	move.w		d0,4(a4)
	
	addq		#8,a4
	add.l		#72,d0
	swap.w		d0
	move.w		d0,(a4)
	swap.w		d0
	move.w		d0,4(a4)

	addq		#8,a4
	move.l		a4,__RendSpriteCopperPointer(a3)

	moveq		#0,d1
	moveq		#0,d2
	move.w		__RendSpritePosX(a2),d1
	move.w		__RendSpritePosY(a2),d2


	add.w		#$81,d1		; d1=hstart (high bits)
	move.l		d1,d3		; d3=hstart (low bit)
	
	add.w		#$2c,d2		; d2=vstart (low bits)
	move.l		d2,d4		; d4=vstart (high bit)
	
	move.l		d2,d5		; d5=vstop (low bits)
	add.l		#16,d5		; sprite heigth
	move.l		d5,d6		; d6=vstop (high bit)

	lsr.w		#1,d1
	lsl.w		#8,d2
	or.w		d2,d1		; d1=sprxpos

	lsl.w		#8,d5
	and.w		#$0001,d3
	or.w		d3,d5
	lsr.w		#8-1,d6		; bit pos 8 -> pos 1
	and.w		#$0002,d6
	or.w		d6,d5
	lsr.w		#8-2,d4		; bit pos 8 -> pos 2
	and.w		#$0004,d4
	or.w		d4,d5		;d5=sprxctl
	
	lea			72(a1),a3

	move.w		d1,(a1)+
	move.w		d1,(a3)+
	move.w		d5,(a1)
	or.w		#$0080,d5	; attach
	move.w		d5,(a3)

	popm		d2-d7/a2-a5
	rts

;==============================================================================
;
; Draw blitter object
;
; Input
;	a0 = resource for sprite
;	a1 = resource for sprite bank
;   a2 = Sprite struct pointer
;   a6 = Custom base
;
;==============================================================================
_drawBob
	pushm		d2-d7/a2-a5

	moveq		#0,d0
	moveq		#0,d1
	move.w		__RendSpritePosX(a2),d0
	move.w		__RendSpritePosY(a2),d1

	lea			_RendVars(pc),a3
	add.w		__RendScrollX(a3),d0
	add.w		__RendScrollY(a3),d1

	move.l		d0,d2
	lsr.l		#3,d0
	and.l		#$fffffffe,d0
	
	lsl.l		#8,d1

	and.w		#$0f,d2
	ror.w		#4,d2

	_get_workmem_ptr BitplaneMem,a4
	add.l		d0,a4
	add.l		d1,a4

	move.l		a1,a5
	
	_wait_blit

	move.l		a5,bltbpt(a6)
	add.l		#16*16/8*4,a5
	move.l		a5,bltapt(a6)
	move.l		a4,bltcpt(a6)
	move.l		a4,bltdpt(a6)
	move.w		#-2,bltamod(a6)
	move.w		#-2,bltbmod(a6)
	move.w		#60,bltcmod(a6)
	move.w		#60,bltdmod(a6)
	move.w		#$0000,bltalwm(a6)
	move.w		#$ffff,bltafwm(a6)	

	move.w		d2,d3
	or.w		#SRCA|SRCB|SRCC|DEST|$CA,d3			; D=A:$f0 $E2
	move.w		d3,bltcon0(a6)	
	;move.w		#SRCA|DEST|$F0,bltcon0(a6)	; D=A:$f0
	move.w		d2,bltcon1(a6)
	move.w		#$1002,bltsize(a6)

	popm		d2-d7/a2-a5
	rts

;==============================================================================
;
; Variables
;
;==============================================================================
	cnop	0,4


SpriteBlank
	dc.w	$0000,$0000
	dc.w	$0000,$0000

;==============================================================================
;
; Copper
;
;==============================================================================
Copper
Copper_bplcon0
	dc.w	bplcon0,$4200
Copper_bplcon1
	dc.w	bplcon1,$0000
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0030
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,$00d6	; 3*64+24=D8, 3*64=C0, 3*40=78
	dc.w	bpl2mod,$00d6
Copper_bplpt
	dc.w	bplpt+0,$0000
	dc.w	bplpt+2,$0000
	dc.w	bplpt+4,$0000
	dc.w	bplpt+6,$0000
	dc.w	bplpt+8,$0000
	dc.w	bplpt+10,$0000
	dc.w	bplpt+12,$0000
	dc.w	bplpt+14,$0000
Copper_sprpt
	dc.w	sprpt+0,$0000
	dc.w	sprpt+2,$0000
	dc.w	sprpt+4,$0000
	dc.w	sprpt+6,$0000
	dc.w	sprpt+8,$0000
	dc.w	sprpt+10,$0000
	dc.w	sprpt+12,$0000
	dc.w	sprpt+14,$0000
	dc.w	sprpt+16,$0000
	dc.w	sprpt+18,$0000
	dc.w	sprpt+20,$0000
	dc.w	sprpt+22,$0000
	dc.w	sprpt+24,$0000
	dc.w	sprpt+26,$0000
	dc.w	sprpt+28,$0000
	dc.w	sprpt+30,$0000	
Copper_color
	dc.w	color+0,$0000	;0
	dc.w	color+2,$0000
	dc.w	color+4,$0000
	dc.w	color+6,$0000
	dc.w	color+8,$0000	;4
	dc.w	color+10,$0000
	dc.w	color+12,$0000
	dc.w	color+14,$0000
	dc.w	color+16,$0000	;8
	dc.w	color+18,$0000
	dc.w	color+20,$0000
	dc.w	color+22,$0000
	dc.w	color+24,$0000	;12
	dc.w	color+26,$0000
	dc.w	color+28,$0000
	dc.w	color+30,$0000

	dc.w	color+32,$0000	;16
	dc.w	color+34,$0000
	dc.w	color+36,$0000
	dc.w	color+38,$0000
	;dc.w	color+34,$0FF0
	;dc.w	color+36,$00FF
	;dc.w	color+38,$0F0F
	dc.w	color+40,$0000	;20
	dc.w	color+42,$0000
	dc.w	color+44,$0000
	dc.w	color+46,$0000
	dc.w	color+48,$0000	;24
	dc.w	color+50,$0000
	dc.w	color+52,$0000
	dc.w	color+54,$0000
	dc.w	color+56,$0000	;28
	dc.w	color+58,$0000
	dc.w	color+60,$0000
	dc.w	color+62,$0000
Copper_end
	dc.w	$FFFF,$FFFE