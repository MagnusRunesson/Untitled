	org 			$0
	
	; commodore includes
	include		"hardware/adkbits.i"
	include		"hardware/blit.i"
	include		"hardware/cia.i"
	include		"hardware/custom.i"
	include		"hardware/dmabits.i"
	include		"hardware/intbits.i"
	include		"exec/exec.i"
	include		"devices/trackdisk.i"
	; ..and my includes created from commodores C-header files
	include		"exec_lib.i"
	include		"graphics_lib.i"
	
	include		"../src/platform/amiga/const.asm"
	include		"../src/platform/amiga/macros.asm"

	
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
	include		"../src/core/gameobjectmanager.asm"
	include		"../src/platform/amiga/inp.asm"
	include		"../src/platform/amiga/rend.asm"
	include		"../src/platform/amiga/mem.asm"
	include		"../src/platform/amiga/file.asm"
	include		"../src/platform/amiga/img.asm"
	
	include		"../src/incbin/files.asm"

	include		"../src/incasm/data.asm"
	
	cnop		0,_chunk_size
	
mainend

workmembegin

TrackdiskMfmBuffer
	dcb.w		12800/2,$FBFF	; mFmBuFFer
	;dcb.b		6800,$bf ; some more

TrackdiskTrackBuffer
	dcb.w		512*11/2,$ACBF	; trACkBuFfer
	;dcb.b		512*5,$cb ; som emore

BitplaneMem
	;incbin		"../src/incbin/untitled_splash_planar.bin"
	;blk.b		(64*64*8*8*4/8)-(*-Bplmem),$01
	dcb.w		64*64*8*8*4/8/2,$BAEE	; BitplAnEmEm
	cnop		0,_chunk_size,1

TilebankMem
	dcb.w		100/2,$EBAE		; tilEBAnkmEm
	cnop		0,_chunk_size

TilemapMem
	dcb.w		2+(64*64),$0EAE		; tilEmApmEm
	cnop		0,_chunk_size

;MapMem
;	dcb.w		64*64*2/2,$AEAE		; mApmEm
;	cnop		0,_chunk_size

PaletteMem
	dcb.w		512/2,$AEEE		; pAlEttEmEm
	cnop		0,_chunk_size

SharedWorkMem
	dcb.w		totalmem_size/2,$AEDE	;shArEDworkmEm

workmemend

databegin		
	include		"../src/incbin/data.asm"
dataend
