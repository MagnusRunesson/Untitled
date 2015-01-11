	
	include		"hardware/custom.i"
	include		"hardware/dmabits.i"
	include		"exec_lib.i"
	include		"graphics_lib.i"
	

	
entrypoint:
	lea		_custom,a2
	move.w	#DMAF_ALL,dmacon(a2)
	
	lea		copperbplpt(pc),a0
	lea		_data_untitled_splash_planar(pc),a1
	move.l	a1,d0
	moveq	#4-1,d1
.bplconloop
	swap.w	d0
	move.w	d0,2(a0)
	swap.w	d0
	move.w	d0,6(a0)
	add.l	#320*224/8,d0
	add.l	#8,a0	
	dbra		d1,.bplconloop
	
	; move.w	#$2c81,diwstrt(a2)
	; move.w	#$0cc1,diwstop(a2)
	; move.w	#$0038,ddfstrt(a2)
	; move.w	#$00d0,ddfstop(a2)
	; move.w	#$0000,bpl1mod(a2)
	; move.w	#$0000,bpl2mod(a2)
	
	lea		copper(pc),a0
	move.l	a0,cop1lc(a2)
	move.w	d0,copjmp1(a2)
	
	
	move.w	#(DMAF_SETCLR!DMAF_COPPER|DMAF_RASTER),dmacon(a2)

	jsr		main(pc)
	
	; teardown
	
	rts

	cnop	0,4
copper
	dc.w	bplcon0,$4200
	dc.w	bplcon1,$0000
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$0cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,$0000
	dc.w	bpl2mod,$0000
copperbplpt
	dc.w	bplpt+0,$0000
	dc.w	bplpt+2,$0000
	dc.w	bplpt+4,$0000
	dc.w	bplpt+6,$0000
	dc.w	bplpt+8,$0000
	dc.w	bplpt+10,$0000
	dc.w	bplpt+12,$0000
	dc.w	bplpt+14,$0000
coppercolor
	dc.w	color+0,$0000	
	dc.w	color+2,$0EEE
	dc.w	color+4,$0CCC
	dc.w	color+6,$0888
	dc.w	color+8,$0666	
	dc.w	color+10,$0444
	dc.w	color+12,$0222
	dc.w	color+14,$0000
	dc.w	color+16,$0000
	dc.w	color+18,$0000
	dc.w	color+20,$0000
	dc.w	color+22,$0000
	dc.w	color+24,$0000
	dc.w	color+26,$0000
	dc.w	color+28,$0000
	dc.w	color+30,$0000	
	dc.w	$FFFF,$FFFE
	



