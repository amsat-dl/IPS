0660103030566
9[....................................................]
€

*******************************************************************
*        EMERGENCY PROGRAM  FOR OSCAR-10       V2.1               *
*        1986 NOV 17  @ 22:00 UTC                                 *
*******************************************************************

0000      71        DIS            *** PREVENT INTERRUPTS
0001      20        DEC,0          *** NO FUNCTION, BAD MEMORY
0002      C0 00 F0  LBR,#00F0      *** JUMP TO BETTER MEMORY
*
* #0005 TO #00EF FILLED WITH #FF-PATTERN TO CHECK MEMORY
*                EXCEPT #007B TO #007F, WHERE SYNC IS STORED.
*
00BB      50 39 15                 *** SYNC-VECTOR
00BE      ED 30
*
*
00F0      F8 F6     LDI,#F6        *** SET INTERRUPT-SERVICE- 
00F2      A1        PLO,1          *** REGISTER #1 TO ADDRESS
00F3      F8 00     LDI,#00        *** #00F6
00F5      B1        PHI,1          
00F6      E2        SEX,2          *** REGISTER #2 IS DATA PONITER
00F7      D1        SEP,1          *** REGISTER #1 IS PROGRAM COUNTER
00F8      A2        PLO,2          *** DATA REGISTER TO #XX00
00F9      F8 02     LDI,#02        *** SET DATA POINTER (REG #2)
00FB      B2        PHI,2          *** ON ADDR. #0200
00FC      F8 A0     LDI,#A0        *** >>>> TRANSPONDER WORD <<<<
00FE      52        STR,2          *** STORE VIA REG #2 (DATA-POINTER)
00FF      67        OUT,7          *** OUTPUT VIA PORT 7 TO TRANSPONDER
0100      F8 00     LDI,#00      
*
0102      B0        PHI,0          *** SET DMA-POINTER TO PAGE #00XX
0103      C0 01 02  LBR,#0102      *** INFINITE LOOP.. HOPEFULLY FOR EVER
*
                    END       
