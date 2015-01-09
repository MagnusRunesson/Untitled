	include		"../src/platform/megadrive/bootup.asm"
	include		"../src/structs.asm"
	include		"../src/macros.asm"
	include		"../src/main.asm"
	include		"../src/core/mem.asm"
	include		"../src/platform/megadrive/inp.asm"
	include		"../src/platform/megadrive/rend.asm"
	include		"../src/platform/megadrive/mem.asm"

	org			$10000

	include		"../src/incbin/data.asm"

	org			$20000
