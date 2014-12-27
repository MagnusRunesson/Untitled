	; Sega Genesis ROM header
	dc.l	$00FFE000	; Initial stack pointer value
	dc.l	$00000200	; Start of our program in ROM
	dc.l	Interrupt	; Bus error
	dc.l	Interrupt	; Address error
	dc.l	Interrupt	; Illegal instruction
	dc.l	Interrupt	; Division by zero
	dc.l	Interrupt	; CHK exception
	dc.l	Interrupt	; TRAPV exception
	dc.l	Interrupt	; Privilege violation
	dc.l	Interrupt	; TRACE exception
	dc.l	Interrupt	; Line-A emulator
	dc.l	Interrupt	; Line-F emulator
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Spurious exception
	dc.l	Interrupt	; IRQ level 1
	dc.l	Interrupt	; IRQ level 2
	dc.l	Interrupt	; IRQ level 3
	dc.l	HBlankInterrupt	; IRQ level 4 (horizontal retrace interrupt)
	dc.l	Interrupt	; IRQ level 5
	dc.l	VBlankInterrupt	; IRQ level 6 (vertical retrace interrupt)
	dc.l	Interrupt	; IRQ level 7
	dc.l	Interrupt	; TRAP #00 exception
	dc.l	Interrupt	; TRAP #01 exception
	dc.l	Interrupt	; TRAP #02 exception
	dc.l	Interrupt	; TRAP #03 exception
	dc.l	Interrupt	; TRAP #04 exception
	dc.l	Interrupt	; TRAP #05 exception
	dc.l	Interrupt	; TRAP #06 exception
	dc.l	Interrupt	; TRAP #07 exception
	dc.l	Interrupt	; TRAP #08 exception
	dc.l	Interrupt	; TRAP #09 exception
	dc.l	Interrupt	; TRAP #10 exception
	dc.l	Interrupt	; TRAP #11 exception
	dc.l	Interrupt	; TRAP #12 exception
	dc.l	Interrupt	; TRAP #13 exception
	dc.l	Interrupt	; TRAP #14 exception
	dc.l	Interrupt	; TRAP #15 exception
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	dc.l	Interrupt	; Unused (reserved)
	
	; Sega string and copyright
	dc.b "SEGA MEGA DRIVE (C)MARC 2004.SEP"

	; Domestic name
	;dc.b "MARCS TEST CODE                                 "
	dc.b "Magnus awesome game                             "

	; Overseas name
	;dc.b "MARCS TEST CODE                                 "
	dc.b "Magnus awesome game                             "

	; GM (game), product code and serial
	dc.b "GM 12345678-01"

	; Checksum will be here
	dc.b $81, $B4

	; Which devices are supported ?
	dc.b "JD              "

	; ROM start address
	dc.b $00, $00, $00, $00

	; ROM end address will be here
	dc.b $00, $02, $00, $00

	; Some magic values, I don't know what these mean
	dc.b $00, $FF, $00, $00
	dc.b $00, $FF, $FF, $FF

	; We don't have a modem, so we fill this with spaces
	dc.b "               "

	; Unused
	dc.b "                        "
	dc.b "                         "

	; Country
	dc.b "JUE             "

	; dc = define constant
	; ds = define space, hur många bytes man vill allokera. ds.l 10 allokerar 10 longs
	; rs = definera en struct


	org	$200


	;
	; Bootup
	;
	; The first attempt was to write a subroutine for each thing we want to do during bootup, to keep the code
	; nice and tidy. There where problems trashing the stack pointer so for simplicity we do everything without
	; subroutines. It's not like we'll reuse the code anyways.
	;

	;
	; Init the copy protection
	;
	move.b		$A10001,d0					; Read MegaDrive hardware version					| D0 =(0x00A10001)
	andi.b		#$0F,d0						; The version is stored in last four bytes			| D0 = 0x0000xxxx
	beq			.no_copy_protection			; If they are all zero we've got one the very
											; first MegaDrives which didn't feature the
											; protection
	move.l		#'SEGA',$A14000				; Move the string "SEGA" at 0xA14000
.no_copy_protection:

	;
	; Clear RAM
	;
	;clr.l		d0							; d0 will contain the value we clear the memory with
	move.l		#'FEST',d0
	move.l		#$3fff,d1					; d1 is the number of long words we will clear. We don't clear the last long since that is the stack 
	move.l		#$0,a0						; a0 is the address to clear. It starts at 0 and is pre decremented before writing, so that means the first long is written to $fffffffc
.clear_ram_loop:
	move.l		d0,-(a0)					; a0 is decremented by 4, and then 0 is written to the new address
	dbra		d1,.clear_ram_loop			; decrease d1 by one. If d1 doesn't reach 0 we keep looping

	;
	; Init stack pointer
	;
	move.l		#$0,sp						; Set stack pointer to 0, and it decrements so the first long value will be stored at $fffffc (decrement first, then write)

	jsr			rendInit

	;
	; Enable interrupts
	;
	move.l		#0,(VarVsync)
	move.l		#0,(VarHsync)
	move.w		#$2400,sr

	move.l		#$11111111,d0
	move.l		#$22222222,d1
	move.l		#$33333333,d2
	move.l		#$44444444,d3
	move.l		#$55555555,d4
	move.l		#$66666666,d5
	move.l		#$77777777,d6
	move.l		#$88888888,d7

	jsr			main

;==============================================================================
;
; Interrupt routines
;
;==============================================================================
Interrupt:
	rte
	
HBlankInterrupt:
	add.l		#1,(VarHsync)
	rte

VBlankInterrupt:
	add.l		#1,(VarVsync)
	rte
