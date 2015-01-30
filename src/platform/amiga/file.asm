;==============================================================================
;
; Load file to specified memory address
;
; Input:
;	d0=file ID
;	a0=address to load file to
;
; Output
;	none
;
;==============================================================================
fileLoad:
	lea			FileIDMap(pc),a1
	asl.l		#2,d0
	add.l		d0,a1
	moveq		#0,d0
	moveq		#0,d1
	move.w		(a1)+,d0
	move.w		(a1),d1

	bsr			trackdiskLoadBlock

	rts
