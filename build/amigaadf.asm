
_custom			equ 	$dff000

_chunk_size		equ		512			; same as TD_SECTOR (size of sector on floppy)

_align_on_chunk	MACRO
\@
.offset			equ		(\@-bootblockbegin)
.mod			equ		(.offset//_chunk_size)
				if .mod<>0
.padsize			equ		(_chunk_size-.mod)			
					blk.b	.padsize,$AC
				endif							
				ENDM

bootblockbegin
	include		"../src/platform/amiga/bootblock.asm"
bootblockend

mainbegin	
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/amiga/inp.asm"
	include		"../src/platform/amiga/rend.asm"
	include		"../src/platform/amiga/mem.asm"

	; test planar, remove!
	cnop	0,4
splashplanar:
	incbin		"../src/incbin/Untitled splash2.bin.planar"
splashpalette:
	incbin		"../src/incbin/Untitled splash2.bin.palette"

	_align_on_chunk	
mainend

mainbeginstartsector	equ ((mainbegin-bootblockbegin)/TD_SECTOR)
mainnumsectors			equ	((mainend-mainbegin)/TD_SECTOR)

workmembegin

workmemend

databegin
	blk.b		300*1024,$DD
	_align_on_chunk	
dataend