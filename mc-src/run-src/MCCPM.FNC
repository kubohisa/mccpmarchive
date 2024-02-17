;=======================================
;  << Mini Compiler Ver1.3 >>
;    RUN-TIME & FUNCTION for CP/M
;=======================================
;===============================
;    RUN TIME ROUTINE
;===============================
;-----------------------
;  HL<DE =>TRUE
;-----------------------
$MCLT:
	CALL	CMPSB1
	RET	NC
	INC	HL
	RET

;-----------------------
;  HL>=DE =>TRUE
;-----------------------
$MCGE:
	CALL	CMPSB1
	RET	C
	INC	HL
	RET

;-----------------------
;  HL==DE =>TRUE
;-----------------------
$MCEQ:
	CALL	CMPSB2
MCEQ:	RET	NZ
	INC	HL
	RET

;-----------------------
;  HL!=DE =>TRUE
;-----------------------
$MCNE:
	CALL	CMPSB2
	RET	Z
	INC	HL
	RET
CMPSB1:	LD	A,H
	ADD	A,80H
	LD	H,A
	LD	A,D
	ADD	A,80H
	LD	D,A
CMPSB2:	OR	A
	SBC	HL,DE
	LD	HL,0
	RET

;-----------------------
;  !HL =>HL
;-----------------------
$MCNOT:
	LD	A,H
	OR	L
	LD	HL,0
	JR	MCEQ

;-----------------------
;  -HL =>HL
;-----------------------
$MCNEG:	
	LD	A,H
	CPL
	LD	H,A
	LD	A,L
	CPL
	LD	L,A
	INC	HL
	RET

;-----------------------
;  DE*HL =>HL
;-----------------------
$MCMULT:
	LD	B,H
	LD	C,L
	LD	HL,0
MULT1:	LD	A,B
	OR	C
	RET	Z
	SRL	B
	RR	C
	JR	NC,MULT2
	ADD	HL,DE
MULT2:	SLA	E
	RL	D
	JR	MULT1

;-------------------------------
;  HL/DE =>DE,HL(MOD)
;-------------------------------
$MCDIVI:
	LD	A,H
	XOR	D
	PUSH	AF
	LD	A,H
	OR	A
	CALL	M,$MCNEG
	EX	DE,HL
	LD	A,H
	OR	A
	CALL	M,$MCNEG
	LD	B,H
	LD	C,L
	LD	HL,0
	LD	A,16
DIVI1:	SLA	E
	RL	D
	ADC	HL,HL
	SBC	HL,BC
	JR	NC,DIVI2
	ADD	HL,BC
	JR	DIVI3
DIVI2:	INC	E
DIVI3:	DEC	A
	JR	NZ,DIVI1
	POP	AF
	RET	P
	CALL	$MCNEG
	EX	DE,HL
	CALL	$MCNEG
	EX	DE,HL
	RET

;-----------------------
;  HL>>DE =>HL
;-----------------------
$MCSFTR:
	LD	A,E
	OR	A
SIFTR1:	RET	Z
	SRL	H
	RR	L
	DEC	A
	JR	SIFTR1

;-----------------------
;  HL<<DE =>HL
;-----------------------
$MCSFTL:
	LD	A,E
	OR	A
SIFTL1:	RET	Z
	ADD	HL,HL
	DEC	A
	JR	SIFTL1

;-----------------------
;  HL&&DE =>HL
;-----------------------
$MCANDB:
	LD	A,H
	OR	L
	LD	HL,0
	RET	Z
	LD	A,D
	OR	E
	RET	Z
	INC	HL
	RET

;-----------------------
;  HL&DE =>HL
;-----------------------
$MCAND:
	LD	A,H
	AND	D
	LD	H,A
	LD	A,L
	AND	E
	LD	L,A
	RET

;-----------------------
;  HL^DE =>HL
;-----------------------
$MCXOR:
	LD	A,H
	XOR	D
	LD	H,A
	LD	A,L
	XOR	E
	LD	L,A
	RET

;-----------------------
;  HL||DE =>HL
;-----------------------
$MCORB:
	LD	A,H
	OR	L
	LD	HL,1
	RET	NZ
	LD	A,D
	OR	E
	RET	NZ
	DEC	HL
	RET

;-----------------------
;  HL|DE =>HL
;-----------------------
$MCOR:
	LD	A,H
	OR	D
	LD	H,A
	LD	A,L
	OR	E
	LD	L,A
	RET

;-----------------------
;  LD (DE),HL
;-----------------------
$MCSTOR:
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	RET

;-----------------------
;  CALL (HL)
;-----------------------
$MCCALL:
	JP	(HL)

;===============================
;    CPM FUNCTION
;===============================
;-----------------------
;  GETCHR()
;-----------------------
_GETCHR:
	LD	C,1
	CALL	BDOS
	LD	L,A
	LD	H,0
	RET

;-----------------------
;  PUTCHR()
;-----------------------
_PUTCHR:
	POP	HL
	POP	DE
	PUSH	HL
PUTCH:	LD	C,2
	JP	BDOS

;---------------------------------
;  PRINTF( *FMT [,DATA..] )
;---------------------------------
_PRINTF:
	POP	IX		;IX=RETURN ADDRESS
	POP	BC		;BC=FORMAT
	XOR	A
	LD	(CONF),A

PRINTF:	LD	A,(BC)
	INC	BC
	OR	A
	JR	NZ,PRINT1
	JP	(IX)
PRINT1:	CP	'%'
	JR	NZ,PRINT2
	POP	HL		;HL=PARAMETER
	LD	A,(BC)
	INC	BC
	CP	'x'
	JR	Z,PRTHEX
	CP	'd'
	JR	Z,PRTDEC
	CP	'c'
	JR	Z,PRTCHR
	CP	's'
	JR	Z,PRTSTR
	PUSH	HL
PRINT2:	CALL	PUTC
	JR	PRINTF

PRTCHR:	LD	A,L
	JR	PRINT2

PRTSTR:	LD	A,(HL)
	INC	HL
	OR	A
	JP	Z,PRINTF
	CALL	PUTC
	JR	PRTSTR

PRTHEX:	LD	A,H
	CALL	PRTHX0
	LD	A,L
	CALL	PRTHX0
	JP	PRINTF
PRTHX0:	PUSH	AF
	RRA
	RRA
	RRA
	RRA
	CALL	PRTHX1
	POP	AF
PRTHX1:	AND	0FH
	ADD	A,'0'
	CP	'9'+1
	JP	C,PUTC
	ADD	A,7
	JP	PUTC

PRTDEC:	PUSH	BC
	CALL	PRTDC0
	POP	BC
	JP	PRINTF
PRTDC0:	LD	A,H
	OR	A
	JP	P,PRTDC1
	CALL	$MCNEG
	LD	A,'-'
	CALL	PUTC
PRTDC1:	LD	C,1		;ZERO-FLAG
	LD	DE,10000
	CALL	PRTDC2
	LD	DE,1000
	CALL	PRTDC2
	LD	DE,100
	CALL	PRTDC2
	LD	DE,10
	CALL	PRTDC2
	LD	DE,1
	LD	C,0
PRTDC2:	XOR	A
PRTDC3:	SBC	HL,DE
	JR	C,PRTDC4
	INC	A
	JR	PRTDC3
PRTDC4:	ADD	HL,DE
	OR	A
	JR	NZ,PRTDC5
	LD	A,C
	OR	A
	RET	NZ
PRTDC5:	ADD	A,'0'
	CALL	PUTC
	LD	C,0
	RET

PUTC:	LD	E,A
	LD	A,(CONF)
	OR	A
	JR	Z,PUTCON
	LD	(IY+0),E
	INC	IY
	XOR	A
	LD	(IY+0),A
	RET

PUTCON:	PUSH	IX
	PUSH	HL
	PUSH	BC
	CALL	PUTCH
	POP	BC
	POP	HL
	POP	IX
	RET

;---------------------------------
;  SPRINTF( *BUF, *FMT [,DATA..] )
;---------------------------------
_SPRINF:
	POP	IX		;IX=RETURN ADDRESS
	POP	IY		;IY=BUFFER ADDRESS
	POP	BC		;BC=FORMAT
	LD	A,1
	LD	(CONF),A
	JP	PRINTF

;---------------------------------
;  SCANF( *FMT [,DATA..] )
;---------------------------------
_SCANF:
	CALL	GETBUF
	POP	IX		;IX=RETURN ADDRESS
	POP	BC		;BC=FORMAT

SCANF:	LD	A,(BC)
	INC	BC
	OR	A
	JR	NZ,SCANF1
	JP	(IX)

SCANF1:	CP	'%'
	JR	NZ,SCANF
SCANF2:	LD	A,(IY+0)
	CP	' '
	JR	NZ,SCANF3
	INC	IY
	JR	SCANF2
SCANF3:	LD	A,(BC)
	INC	BC
	CP	'x'
	JR	Z,GETHEX
	CP	'd'
	JR	Z,GETDEC
	CP	'c'
	JR	Z,GETCHR
	CP	's'
	JR	Z,GETSTR
	JR	SCANF

GETC:	LD	A,(IY+0)
	INC	IY
	CP	' '+1
	JR	C,GETZRO
	OR	A
	RET
GETZRO:	XOR	A
	RET

GETCHR:	POP	DE
	CALL	GETC
	LD	(DE),A
	JP	SCANF

GETSTR:	POP	DE
GETST1:	CALL	GETC
	JR	Z,GETST2
	LD	(DE),A
	INC	DE
	JR	GETST1
GETST2:	XOR	A
	LD	(DE),A
	JP	SCANF

GETDEC:	PUSH	BC
	LD	HL,0
	LD	C,L		;SIGN-FLAG
	CALL	GETC
	CP	'-'
	JR	NZ,GETDC2
	INC	C
GETDC1:	CALL	GETC
GETDC2:	SUB	'0'
	JR	C,GETDC3
	CP	10
	JR	NC,GETDC3
	ADD	HL,HL
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	LD	E,A
	LD	D,0
	ADD	HL,DE
	JR	GETDC1
GETDC3:	LD	A,C
	OR	A
	JR	Z,GETDC4
	CALL	$MCNEG
GETDC4:	POP	BC
	POP	DE
	CALL	$MCSTOR
	JP	SCANF

GETHEX:	LD	HL,0
GETHX1:	CALL	GETC
	CP	'a'
	JR	C,GETHX2
	SUB	20H
GETHX2:	SUB	'0'
	JR	C,GETHX4
	CP	10
	JR	C,GETHX3
	SUB	7
	CP	10
	JR	C,GETHX4
	CP	16
	JR	NC,GETHX4
GETHX3:	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	E,A
	LD	D,0
	ADD	HL,DE
	JR	GETHX1
GETHX4:	POP	DE
	CALL	$MCSTOR
	JP	SCANF

GETBUF:	LD	DE,TXTBUF
	LD	C,10
	CALL	BDOS
	LD	E,0DH
	CALL	PUTCH
	LD	E,0AH
	CALL	PUTCH
	LD	HL,WORK
	LD	A,(TXTBUF+1)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	XOR	A
	LD	(HL),A
	LD	IY,WORK
	RET

;---------------------------------
;  SSCANF( *BUF, *FMT [,DATA..] )
;---------------------------------
_SSCANF:
	POP	IX		;IX=RETURN ADDRESS
	POP	IY		;IY=BUFFER ADDRESS
	POP	BC		;BC=FORMAT
	JP	SCANF

;-----------------------
;  INKEY()
;-----------------------
_INKEY:	
	LD	C,6
	LD	E,0FFH
	CALL	BDOS
	LD	L,A
	LD	H,0
	RET

;-----------------------
;  STRLEN( *STR )
;-----------------------
_STRLEN:
	POP	BC		;BC=RETURN ADDRESS
	POP	DE		;DE=TOP ADDRESS
	PUSH	BC
STRLEN:	LD	HL,0
STRLNL:	LD	A,(DE)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRLNL

;---------------------------------------
;  STRCPY( *TO, *FROM )
;---------------------------------------
_STRCPY:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=TO ADDRESS
	POP	DE		;DE=FROM ADDRESS
	PUSH	BC

STRCPY:	PUSH	HL
	PUSH	DE
	CALL	STRLEN
	INC	HL		;Add NULL byte
	LD	B,H
	LD	C,L
	POP	HL		;HL=FROM ADDRESS
	POP	DE		;DE=TO ADDRESS
	JP	MEMCPY

;---------------------------------------
;  STRCAT( *TO, *FROM )
;---------------------------------------
_STRCAT:
	POP	BC		;BC=RETURN ADDRESS
	POP	DE
	CALL	STRLEN		;DE=TO ADDRESS
	POP	HL		;HL=FROM ADDRESS
	PUSH	BC
	EX	DE,HL
	JR	STRCPY

;---------------------------------------
;  MEMSET( *ADR, DATA, LENGTH )
;---------------------------------------
_MEMSET:
	POP	IX		;IX=RETURN ADDRESS
	POP	HL		;HL=TOP ADDRESS
	POP	DE		;E =DATA
	POP	BC		;BC=COUNT
	PUSH	IX
	LD	A,B		;COUNTER CHECK
	OR	C
	RET	Z	
	LD	(HL),E		;1st DATA SET
	LD	D,H
	LD	E,L
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	RET	Z
	LDIR
	RET

;---------------------------------------
;  MEMCPY( *TO, *FROM, LENGTH )
;---------------------------------------
_MEMCPY:
	POP	IX		;IX=RETURN ADDRESS
	POP	DE		;DE=TO ADDRESS
	POP	HL		;HL=FROM ADDRESS
	POP	BC		;BC=LENGTH
	PUSH	IX
MEMCPY:	LD	A,B		;COUNTER CHECK
	OR	C
	RET	Z
	PUSH	HL
	SBC	HL,DE
	POP	HL
	RET	Z
	JR	C,MEMCPJ
	LDIR			;FADR > TADR
	RET
MEMCPJ:	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	DEC	HL
	DEC	DE
	LDDR			;FADR < TADR
	RET

;---------------------------------------
;  MEMCMP( *ADR1, *ADR2, LENGTH )
;---------------------------------------
_MEMCMP:
	POP	IX		;IX=RETURN ADDRESS
	POP	HL		;HL=ADDRESS1
	POP	DE		;DE=ADDRESS2
	POP	BC		;BC=LENGTH
	PUSH	IX
MEMCM1:	LD	A,B
	OR	C
	JR	Z,MEMCM2
	LD	A,(DE)
	CP	(HL)
	JR	NZ,MEMCM2
	INC	DE
	INC	HL
	DEC	BC
	JR	MEMCM1
MEMCM2:	LD	HL,1
	RET	C
	DEC	HL
	RET	Z
	DEC	HL
	RET

;-------------------------------
;  BDOS( NO, PARA )
;-------------------------------
_BDOS:
	POP	HL		;HL=RETURN ADDRESS
	POP	BC		;C =BDOS NO
	POP	DE		;DE=PARAMETER
	PUSH	HL
	CALL	BDOS
	LD	L,A
	LD	H,0
	RET

;-----------------------
;  RND( NUM )
;-----------------------
_RND:
	POP	BC		;BC=RETURN ADDRESS
	POP	HL		;HL=NUM
	PUSH	BC
	LD	A,H
	CP	80H
	JR	C,RND0
	CALL	$MCNEG
	LD	(RNDSEE),HL
	RET
RND0:	OR	L
	RET	Z
	EX	DE,HL
	LD	HL,(RNDSEE)
	LD	B,H
	LD	C,L
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC
	LD	(RNDSEE),HL
	LD	HL,(RNDSEE+2)
	ADC	HL,HL
	ADC	HL,BC
	LD	(RNDSEE+2),HL
	LD	A,H
	LD	C,L
	LD	HL,0
	LD	B,16
	SRL	A
	RR	C
RND1:	JR	NC,RND2
	ADD	HL,DE
RND2:	RR	H
	RR	L
	RRA
	RR	C
	DJNZ	RND1
	RET
