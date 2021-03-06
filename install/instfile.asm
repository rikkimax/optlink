		TITLE	FILE_INSTALLS - Copyright (C) 1994 SLR Systems

		INCLUDE	MACROS
		INCLUDE	IO_STRUC

		PUBLIC	FILENAME_INSTALL


		.DATA

		EXTERNDEF	FILE_HASH_MOD:DWORD,FILENAME_HASH:DWORD,FILENAME_HASH_TABLE_PTR:DWORD

		EXTERNDEF	_FILE_LIST_GARRAY:STD_PTR_S


		.CODE	FILEPARSE_TEXT

		EXTERNDEF	_move_nfn:proc,OPTI_HASH_IGNORE:PROC,CASE_STRING_COMPARE_HARD:PROC

; _filename_install(NFN_STRUCT *EAX, FILE_LIST_STRUCT **pECX)

		public _filename_install
_filename_install proc
		mov	EAX,4[ESP]
		call	FILENAME_INSTALL
		mov	EDX,8[ESP]
		mov	[EDX],ECX
		ret
_filename_install endp

FILENAME_INSTALL PROC
		;
		;EAX IS NFN_STRUCT
		;
		;RETURNS ECX IS SYMBOL ADDRESS, EAX IS GINDEX
		;
		PUSHM	EDI,ESI,EBX
		CALL	FS_1
		JC	FILE_DO_INSTALL
		POPM	EBX,ESI,EDI
		RET


FILE_DO_INSTALL:
		;
		;ECX GETS POINTER...
		;EAX IS NFN_STRUCT
		;
		ASSUME	EAX:PTR NFN_STRUCT
		PUSH	EAX
		MOV	EAX,[EAX].NFN_TOTAL_LENGTH
		ASSUME	EAX:NOTHING

		MOV	EDX,EDI			;SAVE HASH
		ADD	EAX,FILE_LIST_STRUCT.FILE_LIST_NFN.NFN_TEXT+1
		TEXT_POOL_ALLOC			;EAX IS PHYS
		MOV	ESI,ECX
		MOV	EDI,EAX
		MOV	EBX,EAX
		ASSUME	EBX:PTR FILE_LIST_STRUCT,ESI:PTR FILE_LIST_STRUCT

		INSTALL_POINTER_GINDEX	_FILE_LIST_GARRAY

		MOV	[ESI].FILE_LIST_HASH_NEXT_GINDEX,EAX

		MOV	ESI,EAX			;SAVE GINDEX
		MOV	ECX,FILE_LIST_STRUCT.FILE_LIST_NFN/4
		XOR	EAX,EAX
		REP	STOSD
		MOV	[EBX].FILE_LIST_HASH,EDX;STORE HASH
		POP	ECX
		MOV	EAX,EDI
		MOV	EDI,EBX

		push	ECX
		push	EAX
		call	_move_nfn	; ECX to EAX
		add	ESP,8

		POP	EBX
		MOV	EAX,ESI
		MOV	ECX,EDI
		POPM	ESI,EDI
		RET

FILENAME_INSTALL	ENDP


FS_1		PROC	NEAR
		;
		;EAX IS NFN STRUCTURE, SEE IF A MATCHING FILE_LIST ENTRY EXISTS
		;
		ASSUME	EAX:PTR NFN_STRUCT
		PUSH	EAX
		LEA	ESI,[EAX].NFN_TEXT
		MOV	EAX,[EAX].NFN_TOTAL_LENGTH
		ASSUME	EAX:NOTHING

		PUSH	ESI
		CALL	OPTI_HASH_IGNORE		;CALCULATE HASH
		;
		;EDX IS HASH VALUE, CONVERT IT
		;
		MOV	EAX,FILE_HASH_MOD		;HASH MODIFIER FOR PATHS, LIBS, ETC
		MOV	EBX,FILENAME_HASH_TABLE_PTR
		ADD	EAX,EDX
		XOR	EDX,EDX
		MOV	EDI,EAX
		HASHDIV	FILENAME_HASH			;EDX IS HASH VALUE
		MOV	EAX,DPTR [EBX+EDX*4]
		LEA	EBX,[EBX+EDX*4 - FILE_LIST_STRUCT.FILE_LIST_HASH_NEXT_GINDEX]
NAME_NEXT:
		TEST	EAX,EAX
		JZ	DO1
		MOV	EDX,EAX
		CONVERT	EBX,EAX,_FILE_LIST_GARRAY
		;
		;CHECK HASH VALUE
		;
		MOV	ECX,[EBX].FILE_LIST_HASH
		MOV	EAX,[EBX].FILE_LIST_HASH_NEXT_GINDEX
		CMP	ECX,EDI
		JNZ	NAME_NEXT
NAME_PROB:	;
		;PROBABLE MATCH, NEED COMPARE...
		;
		MOV	EAX,EDI			;SAVE HASH
		POP	EDI			;FILE_LIST_TEXT
		MOV	ECX,[EBX].FILE_LIST_NFN.NFN_TOTAL_LENGTH
		PUSH	EDI
		CMP	ECX,[EDI-4]		;LENGTH SAME?
		JNZ	L88$
		LEA	ESI,[EBX].FILE_LIST_NFN.NFN_TEXT

		PUSH	EAX
		CALL	CASE_STRING_COMPARE_HARD
		POP	EAX
		JZ	L9$
L88$:
		MOV	EDI,EAX
		MOV	EAX,[EBX].FILE_LIST_HASH_NEXT_GINDEX
		JMP	NAME_NEXT

L9$:
		POPM	EDI,EAX
		MOV	ECX,EBX
		MOV	EAX,EDX
		RET

DO1:
		POPM	ESI,EAX
		MOV	ECX,EBX
		STC
		RET

FS_1		ENDP


		END

