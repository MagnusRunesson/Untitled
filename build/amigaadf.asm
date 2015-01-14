	org 			$0
	
	include		"hardware/custom.i"
	include		"hardware/cia.i"
	include		"hardware/dmabits.i"
	include		"hardware/intbits.i"
	include		"exec/exec.i"
	include		"devices/trackdisk.i"
	
	include		"exec_lib.i"
	include		"graphics_lib.i"
		
	include		"../src/platform/amiga/const.asm"
	
bootblockbegin
	include		"../src/platform/amiga/bootblock.asm"
bootblockend

mainbegin	
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/platform/amiga/sys.asm"
	;include		"../src/platform/amiga/trackloader.asm"
	;include		"../src/platform/amiga/tl2.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/amiga/inp.asm"
	include		"../src/platform/amiga/rend.asm"
	include		"../src/platform/amiga/mem.asm"
	include		"../src/platform/amiga/file.asm"
	include		"../src/platform/amiga/img.asm"
	
	include		"../src/incbin/files.asm"
	include		"../src/incbin/untitled_splash_image.asm"	
	
	cnop		0,_chunk_size
	
mainend

workmembegin


Bplmem
	; incbin		"../src/incbin/untitled_splash_planar.bin"
	; blk.b		64*64*8*8*4/8,$01
; mainend
	
workmemend

databegin	
; plbeg
	;cnop		0,(512*11)
	;blk.b		(512*11),0
	;blk.b		(512*11),0
	;blk.b		(512*11),0
	; dc.b		"DATABEGIN"

	incbin		"../src/incbin/untitled_splash_planar.bin"
plend
	include		"../src/incbin/data.asm"
dataend
