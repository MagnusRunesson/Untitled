screen_width				equ			320
screen_height				equ			224

room_width					equ			512
room_height					equ			512

camera_padding_horizontal	equ			96
camera_padding_vertical		equ			64

	rsreset
_hero_sprite_handle			rs.l		1
_hero_sprite_pos_x			rs.w		1
_hero_sprite_pos_y			rs.w		1
_camera_pos_x				rs.w		1
_camera_pos_y				rs.w		1



main:
	;
	jsr			memGetUserBaseAddress(pc)	;
	move.l		a0,a2						; a2 will be user mem from now on

	;
	; Setup local variables
	;
	move		#0,_hero_sprite_pos_x(a2)
	move		#0,_hero_sprite_pos_y(a2)
	move		#0,_camera_pos_x(a2)
	move		#0,_camera_pos_y(a2)

	;
	; Load world graphics
	;
	move.l		#fileid_testtiles_palette,d0
	moveq		#0,d1
	jsr			rendLoadPalette(pc)

	move.l		#fileid_testtiles_bank,d0
	jsr			rendLoadTileBank(pc)

	move.l		#fileid_testmap_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)

	;
	; Load the potion sprite
	;
	move.l		#fileid_testsprite2_sprite_chunky,d0
	move.l		#fileid_testsprite2_sprite,d1
	bsr.w		rendLoadSprite

	;
	; Load the hero sprite
	;
	move.l		#fileid_herotest_sprite_chunky,d0
	move.l		#fileid_herotest_sprite,d1
	bsr.w		rendLoadSprite
	move.l		d0,_hero_sprite_handle(a2)	; Retain the handle to the hero sprite

.main_loop:
	bsr			_inputUpdate
	bsr			_cameraUpdate

	perf_stop
	jsr			rendWaitVSync(pc)
	perf_start

	;
	; Slow loop to test performance thingie
	;
;	move.l		#8000,d1
;.perf_loop_test:
;	dbra		d1,.perf_loop_test

	;
	; Transform hero sprite position from world space
	; to screen space and update hero sprite position
	;
	move		_camera_pos_x(a2),d3
	move		_camera_pos_y(a2),d4
	move.l		_hero_sprite_handle(a2),d0	; d0 should be sprite index
	move		_hero_sprite_pos_x(a2),d1		; d1 should be x position
	move		_hero_sprite_pos_y(a2),d2		; d2 should be y position
	sub			d3,d1
	sub			d4,d2

	jsr			rendSetSpritePosition(pc)

	;
	; Update background position
	;
	clr			d0
	clr			d1
	move		_camera_pos_x(a2),d0
	move		_camera_pos_y(a2),d1
	jsr			rendSetScrollXY(pc)			; d0=x position, d1=y position

	nop
	nop

	;
	bra			.main_loop




;
; Ask hardware for the input and act on it
;
_inputUpdate:
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
	subq.w		#1,_hero_sprite_pos_x(a2)
	bra			.scroll_updown

.scroll_right:
	addq.w		#1,_hero_sprite_pos_x(a2)
	bra			.scroll_updown

.scroll_updown:
	btst		#INPUT_UP,d0
	beq			.scroll_up

	btst		#INPUT_DOWN,d0
	beq			.scroll_down

	bra			.done

.scroll_up:
	subq.w		#1,_hero_sprite_pos_y(a2)
	bra			.done

.scroll_down:
	addq.w		#1,_hero_sprite_pos_y(a2)
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
	; As it is now all the branches to done could be an rts instead,
	; but in case we want to clean something up it's better to have
	; closure to the function so we're prepared.
	rts



;
; Updates the camera. The camera will follow the
; player sprite around, but not go out of bounds
;
_cameraUpdate:
	move		_camera_pos_x(a2),d0
	move		_hero_sprite_pos_x(a2),d1

	;
	; Check if player is too far left
	;
	sub			d0,d1								; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub			#camera_padding_horizontal,d1		; delta -= padding					(10-32=-22)
	cmp			#0,d1								;
	bge			.no_adjust_left
	add			d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp			#0,d0
	bge			.left_ok
	clr			d0
.left_ok:
	move		d0,_camera_pos_x(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
	bra			.check_vertical_adjust

.no_adjust_left:
	move		_hero_sprite_pos_x(a2),d1


	;
	; Check if player is too far to the right
	;

	;
	; CameraX = 10
	; Camera width = 320
	; PlayerX = 340
	; Then player is 10 pixels off screen to the right
	; PlayerX-CameraX-CameraWidth=10
	;
	;
	;

	sub			d0,d1													; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub			#screen_width-camera_padding_horizontal-16,d1			; delta -= padding					(10-32=-22)
	cmp			#0,d1													;
	ble			.no_adjust_right
	add			d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp			#room_width-screen_width,d0
	ble			.right_ok
	move		#room_width-screen_width,d0
.right_ok:
	move		d0,_camera_pos_x(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
.no_adjust_right:




.check_vertical_adjust:
	move		_camera_pos_y(a2),d0
	move		_hero_sprite_pos_y(a2),d1

	;
	; Check if player is too far left
	;
	sub			d0,d1							; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub			#camera_padding_vertical,d1		; delta -= padding					(10-32=-22)
	cmp			#0,d1							;
	bge			.no_adjust_up
	add			d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp			#0,d0
	bge			.up_ok
	clr			d0
.up_ok:
	move		d0,_camera_pos_y(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
	bra			.done

.no_adjust_up:
	move		_hero_sprite_pos_y(a2),d1


	;
	; Check if player is too far to the right
	;

	;
	; CameraX = 10
	; Camera width = 320
	; PlayerX = 340
	; Then player is 10 pixels off screen to the right
	; PlayerX-CameraX-CameraWidth=10
	;
	;
	;

	sub			d0,d1													; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub			#screen_height-camera_padding_vertical-16,d1			; delta -= padding					(10-32=-22)
	cmp			#0,d1													;
	ble			.no_adjust_down
	add			d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp			#room_height-screen_height,d0
	ble			.down_ok
	move		#room_height-screen_height,d0
.down_ok:
	move		d0,_camera_pos_y(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
.no_adjust_down:


.done:
	rts
