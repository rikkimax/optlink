		TITLE	ALLOC - Copyright (c) SLR Systems 1994

		INCLUDE MACROS
if	fgh_win32
		INCLUDE	WIN32DEF
endif

		PUBLIC	CONVERT_SUBBX_TO_EAX_NOZERO,RELEASE_BLOCK,GET_NEW_LOG_BLK,CONVERT_SUBBX_TO_EAX
		PUBLIC	RELEASE_SEGMENT,GET_NEW_IO_LOG_BLK,CONVERT_SUBBX_TO_EAX_NOZERO_IO,RELEASE_IO_SEGMENT
		PUBLIC	RELEASE_IO_BLOCK


		.DATA

		EXTERNDEF	GLOBAL_BLOCKS:BYTE

		EXTERNDEF	ERR_TABLE:DWORD
		EXTERNDEF	NUMBLKS:DWORD
		EXTERNDEF	PHYS_TABLE:DWORD
		EXTERNDEF	PHYS_BEG_FREELIST:DWORD
		EXTERNDEF	PHYS_END_FREELIST:DWORD
		EXTERNDEF	PHYS_PREV_BLOCK:DWORD,PHYS_NEXT_BLOCK:DWORD,SLR_PREV_SEG:DWORD,OPTI_STOSD_SIZE:DWORD
		EXTERNDEF	ALLOCATED_BLOCKS:DWORD,ALLOCATED_IO_BLOCKS:DWORD,PHYS_IO_TEMP:DWORD,SLR_STRUCT_BASE:DWORD
		EXTERNDEF	PHYS_STUFF:DWORD,SLRBUF_PTR:DWORD,BLOCK_NEXT:DWORD,PHYS_TABLE_ENTRIES:DWORD
		EXTERNDEF	SLR_DICTIONARY_BASE:DWORD

		EXTERNDEF	OOM_ERROR_SEM:QWORD,GLOBALALLOC_SEM:GLOBALSEM_STRUCT


		.CODE	ROOT_TEXT

		EXTERNDEF	_seg_released:proc
		EXTERNDEF	_capture_eax:proc
		EXTERNDEF	_release_eax:proc
		EXTERNDEF	_release_eax_bump:proc
		EXTERNDEF	_err_abort:proc,DO_DOSSEMREQUEST_AX:PROC,DO_DOSSEMCLEAR_AX:PROC
		EXTERNDEF	WARN_RET:PROC,RELEASE_64K_SEGMENT:PROC,_disable_mapout:proc,CAPTURE_EAX:PROC,RELEASE_EAX:PROC
		EXTERNDEF	_release_large_segment:proc
		externdef	_oom_error:proc;
		externdef	_sbrk:proc;
		externdef	_get_new_phys_blk:proc;
		externdef	_get_4k_segment:proc
		externdef	_release_4k_segment:proc
		externdef	_release_block:proc

		EXTERNDEF	OOM_ERR:ABS,SEG_ALREADY_RELEASED_ERR:ABS



GET_NEW_PHYS_BLK	PROC
	push	ECX
	push	EDX
	call	_get_new_phys_blk
	pop	EDX
	pop	ECX
	ret
GET_NEW_PHYS_BLK	ENDP


GET_NEW_LOG_BLK		EQU	(GET_NEW_PHYS_BLK)
GET_NEW_IO_LOG_BLK	EQU	(GET_NEW_LOG_BLK)


; save ECX
RELEASE_BLOCK	PROC
	push	ECX
	push	EDX
	push	EAX
	call	_release_block
	add	ESP,4
	pop	EDX
	pop	ECX
	ret
RELEASE_BLOCK	ENDP


RELEASE_SEGMENT		EQU	(RELEASE_BLOCK)
RELEASE_IO_BLOCK	EQU	(RELEASE_BLOCK)
RELEASE_IO_SEGMENT	EQU	(RELEASE_SEGMENT)

;OOM_ERROR:
;		jmp	_oom_error

CONVERT_SUBBX_TO_EAX	PROC
		;
;		MOV	EAX,[ESP]
		MOV	EAX,[EBX]

		OR	EAX,EAX			;DOES BLOCK EXIST?
		JZ	CSTE_1			;NOPE, GO GET ONE

		RET

CSTE_1:
		push	ECX
		push	EDX
		call	_get_new_phys_blk
		pop	EDX
		pop	ECX
;		CALL	GET_NEW_LOG_BLK

		MOV	[EBX],EAX
		PUSHM	EDI,ECX,EAX

		MOV	EDI,EAX
		XOR	EAX,EAX

		MOV	ECX,OPTI_STOSD_SIZE
		OPTI_STOSD			;ZERO THE BLOCK...
		POPM	EAX,ECX,EDI
		RET

CONVERT_SUBBX_TO_EAX	ENDP


CONVERT_SUBBX_TO_EAX_NOZERO	PROC
		;
		MOV	EAX,[EBX]

		OR	EAX,EAX			;DOES BLOCK EXIST?
		JZ	CSTENZ_1		;NOPE, GO GET ONE

		RET

CSTENZ_1:
		push	ECX
		push	EDX
		call	_get_new_phys_blk
		pop	EDX
		pop	ECX
;		CALL	GET_NEW_LOG_BLK

		MOV	[EBX],EAX

		RET

CONVERT_SUBBX_TO_EAX_NOZERO	ENDP


CONVERT_SUBBX_TO_EAX_NOZERO_IO	PROC
		;
		MOV	EAX,[EBX]

		OR	EAX,EAX			;DOES BLOCK EXIST?
		JZ	L1$			;NOPE, GO GET ONE

		RET

L1$:
		push	ECX
		push	EDX
		call	_get_new_phys_blk
		pop	EDX
		pop	ECX
		;CALL	GET_NEW_IO_LOG_BLK

		MOV	[EBX],EAX

		RET

CONVERT_SUBBX_TO_EAX_NOZERO_IO	ENDP


		END
