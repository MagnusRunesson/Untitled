diskstart
contentbegin

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
	dc.b	'DOS',0

; 4/0x04  ulong   1       Chksum          special block checksum
	dc.l	0

; 8/0x08  ulong   1       Rootblock       Value is 880 for DD and HD 
;                                          (yes, the 880 value is strange for HD)
	dc.l	880

; 12/0x0c char    *       Bootblock code  (see 5.2 'Bootable disk' for more info)
;                                         The size for a floppy disk is 1012,
;                                         for a harddisk it is
;                                         (DosEnvVec->Bootblocks * BSIZE) - 12
; -------------------------------------------------------------------------------
	;section code_c,code,chip
	
bootblockcode	
	moveq	#10,d1
.loop2
	moveq	#-1,d0
.loop
	move.w	d0,$dff180
	dbra	d0,.loop
	dbra	d1,.loop2
	
	moveq	#-1,d0
	rts
