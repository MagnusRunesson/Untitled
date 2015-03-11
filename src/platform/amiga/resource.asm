
;==============================================================================
;
; Constants
;
;==============================================================================

_res_sprite_number_of_slots	equ		(20)


;==============================================================================
;
; Structures
;
;==============================================================================

_ResSpriteConfig
	dcb.b					(_ResConfigSizeof)
_ResSpriteSlots
	dcb.b					(_res_sprite_number_of_slots*_ResSlotSizeof)

_ResSpriteBankConfig
	dcb.b					(_ResConfigSizeof)
_ResSpriteBankSlots
	dcb.b					(_res_sprite_number_of_slots*_ResSlotSizeof)

_ResSpriteMemPool
	dcb.b					(_ResMemPoolSizeof)


;==============================================================================
;
; Initialize resource
;
;==============================================================================
	
resourceInit:
	
	; Sprite mem pool
	lea			_ResSpriteMemPool(pc),a0
	_get_workmem_ptr SpriteFileMem,a1
	_get_workmem_ptr SpriteFileMemEnd,a2
	move.l		a1,__ResMemPoolBottomOfMem(a0)
	move.l		a1,__ResMemPoolFirstAvailableMem(a0)
	move.l		a2,__ResMemPoolTopOfMem(a0)

	; Sprite config
	lea			_ResSpriteConfig(pc),a0
	move.w		#_res_sprite_number_of_slots,__ResConfigMaxNumberOfSlots(a0)
	move.w		#0,__ResConfigFirstFreeSlot(a0)

	; Sprite bank config
	lea			_ResSpriteBankConfig(pc),a0
	move.w		#_res_sprite_number_of_slots,__ResConfigMaxNumberOfSlots(a0)
	move.w		#0,__ResConfigFirstFreeSlot(a0)

	rts


;==============================================================================
;
; Wrappers for Sprite Bank
; Input
;   d0.w=resource slot index
; Output
;   a0.l=pointer to resource
;
;==============================================================================

resourceLoadSpriteBank
	push		a2
	lea			_ResSpriteBankConfig(pc),a0
	lea			_ResSpriteBankSlots(pc),a1
	lea			_ResSpriteMemPool(pc),a2
	bsr			resourceLoadDynamicFile
	pop			a2
	rts

;==============================================================================
;
; Wrappers for Sprite
; Input
;   d0.w=resource slot index
; Output
;   a0.l=pointer to resource
;
;==============================================================================

resourceLoadSprite
	push		a2
	lea			_ResSpriteConfig(pc),a0
	lea			_ResSpriteSlots(pc),a1
	lea			_ResSpriteMemPool(pc),a2
	bsr			resourceLoadDynamicFile
	pop			a2
	rts

;==============================================================================
;
; Wrapper for goc
; Input
;   d0.w=resource slot index
; Output
;   a0.l=pointer to resource
;
;==============================================================================

resourceLoadGoc
	bsr			resourceLoadStaticFile
	rts

