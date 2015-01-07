	
	include		"hardware/custom.i"
	include		"hardware/dmabits.i"
	include		"exec_lib.i"
	include		"graphics_lib.i"
	

	
rendInit:
	lea		_custom,a1
	move.w	#DMAF_ALL,dmacon(a1)
	
	lea		copper(pc),a0
	move.l	a0,cop1lc(a1)
	move.w	d0,copjmp1(a1)
	
	move.w	#(DMAF_SETCLR!DMAF_COPPER),dmacon(a1)
	
	rts

copper:
	dc.w	bplcon0,$0200
	dc.w	color+0*2,$0FFF
	dc.w	color+1*2,$0F00
	dc.w	color+2*2,$00F0
	dc.w	color+3*2,$000F
copwait:
	dc.w	$9601,$FFFE
	dc.w	color+0*2,$0404
	dc.w	color+1*2,$0FF0
	dc.w	color+2*2,$00FF
	dc.w	color+3*2,$0F0F	
	dc.w	$FFFF,$FFFE
	
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

	movem.l	d2-d3,-(sp)
	
	; move.w	d0,d2
	; and.w	#$000f,d2
	; asl.w	#4,d2
	; move.w	d1,d3
	; and.w	#$000f,d3
	; or.w    d3,d2
	; move.w	d2,_custom+color
	
	; move.w	#$0f00,_custom+color
	
	; move.w	d1,d2
	and.w	#$00ff,d0
	and.w	#$00ff,d1
	asl.w	#8,d1
	or.w    d1,d0
	or.w	#$0001,d0
	lea		copwait(pc),a0
	move.w	d0,(a0)

	movem.l	(sp)+,d2-d3
	


	
	
	rts



