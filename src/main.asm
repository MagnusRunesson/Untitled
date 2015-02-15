screen_width				equ			320
	ifd	_is_mega_drive
screen_height				equ			224
	else
screen_height				equ			256
	endif

room_width					equ			512
room_height					equ			512

camera_padding_horizontal	equ			96
camera_padding_vertical		equ			64

	rsreset
_hero_go_handle				rs.l		1
_hero_sprite_pos_x			rs.l		1
_hero_sprite_pos_y			rs.l		1
_camera_pos_x				rs.l		1
_camera_pos_y				rs.l		1
_potion_go_handle			rs.w		1
_testanim_time				rs.w		1
_potion2_go_handle			rs.w		1
_potion3_go_handle			rs.w		1
_potion4_go_handle			rs.w		1
_potionanim_time			rs.w		1


main:
	jsr			gomInit(pc)

	;
	jsr			memGetUserBaseAddress(pc)	;
	move.l		a0,a2						; a2 will be user mem from now on
	lea			sintable(pc),a3				; a3 will be sinus table

	;
	; Setup local variables
	;
	move.l		#0,_hero_sprite_pos_x(a2)
	move.l		#0,_hero_sprite_pos_y(a2)
	move.l		#0,_camera_pos_x(a2)
	move.l		#0,_camera_pos_y(a2)

	;
	move		#0,_testanim_time(a2)
	move.w		#0,_potionanim_time(a2)

	;
	; Load world graphics
	;
	move.l		#fileid_testtiles_palette,d0
	moveq		#0,d1
	jsr			rendLoadPalette(pc)

	ifd is_amiga
	move.l		#fileid_testsprite_palette,d0
	moveq		#1,d1
	jsr			rendLoadPalette(pc)
	endif

	move.l		#fileid_testtiles_bank,d0
	jsr			rendLoadTileBank(pc)

	move.l		#fileid_testmap_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)

	;
	; Load the potion game object
	;
	lea			potion_go(pc),a0
	jsr			gomLoadObject(pc)
	move.l		d0,_potion_go_handle(a2)

	;
	; Load the hero game object
	;
	lea			hero_go(pc),a0
	jsr			gomLoadObject(pc)
	move.l		d0,_hero_go_handle(a2)

	;
	; Load more the potions
	;
	lea			potion_go(pc),a0
	jsr			gomLoadObject(pc)
	move.w		d0,_potion2_go_handle(a2)

	;
	; Load more the potions
	;
	lea			potion_go(pc),a0
	jsr			gomLoadObject(pc)
	move.w		d0,_potion3_go_handle(a2)

	;
	; Load more the potions
	;
	lea			potion_go(pc),a0
	jsr			gomLoadObject(pc)
	move.w		d0,_potion4_go_handle(a2)

.main_loop:
	;
	; Read player input and update player world positions
	;
	bsr			_inputUpdate
	bsr			_checkBorders

	;
	; Update hero position with the game object manager
	;
	move.l		_hero_go_handle(a2),d0
	move.l		_hero_sprite_pos_x(a2),d1
	move.l		_hero_sprite_pos_y(a2),d2
	jsr			gomSetPosition(pc)

	;
	;move.w		_potion_go_handle(a2),d0	; d0 is game object handle
	;move.w		_potionanim_time(a2),d3
	;lsl.w		#1,d3
	;move.w		#30,d1						; d1 is world X position
	;move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	;asr.w		#3,d2
	;add.w		#100,d2
	;jsr			gomSetPosition(pc)
;
	;move.w		_potion2_go_handle(a2),d0	; d0 is game object handle
	;add.w		#30,d3
	;and.w		#$1ff,d3
	;add.w		#8,d1						; d1 is world X position
	;move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	;asr.w		#3,d2
	;add.w		#100,d2
	;jsr			gomSetPosition(pc)
;
	;move.w		_potion3_go_handle(a2),d0	; d0 is game object handle
	;add.w		#30,d3
	;and.w		#$1ff,d3
	;add.w		#8,d1						; d1 is world X position
	;move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	;asr.w		#3,d2
	;add.w		#100,d2
	;jsr			gomSetPosition(pc)
;
	;move.w		_potion4_go_handle(a2),d0	; d0 is game object handle
	;add.w		#30,d3
	;and.w		#$1ff,d3
	;add.w		#8,d1						; d1 is world X position
	;move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	;asr.w		#3,d2
	;add.w		#100,d2
	;jsr			gomSetPosition(pc)




	;
	; Update camera so the player doesn't go out of bounds
	;
	bsr			_cameraUpdate

	;
	; Update camera position with the game object manager
	;
	move.l		_camera_pos_x(a2),d0
	move.l		_camera_pos_y(a2),d1
	jsr			gomSetCameraPosition(pc)

	perf_stop
	jsr			rendWaitVSync(pc)
	perf_start

	jsr			gomSortObjects(pc)
	jsr			gomRender(pc)


	;
	; Slow loop to test performance thingie
	;
;	move.l		#8000,d1
;.perf_loop_test:
;	dbra		d1,.perf_loop_test

	;
	; Update animation
	;
	move.w		_potion_go_handle(a2),d0
	move.w		_testanim_time(a2),d1
	lsr			#4,d1
	and			#1,d1
	jsr			rendSetSpriteFrame(pc)

	;
	; Increment animation time
	;
	move.w		_testanim_time(a2),d0
	add.w		#1,d0
	and.w		#$ff,d0
	move.w		d0,_testanim_time(a2)

	;
	; Increment potion animation time
	;
	move.w		_potionanim_time(a2),d0
	add.w		#1,d0
	and.w		#$ff,d0
	move.w		d0,_potionanim_time(a2)


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
	sub.l		#$10000,_hero_sprite_pos_x(a2)
	bra			.scroll_updown

.scroll_right:
	add.l		#$10000,_hero_sprite_pos_x(a2)
	bra			.scroll_updown

.scroll_updown:
	btst		#INPUT_UP,d0
	beq			.scroll_up

	btst		#INPUT_DOWN,d0
	beq			.scroll_down

	bra			.done

.scroll_up:
	sub.l		#$10000,_hero_sprite_pos_y(a2)
	bra			.done

.scroll_down:
	add.l		#$10000,_hero_sprite_pos_y(a2)
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
	move.l		_camera_pos_x(a2),d0
	move.l		_hero_sprite_pos_x(a2),d1

	;
	; Check if player is too far left
	;
	sub.l		d0,d1									; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub.l		#camera_padding_horizontal*$10000,d1	; delta -= padding					(10-32=-22)
	cmp.l		#0,d1									;
	bge			.no_adjust_left
	add.l		d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp.l		#0,d0
	bge			.left_ok
	clr.l		d0
.left_ok:
	move.l		d0,_camera_pos_x(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
	bra			.check_vertical_adjust

.no_adjust_left:
	move.l		_hero_sprite_pos_x(a2),d1


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

	sub.l		d0,d1													; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub.l		#(screen_width-camera_padding_horizontal-16)*$10000,d1			; delta -= padding					(10-32=-22)
	cmp.l		#0,d1													;
	ble			.no_adjust_right
	add.l		d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp.l		#(room_width-screen_width)*$10000,d0
	ble			.right_ok
	move.l		#(room_width-screen_width)*$10000,d0
.right_ok:
	move.l		d0,_camera_pos_x(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
.no_adjust_right:




.check_vertical_adjust:
	move.l		_camera_pos_y(a2),d0
	move.l		_hero_sprite_pos_y(a2),d1

	;
	; Check if player is too far left
	;
	sub.l		d0,d1							; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub.l		#(camera_padding_vertical)*$10000,d1		; delta -= padding					(10-32=-22)
	cmp.l		#0,d1							;
	bge			.no_adjust_up
	add.l		d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp.l		#0,d0
	bge			.up_ok
	clr.l		d0
.up_ok:
	move.l		d0,_camera_pos_y(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
	bra			.done

.no_adjust_up:
	move.l		_hero_sprite_pos_y(a2),d1


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

	sub.l		d0,d1													; d2 = CameraX - HeroSpriteX		(30-40=10 pixels to the left)
	sub.l		#(screen_height-camera_padding_vertical-16)*$10000,d1			; delta -= padding					(10-32=-22)
	cmp.l		#0,d1													;
	ble			.no_adjust_down
	add.l		d1,d0

	; Now when we've adjust the camera to the left we need to make sure it isn't too far off to the left
	cmp.l		#(room_height-screen_height)*$10000,d0
	ble			.down_ok
	move.l		#(room_height-screen_height)*$10000,d0
.down_ok:
	move.l		d0,_camera_pos_y(a2)		; If we need to adjust the camera then d2 will be a negative value, hence moving the camera to the left when we add d2 to the camera position
.no_adjust_down:


.done:
	rts


_checkBorders:
	move.l		_hero_sprite_pos_x(a2),d0
	cmp.l		#0,d0
	bge			.no_left

	;
	; Load room to the left
	;
	move.l		#fileid_testmap_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)

	;
	; Warp hero to the right of the new map
	;
	move.l		#(511-16)*$10000,_hero_sprite_pos_x(a2)

	; Done
	bra			.done

.no_left:
	cmp.l		#(511-16)*$10000,d0
	ble			.no_right

	;
	; Load room to the right
	;
	move.l		#fileid_testmap2_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)

	;
	; Warp hero to the left of the new map
	;
	move.l		#0,_hero_sprite_pos_x(a2)

.no_right:
.done:
	rts
