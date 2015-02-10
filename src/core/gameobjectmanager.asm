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
_gom_draworder		rs.b		_gom_max_objects			; This table describe which game object to draw when. First entry should be drawn first (i.e. earlier entries should be displayed "behind" later entries in this list)
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
	push.w				d0

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
	pop.w				d2
	move.w				d2,_go_sprite_handle(a0)

	; Setup default values for our new game object
	move.w				#0,_go_anim_time(a0)
	move.w				#0,_go_world_pos_x(a0)
	move.w				#0,_go_world_pos_y(a0)
	move.w				#0,_go_sort(a0)

	; We also need to add this object to the draw order array

	; Fetch the address to the game object manager
	jsr					memGetGameObjectManagerBaseAddress(pc)
	clr.l				d0
	move.w				_gom_numobjects(a0),d0
	; a0=the address to the game object manager
	; d0=the number of game objects in the scene

	; Find the byte address to the next entry in the draw order table
	add.l				#_gom_draworder,a0
	add.l				d0,a0
	; Now a0 is the address of the next entry in the draw order table

	; Add the new game object last in the draw order table
	move.b				d2,(a0)

	rts


;==============================================================================
;
; Input
;	d0=Game object handle
;	d1=World position X
;	d2=World position Y
;
;==============================================================================

gomSetPosition:
	jsr				memGetGameObjectManagerBaseAddress(pc)
	add.l			#_gom_gameobjects,a0
	mulu			#_go_size,d0
	add.l			d0,a0
	; a0 is now pointing to the game object instance

	move.w			d1,_go_world_pos_x(a0)
	move.w			d2,_go_world_pos_y(a0)

	rts


gomSetCameraPosition:
	jsr				memGetGameObjectManagerBaseAddress(pc)
	move			d0,_gom_camera_x(a0)
	move			d1,_gom_camera_y(a0)
	rts

;==============================================================================
;
; Transform all world positions to screen
; positions and refresh all sprite positions
;
;==============================================================================

gomRender:
	pushm			d2-d7/a2-a7

	; Iterate over all game objects
	; For each game object:
	;	Transform them from world space to screen space
	;	Push the new screen space position to the renderer

	; Fetch the address to the game object manager
	jsr				memGetGameObjectManagerBaseAddress(pc)
	move.l			a0,a2
	; Now a2 is the address to the game object manager

	; Fetch the camera position
	move.w			_gom_camera_x(a2),d3
	move.w			_gom_camera_y(a2),d4

	; Update the background position
	clr.l			d0
	clr.l			d1
	move.w			d3,d0
	move.w			d4,d1
	jsr				rendSetScrollXY(pc)			; d0=x position, d1=y position

	; Fetch the number of game objects allocated.
	clr.l			d5
	move.w			_gom_numobjects(a2),d5
	sub.w			#1,d5		; dbra needs to subtract one otherwise we'll loop too many times

	; Calculate the address of the last object in the list (i.e., the
	; object we will work on first, since the ID is going from max to 0)

	; d2 is the game object ID
	move.l			a2,a3			; a2 is the game object manager base address
	add.w			#_gom_gameobjects,a3
	move.w			d5,d0
	mulu			#_go_size,d0
	add.w			d0,a3

	; d0 is trash
	; d1 is trash
	; d2 is trash
	; d3 is camera X
	; d4 is camera Y
	; d5 is the game object ID, which is also used as the loop counter
	; a2 is the game object manager base address
	; a3 is now the address to the last game object and will be used for as a pointer to the current game object we're working on

.loop:
	move		_go_sprite_handle(a3),d0	; d0 = sprite handle
	move		_go_world_pos_x(a3),d1		; d1 = game object world position X
	move		_go_world_pos_y(a3),d2		; d2 = game object world position Y
	sub			d3,d1						; World to camera space on X
	sub			d4,d2						; World to camera space on Y
	jsr			rendSetSpritePosition(pc)	; Refresh hardware sprite position

	; Go to next game object (i.e. the game object that is
	; before this in memory, since we're iterating down)
	sub				#_go_size,a3
	dbra			d5,.loop

	popm			d2-d7/a2-a7

	rts


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
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	printt			"gom_draworder address in RAM:"
	printv			$00ff0000+gommem_base+_gom_draworder
;
; A simple bubble sort
;
gomSortObjects:
	pushm			d2-d7/a2-a7

	; Fetch the address of the draw order table
	jsr				memGetGameObjectManagerBaseAddress(pc)
	move.l			a0,a2
	add.l			#_gom_draworder,a2
	move.l			a0,a3
	add.l			#_gom_gameobjects,a3

	; 
	move.w			_gom_numobjects(a0),d0
	sub.w			#1,d0						; Don't check the last object in the array since we always compare pairs (we compare i and i+1)

	; a2=address to the draw order table
	; a3=address to the game object table
	; d0=num game objects in scene-1 (because bubble sort compair pairs)
.sort_again_loop:
	clr				d2
	move.w			d0,d2			; d0 is the game object index for the sort loop
	move.w			d0,d3
	add.w			#1,d3			; d3 is the "other" index to the draw order table (index to game object B)
	clr				d1				; d1 is flag that determine if we should do another round

.compare_loop:
	clr				d4
	clr				d5
	move.b			(a2,d2),d4		; d4 is index to game object A
	move.b			(a2,d3),d5		; d5 is index to game object B
	mulu			#_go_size,d4	; d4 is now byte offset from game object table start to game object A
	mulu			#_go_size,d5	; d5 is now byte offset from game object table start to game object B
	move.l			a3,a4
	move.l			a3,a5
	add.l			d4,a4						; a4 is now the address to game object A
	add.l			d5,a5						; a5 is now the address to game object B
	move.w			_go_world_pos_y(a4),d4		; d4 is now the sort value for game object A
	move.w			_go_world_pos_y(a5),d5		; d5 is now the sort value for game object B

	cmp				d4,d5
	bge.w			.no_swap

	;
	; d4 is greater than d5, so we need to swap the objects
	;
	or.w			#1,d1			; Set the "loop again" flag

	;
	; Swap indices
	;
	move.b			(a2,d2),d4		; d4 is index to game object A
	move.b			(a2,d3),d5		; d5 is index to game object B
	move.b			d5,(a2,d2)
	move.b			d4,(a2,d3)

.no_swap:
	sub.w			#1,d3
	dbra			d2,.compare_loop

	; Did we do any changes this iteration, so we need to check again?
	cmp.w			#0,d1
	bne				.sort_again_loop


	popm			d2-d7/a2-a7
	rts


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
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
