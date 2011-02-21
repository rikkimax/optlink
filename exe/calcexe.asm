		TITLE	CALCEXE - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS
		INCLUDE	EXES


		PUBLIC	CALC_EXE_LEN,DO_EXEHEADER


		.DATA

		EXTERNDEF	NEW_REPT_ADDR:DWORD,FINAL_HIGH_WATER:DWORD,EXE_OUT_POSITION:DWORD,HIGH_PC:DWORD,DOSX_HDR_SIZE:DWORD

		EXTERNDEF	EXEHEADER:EXE


		.CODE	PASS2_TEXT


CALC_EXE_LEN	PROC

if	fg_slrpack
		BITT	SLRPACK_FLAG
		JZ	L23$

		MOV	EAX,NEW_REPT_ADDR
		RET

L23$:
endif
		MOV	EAX,FINAL_HIGH_WATER
		MOV	ECX,EXE_OUT_POSITION

		SUB	EAX,ECX

		RET

CALC_EXE_LEN	ENDP


DO_EXEHEADER	PROC
		;
		;DO EXEHEADER
		;
		PUSHM	ESI,EBX

		MOV	ECX,FINAL_HIGH_WATER
		MOV	EDX,DOSX_HDR_SIZE

		MOV	ESI,OFF EXEHEADER
		ASSUME	ESI:PTR EXE
		SUB	ECX,EDX

		MOV	EDX,ECX
		AND	ECX,511

		MOV	[ESI]._EXE_LEN_MOD_512,CX
		ADD	EDX,511

		SHR	EDX,9

		MOV	[ESI]._EXE_LEN_PAGE_512,DX
		;
		;MIN ABOVE...
		;
		MOV	ECX,EXE_OUT_POSITION
		MOV	EBX,FINAL_HIGH_WATER

		MOV	EAX,HIGH_PC
		SUB	EBX,ECX

		ADD	EAX,15
		ADD	EBX,15

		AND	BL,0F0H

		SUB	EAX,EBX
		JNC	L5$

		XOR	EAX,EAX
L5$:
		SHR	EAX,4
		MOV	EDX,DOSX_HDR_SIZE

		MOV	[ESI]._EXE_MIN_ABOVE,AX
		XOR	ECX,ECX

		CMP	[ESI]._EXE_MAX_ABOVE,AX
		JNC	L7$

		MOV	[ESI]._EXE_MAX_ABOVE,AX
L7$:
		TEST	EDX,EDX
		JZ	L9$
		MOV	[ESI]._EXE_REG_SS,CX
		MOV	[ESI]._EXE_REG_SP,CX
L9$:
		MOV	EAX,ESI

		POPM	EBX,ESI

		RET

DO_EXEHEADER	ENDP


		END
