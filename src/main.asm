main:
	move.l		#0,d0					; d0 = scroll position for background layer
	move.l		#0,d1					; d1 = scroll vertical


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

	btst		#INPUT_UP,d7
	beq			.scroll_up

	btst		#INPUT_DOWN,d7
	beq			.scroll_down

	bra			.done

.scroll_left:
	addq.w		#1,d0
	bra			.done

.scroll_right:
	subq.w		#1,d0
	bra			.done

.scroll_up:
	subq.w		#1,d1
	bra			.done

.scroll_down:
	addq.w		#1,d1
	bra			.done

.done:
	jsr			rendWaitVSync
	jsr			rendSetScrollXY			; d0=x position, d1=y position

	bra			.loop

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
