main:
	move.l		#0,d2					; d2 = x scroll position for background layer
	move.l		#0,d3					; d3 = y scroll position for background layer

	jsr			memGetUserBaseAddress(pc)	;
	move.l		a0,a2					; a2 will be user mem from now on

	move.l		#fileid_testtiles_palette,d0
	moveq		#0,d1
	jsr			rendLoadPalette(pc)

	move.l		#fileid_testtiles_bank,d0
	jsr			rendLoadTileBank(pc)

	move.l		#fileid_testmap_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)

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

	move.l		#fileid_herotest_sprite_chunky,d0
	move.l		#fileid_herotest_sprite,d1
	bsr.w		rendLoadSprite

	move.l		#fileid_testsprite2_sprite_chunky,d0
	move.l		#fileid_testsprite2_sprite,d1
	bsr.w		rendLoadSprite


	;move.l		#FILEID_UNTITLED_SPLASH_PALETTE,d0
	;bsr.w		fileLoad

	;move.l		#_data_untitled_splash_bank_pos,d0

	;printt		'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
	;printt		'_data_untitled_splash_bank:'
	;printv		_data_untitled_splash_bank
	;printt		''
	;printt		'_data_untitled_splash_map:'
	;printv		_data_untitled_splash_map
	;printt		''
	;printt		'_data_untitled_splash_palette:'
	;printv		_data_untitled_splash_palette
	;printt		''

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

.loop:
	jsr			inpUpdate(pc)				; Return the currently pressed buttons in d0

	btst		#INPUT_ACTION,d0
	beq			.change_picture_0

	btst		#INPUT_ACTION2,d0
	beq			.change_picture_1

	btst		#INPUT_LEFT,d0
	beq			.scroll_left

	btst		#INPUT_RIGHT,d0
	beq			.scroll_right

	bra			.scroll_updown

.scroll_left:
	subq.w		#1,d2
	bra			.scroll_updown

.scroll_right:
	addq.w		#1,d2
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

.change_picture_0
	lea			testtiles_image(pc),a0
	bsr.w		imgLoad
	bra			.done

.change_picture_1
	lea			untitled_splash_image(pc),a0
	bsr.w		imgLoad
	bra			.done

.done:
	perf_stop
	jsr			rendWaitVSync(pc)
	perf_start
	
	;
	; Slow loop to test performance thingie
	;
;	move.l		#8000,d1
;.perf_loop_test:
;	dbra		d1,.perf_loop_test

	;push		d2
	move.l		d2,-(sp)

	nop
	nop
	nop

	move		#0,d0		; d0 should be sprite index
	move.l		d2,d1		; d1 should be x position
	move.l		d3,d2		; d2 should be y position
	jsr			rendSetSpritePosition(pc)

	nop
	nop
	nop

	; Update scrolling position
	;move.l		d2,d0					; x position
	;move.l		d3,d1					; y position
	;jsr			rendSetScrollXY(pc)			; d0=x position, d1=y position

	;pop			d2
	move.l		(sp)+,d2

	;
	bra			.loop
