_chunk_size		equ		512			; same as TD_SECTOR (size of sector on floppy)
_custom			equ 	$dff000

	org 		$0
	
bootblockbegin
	include		"../src/platform/amiga/bootblock.asm"
bootblockend

mainbegin	
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/platform/amiga/sys.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/amiga/inp.asm"
	include		"../src/platform/amiga/rend.asm"
	include		"../src/platform/amiga/mem.asm"
	include		"../src/platform/amiga/file.asm"
	include		"../src/platform/amiga/img.asm"
	
	include		"../src/incbin/files.asm"
	include		"../src/incbin/untitled_splash_image.asm"	
	include		"../src/incbin/testtiles_image.asm"

	include		"../src/incbin/data.asm" ; not really!
mainend

workmembegin

workmemend

databegin
	; include		"../src/incbin/data.asm"
dataend
