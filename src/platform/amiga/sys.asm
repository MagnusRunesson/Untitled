entryPoint:
	; rainbow
;	moveq		#4,d0
;.two
;	moveq		#-1,d1
;.rainbows
;	move.w		d1,d2
;	and.w		#$0F00,d2
;	move.w		d2,$dff180
;	;move.w		#$0FFF,$dff180
;	dbf			d1,.rainbows
;	dbf			d0,.two
;
;firstAbove
	
	lea			_custom,a2
	; move.w		#DMAF_ALL,dmacon(a2)
	move.w		#DMAF_ALL|DMAF_MASTER,dmacon(a2)
	
	lea			Copper_bplpt(pc),a0
	; lea			_data_untitled_splash_planar(pc),a1
	;lea			BitplaneMem(pc),a1
	_get_workmem_ptr BitplaneMem,a1
	move.l		a1,d0
	moveq		#4-1,d1
.bplconLoop
	swap.w		d0
	move.w		d0,2(a0)
	swap.w		d0
	move.w		d0,6(a0)
	add.l		#64,d0
	add.l		#8,a0	
	dbra		d1,.bplconLoop
	
	; move.w		#$2c81,diwstrt(a2)
	; move.w		#$0cc1,diwstop(a2)
	; move.w		#$0038,ddfstrt(a2)
	; move.w		#$00d0,ddfstop(a2)
	; move.w		#$0000,bpl1mod(a2)
	; move.w		#$0000,bpl2mod(a2)
	
	lea			Copper(pc),a0
	move.l		a0,cop1lc(a2)
	move.w		d0,copjmp1(a2)
	
	; lea			copperInterrupt(pc),a0
	; move.l		a0,_interrupt_vec_copper
	
	move.w		#(DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_BLITTER|DMAF_MASTER),dmacon(a2)
	move.w		#$7FFF,intena(a5)
	; MOVE.w		#$83A0,DMACON(a5)	; Enable DMA
	
	

	; rainbow
;	moveq		#4,d0
;.two
;	moveq		#-1,d1
;.rainbows
;	move.w		d1,d2
;	and.w		#$0F0F,d2
;	move.w		d2,$dff180
	;move.w		#$0FFF,$dff180
;	dbf			d1,.rainbows
;	dbf			d0,.two
	
	; load file FILEID_UNTITLED_SPLASH_PLANAR to bplmem

	bsr			trackdiskInit

	;move.l		#_data_untitled_splash_planar/512,d0
	;moveq		#_data_untitled_splash_planar_length,d1
	;_get_workmem_ptr	BitplaneMem,a0

	;bsr			trackdiskLoadBlock
	
	; rainbow
;again
;	moveq		#6,d0
;.two
;	moveq		#-1,d1
;.rainbows
;	move.w		d1,d2
;	and.w		#$00FF,d2
;	move.w		d2,$dff180
;	dbf			d1,.rainbows
;	dbf			d0,.two
	
	
	
	jsr			main(pc)
	
	; teardown
	
	rts


;==============================================================================
;
; Variables
;
;==============================================================================
	cnop	0,4
	


;==============================================================================
;
; Copper
;
;==============================================================================
Copper
	dc.w	bplcon0,$4200
	dc.w	bplcon1,$0000
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,$00d8	; 3*64+24=D8, 3*64=C0, 3*40=78
	dc.w	bpl2mod,$00d8
Copper_bplpt
	dc.w	bplpt+0,$0000
	dc.w	bplpt+2,$0000
	dc.w	bplpt+4,$0000
	dc.w	bplpt+6,$0000
	dc.w	bplpt+8,$0000
	dc.w	bplpt+10,$0000
	dc.w	bplpt+12,$0000
	dc.w	bplpt+14,$0000
Copper_color
	;dc.w	color+0,$0000	
	;dc.w	color+2,$0EEE
	;dc.w	color+4,$0CCC
	;dc.w	color+6,$0888
	;dc.w	color+8,$0666	
	;dc.w	color+10,$0444
	;dc.w	color+12,$0222
	;dc.w	color+14,$0000
	;dc.w	color+16,$00F0
	;dc.w	color+18,$000F
	;dc.w	color+20,$0FF0
	;dc.w	color+22,$00FF
	;dc.w	color+24,$0F0F
	;dc.w	color+26,$0F80
	;dc.w	color+28,$008F
	;dc.w	color+30,$0F00

	dc.w	color+0,$0000	
	dc.w	color+2,$0000
	dc.w	color+4,$0444
	dc.w	color+6,$088a
	dc.w	color+8,$0eee
	dc.w	color+10,$004a
	dc.w	color+12,$008c
	dc.w	color+14,$0282
	dc.w	color+16,$02a2
	dc.w	color+18,$04c4
	dc.w	color+20,$0820
	dc.w	color+22,$0a60
	dc.w	color+24,$0e0e
	dc.w	color+26,$0e0e
	dc.w	color+28,$0e82
	dc.w	color+30,$0e04

	dc.w	$FFFF,$FFFE
	;0e0e 0000 0444 0a88 0eee 0a40 0c80 0282
	;02a2 04c4 0028 006a 0e0e 0e0e 028e 040e
	