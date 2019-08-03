; This program is a simple one to test the I/O capabilities of the P3D IHU
;
         .org 0       ;comment test

start:  NOP
	DEC	0
	NOP
	LDI	9
	PLO	3
	GHI	0
	PHI	3
	SEP	3
	SEX	2

label:	BN1	label
	INP	2	; 0x0A
	OUT	1
	INP	3	; 0x0B
	OUT	2
	INP	3	; 0x0B
	OUT	4
	INP	3	; 0x0B
	OUT	7
	INP	5	; 0x0D
	OUT	3
	INP	6	; 0x0E
	OUT	6	; pulse only
	INP	6	; 0x0E

;	reset psuedo interrupt

	OUT	5

;	play it again and again...

	BR	label

;	sync vectors

	.db	0x50
	.db	0x50
	.db	0x50
	.db	0x50
	.db	0x50
	.db	0x50

	.db	0x39
	.db	0x15
	.db	0xED
	.db	0x30
	.db	"This is a test of inputs A, B, D and E and outputs 1, 2, 3, 4, 7 and output pulse 6... :-)"
	
         .end  start
