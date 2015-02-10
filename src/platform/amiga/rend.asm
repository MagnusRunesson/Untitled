
;==============================================================================
;
; Init
;
;==============================================================================

rendInit:
	lea			_custom,a2

	_get_workmem_ptr BitplaneMem,a0
	subq.l		#2,a0
	bsr			_setupBitplanePointers
	
	lea 		SpriteExportTest(pc),a0
	lea 		Copper_sprpt+2(pc),a1
	move.l		a0,d0
	swap.w		d0
	move.w		d0,(a1)
	swap.w		d0
	move.w		d0,4(a1)
	
	lea 		SpriteExportTest+72(pc),a0
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
	
	lea			Copper(pc),a0
	move.l		a0,cop1lc(a2)
	move.w		d0,copjmp1(a2)
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
	movem.l			a0-a6/d0-d7,-(sp)
	
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

	movem.l			(sp)+,a0-a6/d0-d7
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

rendLoadSprite:
	rts


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
	movem.l			a0-a6/d0-d7,-(sp)

	move.l		d1,d3
	
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	_get_workmem_ptr	PaletteMem,a0
	jsr			fileLoad

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


	movem.l			(sp)+,a0-a6/d0-d7
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
	movem.l		d2-d3,-(sp)

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

	movem.l		(sp)+,d2-d3
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


	; temp hack to move player character (sprite ID=1)

	movem.l		d2-d7/a2-a5,-(sp)
	
	cmp.w		#1,d0
	bne.s		testBob

	add.w		#$81,d1		; d1=hstart (high bits)
	move.l		d1,d3		; d3=hstart (low bit)
	
	add.w		#$2c,d2		; d2=vstart (low bits)
	move.l		d2,d4		; d4=vstart (high bit)
	
	move.l		d2,d5		; d5=vstop (low bits)
	add.l		#16,d5		; sprite heigth
	move.l		d5,d6		; d6=vstop (high bit)

	lsr.w		#1,d1
	and.w		#$00ff,d1	; <- remove?
	lsl.w		#8,d2
	and.w		#$ff00,d2	; <- remove?
	or.w		d2,d1		; d1=sprxpos

	lsl.w		#8,d5
	and.w		#$ff00,d5	; <- remove?
	and.w		#$0001,d3
	or.w		d3,d5
	lsl.w		#8-1,d6		; bit pos 8 -> pos 1
	and.w		#$0002,d6
	or.w		d6,d5
	lsl.w		#8-2,d4		; bit pos 8 -> pos 2
	and.w		#$0004,d4
	or.w		d4,d5		;d5=sprxctl
	
	lea			SpriteExportTest(pc),a0
	lea			SpriteExportTest+72(pc),a1
	move.w		d1,(a0)+
	move.w		d1,(a1)+
	move.w		d5,(a0)
	or.w		#$0080,d5	; attach
	move.w		d5,(a1)

	movem.l		(sp)+,d2-d7/a2-a5
	rts


testBob
	lea			_custom,a6

	move.l		d1,d3
	lsr.l		#3,d1
	and.l		#$fffffffe,d1
	
	add.l		#16,d2
	lsl.l		#8,d2


	and.w		#$0f,d3
	ror.w		#4,d3

	_get_workmem_ptr BitplaneMem,a2
	add.l		d1,a2
	add.l		d2,a2

	lea			TestBobGfx(pc),a0
	lea			TestBobMask(pc),a1
	bsr			waitBlit

	move.l		a0,bltbpt(a6)
	move.l		a1,bltapt(a6)
	move.l		a2,bltcpt(a6)
	move.l		a2,bltdpt(a6)
	move.w		#-2,bltamod(a6)
	move.w		#-2,bltbmod(a6)
	move.w		#60,bltcmod(a6)
	move.w		#60,bltdmod(a6)
	move.w		#$0000,bltalwm(a6)
	move.w		#$ffff,bltafwm(a6)	

	move.w		d3,d4
	or.w		#SRCA|SRCB|SRCC|DEST|$CA,d4			; D=A:$f0 $E2
	move.w		d4,bltcon0(a6)	
	;move.w		#SRCA|DEST|$F0,bltcon0(a6)	; D=A:$f0
	move.w		d3,bltcon1(a6)
	move.w		#$1002,bltsize(a6)

	movem.l		(sp)+,d2-d7/a2-a5
	rts

waitBlit
	btst.b		#DMAB_BLTDONE-8,dmaconr(a6)
.waitBlit
	btst.b		#DMAB_BLTDONE-8,dmaconr(a6)
	bne.s		.waitBlit
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
; Variables
;
;==============================================================================
	cnop	0,4
	
SpriteExportTest
	incbin	"../src/incbin/herotest_sprite_amiga.bin"

SpriteBlank
	dc.w	$0000,$0000
	dc.w	$0000,$0000

TestBobGfx
	dc.w	$0ff0,$0000,$0000,$0000
	dc.w	$3fec,$0010,$0ff0,$0000
	dc.w	$7fc2,$000c,$33fc,$0000
	dc.w	$3f0c,$00f0,$0ff0,$0000
	dc.w	$0ff0,$0000,$0000,$0000
	dc.w	$11f8,$0e00,$0ff0,$0000
	dc.w	$11f8,$0a00,$0f90,$0000
	dc.w	$21fc,$1600,$1fd8,$0000
	dc.w	$23fc,$1400,$1fe8,$0000
	dc.w	$42fe,$2c00,$3fec,$0000
	dc.w	$47fe,$3800,$3ff4,$0000
	dc.w	$ffbf,$0000,$7ff2,$0000
	dc.w	$fbff,$0000,$7fe2,$0000
	dc.w	$ffff,$0000,$7f86,$0000
	dc.w	$7ffe,$0000,$3ffc,$0000
	dc.w	$3ffc,$0000,$0000,$0000

TestBobMask
	dc.w	$0ff0,$0ff0,$0ff0,$0ff0
	dc.w	$3ffc,$3ffc,$3ffc,$3ffc
	dc.w	$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$3ffc,$3ffc,$3ffc,$3ffc
	dc.w	$0ff0,$0ff0,$0ff0,$0ff0
	dc.w	$1ff8,$1ff8,$1ff8,$1ff8
	dc.w	$1ff8,$1ff8,$1ff8,$1ff8
	dc.w	$3ffc,$3ffc,$3ffc,$3ffc
	dc.w	$3FFC,$3FFC,$3FFC,$3FFC
	dc.w	$7FFE,$7FFE,$7FFE,$7FFE
	dc.w	$7FFE,$7FFE,$7FFE,$7FFE
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$7FFE,$7FFE,$7FFE,$7FFE
	dc.w	$3ffc,$3ffc,$3ffc,$3ffc

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