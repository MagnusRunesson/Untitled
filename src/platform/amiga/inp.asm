		
;==============================================================================
;
; It is quite likely that the bit positions for the different buttons will be
; different on the different platforms so the macros for them should be in the
; platform specific source file.
;
;==============================================================================

INPUT_1_UP			equ		26
INPUT_1_DOWN		equ		18
INPUT_1_LEFT		equ		25
INPUT_1_RIGHT		equ		17

INPUT_2_UP			equ		10
INPUT_2_DOWN		equ		2
INPUT_2_LEFT		equ		9
INPUT_2_RIGHT		equ		1

INPUT_UP			equ		(INPUT_1_UP)
INPUT_DOWN			equ		(INPUT_1_DOWN)
INPUT_LEFT			equ		(INPUT_1_LEFT)
INPUT_RIGHT			equ		(INPUT_1_RIGHT)

INPUT_ACTION		equ		3
INPUT_PAUSE			equ		4
INPUT_ACTION2		equ		5
INPUT_ACTION3		equ		6


;==============================================================================
;
; Read joystick information
;
; Returns the joypad values into register d0
;
;==============================================================================

inpUpdate:
	movem.l		d2/a5,-(sp)

	moveq		#0,d0

	lea			_custom,a5
	move.w		joy0dat(a5),d1
    
    move.w		d1,d2
    lsr.w		#1,d2
    eor.w 		d1,d2

    btst 		#1,d1
    bne.s 		.right

    btst.l 		#9,d1
    bne.s 		.left

    btst		#0,d2
    bne.s 		.down

    btst 		#8,d2
    bne.s 		.up

    bra.s 		.testAction

.right:
	bset.l		#INPUT_RIGHT,d0

    btst 		#0,d2
    bne.s 		.down

    btst		#8,d2
    bne.s 		.up

    bra.s		.testAction

.left:
	bset.l		#INPUT_LEFT,d0

    btst.l		#0,d2
    bne.s		.down

    btst		#8,d2
    bne.s		.up

    bra.s		.testAction

.down
	bset.l		#INPUT_DOWN,d0
    bra.s 		.testAction

.up
	bset.l		#INPUT_UP,d0

.testAction
	lea			_ciaa,a5
	move.b		ciapra(a5),d1
	btst.l		#6,d1
	bne.s		.testAction2
	bset.l		#INPUT_ACTION,d0

.testAction2
	;not implemented yet

.done
	not.l		d0

	movem.l		(sp)+,d2/a5
	rts

