		TITLE	CVPUBALL - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS
if	fg_cvpack
		INCLUDE	SYMBOLS
		INCLUDE	MODULES
		INCLUDE	SEGMENTS
		INCLUDE	CVTYPES
		INCLUDE SEGMSYMS
if	fg_pe
		INCLUDE	PE_STRUC
endif

		PUBLIC	CV_PUBLICS_ALL_4


		.DATA

		EXTERNDEF	CV_TEMP_RECORD:BYTE

		EXTERNDEF	CURNMOD_NUMBER:DWORD,CV_PUB_TXT_OFFSET:DWORD,CV_PUB_SYMBOL_ID:DWORD,CVG_SEGMENT:DWORD
		EXTERNDEF	BYTES_SO_FAR:DWORD,CVG_SYMBOL_OFFSET:DWORD,CVG_SEGMENT_OFFSET:DWORD,CVG_SYMBOL_HASH:DWORD
		EXTERNDEF	PE_BASE:DWORD,CURNMOD_GINDEX:DWORD,FIRST_MODULE_GINDEX:DWORD

		EXTERNDEF	MODULE_GARRAY:STD_PTR_S,SYMBOL_GARRAY:STD_PTR_S,SEGMENT_GARRAY:STD_PTR_S,PE_OBJECT_GARRAY:STD_PTR_S

		EXTERNDEF	FIRST_IMPMOD_GINDEX:DWORD,IMPMOD_GARRAY:IMPMOD_STRUCT
		EXTERNDEF	ICODE_PEOBJECT_GINDEX:DWORD,ICODE_PEOBJECT_NUMBER:DWORD
		EXTERNDEF	PE_THUNKS_RVA:DWORD,PE_IMPORTS_OBJECT_NUMBER:DWORD,PE_IMPORTS_OBJECT_GINDEX:DWORD

		.CODE	ROOT_TEXT

		EXTERNDEF	MOVE_ASCIZ_ESI_EDI:PROC

		.CODE	CVPACK_TEXT

		EXTERNDEF	MOVE_TEXT_TO_OMF:PROC,HANDLE_CV_INDEX:PROC,FLUSH_CV_TEMP:PROC,_store_cv_symbol_info:proc
		EXTERNDEF	_output_cv_symbol_align:proc,_init_cv_symbol_hashes:proc,_flush_cv_symbol_hashes:proc,SAY_VERBOSE:PROC
		EXTERNDEF	GET_NAME_HASH32:PROC,MOVE_ASCIZ_ESI_EDI:PROC

CV_PUBLICS_ALL_4_VARS	STRUC

THUNKS_RVA_BP		DD	?
PUBLIC_VECTOR_BP	DD	?
IMPSYM_RVA_BP           DD	?
IMPNAME_BUFFER_BP       DD	?
IMPNAME_BUFFER2_BP      DW      ?
NAME_BUFFER_BP          DB	SYMBOL_TEXT_SIZE+2 DUP (?)

CV_PUBLICS_ALL_4_VARS	ENDS

FIX	MACRO	X

X	EQU	([EBP-SIZE CV_PUBLICS_ALL_4_VARS].(X&_BP))

	ENDM

FIX	THUNKS_RVA
FIX	PUBLIC_VECTOR
FIX	IMPSYM_RVA
FIX     IMPNAME_BUFFER
FIX     IMPNAME_BUFFER2
FIX     NAME_BUFFER

CV_PUBLICS_ALL_4	PROC
		;
		;OUTPUT GLOBALPUBLIC TABLE
		;
		;
		;INITIALIZE STUFF
		;
		PUSHM	EBP,EDI,ESI,EBX
                MOV	EAX,SYMBOL_TEXT_SIZE/2 - 4
                MOV	EBP,ESP
		SUB	ESP,SIZE CV_PUBLICS_ALL_4_VARS - SYMBOL_TEXT_SIZE - 4
                PUSH	EBP
                SUB	ESP,EAX
                PUSH	EBP
                SUB	ESP,EAX
                PUSH	EBP

		ASSUME	EBP:PTR CV_PUBLICS_ALL_4_VARS

		MOV	EAX,OFF DOING_SSTGLOBALPUB_MSG
		CALL	SAY_VERBOSE

		SETT	DOING_4K_ALIGN			;WE WANT S_ALIGN SYMBOLS WHERE NEEDED

		RESS	ANY_PUBLICS

		;
		;MODULE BY MODULE, ADD PUBLIC SYMBOLS TO TABLE
		;
		MOV	ESI,FIRST_MODULE_GINDEX
		JMP	L3$

L1$:
		CONVERT	ESI,ESI,MODULE_GARRAY
		ASSUME	ESI:PTR MODULE_STRUCT

		MOV	BL,[ESI]._M_FLAGS
		MOV	EAX,[ESI]._M_NEXT_MODULE_GINDEX

		AND	BL,MASK M_OMIT_$$PUBLICS	;DID LNKDIR PCODE DIRECTIVE SAY NO?
		PUSH	EAX

		JNZ	L2$

		MOV	EAX,[ESI]._M_FIRST_PUB_GINDEX
		MOV	PUBLIC_VECTOR,OFFSET STORE_THIS_PUBLIC
		CALL	STORE_MY_PUBLICS
L2$:
		POP	ESI
L3$:
		TEST	ESI,ESI
		JNZ	L1$
		;
		;NOW SCAN FOR IMPORTS
		;
		GETT	CL,OUTPUT_PE
		TEST	CL,CL

		JZ	L6$

		CALL	INIT_IMPORT_STUFF

		MOV	EAX,FIRST_IMPMOD_GINDEX

		PUSH	EAX
		JMP	L5$

L4$:
		CONVERT	ESI,ESI,IMPMOD_GARRAY
		ASSUME	ESI:PTR IMPMOD_STRUCT

		MOV	EAX,[ESI]._IMPM_NEXT_GINDEX

		PUSH	EAX

		MOV	EAX,[ESI]._IMPM_NAME_SYM_GINDEX
		MOV	PUBLIC_VECTOR,OFFSET STORE_THIS_IMPORT
		CALL	STORE_MY_PUBLICS

		MOV	EAX,[ESI]._IMPM_ORD_SYM_GINDEX
		CALL	STORE_MY_PUBLICS

		ADD	THUNKS_RVA,4

L5$:
		POP	ESI
		TEST	ESI,ESI
		JNZ	L4$

L6$:
		BITT	ANY_PUBLICS
		JZ	L9$

		MOV	EAX,OFF CV_TEMP_RECORD

		MOV	CURNMOD_NUMBER,-1

		MOV	DPTR [EAX],6 + S_ALIGN*64K
		MOV	DPTR 4[EAX],-1

		push	EAX
		call	_output_cv_symbol_align	;DO DWORD ALIGN, 4K ALIGN, RETURN OFFSET
		add	ESP,4

		;
		;CLEANUP INCLUDES:
		;  1.  DO NAME HASH TABLE
		;  2.  DO ADDRESS HASH TABLE
		;  3.  WRITE HEADER
		;  4.  DO CV_INDEX
		;
		MOV	EAX,012AH
		push	EAX
		call	_flush_cv_symbol_hashes
		add	ESP,4
L9$:
		MOV	ESP,EBP
		POPM	EBX,ESI,EDI,EBP

		RET

CV_PUBLICS_ALL_4	ENDP


STORE_MY_PUBLICS	PROC	NEAR
		PUSHM	ESI
		;
		;OUTPUT PUBLICS PLEASE
		;
L0$:
		TEST	EAX,EAX
		JZ	L9$

		CONVERT	EAX,EAX,SYMBOL_GARRAY
		ASSUME	EAX:PTR SYMBOL_STRUCT

		MOV	ESI,EAX
		MOV	BL,[EAX]._S_REF_FLAGS

		MOV	EAX,[EAX]._S_NEXT_SYM_GINDEX
		AND	BL,MASK S_SPACES + MASK S_NO_CODEVIEW

		JNZ	L0$

		PUSH	EAX

		;
		;ESI IS SYMBOL
		;
		GETT	AL,ANY_PUBLICS
		TEST	AL,AL
		JZ	L1$
L2$:
		CALL	PUBLIC_VECTOR

		POP	EAX
		JMP	L0$

L9$:
		POPM	ESI
		RET
L1$:
		SETT	ANY_PUBLICS

		call	_init_cv_symbol_hashes

		JMP	L2$

STORE_MY_PUBLICS	ENDP


STORE_THIS_PUBLIC	PROC	NEAR
		;
		;ESI IS SYMBOL
		;
		MOV	EDI,OFF CV_TEMP_RECORD

		CALL	CREATE_PUBSYM		;RETURNS DX == SEGMENT, CX:BX IS OFFSET

		MOV	EAX,OFF CV_TEMP_RECORD
		MOV	CVG_SEGMENT_OFFSET,EBX

		MOV	CVG_SEGMENT,EDX
		push	EAX
		call	_output_cv_symbol_align	;DO DWORD ALIGN, 4K ALIGN, RETURN OFFSET
		add	ESP,4

		MOV	CVG_SYMBOL_OFFSET,EAX	;STORE SYMBOL OFFSET
		MOV	EAX,CV_PUB_TXT_OFFSET

		ADD	EAX,OFF CV_TEMP_RECORD
		CALL	GET_NAME_HASH32

		MOV	CVG_SYMBOL_HASH,EAX
		jmp	_store_cv_symbol_info	;STORE INFO FOR SYMBOL HASHES

;		RET

STORE_THIS_PUBLIC	ENDP


CREATE_PUBSYM	PROC	NEAR
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		ASSUME	ESI:PTR SYMBOL_STRUCT

		MOV	EDX,[ESI]._S_SEG_GINDEX
		MOV	EAX,[ESI]._S_OFFSET

		TEST	EDX,EDX
		JZ	L4$

		CONVERT	EDX,EDX,SEGMENT_GARRAY
		ASSUME	EDX:PTR SEGMENT_STRUCT

		GETT	CL,OUTPUT_PE

		OR	CL,CL
		JNZ	L1$

		MOV	ECX,[EDX]._SEG_OFFSET
		MOV	EDX,[EDX]._SEG_CV_NUMBER

		SUB	EAX,ECX
		JMP	L4$

L1$:
		MOV	ECX,[EDX]._SEG_PEOBJECT_GINDEX
		MOV	EDX,[EDX]._SEG_PEOBJECT_NUMBER

		CONVERT	ECX,ECX,PE_OBJECT_GARRAY
		ASSUME	ECX:PTR PE_OBJECT_STRUCT

		SUB	EAX,PE_BASE
		MOV	ECX,[ECX]._PEOBJECT_RVA

		SUB	EAX,ECX
L4$:
		;
		;EAX IS OFFSET
		;EDX IS SEGMENT #
		;
		MOV	EBX,EDI
		MOV	ECX,103H			;ASSUME	16BIT?

		PUSHM	EAX,EDX

		MOV	[EDI+4],EAX			;STORE OFFSET
		GETT	AL,OUTPUT_32BITS

		ADD	EDI,10				;UPDATE PER 16-BIT
		LEA	ESI,[ESI]._S_NAME_TEXT

		OR	AL,AL
		JZ	DO_16

		ADD	EDI,2
		MOV	CH,2				;ECX=203H
DO_16:
		MOV	WPTR [EBX+2],CX

		MOV	[EDI-4],EDX
		CALL	MOVE_TEXT_TO_OMF

		LEA	EAX,[EDI-2]
		POP	EDX

		SUB	EAX,EBX

		MOV	WPTR [EBX],AX			;RECORD LENGTH
		POP	EBX
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		RET

CREATE_PUBSYM	ENDP

INIT_IMPORT_STUFF PROC NEAR

                MOV	EAX,PE_THUNKS_RVA
                MOV	THUNKS_RVA,EAX
                MOV	IMPNAME_BUFFER,'mi__'
                MOV	IMPNAME_BUFFER2,'_p'

		MOV	EAX,ICODE_PEOBJECT_GINDEX
		CONVERT	EAX,EAX,PE_OBJECT_GARRAY
		ASSUME	EAX:PTR PE_OBJECT_STRUCT

		TEST	EAX,EAX
		JZ	L1

		MOV	EAX,[EAX]._PEOBJECT_RVA
		ADD	EAX,PE_BASE
                MOV	IMPSYM_RVA,EAX
L1:
		MOV	EAX,PE_IMPORTS_OBJECT_GINDEX
		CONVERT	EAX,EAX,PE_OBJECT_GARRAY

		TEST	EAX,EAX
		JZ	L2

		MOV	EAX,[EAX]._PEOBJECT_RVA
                SUB	THUNKS_RVA,EAX
L2:
                RET

INIT_IMPORT_STUFF ENDP

STORE_THIS_IMPORT	PROC	NEAR
		;
		;ESI IS SYMBOL
		;
		MOV	EDI,OFF CV_TEMP_RECORD

		PUSHM	ESI
		CALL	CREATE_PUBIMPSYM	;RETURNS DX == SEGMENT, CX:BX IS OFFSET

		MOV	EAX,OFF CV_TEMP_RECORD
		MOV	CVG_SEGMENT_OFFSET,EBX

		MOV	CVG_SEGMENT,EDX
		push	EAX
		call	_output_cv_symbol_align	;DO DWORD ALIGN, 4K ALIGN, RETURN OFFSET
		add	ESP,4

		MOV	CVG_SYMBOL_OFFSET,EAX	;STORE SYMBOL OFFSET
		MOV	EAX,CV_PUB_TXT_OFFSET

		ADD	EAX,OFF CV_TEMP_RECORD
		CALL	GET_NAME_HASH32

		MOV	CVG_SYMBOL_HASH,EAX
		call	_store_cv_symbol_info	;STORE INFO FOR SYMBOL HASHES

		MOV	EDI,OFF CV_TEMP_RECORD
		POPM	ESI
		CALL	CREATE_PUB__IMP		;RETURNS DX == SEGMENT, CX:BX IS OFFSET

		MOV	EAX,OFF CV_TEMP_RECORD
		MOV	CVG_SEGMENT_OFFSET,EBX

		MOV	CVG_SEGMENT,EDX
		push	EAX
		call	_output_cv_symbol_align	;DO DWORD ALIGN, 4K ALIGN, RETURN OFFSET
		add	ESP,4

		MOV	CVG_SYMBOL_OFFSET,EAX	;STORE SYMBOL OFFSET
		MOV	EAX,CV_PUB_TXT_OFFSET

		ADD	EAX,OFF CV_TEMP_RECORD
		CALL	GET_NAME_HASH32

		MOV	CVG_SYMBOL_HASH,EAX
		jmp	_store_cv_symbol_info	;STORE INFO FOR SYMBOL HASHES

;		RET

STORE_THIS_IMPORT	ENDP


CREATE_PUBIMPSYM	PROC	NEAR
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		ASSUME	ESI:PTR SYMBOL_STRUCT

		MOV	EAX,[ESI]._S_OFFSET
		MOV	EDX,ICODE_PEOBJECT_NUMBER

		SUB	EAX,IMPSYM_RVA
		;
		;EAX IS OFFSET
		;EDX IS SEGMENT #
		;
		MOV	EBX,EDI
		MOV	ECX,203H			;ASSUME	32BIT

		PUSHM	EAX,EDX

		MOV	[EDI+4],EAX			;STORE OFFSET

		ADD	EDI,12				;UPDATE PER 32-BIT
		LEA	ESI,[ESI]._S_NAME_TEXT

		MOV	WPTR [EBX+2],CX

		MOV	[EDI-4],EDX
		CALL	MOVE_TEXT_TO_OMF

		LEA	EAX,[EDI-2]
		POP	EDX

		SUB	EAX,EBX

		MOV	WPTR [EBX],AX			;RECORD LENGTH
		POP	EBX
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		RET

CREATE_PUBIMPSYM ENDP

CREATE_PUB__IMP	PROC	NEAR
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		ASSUME	ESI:PTR SYMBOL_STRUCT

		MOV	EAX,THUNKS_RVA
		ADD	THUNKS_RVA,4
		MOV	EDX,PE_IMPORTS_OBJECT_NUMBER
		;
		;EAX IS OFFSET
		;EDX IS SEGMENT #
		;
		MOV	EBX,EDI
		MOV	ECX,203H			;ASSUME	32BIT

		PUSHM	EAX,EDX

		MOV	[EDI+4],EAX			;STORE OFFSET

		ADD	EDI,12				;UPDATE PER 32-BIT

		MOV	WPTR [EBX+2],CX

		MOV	[EDI-4],EDX

                PUSHM	EDI
		LEA	ESI,[ESI]._S_NAME_TEXT
                LEA     EDI,NAME_BUFFER
		CALL	MOVE_ASCIZ_ESI_EDI
                POPM	EDI

		LEA	ESI,IMPNAME_BUFFER
		CALL	MOVE_TEXT_TO_OMF

		LEA	EAX,[EDI-2]
		POP	EDX

		SUB	EAX,EBX

		MOV	WPTR [EBX],AX			;RECORD LENGTH
		POP	EBX
		;
		;RETURN EDX = SEGMENT, EBX IS OFFSET
		;
		RET

CREATE_PUB__IMP ENDP

		.CONST

DOING_SSTGLOBALPUB_MSG DB	SIZEOF DOING_SSTGLOBALPUB_MSG-1,'Doing SSTGLOBALPUB',0DH,0AH


endif


		END

