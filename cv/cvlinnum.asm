		TITLE	CVLINNUM - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS
		INCLUDE	SEGMENTS
		INCLUDE	MODULES

		PUBLIC	CV_LINNUMS_3


		.DATA

		EXTERNDEF	CV_TEMP_RECORD:BYTE

		EXTERNDEF	CURNMOD_GINDEX:DWORD,BYTES_SO_FAR:DWORD,CV_HEADER_LOC:DWORD

		EXTERNDEF	SEGMOD_GARRAY:STD_PTR_S,SEGMENT_GARRAY:STD_PTR_S,MODULE_GARRAY:STD_PTR_S,CSEG_GARRAY:STD_PTR_S
		EXTERNDEF	SRC_GARRAY:STD_PTR_S,MDB_GARRAY:STD_PTR_S


		.CODE	PASS2_TEXT

		EXTERNDEF	MOVE_TEXT_TO_OMF:PROC,HANDLE_CV_INDEX:PROC,RELEASE_SEGMENT:PROC,FLUSH_CV_TEMP:PROC
		EXTERNDEF	MOVE_EAX_TO_EDX_FINAL:PROC,RELEASE_BLOCK:PROC,OBJ_PHASE:PROC


CVLIN_STRUCT		STRUC

CV_LIN_FACTOR_BP	DD	?
CV_LIN_LAST_SRC_GINDEX_BP	DD	?
CV_LIN_LAST_SEG_GINDEX_BP	DD	?
CV_LINNUM_COUNT_BP	DD	?
CV_SEG_INDEX_BP		DD	?
CV_SEG_FRAME_BP		DD	?
CV_LINNUM_COUNT_ADDR_BP	DD	?
CV_LN_STUFF_BP		LINNUM_HEADER_TYPE	<>
OFFSET_SIZE_BP		DD	?

CVLIN_STRUCT		ENDS


FIX	MACRO	X

X	EQU	([EBP-SIZE CVLIN_STRUCT].(X&_BP))

	ENDM


FIX	CV_LIN_FACTOR
FIX	CV_LIN_LAST_SRC_GINDEX
FIX	CV_LIN_LAST_SEG_GINDEX
FIX	CV_LINNUM_COUNT
FIX	CV_SEG_INDEX
FIX	CV_SEG_FRAME
FIX	CV_LINNUM_COUNT_ADDR
FIX	CV_LN_STUFF
FIX	OFFSET_SIZE


CV_LN_NEXT_LINNUM	EQU	CV_LN_STUFF._LN_NEXT_LINNUM
CV_LN_BLOCK_BASE	EQU	CV_LN_STUFF._LN_BLOCK_BASE
CV_LN_LENGTH		EQU	CV_LN_STUFF._LN_LENGTH
CV_LN_TYPE		EQU	CV_LN_STUFF._LN_TYPE
CV_LN_SRC_GINDEX	EQU	CV_LN_STUFF._LN_SRC_GINDEX


CV_LINNUMS_3	PROC
		;
		;OUTPUT LINE NUMBER INFO FOR THIS MODULE, CODEVIEW VERSION < 4.0
		;
		;THIS GETS BUILT IN EXETABLE FIRST SINCE WE MUST UPDATE LINE# COUNT...
		;
		PUSH	EBP
		MOV	EAX,CURNMOD_GINDEX	;THIS MODULE
		CONVERT	EAX,EAX,MODULE_GARRAY
		ASSUME	EAX:PTR MODULE_STRUCT

		PUSHM	EDI,ESI
		;
		;NOW, SEE IF ANY LINE NUMBERS THIS MODULE
		;
		MOV	CL,[EAX]._M_FLAGS
		PUSH	EBX

		AND	CL,MASK M_SRCS_PRESENT
		JZ	L9$

		MOV	EBP,ESP
		SUB	ESP,SIZE CVLIN_STRUCT
		ASSUME	EBP:PTR CVLIN_STRUCT

		MOV	ECX,BYTES_SO_FAR	;SAVE FOR SECTION LENGTH
		XOR	EDX,EDX

		PUSH	ECX
		MOV	CV_LIN_LAST_SEG_GINDEX,EDX	;FORCE NEW RECORD

		MOV	CV_SEG_FRAME,EDX		;FOR SEGMENTED OUTPUT
		MOV	CV_LINNUM_COUNT,EDX	;# OF LINES SO FAR THIS RECORD

		MOV	EAX,[EAX]._M_MDB_GINDEX

		TEST	EAX,EAX
		JZ	L2$

		CONVERT	EAX,EAX,MDB_GARRAY
		ASSUME	EAX:PTR MDB_STRUCT

		MOV	EAX,[EAX]._MD_FIRST_CSEGMOD_GINDEX

		TEST	EAX,EAX
		JNZ	CHECK_CSEGMOD
L2$:
		JMP	LINES_DONE

L9$:
		POPM	EBX,ESI,EDI,EBP

		RET

CSEGMOD_LOOP:
		;
		;START A NEW SEGMOD
		;
		CALL	CSEGMOD_START

		PUSH	EAX		;NEXT CSEGMOD
		JMP	CHECK_LINNUM

LLIN_LOOP:
		;
		;START A NEW LINNUM RECORD
		;
		MOV	EAX,ECX
		CALL	LINE_START	;INIT RECORD BUFFER, ESI IS INPUT POINTER, EDI IS OUTPUT POINTER
					;EBX IS INPUT LIMIT, ECX IS # OF ITEMS, EDX IS OFFSET TO ADD
LINE_LOOP:
		CMP	ESI,EBX
		JAE	CV_LIN_SPEC

		MOV	EAX,[ESI]
		ADD	ESI,4

		ADD	EAX,EDX

		MOV	[EDI],EAX
		MOV	EAX,OFFSET_SIZE

		ADD	EDI,4
		ADD	ESI,EAX
L1$:
		CMP	EDI,OFF CV_TEMP_RECORD+CV_TEMP_SIZE-4	;ROOM FOR AT LEAST 2 MORE?
		JAE	L5$
L51$:
		DEC	ECX
		JNZ	LINE_LOOP

		JMP	LINE_DONE

L5$:
		PUSHM	EDX,ECX

		CALL	FLUSH_CV_TEMP

		POPM	ECX,EDX

		JMP	L51$

CV_LIN_SPEC:
		;
		;MAY CROSS BOUNDARIES
		;
		CALL	GET2

		STOSW			;LINE #

		CALL	GET2

		SHL	EAX,16

		ADD	EAX,EDX

		SHR	EAX,16

		STOSW			;OFFSET

		MOV	EAX,OFFSET_SIZE

		TEST	EAX,EAX
		JZ	L1$

		CALL	GET2		;SKIP HIGH WORD

		JMP	L1$

LINE_DONE:
		CALL	FLUSH_CV_TEMP
NEXT_LINE:
		;
		;DEC USAGE COUNT
		;
		MOV	EAX,CV_LN_BLOCK_BASE

		DEC	DPTR [EAX]
		JNZ	NY_1

		CALL	RELEASE_SEGMENT
NY_1:
		MOV	ECX,CV_LN_NEXT_LINNUM	;ANOTHER RECORD?
CHECK_LINNUM:
		TEST	ECX,ECX
		JNZ	LLIN_LOOP
		;
		;NO MORE LINES THIS SEGMOD, TRY NEXT
		;
		POP	EAX
CHECK_CSEGMOD:
		TEST	EAX,EAX
		JNZ	CSEGMOD_LOOP
		;
		;NO MORE CODE SEGMODS, YOU ARE DONE
		;
		CALL	LINNUM_FLUSH		;FLUSH COUNT FROM LAST LINNUM TYPE
		;
		;NOW OUTPUT INDEX ENTRY
		;
		POP	EAX			;OLD BYTES_SO_FAR (FOR INDEX)
		MOV	ECX,105H

		BITT	NEW_CV_INFO
		JZ	NY_9

		MOV	CL,9
NY_9:
		CALL	HANDLE_CV_INDEX
LINES_DONE:
		MOV	ESP,EBP

		POPM	EBX,ESI,EDI,EBP

		RET

CV_LINNUMS_3	ENDP


GET2		PROC	NEAR	PRIVATE
		;
		;GET NEXT TWO BYTES FROM INPUT STREAM
		;
		LEA	EAX,[EBX+6]

		CMP	ESI,EAX
		JE	L1$

		MOV	AX,WPTR [ESI]
		ADD	ESI,2

		RET

L1$:
		MOV	EAX,CV_LN_BLOCK_BASE

		DEC	DPTR [EAX]		;LAST ITEM IN BLOCK?
		MOV	ESI,DPTR [EAX+4]

		MOV	CV_LN_BLOCK_BASE,ESI
		JNZ	L2$

		CALL	RELEASE_SEGMENT		;RELEASE IF DONE
L2$:
		LEA	EBX,[ESI + PAGE_SIZE-6]

		MOV	AX,WPTR [ESI+8]
		ADD	ESI,10

		RET

GET2		ENDP


LINE_START	PROC	NEAR	PRIVATE
		;
		;EAX IS LOGICAL ADDRESS OF NEW LINNUM RECORD
		;
		;INIT RECORD BUFFER,
		;
		;RETURNS:
		;EDX = OFFSET TO ADD, ECX = # OF ITEMS,
		;INPUT LIMIT, OFFSET_SIZE IS 0 OR 2 OFFSET DELTA
		;
		ASSUME	EAX:PTR LINNUM_HEADER_TYPE

		MOV	ECX,[EAX]._LN_BLOCK_BASE
		MOV	EDX,[EAX]._LN_NEXT_LINNUM

		MOV	CV_LN_BLOCK_BASE,ECX
		LEA	EBX,[ECX+PAGE_SIZE-6]

		MOV	CV_LN_NEXT_LINNUM,EDX
		MOV	ECX,DPTR [EAX]._LN_LENGTH

		MOV	EDX,[EAX]._LN_SRC_GINDEX
		MOV	DPTR CV_LN_LENGTH,ECX

		MOV	CV_LN_SRC_GINDEX,EDX
		LEA	ESI,[EAX + SIZEOF LINNUM_HEADER_TYPE]
		;
		;
		;
		;
		;SEE IF FILENAME MATCHES PREVIOUS RECORD
		;IF FILENAME OR SEGMOD IS DIFFERENT, START A NEW RECORD
		;
		MOV	EAX,CV_LN_SRC_GINDEX
		MOV	ECX,CV_LIN_LAST_SRC_GINDEX

		CMP	EAX,ECX
		JZ	L5$

		PUSH	ESI
		MOV	CV_LIN_LAST_SRC_GINDEX,EAX
		;
		;NEW LINNUM HEADER STARTING
		;
		CALL	LINNUM_FLUSH		;FLUSH STUFF TO HERE

		MOV	ESI,CV_LIN_LAST_SRC_GINDEX
		CONVERT	ESI,ESI,SRC_GARRAY
		MOV	EDI,OFF CV_TEMP_RECORD	;PLACE TO BUILD THIS RECORD

		ADD	ESI,SRC_STRUCT._SRC_TEXT
		CALL	MOVE_TEXT_TO_OMF	;LENGTH IN AX

		BITT	NEW_CV_INFO
		JZ	L2$
		;
		;NEED SEGMENT INDEX... (ACTUALLY THIS IS SEGMENT FRAME OR SEGMENT NUMBER)
		;
		MOV	EAX,CV_SEG_INDEX

		STOSW
L2$:
		CALL	FLUSH_CV_TEMP		;FOR DWORD ALIGNMENT?

		POP	ESI
		MOV	EAX,BYTES_SO_FAR

		MOV	CV_LINNUM_COUNT_ADDR,EAX	;ADDR FOR UPDATING LINE # COUNT
		ADD	EAX,2

		MOV	BYTES_SO_FAR,EAX
L5$:
		;
		;CALCULATE # OF LINE #'S IN THIS RECORD
		;
		MOV	EAX,DPTR CV_LN_LENGTH

		MOV	DL,CV_LN_TYPE
		AND	EAX,0FFFFH

		AND	DL,MASK BIT_32
		JZ	L91$

		MOV	ECX,6
		XOR	EDX,EDX

		DIV	CX

		MOV	OFFSET_SIZE,2

		ADD	CV_LINNUM_COUNT,EAX
		TEST	EDX,EDX

		MOV	EDX,CV_LIN_FACTOR	;AMOUNT TO ADD TO EACH OFFSET...
		MOV	EDI,OFF CV_TEMP_RECORD	;PLACE TO BUILD THIS RECORD

		MOV	ECX,EAX
		JNZ	OBJ_E
OBJ_E_RET:
		RET

L91$:
		TEST	AL,3
		JNZ	OBJ_E

		SHR	EAX,2
		MOV	EDX,CV_LIN_FACTOR	;AMOUNT TO ADD TO EACH OFFSET...

		MOV	OFFSET_SIZE,0

		ADD	CV_LINNUM_COUNT,EAX
		MOV	ECX,EAX

		MOV	EDI,OFF CV_TEMP_RECORD	;PLACE TO BUILD THIS RECORD
		RET

OBJ_E:
		CALL	OBJ_PHASE
		JMP	OBJ_E_RET

LINE_START	ENDP


CSEGMOD_START	PROC	NEAR	PRIVATE
		;
		;AX IS SEGMOD
		;
		;RETURNS DX=OFFSET TO ADD TO EACH LINENUMBER
		;	AX IS NEXT CSEGMOD
		;	DSSI IS VIRTUAL LINNUM RECORD ADDRESS
		;
		CONVERT	EAX,EAX,SEGMOD_GARRAY
		ASSUME	EAX:PTR SEGMOD_STRUCT

		MOV	EDX,[EAX]._SM_START		;WE ONLY CARE ABOUT LOW 16-BITS THIS TIME
		MOV	ECX,[EAX]._SM_MODULE_CSEG_GINDEX

		MOV	EAX,[EAX]._SM_BASE_SEG_GINDEX

		CMP	CV_LIN_LAST_SEG_GINDEX,EAX
		JZ	L1$

		PUSHM	EDX,ECX

		CALL	CSEGMENT_START

		POPM	ECX,EDX
L1$:
		SUB	EDX,CV_SEG_FRAME			;OVERALL OFFSET MAYBE MINUS FRAME
		CONVERT	ECX,ECX,CSEG_GARRAY
		ASSUME	ECX:PTR CSEG_STRUCT
		MOV	EAX,[ECX]._CSEG_NEXT_CSEGMOD_GINDEX

		SHL	EDX,16
		MOV	ECX,[ECX]._CSEG_FIRST_LINNUM

		MOV	CV_LIN_FACTOR,EDX

		RET

CSEGMOD_START	ENDP


CSEGMENT_START	PROC	NEAR	PRIVATE
		;
		;EAX IS NEW SEGMENT_GINDEX
		;
		MOV	CV_LIN_LAST_SEG_GINDEX,EAX
		CONVERT	ECX,EAX,SEGMENT_GARRAY
		ASSUME	ECX:PTR SEGMENT_STRUCT

		MOV	CV_LIN_LAST_SRC_GINDEX,0		;FORCE NEW CODEVIEW RECORD
		;
		;ALSO DEFINE SEG_INDEX FOR CV TYPE 2
		;
		MOV	EAX,[ECX]._SEG_OS2_NUMBER		;ALSO FRAME.LW
		GETT	DL,OUTPUT_SEGMENTED

		OR	DL,DL
		JNZ	L2$

		MOV	CV_SEG_FRAME,EAX

		SHR	EAX,4
L2$:
		MOV	CV_SEG_INDEX,EAX			;NOT REALLY INDEX, SELECTOR OR PARAGRAPH

		RET

CSEGMENT_START	ENDP


LINNUM_FLUSH	PROC	NEAR	PRIVATE
		;
		;FLUSH LINNUM_COUNT
		;
		MOV	EAX,CV_LINNUM_COUNT
		MOV	EDX,CV_LINNUM_COUNT_ADDR

		TEST	EAX,EAX
		JZ	L8$

		MOV	ECX,CV_HEADER_LOC
		LEA	EAX,CV_LINNUM_COUNT

		ADD	EDX,ECX
		MOV	ECX,2

		CALL	MOVE_EAX_TO_EDX_FINAL

		MOV	CV_LINNUM_COUNT,0
L8$:
		RET

LINNUM_FLUSH	ENDP


		END
