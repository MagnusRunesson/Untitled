	org 			$0
	

	include		"hardware/adkbits.i"
	include		"hardware/blit.i"
	include		"hardware/cia.i"
	include		"hardware/custom.i"
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
	include		"../src/platform/amiga/trackloader.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/amiga/inp.asm"
	include		"../src/platform/amiga/rend.asm"
	include		"../src/platform/amiga/mem.asm"
	include		"../src/platform/amiga/file.asm"
	include		"../src/platform/amiga/img.asm"
	
	include		"../src/incbin/files.asm"
	;include		"../src/incbin/untitled_splash_image.asm"	
	
	cnop		0,_chunk_size
	
mainend

workmembegin


Bplmem
	; incbin		"../src/incbin/untitled_splash_planar.bin"
	; blk.b		64*64*8*8*4/8,$01
; mainend
	
workmemend

databegin	

	cnop		0,(512*11) 		; end of track 0
	blk.b		(512*11),0 		; this is track 1
	blk.b		(512*11)*140,0 		; this is track 2
	blk.b		(512*11)-8,0	; this is track 3
	dc.b		"DATABEGN"		; final marker on track 3
	cnop		0,(512)
	printt "untitled_splash_planar.bin is located here:"
	printv *
	printv */512
	incbin		"../src/incbin/untitled_splash_planar.bin"

	include		"../src/incbin/data.asm"
	;include		"../src/incbin/files.asm"
	include		"../src/incbin/untitled_splash_image.asm"
	include		"../src/incbin/testtiles_image.asm"
dataend
