
typedef struct LIBRARY_STRUCT
{
    struct LIBRARY_STRUCT *_LS_NEXT_LIB_GINDEX;	// NEXT LIBRARY	PROBABLY FOR LRU
    struct LIBRARY_STRUCT *_LS_PREV_LIB_GINDEX;	// PREVIOUS LIBRARY
    struct LIBRARY_STRUCT *_LS_NEXT_RLIB_GINDEX;	// NEXT LIBRARY - REQUESTED ORDER
    int _LS_PREV_RLIB_GINDEX;	// I THINK NOT USED
#if	fgh_inthreads
    struct LIBRARY_STRUCT *_LS_NEXT_TRLIB_GINDEX;	// NEXT LIBRARY - REQUESTED ORDER FOR THIS THREAD
    int *_LS_NEXT_TRLIB_BLOCK;	// NEXT BLOCK FOR LIBREAD TO READ
    unsigned *_LS_NEXT_REQUEST_BLOCK;	// NEXT REQUEST BLOCK STORAGE SPOT
// _LS_HANDLE_SEM		GLOBALSEM_STRUCT<>	// SEMAPHORE CONTROLLING ACCESS TO HANDLE
#endif

    int _LS_BLOCKS_LEFT;	// # OF BLOCKS YET TO READ
    unsigned _LS_BLOCKS;	// TOTAL # OF PAGE_SIZE BLOCKS

    int _LS_LIBNUM;		// CV LIBRARY NUMBER
    struct LIBRARY_STRUCT *_LS_NEXT_CV_GINDEX;	// IN CODEVIEW ORDER...

#if	fgh_inthreads
    int _LS_OS2_BLOCKS_REQUESTED;	// # OF BLOCKS FOR OS2 THREAD TO READ
    struct MYL2_STRUCT *_LS_THREAD_LOCALS;	// OWNING READ-THREAD
#endif

    int _LS_MODULES;		// TOTAL # OF MODULES THIS LIB
    int _LS_MODULES_LEFT;	// # OF MODULES NOT READ IN - I THINK NOT USED

    int _LS_SELECTED_MODULES;	// # UNREAD SELECTED MODULES
    void *_LS_HANDLE;		// FILE HANDLE

    void *_LS_BLOCK_TABLE[4];	// PTR TO BLOCK TABLE - 4 BYTES PER BLOCK (MAYBE SEGMENT LIST IF TOO MANY BLOCKS)
				// 
				// DD	BLOCK_ADDRESS IF READ
				// DD	# OF MODULES UNPROCESSED IN THIS BLOCK
				// 
    int _LS_FILE_POSITION;	// CURRENT FILE-HANDLE POSITION
    void **_LS_MODULE_PTRS;	// PTR TO MODULE OFFSETS - 4 BYTE OFFSETS.  THIS IS PTR TO LIST OF BLOCKS IF >PAGE_SIZE/8
    struct FILE_LIST_STRUCT *_LS_FILE_LIST_GINDEX;	// PTR TO ORIGINAL FILE_LIST ENTRY
    struct SYMBOL_STRUCT *_LS_FIRST_EXTRN_GINDEX;	// FIRST REQUESTED SYMBOL FOR THIS LIBRARY
    int _LS_LAST_EXTRN_GINDEX;	// LAST REQUESTED SYMBOL FOR THIS
} LIBRARY_STRUCT;

extern struct LIBRARY_STRUCT *CURNLIB_GINDEX;
