; * BootBlock
; -------------------------------------------------------------------------------
; offset  size    number  name            meaning
; -------------------------------------------------------------------------------
; 0/0x00  char    4       DiskType        'D''O''S' + flags
;                                         flags = 3 least signifiant bits
;                                                set         clr
;                                           0    FFS         OFS
;                                           1    INTL ONLY   NO_INTL ONLY
;                                           2    DIRC&INTL   NO_DIRC&INTL
; 4/0x04  ulong   1       Chksum          special block checksum
; 8/0x08  ulong   1       Rootblock       Value is 880 for DD and HD 
;                                          (yes, the 880 value is strange for HD)
; 12/0x0c char    *       Bootblock code  (see 5.2 'Bootable disk' for more info)
;                                         The size for a floppy disk is 1012,
;                                         for a harddisk it is
;                                         (DosEnvVec->Bootblocks * BSIZE) - 12
; -------------------------------------------------------------------------------
;
; more information at  http://amigadev.elowar.com/read/ADCD_2.1/Devices_Manual_guide/node015A.html 
;
		
mainbeginstartsector	equ ((mainbegin-bootblockbegin)/TD_SECTOR)
mainnumsectors			equ	((mainend-mainbegin)/TD_SECTOR)
	printv mainnumsectors
		
	dc.b	'DOS',0
	dc.l	0
	dc.l	880

bootblockcodestart	

	; The code is called with an open trackdisk.device I/O request pointer in A1
	move.l	a1,a3

	moveq	#-1,d0
.rainbow
	move.w	d0,d1
	and.w	#$00F0,d1
	move.w	d1,$DFF180
	dbf		d0,.rainbow

	move.w	#$0F0F,$DFF180
	
	; allocate memory
	move.l	#(487*1024),d0	; 487k is max alloc (at least on fs-uae a500)
	moveq	#MEMF_CHIP,d1
	jsr		_LVOAllocMem(a6)
	tst.l	d0
	beq.s 	.outofmemerror
	move.l	d0,d7			; d7=store memory pointer

	; load code
	move.l	a3,a1
	;move.l	#mainnumsectors*TD_SECTOR,IO_LENGTH(a1)
	move.l	#112640,IO_LENGTH(a1)
	
	move.l	d0,IO_DATA(a1)
	move.l	#mainbeginstartsector*TD_SECTOR,IO_OFFSET(a1)
	move.w 	#CMD_READ,IO_COMMAND(a1)
	jsr		_LVODoIO(a6)
	tst.l	d0
	bne.s	.diskreaderror
	
	; goto code
	move.l	d7,a0
	moveq	#0,d0
	rts

.outofmemerror
	moveq	#1,d0
	rts

.diskreaderror
	moveq	#2,d0
	rts

bootblockcodeend

bootblockcodelength equ (bootblockcodeend-bootblockbegin)

	blk.b	(TD_SECTOR*2)-bootblockcodelength,$BB