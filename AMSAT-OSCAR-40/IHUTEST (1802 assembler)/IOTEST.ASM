;
; This program is a simple one to test the I/O capabilities of the P3D IHU
;     modified: DB2OS  02/09/95
;
        .org 0

        NOP         ;
        DEC 0       ;  Wait for DMA
        NOP         ;
;
        LDI begin   ; Jump to "begin"
        PLO 1       ; set lower nibble of R(1)
        GHI 0       ; load Accumulator with Zero
        PHI 1       ; set higher nibble of R(1)
        SEP 1       ; R(1)->P is now Programm Counter
;
begin:  SEX 2       ; R(2)->X is now Data Pointer
;
loop:   BN1 loop    ; Wait for 50ms Pseudo-Interrupt on EF1
;
;       Copy Inputs to Outputs every 50ms..
;
        INP 2       ; 0x0A
        OUT 1
        INP 3       ; 0x0B
        OUT 2
        INP 3       ; 0x0B
        OUT 4
        INP 3       ; 0x0B
        OUT 7
        INP 5       ; 0x0D
        OUT 3
        INP 6       ; 0x0E
        OUT 6       ; pulse only
        INP 6       ; 0x0E
;
        OUT 5       ; Reset Pseudo Interrupt Flag
        BR  loop    ; Play it again..
;
;	sync vectors
        .db 0x50, 0x50, 0x50, 0x50, 0x50
        .db 0x50, 0x39, 0x15, 0xED, 0x30
        .db "  This is a test of inputs A, B, D and E and outputs 1, 2, 3, 4, 7 and output pulse 6... :-)"
;
        .end

