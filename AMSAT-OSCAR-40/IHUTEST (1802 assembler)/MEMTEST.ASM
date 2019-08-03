;
;       Simple Memory Test Program
;       DB2OS  01/09/95
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
loop0:  LDI 0x02
        PHI 2
        LDI 0x00
        PLO 2       ; #0200 Start Adress
;
loop1:  INP 2       ; get testpattern from Switchbox IN-A
        STR 2       ; write into memory
        LDN 2       ; read from memory
        OUT 1       ; display on LED's OUT-A
        INC 2       ; Increment data pointer
        GHI 2
        XRI 0xF0
        BNZ loop1   ; repeat until 0xEFFF
;
        BR  loop0   ; do it again..
;
sync:   .db 0x50, 0x39, 0x15, 0xED, 0x30   ; SYNC-Vector
        .db "  -- Simple IHU Memory Test  01Sep95 DB2OS --  "
;
        .end

