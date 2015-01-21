_chunk_size		equ		128			; same as TD_SECTOR (size of sector on floppy)

	include		"../src/platform/megadrive/bootup.asm"
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/megadrive/mem.asm"
	include		"../src/platform/megadrive/inp.asm"
	include		"../src/platform/megadrive/rend.asm"
	include		"../src/platform/megadrive/file.asm"
	include		"../src/platform/megadrive/img.asm"

	include		"../src/incbin/untitled_splash_image.asm"
	include		"../src/incbin/testtiles_image.asm"

	org			$10000

	include		"../src/incbin/data.asm"
	include		"../src/incbin/files.asm"

	org			$20000
