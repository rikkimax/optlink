		TITLE THEADR - Copyright (c) SLR Systems 1994

		INCLUDE MACROS

		PUBLIC	THEADR,RHEADR,STRIP_PATH_EXT


		.DATA

		EXTERNDEF	MODULE_NAME:BYTE,THEADR_TEMP:BYTE,SYMBOL_TEXT:BYTE

		EXTERNDEF	END_OF_RECORD:DWORD,LIN_SRC_GINDEX:DWORD,SYMBOL_LENGTH:DWORD


		.CODE	PASS1_TEXT

		EXTERNDEF	OBJ_PHASE:PROC,TOO_LONG:PROC,SRCNAME_INSTALL:PROC,OPTI_MOVE_PRESERVE_IGNORE:PROC


RHEADR		LABEL	PROC

		SETT	RHEADR_FLAG

THEADR		PROC		;USES
		;
		;ESI IS RECORD POINTER
		;
		;THIS USUALLY CONTAINS A FILENAME FOR DEBUGGING USE
		;IN LIBRARIES, IT ALSO MAY BE A MODULE NAME THE FIRST TIME
		;
		MOV	EDI,OFF THEADR_TEMP+4

		GET_OMF_NAME_LENGTH		;IN EAX

		MOV	ECX,EAX
		MOV	[EDI-4],EAX

		GETT	DL,FOUND_THEADR
		OPTI_MOVSB

		MOV	[EDI],ECX
		MOV	CL,-1

		TEST	DL,DL			;IS THIS THE FIRST THEADR?
		JNZ	THEADR1 		;NOPE, SKIP IT

		GETT	DL,LIB_OR_NOT		;NOW, IF A LIB FILE, MAKE THIS
		SETT	FOUND_THEADR,CL		;MARK THEADR FOUND

		TEST	DL,DL
		JZ	THEADR1 		;THE MODULE NAME...
		;
		;NOW MOVE MODULE NAME FROM THEADR
		;
		MOV	ECX,OFF THEADR_TEMP
		MOV	EAX,OFF MODULE_NAME

		CALL	STRIP_PATH_EXT
THEADR1:
		XOR	EAX,EAX
		GETT	DL,RHEADR_FLAG

		MOV	LIN_SRC_GINDEX,EAX	;THEADR ADDRESS INVALID
		TEST	DL,DL

		MOV	EAX,END_OF_RECORD
		JNZ	L5$

		CMP	EAX,ESI			;SHOULD BE EXACT
		JNZ	NAME_ERR1		;NOPE, FAIL

		RET

L5$:
		RESS	RHEADR_FLAG
		RET

NAME_ERR1:
		CALL	OBJ_PHASE
		RET

THEADR		ENDP


STRIP_PATH_EXT	PROC
		;
		;ECX IS SYMBOL_LENGTH
		;EAX IS DESTINATION
		;
		PUSH	ESI
		MOV	ESI,ECX

		PUSH	EDI
		MOV	EDI,EAX

		MOV	ECX,[ESI]
		ADD	ESI,3

		PUSH	EBX
		ADD	ESI,ECX

		XOR	EBX,EBX
		MOV	EDX,ESI		;SAVE END OF NAME...
		;
		;LOOK BACKWARDS FOR \, /, :, OR FIRST .
		;
		TEST	ECX,ECX
		JZ	L19$
L1$:
		MOV	AL,[ESI]
		DEC	ESI

		CMP	AL,'\'
		JZ	L2$

		CMP	AL,'/'
		JZ	L2$

		CMP	AL,':'
		JZ	L2$

		CMP	AL,'.'
		JNZ	L15$

		OR	EBX,EBX			;ALREADY FOUND A DOT?
		JNZ	L15$

		MOV	EBX,ESI			;LAST DOT
L15$:
		DEC	ECX
		JNZ	L1$
L191$:
		DEC	ESI
L2$:
		MOV	ECX,EBX

		TEST	EBX,EBX
		JNZ	L3$

		MOV	ECX,EDX
L3$:
		INC	ESI
		POP	EBX

		SUB	ECX,ESI
		INC	ESI		;FIRST CHAR OF NAME

		MOV	[EDI],ECX
		ADD	EDI,4

		REP	MOVSB

		MOV	[EDI],ECX
		POP	EDI

		POP	ESI

		RET

L19$:
		JMP	L191$

STRIP_PATH_EXT	ENDP


		END
