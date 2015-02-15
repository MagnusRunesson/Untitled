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

fileLoad
	pushm		d1-d7/a0-a6

	lea			FileIDMap(pc),a1
	asl.l		#2,d0
	add.l		d0,a1
	moveq		#0,d0
	move.w		(a1)+,d0
	moveq		#0,d1	
	move.w		(a1),d1

	push		d1			; file length in number of sectors

	bsr			trackdiskLoadBlock

	pop			d0

	popm		d1-d7/a0-a6
	rts


