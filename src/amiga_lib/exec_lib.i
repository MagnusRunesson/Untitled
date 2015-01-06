	ifnd _exec_lib_i_

_exec_lib_i_


;------ misc ---------------------------------------------------------
_LVOSupervisor equ -$1e

;------ special patchable hooks to internal exec activity ------------
;------ module creation ----------------------------------------------
_LVOInitCode equ -$48 
_LVOInitStruct equ -$4e 
_LVOMakeLibrary equ -$54 
_LVOMakeFunctions equ -$5a 
_LVOFindResident equ -$60 
_LVOInitResident equ -$66 

;------ diagnostics --------------------------------------------------
_LVOAlert equ -$6c 
_LVODebug equ -$72 

;------ interrupts ---------------------------------------------------
_LVODisable equ -$78 
_LVOEnable equ -$7e 
_LVOForbid equ -$84 
_LVOPermit equ -$8a 
_LVOSetSR equ -$90 
_LVOSuperState equ -$96 
_LVOUserState equ -$9c 
_LVOSetIntVector equ -$a2 
_LVOAddIntServer equ -$a8 
_LVORemIntServer equ -$ae 
_LVOCause equ -$b4 

;------ memory allocation --------------------------------------------
_LVOAllocate equ -$ba 
_LVODeallocate equ -$c0 
_LVOAllocMem equ -$c6 
_LVOAllocAbs equ -$cc 
_LVOFreeMem equ -$d2 
_LVOAvailMem equ -$d8 
_LVOAllocEntry equ -$de 
_LVOFreeEntry equ -$e4 

;------ lists --------------------------------------------------------

_LVOInsert equ -$ea 
_LVOAddHead equ -$f0 
_LVOAddTail equ -$f6 
_LVORemove equ -$fc 
_LVORemHead equ -$102 
_LVORemTail equ -$108 
_LVOEnqueue equ -$10e 
_LVOFindName equ -$114 

;------ tasks --------------------------------------------------------

_LVOAddTask equ -$11a 
_LVORemTask equ -$120 
_LVOFindTask equ -$126 
_LVOSetTaskPri equ -$12c 
_LVOSetSignal equ -$132 
_LVOSetExcept equ -$138 
_LVOWait equ -$13e 
_LVOSignal equ -$144 
_LVOAllocSignal equ -$14a 
_LVOFreeSignal equ -$150 
_LVOAllocTrap equ -$156 
_LVOFreeTrap equ -$15c 

;------ messages -----------------------------------------------------

_LVOAddPort equ -$162 
_LVORemPort equ -$168 
_LVOPutMsg equ -$16e 
_LVOGetMsg equ -$174 
_LVOReplyMsg equ -$17a 
_LVOWaitPort equ -$180 
_LVOFindPort equ -$186 

;------ libraries ----------------------------------------------------

_LVOAddLibrary equ -$18c 
_LVORemLibrary equ -$192 
_LVOOldOpenLibrary equ -$198 
_LVOCloseLibrary equ -$19e 
_LVOSetFunction equ -$1a4 
_LVOSumLibrary equ -$1aa 

;------ devices ------------------------------------------------------

_LVOAddDevice equ -$1b0 
_LVORemDevice equ -$1b6 
_LVOOpenDevice equ -$1bc 
_LVOCloseDevice equ -$1c2 
_LVODoIO equ -$1c8 
_LVOSendIO equ -$1ce 
_LVOCheckIO equ -$1d4 
_LVOWaitIO equ -$1da 
_LVOAbortIO equ -$1e0 

;------ resources ----------------------------------------------------

_LVOAddResource equ -$1e6 
_LVORemResource equ -$1ec 
_LVOOpenResource equ -$1f2 

;------ private diagnostic support -----------------------------------
;------ misc ---------------------------------------------------------

_LVORawDoFmt equ -$20a 
_LVOGetCC equ -$210 
_LVOTypeOfMem equ -$216 
_LVOProcure equ -$21c 
_LVOVacate equ -$222 
_LVOOpenLibrary equ -$228 

;--- functions in V33 or higher (Release 1.2) ---
;------ signal semaphores (note funny registers)----------------------

_LVOInitSemaphore equ -$22e 
_LVOObtainSemaphore equ -$234 
_LVOReleaseSemaphore equ -$23a 
_LVOAttemptSemaphore equ -$240 
_LVOObtainSemaphoreList equ -$246 
_LVOReleaseSemaphoreList equ -$24c 
_LVOFindSemaphore equ -$252 
_LVOAddSemaphore equ -$258 
_LVORemSemaphore equ -$25e 

;------ kickmem support ----------------------------------------------

_LVOSumKickData equ -$264 

;------ more memory support ------------------------------------------

_LVOAddMemList equ -$26a 
_LVOCopyMem equ -$270 
_LVOCopyMemQuick equ -$276 

;------ cache --------------------------------------------------------
;--- functions in V36 or higher (Release 2.0) ---

_LVOCacheClearU equ -$27c 
_LVOCacheClearE equ -$282 
_LVOCacheControl equ -$288 

;------ misc ---------------------------------------------------------

_LVOCreateIORequest equ -$28e 
_LVODeleteIORequest equ -$294 
_LVOCreateMsgPort equ -$29a 
_LVODeleteMsgPort equ -$2a0 
_LVOObtainSemaphoreShared equ -$2a6 

;------ even more memory support -------------------------------------

_LVOAllocVec equ -$2ac 
_LVOFreeVec equ -$2b2 

;------ V39 Pool LVOs...
_LVOCreatePool equ -$2b8 
_LVODeletePool equ -$2be 
_LVOAllocPooled equ -$2c4 
_LVOFreePooled equ -$2ca 

;------ misc ---------------------------------------------------------

_LVOAttemptSemaphoreShared equ -$2d0 
_LVOColdReboot equ -$2d6 
_LVOStackSwap equ -$2dc 

;------ future expansion ---------------------------------------------

_LVOCachePreDMA equ -$2fa 
_LVOCachePostDMA equ -$300 

;------ New, for V39
;--- functions in V39 or higher (Release 3) ---
;------ Low memory handler functions

_LVOAddMemHandler equ -$306 
_LVORemMemHandler equ -$30c 

;------ Function to attempt to obtain a Quick Interrupt Vector...

_LVOObtainQuickVector equ -$312 

;--- functions in V45 or higher ---
;------ Finally the list functions are complete

_LVONewMinList equ -$33c 

;------ New AVL tree support for V45. Yes, this is intentionally part of Exec!

_LVOAVL_AddNode equ -$354 
_LVOAVL_RemNodeByAddress equ -$35a 
_LVOAVL_RemNodeByKey equ -$360 
_LVOAVL_FindNode equ -$366 
_LVOAVL_FindPrevNodeByAddress equ -$36c 
_LVOAVL_FindPrevNodeByKey equ -$372 
_LVOAVL_FindNextNodeByAddress equ -$378 
_LVOAVL_FindNextNodeByKey equ -$37e 
_LVOAVL_FindFirstNode equ -$384 
_LVOAVL_FindLastNode equ -$38a 

;--- (10 function slots reserved here) ---

	endif