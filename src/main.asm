main:
	move.l		#0,d2					; d2 = x scroll position for background layer
	move.l		#0,d3					; d3 = y scroll position for background layer

	jsr			memGetUserBaseAddress	;
	move.l		a0,a2					; a2 will be user mem from now on

	nop									; krister was here
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	; Yo from Magnus!

.loop:
	jsr			inpUpdate				; Return the currently pressed buttons in d7

	btst		#INPUT_LEFT,d7
	beq			.scroll_left

	btst		#INPUT_RIGHT,d7
	beq			.scroll_right

	bra			.scroll_updown

.scroll_left:
	addq.w		#1,d2
	bra			.scroll_updown

.scroll_right:
	subq.w		#1,d2
	bra			.scroll_updown

.scroll_updown:
	btst		#INPUT_UP,d7
	beq			.scroll_up

	btst		#INPUT_DOWN,d7
	beq			.scroll_down

	bra			.done

.scroll_up:
	subq.w		#1,d3
	bra			.done

.scroll_down:
	addq.w		#1,d3
	bra			.done

.done:
	jsr			rendWaitVSync

	; Update scrolling position
	move.l		d2,d0					; x position
	move.l		d3,d1					; y position
	jsr			rendSetScrollXY			; d0=x position, d1=y position

	;
	bra			.loop

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
