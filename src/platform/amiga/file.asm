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
	move.l		#0,a0
	move.l		#0,d0
	rts
