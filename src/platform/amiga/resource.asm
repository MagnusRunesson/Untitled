
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

* struct resourceConfig
* 	word maxNumberOfSlots
* 	word firstFreeSlot
_ResConfig					rsreset
__ResConfigMaxNumberOfSlots	rs.w	1
__ResConfigFirstFreeSlot	rs.w	1
_ResConfigSizeof			rs.b	0

* struct resourceMemPool
* 	long bottomOfMem		; allocations grows from bottom to top
* 	long topOfMem
* 	long firstAvailableMem
_ResMemPool						rsreset
__ResMemPoolBottomOfMem			rs.l	1 ; allocations grows from bottom to top
__ResMemPoolTopOfMem			rs.l	1
__ResMemPoolFirstAvailableMem	rs.l	1
_ResMemPoolSizeof				rs.b	0

* struct resourceSlot
* 	word fileId
* 	long filePtr
_ResSlot					rsreset
__ResSlotFileId				rs.w	1
__ResSlotFilePointer		rs.l	1
_ResSlotSizeof				rs.b	0

* resourceConfig spriteConfig
* resourceSlot spriteSlots[20]
_ResSpriteConfig
	dcb.b					(_ResConfigSizeof)
_ResSpriteSlots
	dcb.b					(_res_sprite_number_of_slots*_ResSlotSizeof)

* resourceConfig spriteBankConfig
* resourceSlot spriteBankSlots[20]
_ResSpriteBankConfig
	dcb.b					(_ResConfigSizeof)
_ResSpriteBankSlots
	dcb.b					(_res_sprite_number_of_slots*_ResSlotSizeof)

* resourceMemPool
_ResSpriteMemPool
	dcb.b					(_ResMemPoolSizeof)


;==============================================================================
;
; Source code file name
;
;==============================================================================

	dc.b	"resource.asm"
	cnop	0,4

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
; Loads resource if neccessary
; Input
;   d0.w=file id
;   a0.l=pointer to resource configuration
;   a1.l=pointer to resoruce slots
;   a2.l=pointer to memory pool
; Output
;   d0.w=resource slot index
;
;==============================================================================

* word resourceLoadFile(word fileId, resConfig config, resSlot[] slotList, resMemPool memPool)
* {
* 	word slotIndex = 0
* 
* 	for (word i=0;i<config.maxNumberOfSlots;i++)
* 	{
* 		if (i==config.firstFreeSlot)
* 		{		
* 			word filePos = fileIdMap[fileId].pos
* 			word fileLen = fileIdMap[fileId].len	
* 			ptr = alloc(memPool,fileLen)
* 			fileLoad(filePos, fileLen, ptr)
* 			slotList[i].filePtr = ptr 
* 			slotList[i].fileId = fileId
* 			config.firstFreeSlot++
* 			slotIndex = i;
* 			goto .exit
* 		}
* 		if (slotList[i].fileId == fileId)
* 		{
* 			slotIndex = i;
* 			goto .exit
* 		}
* 	}
* 	
* 	sysError("no available slots!")
* 
* .exit
* 	return slotIndex
* }

resourceLoadFile
	pushm		d2-d7/a2-a6

	moveq		#0,d6								; loop counter
	move.w		__ResConfigMaxNumberOfSlots(a0),d2
	move.w		__ResConfigFirstFreeSlot(a0),d3
.loop
	cmp.w		d6,d2
	beq			.endOfLoop

	cmp.w		d6,d3
	beq			.firstFreeSlotReached

	move.w		__ResSlotFileId(a1),d4
	cmp.w		d0,d4
	beq.s		.foundExistingResource

	add.l		#_ResSlotSizeof,a1					; point to next slot
	addq		#1,d6
	bra			.loop

.endOfLoop
	move.w		#$0f00,d0
	jmp			sysError(pc)

.firstFreeSlotReached
	addq		#1,d3
	move.w		d3,__ResConfigFirstFreeSlot(a0)

	move.l		__ResMemPoolFirstAvailableMem(a2),a0	; memory pointer for file load

	move.w		d0,__ResSlotFileId(a1)
	move.l		a0,__ResSlotFilePointer(a1)

	move.l		a0,d7	; memory pointer for file load

	bsr			fileLoad

	move.l		d7,d2	; memory pointer for file load

	add.l		d0,d2	; next memory pointer for file load
	;add.l		#1024*300,d2

	move.l		__ResMemPoolTopOfMem(a2),d3	; memory pointer for file load

	cmp.l		d3,d2
	bgt			.outOfMemory

	move.l		d2,__ResMemPoolFirstAvailableMem(a2)

	move.l		d6,d0

	bra			.exit

.foundExistingResource
	move.w		d6,d0

.exit
	popm		d2-d7/a2-a6
	rts

.outOfMemory
	move.w		#$0f0f,d0
	jmp			sysError(pc)

;==============================================================================
;
; Get pointer to resource by slot index
; Input
;   d0.w=resource slot index
;   a0.l=pointer to resource slots
; Output
;   a0.l=pointer to resource
;
;==============================================================================

* long resourceGetBySlotIndex(word slotIndex, resourceSlot[] slotList)
* {
* 	long ptr = slotList + slotIndex * sizeof(resourceSlot)
* 	return ptr
* }

resourceGetBySlotIndex
	mulu		#_ResSlotSizeof,d0
	lea			(a0,d0.l),a0
	move.l		__ResSlotFilePointer(a0),a0
	rts

;==============================================================================
;
; Wrappers for Sprite Bank
; Input
;   d0.w=resource slot index
;
;==============================================================================

resourceLoadSpriteBank
	push		a2
	lea			_ResSpriteBankConfig(pc),a0
	lea			_ResSpriteBankSlots(pc),a1
	lea			_ResSpriteMemPool(pc),a2
	bsr			resourceLoadFile
	pop			a2
	rts

resourceGetSpriteBank
	lea			_ResSpriteBankSlots(pc),a0
	bsr			resourceGetBySlotIndex
	rts

;==============================================================================
;
; Wrappers for Sprite
; Input
;   d0.w=resource slot index
;
;==============================================================================

resourceLoadSprite
	lea			_ResSpriteConfig(pc),a0
	lea			_ResSpriteSlots(pc),a1
	lea			_ResSpriteMemPool(pc),a2
	bsr			resourceLoadFile
	rts

resourceGetSprite
	lea			_ResSpriteSlots(pc),a0
	bsr			resourceGetBySlotIndex
	rts

