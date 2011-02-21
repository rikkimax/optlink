		TITLE	SYMMAP - Copyright (C) SLR Systems 1994

		INCLUDE	MACROS
		INCLUDE	SYMBOLS
if	fg_segm OR fg_pe
		INCLUDE	SEGMSYMS
		INCLUDE	SECTIONS
endif
if	fg_pe
		INCLUDE	PE_STRUC
endif
if	fg_dosx
		INCLUDE	EXES
endif

		PUBLIC	ALLOW_SYMBOLS_MAP,DO_SYMBOLS_MAP

if	fg_segm OR fg_pe
		PUBLIC	ALLOW_EXPORTS_MAP,DO_EXPORTS_MAP
endif


		.DATA

		EXTERNDEF	XOUTBUF:BYTE,EXETYPE_FLAG:BYTE

		EXTERNDEF	EXP_BUFFER:DWORD,ICODE_OS2_NUMBER:DWORD,PE_BASE:DWORD,ICODE_SM_START:DWORD
		EXTERNDEF	FIRST_ENTRYNAME_GINDEX:DWORD

		EXTERNDEF	PUBS_DEFINED_SEM:GLOBALSEM_STRUCT,ENTRYNAME_GARRAY:STD_PTR_S,EXPS_DEFINED_SEM:GLOBALSEM_STRUCT
		EXTERNDEF	SYMBOL_GARRAY:STD_PTR_S,IMPNAME_GARRAY:STD_PTR_S,PE_OBJECT_GARRAY:STD_PTR_S,IMPMOD_GARRAY:STD_PTR_S


		.CODE	MIDDLE_TEXT

		EXTERNDEF	_capture_eax:proc
		EXTERNDEF	_release_eax:proc
		EXTERNDEF	_release_eax_bump:proc
		EXTERNDEF	HEADER_OUT:PROC,UNUSE_ENTRYNAMES:PROC,TQUICK_ENTRYNAMES:PROC,HEXWOUT:PROC,MOVE_ASCIZ_ESI_EDI:PROC
		EXTERNDEF	SPACE_OUT:PROC,LINE_OUT:PROC,TQUICK_ALPHA:PROC,CBTA16:PROC,TQUICK_NUMERIC:PROC,UNUSE_SYMBOLS:PROC
		EXTERNDEF	RELEASE_EAX_BUFFER:PROC,MOVE_SLEN:PROC,UNUSE_EXPORTS:PROC,HEXDWOUT:PROC
		EXTERNDEF	UNUSE_IMPORTS:PROC,CAPTURE_EAX:PROC,RELEASE_EAX:PROC,SAY_VERBOSE:PROC,UNUSE_SORTED_EXPORTS:PROC
		EXTERNDEF	_do_dossleep_0:PROC


if	fg_segm OR fg_pe

COMMENT	|

 Address   Export                  Alias

 0027:3AC0 AbortTest               AbortTest

|

SYM_VARS	STRUC

QN_BUFFER_BP		DD	256K/(page_size/4) DUP(?)	;256K SYMBOLS SORTING

N_SYM_START		=	$

SYM_HEADER1_HELPER_BP	DD	?	;**
SYM_HEADER2_HELPER_BP	DD	?	;**
EXP_HEADER_HELPER_BP	DD	?	;**
SYM_OUT_HELPER_BP	DD	?	;**
SYM_COLON_ADDR_BP	DD	?	;**
SYM_DESCR_ADDR_BP	DD	?	;**
SYM_NAME_ADDR_BP	DD	?	;**
SYM_IMPORT_ADDR_BP	DD	?	;**
EXP_NAME_OFFSET_BP	DD	?	;**
EXP_ALIAS_OFFSET_BP	DD	?	;**

N_SYM_HELPERS		=	($-N_SYM_START)/4

WM_BLK_PTR_BP		DD	?
WM_CNT_BP		DD	?
WM_PTR_BP		DD	?

SYM_VARS	ENDS


FIX	MACRO	X

X	EQU	([EBP-SIZE SYM_VARS].(X&_BP))

	ENDM


FIX	QN_BUFFER
FIX	SYM_HEADER1_HELPER
FIX	SYM_HEADER2_HELPER
FIX	EXP_HEADER_HELPER
FIX	SYM_OUT_HELPER
FIX	SYM_COLON_ADDR
FIX	SYM_DESCR_ADDR
FIX	SYM_NAME_ADDR
FIX	SYM_IMPORT_ADDR
FIX	EXP_NAME_OFFSET
FIX	EXP_ALIAS_OFFSET
FIX	WM_BLK_PTR
FIX	WM_CNT
FIX	WM_PTR


ALLOW_EXPORTS_MAP	PROC
		;
		;
		;
if	fgh_mapthread
		BITT	_HOST_THREADED
		JZ	DO_EXPORTS_MAP

		RELEASE	EXPS_DEFINED_SEM

		RET

endif

ALLOW_EXPORTS_MAP	ENDP


DO_EXPORTS_MAP	PROC
		;
		;IF GENERATING A MAP FILE WITH SYMBOLS, AND GENERATING SEGMENTED OUTPUT, AND THERE ARE EXPORTS...
		;
		BITT	SYMBOLS_OUT
		JZ	L9$

if	fg_pe
		BITT	OUTPUT_PE
		MOV	ESI,OFF PE_STUFF
		JNZ	L1$
endif
if	fg_segm
		BITT	OUTPUT_SEGMENTED
		MOV	ESI,OFF SEGM_STUFF
		JNZ	L1$
endif
		JMP	L8$

L1$:
		MOV	EAX,FIRST_ENTRYNAME_GINDEX

		TEST	EAX,EAX
		JZ	L8$

		PUSH	EBP
		MOV	EBP,ESP
		ASSUME	EBP:PTR SYM_VARS

		SUB	ESP,SIZE SYM_VARS
		MOV	ECX,N_SYM_HELPERS

		LEA	EDI,SYM_HEADER1_HELPER
		REP	MOVSD
		;
		;
		;
		MOV	EAX,EXP_HEADER_HELPER
		CALL	HEADER_OUT

		CAPTURE	EXPS_DEFINED_SEM

		YIELD					;SO STOP WORKS
if	debug
		MOV	EAX,OFF WRITING_MAP_EXPORTS_MSG
		CALL	SAY_VERBOSE
endif
		MOV	AL,' '
		MOV	XOUTBUF,AL
		MOV	XOUTBUF+10,AL
		MOV	XOUTBUF+14,AL			;FOR PE
		MOV	XOUTBUF+5,':'
		CALL	TBLINIT_1
		JMP	L5$

L4$:
		CALL	OUTPUT_ENTRYNAME
L5$:
		CALL	TBLNEXT_1
		JNZ	L4$

		MOV	ESP,EBP
		POP	EBP
L8$:
		CALL	UNUSE_SORTED_EXPORTS

		CALL	UNUSE_ENTRYNAMES		;FREE THEM UP
L9$:
		RET

DO_EXPORTS_MAP	ENDP


TBLINIT		PROC	PRIVATE

		LEA	ECX,QN_BUFFER+8		;TABLE OF BLOCKS OF INDEXES
		MOV	EAX,QN_BUFFER+4	;FIRST BLOCK

		JMP	TBLINIT_2

TBLINIT		ENDP


TBLINIT_1 	PROC	NEAR
		;
		;
		;
		MOV	ECX,OFF EXP_BUFFER+8	;TABLE OF BLOCKS OF INDEXES
		MOV	EAX,EXP_BUFFER+4	;FIRST BLOCK
TBLINIT_2::
		MOV	WM_BLK_PTR,ECX		;POINTER TO NEXT BLOCK

		TEST	EAX,EAX
		JZ	L9$
		;
		MOV	ECX,PAGE_SIZE/4
		MOV	WM_PTR,EAX		;PHYSICAL POINTER TO NEXT INDEX TO PICK

		MOV	WM_CNT,ECX
		OR	AL,1
L9$:
		RET

TBLINIT_1 	ENDP


TBLNEXT_1 	PROC	NEAR
		;
		;GET NEXT SYMBOL INDEX IN AX, DS:SI POINTS
		;
		MOV	EDX,WM_CNT
		MOV	ECX,WM_PTR

		DEC	EDX			;LAST ONE?
		JZ	L5$

		MOV	EAX,[ECX]		;NEXT INDEX
		ADD	ECX,4

		TEST	EAX,EAX
		JZ	L9$

		MOV	WM_PTR,ECX		;UPDATE POINTER
		MOV	WM_CNT,EDX		;UPDATE COUNTER

L9$:
		RET

L5$:
		;
		;NEXT BLOCK
		;
		MOV	EAX,[ECX]
		MOV	ECX,WM_BLK_PTR

		MOV	WM_CNT,PAGE_SIZE/4

		MOV	EDX,[ECX]
		ADD	ECX,4

		MOV	WM_PTR,EDX
		MOV	WM_BLK_PTR,ECX

		TEST	EAX,EAX

		RET


TBLNEXT_1 	ENDP


OUTPUT_ENTRYNAME	PROC	NEAR
		;
		;EAX IS ENTRYNAME GINDEX
		;
		CONVERT	EAX,EAX,ENTRYNAME_GARRAY
		ASSUME	EAX:PTR ENT_STRUCT

		LEA	ESI,[EAX]._ENT_TEXT
		MOV	ECX,[EAX]._ENT_INTERNAL_NAME_GINDEX

		MOV	EDI,EXP_NAME_OFFSET			;MOVE NAME TEXT WHILE IT IS THERE
		PUSH	ECX

		CALL	MOVE_ASCIZ_ESI_EDI
		ASSUME	EAX:NOTHING

		POP	ESI
		PUSH	EDI
		CONVERT	ESI,ESI,SYMBOL_GARRAY
		ASSUME	ESI:PTR SYMBOL_STRUCT

		MOV	EAX,[ESI]._S_OS2_NUMBER
		MOV	ECX,[ESI]._S_OFFSET		;THIS IS TOTAL OFFSET

		MOV	BL,[ESI]._S_NSYM_TYPE
		CALL	SYM_OUT_HELPER

		POP	EDI
		MOV	ECX,EXP_ALIAS_OFFSET

		CALL	SPACE_OUT

		LEA	ESI,[ESI]._S_NAME_TEXT
		MOV	BPTR [EDI],' '

		INC	EDI
		CALL	MOVE_ASCIZ_ESI_EDI

		JMP	LINE_OUT

OUTPUT_ENTRYNAME	ENDP

endif


ALLOW_SYMBOLS_MAP	PROC
		;
		;
		;
if	fgh_mapthread
		BITT	_HOST_THREADED
		JZ	DO_SYMBOLS_MAP

		RELEASE	PUBS_DEFINED_SEM

		RET

endif

ALLOW_SYMBOLS_MAP	ENDP


DO_SYMBOLS_MAP	PROC
		;
		;
		;
		BITT	SYMBOLS_OUT
		JZ	L9$

		PUSH	EBP
		MOV	EBP,ESP
		ASSUME	EBP:PTR SYM_VARS

		SUB	ESP,SIZE SYM_VARS
if	fgh_mapthread

		BITT	_HOST_THREADED
		JZ	L0$

		CAPTURE	PUBS_DEFINED_SEM	;WAIT FOR DEFPUBS TO FINISH

		YIELD				;SO STOP WORKS

		CALL	_do_dossleep_0		;GIVE FIXUPP2 ANOTHER CHANCE
L0$:

endif						;BEFORE GRABBING CPU FOR SORT

if	fg_pe
		BITT	OUTPUT_PE
		MOV	ESI,OFF PE_STUFF
		JNZ	L1$
endif

if	fg_segm
		BITT	OUTPUT_SEGMENTED
		MOV	ESI,OFF SEGM_STUFF
		JNZ	L1$
endif
if	fg_dosx
		CMP	EXETYPE_FLAG,DOSX_EXE_TYPE
		MOV	ESI,OFF DOSX_STUFF
		JZ	L1$
endif
		MOV	ESI,OFF REAL_STUFF
L1$:
		LEA	EDI,SYM_HEADER1_HELPER
		MOV	ECX,N_SYM_HELPERS

		REP	MOVSD

		MOV	QN_BUFFER,0		;MAKE SURE SORT HAPPENS

		BITT	ALPHA_ORDER_ALSO
		JZ	NOT_ALPHA
		;
		;output symbols in alphabetical order...
		;
if	debug
		MOV	EAX,OFF ASORTING_MAP_SYMBOLS_MSG
		CALL	SAY_VERBOSE
endif
		LEA	EAX,QN_BUFFER
		CALL	TQUICK_ALPHA
if	debug
		MOV	EAX,OFF WRITING_SYMBOLS_MSG
		CALL	SAY_VERBOSE
endif
		MOV	EAX,SYM_HEADER1_HELPER
		CALL	OUTPUT_SYMBOLS
		;
		;now, resort by value
		;
NOT_ALPHA:
if	debug
		MOV	EAX,OFF NSORTING_MAP_SYMBOLS_MSG
		CALL	SAY_VERBOSE
endif
		LEA	EAX,QN_BUFFER
		CALL	TQUICK_NUMERIC

		MOV	EAX,OFF WRITING_SYMBOLS_MSG
		CALL	SAY_VERBOSE

		MOV	EAX,SYM_HEADER2_HELPER
		CALL	OUTPUT_SYMBOLS

		CALL	UNUSE_SYMBOLS
if	fg_segm OR fg_pe
		CALL	UNUSE_IMPORTS
endif
		;
		;FIRST, RELEASE ANY BLOCKS USED FOR SYMBOL POINTERS...
		;
		LEA	EAX,QN_BUFFER
		CALL	RELEASE_EAX_BUFFER

if	debug
		MOV	EAX,OFF LEAVING_MAP_MSG
		CALL	SAY_VERBOSE
endif
		MOV	ESP,EBP
		POP	EBP
L9$:
		RET

DO_SYMBOLS_MAP	ENDP


OUTPUT_SYMBOLS	PROC	NEAR
		;
		;
		;
		CALL	HEADER_OUT

		MOV	EDI,OFF XOUTBUF
		MOV	EAX,'    '

		MOV	ECX,6
		MOV	EBX,SYM_COLON_ADDR

		REP	STOSD

		MOV	BPTR [EBX],':'
		CALL	TBLINIT

		JMP	OS_1

OS_LOOP:
		CALL	OUTPUT_SYMBOL
OS_1:
		CALL	TBLNEXT_1

		JNZ	OS_LOOP

		RET

OUTPUT_SYMBOLS	ENDP


if	fg_prot


OUT_SYM_SEGM	PROC	NEAR
		;
		;DS:SI IS SYMBOL
		;DX:CX IS COMPLETE ADDRESS
		;AX IS FRAME
		;
		CMP	BL,NSYM_ASEG
		JZ	OUT_SYM_REAL

		MOV	EDI,OFF XOUTBUF+1
		CALL	HEXWOUT		;PRINT SEGMENT #

		INC	EDI		;SKIP COLON
		MOV	EAX,ECX

		JMP	HEXWOUT		;PRINT OFFSET FROM SEGMENT

;		RET

OUT_SYM_SEGM	ENDP

endif

if	fg_pe

OUT_SYM_PE	PROC	NEAR
		;
		;DS:SI IS SYMBOL
		;DX:CX IS COMPLETE ADDRESS
		;AX IS SECTION
		;
		CMP	BL,NSYM_ASEG
		JZ	OUT_SYM_REAL

		TEST	EAX,EAX
		JZ	L5$

		CONVERT	EAX,EAX,PE_OBJECT_GARRAY
		ASSUME	EAX:PTR PE_IOBJECT_STRUCT

		PUSH	ESI
		MOV	ESI,EAX
		ASSUME	ESI:PTR PE_IOBJECT_STRUCT

		MOV	EAX,[EAX]._PEOBJECT_NUMBER

		MOV	EDI,OFF XOUTBUF+1
		CALL	HEXWOUT		;PRINT PE_SECTION #

		MOV	EAX,ECX
		MOV	ECX,PE_BASE

		INC	EDI
		SUB	EAX,ECX

		MOV	ECX,[ESI]._PEOBJECT_RVA
		POP	ESI

		SUB	EAX,ECX
		JMP	HEXDWOUT

L5$:
		MOV	EDI,OFF XOUTBUF+1
		CALL	HEXWOUT

		MOV	EAX,ECX
		INC	EDI

		JMP	HEXDWOUT

OUT_SYM_PE	ENDP

endif

if	fg_dosx

OUT_SYM_DOSX	PROC	NEAR
		;
		;DS:SI IS SYMBOL
		;DX:CX IS COMPLETE ADDRESS
		;AX IS FRAME
		;
		MOV	EDX,EAX
		MOV	EDI,OFF XOUTBUF+1

		SHL	EDX,4
		CALL	HEXWOUT			;PRINT FRAME

		MOV	EAX,ECX
		INC	EDI			;SKIP COLON

		SUB	EAX,EDX			;SUBTRACT FRAME FROM FULL ADDRESS
		JMP	HEXDWOUT		;PRINT OFFSET
;		RET

OUT_SYM_DOSX	ENDP

endif

OUT_SYM_REAL	PROC	NEAR
		;
		;DS:SI IS SYMBOL
		;DX:CX IS COMPLETE ADDRESS
		;AX IS FRAME
		;
		MOV	EDX,EAX
		MOV	EDI,OFF XOUTBUF+1

		SHL	EDX,4
		CALL	HEXWOUT			;PRINT FRAME

		MOV	EAX,ECX
		INC	EDI			;SKIP COLON

		SUB	EAX,EDX			;SUBTRACT FRAME FROM FULL ADDRESS
		JMP	HEXWOUT			;PRINT OFFSET
;		RET

OUT_SYM_REAL	ENDP


OUTPUT_SYMBOL	PROC	NEAR
		;
		;
		;
		CONVERT	EAX,EAX,SYMBOL_GARRAY
		ASSUME	EAX:PTR SYMBOL_STRUCT

		MOV	ESI,EAX
		MOV	BL,[EAX]._S_NSYM_TYPE

		MOV	ECX,[EAX]._S_OFFSET	;THIS IS TOTAL OFFSET
		MOV	EAX,[EAX]._S_OS2_NUMBER	;FRAME
		ASSUME	EAX:NOTHING

if	fg_segm OR fg_pe
		CMP	BL,NSYM_IMPORT
		JZ	OS_IMPORT
endif

		CALL	SYM_OUT_HELPER		;PRINT FRAME:OFFSET, MAYBE ADJUST OFFSET

		ASSUME	ESI:PTR SYMBOL_STRUCT

		MOV	EDI,SYM_DESCR_ADDR
		MOV	EBX,ESI

if	any_overlays
		XOR	ECX,ECX			;CLEAR OUT SECTION #
endif
		MOV	AL,[ESI]._S_NSYM_TYPE
		MOV	EDX,' sbA'

		CMP	AL,NSYM_ASEG
		JZ	SYM_IS_ASEG		;RARE JUMPS

		CMP	AL,NSYM_CONST
		JZ	SYM_IS_ASEG

		MOV	EDX,'    '		;MUST CLEAR OUT NON-SPACE FROM BEFORE

if	any_overlays
		BITT	DOING_OVERLAYS
		JZ	SYM_IS_ASEG
		;
		;IF DOING OVERLAYS, MARK SYMBOLS AS Res OR Ovl
		;
		LEA	SI,RES_A
		TEST	[BX]._S_PLTYPE,MASK LEVEL_0_SECTION
		JNZ	SYM_IS_ASEG
		MOV	CX,[BX]._S_SECTION_GINDEX
		LEA	SI,OVL_A
endif

SYM_IS_ASEG:
		LEA	ESI,[ESI]._S_NAME_TEXT
		MOV	DPTR [EDI],EDX

		MOV	EDI,SYM_NAME_ADDR
		CALL	MOVE_ASCIZ_ESI_EDI
if	any_overlays
		OR	CX,CX
		JNZ	5$
6$:
endif
SYM_AFTER_NAME:
if	fg_pe
		GETT	AL,OUTPUT_PE
		MOV	ECX,OFF XOUTBUF+48

		OR	AL,AL
		JZ	L9$

		CALL	SPACE_OUT
		ASSUME	EBX:PTR SYMBOL_STRUCT

		MOV	EAX,[EBX]._S_OFFSET
		CALL	HEXDWOUT
endif
L9$:
		JMP	LINE_OUT
;		RET

if	any_overlays
		CALL	OUT_SECT_NUMBER
		JMP	6$
endif

if	fg_segm OR fg_pe

OS_IMPORT:
		GETT	DL,OUTPUT_PE
		MOV	EDI,OFF XOUTBUF+1

		OR	DL,DL
		JZ	OSI_1

		CALL	SYM_OUT_HELPER

		MOV	EBX,ESI
		JMP	OSI_2


OSI_1:
		MOV	EAX,'0000'
		MOV	EBX,ESI

		MOV	[EDI],EAX
		MOV	[EDI+5],EAX

OSI_2:
		MOV	EAX,SYM_DESCR_ADDR
		MOV	ECX,' pmI'

		MOV	EDI,SYM_NAME_ADDR
		LEA	ESI,[EBX]._S_NAME_TEXT

		MOV	[EAX],ECX
		CALL	MOVE_ASCIZ_ESI_EDI

		MOV	ECX,SYM_IMPORT_ADDR	;XOUTBUF+38
		CALL	SPACE_OUT

		MOV	BPTR [EDI],'('
		INC	EDI
		;
		;KERNEL.34)
		;
		MOV	ESI,[EBX]._S_IMP_MODULE		;MODULE I'M IMPORTED FROM
		MOV	AL,[EBX]._S_REF_FLAGS

		MOV	ECX,[EBX]._S_IMP_IMPNAME_GINDEX	;IF BY NAME
		MOV	EBX,[EBX]._S_IMP_ORDINAL		;ORDINAL #

		PUSHM	ECX,EBX,EAX

		CONVERT	ESI,ESI,IMPMOD_GARRAY
		ADD	ESI,IMPMOD_STRUCT._IMPM_TEXT
		CALL	MOVE_ASCIZ_ESI_EDI

		MOV	BPTR [EDI],'.'
		INC	EDI
		POPM	EAX,EBX,ESI

		TEST	AL,MASK S_IMP_ORDINAL
		JNZ	OS_IMP_ORD

		CONVERT	ESI,ESI,IMPNAME_GARRAY
		ADD	ESI,IMPNAME_STRUCT._IMP_TEXT
		CALL	MOVE_ASCIZ_ESI_EDI

		JMP	OS_IMP_DONE

OS_IMP_ORD:
		MOV	EAX,EBX
		MOV	ECX,EDI
		CALL	CBTA16

		MOV	EDI,EAX
OS_IMP_DONE:
		MOV	BPTR [EDI],')'
		INC	EDI
		JMP	LINE_OUT
;		RET

endif

OUTPUT_SYMBOL	ENDP

if	any_overlays

		ASSUME	DS:NOTHING
OUT_SECT_NUMBER	PROC	NEAR
		;
		;CX IS SECTION_GINDEX
		;
		MOV	AX,'( '
		STOSW
		MOV	AX,CX
		XOR	DX,DX
		CALL	HEXDWOUTSH
		MOV	AL,')'
		STOSB
		RET

OUT_SECT_NUMBER	ENDP

endif

		.CONST

		ALIGN	4

REAL_STUFF	DD	SYM1_HEADER,SYM2_HEADER,0,OUT_SYM_REAL,XOUTBUF+5,XOUTBUF+12,XOUTBUF+17,XOUTBUF+38

if	fg_dosx

DOSX_STUFF	DD	SYM1_HEADER,SYM2_HEADER,0,OUT_SYM_DOSX,XOUTBUF+5,XOUTBUF+16,XOUTBUF+20,XOUTBUF+38

endif

if	fg_segm

SEGM_STUFF	DD	SYM1_HEADER,SYM2_HEADER,EXP_HEADER_SEGM,OUT_SYM_SEGM,XOUTBUF+5,XOUTBUF+12,XOUTBUF+17,XOUTBUF+38,XOUTBUF+11,XOUTBUF+34

endif

if	fg_pe

PE_STUFF	DD	SYM1_HEADER_PE,SYM2_HEADER_PE,EXP_HEADER_PE,OUT_SYM_PE,XOUTBUF+5,XOUTBUF+16,XOUTBUF+21,XOUTBUF+42,XOUTBUF+15,XOUTBUF+38

endif


SYM1_HEADER	DB	SIZEOF SYM1_HEADER-1,0DH,0AH,\
			'  Address         Publics by Name',\
			0DH,0AH,0DH,0AH

SYM2_HEADER	DB	SIZEOF SYM2_HEADER-1,0DH,0AH,\
			'  Address         Publics by Value',\
			0DH,0AH,0DH,0AH

if	fg_pe

SYM1_HEADER_PE	DB	SIZEOF SYM1_HEADER_PE-1,0DH,0AH,\
			'  Address         Publics by Name               Rva+Base',\
			0DH,0AH,0DH,0AH

SYM2_HEADER_PE	DB	SIZEOF SYM2_HEADER_PE-1,0DH,0AH,\
			'  Address         Publics by Value              Rva+Base',\
			0DH,0AH,0DH,0AH

EXP_HEADER_PE	DB	SIZEOF EXP_HEADER_PE-1,0DH,0AH,\
			' Address       Export                  Alias',\
			0DH,0AH,0DH,0AH
endif

if	fg_segm
EXP_HEADER_SEGM	DB	SIZEOF EXP_HEADER_SEGM-1,0DH,0AH,\
			' Address   Export                  Alias',\
			0DH,0AH,0DH,0AH
endif

if	debug
WRITING_MAP_EXPORTS_MSG		DB	SIZEOF WRITING_MAP_EXPORTS_MSG-1,'Writing Exported Symbols to .MAP file',0DH,0AH
ASORTING_MAP_SYMBOLS_MSG	DB	SIZEOF ASORTING_MAP_SYMBOLS_MSG-1,'Alpha Sorting Symbols for .MAP file',0DH,0AH
NSORTING_MAP_SYMBOLS_MSG	DB	SIZEOF NSORTING_MAP_SYMBOLS_MSG-1,'Numeric Sorting Symbols for .MAP file',0DH,0AH
LEAVING_MAP_MSG			DB	SIZEOF LEAVING_MAP_MSG-1,'Finished Symbols .MAP',0DH,0AH
endif

WRITING_SYMBOLS_MSG	DB	SIZEOF WRITING_SYMBOLS_MSG-1,'Writing Symbols to .MAP file',0DH,0AH


		END
