;==============================================================================
;
; Load file to specified memory address
;
; Input:
;	d0=file ID
;	a0=address to load file to
;
; Output
;	d0=file size
;
;==============================================================================
fileLoad:
	lea			FileIDMap(pc),a1
	asl.l		#2,d0
	add.l		d0,a1
	moveq		#0,d0
	move.w		(a1)+,d0
	moveq		#0,d1	
	move.w		(a1),d1

	move.l		d1,-(sp)
	bsr			trackdiskLoadBlock
	move.l		(sp)+,d0

	rts
