_chunk_size		equ		128			; same as TD_SECTOR (size of sector on floppy)

	include		"../src/platform/megadrive/macros.asm"

	include		"../src/platform/megadrive/bootup.asm"
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/core/gameobjectmanager.asm"
	include		"../src/core/resource.asm"
	include		"../src/platform/megadrive/mem.asm"
	include		"../src/platform/megadrive/inp.asm"
	include		"../src/platform/megadrive/rend.asm"
	include		"../src/platform/megadrive/file.asm"
	include		"../src/platform/megadrive/img.asm"
	include		"../src/platform/megadrive/resource.asm"
	include		"../src/platform/megadrive/error.asm"
	include		"../src/incasm/data.asm"
	include		"../src/incbin/datasta_md.asm"
	include		"../src/incbin/fileidmap_md.asm"

	org			$10000

	include		"../src/incbin/datadyn_md.asm"
	include		"../src/incbin/files.asm"
	include		"../src/incbin/overworld_goc_identifiers.asm"	; This should really be included by something else. Preferrably by data.asm
