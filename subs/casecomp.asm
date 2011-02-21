		TITLE	CASECOMP - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS

		PUBLIC	CASE_STRING_COMPARE_EASY,CASE_STRING_COMPARE_HARD


		.DATA

		EXTERNDEF	UPPER_TABLE:BYTE


		.CODE	ROOT_TEXT


CASE_STRING_COMPARE_EASY	PROC
		;
		;DS:SI IS STRING1, ES:DI IS STRING2
		;CX IS BYTE-LENGTH OF ONE OF THEM
		;
		SHR	ECX,2

		INC	ECX		;ROUND UP TO TEST 0 AT END

		REPE	CMPSD

		RET

CASE_STRING_COMPARE_EASY	ENDP


CASE_STRING_COMPARE_HARD	PROC
		;
		;MOST CASES STILL MATCH ANYWAY
		;
		SHR	ECX,2

		INC	ECX			;COUNT A ZERO

		REPE	CMPSD			;USUAL CASE IS CASE MATCHES

		JNZ	L5$

		RET

L5$:
		PUSHM	EBP,EDX
		PUSHM	EBX,EAX

		XOR	EAX,EAX
		XOR	EBX,EBX

		MOV	EBP,OFF UPPER_TABLE
		;
		;TRY IGNORING CASE...
		;
		MOV	AL,[ESI-4]

		SUB	ESI,3
		MOV	BL,[EDI-4]

		SUB	EDI,3
		INC	ECX
L6$:
		MOV	DL,[EBP+EAX]
		MOV	AL,[ESI]

		INC	ESI
		MOV	DH,[EBP+EBX]

		MOV	BL,[EDI]
		INC	EDI

		CMP	DL,DH
		JNZ	L9$

		MOV	DL,[EBP+EAX]
		MOV	AL,[ESI]

		INC	ESI
		MOV	DH,[EBP+EBX]

		MOV	BL,[EDI]
		INC	EDI

		CMP	DL,DH
		JNZ	L9$

		MOV	DL,[EBP+EAX]
		MOV	AL,[ESI]

		INC	ESI
		MOV	DH,[EBP+EBX]

		MOV	BL,[EDI]
		INC	EDI

		CMP	DL,DH
		JNZ	L9$

		MOV	DL,[EBP+EAX]
		MOV	AL,[EBP+EBX]

		CMP	DL,AL
		JNZ	L9$

		DEC	ECX
		JZ	L9$

		MOV	AL,[ESI]
		INC	ESI

		MOV	BL,[EDI]
		INC	EDI

		JMP	L6$

L9$:
		POPM	EAX,EBX

		POPM	EDX,EBP

		RET

CASE_STRING_COMPARE_HARD	ENDP


		END
