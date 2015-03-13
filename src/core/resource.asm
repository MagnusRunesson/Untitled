;==============================================================================
;
; Structures
;
;==============================================================================


_ResConfig					rsreset
__ResConfigMaxNumberOfSlots	rs.w	1
__ResConfigFirstFreeSlot	rs.w	1
_ResConfigSizeof			rs.b	0

_ResMemPool						rsreset
__ResMemPoolBottomOfMem			rs.l	1 ; allocations grows from bottom to top
__ResMemPoolTopOfMem			rs.l	1
__ResMemPoolFirstAvailableMem	rs.l	1
_ResMemPoolSizeof				rs.b	0


_ResSlot					rsreset
__ResSlotFileId				rs.w	1
__ResSlotFilePointer		rs.l	1
_ResSlotSizeof				rs.b	0




;==============================================================================
;
; Initialize resource
;
;==============================================================================

; Initialization contains no platform independant initialization. This is 
; therefore handled by the platform specific resource.asm file. 


;==============================================================================
;
; Loads resource if neccessary
; Input
;   d0.w=file id
;   a0.l=pointer to resource configuration
;   a1.l=pointer to resoruce slots
;   a2.l=pointer to memory pool
; Output
;   a0.l=pointer to dynamic resource
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

resourceLoadDynamicFile
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
	moveq		#0,d0								; todo: error code
	move.w		#$0f00,d1
	jmp			errorScreen(pc)

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

	move.l		__ResMemPoolTopOfMem(a2),d3	; memory pointer for file load

	cmp.l		d3,d2
	bgt			.outOfMemory

	move.l		d2,__ResMemPoolFirstAvailableMem(a2)

	move.l		d7,a0
	bra			.exit

.foundExistingResource
	move.l		__ResSlotFilePointer(a1),a0	

.exit
	popm		d2-d7/a2-a6
	rts

.outOfMemory
	moveq		#0,d0								; todo: error code
	move.w		#$0f0f,d1
	jmp			errorScreen(pc)

;==============================================================================
;
; Loads static resource 
; Input
;   d0.w=file id
; Output
;   a0.l=pointer to static resource
;
;==============================================================================


resourceLoadStaticFile
	pushm		d1-d7/a1-a6

	moveq		#0,d1
	move.w		d0,d1
	asl.l		#2,d1
		
	lea			FileIDMap(pc),a0
	add.l		d1,a0
	move.w		(a0)+,d5
	btst		#15,d5
	beq			.isDynamicResource

.isStaticResource
	swap.w		d5
	move.w		(a0),d5
	and.l		#$7fffffff,d5
	lea			StaticData(pc),a0
	add.l		d5,a0	

	popm		d1-d7/a1-a6
	rts

.isDynamicResource
	moveq		#0,d0								; todo: error code
	move.w		#$0f0f,d1
	jmp			errorScreen(pc)

;==============================================================================
;
; Reset resource memory pool and config
; Input
;   a0.l=pointer to resource configuration
;   a1.l=pointer to memory pool
;
;==============================================================================

resourceReset
	move.w		#0,__ResConfigFirstFreeSlot(a0)
	move.l		__ResMemPoolBottomOfMem(a1),__ResMemPoolFirstAvailableMem(a1)
	rts
