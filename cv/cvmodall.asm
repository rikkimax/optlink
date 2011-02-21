		TITLE	CVMODALL - Copyright (c) SLR Systems 1994

		INCLUDE	MACROS
		INCLUDE	MODULES

		PUBLIC	CV_MODULES_ALL_4


		.DATA

		EXTERNDEF	CURNMOD_GINDEX:DWORD,FIRST_MODULE_GINDEX:DWORD,CURNMOD_NUMBER:DWORD

		EXTERNDEF	MODULE_GARRAY:STD_PTR_S


		.CODE	PASS2_TEXT

		EXTERNDEF	CV_MODULE_4:PROC


CV_MODULES_ALL_4	PROC
		;
		;OUTPUT ALL MODULE RECORDS AND THEIR INDEXES
		;
		MOV	EAX,FIRST_MODULE_GINDEX
		JMP	MOD_NEXT

MOD_LOOP:
		CALL	CV_MODULE_4

		MOV	EAX,CURNMOD_GINDEX
		CONVERT	EAX,EAX,MODULE_GARRAY
		ASSUME	EAX:PTR MODULE_STRUCT

		MOV	EAX,[EAX]._M_NEXT_MODULE_GINDEX
MOD_NEXT:
		MOV	ECX,CURNMOD_NUMBER
		MOV	CURNMOD_GINDEX,EAX

		INC	ECX
		TEST	EAX,EAX

		MOV	CURNMOD_NUMBER,ECX
		JNZ	MOD_LOOP

		MOV	CURNMOD_NUMBER,EAX

		RET

CV_MODULES_ALL_4	ENDP


		END
