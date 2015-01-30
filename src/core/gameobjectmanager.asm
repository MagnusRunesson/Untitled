;==============================================================================
;
; The Game Object manager is a layer between the game logic and the
; rendering hardware.
;
; This layer handles things like loading hardware sprites, updating
; animations on game objects, doing world to screen transform before
; rendering etc.
;
; Should it also resolve physics etc? If it holds the world position
; of game objects, and the interface to change the world position is
; through this, does that mean this should also handle collision?
;
; Maybe!
;
;==============================================================================

_gom_max_objects	equ			40		; Maximum number of game objects in a room at any given time


;
; The properties of an individual game object
;
	rsreset
_go_world_pos_x		rs.w		1							; Game object world X position
_go_world_pos_y		rs.w		1							; Game object world Y position
_go_sprite_handle	rs.w		1							; Hardware sprite handle for the associated sprite
_go_anim_time		rs.w		1							; Current animation time
_go_size			rs.w		1

;
; The state variables of the game object manager
;
	rsreset
_gom_numobjects		rs.w		1							; How many objects we currently have loaded. This increments for each loaded game object.
_gom_watermark		rs.w		1							; To unload game objects
_gom_camera_x		rs.w		1							; Camera world X position, so we can do world to screen transform
_gom_camera_y		rs.w		1							; Camera world Y position, same reason as above
_gom_gameobjects	rs.b		_gom_max_objects*_go_size	; All game objects goes here
_gom_size			rs.w		1


;==============================================================================
;
; Game Object Manager Init
;
; Setup the default state of the game object manager
;
; Input
;	None
;
; Output
;	None
;
;==============================================================================

gomInit:
	jsr			memGetGameObjectManagerBaseAddress(pc)

	;	
	; Clear all local variables
	;
	move.l		#(_gom_size/4)-1,d0
.loop:
	move.l		#0,(a0)+
	dbra		d0,.loop

	rts


;==============================================================================
;
; Loads a game object and set up all the state variables needed
;
; Input
;	a0=address pointing at static game object data
;
; Output
;	d0=handle to the game object
;
;==============================================================================

gomLoadObject:
	stack_alloc			8
	stack_write.l		a0,0

	jsr					memGetGameObjectManagerBaseAddress(pc)
	move.w				_gom_numobjects(a0),d0
	add.w				#1,_gom_numobjects(a0)

	; Allocate a game object first

	stack_read.l		a0,0

	clr					d0
	clr					d1
	move.w				(a0)+,d0			; Read the file ID for the sprite tiles into d0
	move.w				(a0)+,d1			; Read the file ID for the sprite definition into d1
	jsr					rendLoadSprite(pc)	;

	stack_free			8
	rts




































