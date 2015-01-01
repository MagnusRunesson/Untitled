

flimmer	

	moveq	#-1,d0
.loop
	move.w	d0,$dff180
	dbra	d0,.loop
	
	moveq	#-1,d0
.loop2
	move.w	#$0F0F,$dff180
	dbra	d0,.loop2
	
	bra.s	flimmer

data
	dc.l	0