		TITLE	INITPOOL - Copyright (C) 1992 SLR Systems

		INCLUDE	MACROS

		PUBLIC	INIT_POOL

		.CODE	ROOT_TEXT

	SOFT	EXTP	GET_NEW_LOG_BLK

		ASSUME	DS:NOTHING

INIT_POOL	PROC
		;
		;SI MUST BE POINTING TO _STUFF, INITIALIZE  WITHOUT HASH TABLE
		;
IF 0
		PUSHM	ES,DI,CX,BX,AX

		CALL	GET_NEW_LOG_BLK 	;LEAVE IN FAST MEMORY

		MOV	DGROUP:[SI].ALLO_BLK_LIST,AX
		MOV	DGROUP:[SI].ALLO_PTR.OFFS,0
		MOV	DGROUP:[SI].ALLO_PTR.SEGM,AX
		MOV	DGROUP:[SI].ALLO_CNT,PAGE_SIZE

		LEA	
		FIXES
		LEA	DI,ALLO_FIRST[SI]
		STOSW			;FIRST BLOCK
		XCHG	AX,BX
		MOV	AX,PAGE_SIZE-16
		STOSW			;BYTE COUNT LEFT
		MOV	AX,16
		STOSW			;PTR.OFFS
		MOV	AX,BX
		STOSW			;PTR.SEGM
		XOR	AX,AX
		STOSW			;NB_PTR.OFFS
		MOV	AX,BX
		STOSW
		MOV	AX,8		;NB_COUNT
		STOSW
		MOV	ES,BX
		ASSUME	ES:NOTHING
		CONV_ES
		XOR	DI,DI
		MOV	CX,8
		XOR	AX,AX
		REP	STOSW

		POPM	AX,BX,CX,DI,ES
ENDIF
		RET

INIT_POOL	ENDP

		END
