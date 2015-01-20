	
; plbeginstartsector		equ ((databegin-bootblockbegin)/TD_SECTOR)
; plnumsectors			equ	((plend-databegin)/TD_SECTOR)
	
; TODO: VBR for interrups

entryPoint:

	; ExecBase
	; move.l		4.w,a6
	; move.l		a6,_ExecBase

	; MsgPort
	; jsr			_LVOCreateMsgPort(a6)
	; move.l		d0,a5
	; Uhmm, maybe not!
	
	; ; The code is called with an open trackdisk.device I/O request pointer in A1
	; move.l		a1,a3
	; lea			Bplmem(pc),a1
	; move.l		a1,d0
	; move.l		a3,a1
	; move.l		#plnumsectors*TD_SECTOR,IO_LENGTH(a1)
	; move.l		d0,IO_DATA(a1)
	; move.l		#plbeginstartsector*TD_SECTOR,IO_OFFSET(a1)
	; move.w 		#CMD_READ,IO_COMMAND(a1)
	; jsr			_LVODoIO(a6)
	; tst.l		d0
	; ; bne.s		.diskReadError
	
	
	
	
	; rainbow
;	moveq		#4,d0
;.two
;	moveq		#-1,d1
;.rainbows
;	move.w		d1,d2
;	and.w		#$0F00,d2
;	move.w		d2,$dff180
;	;move.w		#$0FFF,$dff180
;	dbf			d1,.rainbows
;	dbf			d0,.two
;
;firstAbove
	
	lea			_custom,a2
	; move.w		#DMAF_ALL,dmacon(a2)
	move.w		#DMAF_ALL|DMAF_MASTER,dmacon(a2)
	
	lea			Copper_bplpt(pc),a0
	; lea			_data_untitled_splash_planar(pc),a1
	lea			Bplmem(pc),a1
	move.l		a1,d0
	moveq		#4-1,d1
.bplconLoop
	swap.w		d0
	move.w		d0,2(a0)
	swap.w		d0
	move.w		d0,6(a0)
	add.l		#320/8,d0
	add.l		#8,a0	
	dbra		d1,.bplconLoop
	
	; move.w		#$2c81,diwstrt(a2)
	; move.w		#$0cc1,diwstop(a2)
	; move.w		#$0038,ddfstrt(a2)
	; move.w		#$00d0,ddfstop(a2)
	; move.w		#$0000,bpl1mod(a2)
	; move.w		#$0000,bpl2mod(a2)
	
	lea			Copper(pc),a0
	move.l		a0,cop1lc(a2)
	move.w		d0,copjmp1(a2)
	
	; lea			copperInterrupt(pc),a0
	; move.l		a0,_interrupt_vec_copper
	
	move.w		#(DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_BLITTER|DMAF_MASTER),dmacon(a2)
	; MOVE.w		#$83A0,DMACON(a5)	; Enable DMA
	
	

	; rainbow
	moveq		#4,d0
.two
	moveq		#-1,d1
.rainbows
	move.w		d1,d2
	and.w		#$0F0F,d2
	move.w		d2,$dff180
	;move.w		#$0FFF,$dff180
	dbf			d1,.rainbows
	dbf			d0,.two
	
	
	; MOVE.w	#$83A0,DMACON(a5)	; Enable DMA		
	; bsr.w	trackloadMotorOn
	; bsr.w	trackloadMoveToCylinder0
	; bsr.w	trackloadMotorOff
	;bsr.w	TLInit
	
	
	; load file FILEID_UNTITLED_SPLASH_PLANAR to bplmem

	bsr			trackdiskInit

	move.l		#1606,d0				; 
	moveq		#(35840/512),d1		; 70
	lea			Bplmem(pc),a0

	bsr			trackdiskLoadBlock
	;bsr.w		TLLoad
	; bsr.w		hardtl
	
	; rainbow
again
	moveq		#6,d0
.two
	moveq		#-1,d1
.rainbows
	move.w		d1,d2
	and.w		#$00FF,d2
	move.w		d2,$dff180
	;move.w		#$0FFF,$dff180	
	dbf			d1,.rainbows
	dbf			d0,.two
	
	
		; d0 = start track (0 - 159) (no check for illegal tracks)
	; d1 = number of tracks to read (no check for illegal count,
	;      d1 = 0 moves head to right track).
	; a0 = data buffer, must be at least 11 * 512 * d1 bytes large
	
	jsr			main(pc)
	
	; teardown
	
	rts

;==============================================================================
;
; Interrupts
;
;==============================================================================
; copperInterrupt:
	; movem.l		d0-a6,-(sp)

	; ; is it a copper interrupt?
	; ; lea			_custom,a5
	; ; move.w		intreqr(a5),d0
	; ; and.w		#$0010,d0		
	; ; beq.s		.endCopperInterrupt

	; ; ; yes it is 
	; ; nop

; .endCopperInterrupt:
	; ; move.w		#$0010,intreq(a5)	; clear copper interrupt bit	
	; movem.l		(sp)+,d0-a6
	; rte


;==============================================================================
;
; Variables
;
;==============================================================================
	cnop	0,4
	
_ExecBase
	dc.l	0

;==============================================================================
;
; Copper
;
;==============================================================================
Copper
	dc.w	bplcon0,$4200
	dc.w	bplcon1,$0000
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$0cc1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,$0078
	dc.w	bpl2mod,$0078
Copper_bplpt
	dc.w	bplpt+0,$0000
	dc.w	bplpt+2,$0000
	dc.w	bplpt+4,$0000
	dc.w	bplpt+6,$0000
	dc.w	bplpt+8,$0000
	dc.w	bplpt+10,$0000
	dc.w	bplpt+12,$0000
	dc.w	bplpt+14,$0000
Copper_color
	dc.w	color+0,$0000	
	dc.w	color+2,$0EEE
	dc.w	color+4,$0CCC
	dc.w	color+6,$0888
	dc.w	color+8,$0666	
	dc.w	color+10,$0444
	dc.w	color+12,$0222
	dc.w	color+14,$0000
	dc.w	color+16,$00F0
	dc.w	color+18,$000F
	dc.w	color+20,$0FF0
	dc.w	color+22,$00FF
	dc.w	color+24,$0F0F
	dc.w	color+26,$0F80
	dc.w	color+28,$008F
	dc.w	color+30,$0F00
	
	dc.w	$FFFF,$FFFE



