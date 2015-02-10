;==============================================================================
;
; Amiga chunk size matches TD_SECTOR (size of sector on floppy)
;
;==============================================================================
_chunk_size			equ		TD_SECTOR			

;==============================================================================
;
; Amiga specific consts
;
;==============================================================================

_custom				equ 	$dff000

_ciaa				equ		$bfe001
_ciab				equ		$bfd000

_interrupt_vec_1	equ		$64
_interrupt_vec_2	equ		$68
_interrupt_vec_3	equ		$6c	
_interrupt_vec_4	equ		$70
_interrupt_vec_5	equ		$74
_interrupt_vec_6	equ		$78
_interrupt_vec_7	equ		$7C

_interrupt_vec_copper	equ		_interrupt_vec_3