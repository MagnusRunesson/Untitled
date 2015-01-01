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
	include "exec/exec.i"
	
bootblockbegin
		dc.b	'DOS',0
		dc.l	0
		dc.l	880

bootblockcodestart	

	; allocate memory
	move.l	#(489*1024),d0 ; 489k is max alloc (at least on fs-uae a500)
	moveq	#MEMF_CHIP,d1
	; jsr		AllocMem(a6)
	; JMPLIB AllocMem
	; jsr	_LOVAllocMem(a6)
	jsr		-$c6(a6) ;AllocMem
	cmp.l	#0,d0
	beq.s 	booterror
		
	; load code
	;----
	
	; store data pointer for use by real code
	;  (probably useless, better to use Dx to pass it on)
	move.l	d0,a0
	move.l	d0,(data-flimmer)(a0)
	
	; debug code to show OK for now
	;  (remove when done)
ok
	moveq	#-1,d0
.loop
	move.w	d0,$dff180
	dbra	d0,.loop
	
	bra.s 	ok


booterror
	moveq	#1,d0
	rts

bootblockcodeend

bootblocklength = (bootblockcodeend-bootblockbegin)
	blk.b	1024-bootblocklength,$BB

bootblockend