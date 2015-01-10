;==============================================================================
;
; Get the address to a file
;
; Input:
;	d0=file ID
;
; Output
;	a0=address to file data
;	d0=file size
;
;==============================================================================
fileLoad:
	printt		''
	printt		'=====> File ID map is at:'
	printv		FileIDMap
	printt		''

	lea			FileIDMap,a0
	mulu		#4,d0
	add.l		d0,a0
	clr.l		d0
	clr.l		d1
	move.w		(a0)+,d0		; Read offset
	move.w		(a0)+,d1		; Read size

	mulu		#_chunk_size,d0	; Offset is not in bytes but in X byte chunks. Correct that.
	move.l		d0,a0			; Move the corrected address into the return register

	rts
