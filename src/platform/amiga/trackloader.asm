
;==============================================================================
;
; Constants
;
;==============================================================================

_mfm_sync_pattern						equ	($4489)
_mfm_mask								equ	($55555555)
_dsklen_dma_off							equ ($4000) ; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0192.html

_step_wait_time_3_ms					equ	(2128)	; (3 * 1000) / 1.4096836810788
_select_head_wait_time_0_1_ms			equ	(71)	; (0.1 * 1000) / 1.4096836810788
_reverse_direction_delay_time_18_ms		equ (12769)	; (18 * 1000) / 1.4096836810788
_track_settle_delay_time_15_ms			equ (10641)	; (15 * 1000) / 1.4096836810788

_trackdisk_direction_outward	equ		(-1)
_trackdisk_direction_center		equ		(1)

;==============================================================================
;
; Structures
;
;==============================================================================

							rsreset
__TrackdiskCurrentCylinder	rs.w	1
__TrackdiskCurrentDirection	rs.w	1	; [1=center, -1=outward]
__TrackdiskCurrentSide		rs.b	1	; [0=lower head, 1=upper head]
							rs.b	1	; pad
_TrackdiskVarsSizeof		rs.b	0

_TrackdiskVars
	dc.w	-1	; __TrackdiskCurrentCylinder
	dc.w	0	; __TrackdiskCurrentDirection
	dc.b	-1	; __TrackdiskCurrentSide
	cnop	0,2

;==============================================================================
;
; Macros
;
;==============================================================================

_wait_disk_ready	MACRO
	
.loop
	btst.b		#CIAB_DSKRDY,ciapra(a4)	;check for disk ready signal
	bne.s		.loop

	ENDM

_start_motor		MACRO

	bset.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: high
	bclr.b		#CIAB_DSKMOTOR,ciaprb(a6)		;dskmotor low
	bclr.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: low

	ENDM

_stop_motor			MACRO

	bset.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: high
	bset.b		#CIAB_DSKMOTOR,ciaprb(a6)		;dskmotor high
	bclr.b		#CIAB_DSKSEL0,ciaprb(a6)		;select df0: low

	ENDM

;==============================================================================
;
; Initialize trackdisk system
;
;==============================================================================

trackdiskInit
	pushm		d2-d7/a2-a6

	;clr.w		$100
	
	bsr			_trackdiskPrepareRegisters

	move.w		#-1,__TrackdiskCurrentCylinder(a2)
	move.w		#0,__TrackdiskCurrentDirection(a2)
	move.b		#-1,__TrackdiskCurrentSide(a2)

	_start_motor
	_wait_disk_ready

	bsr			_trackdiskSetDirectionOutwardNoCheck

.checkAndStepToTrackZero
	btst.b		#CIAB_DSKTRACK0,ciapra(a4)
	beq.s		.atTrackZero
	bsr			_trackdiskStepHeadAndWait
	bra.s		.checkAndStepToTrackZero

.atTrackZero:	
	bsr			_trackdiskSetDirectionCenter

	move.w		#0,__TrackdiskCurrentCylinder(a2)

	_stop_motor

	move.b		#0,d6
	bsr			_trackdiskSelectSide

	popm		d2-d7/a2-a6	
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
	pushm		d2-d7/a2-a6

	bsr			_trackdiskPrepareRegisters
	_start_motor
	_wait_disk_ready

	subq.l		#1,d1		; -1 for dbf
.sectorLoop
	move.l		d0,d5		; d5=sector...
	divu.w		#11,d5
	
	moveq		#0,d6		; d6=track (cylinder/side)...
	move.w		d5,d6		; ...track done
	
	bsr			_trackdiskLoadTrack

	clr.w		d5
	swap.w		d5			; ...sector done
.copyData
	lsl.l		#7,d5
	lsl.l		#2,d5
	_get_workmem_ptr TrackdiskTrackBuffer,a3
	add.l		d5,a3
	moveq		#(512/4)-1,d4
.copyLoop
	move.l		(a3)+,(a0)+
	dbf			d4,.copyLoop

	addq.l		#1,d0
	dbf			d1,.sectorLoop

	_stop_motor

	popm		d2-d7/a2-a6
	rts

;==============================================================================
;
; Prepares hardware and registers
;
;==============================================================================
_trackdiskPrepareRegisters
	lea			_TrackdiskVars(pc),a2
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
	push		d5

	move.w		__TrackdiskCurrentCylinder(a2),d5
	lsl.l		#1,d5
	or.b		__TrackdiskCurrentSide(a2),d5
	cmp.w		d6,d5
	beq.w		.done

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
	_get_workmem_ptr TrackdiskMfmBuffer,a1
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

.mfmDecode
	move.l		#_mfm_mask,d5
	moveq.l		#11-1,d4
.decodeSector
	_get_workmem_ptr TrackdiskTrackBuffer,a3
.findSectorSync
	cmp.w		#_mfm_sync_pattern,(a1)+		; find start of sector
	bne.s		.findSectorSync
	cmp.w		#_mfm_sync_pattern,(a1)
	beq.s		.findSectorSync
	move.l		(a1)+,d3						; MFM coded sector header to d3...
	move.l		(a1),d2							; ...and d2

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
	adda.w		#516,a1
	dbra		d4,.decodeSector
.done
	pop			d5
	rts

.mfmDecodeRegs
	and.l	d5,d3
	lsl.l	#1,d3
	and.l	d5,d2
	or.l	d3,d2
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

	move.w		#_trackdisk_direction_outward,__TrackdiskCurrentDirection(a2)

	rts

_trackdiskSetDirectionOutward
	cmp.w		#_trackdisk_direction_outward,__TrackdiskCurrentDirection(a2)
	beq.s		.alreadyOutward

	bset.b		#CIAB_DSKDIREC,ciaprb(a6)

	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#_trackdisk_direction_outward,__TrackdiskCurrentDirection(a2)
.alreadyOutward
	rts

_trackdiskSetDirectionCenter
	cmp.w		#_trackdisk_direction_center,__TrackdiskCurrentDirection(a2)
	beq.w		.alreadyCenter

	bclr.b		#CIAB_DSKDIREC,ciaprb(a6)

	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		#_trackdisk_direction_center,__TrackdiskCurrentDirection(a2)	
.alreadyCenter
	rts	

_trackdiskSetDirection
	cmp.w		__TrackdiskCurrentDirection(a2),d5
	beq.w		.alreadyOk

	cmp.b		#_trackdisk_direction_center,d5
	beq.s		.center
.outwards
	bset.b		#CIAB_DSKDIREC,ciaprb(a6)
	bra.s		.wait
.center
	bclr.b		#CIAB_DSKDIREC,ciaprb(a6)
.wait
	move.w		#_step_wait_time_3_ms,d7
	bsr			_trackdiskWaitTimer

	move.w		d5,__TrackdiskCurrentDirection(a2)	
.alreadyOk
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

; d6.b=side
_trackdiskSelectSide
	cmp.b		__TrackdiskCurrentSide(a2),d6
	beq.s		.done
	cmp.b		#1,d6
	beq.s		.upperHead
.lowerHead
	bset.b		#CIAB_DSKSIDE,ciaprb(a6)
	bra.s		.wait
.upperHead
	bclr.b		#CIAB_DSKSIDE,ciaprb(a6)
.wait
	move.w		#_select_head_wait_time_0_1_ms,d7
	bsr			_trackdiskWaitTimer
.done
	move.b		d6,__TrackdiskCurrentSide(a2)
	rts

; d6.w=cylinder
_trackdiskSeekCylinder
	pushm		d4-d5
	move.w		__TrackdiskCurrentCylinder(a2),d4
	cmp.w		d6,d4
	beq.s		.done
	cmp.w		d6,d4
	bgt.s		.seekOutwards
.seekCenter
	moveq		#_trackdisk_direction_center,d5
	bra.s		.doSeek
.seekOutwards
	moveq		#_trackdisk_direction_outward,d5
.doSeek
	bsr			_trackdiskSetDirection
	
.seekLoop
	bsr			_trackdiskStepHeadAndWait
	add.w		d5,d4
	cmp.w		d4,d6
	bne.s		.seekLoop

	move.w		d6,__TrackdiskCurrentCylinder(a2)
.done
	popm		d4-d5
	rts

;==============================================================================
;
; Wait
; d7.w=Wait time in ms
;
;==============================================================================	

_trackdiskWaitTimer
	push		d0

    move.b  	ciacra(a6),d0
    and.b   	#(CIACRBF_ALARM|CIACRBF_IN_TA),d0
    or.b    	#CIACRBF_RUNMODE,d0
    move.b  	d0,ciacra(a6)

    move.b  	#(CIAICRF_FLG|CIAICRF_SP|CIAICRF_ALRM|CIAICRF_TB|CIAICRF_TA),ciaicr(a6)

    move.b  	d7,ciatalo(a6)
    lsr.w		#8,d7
    move.b  	d7,ciatahi(a6)
.wait
    btst.b  	#CIAICRB_TA,ciaicr(a6)
    beq.s   	.wait

    pop			d0
	rts	


