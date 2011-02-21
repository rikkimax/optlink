		TITLE SEGDEF - Copyright (c) SLR Systems 1994

		INCLUDE MACROS
		INCLUDE	SEGMENTS

		PUBLIC	SEGDEF,SEGDEF32


		.DATA

		EXTERNDEF	SEG_COMBINE:BYTE,SEG_ALIGN:BYTE,SEG32_FLAGS:BYTE,CLASS_TYPE:BYTE

		EXTERNDEF	END_OF_RECORD:DWORD,DEFAULT_SIZE:DWORD,SEG_FOFFS:DWORD,BUFFER_OFFSET:DWORD,SEG_LEN:DWORD
		EXTERNDEF	SEG_FRAME:DWORD,SEG_NAME_LINDEX:DWORD,CLASS_NAME_LINDEX:DWORD

		EXTERNDEF	SEGMOD_LARRAY:LARRAY_STRUCT


		.CODE	PASS1_TEXT

		EXTERNDEF	OBJ_PHASE:PROC,WARN_RET:PROC,DEFINE_SEGMOD:PROC,FIX_MULTI_CSEGS:PROC,ERR_RET:PROC

		EXTERNDEF	ASEG_ERR:ABS,SEG_4G_ERR:ABS,BAD_SEG_SIZE_ERR:ABS


SEGDEF32	PROC

		MOV	ECX,MASK BIT_32
		JMP	SEGDEF_COMMON

L3$:
		MOV	AL,4
		CMP	DEFAULT_SIZE,0
		JNZ	L4$
		;
		;LTL, SKIP STUFF
		;
		MOV	AL,3
		ADD	ESI,5
		JMP	L4$

SEGDEF		LABEL	PROC

if	fg_phar
		MOV	ECX,DEFAULT_SIZE
else
		XOR	ECX,ECX
endif

SEGDEF_COMMON:
		;
		;DS:SI OF COURSE IS SEGDEF RECORD POINTER...
		;
		;
		;GET SEG_ATTR BYTE
		;	AND OPTIONAL FRAME AND OFFSET
		;GET SEGMENT_LENGTH
		;GET SEG_NAME
		;GET CLASS_NAME
		;GET OVERLAY_NAME
		;
		;NOW WHAT?????
		;
		MOV	AL,[ESI]
		INC	ESI
		;
		;BITS 5-7
		;	0 = ASEG
		;	1 = BYTE ALIGNED
		;	2 = WORD ALIGNED
		;	3 = PARAGRAPH ALIGNED
		;	4 = PAGE ALIGNED
		;	5 = DWORD ALIGNED
		;	6 = 4K BLOCK ALIGNED (IF PHARLAP)
		;	    ELSE LTL SEGMENT, PARAGRAPH ALIGNED.
		;       7 = 32 BYTE ALIGNED (Java)
		;
		MOV	DL,AL
		MOV	SEG_COMBINE,AL

		ROL	AL,3

		AND	AL,7
		JZ	L1$			;ASEG, RARE, SO JUMP

		CMP	AL,6			;DIFFERENT FOR PHARLAP VS INTEL
		JZ	L3$
L4$:
		MOV	SEG_ALIGN,AL		;ALIGN BYTE
		;
		;GET SEGMENT LENGTH
		;
		TEST	ECX,ECX

		MOV	EAX,[ESI]		;GET 32-BIT SIZE
		JZ	SEGDEF_SMALL

		ADD	ESI,4
		AND	DL,2

		JZ	SEGDEF_COMMON1

		PUSH	EAX
		MOV	AL,SEG_4G_ERR
		CALL	ERR_RET
		POP	EAX
		JMP	SEGDEF_COMMON1
	
L1$:
		;
		;ABSOLUTE SEGMENT, LOAD FRAME # AND OFFSET
		;
		PUSH	EAX
		MOV	EAX,[ESI]	;MOVE FRAME
		ADD	ESI,3
		AND	EAX,0FFFFH
		SHL	EAX,4		;ASSUME REAL-MODE FRAME
		MOV	SEG_FRAME,EAX	;MOVE OFFSET
		POP	EAX
		JMP	L4$

SA_ABS_FIX:
		MOV	AL,SC_ABSOLUTE
		JMP	SA_ABS_FIX_RET

HANDLE_BIG:
		TEST	EAX,EAX
		JNZ	HB_1
HB_2:
		MOV	EAX,10000H
		JMP	SEGDEF_COMMON1

HB_1:
		MOV	AL,BAD_SEG_SIZE_ERR
		CALL	WARN_RET
		JMP	HB_2

		DOLONG	L1
		DOLONG	L2
		DOLONG	L3

SEGDEF_SMALL:
		ADD	ESI,2
		AND	EAX,0FFFFH

		AND	DL,2
		JNZ	HANDLE_BIG
SEGDEF_COMMON1:
		MOV	DH,SEG_ALIGN
		MOV	SEG_LEN,EAX
		;
		;ASSUME USE16 BY DEFAULT
		;
		CMP	DH,SA_ABSOLUTE
		MOV	DL,MASK SEG32_USE16

		MOV	AL,SEG_COMBINE
		JZ	SA_ABS_FIX

		TEST	AL,1
		JZ	NOT_USE32

;		MOV	AH,-1
		MOV	DL,MASK SEG32_USE32
;		SETT	ANY_USE32,AH
NOT_USE32:
		SHR	AL,2

		AND	EAX,7

		MOV	AL,SEG_COMBINE_TBL[EAX]
SA_ABS_FIX_RET:
		MOV	SEG32_FLAGS,DL
		MOV	SEG_COMBINE,AL
		;
		;HERE FOR 16 AND 32 BIT SEGMENT DEFINITIONS...
		;
		NEXT_INDEX	L1
		MOV	SEG_NAME_LINDEX,EAX		;SEGMENT NAME INDEX
		NEXT_INDEX	L2
		MOV	EDX,END_OF_RECORD
		MOV	CLASS_NAME_LINDEX,EAX		;CLASS NAME INDEX
		NEXT_INDEX	L3		;OVERLAY NAME INDEX (IGNORED)

		CMP	EDX,ESI
		JNZ	SEGDEF_CORR		;SEGDEF RECORD CORRUPT
SEGDEF_NOTCOR:
		MOV	BUFFER_OFFSET,ESI
		;
		;ALL REGS AVAILABLE AT THIS POINT...
		;FIRST, SEARCH FOR MATCHING CLASS...
		;
		CALL	DEFINE_SEGMOD		;EAX IS SEGMOD GINDEX, ECX PHYS
		ASSUME	ECX:PTR SEGMOD_STRUCT

		MOV	EDI,EAX
		INSTALL_GINDEX_LINDEX	SEGMOD_LARRAY

		MOV	AL,CLASS_TYPE
		MOV	DL,SEG32_FLAGS

		AND	AL,MASK SEG_CV_TYPES1 + MASK SEG_CV_SYMBOLS1
		JNZ	NOT_321

		AND	DL,MASK SEG32_USE32
		JZ	NOT_321

		SETT	ANY_USE32

NOT_321:
		GETT	DL,KEEPING_LINNUMS
		MOV	AL,[ECX]._SM_FLAGS

		TEST	DL,DL		;ANY DEBUGGING?
		JZ	SEG_DONE
		;
		;SEE IF A 'CODE' SEGMENT
		;
		TEST	AL,MASK SEG_CLASS_IS_CODE	;CODE?
		JZ	SEG_DONE
		;
		;ONLY IF LENGTH >0
		;
		MOV	EAX,[ECX]._SM_LEN
if	fg_td
		GETT	DL,TD_FLAG
endif
		TEST	EAX,EAX
		JZ	SEG_DONE		;IGNORE 0-LENGTH CODE SEGMENTS
if	fg_td
		TEST	DL,DL			;FOR TURBO DEBUG, ONLY DO THIS IF LINNUMS FOUND
		JNZ	SEG_DONE		;OR SCOPES FOUND
endif
		MOV	EAX,EDI
		CALL	FIX_MULTI_CSEGS		;EAX IS SEGMOD GINDEX, ECX IS PHYSICAL
SEG_DONE:
		RET

SEGDEF_CORR:
		;
		;OK IF PHARLAP...
		;
if	fg_phar
		MOV	EDX,DEFAULT_SIZE
		MOV	AH,[ESI]

		TEST	EDX,EDX
		JZ	SEGDEF_CORR1

		MOV	AL,SEG32_FLAGS
		INC	ESI

		AND	AL,NOT MASK SEG32_USE32
		;
		;PHARLAP ACCESS TYPES NOT YET SUPPORTED
		;
		OR	AL,MASK SEG32_USE16

		TEST	AH,4
		JZ	PH_NOT_USE32

		AND	AL,NOT MASK SEG32_USE16
;		MOV	DL,-1

		OR	AL,MASK SEG32_USE32
;		SETT	ANY_USE32,DL
PH_NOT_USE32:
		MOV	EDX,END_OF_RECORD
		MOV	SEG32_FLAGS,AL

		CMP	EDX,ESI
		JNZ	SEGDEF_CORR1
		;
		;SPECIAL PHARLAP SEGMENT TYPING...
		;

		JMP	SEGDEF_NOTCOR

endif

SEGDEF_CORR1:
		CALL	OBJ_PHASE
		JMP	SEGDEF_NOTCOR

SEGDEF32	ENDP


SEG_COMBINE_TBL	DB	SC_PRIVATE
		DB	SC_PUBLIC	;MEMORY, TREAT LIKE PUBLIC
		DB	SC_PUBLIC	;PUBLIC
		DB	SC_PUBLIC	;RESERVED
		DB	SC_PUBLIC	;??
		DB	SC_STACK	;SC_STACK
		DB	SC_COMMON	;SC_COMMON
		DB	SC_PUBLIC	;??


		END
