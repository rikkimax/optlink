		TITLE	CVFILALL - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS

if	fg_cvpack

		INCLUDE	MODULES
		INCLUDE	CVSTUFF

		PUBLIC	CV_FILES_ALL_4


		.DATA

		EXTERNDEF	CV_TEMP_RECORD:BYTE

		EXTERNDEF	CURNMOD_NUMBER:DWORD,CURNMOD_NUMBER:DWORD,BYTES_SO_FAR:DWORD,FINAL_HIGH_WATER:DWORD,SRC_COUNT:DWORD
		EXTERNDEF	FIRST_MODULE_GINDEX:DWORD,MODULE_COUNT:DWORD,FIRST_RELOC_GINDEX:DWORD,LAST_RELOC_GINDEX:DWORD

		EXTERNDEF	MODULE_GARRAY:STD_PTR_S,SRC_GARRAY:STD_PTR_S,MDB_GARRAY:STD_PTR_S,RELOC_GARRAY:STD_PTR_S
		EXTERNDEF	RELOC_STUFF:ALLOCS_STRUCT

		EXTERNDEF	CV_DWORD_ALIGN:DWORD


		.CODE	CVPACK_TEXT

		EXTERNDEF	MOVE_EAX_TO_FINAL_HIGH_WATER:PROC,HANDLE_CV_INDEX:PROC
		EXTERNDEF	_release_minidata:proc,RELEASE_GARRAY:PROC,GET_NEW_LOG_BLK:PROC,MOVE_EAX_TO_EDX_FINAL:PROC
		EXTERNDEF	RELEASE_BLOCK:PROC,INSTALL_FILEINDEX_SPACE:PROC,SAY_VERBOSE:PROC,MOVE_ASCIZ_ESI_EDI:PROC


CVT_MODSTART_BUFSIZE	EQU	64
CVT_REFCNT_BUFSIZE	EQU	64
CVT_NAMEREF_BUFSIZE	EQU	256


CVFIL_VARS	STRUC

CVT_MODSTART_BUFFER_BP	DB	CVT_MODSTART_BUFSIZE DUP(?)
CVT_REFCNT_BUFFER_BP	DB	CVT_REFCNT_BUFSIZE DUP(?)
CVT_NAMEREF_BUFFER_BP	DB	CVT_NAMEREF_BUFSIZE DUP(?)
CVT_SECTION_OFFSET_BP	DD	?	;
CVT_MODSTART_FINAL_BP	DD	?	;
CVT_REFCNT_FINAL_BP	DD	?	;
CVT_NAMEREF_FINAL_BP	DD	?	;
CVT_NAMES_FINAL_BP	DD	?	;
;CVT_NAMES_OFFSET_BP	DD	?	;
CVT_MODSTART_PUT_PTR_BP	DD	?
CVT_MODSTART_LIMIT_BP	DD	?
CVT_REFCNT_PUT_PTR_BP	DD	?
CVT_REFCNT_LIMIT_BP	DD	?
CVT_NAMEREF_PUT_PTR_BP	DD	?
CVT_NAMEREF_LIMIT_BP	DD	?
;CVT_NAMES_PUT_PTR_BP	DD	?
;CVT_NAMES_LIMIT_BP	DD	?

CVFIL_VARS	ENDS


FIX	MACRO	X

X	EQU	([EBP-SIZE CVFIL_VARS].(X&_BP))

	ENDM


FIX	CVT_MODSTART_BUFFER
FIX	CVT_REFCNT_BUFFER
FIX	CVT_NAMEREF_BUFFER
FIX	CVT_SECTION_OFFSET
FIX	CVT_MODSTART_FINAL
FIX	CVT_REFCNT_FINAL
FIX	CVT_NAMEREF_FINAL
FIX	CVT_NAMES_FINAL
FIX	CVT_NAMES_OFFSET
FIX	CVT_MODSTART_PUT_PTR
FIX	CVT_MODSTART_LIMIT
FIX	CVT_REFCNT_PUT_PTR
FIX	CVT_REFCNT_LIMIT
FIX	CVT_NAMEREF_PUT_PTR
FIX	CVT_NAMEREF_LIMIT
FIX	CVT_NAMES_PUT_PTR
FIX	CVT_NAMES_LIMIT


CV_FILES_ALL_4	PROC
		;
		;OUTPUT SSTFILEINDEX TABLE
		;
		MOV	EAX,SRC_COUNT

		TEST	EAX,EAX
		JNZ	L0$

		RET

L0$:
		MOV	EAX,OFF DOING_SSTFILEINDEX_MSG
		CALL	SAY_VERBOSE
		;
		;INITIALIZE STUFF
		;
		CALL	CV_DWORD_ALIGN

		PUSHM	EDI,ESI,EBX,EBP

		MOV	EBP,ESP
		SUB	ESP,SIZE CVFIL_VARS
		ASSUME	EBP:PTR CVFIL_VARS

		MOV	EDX,BYTES_SO_FAR		;STORE ADDRESS FOR SSTGLOBALTYPES INDEX LATER
		MOV	EAX,OFF CV_TEMP_RECORD

		MOV	EBX,SRC_COUNT
		MOV	CVT_SECTION_OFFSET,EDX

		SHL	EBX,16
		MOV	ECX,MODULE_COUNT

		ADD	EBX,ECX
		MOV	ECX,4

		MOV	[EAX],EBX
		ADD	EDX,ECX

		MOV	BYTES_SO_FAR,EDX
		CALL	MOVE_EAX_TO_FINAL_HIGH_WATER

		MOV	EBX,MODULE_COUNT
		MOV	EAX,FINAL_HIGH_WATER		;PLACE TO WRITE BUFFERED TYPE INDEXES

		ADD	EBX,EBX
		MOV	CVT_MODSTART_FINAL,EAX

		ADD	EAX,EBX
		MOV	ECX,SRC_COUNT

		MOV	CVT_REFCNT_FINAL,EAX
		ADD	EAX,EBX

		SHL	ECX,2
		MOV	CVT_NAMEREF_FINAL,EAX

		ADD	EAX,ECX
		LEA	EBX,CVT_MODSTART_BUFFER

		MOV	CVT_NAMES_FINAL,EAX
		MOV	CVT_MODSTART_PUT_PTR,EBX

		ADD	EBX,CVT_MODSTART_BUFSIZE
		LEA	EAX,CVT_REFCNT_BUFFER

		MOV	CVT_MODSTART_LIMIT,EBX
		MOV	CVT_REFCNT_PUT_PTR,EAX

		LEA	EBX,CVT_NAMEREF_BUFFER
		ADD	EAX,CVT_REFCNT_BUFSIZE


		MOV	CVT_NAMEREF_PUT_PTR,EBX
		MOV	CVT_REFCNT_LIMIT,EAX

		ADD	EBX,CVT_NAMEREF_BUFSIZE

		MOV	CVT_NAMEREF_LIMIT,EBX
		MOV	EBX,FIRST_MODULE_GINDEX
L1$:
		CONVERT	EBX,EBX,MODULE_GARRAY
		ASSUME	EBX:PTR MODULE_STRUCT

		MOV	AL,[EBX]._M_FLAGS
		MOV	ESI,[EBX]._M_MDB_GINDEX

		TEST	AL,MASK M_SRCS_PRESENT
		JZ	L5$

		TEST	ESI,ESI
		JZ	L5$

		CONVERT	ESI,ESI,MDB_GARRAY
		ASSUME	ESI:PTR MDB_STRUCT

		MOV	EAX,[ESI]._MD_SRC_COUNT
		MOV	EDI,[ESI]._MD_FIRST_SRC_GINDEX

		CALL	STORE_REFCNT

		CONVERT	EDI,EDI,SRC_GARRAY
		ASSUME	EDI:PTR SRC_STRUCT

		MOV	EAX,[EDI]._SRC_NUMBER

		DEC	EAX
		CALL	STORE_MODSTART_GINDEX

		MOV	EDI,[ESI]._MD_SRC_COUNT
		MOV	ESI,[ESI]._MD_FIRST_SRC_GINDEX
L2$:
		CONVERT	ESI,ESI,SRC_GARRAY
		ASSUME	ESI:PTR SRC_STRUCT

		MOV	EAX,[ESI]._SRC_HASH
		LEA	ECX,[ESI]._SRC_TEXT

		MOV	ESI,[ESI]._SRC_NEXT_GINDEX
		CALL	INSTALL_FILEINDEX_SPACE

		CALL	STORE_NAMEREF_ADDRESS

		DEC	EDI
		JNZ	L2$

		JMP	L6$

L5$:
		XOR	EAX,EAX
		CALL	STORE_MODSTART_GINDEX

		XOR	EAX,EAX
		CALL	STORE_REFCNT
L6$:
		MOV	EBX,[EBX]._M_NEXT_MODULE_GINDEX

		TEST	EBX,EBX
		JNZ	L1$

		CALL	FLUSH_MODSTART_BUFFER

		CALL	FLUSH_REFCNT_BUFFER

		CALL	FLUSH_NAMEREF_BUFFER

		CALL	FLUSH_NAMES_BUFFER

		MOV	EAX,CVT_SECTION_OFFSET
		MOV	ESP,EBP

		MOV	CURNMOD_NUMBER,-1

		POPM	EBP,EBX,ESI,EDI

		MOV	ECX,0133H
		JMP	HANDLE_CV_INDEX		;BACKWARDS

CV_FILES_ALL_4	ENDP


STORE_MODSTART_GINDEX	PROC	NEAR
		;
		;
		;
		MOV	EDX,CVT_MODSTART_PUT_PTR
		MOV	ECX,CVT_MODSTART_LIMIT

		MOV	WPTR [EDX],AX
		ADD	EDX,2

		MOV	CVT_MODSTART_PUT_PTR,EDX
		CMP	EDX,ECX

		JZ	FLUSH_MODSTART_BUFFER

		RET

STORE_MODSTART_GINDEX	ENDP


FLUSH_MODSTART_BUFFER	PROC	NEAR
		;
		;
		;
		MOV	ECX,CVT_MODSTART_PUT_PTR
		LEA	EAX,CVT_MODSTART_BUFFER

		SUB	ECX,EAX
		JZ	L4$

		ADD	BYTES_SO_FAR,ECX
		MOV	EDX,CVT_MODSTART_FINAL

		MOV	CVT_MODSTART_PUT_PTR,EAX

		ADD	CVT_MODSTART_FINAL,ECX
		JMP	MOVE_EAX_TO_EDX_FINAL

L4$:
		RET

FLUSH_MODSTART_BUFFER	ENDP


STORE_REFCNT	PROC	NEAR
		;
		;
		;
		MOV	EDX,CVT_REFCNT_PUT_PTR
		MOV	ECX,CVT_REFCNT_LIMIT

		MOV	WPTR [EDX],AX
		ADD	EDX,2

		CMP	ECX,EDX
		MOV	CVT_REFCNT_PUT_PTR,EDX

		JZ	FLUSH_REFCNT_BUFFER

		RET

STORE_REFCNT	ENDP


FLUSH_REFCNT_BUFFER	PROC	NEAR
		;
		;
		;
		MOV	ECX,CVT_REFCNT_PUT_PTR
		LEA	EAX,CVT_REFCNT_BUFFER

		SUB	ECX,EAX
		JZ	L4$

		ADD	BYTES_SO_FAR,ECX
		MOV	EDX,CVT_REFCNT_FINAL

		MOV	CVT_REFCNT_PUT_PTR,EAX

		ADD	CVT_REFCNT_FINAL,ECX
		JMP	MOVE_EAX_TO_EDX_FINAL

L4$:
		RET

FLUSH_REFCNT_BUFFER	ENDP


STORE_NAMEREF_ADDRESS	PROC	NEAR
		;
		;
		;
		MOV	EDX,CVT_NAMEREF_PUT_PTR
		MOV	ECX,CVT_NAMEREF_LIMIT

		ADD	EDX,4

		CMP	EDX,ECX
		MOV	CVT_NAMEREF_PUT_PTR,EDX

		MOV	[EDX-4],EAX
		JZ	FLUSH_NAMEREF_BUFFER

		RET

STORE_NAMEREF_ADDRESS	ENDP


FLUSH_NAMEREF_BUFFER	PROC	NEAR
		;
		;
		;
		MOV	ECX,CVT_NAMEREF_PUT_PTR
		LEA	EAX,CVT_NAMEREF_BUFFER

		SUB	ECX,EAX
		JZ	L4$

		ADD	BYTES_SO_FAR,ECX
		MOV	CVT_NAMEREF_PUT_PTR,EAX

		MOV	EDX,CVT_NAMEREF_FINAL

		ADD	CVT_NAMEREF_FINAL,ECX
		JMP	MOVE_EAX_TO_EDX_FINAL

L4$:
		RET

FLUSH_NAMEREF_BUFFER	ENDP


FLUSH_NAMES_BUFFER	PROC	NEAR
		;
		;
		;
		MOV	EDI,OFF CV_TEMP_RECORD
		MOV	ESI,FIRST_RELOC_GINDEX

		JMP	TEST_NAMESP

NAMESP_LOOP:
		CONVERT	ESI,ESI,RELOC_GARRAY
		ASSUME	ESI:PTR CV_NAMESP_STRUCT

		MOV	EAX,[ESI]._CNS_NEXT_GINDEX
		INC	EDI

		PUSH	EAX
		LEA	ESI,[ESI]._CNS_TEXT

		MOV	EBX,EDI
		CALL	MOVE_ASCIZ_ESI_EDI

		POP	ESI
		MOV	EAX,EDI

		SUB	EAX,EBX
		CMP	EDI,OFF CV_TEMP_RECORD+CV_TEMP_SIZE-SYMBOL_TEXT_SIZE-2

		MOV	BYTE PTR[EBX-1],AL
		JC	L75$

		CALL	FLUSH_CV_TEMP
L75$:

TEST_NAMESP:
		TEST	ESI,ESI
		JNZ	NAMESP_LOOP

		CALL	FLUSH_CV_TEMP

		MOV	EAX,OFF RELOC_STUFF
		push	EAX
		call	_release_minidata
		add	ESP,4

		MOV	EAX,OFF RELOC_GARRAY
		CALL	RELEASE_GARRAY

		XOR	EAX,EAX

		MOV	FIRST_RELOC_GINDEX,EAX
		MOV	LAST_RELOC_GINDEX,EAX

		RET

FLUSH_NAMES_BUFFER	ENDP


FLUSH_CV_TEMP	PROC	NEAR	PRIVATE
		;
		;
		;
		MOV	ECX,EDI
		MOV	EAX,OFF CV_TEMP_RECORD

		SUB	ECX,EAX
		JZ	L9$

		MOV	EDX,BYTES_SO_FAR
		MOV	EDI,EAX

		ADD	EDX,ECX

		MOV	BYTES_SO_FAR,EDX
		JMP	MOVE_EAX_TO_FINAL_HIGH_WATER

L9$:
		RET

FLUSH_CV_TEMP	ENDP


DOING_SSTFILEINDEX_MSG DB	SIZEOF DOING_SSTFILEINDEX_MSG-1,'Doing SSTFILEINDEX',0DH,0AH

endif


		END

