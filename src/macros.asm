;==================================================================================================
;
; RAM Memory map for shared code. Platform specific code is not included in this
;
;==================================================================================================
totalmem_size		=	$e000			; This is the total amount of RAM allocated for the shared
										; code. The total size of all other areas must not be
										; greater than this size. Also, the Mega Drive only have
										; 64KB RAM so the totalmem_size and all platform specific
										; memory most not be greater than $ffff

; Game logic etc..
usermem_base		=	$0000
usermem_size		=	$0100
usermem_end			=	usermem_size

; Game Object Manager
gommem_base			= 	usermem_size
gommem_size			=	$0100
gommem_end			=	gommem_base+gommem_size

;
; Will decrement the stack pointer and write a register to the new address
;
; Usage:
; push		d0
;
push			MACRO
	move.l		\1,-(sp)
	ENDM

;
; Will write a value from the current stack address into a register, and then increment the stack pointer
;
; Usage:
; pop		d0
;
pop				MACRO
	move.l		(sp)+,\1
	ENDM

