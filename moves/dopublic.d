// DOPUBLIC - Copyright (c) SLR Systems 1994

import symbols;
import segments;
import cddata;

PUBLIC	FIX_COMMUNAL_ENTRY,
	DO_PUBLIC,
	PREV_DEF_FAIL,
	FIX_VIRDEF_ENTRY,
	FIX_COMDAT_ENTRY


const WEP_HASH	= 0x9E2A;


DO_PUBLIC(EDX)
{
	// EDX IS HASH

	PUSH	ESI

    version(fg_td)
    {
	TPTR_STRUCT* ESI = &SYMBOL_TPTR;
	if (EDX == WEP_HASH)
		goto WEP_SPEC;
      WEP__WEP:
	;
    }
    // EAX IS GINDEX, ECX IS PHYS
    FAR_INSTALL();
    ASSUME	ECX:PTR SYMBOL_STRUCT
WEP_FINISH:
    EDX = DPTR [ECX]._S_NSYM_TYPE & NSYM_ANDER;
		PUSH	EBX
    version(fg_td)
    {
	LAST_PUBDEF_GINDEX = EAX;	// FOR BORLAND DEBUG INFO
    }
    switch (EDX)
    {
	case NSYM_UNDEFINED:
		goto	DP_2	// FRESH SYMBOL, JUST DEFINE
	case NSYM_ASEG:
		goto	PREV_ASEG	// ALREADY ASEG, COMPARE
	case NSYM_RELOC:
		goto	PREV_RELOC	// ALREADY RELOCATABLE, COMMON?
	case NSYM_COMM_NEAR:
	case NSYM_COMM_FAR:
	case NSYM_COMM_HUGE:
		goto	PREV_COMMUNAL
	case NSYM_CONST:
		goto	PREV_CONST	// ALREADY CONSTANT, COMPARE
	case NSYM_LIBRARY:
		goto	DP_LIB	// IN A LIB, NOT REFERENCED, JUST DEFINE
	case NSYM_IMPORT:
		goto	PREV_DEF_FAIL_A	// IMPORTED, CANNOT BE DEFINED
	case NSYM_PROMISED:
		goto	DP_3	// JUST DEFINE
	case NSYM_EXTERNAL:
		goto	DP_1	// REMOVE FROM LIST
	case NSYM_WEAK_EXTRN:
		goto	DP_4	// REMOVE FROM LIST
	case NSYM_POS_WEAK:
		goto	DP_2	// POSSIBLE WEAK, JUST DEFINE
	case NSYM_LIBRARY_LIST:
		goto	DP_5	// IN LIBRARY LIST, REMOVE IT
	case NSYM__IMP__UNREF:
		goto	DP_2	// JUST DEFINE
	case NSYM_ALIASED:
		goto	DP_ALIASED	// DEFINING AN ALIASED SYMBOL
	case NSYM_COMDAT:
		goto	PREV_COMDAT	// ALREADY A COMDAT
	case NSYM_WEAK_DEFINED:
		goto	DP_4A
	case NSYM_WEAK_UNREF:
	case NSYM_ALIASED_UNREF:
	case NSYM_POS_LAZY:
		goto	DP_2	// JUST DEFINE
	case NSYM_LAZY:
		goto	DP_LAZY	// UNDO, THEN DEFINE
	case NSYM_LAZY_UNREF:
		goto	DP_2	// JUST DEFINE
	case NSYM_ALIAS_DEFINED:
		goto	DP_ALIAS_DEFINED // UNDO, THEN DEFINE
	case NSYM_LAZY_DEFINED:
		goto	DP_LAZY_DEFINED	// UNDO, THEN DEFINE
	case NSYM_NCOMM_UNREF:
	case NSYM_FCOMM_UNREF:
	case NSYM_HCOMM_UNREF:
		goto	DP_COMM_UNREF	// CHECK CODE-DATA, THEN DEFINE
	case NSYM__IMP__:
		goto	DP__IMP
	case NSYM_UNDECORATED:
		goto	DP_3	// CANNOT
	default:
	    assert(0);
    }

    version(fg_td)
    {
WEP_SPEC:
	if ([ESI]._TP_LENGTH != 3)
		goto WEP__WEP;
	if (DPTR [ESI]._TP_TEXT != 'PEW')
		goto WEP__WEP;
	if (FIRST_WEP_GINDEX != 0)
		goto WEP_DO__WEP;
	FAR_INSTALL();
	FIRST_WEP_GINDEX = EAX;
	goto WEP_FINISH;

WEP_DO__WEP:

	// REPLACE NAME WITH __WEP


		PUSHM	EDI,ESI
	EDI = ESI;
		ASSUME	EDI:PTR TPTR_STRUCT
	ESI = OFF __WEP_TEXT;
		GET_NAME_HASH
		POPM	ESI,EDI
	goto WEP__WEP;

    }

DP__IMP:
	REMOVE_FROM__IMP__LIST();
	goto DP_11;

DP_LAZY:
	REMOVE_FROM_LAZY_LIST();
	goto DP_11;

DP_LAZY_DEFINED:
	REMOVE_FROM_LAZY_DEFINED_LIST();
	goto DP_11;

DP_ALIAS_DEFINED:
	REMOVE_FROM_ALIAS_DEFINED_LIST();
	goto DP_11;

DP_ALIASED:
	REMOVE_FROM_ALIASED_LIST();
	goto DP_11;

DP_5:

	// IN LIBRARY LIST, REMOVE IT


	REMOVE_FROM_LIBSYM_LIST();

	DL = [ECX]._S_REF_FLAGS;

	// WAS THIS ORIGINALLY A COMDEF?
	DL &= MASK S_DATA_REF;
	// NO, OK
		JZ	DP_11

	// YES, CHECK DATA-CODE
	goto DP_COMM_UNREF;

DP_4:

	// IN WEAK_EXTRN LIST, REMOVE IT PLEASE


	REMOVE_FROM_WEAK_LIST();
	goto DP_11;

DP_4A:

	// IN WEAK_DEFINED LIST, REMOVE IT PLEASE


	REMOVE_FROM_WEAK_DEFINED_LIST();
	goto DP_11;

DP_1:
	REMOVE_FROM_EXTERNAL_LIST();
DP_11:
DP_3:
DP_2::

	// ECX IS SYMBOL, EAX IS GINDEX



	// ADD TO SEGMENT...


	EDX = EAX;
	EAX = PUB_SEGMOD_GINDEX;

	EBX = CURNMOD_GINDEX;
	[ECX]._S_SEG_GINDEX = EAX;

	EAX = PUB_OFFSET;
	[ECX]._S_MOD_GINDEX = EBX;

	[ECX]._S_OFFSET = EAX;
	EBX = PUB_CV;

	[ECX]._S_CV_TYPE3 = BX;
	EAX = PUB_TYPE;

	EBX = PUB_GROUP_GINDEX;
    version(any_overlays)
    {
	if (AL == NSYM_CONST)
		goto PN_5;
	if (AL != NSYM_ASEG)
		goto PN_9;
PN_5:
	[ECX]._S_PLTYPE |= MASK LEVEL_0_SECTION;
PN_9:
    }
	// PUB_TYPE
	[ECX]._S_NSYM_TYPE = AL;

	// NEED TO LINK THIS INTO PUBLIC LIST


	EAX = MOD_FIRST_PUBLIC_GINDEX;
	MOD_FIRST_PUBLIC_GINDEX = EDX;

	[ECX]._S_NEXT_SYM_GINDEX = EAX;
	if (EBX)
		POPM	EBX,ESI
		JNZ	L9$

	return;

L9$:
	[ECX]._S_REF_FLAGS |= MASK S_USE_GROUP;

	return;

PREV_COMDAT:
	// SAFELY OVERIDES A PICK-ANY COMDAT

	EDX = [ECX]._S_CD_SEGMOD_GINDEX;
		CONVERT	EDX,EDX,SEGMOD_GARRAY
		ASSUME	EDX:PTR CDSEGMOD_STRUCT
	DL = [EDX]._CDSM_ATTRIB;
	DL &= 0F0H;

	// PICK ANY, DON'T EVEN CHECK SIZE
	if (DL != 10H)
		goto PREV_DEF_FAIL_A;
	REMOVE_FROM_COMDAT_LIST();
	goto DP_11;

		ASSUME	ECX:PTR SYMBOL_STRUCT
PREV_CONST:

	// MUST BE CONSTANT


	EAX = PUB_TYPE;
	EBX = PUB_OFFSET;

	if (AL != NSYM_CONST)
		goto PREV_DEF_FAIL_A;

	if (EBX != [ECX]._S_OFFSET)
		goto PREV_DEF_FAIL_A;

		POPM	EBX,ESI

	return;

PREV_ASEG:
	EAX = PUB_TYPE;

	if (AL == NSYM_ASEG)
		goto PR_0;

	goto PREV_DEF_FAIL_A;

PREV_RELOC:
	EAX = PUB_TYPE;

	if (AL != NSYM_RELOC)
		goto PREV_DEF_FAIL_A;
PR_0:

	// EAX IS GINDEX, ECX IS SYMBOL


	// FIRST, GROUP INFO MUST MATCH


	EBX = PUB_GROUP_GINDEX;
	AL = [ECX]._S_REF_FLAGS;

	if (EBX & EBX)
		JZ	PR_NOG

	if (AL & MASK S_USE_GROUP)
		JNZ	PREV_G_OK
PREV_DEF_FAIL_A:
	PREV_DEF_FAIL();

		POPM	EBX,ESI

	return;

PR_NOG:
	if (AL & MASK S_USE_GROUP)
		JNZ	PREV_DEF_FAIL_A
PREV_G_OK:
	EAX = PUB_OFFSET;
	EDX = [ECX]._S_OFFSET;

	if (EAX != EDX)
		goto PREV_DEF_FAIL_A;

	// SEGMENT BASES, NOT SEGMODS, MUST MATCH...


	ECX = [ECX]._S_SEG_GINDEX;
		CONVERT	ECX,ECX,SEGMOD_GARRAY
		ASSUME	ECX:PTR SEGMOD_STRUCT
	EAX = PUB_SEGMOD_GINDEX;

	ECX = [ECX]._SM_BASE_SEG_GINDEX;

		CONVERT	EAX,EAX,SEGMOD_GARRAY
		ASSUME	EAX:PTR SEGMOD_STRUCT

	if ([EAX]._SM_BASE_SEG_GINDEX != ECX)
		goto PREV_DEF_FAIL_A;

		CONVERT	ECX,ECX,SEGMENT_GARRAY
		ASSUME	ECX:PTR SEGMENT_STRUCT

	// MUST BE COMMON
	if ([ECX]._SEG_COMBINE != SC_COMMON)
		goto PREV_DEF_FAIL_A;

		POPM	EBX,ESI

	return;

		ASSUME	ECX:PTR SYMBOL_STRUCT
DP_LIB:

	// ECX IS PHYS, AX IS LOG


	DL = [ECX]._S_REF_FLAGS;

	// WAS THIS COMDEF?
	DL &= MASK S_DATA_REF;
	// YES, CHECK DATA-CODE
		JNZ	DP_COMM_UNREF

	goto DP_2;

DP_COMM_UNREF:

	// UNREFERENCED COMMUNAL


	EBX = PUB_SEGMOD_GINDEX;

	// MICROSOFT ALLOWS...
	if (EBX & EBX)
		JZ	DP_2

		CONVERT	EBX,EBX,SEGMOD_GARRAY
		ASSUME	EBX:PTR SEGMOD_STRUCT

	EBX = [EBX]._SM_BASE_SEG_GINDEX;
		CONVERT	EBX,EBX,SEGMENT_GARRAY
		ASSUME	EBX:PTR SEGMENT_STRUCT

	BL = [EBX]._SEG_TYPE;

	BL &= MASK SEG_CLASS_IS_CODE;
		JZ	DP_2
PREV_DEF_FAIL_B:
	goto PREV_DEF_FAIL_A;


		ASSUME	ECX:PTR SYMBOL_STRUCT

PREV_COMMUNAL:

	// IS CURRENT SEG A CODE SEG?


	EBX = PUB_SEGMOD_GINDEX;

	if (EBX & EBX)
		JZ	FIX_COMMUNAL_ENTRY1

		CONVERT	EBX,EBX,SEGMOD_GARRAY
		ASSUME	EBX:PTR SEGMOD_STRUCT

	EBX = [EBX]._SM_BASE_SEG_GINDEX;
		CONVERT	EBX,EBX,SEGMENT_GARRAY
		ASSUME	EBX:PTR SEGMENT_STRUCT

	BL = [EBX]._SEG_TYPE;

	BL &= MASK SEG_CLASS_IS_CODE;
		JNZ	PREV_DEF_FAIL_B
FIX_COMMUNAL_ENTRY1:

	// ECX IS PHYSICAL, EAX IS GINDEX


	REMOVE_FROM_COMMUNAL_LIST();
	goto DP_2;

FIX_COMMUNAL_ENTRY::

	// ECX IS PHYSICAL, EAX IS GINDEX


		PUSH	ESI
	REMOVE_FROM_COMMUNAL_LIST();

		PUSH	EBX
	goto DP_2;


FIX_VIRDEF_ENTRY::

	// ECX IS PHYSICAL, AX IS GINDEX


		PUSH	ESI
	REMOVE_FROM_VIRDEF_LIST();

		PUSH	EBX
	goto DP_2;

FIX_COMDAT_ENTRY::

	// ECX IS PHYSICAL, AX IS GINDEX


		PUSH	ESI
	REMOVE_FROM_COMDAT_LIST();

		PUSH	EBX
	goto DP_2;


    version(fg_td)
    {
__WEP_TEXT	DB	5,'__WEP'
    }
}


PREV_DEF_FAIL()
{
    LAST_PUBDEF_GINDEX = 0;	// DON'T KEEP ANY PUBLIC TYPE INFO
    LAST_EXTDEF_GINDEX = 0;	// DON'T KEEP ANY EXTRN TYPE INFO

    // ALWAYS AN ERROR IF NOT IN A LIBRARY
    if (!LIB_OR_NOT || PREV_DEF_IS_ERROR)
	ERR_SYMBOL_TEXT_RET(PREV_DEF_ERR);
    else
	WARN_SYMBOL_TEXT_RET(PREV_DEF_ERR);
}
