platform_mem_size				= $2000
platform_mem_start				= $00ff0000+totalmem_size

platform_renderer_start			= platform_mem_start
platform_renderer_size			= $500


;==================================================================================================
;
; Get the base address for this platform
;
;==================================================================================================
memGetPlatformBase:
	move.l			#$00ff0000,a0
	rts
