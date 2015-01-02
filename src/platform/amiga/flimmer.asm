

flimmer	

	moveq	#-1,d0
.loop
	move.w	d0,$dff180
	dbra	d0,.loop
	
	moveq	#-1,d0
.loop2
	move.w	#$0f0f,$dff180
	dbra	d0,.loop2
	; nop
	
	bra.s	flimmer

data
	dc.b	'krister'
	; dc.l	0