;==============================================================================
;
; It is quite likely that the bit positions for the different buttons will be
; different on the different platforms so the macros for them should be in the
; platform specific source file.
;
;==============================================================================
INPUT_UP			equ		0
INPUT_DOWN			equ		1
INPUT_LEFT			equ		2
INPUT_RIGHT			equ		3
INPUT_ACTION		equ		6
INPUT_PAUSE			equ		7
INPUT_ACTION2		equ		4
INPUT_ACTION3		equ		5


;==============================================================================
; Read joypad 1
;
; Returns the joypad values in the last byte of D7 with the following layout:
; SACBRLDU (Start A C B Right Left Down Up)
;==============================================================================
inpUpdate:
	; Push
	move.l		a0,-(sp)
	move.l		d0,-(sp)

	;
	move.l		#$00A10003,a0				; Joypad 1 is at 0x00A10003

	;
	move.b		#$40,(a0)					; Set TH to high
	nop										; Wait for the bus to synchronize
	move.b		(a0),d7						; Read status into D7

	andi.b		#$3F,d7						; D7.b = 00CBRLDU

	move.b		#$00,(a0)					; Set TH to low
	nop										; Wait for the bus to synchronize
	move.b		(a0),d0						; Read status into D0
											; D0.b = ?0SA00DU

	rol			#2,d0						; D0.b = SA00DU??
	andi.b		#$C0,d0						; D0.b = SA000000
	or.b 		d0,d7						; D7.b = SACBRLDU

	move.l		(sp)+,d0
	move.l		(sp)+,a0

	rts										; Return to caller
