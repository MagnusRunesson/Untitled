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


;==================================================================================================
;
; Macros to push and pop to the stack
;
;==================================================================================================
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


;==================================================================================================
;
; Stack macros that treat the stack like a small piece of memory that
; you can freely write to and read from in any order you'd like.
;
;==================================================================================================
;
;
; Allocates X bytes on the stack.
;
; Usage:
; stack_alloc	8		; Will allocate 8 bytes on the stack
; stack_alloc	$20		; Will allocate 32 bytes on the stack
;
stack_alloc		MACRO
	sub.l		#\1,sp
	endm

;
; Free X bytes on the stack.
;
; Usage:
; stack_free	8		; Will free 8 bytes from the stack
; stack_free	$20		; Will free 32 bytes from the stack
;
stack_free		MACRO
	add.l		#\1,sp
	endm

;
; Write a register to an address with a specified offset relative to the stack. This is
; to get around the specific order of pushing and popping that is otherwise needed.
;
; Can only be used after a stack_alloc and isn't allowed
; to write to more bytes than what was allocated
;
; mnemonic extension is supported.
;
; Usage:
; stack_write	d0,0		; Will write d0 to sp+0
; stack_write	d0,4		; Will write d0 to sp+4
; stack_write.b	d0,0		; Will write the lowest byte of d0 into sp+0
;
;
stack_write		MACRO
	move.\0		\1,\2(sp)
	ENDM

;
; Read from the stack with an offset into the specified register. This is to get
; around the specific order of pushing and popping that is otherwise needed.
;
; Can only be used after a stack_alloc and isn't allowed
; to write to more bytes than what was allocated
;
; mnemonic extension is supported.
;
; Usage:
; stack_read	d0,0		; Will read from sp+0 and write into d0
; stack_read	d0,4		; Will read from sp+04 and write into d0
; stack_read.b	d0,0		; Will read lowest byte from sp+0 and write into lowest byte of d0
;
stack_read		MACRO
	move.\0		\2(sp),\1
	ENDM
