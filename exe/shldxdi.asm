		TITLE	SHLDXDI - Copyright (c) SLR Systems 1991

		INCLUDE	MACROS

		PUBLIC	SHL_DXDI_PAGESHIFT_DI

		.CODE	ROOT_TEXT

		ASSUME	DS:NOTHING

SHL_DXDI_PAGESHIFT_DI	PROC
		;
		;
		;
		REPT	PAGE_SHIFT
		ADD	DI,DI
		ADC	DX,DX
		ENDM
		SHRI	DI,PAGE_SHIFT
		RET

SHL_DXDI_PAGESHIFT_DI	ENDP

		END
