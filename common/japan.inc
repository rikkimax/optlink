;; Japanese translation, 1/94.
;; Please check entries with "???".
;; no translate "debug" and "os2" messages.

TITLE	ERRORS - Copyright (C) SLR Systems 1988


SHORT_JMP	DB	LENGTH SHORT_JMP-1,'Short JMP'
;SHORT_JMP	DB	LENGTH SHORT_JMP-1,'Short JMP'
NORMAL_JMP	DB	LENGTH NORMAL_JMP-1,'Near JMP�܂���CALL'
;NORMAL_JMP	DB	LENGTH NORMAL_JMP-1,'Near JMP or CALL'
UNDEF_JMP	DB	LENGTH UNDEF_JMP-1,'����̌^'
;UNDEF_JMP	DB	LENGTH UNDEF_JMP-1,'Unknown Type'
NORMAL_32_JMP	DB	LENGTH NORMAL_32_JMP-1,'32�r�b�g����JMP'
;NORMAL_32_JMP	DB	LENGTH NORMAL_32_JMP-1,'32-bit Conditional JMP'
LOBYTE_ADR1	DB	LENGTH LOBYTE_ADR1-1,'LoByte (�P��o�C�g)'
;LOBYTE_ADR1	DB	LENGTH LOBYTE_ADR1-1,'LoByte (single byte)'
OFFSET_ADR1	DB	LENGTH OFFSET_ADR1-1,'16�r�b�g�I�t�Z�b�g'
;OFFSET_ADR1	DB	LENGTH OFFSET_ADR1-1,'16-bit Offset'
WOFFSET_ADR1	DB	LENGTH WOFFSET_ADR1-1,'16�r�b�g�j��I�t�Z�b�g'
;WOFFSET_ADR1	DB	LENGTH WOFFSET_ADR1-1,'16-bit Weird Offset'
BASE_ADR1	DB	LENGTH BASE_ADR1-1,'�Z�O�����g�x�[�X'
;BASE_ADR1	DB	LENGTH BASE_ADR1-1,'Segment Base'
PTR_ADR1	DB	LENGTH PTR_ADR1-1,'DWORD �Z�O�����g:�I�t�Z�b�g'
;PTR_ADR1	DB	LENGTH PTR_ADR1-1,'DWORD seg:offs'
HIBYTE_ADR1	DB	LENGTH HIBYTE_ADR1-1,'16�r�b�g�I�t�Z�b�g�̏�ʃo�C�g'
;HIBYTE_ADR1	DB	LENGTH HIBYTE_ADR1-1,'Hi Byte of 16-bit Offset'
DWORD_ADR1	DB	LENGTH DWORD_ADR1-1,'32�r�b�g�I�t�Z�b�g'
;DWORD_ADR1	DB	LENGTH DWORD_ADR1-1,'32-bit Offset'
WDWORD_ADR1	DB	LENGTH WDWORD_ADR1-1,'32�r�b�g�j��I�t�Z�b�g'
;WDWORD_ADR1	DB	LENGTH WDWORD_ADR1-1,'32-bit Weird Offset'
FWORD_PTR_ADR1	DB	LENGTH FWORD_PTR_ADR1-1,'FWORD �Z�O�����g:32�r�b�g�I�t�Z�b�g'
;FWORD_PTR_ADR1	DB	LENGTH FWORD_PTR_ADR1-1,'FWORD seg:32-bit offs'

TARG_ADR	DB	'TARGET'
;TARG_ADR	DB	'TARGET'
LOC_ADR 	DB	'���݈ʒu'
;LOC_ADR 	DB	'Current Location'
EXTERNAL_ADR	DB	'�O���V���{�� '
;EXTERNAL_ADR	DB	'External Symbol '
GROUP_ADR	DB	'�O���[�v '
;GROUP_ADR	DB	'Group '
SEGMENT_ADR	DB	'�Z�O�����g '
;SEGMENT_ADR	DB	'Segment '

;; ??? assuming that the following strings are CONCATENATED when output.
;; ??? please check.

FRAME_ADR	DB	' FRAME  = '
;FRAME_ADR	DB	' FRAME  = Frame of '
TARGET_ADR	DB	' TARGET = '
;TARGET_ADR	DB	'�̃t���[���ATARGET = '
ATRELATIVE_ADR	DB	' '
;ATRELATIVE_ADR	DB	'at Relative '
FROMSEG_ADR	DB	' ����',0DH,0AH,'�Z�O�����g'
;FROMSEG_ADR	DB	' from',0DH,0AH,' Segment '
LINE_ADR	DB	'�A���悻�̍s�ԍ�'
;LINE_ADR	DB	' Near Line #'
INFILE_ADR	DB	'�A�t�@�C��'
;INFILE_ADR	DB	' in File '
FIX_TYPE_ADR	DB	'�AFIXUPP �^�C�v = '
;FIX_TYPE_ADR	DB	' FIXUPP Type = '


.XALL
ERR_CNT 	=	0
DEFINE		MACRO	XX,YY
T&XX		EQU	YY
		ENDM

MK		MACRO	XX,YY
		LOCAL	L1,L2
		PUBLIC	XX
XX		EQU	ERR_CNT+0
L1		DB	L2,YY
L2		EQU	$-L1-1
		DEFINE	%ERR_CNT,L1
ERR_CNT 	=	ERR_CNT+1
		ENDM

BUILD		MACRO	XX
		DW	T&XX
		ENDM

MK	OOPS_ERR,'�܂������B'
;MK	OOPS_ERR,'Oops'

if	fg_demo
MK	DEMO_EXPIRED_ERR,'���̃f���ł������؂�ɂȂ�܂����B'
;MK	DEMO_EXPIRED_ERR,'This DEMO has expired.'
endif

;Print symbol name for these error msgs
MK	PREV_DEF_ERR,'�O�̒�`�ƈႤ'            ;error
;MK	PREV_DEF_ERR,'Previous Definition Different'            ;error

;Print file name for these errors
MK	FILE_NOT_FOUND_ERR,'�t�@�C����������Ȃ�'                     ;fatal for objs and indirect, warn for libs
;MK	FILE_NOT_FOUND_ERR,'File Not Found'                     ;fatal for objs and indirect, warn for libs
;MK	SYM_LONG_ERR,'Symbol Name Too Long'                     ;fatal
MK	CANT_CREATE_ERR,'�t�@�C�����쐬�ł��Ȃ�'                    ;fatal
;MK	CANT_CREATE_ERR,'Cannot Create File'                    ;fatal
MK	REC_TOO_LONG_ERR,'OBJ���R�[�h����������'                  ;fatal
;MK	REC_TOO_LONG_ERR,'OBJ Record Too Long'                  ;fatal
MK	BAD_CHKSUM_ERR,'�`�F�b�N�T�����s��'                           ;warning
;MK	BAD_CHKSUM_ERR,'Bad Checksum'                           ;warning
MK	LIBRARY_ERR,'���C�u�����G���['				;error
;MK	LIBRARY_ERR,'Library Error'				;error
;-----------------------------------
if	fgh_os2
MK	OOM_ERR,'Swap File Full'				;fatal
else
MK	OOM_ERR,'�������s��'                                 ;fatal
;MK	OOM_ERR,'Out of Memory'                                 ;fatal
endif
MK	FILENAME_ERR,'�s���t�@�C����'                         ;fatal
;MK	FILENAME_ERR,'Illegal Filename'                         ;fatal
MK	CMDLIN_ERR,"�s���I�v�V����"                             ;fatal
;MK	CMDLIN_ERR,"Unknown option"                             ;fatal
MK	DISK_FULL_ERR,'�f�B�X�N�̎c��e�ʂ��Ȃ�'                       ;fatal
;MK	DISK_FULL_ERR,'Disk Full Writing'                       ;fatal
MK	MISSING_COLON_ERR,'�R�������K�v'                      ;fatal
;MK	MISSING_COLON_ERR,'Colon Expected'                      ;fatal
MK	ILL_NUMBER_ERR,'���l�I�[�o�[�t���['                        ;fatal
;MK	ILL_NUMBER_ERR,'Number Overflow'                        ;fatal
MK	OBJ_PHASE_ERR,'���R�[�h�̃V���^�b�N�X���s��'			;FATAL
;MK	OBJ_PHASE_ERR,'Illegal Record Syntax'			;FATAL
MK	BAD_RECORD_ERR,'���R�[�h���F���ł��Ȃ�'			;ERROR
;MK	BAD_RECORD_ERR,'Unrecognized Record'			;ERROR
; ??? what does extension mean ???
MK	BAD_OMF_EXTENT_ERR,'OMF�g���q���s��'			;fatal
;MK	BAD_OMF_EXTENT_ERR,'Bad OMF Extension'			;fatal
; ??? what does index range mean?
MK	INDEX_RANGE_ERR,'�C���f�b�N�X�͈̔�'				;FATAL
;MK	INDEX_RANGE_ERR,'Index Range'				;FATAL

MK	GRP_TOO_BIG_ERR,'�O���[�v�̃T�C�Y��64K���z���Ă���'		;ERROR
;MK	GRP_TOO_BIG_ERR,'Group Size Exceeds 64k'		;ERROR
MK	GRP_TYP_ERR,'GROUP �ɍĔz�u�\�ƃA�u�\�����[�g�͓����Ɏw��ł��Ȃ�';ERROR
;MK	GRP_TYP_ERR,'GROUP Cannot Be Both Relocatable and Absolute';ERROR

MK	SEG_TOO_BIG_ERR,'�Z�O�����g�̃T�C�Y��64K���z���Ă���'		;ERROR
;MK	SEG_TOO_BIG_ERR,'Segment Size Exceeds 64k'		;ERROR
MK	SEG_4G_ERR,'�Z�O�����g >= 4G'				;ERROR
;MK	SEG_4G_ERR,'Segment >= 4G'				;ERROR
MK	BAD_SEG_SIZE_ERR,'�Z�O�����g�T�C�Y����������'		;ERROR
;MK	BAD_SEG_SIZE_ERR,'Badly Formed Segment Size'		;ERROR
MK	NC_TOO_BIG_ERR,'Near Communal�T�C�Y��64k���z���Ă���'	;FATAL
;MK	NC_TOO_BIG_ERR,'Near Communal Size Exceeds 64k'		;FATAL
MK	DUP_GROUP_ERR,'�Z�O�����g�����ɕʂ̃O���[�v�ɂ���'	;WARNING
;MK	DUP_GROUP_ERR,'Segment Already in Different Group'	;WARNING

MK	MISSING_STACK_ERR,'�X�^�b�N���Ȃ�'				;WARNING
;MK	MISSING_STACK_ERR,'No Stack'				;WARNING
MK	MULTIPLE_STACKS_ERR,'���W���[���ɃX�^�b�N�����ɒ�`����Ă���'	;WARNING
;MK	MULTIPLE_STACKS_ERR,'Stack Already Declared in Module'	;WARNING

MK	MUST_HAVE_SEGMENT_ERR,'PUBDEF�ɂ̓Z�O�����g�C���f�b�N�X���Ȃ���΂Ȃ�Ȃ�'	;ERROR
;MK	MUST_HAVE_SEGMENT_ERR,'PUBDEF Must Have Segment Index'	;ERROR
MK	TOO_COMPLEX_ERR,'���W���[������Groups, Segments, Externals����������'
;MK	TOO_COMPLEX_ERR,'Too Many Groups, Segments or Externals in Module'

MK	LINE_TOO_LONG_ERR,'1�s��500�o�C�g���z���Ă���'
;MK	LINE_TOO_LONG_ERR,'Line Exceeds 500 Bytes Reading '
MK	BAD_THREAD_ERR,'FIXUPP�X���b�h���s��'			;FATAL
;MK	BAD_THREAD_ERR,'Bad FIXUPP Thread'			;FATAL
MK	BAD_LOC_ERR,'�J�n�A�h���X��LOC�t���[�����s��'		;FATAL
;MK	BAD_LOC_ERR,'Bad LOC Frame in start address'		;FATAL

MK	DOS_ERR,'DOS �d��G���['				;FATAL
;MK	DOS_ERR,'DOS Critical Error'				;FATAL

MK	UNEXP_EOF_ERR,'�t�@�C���̏I��ɒB���Ă��܂���'			;FATAL
;MK	UNEXP_EOF_ERR,'Unexpected End of File'			;FATAL
MK	TOO_MANY_SYMBOLS_ERR,'LIB�t�@�C�����̃��W���[������������'
;MK	TOO_MANY_SYMBOLS_ERR,'Too Many Modules in LIB File'
MK	MUL32_ERR,'32�r�b�g��Z�I�[�o�[�t���['			;ABORT
;MK	MUL32_ERR,'Overflow 32-bit Multiply'			;ABORT
MK	NOT_IN_GROUP_ERR,'Group�O�̃Z�O�����g'
;MK	NOT_IN_GROUP_ERR,'Segment Not in That Group'

MK	DATA_OUTSIDE_SEGMOD_ERR,'�Z�O�����g�͈͊O�̃f�[�^������'	;ERROR
;MK	DATA_OUTSIDE_SEGMOD_ERR,'Data Outside Segment Bounds'	;ERROR

MK	UNRECOGNIZED_FIXUPP_FRAME_ERR,'�s����FIXUPP�t���[���^�C�v';FATAL
;MK	UNRECOGNIZED_FIXUPP_FRAME_ERR,'Unknown FIXUPP Frame Type';FATAL

MK	FIXUPP_OFFSET_ERR,'FIXUPP�̓f�[�^���R�[�h�̐���w���Ă���'	;error
;MK	FIXUPP_OFFSET_ERR,'FIXUPP Points Past Data Record'	;error
MK	CANT_REACH_ERR,'FRAME����TARGET�ɂ͂��ǂ���Ȃ�'		;error
;MK	CANT_REACH_ERR,'Cannot Reach TARGET from FRAME'		;error
MK	LOC_FRAME_ERR,'LOCATION��FRAME���ł͂Ȃ�'		;error
;MK	LOC_FRAME_ERR,'LOCATION Not Within FRAME'		;error
MK	SHORT_ERR,'�͈͊O��Short JMP'			;error
;MK	SHORT_ERR,'Short JMP Out of Range'			;error
MK	LOBYTE_ERR,'�͈͊O��BYTE'				;error
;MK	LOBYTE_ERR,'BYTE Out of Range'				;error
MK	BASE_RELOC_ERR,'��΃��[�h�ł͍Ĕz�u�\�ȃx�[�X�𗘗p�ł��Ȃ�';error
;MK	BASE_RELOC_ERR,'Relocatable Bases Not Allowed in Absolute Mode';error
MK	TOO_MANY_BASES_ERR,'�x�[�XFIXUPP��65535���z���Ă���';fatal
;MK	TOO_MANY_BASES_ERR,'Limit of 65535 Base Fixupps Exceeded';fatal
MK	UNREC_FIXUPP_ERR,'�s����FIXUPP�^�C�v'		;error
;MK	UNREC_FIXUPP_ERR,'Unrecognized FIXUPP Type'		;error
MK	ASEG_RELOC_ERR,'ASEG����RELOC�ցA�܂���RELOC����ASEG�ւ͂��ǂ���Ȃ�'
;MK	ASEG_RELOC_ERR,'Cannot Reach ASEG from RELOC or RELOC from ASEG'
MK	UNDEFINED_ERR,'����`�V���{��'			;error
;MK	UNDEFINED_ERR,'Symbol Undefined'			;error
MK	MULTI_CSEG_ERR,'��̃��W���[�����ɕ�����CODE�Z�O�����g�����݂���'
;MK	MULTI_CSEG_ERR,'Multiple CODE Segments in Single Module'
MK	LIB_ERR,'�s�����C�u�����t�@�C��'			;fatal
;MK	LIB_ERR,'Not a Valid Library File'			;fatal
MK	DICT_TOO_BIG_ERR,'LIB����������������'
;MK	DICT_TOO_BIG_ERR,'LIB Dictionary Too Big'
MK	MIC_NUM_ERR,'Communal�V���^�b�N�X��F���ł��Ȃ�'		;fatal
;MK	MIC_NUM_ERR,'Unrecognized Communal Syntax'		;fatal
MK	CV_TOO_MANY_ERR,'��CodeView�`���ɂ̓f�o�b�O��񂪑��߂���';fatal
;MK	CV_TOO_MANY_ERR,'Too Much DEBUG Data for Old CodeView format';fatal
MK	COM_PC_ERR,'�J�n�A�h���X��100H�łȂ���΂Ȃ�Ȃ�'			;error
;MK	COM_PC_ERR,'Start Address Must Be 100H'			;error
MK	COM_BELOW_100_ERR,'100H�ȉ��͏������ł��Ȃ�'	;warning
;MK	COM_BELOW_100_ERR,'Below 100H Cannot Be Initialized'	;warning
MK	COM_ABOVE_100_ERR,'100H����ɂ͉����Ȃ�'
;MK	COM_ABOVE_100_ERR,'Nothing Above 100H'
MK	FORREF_ERR,'B2���R�[�h��F���ł��Ȃ�'			;fatal
;MK	FORREF_ERR,'Unrecognized B2 Record'			;fatal
MK	CTRLC_ERR,'���[�U�ɂ�钆�~'					;fatal
;MK	CTRLC_ERR,'User ABORT'					;fatal
iff	fgh_os2
MK	CANT_REOPEN_ERR,'�o�̓t�@�C�����ăI�[�v���ł��Ȃ�'		;fatal
;MK	CANT_REOPEN_ERR,'Cannot Reopen output file'		;fatal
endif
if	fg_virt
MK	EMS_ERR,'         EMS�G���['				;fatal
;MK	EMS_ERR,'         EMS Error'				;fatal
MK	EMS_CANT_ALLOC_ERR,'EMS�u���b�N���m�ۂł��Ȃ�'		;warning
;MK	EMS_CANT_ALLOC_ERR,'Cannot Allocate EMS Blocks'		;warning
MK	XMS_ERR,'XMS �G���['					;fatal
;MK	XMS_ERR,'XMS Error'					;fatal
endif
MK	CURN_MOD_ERR,'SEGDEF Curnmod ����`����Ă��Ȃ�'
;MK	CURN_MOD_ERR,'SEGDEF Curnmod Undefined'
MK	DUP_MODEND_ERR,'���W���[����start�����łɎw�肳��Ă���';warning
;MK	DUP_MODEND_ERR,'Start Previously Specified in Module'	;warning
MK	CV_TOO_MANY_LINNUMS_ERR,'���W���[�����̍s�ԍ��f�o�b�N��񂪑�������';fatal
;MK	CV_TOO_MANY_LINNUMS_ERR,'Too Many Linenumbers in a Module for Debug Info';fatal
MK	SYNTAX_ERR,'.DEF�V���^�b�N�X�G���['			;fatal
;MK	SYNTAX_ERR,'.DEF Syntax Error'				;fatal
if	fg_rom
MK	ALREADY_ORGED_ERR,'���ɐ��񂳂�Ă���'
;MK	ALREADY_ORGED_ERR,'Already ordered'
MK	ASEG_ERR,'�s��SEGMENT�B���R�[�h: '
;MK	ASEG_ERR,'Illegal SEGMENT AT record'
MK	SEG_OVERLAP_ERR,'�Z�O�����g���ʂ̃Z�O�����g�Əd�Ȃ��Ă���'
;MK	SEG_OVERLAP_ERR,'Segment Overlaps Another'
; ??? what is a hole ???
MK	CANNOT_PLACE_ERR,'�Z�O�����g�p�̌���������Ȃ�'
;MK	CANNOT_PLACE_ERR,'Cannot find hole for segment'
MK	SEG_WRAP_ERR,'�Z�O�����g��1GB���E���ׂ��Ă���'
;MK	SEG_WRAP_ERR,'Segment wraps 1 Mb Boundary'
MK	LEFT_ERR,"'('���Ȃ���΂Ȃ�Ȃ�"
;MK	LEFT_ERR,"'(' Expected"
MK	RIGHT_ERR,"�R���}�܂���')'���Ȃ���΂Ȃ�Ȃ�"
;MK	RIGHT_ERR,"Comma or ')' Expected"
MK	RANGE_WRAP_ERR,'�s���ȗ̈�̏d�Ȃ�'
;MK	RANGE_WRAP_ERR,'Illegal Range-wrap'
MK	MUST_SEGMENT_ERR,'Phase��SEGMENT���ƂłȂ���΂Ȃ�Ȃ�'
;MK	MUST_SEGMENT_ERR,'Phase must be by SEGMENT'
MK	ALREADY_PHASED_ERR,'����PHASE������Ă���'
;MK	ALREADY_PHASED_ERR,'Already PHASEd'
MK	TOO_PHASE_ERR,'PHASE���Z�O�����g�����߂���'
;MK	TOO_PHASE_ERR,'Too many PHASEd segments'
MK	OUTTYPE_UNDEF_ERR,'����`�o�̓^�C�v'
;MK	OUTTYPE_UNDEF_ERR,'Undefined Output type'
endif
MK	START_ERR,'�s���J�n�A�h���X'			;error
;MK	START_ERR,'Illegal Start Address'			;error
if	debug
MK	LIB1_ERR,'BINSER_MODULE�Ń��W���[����������܂���'
;MK	LIB1_ERR,'BINSER_MODULE cannot find module'
MK	UNLOCK_ERR,'�񃍃b�N�̃u���b�N�����b�N�������悤�Ƃ���'
;MK	UNLOCK_ERR,'Attempt to unlock unlocked block'
endif
;MK	LIB2_ERR,'Requesting a Block with no Modules...'


if	fgh_os2

MK	THREAD_FAIL_ERR,'Cannot Create Thread'			;fatal
;MK	BAD_SEM_ERR,'Semaphore Error'				;fatal
MK	TIMEOUT_ERR,'Semaphore Timeout'				;fatal
;MK	PRIORITY_ERR,'Cannot Set Priority'			;fatal
MK	QFH_FAILED_ERR,'QFH Error'				;fatal
MK	CLOSE_ERR,'Close Error'					;fatal
MK	DOS_READ_ERR,'Critical Read'				;fatal
MK	DOS_POS_ERR,'Critical Position'				;fatal
MK	DOS_WRITE_ERR,'Critical Write'				;fatal
MK	DOS_NEWSIZE_ERR,'DOSNEWSIZE Error'			;fatal
MK	DOS_SETFILEINFO_ERR,'DOSSETFILEINFO Error'		;fatal
;MK	UNEXP_XEOF_ERR,'     Unexpected Extended End of File'

endif

MK	SEG_ALREADY_RELEASED_ERR,'�Z���N�^�����ɉ������Ă���'	;fatal
;MK	SEG_ALREADY_RELEASED_ERR,'Selector Already Released'	;fatal
MK	RELOC_CONFLICT_ERR,'�f�[�^�ƍĔz�u���I�[�o���b�v���Ă���'	;error
;MK	RELOC_CONFLICT_ERR,'Data Overlaps Relocations'		;error
MK	CANNOT_PACK_ERR,'�Ĕz�u����������EXEPACK�ł��Ȃ�'		;fatal
;MK	CANNOT_PACK_ERR,'Too Many Relocs to EXEPACK'		;fatal
MK	NOTHING_ERR,'�ǂ̃Z�O�����g�������N���Ȃ�����'			;fatal
;MK	NOTHING_ERR,'No Segments Linked!'			;fatal
MK	INCERR_ERR,'�C���N�������^���R���p�C���̃G���['			;fatal
;MK	INCERR_ERR,'Incremental Compile Error'			;fatal
MK	EXESTR_ERR,'EXESTR�f�[�^�����߂���'			;fatal
;MK	EXESTR_ERR,'Too much EXESTR data'			;fatal
MK	ALIAS_ERR,'�s����ALIAS'				;error
;MK	ALIAS_ERR,'Illegal ALIAS'				;error
MK	CIRCULAR_ALIAS_ERR,'ALIAS���z���Ă���'			;fatal
;MK	CIRCULAR_ALIAS_ERR,'Circular ALIAS'			;fatal

MK	SEG_COMMON_ERR,'COMMON�̑g�����^�C�v�������I�[�o���C�h����'	;warning
;MK	SEG_COMMON_ERR,'COMMON Combine type overrides others'	;warning
MK	SEG_STACK_ERR,'STACK�̑g�����^�C�v�������I�[�o���C�h���Ă���';warning
;MK	SEG_STACK_ERR,'STACK Combine type overrides others'	;warning

MK	LIN_NONCODE_ERR,'��CODE�Z�O�����g��LINNUM��������'	;warning
;MK	LIN_NONCODE_ERR,'LINNUMs in Non-CODE segment'		;warning
MK	LINSYM_BEFORE_COMDAT_ERR,'COMDAT�̑O��LINSYM������'	;ERROR
;MK	LINSYM_BEFORE_COMDAT_ERR,'LINSYM before COMDAT'		;ERROR
MK	LINSYM_CONT_ERR,'LINSYM ���p�����Ă���'			;ERROR
;MK	LINSYM_CONT_ERR,'LINSYM Continuation'			;ERROR

if	fg_segm

MK	CODEPACK_ERR,'�Z�O�����g����������̂�PACKCODE�����s'	;warning
;MK	CODEPACK_ERR,'Too many segments, trying PACKCODE'	;warning
MK	DATAPACK_ERR,'�Z�O�����g����������̂�PACKDATA�����s'	;warning
;MK	DATAPACK_ERR,'Too many segments, trying PACKDATA'	;warning
MK	TOO_MANY_SEGS_ERR,'�Z�O�����g��EXE�`���ɂ���ɂ̓Z�O�����g����������'	;fatal
;MK	TOO_MANY_SEGS_ERR,'Too many segments for segmented .EXE format'	;fatal
MK	TOO_ENTRIES_ERR,'ENTRY�����߂���'			;fatal
;MK	TOO_ENTRIES_ERR,'Too many ENTRIES'			;fatal
MK	EXP_CONST_ERR,'EXPORT�ł��Ȃ�'				;error
;MK	EXP_CONST_ERR,'Cannot EXPORT'				;error
MK	DUP_ENT_ORD_ERR,'ORDINAL�ԍ����d�����Ă���'		;error
;MK	DUP_ENT_ORD_ERR,'Duplicate ORDINAL Number'		;error
MK	START_CANT_REACH_ERR,'�J�n�A�h���X�̃t���[�����s��'	;error
;MK	START_CANT_REACH_ERR,'Illegal frame on start address'	;error
MK	START_IMPORT_ERR,'IMPORT���J�n�A�h���X�ɂ͎g���Ȃ�'	;error
;MK	START_IMPORT_ERR,'IMPORT illegal as start address'	;error
MK	BAD_STUB_ERR,'�s��STUB�t�@�C��'				;fatal
;MK	BAD_STUB_ERR,'Bad STUB file'				;fatal
MK	EXPORT_CONFLICT_ERR,'_export��EXPORTS�̖���'	;error
;MK	EXPORT_CONFLICT_ERR,'_export conflicts with EXPORTS'	;error
MK	ALIGN_SMALL_ERR,'/ALIGNMENT�l��傫������K�v������'			;fatal
;MK	ALIGN_SMALL_ERR,'Need larger /ALIGNMENT value'		;fatal
MK	HEAP_STACK_DGROUP_ERR,'DGROUP+�X�^�b�N+�q�[�v��64k-16���z���Ă���'	;error
;MK	HEAP_STACK_DGROUP_ERR,'DGROUP + Stack + Heap exceeds 64k-16';error
MK	GRP_OVERLAP_ERR,'�O���[�v���I�[�o���b�v���Ă���'	;error
;MK	GRP_OVERLAP_ERR,'Groups Overlap'			;error
MK	ONE_NAME_ERR,'NAME�܂���LIBRARY��1�Ɍ���'		;error
;MK	ONE_NAME_ERR,'Only one NAME or LIBRARY allowed'		;error
MK	SEGM_COM_SYS_ERR,'�Z�O�����g��.COM�܂���.SYS�t�@�C���������ł��Ȃ�'	;warning
;MK	SEGM_COM_SYS_ERR,'Cannot generate Segmented .COM or .SYS file'	;warning
MK	DLL_NO_LIB_ERR,'.DLL�p��.DEF�t�@�C����LIBRARY�w�肪�����Ă���'	;warning
;MK	DLL_NO_LIB_ERR,'Missing LIBRARY in .DEF file for .DLL'	;warning
MK	ONE_DESC_ERR,'�����̋L�q'			;error
;MK	ONE_DESC_ERR,'Multiple Descriptions'			;error
MK	DEF_CODE_ERR,'CODE�w��'				;error
;MK	DEF_CODE_ERR,'CODE Directive'				;error
MK	DEF_DATA_ERR,'DATA�w��'				;error
;MK	DEF_DATA_ERR,'DATA Directive'				;error
MK	DEF_SEGMENTS_ERR,'SEGMENTS�w��'			;error
;MK	DEF_SEGMENTS_ERR,'SEGMENTS Directive'			;error
MK	DUP_HEAP_ERR,'HEAPSIZE�w��'			;error
;MK	DUP_HEAP_ERR,'HEAPSIZE Directive'			;error
MK	DEF_EXETYPE_ERR,'EXETYPE�w��'			;error
;MK	DEF_EXETYPE_ERR,'EXETYPE Directive'			;error
MK	PROT_REAL_ERR,'PROT vs REAL conflict'			;error
;MK	PROT_REAL_ERR,'PROT��REAL���������Ă���'			;error
MK	DEF_IMPORTS_ERR,'IMPORTS�w��'			;error
;MK	DEF_IMPORTS_ERR,'IMPORTS Directive'			;error
MK	DEF_EXPORTS_ERR,'EXPORTS�w��'			;error
;MK	DEF_EXPORTS_ERR,'EXPORTS Directive'			;error
MK	DUP_OLD_ERR,'OLD���d�����Ă���'				;error
;MK	DUP_OLD_ERR,'Duplicate OLD'				;error
MK	DUP_STUB_ERR,'STUB���d�����Ă���'			;error
;MK	DUP_STUB_ERR,'Duplicate STUB'				;error
MK	DEF_STRING_ERR,'��؂蕶����łȂ���΂Ȃ�Ȃ�'		;error
;MK	DEF_STRING_ERR,'Delimited String Expected'		;error
MK	APPLOAD_ERR,'APPLOAD��SEGMENTS�̑O�łȂ���΂Ȃ�Ȃ�'	;fatal
;MK	APPLOAD_ERR,'APPLOAD must appear before any SEGMENTS'	;fatal
MK	DUP_RESOURCE_ERR,'RESOURCE���d�����Ă���̂Ŗ���'		;error
;MK	DUP_RESOURCE_ERR,'Duplicate RESOURCE, ignored'		;error
MK	MULTIPLE_RC_ERR,'RC�R�}���h���d�����Ă���'			;error
;MK	MULTIPLE_RC_ERR,'Duplicate RC commands'			;error
MK	RC_64K_ERR,'Preload�Z�O�����g+�Ĕz�u > 64k�Ȃ̂ŁA-k�I�v�V����������K�v������'	;error
;MK	RC_64K_ERR,'Preload Segment + Relocs > 64k, use -k'	;error
MK	EXEHDR_ERR,'.EXE�w�b�_ >64k'				;error
;MK	EXEHDR_ERR,'.EXE Header >64k'				;error
MK	RESOURCE_CORRUPT_ERR,'.RES�t�@�C�����j�󂳂�Ă���'		;fatal
;MK	RESOURCE_CORRUPT_ERR,'.RES file Corrupt'		;fatal
MK	EXP_TEXT_ERR,'EXPORT���̃e�L�X�g>64k'			;fatal
;MK	EXP_TEXT_ERR,'EXPORTed names text >64k'			;fatal
MK	SUBSYSTEM_ERR,'SUBSYSTEM�w��'			;error
;MK	SUBSYSTEM_ERR,'SUBSYSTEM Directive'			;error

endif

iff	fg_segm

MK	NO_IMPORTS_ERR,'�s����Import�錾'	;fatal
;MK	NO_IMPORTS_ERR,'Import Declarations Illegal'	;fatal

endif

if	fg_prot

MK	OS2_FLAG_CONFLICT_ERR,'�O���[�v���Z�O�����g�̃t���O���������Ă���'	;warning
;MK	OS2_FLAG_CONFLICT_ERR,'Grouped segments have conflicting flags'	;warning
MK	GRP_COD_DAT_ERR,'�O���[�v�͓�����CODE��DATA�̃Z�O�����g���܂߂Ȃ�'	;error
;MK	GRP_COD_DAT_ERR,'Group cannot contain CODE and DATA segments'	;error

endif

MK	TOKEN_TOO_LONG_ERR,'�g�[�N�������߂���'		;fatal
;MK	TOKEN_TOO_LONG_ERR,'Token Too Long'		;fatal
MK	FILE_EXP_ERR,'�t�@�C�����łȂ���΂Ȃ�Ȃ�'		;fatal
;MK	FILE_EXP_ERR,'Filename Expected'		;fatal
;; ??? what does this meam?
MK	WEAK_DEF_ERR,'Weak EXTRN���Ⴄ'		;error
;MK	WEAK_DEF_ERR,'Weak EXTRN Different'		;error

MK	INDIRECT_DEEP_ERR,'�Ԑڃt�@�C���̃l�X�g���[������';fatal
;MK	INDIRECT_DEEP_ERR,'Indirect file nested too deep';fatal
MK	GRP_ERR,'���T�|�[�gGRPDEF�̃^�C�v'		;error
;MK	GRP_ERR,'Unsupported GRPDEF Type'		;error
MK	ALIAS_IGNORED_ERR,'ALIAS�͊��ɒ�`����Ă���'	;warn
;MK	ALIAS_IGNORED_ERR,'ALIAS Previously defined'	;warn
MK	CANNOT_LINK_ERR,'�����N�ł��Ȃ�'			;fatal
;MK	CANNOT_LINK_ERR,'Cannot Link'			;fatal

if	any_overlays

MK	MISSING_ENDAREA_ERR,'ENDAREA�������Ă���'		;fatal
;MK	MISSING_ENDAREA_ERR,'Missing ENDAREA'		;fatal
MK	ENDAREA_ERR,'ENDAREA�ɑΉ�����BEGINAREA���Ȃ�'		;fatal
;MK	ENDAREA_ERR,'ENDAREA without BEGINAREA'		;fatal
MK	CACHE_VALUE_ERR,'�L���b�V���l'			;fatal
;MK	CACHE_VALUE_ERR,'Cache Value'			;fatal
MK	DUP_CACHE_ERR,'�L���b�V���v�����d�����Ă���'		;fatal
;MK	DUP_CACHE_ERR,'Duplicate Cache Request'		;fatal
MK	SECTION_REQ_ERR,'Overlay�Z�N�V�������łȂ���΂Ȃ�Ȃ�'	;fatal
;MK	SECTION_REQ_ERR,'Must be in Overlay Section'	;fatal
MK	PAREN_NESTING_ERR,'���ʂ��Ή����Ă��Ȃ�'		;fatal
;MK	PAREN_NESTING_ERR,'Mismatched Parens'		;fatal

endif

MK	ID_EXP_ERR,'�V���{���܂��͖��̂łȂ���΂Ȃ�Ȃ�'		;fatal
;MK	ID_EXP_ERR,'Symbol or Name Expected'		;fatal

if	fg_plink

MK	RIGHT_ERR,"','�܂���')'���Ȃ���΂Ȃ�Ȃ�"		;fatal
;MK	RIGHT_ERR,"Comma or ')' Expected"		;fatal
MK	ALWAYS_NEVER_CONFLICT_ERR,'Always-Never�̖���';fatal
;MK	ALWAYS_NEVER_CONFLICT_ERR,'Always-Never Conflict';fatal
MK	AREA_DEEP_ERR,'BEGINAREA�̃l�X�g���[�߂���'	;fatal
;MK	AREA_DEEP_ERR,'BEGINAREAs nested too deep'	;fatal
MK	TRACK_NEVER_ERR,'Track-Never�̖���'		;fatal
;MK	TRACK_NEVER_ERR,'Track-Never Conflict'		;fatal
MK	NEAR_FAR_ERR,'Near-Far�łȂ���΂Ȃ�Ȃ�'		;fatal
;MK	NEAR_FAR_ERR,'Near-Far Expected'		;fatal
MK	PUB_NOPUB_ERR,'Public-Nopublic�̖���'	;fatal
;MK	PUB_NOPUB_ERR,'Public-Nopublics Conflict'	;fatal
MK	FI_MO_SY_ERR,'�t�@�C��-���W���[��-�V���{���łȂ���΂Ȃ�Ȃ�'	;fatal
;MK	FI_MO_SY_ERR,'File-Module-Symbol Expected'	;fatal

endif
if	any_overlays

MK	DUP_SECTION_ERR,'���̍��ڂɂ͊��ɃZ�N�V�������錾����Ă���'	;fatal
;MK	DUP_SECTION_ERR,'That Item Already has Section Declared'	;fatal
MK	TOO_MANY_VECTORS_ERR,'�x�N�g�����V���{�������߂���';fatal
;MK	TOO_MANY_VECTORS_ERR,'Too Many Vectored Symbols';fatal
MK	OVL_COM_SYS_ERR,'COM�܂���SYS�̃I�[�o���C���ł��Ȃ��Bextent��EXE�ɕύX����';warning
;MK	OVL_COM_SYS_ERR,'Cannot Overlay COM or SYS files, extent changed to EXE';warning

endif

if	debug
MK	EMS_XMS_LIST_ERR,'MRU or Freelist corrupt'
endif

MK	SECTION_ERR,'�I�[�o���C�ԍ� >32k'			;error
;MK	SECTION_ERR,'Overlay Number >32k'			;error
MK	COMDAT_SYNTAX_ERR,'COMDAT�V���^�b�N�X'			;fatal
;MK	COMDAT_SYNTAX_ERR,'COMDAT Syntax'			;fatal
MK	COMDAT_CONT_ERR,'COMDAT�p���s����������'		;fatal
;MK	COMDAT_CONT_ERR,'COMDAT Continuation Mismatch'		;fatal
MK	BAD_CD_ALLOC_ERR,'�F���ł��Ȃ�COMDAT���蓖�ă^�C�v'	;fatal
;MK	BAD_CD_ALLOC_ERR,'Unknown COMDAT Allocation type'	;fatal
; ??? what does this mean?
MK	DEF_WEAK_INT_ERR,'WeakLazyAlias Internal'		;fatal
;MK	DEF_WEAK_INT_ERR,'WeakLazyAlias Internal'		;fatal
MK	COMMUNAL_ERR,'COMDEF�̃T�C�Y���s��'			;warn
;MK	COMMUNAL_ERR,'Bad COMDEF Sizes'			;warn
MK	CEXTDEF_ERR,'COMDAT���Ȃ��̂�CEXTDEF��������'		;fatal
;MK	CEXTDEF_ERR,'CEXTDEF with no COMDAT'		;fatal
MK	CONST_FRAME_ERR,'�萔��FRAME=0�łȂ���΂Ȃ�Ȃ�'	;error
;MK	CONST_FRAME_ERR,'Constants must have FRAME=0'	;error

MK	STD_MAXINDEX_ERR,'64k�̐������z����: '		;fatal
;MK	STD_MAXINDEX_ERR,'64k Limit Exceeded:'		;fatal
MK	NO_START_ERR,'�J�n�A�h���X���Ȃ�'			;warn
;MK	NO_START_ERR,'No Start Address'			;warn

MK	UNREC_IN_CFG_ERR,'.CFG�ɔF���ł��Ȃ��f�[�^������'	;ERROR
;MK	UNREC_IN_CFG_ERR,'Unrecognized data in .CFG'	;ERROR
MK	LIB_DUP_ERR,'����LIB�Œ�`���ꂽ�V���{���͑��ł���`����Ă���'	;warn
;MK	LIB_DUP_ERR,'Symbol in this LIB Defined Elsewhere'	;warn
MK	HEAP_NO_DGROUP_ERR,'DGROUP���Ȃ��̂Ƀq�[�v��������'	;warning
;MK	HEAP_NO_DGROUP_ERR,'Heap without DGROUP'	;warning

if	fg_td

MK	TD_E0_EXTDEF_ERR,'EXTDEF�̂Ȃ�E0'		;ERROR
;MK	TD_E0_EXTDEF_ERR,'E0 without EXTDEF'		;ERROR
MK	TD_E1_PUBDEF_ERR,'PUBDEF�̂Ȃ�E1'		;ERROR
;MK	TD_E1_PUBDEF_ERR,'E1 without PUBDEF'		;ERROR
MK	TD_SCOPE_NEST_ERR,'SCOPE�������Ă���'		;ERROR
;MK	TD_SCOPE_NEST_ERR,'Missing SCOPE'		;ERROR
MK	TD_NAMES_COUNT_ERR,'���̐� > 64k (TD 3.x�̐���)'	;ERROR
;MK	TD_NAMES_COUNT_ERR,'>64k Names, TD 3.x limit'	;ERROR
MK	TD_LOCALS_COUNT_ERR,'���[�J���� > 64k (TD 3.x�̐���)'	;ERROR
;MK	TD_LOCALS_COUNT_ERR,'>64k Locals, TD 3.x limit'	;ERROR
MK	TD_TYPES_COUNT_ERR,'�^�C�v�� > 64k (TD 3.x�̐���)';ERROR
;MK	TD_TYPES_COUNT_ERR,'>64k Types, TD 3.x limit'	;ERROR
MK	TD_MEMBERS_COUNT_ERR,'�����o�[�� > 64k (TD 3.x�̐���)'	;ERROR
;MK	TD_MEMBERS_COUNT_ERR,'>64k Members, TD 3.x limit'	;ERROR
MK	TD_LINES_COUNT_ERR,'�s�ԍ� > 64k (TD 3.x�̐���)'	;ERROR
;MK	TD_LINES_COUNT_ERR,'>64k Linenumbers, TD 3.x limit'	;ERROR
MK	TD_SYMBOLS_COUNT_ERR,'�V���{���� > 64k (TD �̐���)'	;FATAL
;MK	TD_SYMBOLS_COUNT_ERR,'>64k Symbols, TD limit'	;FATAL
;; ??? what is coverages?
MK	TD_COVERAGE_COUNT_ERR,'>64k Coverages, (TD �̐���)';FATAL
;MK	TD_COVERAGE_COUNT_ERR,'>64k Coverages, TD limit';FATAL
MK	TD_TID_ERR,'�s��TID�BSLR�ɘA���肢�܂��B'		;FATAL
;MK	TD_TID_ERR,'Unknown TID, notify SLR'		;FATAL
MK	TD_CLASS_ERR,'Class���R�[�h�����߂ł��Ȃ�'	;FATAL
;MK	TD_CLASS_ERR,'Cannot parse Class record'	;FATAL
MK	TLINK_XTRA_ERR,'�]�v�ȕ����𖳎�'	;warn
;MK	TLINK_XTRA_ERR,'Extra characters ignored'	;warn
if	debug
MK	TYPE_PUNT_ERR,'TYPE Punt'
MK	TYPE_PUNT_SUCCESS_ERR,'TYPE Success, No Punt'
MK	MEMBER_PUNT_ERR,'MEMBER Punt'
MK	CLASS_PUNT_ERR,'CLASS Punt'
MK	TD_UNUSED_TYPES_ERR,'Unused Types'
MK	TD_UNUSED_CLASSES_ERR,'Unused Classes'
MK	CLASS_ZERO_ERR,'Class Index == 0'
MK	FIXED_SPEC_ERR,'Fixed SpecFunc'
MK	TYPE_ZERO_ERR,'TYPE ZERO'
MK	CANNOT_FIX_SPEC_ERR,'Cannot Fix SpecialFunction'
endif

endif

if	debug
MK	DGROUP_STEPPED_ERR,'DGROUP Wedged'
MK	VIRT_FAIL_ERR,'Illegal Virtual Address'
endif

MK	INVALID_OBJ_ERR,'���W���[���܂��͎������j�󂳂�Ă���'	;fatal
;MK	INVALID_OBJ_ERR,'Module or Dictionary corrupt'	;fatal
MK	FATAL_RESTART_ERR,'�v���I��Restart�G���['		;fatal
;MK	FATAL_RESTART_ERR,'FATAL Restart error'		;fatal
MK	FIX_LIB_ERR,'���C�u������FIXLIB���K�v�ȉ\��������'	;warning
;MK	FIX_LIB_ERR,'Library probably needs FIXLIB'	;warning
MK	NO_BASE_SEG_ERR,'����`�Z�O�����g���Q�Ƃ��Ă���'	;fatal
;MK	NO_BASE_SEG_ERR,'References Undefined Segment'	;fatal

if	V5
MK	PAGESIZE_ERR,'/IMPLIB�ɂ��傫��/PAGESIZE���K�v'	;fatal
;MK	PAGESIZE_ERR,'/IMPLIB needs larger /PAGESIZE'	;fatal
MK	DIR_TOO_BIG,'������ 512k �𒴂���'		;fatal
;MK	DIR_TOO_BIG,'Dictionary Exceeded 512k'		;fatal
if	fg_virt
MK	CANT_WINPACK_ERR,'REAL���[�h�ł�WINPACK���g���Ȃ�'	;fatal
;MK	CANT_WINPACK_ERR,'Cannot WINPACK in REAL mode'	;fatal
endif
endif
MK	IMPORT_TOO_LONG_ERR,'���̂ɂ��C���|�[�g���ł��Ȃ�(>468����)'	;fatal
;MK	IMPORT_TOO_LONG_ERR,'Cannot Import by Name >468 chars'	;fatal
MK	EXPORT_TOO_LONG_ERR,'���̂ɂ��G�N�X�|�[�g���ł��Ȃ�(>468����)'	;fatal
;MK	EXPORT_TOO_LONG_ERR,'Cannot Export by Name >468 chars'	;fatal
MK	RES_TOO_LONG_ERR,'���\�[�X���� >468����'	;fatal
;MK	RES_TOO_LONG_ERR,'Resource Name >468 chars'	;fatal
MK	TOO_LONG_ERR,'�V���{���� >468����'		;fatal
;MK	TOO_LONG_ERR,'Symbol >468 chars'		;fatal

MK	USE32_USE16_ERR,'USE16/USE32�̖���'		;error
;MK	USE32_USE16_ERR,'USE16/USE32 Mismatch'		;error
MK	LIDATA_ERR,'�s��LIDATA���R�[�h'		;fatal
;MK	LIDATA_ERR,'Illegal LIDATA Record'		;fatal
MK	STACK_NZERO_ERR,'�X�^�b�N�G���['			;error
;MK	STACK_NZERO_ERR,'Stack Error'			;error

if	fg_pe
MK	RES_CONV_ERR,'16�r�b�g��32�r�b�g��.RES�ϊ��G���['	;fatal
;MK	RES_CONV_ERR,'16-bit to 32-bit .RES conversion failed'	;fatal
MK	VERSION_BIG_ERR,'VERSION���\�[�X��16��32�r�b�g�ϊ������T�|�[�g';fatal
;MK	VERSION_BIG_ERR,'Cannot yet convert VERSION resources from 16 to 32-bit';fatal
endif

MK	NO_IMPORTS_ERR,'Import Declarations Illegal'		;fatal
MK	NEAR_IMPORT_ERR,'NEAR call to IMPORT'
MK	CMDLINE_ERR,'Cmdline too long'
MK	MODEL_CONFLICT_ERR,'Memory Model Conflict'	;warning
MK	DUP_LOD_ERR,'Duplicate .LOD Specified'		;warning




		EVEN	?
ERR_TABLE	EQU	THIS WORD

LOOP_CNT	=	0
		REPT	ERR_CNT
		BUILD	%LOOP_CNT
LOOP_CNT	=	LOOP_CNT+1
		ENDM

OFFSET_ADR	DB	' �I�t�Z�b�g '
;OFFSET_ADR	DB	' Offset '
ERROR_ADR	DB	' �G���[ '
;ERROR_ADR	DB	' Error '
WARN_ADR	DB	' �x�� '
;WARN_ADR	DB	' Warning '
RECTYP_ADR	DB	'���R�[�h�^�C�v'
;RECTYP_ADR	DB	'Record Type '

if	fg_segm

PREVOFF_ADR	DB	'  �O�̃I�t�Z�b�g: '
;PREVOFF_ADR	DB	'  Previous Offset: '
NAME_ADR	DB	'  ����: '
;NAME_ADR	DB	'  Name: '
TYPE_ADR	DB	0DH,0AH,'�^�C�v: '
;TYPE_ADR	DB	0DH,0AH,'Type: '

		EVEN	?

PRC_RC_TYPES	LABEL	WORD

		DW	RT_0000H		;0
		DW	RT_CURSOR		;1
		DW	RT_BITMAP		;2
		DW	RT_ICON			;3
		DW	RT_MENU			;4
		DW	RT_DIALOG		;5
		DW	RT_STRING		;6
		DW	RT_FONTDIR		;7
		DW	RT_FONT			;8
		DW	RT_ACCELERATORS		;9
		DW	RT_RCDATA		;10
		DW	RT_ERRTABLE		;11
		DW	RT_GROUP_CURSOR		;12
		DW	RT_000DH		;13
		DW	RT_GROUP_ICON		;14
		DW	RT_NAMETABLE		;15

RT_0000H	DB	LENGTH RT_0000H-1,'0000'
RT_CURSOR	DB	LENGTH RT_CURSOR-1,'�J�[�\��'
;RT_CURSOR	DB	LENGTH RT_CURSOR-1,'Cursor'
RT_BITMAP	DB	LENGTH RT_BITMAP-1,'�r�b�g�}�b�v'
;RT_BITMAP	DB	LENGTH RT_BITMAP-1,'Bitmap'
RT_ICON		DB	LENGTH RT_ICON-1,'�A�C�R��'
;RT_ICON		DB	LENGTH RT_ICON-1,'Icon'
RT_MENU		DB	LENGTH RT_MENU-1,'���j���['
;RT_MENU		DB	LENGTH RT_MENU-1,'Menu'
RT_DIALOG	DB	LENGTH RT_DIALOG-1,'�_�C�A���O'
;RT_DIALOG	DB	LENGTH RT_DIALOG-1,'Dialog'
RT_STRING	DB	LENGTH RT_STRING-1,'�X�g�����O�e�[�u��'
;RT_STRING	DB	LENGTH RT_STRING-1,'String Table'
RT_FONTDIR	DB	LENGTH RT_FONTDIR-1,'�t�H���g�f�B���N�g��'
;RT_FONTDIR	DB	LENGTH RT_FONTDIR-1,'Font Directory'
RT_FONT		DB	LENGTH RT_FONT-1,'�t�H���g'
;RT_FONT		DB	LENGTH RT_FONT-1,'Font'
RT_ACCELERATORS	DB	LENGTH RT_ACCELERATORS-1,'�A�N�Z�����[�^'
;RT_ACCELERATORS	DB	LENGTH RT_ACCELERATORS-1,'Accelerator'
RT_RCDATA	DB	LENGTH RT_RCDATA-1,'RCDATA'
RT_ERRTABLE	DB	LENGTH RT_ERRTABLE-1,'�G���[�e�[�u��'
;RT_ERRTABLE	DB	LENGTH RT_ERRTABLE-1,'Error Table'
RT_GROUP_CURSOR	DB	LENGTH RT_GROUP_CURSOR-1,'�O���[�v�J�[�\��'
;RT_GROUP_CURSOR	DB	LENGTH RT_GROUP_CURSOR-1,'Group Cursor'
RT_000DH	DB	LENGTH RT_000DH-1,'000D'
RT_GROUP_ICON	DB	LENGTH RT_GROUP_ICON-1,'�O���[�v�A�C�R��'
;RT_GROUP_ICON	DB	LENGTH RT_GROUP_ICON-1,'Group Icon'
RT_NAMETABLE	DB	LENGTH RT_NAMETABLE-1,'���̃e�[�u��'
;RT_NAMETABLE	DB	LENGTH RT_NAMETABLE-1,'Name Table'

endif

OPTLINK_TEXT	DB	'OPTLINK :'

XX	=	0

STD_HELP	MACRO	X

		PUBLIC	X&_EQU

X&_EQU		EQU	(XX)
XX		=	XX+1

		DW	X&_TEXT

		ENDM

		EVEN	?

STD_TEXT_TABLE	LABEL	WORD

		STD_HELP	LIBRARY
		STD_HELP	SEGCLASS
		STD_HELP	FILES
		STD_HELP	PUBSYMS
		STD_HELP	SEGMENTS
		STD_HELP	SEGMODS
		STD_HELP	GROUPS
		STD_HELP	MODULES
		STD_HELP	OUTFILES
		STD_HELP	AREAS
		STD_HELP	SECTIONS
		STD_HELP	CSEGS
		STD_HELP	RELOCS
		STD_HELP	SRCS
if	fg_td
		STD_HELP	TDLOCALS
		STD_HELP	TDCLASSES
		STD_HELP	TDLTYPES
		STD_HELP	TDLCLASSES
		STD_HELP	TDLMEMBERS
endif

if	fg_segm OR fg_pe
		STD_HELP	IMPNAMES
		STD_HELP	ENTNAMES
		STD_HELP	PENTS
		STD_HELP	ENTRIES
		STD_HELP	IMPMODS
		STD_HELP	RESNAMES
		STD_HELP	RESTYPES
		STD_HELP	RES_TYPENAMES
		STD_HELP	RTNLS
endif

if	fg_pe
		STD_HELP	PAGE_RELOCS
endif

LIBRARY_TEXT	DB	LENGTH LIBRARY_TEXT-1,'���C�u�����t�@�C��'
;LIBRARY_TEXT	DB	LENGTH LIBRARY_TEXT-1,'Library Files'
SEGCLASS_TEXT	DB	LENGTH SEGCLASS_TEXT-1,'�Z�O�����g�N���X'
;SEGCLASS_TEXT	DB	LENGTH SEGCLASS_TEXT-1,'Segment Classes'
FILES_TEXT	DB	LENGTH FILES_TEXT-1,'�t�@�C����'
;FILES_TEXT	DB	LENGTH FILES_TEXT-1,'Filenames'
PUBSYMS_TEXT	DB	LENGTH PUBSYMS_TEXT-1,'�O���[�o���V���{��'
;PUBSYMS_TEXT	DB	LENGTH PUBSYMS_TEXT-1,'Global Symbols'
SEGMENTS_TEXT	DB	LENGTH SEGMENTS_TEXT-1,'�Z�O�����g'
;SEGMENTS_TEXT	DB	LENGTH SEGMENTS_TEXT-1,'Segments'
SEGMODS_TEXT	DB	LENGTH SEGMODS_TEXT-1,'�Z�O�����g����'
;SEGMODS_TEXT	DB	LENGTH SEGMODS_TEXT-1,'Segment Pieces'
GROUPS_TEXT	DB	LENGTH GROUPS_TEXT-1,'�O���[�v'
;GROUPS_TEXT	DB	LENGTH GROUPS_TEXT-1,'Groups'
MODULES_TEXT	DB	LENGTH MODULES_TEXT-1,'���W���[��'
;MODULES_TEXT	DB	LENGTH MODULES_TEXT-1,'Modules'
OUTFILES_TEXT	DB	LENGTH OUTFILES_TEXT-1,'�o�̓t�@�C����'
;OUTFILES_TEXT	DB	LENGTH OUTFILES_TEXT-1,'Output Filenames'
AREAS_TEXT	DB	LENGTH AREAS_TEXT-1,'�̈�(Area)'
;AREAS_TEXT	DB	LENGTH AREAS_TEXT-1,'Areas'
SECTIONS_TEXT	DB	LENGTH SECTIONS_TEXT-1,'�Z�N�V����'
;SECTIONS_TEXT	DB	LENGTH SECTIONS_TEXT-1,'Sections'
CSEGS_TEXT	DB	LENGTH CSEGS_TEXT-1,'�f�o�b�O�p�Z�O�����g����'
;CSEGS_TEXT	DB	LENGTH CSEGS_TEXT-1,'Debug Segment Pieces'
RELOCS_TEXT	DB	LENGTH RELOCS_TEXT-1,'�Ĕz�u'
;RELOCS_TEXT	DB	LENGTH RELOCS_TEXT-1,'Relocations'
SRCS_TEXT	DB	LENGTH SRCS_TEXT-1,'�\�[�X�t�@�C��'
;SRCS_TEXT	DB	LENGTH SRCS_TEXT-1,'Source Files'

if	fg_td
TDLOCALS_TEXT	DB	LENGTH	TDLOCALS_TEXT-1,'TD���[�J���V���{��'
;TDLOCALS_TEXT	DB	LENGTH	TDLOCALS_TEXT-1,'TD Local Symbols'
TDCLASSES_TEXT	DB	LENGTH	TDCLASSES_TEXT-1,'TD�N���X'
;TDCLASSES_TEXT	DB	LENGTH	TDCLASSES_TEXT-1,'TD Classes'
TDLTYPES_TEXT	DB	LENGTH	TDLTYPES_TEXT-1,'TD���[�J���^'
;TDLTYPES_TEXT	DB	LENGTH	TDLTYPES_TEXT-1,'TD Local Types'
TDLCLASSES_TEXT	DB	LENGTH TDLCLASSES_TEXT-1,'TD���[�J���N���X'
;TDLCLASSES_TEXT	DB	LENGTH TDLCLASSES_TEXT-1,'TD Local Classes'
TDLMEMBERS_TEXT	DB	LENGTH TDLMEMBERS_TEXT-1,'TD���[�J�������o'
;TDLMEMBERS_TEXT	DB	LENGTH TDLMEMBERS_TEXT-1,'TD Local Members'
endif

if	fg_segm OR fg_pe
IMPNAMES_TEXT	DB	LENGTH IMPNAMES_TEXT-1,'�C���|�[�g��'
;IMPNAMES_TEXT	DB	LENGTH IMPNAMES_TEXT-1,'Imported Names'
ENTNAMES_TEXT	DB	LENGTH ENTNAMES_TEXT-1,'�G�N�X�|�[�g��'
;ENTNAMES_TEXT	DB	LENGTH ENTNAMES_TEXT-1,'Exported Names'
PENTS_TEXT	DB	LENGTH PENTS_TEXT-1,'Possible Entries'
;PENTS_TEXT	DB	LENGTH PENTS_TEXT-1,'Possible Entries'
ENTRIES_TEXT	DB	LENGTH ENTRIES_TEXT-1,'�G�N�X�|�[�g�V���{��'
;ENTRIES_TEXT	DB	LENGTH ENTRIES_TEXT-1,'Exported Symbols'
IMPMODS_TEXT	DB	LENGTH IMPMODS_TEXT-1,'�C���|�[�g���W���[��'
;IMPMODS_TEXT	DB	LENGTH IMPMODS_TEXT-1,'Imported Modules'
RESNAMES_TEXT	DB	LENGTH RESNAMES_TEXT-1,'RES�̖���'
;RESNAMES_TEXT	DB	LENGTH RESNAMES_TEXT-1,'RES Names'
RESTYPES_TEXT	DB	LENGTH RESTYPES_TEXT-1,'RES�̃^�C�v'
;RESTYPES_TEXT	DB	LENGTH RESTYPES_TEXT-1,'RES Types'
RES_TYPENAMES_TEXT	DB	LENGTH RES_TYPENAMES_TEXT-1,'RES�̌^��'
;RES_TYPENAMES_TEXT	DB	LENGTH RES_TYPENAMES_TEXT-1,'RES TypeNames'
RTNLS_TEXT	DB	LENGTH RTNLS_TEXT-1,'RES��RTNL'
;RTNLS_TEXT	DB	LENGTH RTNLS_TEXT-1,'RES RTNLs'

endif

if	fg_pe

PAGE_RELOCS_TEXT	DB	LENGTH PAGE_RELOCS_TEXT-1,'�Ĕz�u�y�[�W'
;PAGE_RELOCS_TEXT	DB	LENGTH PAGE_RELOCS_TEXT-1,'Relocation Pages'

endif

ERROR_DATA	ENDS

.DATA

EOF_TXT		DB	'[EOF]'

