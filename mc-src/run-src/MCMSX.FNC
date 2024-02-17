;=======================================
;  << Mini Compiler Ver1.0 >>
;    RUN-TIME & FUNCTION for MSX
;=======================================
;-----------------------
;  LOCATE( X, Y )
;-----------------------
_LOCATE:
	POP	BC		;BC=RETURN ADDRESS
	POP	DE		;DE=X
	POP	HL		;HL=Y
	PUSH	BC
	INC	L
	INC	E
	LD	H,E		;HL=XY
	LD	IX,POSIT
	JP	CALROM

;-------------------------------
;  SCREEN( NO, SIZE, KEY )
;-------------------------------
_SCREEN:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL
	LD	A,L		;A =SCREEN NO
	POP	HL
	LD	D,L		;D =SPRITE SIZE
	POP	HL
	LD	E,L		;E =KEY CLICK
	PUSH	BC
	CP	9		;SCREEN NO CHECK(for MSX2)
	RET	NC
	PUSH	DE
	LD	IX,CHGMOD
	CALL	CALROM
	POP	DE
	LD	A,E		;CLICK FLAG CHECK
	CP	2
	JR	NC,SCREN1
	LD	(CLIKSW),A	;KEY CLICK FLAG CHANGE
SCREN1:	LD	A,(RG1SAV)
	AND	0FCH
	OR	D
	LD	B,A		;B =SPRITE SIZE
	LD	C,1		;C =VDP REGISTOR NO
	LD	IX,WRTVDP
	CALL	CALROM		;SPRITE SIZE CHANGE
	LD	IX,CLRSPR
	JP	CALROM		;SPRITE INITIALIZE

;-------------------------------
;  COLOR( FORE, BACK, BORDER )
;-------------------------------
_COLOR:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL
	LD	A,L		;A =FORE COLOR
	LD	(FORCLR),A
	POP	HL
	LD	A,L		;A =BACK COLOR
	LD	(BAKCLR),A
	POP	HL
	LD	A,L		;A =BORDER OCLOR
	LD	(BDRCLR),A
	PUSH	BC
	LD	IX,CHGCLR
	JP	CALROM

;-----------------------
;  VPEEK( ADR )
;-----------------------
_VPEEK:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=VRAM ADDRESS
	PUSH	BC
	LD	IX,RDVRM
CLROMA:	CALL	CALROM
	LD	L,A
	LD	H,0
	RET

;-----------------------
;  VPOKE( ADR, DATA )
;-----------------------
_VPOKE:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=VRAM ADDRESS
	POP	DE		;DE=DATA
	PUSH	BC
	LD	A,E
	LD	IX,WRTVRM
	JP	CALROM

;-------------------------------
;  VREAD( MADR, VADR, BYTE )
;-------------------------------
_VREAD:
	POP	IX		;IX=RETURN ADDRESS
	POP	DE		;DE=MEMORY ADDRESS
	POP	HL		;HL=VRAM ADDRESS
	POP	BC		;BYTE COUNT
	PUSH	IX
LDIRVM:	LD	IX,RDVRM
VREAD:	LD	A,B
	OR	C
	RET	Z
	CALL	CALROM
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	BC
	JR	VREAD

;-------------------------------
;  VWRITE( VADR, MADR, BYTE )
;-------------------------------
_VWRITE:
	POP	IX		;IX=RETURN ADDRESS
	POP	HL		;HL=VRAM ADDRESS
	POP	DE		;DE=MEMORY ADDRESS
	POP	BC		;BYTE COUNT
	PUSH	IX
LDIRMV:	LD	IX,WRTVRM
VWRITE:	LD	A,B
	OR	C
	RET	Z
	LD	A,(DE)
	CALL	CALROM
	INC	HL
	INC	DE
	DEC	BC
	JR	VWRITE

;-----------------------
;  SPRITE( PTN, DATA )
;-----------------------
_SPRITE:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=SPRITE PATTERN NO
	POP	DE		;DE=PATTERN DATA ADDRESS
	PUSH	BC
	LD	A,(SCRMOD)	;SCREEN CHECK
	OR	A
	RET	Z
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,(PATBAS)
	ADD	HL,BC		;HL=(PATBAS)+PTN*8
	LD	A,(RG1SAV)
	AND	2
	LD	B,0
	LD	C,8
	JP	Z,LDIRMV
	LD	C,32		;BC=SPRITE DATA COUNT
	JP	LDIRMV

;-------------------------------
;  PUTSPR( NO, X, Y, C, PTN )
;-------------------------------
_PUTSPR:
	POP	IX		;IX=RETURN ADDRESS
	POP	DE		;DE=SPRITE NO
	POP	BC
	LD	H,C		;H =X
	POP	BC
	LD	L,C		;L =Y
	LD	(WORK),HL
	POP	BC
	LD	H,C		;H =COLOR
	POP	BC
	LD	L,C		;L =SPRITE PATTERN NO
	LD	(WORK+2),HL	;(WORK)=Y,X,PTN,C
	PUSH	IX
	LD	A,(SCRMOD)	;SCREEN NO CHECK
	OR	A
	RET	Z
	EX	DE,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,(ATRBAS)
	ADD	HL,DE		;HL=ATRBAS+NO*4
	LD	B,0
	LD	C,4
	LD	DE,WORK
	JP	LDIRMV

;-----------------------
;  STICK( NO )
;-----------------------
_STICK:
	POP	BC		;BC=RETURN ADDERSS
	POP	HL		;HL=NO
	PUSH	BC
	LD	A,L
	LD	IX,GTSTCK
	JP	CLROMA

;-----------------------
;  STRIG( NO )
;-----------------------
_STRIG:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=NO
	PUSH	BC
	LD	A,L
	LD	IX,GTTRIG
	JP	CLROMA

;-----------------------
;  KEYSNS( NO )
;-----------------------
_KEYSNS:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=MATRIX NO
	PUSH	BC
	LD	A,L
	LD	IX,SNSMAT
	JP	CLROMA

;-----------------------
;  KILBUF()
;-----------------------
_KILBUF:
	LD	IX,KILBUF
	JP	CALROM

;-----------------------
;  PSGINI()
;-----------------------
_PSGINI:
	LD	IX,GICINI
	JP	CALROM

;-----------------------
;  SOUND( REG, DATA )
;-----------------------
_SOUND:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL
	LD	A,L		;A =REGISTER NO
	POP	HL
	LD	E,L		;E = DATA
	PUSH	BC
	LD	IX,WRTPSG	
	JP	CALROM
