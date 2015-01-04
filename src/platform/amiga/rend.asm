	
	include		"hardware/custom.i"
	

	
rendInit:
	; jsr			InitVDP
	; ;move.l		#$11213141,$fffff4		; Write some magic values so we know we've reached this far

	; jsr			LoadPalettes
	; ;move.l		#$12223242,$fffff8		; Write some magic values so we know we've reached this far

	; jsr			LoadPatterns
	; jsr			FillPlaneA
	; jsr			FillPlaneB

	; jsr			LoadSprites
	; ;move.l		#$12223344,$fffffc		; Write some magic values so we know we've reached this far

	rts

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
; kurt: 	dc.w 	$0000

rendSetScrollXY:

	movem.l	d2-d3,-(sp)
	
	; lea		kurt(pc),a0
	; move.w	(a0),d2
	; add.w	#$1,d2
	; move.w	d2,(a0)
	; move.w	d2,$dff180
	move.w	d0,d2
	and.w	#$000f,d2
	asl.w	#4,d2
	move.w	d1,d3
	and.w	#$000f,d3
	or.w    d3,d2
	move.w	d2,_custom+color
	; move.w	#$0f00,_custom+color

	movem.l	(sp)+,d2-d3
	


	
	
	rts



