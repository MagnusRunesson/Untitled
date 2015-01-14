	; include	"hardware/custom.i"

		
;==============================================================================
;
; It is quite likely that the bit positions for the different buttons will be
; different on the different platforms so the macros for them should be in the
; platform specific source file.
;
;==============================================================================
INPUT_UP			equ		10
INPUT_DOWN			equ		2
INPUT_LEFT			equ		9
INPUT_RIGHT			equ		1
INPUT_ACTION		equ		0;error
INPUT_PAUSE			equ		0;error
INPUT_ACTION2		equ		0;error
INPUT_ACTION3		equ		0;error


;==============================================================================
; Read joypad 1
;
; Returns the joypad values in the last byte of D7 with the following layout:
; SACBRLDU (Start A C B Right Left Down Up)
;==============================================================================
inpUpdate:
	
	; More information: http://eab.abime.net/showthread.php?t=75779
		
	; this: http://eab.abime.net/showpost.php?p=987590&postcount=48 ===>
	move.l  joy0dat+_custom,d0
    and.l   #$03030303,d0
    move.l  d0,d1
    add.l   d1,d1
    add.l   #$01010101,d0
    add.l   d1,d0
	not.l	d0
	
	; 	btst	#CIAB_GAMEPORT1,_ciaa+ciapra
	;	bne.s	.diskReady	
	rts

