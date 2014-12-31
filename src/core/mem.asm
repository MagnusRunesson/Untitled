
;==================================================================================================
;
; Get the address of different memory spaces
;
;==================================================================================================
memGetUserBaseAddress:
	jsr				memGetPlatformBase
	add.l			#usermem_base,a0
	rts

memGetGameObjectManagerBaseAddress:
	jsr				memGetPlatformBase
	add.l			#gommem_base,a0
	rts
