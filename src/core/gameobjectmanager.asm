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
_go_sort			rs.w		1							; Sort value for object compared to other objects. Haven't decided if lower sort means drawn before or after higher sort values
_go_size			rs.w		0

;
; The state variables of the game object manager
;
	rsreset
_gom_numobjects		rs.w		1							; How many objects we currently have loaded. This increments for each loaded game object.
_gom_watermark		rs.w		1							; To unload game objects
_gom_camera_x		rs.w		1							; Camera world X position, so we can do world to screen transform
_gom_camera_y		rs.w		1							; Camera world Y position, same reason as above
_gom_gameobjects	rs.b		_gom_max_objects*_go_size	; All game objects goes here
_gom_size			rs.w		0

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
	; First we load the sprite, while the registers are untouched
	clr					d0
	clr					d1
	move.w				(a0)+,d0			; Read the file ID for the sprite tiles into d0
	move.w				(a0)+,d1			; Read the file ID for the sprite definition into d1
	jsr					rendLoadSprite(pc)	;

	; Fetch the address to the game object manager
	jsr					memGetGameObjectManagerBaseAddress(pc)
	; Now a0 is the address to the game object manager

	; Find the next free game object ID
	move.w				_gom_numobjects(a0),d0

	; "Allocate" the object ID
	add.w				#1,_gom_numobjects(a0)

	; Now we have an object ID, wen can turn that into an address for our object data
	move				d0,d1
	mulu				#_go_size,d1			; First we take the ID and turn into a byte offset from the game object manager base memory
	add.l				#_gom_gameobjects,a0	; a0 is the gom base address, so offset that into the game objects array
	add.l				d1,a0					; From the game object array, go to the specific game object
	; Current register status at this point
	; a0=the data for this specific game object
	; d0=the object ID for the game object we're working on
	; a1=unused
	; d1=unused

	; Retain the sprite handle in this game object
	move.w				d0,_go_sprite_handle(a0)

	; Setup default values for our new game object
	move.w				#0,_go_anim_time(a0)
	move.w				#0,_go_world_pos_x(a0)
	move.w				#0,_go_world_pos_y(a0)
	move.w				#0,_go_sort(a0)

	rts




































