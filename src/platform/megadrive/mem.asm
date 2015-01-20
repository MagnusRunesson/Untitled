platform_mem_size				= $2000
platform_mem_start				= $00ff0000+totalmem_size

platform_renderer_start			= platform_mem_start
platform_renderer_size			= $500

VRAM_MapTiles_Start				= $0000
VRAM_SpriteTiles_Start			= $bd80		; This one goes down when allocated, so it should be the same as another VRAM tag
VRAM_SpriteAttributes_Start		= $bd80
VRAM_TileMap0_Start				= $c000
VRAM_TileMap1_Start				= $e000


;==================================================================================================
;
; Get the base address for this platform
;
;==================================================================================================
memGetPlatformBase:
	move.l			#$00ff0000,a0
	rts
