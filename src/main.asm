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
_signpost_go_handle			rs.w		1
_stoneblock_go_handle		rs.w		1
_potionanim_time			rs.w		1
_current_collisionmap		rs.l		1


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
	move.l		#_data_testmap_collisionmap,_current_collisionmap(a2)

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

	;
	; Load more the potions
	;
	lea			signpost_go(pc),a0
	jsr			gomLoadObject(pc)
	move.w		d0,_signpost_go_handle(a2)
	move.l		#$280000,d1
	move.l		#$140000,d2
	jsr			gomSetPosition(pc)

	;
	; Load stone block
	;
	lea			stoneblock_go(pc),a0
	jsr			gomLoadObject(pc)
	move.w		d0,_stoneblock_go_handle(a2)
	move.l		#$780000,d1
	move.l		#$840000,d2
	jsr			gomSetPosition(pc)

.main_loop:
	;
	; Read player input and update player world positions
	;
	bsr			_inputUpdate

	;
	; Check collision here!
	;
	bsr			_checkCollision

	;
	; Apply new delta
	;
	add.l		d0,_hero_sprite_pos_x(a2)
	add.l		d1,_hero_sprite_pos_y(a2)

	;
	; Update camera
	;
	bsr			_checkBorders

	;
	; Update hero position with the game object manager
	;
	move.l		_hero_go_handle(a2),d0
	move.l		_hero_sprite_pos_x(a2),d1
	move.l		_hero_sprite_pos_y(a2),d2
	jsr			gomSetPosition(pc)

	;
	; Sinus movement for potions
	;
	move.w		_potion_go_handle(a2),d0	; d0 is game object handle
	move.w		_potionanim_time(a2),d3
	lsl.w		#1,d3
	move.l		#30*$10000,d1				; d1 is world X position
	move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	asr.w		#3,d2
	swap.w		d2
	clr.w		d2
	add.l		#100*$10000,d2
	jsr			gomSetPosition(pc)

	move.w		_potion2_go_handle(a2),d0	; d0 is game object handle
	add.w		#30,d3
	and.w		#$1ff,d3
	add.l		#8*$10000,d1				; d1 is world X position
	move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	asr.w		#3,d2
	swap.w		d2
	clr.w		d2	
	add.l		#100*$10000,d2
	jsr			gomSetPosition(pc)

	move.w		_potion3_go_handle(a2),d0	; d0 is game object handle
	add.w		#30,d3
	and.w		#$1ff,d3
	add.l		#8*$10000,d1				; d1 is world X position
	move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	asr.w		#3,d2
	swap.w		d2
	clr.w		d2	
	add.l		#100*$10000,d2
	jsr			gomSetPosition(pc)

	move.w		_potion4_go_handle(a2),d0	; d0 is game object handle
	add.w		#30,d3
	and.w		#$1ff,d3
	add.l		#8*$10000,d1				; d1 is world X position
	move.w		(a3,d3),d2					; d2 is world Y position, from sin table. Can be negative.
	asr.w		#3,d2
	swap.w		d2
	clr.w		d2	
	add.l		#100*$10000,d2
	jsr			gomSetPosition(pc)




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
; Ask hardware for the input and put the result in registers
;
; Input:
;	none
;
; Output:
;	d0=delta on X, in 16.16 fixed point
;	d1=delta on Y, in 16.16 fixed point
;
_inputUpdate:
	jsr			inpUpdate(pc)				; Return the currently pressed buttons in d0

	move.l		d0,d2

	btst		#INPUT_ACTION,d2
	beq			.change_picture_0

	btst		#INPUT_ACTION2,d2
	beq			.change_picture_1

	btst		#INPUT_LEFT,d2
	beq			.scroll_left

	btst		#INPUT_RIGHT,d2
	beq			.scroll_right

	; No movement on X
	clr.l		d0
	bra			.scroll_updown

.scroll_left:
	move.l		#-$10000,d0
	bra			.scroll_updown

.scroll_right:
	move.l		#$10000,d0
	bra			.scroll_updown

.scroll_updown:
	btst		#INPUT_UP,d2
	beq			.scroll_up

	btst		#INPUT_DOWN,d2
	beq			.scroll_down

	; No movement on Y
	clr.l		d1

	bra			.done

.scroll_up:
	move.l		#-$10000,d1
	bra			.done

.scroll_down:
	move.l		#$10000,d1
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
	move.l		#_data_testmap_collisionmap,_current_collisionmap(a2)

	;
	; Warp hero to the right of the new map
	;
	move.l		#511*$10000,_hero_sprite_pos_x(a2)

	; Done
	bra			.done

.no_left:
	cmp.l		#511*$10000,d0
	ble			.no_right

	;
	; Load room to the right
	;
	move.l		#fileid_testmap2_map,d0
	move.l		#0,d1
	jsr			rendLoadTileMap(pc)
	move.l		#_data_testmap2_collisionmap,_current_collisionmap(a2)

	;
	; Warp hero to the left of the new map
	;
	move.l		#0,_hero_sprite_pos_x(a2)

.no_right:
.done:
	rts



;
; Input
;	d0=movement X, in 16.16 fixed point
;	d1=movement Y, in 16.16 fixed point
;
; Output:
;	d0=movement X, in 16.16 fixed point
;	d1=movement Y, in 16.16 fixed point
;
_checkCollision:
	pushm.l		d2-d7/a0-a6

	;
	; First convert from 16.16 fixed point to 32.0 regular thingie
	;
	swap		d0
	and.l		#$0000ffff,d0
	swap		d1
	and.l		#$0000ffff,d1

	;
	; Find out which way we're going so we know which sensors to use for collision detection
	;
	; 		int mdx = wanted_dir_x+1;
	;		int mdy = wanted_dir_y+1;
	;		int sensor_list_index = (mdy*3)+mdx;
	;		if( sensor_list_index == 4 )
	;			goto done;
	;
	move.w		d1,d2		; wanted dir Y to d2
	add.w		#1,d2		; Since direction is -1 to 1 we need to move it to 0 to 2
	mulu.w		#3,d2		; Multiply from row to index of a 3x3 matrix of stuff. Should this be 4x4 to avoid the mul?
	add.w		d0,d2		; Add wanted dir x
	add.w		#1,d2		; And again, convert from -1..1 direction to 0..2

	; Now d2 is an index into our list of sensors for the direction the object is going
	; If that index is #4 that means we're not moving, so we can skip this whole thing
	cmp.w		#4,d2
	beq			.all_done

	; Before we lose a2 we should fetch the current player position, convert from 16.16 fixed point to 32.0 and store result in a3 and a4
	move.l		_hero_sprite_pos_x(a2),d3
	swap		d3
	and.l		#$0000ffff,d3
	move.l		d3,a3
	move.l		_hero_sprite_pos_y(a2),d3
	swap		d3
	and.l		#$0000ffff,d3
	move.l		d3,a4
	; a3 is now player position X, in 32.0 format
	; a4 is now player position Y, in 32.0 format

	; Fetch the pointer to the collision tiles
	move.l		_current_collisionmap(a2),a0
	add.l		#2,a0

	; The sensor order list contain 8 entries for list, so we need to convert from index into byte offset
	lsl.w		#3,d2

	; a2 should be the pointer to our sensors
	lea			.player_sensors_orders(pc),a2
	add.w		d2,a2		; d2 is the byte offset from the start of the address to the current list of sensors, so add that offset

	; Now a2 point to somewhere in the .player_sensor_order
	clr			d7
	move.b		(a2)+,d7	; First byte in the list is the number of sensors in that list (the length of the list)
	sub.b		#1,d7		; Compensate for dbra

	; Fetch the sensor offset list
	lea			.player_sensor_offsets(pc),a1


	; d7 is the number of sensors, so we will use that to control the number of loops
	; a0 now point to the collision tile map
	; a1 now point to the list of sensor offsets
	; a2 now point to the list of sensor order for this direction
	; a3 is the current player X position, 32.0 format
	; a4 is the current player Y position, 32.0 format
	;
	; d0-d6 are unused
	; a5-a6 are unused
.loop_sensors:
	clr			d6			; Not sure if this needs to be cleared, but it will be used as an address offset, so I assume so
	move.b		(a2,d7),d6	; Read sensor index from sensor order list
	lsl.b		#2,d6

	; Read the sensor pixel offset from the table of sensor offsets
	clr			d2
	clr			d3
	move.w		(a1,d6),d2
	add.b		#2,d6
	move.w		(a1,d6),d3

	; Find the wanted X position based on player position (a3), the sensor offset (d2), and the wanted direction (d0)
	move.l		a3,d4	; a3=player world position X
	add.w		d2,d4	; d2=sensor X offset
	add.w		d0,d4	; d0=wanted X direction

	; Check if too far to the left
	cmp.w		#0,d4
	bge			.pos_x_check_right
	move.w		#0,d4
	bra			.pos_x_done

	;
	; Check if too far to the right
	;
.pos_x_check_right:
	cmp.w		#511,d4
	ble			.pos_x_done
	move.w		#511,d4

.pos_x_done:
	; Also find the wanted Y position based on player position (a4), the sensor offset (d3), and the wanted direction (d1)
	move.l		a4,d5	; a4=player world position Y
	add.w		d3,d5	; d3=sensor Y offset
	add.w		d1,d5	; d1=wanted Y direction

	;
	; Check if too far above
	;
	cmp.w		#0,d5
	bge			.pos_y_check_bottom
	move.w		#0,d5
	bra			.pos_y_done

.pos_y_check_bottom:
	; Check if too far below
	cmp.w		#511,d5
	ble			.pos_y_done
	move.w		#511,d5

.pos_y_done:

	; Calculate the tile position from a pixel position
	; Tile X from world X
	move.w		d4,d2 	; d4=new world X position for this sensor
	lsr.w		#3,d2
	
	; Tile Y from world Y
	move.w		d5,d3	; d5=new world Y position for this sensor
	lsr.w		#3,d3

	; Calculate index into collision map based on tile X and Y
	move.w		d3,d6		; d6=y
	lsl.w		#6,d6		; y*=64
	add.w		d2,d6		; d6+=x

	; Read the collision tile ID from the map
	move.b		(a0,d6),d6	;

	;
	cmp.b		#0,d6			; Collision tile #0 means no collision
	beq			.next_sensor	

	; Get the pixel offset into this tile
	move.w		d4,d2		; d4=new world X position for this sensor
	and.w		#7,d2
	move.w		d5,d3		; d5=new world Y position for this sensor
	and.w		#7,d3

	;
	cmp.b		#1,d6		; Check for collision tile 1
	beq			.l1
	cmp.b		#2,d6		; Check for collision tile 2
	beq			.l2
	cmp.b		#3,d6		; Check for collision tile 3
	beq			.l3
	cmp.b		#4,d6		; Check for collision tile 4
	beq			.l4
	cmp.b		#5,d6		; Check for collision tile 5
	beq			.l5_slope_upleft
	cmp.b		#6,d6		; Check for collision tile 6
	beq			.l6_slope_upright
	cmp.b		#7,d6		; Check for collision tile 7
	beq			.l7_slope_downleft
	cmp.b		#8,d6		; Check for collision tile 8
	beq			.l8_slope_downright
	cmp.b		#9,d6
	beq			.l9_full_stop

	bra			.next_sensor

.l1:
.l2:
	clr			d1
	bra			.next_sensor

.l3:
.l4:
	clr			d0
	bra			.next_sensor

.l5_slope_upleft:

	; if( (7-_in_tile_x) > _in_tile_y )
	;	return;
	move.b		#7,d4		; 
	sub.b		d2,d4		; 7-_in_tile_x
	cmp.b		d4,d3		; d4=(7-_in_tile_x) and d3=_in_tile_y
	blt			.next_sensor

	; if( _dir_x+_dir_y == 2 )
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 0;
	; 	return;
	; }
	move.b		d0,d4
	add.b		d1,d4
	cmp.b		#2,d4
	bne			.l5_a

	clr			d0
	clr			d1
	bra			.next_sensor

.l5_a:
	; if((_dir_x>0) && (_dir_y<0))
	; {
	;	_dir_x = 0;
	;	_dir_y = -1;
	; 	return;
	; }
	cmp.w		#0,d0
	ble			.l5_b
	cmp.w		#0,d1
	bge			.l5_b

	move.w		#0,d0
	move.w		#-1,d1
	bra			.next_sensor

.l5_b:
	; if((_dir_x<0) && (_dir_y>0))
	; {
	; 	_dir_x = -1;
	; 	_dir_y = 0;
	; 	return;
	; }
	cmp.w		#0,d0
	bge			.l5_c
	cmp.w		#0,d1
	ble			.l5_c

	move.w		#-1,d0
	move.w		#0,d1
	bra			.next_sensor

.l5_c:
	; if( _dir_x > 0 )
	; 	_dir_y = -1;
	cmp.w		#0,d0
	ble			.l5_d
	move.w		#-1,d1

.l5_d:
	; if( _dir_y > 0 )
	; 	_dir_x = -1;
	cmp.w		#0,d1
	ble			.l5_e
	move.w		#-1,d0

.l5_e:
	bra			.next_sensor

;
; Slope, up right
;
.l6_slope_upright:
	; if( _in_tile_x > _in_tile_y )
	;	return;
	cmp.b		d2,d3
	blt			.next_sensor

	; if( _dir_x-_dir_y == -2 )
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 0;
	; 	return;
	; }
	move.b		d0,d4
	sub.b		d1,d4
	cmp.b		#-2,d4
	bne			.l6_a

	clr			d0
	clr			d1
	bra			.next_sensor

.l6_a:
	; if((_dir_x<0) && (_dir_y<0))
	; {
	; 	_dir_x = 0;
	; 	_dir_y = -1;
	; 	return;
	; }
	cmp.w		#0,d0
	bge			.l6_b
	cmp.w		#0,d1
	bge			.l6_b

	move.w		#0,d0
	move.w		#-1,d1
	bra			.next_sensor

.l6_b:
	; if((_dir_x>0) && (_dir_y>0))
	; {
	; 	_dir_x = 1;
	; 	_dir_y = 0;
	; 	return;
	; }
	cmp.w		#0,d0
	ble			.l6_c
	cmp.w		#0,d1
	ble			.l6_c

	move.w		#1,d0
	move.w		#0,d1
	bra			.next_sensor

.l6_c:
	; if( _dir_x < 0 )
	; 	_dir_y = -1;
	cmp.w		#0,d0
	bge			.l6_d
	move.w		#-1,d1

.l6_d:
	; if( _dir_y > 0 )
	; 	_dir_x = 1;
	cmp.w		#0,d1
	ble			.l6_e
	move.w		#1,d0

.l6_e:
	bra			.next_sensor


.l7_slope_downleft:

	; if( _in_tile_x < _in_tile_y )
	;	return;
	cmp.b		d2,d3
	bgt			.next_sensor

	; if( _dir_x-_dir_y == 2 )
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 0;
	; 	return;
	; }
	move.b		d0,d4
	sub.b		d1,d4
	cmp.b		#2,d4
	bne			.l7_a

	clr			d0
	clr			d1
	bra			.next_sensor

.l7_a:
	; if((_dir_x>0) && (_dir_y>0))
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 1;
	; 	return;
	; }
	cmp.w		#0,d0
	ble			.l7_b
	cmp.w		#0,d1
	ble			.l7_b

	move.w		#0,d0
	move.w		#1,d1
	bra			.next_sensor

.l7_b:
	; if((_dir_x<0) && (_dir_y<0))
	; {
	; 	_dir_x = -1;
	; 	_dir_y = 0;
	; 	return;
	; }
	cmp.w		#0,d0
	bge			.l7_c
	cmp.w		#0,d1
	bge			.l7_c

	move.w		#-1,d0
	move.w		#0,d1
	bra			.next_sensor

.l7_c:
	; if( _dir_y < 0 )
	; 	_dir_x = -1;
	cmp.w		#0,d1
	bge			.l7_d
	move.w		#-1,d0

.l7_d:
	; if( _dir_x > 0 )
	; 	_dir_y = 1;
	cmp.w		#0,d0
	ble			.l7_e
	move.w		#1,d1

.l7_e:
	bra			.next_sensor



.l8_slope_downright:

	; if( _in_tile_x > (7-_in_tile_y))
	;	return;
	move.b		#7,d4
	sub.b		d3,d4
	cmp.b		d2,d4
	blt			.next_sensor

	; if( _dir_x+_dir_y == -2 )
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 0;
	; 	return;
	; }
	move.b		d0,d4
	add.b		d1,d4
	cmp.b		#-2,d4
	bne			.l8_a

	clr			d0
	clr			d1
	bra			.next_sensor

.l8_a:
	; if((_dir_x<0) && (_dir_y>0))
	; {
	; 	_dir_x = 0;
	; 	_dir_y = 1;
	; 	return;
	; }
	cmp.w		#0,d0
	bge			.l8_b
	cmp.w		#0,d1
	ble			.l8_b

	move.w		#0,d0
	move.w		#1,d1
	bra			.next_sensor

.l8_b:
	; if((_dir_x>0) && (_dir_y<0))
	; {
	; 	_dir_x = 1;
	; 	_dir_y = 0;
	; 	return;
	; }
	cmp.w		#0,d0
	ble			.l8_c
	cmp.w		#0,d1
	bge			.l8_c

	move.w		#1,d0
	move.w		#0,d1
	bra			.next_sensor

.l8_c:
	; if( _dir_y < 0 )
	; 	_dir_x = 1;
	cmp.w		#0,d1
	bge			.l8_d
	move.w		#1,d0

.l8_d:
	; if( _dir_x > 0 )
	; 	_dir_y = 1;
	cmp.w		#0,d0
	bge			.l8_e
	move.w		#1,d1

.l8_e:
	bra			.next_sensor





;
;
;
.l9_full_stop:
	move.w		#0,d0
	move.w		#0,d1
	bra			.next_sensor



.next_sensor:
	dbra		d7,.loop_sensors


	;clr.l		d0
	;clr.l		d1


.all_done:
	; Convert from 32.0 fixed point to 16.16
	swap		d0
	swap		d1

	popm.l		d2-d7/a0-a6
	rts

.player_sensors_orders:
	dc.b		5,2,1,5,4,0,-1,-1	 		; new int[]{2, 1, 5, 4, 0},
	dc.b		3,1,0,4,-1,-1,-1,-1			; new int[]{1, 0, 4},
	dc.b		5,3,0,6,4,1,-1,-1			; new int[]{3, 0, 6, 4, 1},
	dc.b		3,2,0,5,-1,-1,-1,-1			; new int[]{2, 0, 5},
	dc.b		0,-1,-1,-1,-1,-1,-1,-1		; null,
	dc.b		3,3,1,6,-1,-1,-1,-1			; new int[]{3, 1, 6},
	dc.b		5,0,3,5,7,2,-1,-1			; new int[]{0, 3, 5, 7, 2},
	dc.b		3,3,2,7,-1,-1,-1,-13		; new int[]{3, 2, 7},
	dc.b		5,1,2,6,7,3,-1,-1			; new int[]{1, 2, 6, 7, 3},

.player_sensor_offsets:
	dc.w		-6,-6						; 0 - Top left
	dc.w		5,-6						; 1 - Top right
	dc.w		-6,5						; 2 - Bottom left
	dc.w		5,5							; 3 - Bottom right
	dc.w		0,-6						; 4 - Top center
	dc.w		-6,0						; 5 - Mid left
	dc.w		5,0							; 6 - Mid right
	dc.w		0,5							; 7 - Bottom center
