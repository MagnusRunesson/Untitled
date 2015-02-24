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
	push.l		d2

	lea			FileIDMap(pc),a1
	asl.l		#2,d0
	add.l		d0,a1
	moveq		#0,d0
	move.w		(a1)+,d0		; file position (sector index)
	moveq		#0,d1	
	move.w		(a1),d1			; file length in number of sectors
		
	move.l		d1,d2			; file length in bytes
	mulu.w		#_chunk_size,d2 

	bsr			trackdiskLoadBlock

	move.l		d2,d0			; file length in bytes

	pop.l		d2
	rts


