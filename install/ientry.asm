		TITLE	ENTRY - Copyright (C) 1994 SLR Systems

		INCLUDE	MACROS
		INCLUDE	SEGMSYMS

if	fg_segm

		PUBLIC	INSTALL_ENTRY


		.DATA

		EXTERNDEF	ENTRY_STUFF:ALLOCS_STRUCT,ENTRY_GARRAY:STD_PTR_S


		.CODE	PASS2_TEXT

		EXTERNDEF	COMMON_INST_INIT:PROC,ENTRY_POOL_GET:PROC


INIT_ENTRY	PROC
		;
		;
		;
		MOV	EAX,OFF ENTRY_STUFF
		CALL	COMMON_INST_INIT

		MOV	EBX,ENTRY_STUFF.ALLO_HASH_TABLE_PTR
		MOV	EAX,EDI

		JMP	IE_1

INIT_ENTRY	ENDP


INSTALL_ENTRY	PROC
		;
		;DL:AX IS ITEM TO STORE... SEGMENT:OFFSET
		;CX IS ORDINAL #
		;
		;NOW TRASHES SI...
		;
		PUSHM	EDI,ESI

		PUSHM	EBX,ECX

		AND	EDX,0FFH
		MOV	EDI,EAX			;DI=OFFSET

		MOV	ECX,EDX			;CX=SEGMENT
		MOV	EBX,ENTRY_STUFF.ALLO_HASH_TABLE_PTR

		TEST	EBX,EBX
		JZ	INIT_ENTRY
IE_1::
		HASHDIV	ENTRY_STUFF.ALLO_HASH

		MOV	EAX,DPTR [EBX+EDX*4]
		LEA	EBX,[EBX+EDX*4 - ENTRY_STRUCT._ENTRY_NEXT_HASH_GINDEX]
NAME_NEXT:
		TEST	EAX,EAX
		JZ	DO1

		MOV	EDX,EAX
		CONVERT	EAX,EAX,ENTRY_GARRAY
		ASSUME	EAX:PTR ENTRY_STRUCT
		MOV	EBX,EAX
		ASSUME	EBX:PTR ENTRY_STRUCT
		;
		;IS IT A MATCH?
		;
		MOV	ESI,[EAX]._ENTRY_OFFSET
		MOV	EAX,[EAX]._ENTRY_NEXT_HASH_GINDEX

		CMP	ESI,EDI
		JNZ	NAME_NEXT

		CMP	[EBX]._ENTRY_SEGMENT,ECX
		JNZ	NAME_NEXT

		POP	EAX
		MOV	ECX,[EBX]._ENTRY_ORD

		TEST	ECX,ECX
		JNZ	L8$

		MOV	[EBX]._ENTRY_ORD,EAX
L8$:
		CMP	ESP,-1

		MOV	EAX,EDX
		POP	EBX

		POPM	ESI,EDI

		RET

DO1:
		;
		;DS:BX GETS POINTER
		;
		;DI:CX...
		;
		MOV	EDX,EDI
		MOV	EAX,SIZE ENTRY_STRUCT
		CALL	ENTRY_POOL_GET

		MOV	EDI,EBX
		MOV	EBX,EAX
		INSTALL_POINTER_GINDEX	ENTRY_GARRAY

		MOV	[EDI].ENTRY_STRUCT._ENTRY_NEXT_HASH_GINDEX,EAX
		XOR	EDI,EDI

		MOV	[EBX]._ENTRY_OFFSET,EDX
		MOV	[EBX]._ENTRY_NEXT_HASH_GINDEX,EDI

		POP	EDX
		MOV	[EBX]._ENTRY_SEGMENT,ECX

		MOV	[EBX]._ENTRY_ORD,EDX
		POP	EBX

		POPM	ESI,EDI

		RET		;CARRY MUST BE CLEAR

INSTALL_ENTRY	ENDP

endif


		END
