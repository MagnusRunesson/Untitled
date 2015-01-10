main:
	jsr			rendInit(pc)
	move.l		#0,d2					; d2 = x scroll position for background layer
	move.l		#0,d3					; d3 = y scroll position for background layer

	jsr			memGetUserBaseAddress(pc)	;
	move.l		a0,a2					; a2 will be user mem from now on

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	move.l		#FILEID_UNTITLED_SPLASH_PALETTE,d0
	jsr			fileLoad

	;move.l		#_data_untitled_splash_bank_pos,d0

	printt		'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
	printt		'_data_untitled_splash_palette_pos:'
	printv		_data_untitled_splash_palette_pos
	printt		''
	printt		'_data_untitled_splash_palette_length:'
	printv		_data_untitled_splash_palette_length
	printt		''
	printt		'_data_untitled_splash_palette:'
	printv		_data_untitled_splash_palette
	printt		''

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.loop:
	jsr			inpUpdate				; Return the currently pressed buttons in d7

	btst		#INPUT_LEFT,d0
	beq			.scroll_left

	btst		#INPUT_RIGHT,d0
	beq			.scroll_right

	bra			.scroll_updown

.scroll_left:
	addq.w		#1,d2
	bra			.scroll_updown

.scroll_right:
	subq.w		#1,d2
	bra			.scroll_updown

.scroll_updown:
	btst		#INPUT_UP,d0
	beq			.scroll_up

	btst		#INPUT_DOWN,d0
	beq			.scroll_down

	bra			.done

.scroll_up:
	subq.w		#1,d3
	bra			.done

.scroll_down:
	addq.w		#1,d3
	bra			.done

.done:
	jsr			rendWaitVSync(pc)

	; Update scrolling position
	move.l		d2,d0					; x position
	move.l		d3,d1					; y position
	jsr			rendSetScrollXY(pc)			; d0=x position, d1=y position

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
