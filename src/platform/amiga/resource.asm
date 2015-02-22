
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

	rts


* word resourceLoadFile(word fileId, resConfig config, resSlot[] slotList, resMemPool memPool)
* {
* 	word slotIndex = 0
* 	word filePos = fileIdMap[fileId].pos
* 	word fileLen = fileIdMap[fileId].len
* 	
* 
* 	for (word i=0;i<config.maxNumberOfSlots;i++)
* 	{
* 		if (i==config.firstFreeSlot)
* 		{			
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
* 

;==============================================================================
;
; Get pointer to resource by slot index
; Input
;   d0=slot index
;   a0=pointer to slots
; Output
;   a0=pointer to resource
;
;==============================================================================

* long resourceGetBySlotIndex(word slotIndex, resourceSlot[] slotList)
* {
* 	long ptr = slotList + slotIndex * sizeof(resourceSlot)
* 	return ptr
* }

resourceGetBySlotIndex
	mulu	#_ResSlotSizeof,d0
	lea		(a0,d0.l),a0

	rts


