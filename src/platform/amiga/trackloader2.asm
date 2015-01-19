
_mfm_sync_pattern						equ	($4489)
_mfm_mask								equ	($55555555)
_dsklen_dma_off							equ ($4000) ; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0192.html

_step_wait_time_3_ms					equ	(2128)	; (3 * 1000) / 1.4096836810788
_select_head_wait_time_0_1_ms			equ	(71)	; (0.1 * 1000) / 1.4096836810788
_reverse_direction_delay_time_18_ms		equ (12769)	; (18 * 1000) / 1.4096836810788
_track_settle_delay_time_15_ms			equ (10641)	; (15 * 1000) / 1.4096836810788

;==============================================================================
;
; Initialized trackdisk system
;
;==============================================================================

trackdiskInit
	movem.l		d2-d7/a2-a6,-(sp)

	bsr			_trackdiskPrepareRegisters
	bsr			_startMotor
	bsr			_waitDiskReady
	bsr			_trackdiskSetDirectionOutwardNoCheck

.checkAndStepToTrackZero
	btst.b		#CIAB_DSKTRACK0,ciapra(a4)
	beq.s		.atTrackZero
	bsr			_trackdiskStepHeadAndWait
	bra.s		.checkAndStepToTrackZero

.atTrackZero:	
	bsr			_trackdiskSetDirectionCenter

	move.w		#0,_TrackdiskCurrentCylinder

	bsr			_stopMotor
	;;;;;;;;;bsr			_waitDiskReady

	movem.l		(sp)+,d2-d7/a2-a6	
	rts

;==============================================================================
;
; Loads blocks from df0: to target memory 
;
; d0=First block to load
; d1=Number of blocks to load
; a0=Target memory
;
;==============================================================================

trackdiskLoadBlock
	movem.l		d2-d7/a2-a6,-(sp)

	bsr			_trackdiskPrepareRegisters

	bsr			_startMotor
	bsr			_waitDiskReady

	subq.l		#1,d1		; -1 for dbf
.sectorLoop
	;move.w		d1,d6
	;move.w		#_reverse_direction_delay_time_18_ms,d7
	;bsr			_trackdiskWaitTimer

	;Block	sector	side	cylinder 
	;--------------------------------
	;0		0		0		0
	;1		1		0		0
	;2		2		0		0
	;10		10		0		0
	;11		0		1		0
	;20		9		1		0
	;21		10		1		0
	;22		0		0		1
	;23		1		0		1
	;24		2		0		1
	;1759	10		1		79
	;120	10		0		5
	;122	1		1		5
	;123 	2		1		5

	; sector=remainder(block/11)	=> d5
	; track=(block/11)				=> d6
	;
	; side=track % 0x0001
	; cylinder=track >> 1

	; side=(block/11)%0x0001		=> d5
	; cylinder=(block/11)>>1		=> d7

	move.l		d0,d5		; d5=sector...
	divu.w		#11,d5
	
	moveq		#0,d6		; d6=track (cylinder/side)...
	move.w		d5,d6		; ...track done
	
	bsr			_trackdiskLoadTrack

	;lsr.w		#1,d7		; ...cylinder done

	;move.w		d6,d5		; d5=side...
	;and.l		#$0001,d5	; ...side done

	clr.w		d5
	swap.w		d5			; ...sector done


	;bsr			_trackdiskSetSide

	addq.l		#1,d0
	dbf			d1,.sectorLoop

	bsr			_stopMotor
	;bsr			_waitDiskReady

	movem.l		(sp)+,d2-d7/a2-a6
	rts

;==============================================================================
;
; Prepares hardware and registers
;
;==============================================================================
_trackdiskPrepareRegisters
	lea			_custom,a5
	lea			_ciaa,a4 ; _ciaa is on an ODD address (e.g. the low byte) -- $bfe001
	lea			_ciab,a6 ; _ciab is on an EVEN address (e.g. the high byte) -- $bfd000
	
	move.w		#_mfm_sync_pattern,dsksync(a5)	
	move.w		#(ADKF_SETCLR|ADKF_MFMPREC|ADKF_WORDSYNC|ADKF_FAST),adkcon(a5)	
	move.w		#(DMAF_SETCLR|DMAF_DISK),dmacon(a5)

	rts

;==============================================================================
;
; Load track
; d6=track=(block/11)
;    side=track % 0x0001
;    cylinder=track >> 1
;
;==============================================================================
_trackdiskLoadTrack
	move.l		d6,d4
	lsr.l		#1,d6
	bsr			_trackdiskSeekCylinder

	move.l		d4,d6
	and.b		#$01,d6
	bsr			_trackdiskSelectSide


.readTrack
	move.w		#_track_settle_delay_time_15_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#INTF_DSKBLK,intreq(a5)
	lea			_TrackdiskMfmBufer,a1
	move.l		a1,dskpt(a5)
	move.w		#(DMAF_SETCLR|DMAF_DISK),dmacon(a5)
	move.w		#_dsklen_dma_off,dsklen(a5)
	move.w		#$8000|6400,dsklen(a5)
	move.w		#$8000|6400,dsklen(a5)			; write to dsklen twice in succession to start
.wait:
	btst.b		#INTB_DSKBLK,intreqr+1(a5)
	beq.s		.wait
	move.w		#_dsklen_dma_off,dsklen(a5)
	move.w		#DMAF_DISK,dmacon(a5)	; OFF!

	;rts

.mfmDecode
	move.l		#_mfm_mask,d5
	moveq.l		#11-1,d4
.decodSector
	lea			_TrackdiskTrackBuffer,a3
.findSectorSync
	cmp.w		#_mfm_sync_pattern,(a1)+		; find start of sector
	bne.s		.findSectorSync
	cmp.w		#_mfm_sync_pattern,(a1)
	beq.s		.findSectorSync
	move.l		(a1)+,d3						; MFM coded sector header to d3...
	move.l		(a1),d2							; ...and d2




	;rts

	bsr.s		.mfmDecodeRegs
	andi.l		#$0000ff00,d2
	add.l		d2,d2
	adda.w		d2,a3
	adda.w		#52,a1
	moveq.l		#128-1,d6
.decodeSectorContent
	move.l		512(a1),d2
	move.l		(a1)+,d3
	bsr.s		.mfmDecodeRegs
	move.l		d2,(a3)+
	dbra		d6,.decodeSectorContent
	adda.w		#516,a1		;skip to next sector header
	dbra		d4,.decodSector
	;adda.w		#5632,a2		;move main pointer past the sector data just decoded (11 sectors * 512 decode bytes each = 5632 bytes)
	;bsr.s		.mfmDecodeRegs
	rts

.mfmDecodeRegs
	and.l	d5,d3
	lsl.l	#1,d3
	and.l	d5,d2
	or.l	d3,d2
	rts

;==============================================================================
;
; Motor control
;
;==============================================================================
_startMotor	
	bset.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: high
	bclr.b		#CIAB_DSKMOTOR,ciaprb(a6)		;dskmotor low
	bclr.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: low

	rts

_stopMotor
	bset.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: high
	bset.b		#CIAB_DSKMOTOR,ciaprb(a6)		;dskmotor high
	bclr.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: low

	rts

;==============================================================================
;
; Disk seek direction
;
;==============================================================================

_trackdiskSetDirectionOutwardNoCheck
	bset.b		#CIAB_DSKDIREC,ciaprb(a6)

	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#1,_TrackdiskCurrentDirection

	rts

_trackdiskSetDirectionOutward
	cmp.w		#1,_TrackdiskCurrentDirection
	beq.s		.alreadyOutward

	bset.b		#CIAB_DSKDIREC,ciaprb(a6)

	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#1,_TrackdiskCurrentDirection
.alreadyOutward
	rts

_trackdiskSetDirectionCenter
	cmp.w		#-1,_TrackdiskCurrentDirection
	beq.w		.alreadyCenter

	bclr.b		#CIAB_DSKDIREC,ciaprb(a6)

	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#-1,_TrackdiskCurrentDirection	
.alreadyCenter
	rts	

_trackdiskSetDirection
	cmp.w		(_TrackdiskCurrentDirection),d5
	beq.w		.alreadyOk

	cmp.b		#-1,d5
	beq.s		.center
.outwards
	bset.b		#CIAB_DSKDIREC,ciaprb(a6)
	bra.s		.wait
.center
	bclr.b		#CIAB_DSKDIREC,ciaprb(a6)
.wait
	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		d5,_TrackdiskCurrentDirection	
.alreadyOk
	rts	

;==============================================================================
;
; Disk ready
;
;==============================================================================

_waitDiskReady
	move.w  	#$0F00,$dff180
	btst.b		#CIAB_DSKRDY,ciapra(a4)	;check for disk ready signal
	bne.s		_waitDiskReady

	rts

;==============================================================================
;
; Head control
;
;==============================================================================

_trackdiskStepHeadAndWait
	bset.b		#CIAB_DSKSTEP,ciaprb(a6)
	bclr.b		#CIAB_DSKSTEP,ciaprb(a6)
	bset.b		#CIAB_DSKSTEP,ciaprb(a6)
	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer
	rts

;_trackdiskSelectLowerHeadAndWait:	
;	bset.b		#CIAB_DSKSIDE,ciaprb(a6)
;	moveq.l		#_select_head_wait_time_0_1_ms,d7
;	bsr			_trackdiskWaitTimer
;	move.b		#0,_TrackdiskCurrentSide
;	rts

;_trackdiskSelectUpperHeadAndWait
;	bclr.b		#CIAB_DSKSIDE,ciaprb(a6)
;	moveq.l		#_select_head_wait_time_0_1_ms,d7
;	bsr			_trackdiskWaitTimer
;	move.b		#1,_TrackdiskCurrentSide
;	rts	

; d6.b=side
_trackdiskSelectSide
	cmp.b		(_TrackdiskCurrentSide),d6
	beq.s		.done
	cmp.b		#1,d6
	beq.s		.upperHead
.lowerHead
	bset.b		#CIAB_DSKSIDE,ciaprb(a6)
	bra.s		.wait
.upperHead
	bclr.b		#CIAB_DSKSIDE,ciaprb(a6)
.wait
	moveq.l		#_select_head_wait_time_0_1_ms,d7
	bsr			_trackdiskWaitTimer
.done
	move.b		d6,_TrackdiskCurrentSide
	rts

; d6.w=cylinder
_trackdiskSeekCylinder
	cmp.w		(_TrackdiskCurrentCylinder),d6
	beq.s		.done
	bgt.s		.seekOutwards
.seekCenter
	moveq		#-1,d5
	bra.s		.doSeek
.seekOutwards
	moveq		#1,d5
.doSeek
	bra			_trackdiskSetDirection
.seekLoop
	bsr			_trackdiskStepHeadAndWait
	add.w		d5,d6
	cmp.w		(_TrackdiskCurrentCylinder),d6
	bne.s		.seekLoop
.done
	move.w		d6,_TrackdiskCurrentCylinder
	rts

;==============================================================================
;
; Wait
; d0=Wait time in ms
;
;==============================================================================	

_trackdiskWaitTimer
    ;move.b  	ciacra(a6),d0
    ;and.b   	#(CIACRBF_ALARM|CIACRBF_IN_TA),d0
    ;or.b    	#CIACRBF_RUNMODE,d0
    ;move.b  	d0,ciacra(a6)

    and.b   	#(CIACRBF_ALARM|CIACRBF_IN_TA),ciacra(a6)
    or.b    	#CIACRBF_RUNMODE,ciacra(a6)


    move.b  	#(CIAICRF_FLG|CIAICRF_SP|CIAICRF_ALRM|CIAICRF_TB|CIAICRF_TA),ciaicr(a6)

    move.b  	d7,ciatalo(a6)
    lsr.w		#8,d7
    move.b  	d7,ciatahi(a6)
.wait
	move.w  	d6,$dff180
    btst.b  	#CIAICRB_TA,ciaicr(a6)
    beq.s   	.wait
	rts	


_TrackdiskCurrentCylinder
	dc.w	-1

_TrackdiskCurrentDirection ; [-1=center, 1=outward]
	dc.w	0

_TrackdiskCurrentSide	; [0=lower head, 1=upper head]
	dc.b	-1

	cnop		0,4

_TrackdiskMfmBufer
	dcb.b		12800,$bb

_TrackdiskTrackBuffer
	dcb.b		512*11,$cc