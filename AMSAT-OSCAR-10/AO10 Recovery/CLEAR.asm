*******************************************************************
*        WHOLE MEMORY TEST PROGRAM    FOR OSCAR-10       V1.1     *
*        1986 NOV 23  @ 18:00 UTC     DE DB2OS                    *
*******************************************************************

0000      71        DIS            *** PREVENT INTERRUPTS
0001      20        DEC,0          *** NO FUNCTION, BAD MEMORY
0002      C0 00 F0  LBR,#00F0      *** JUMP TO BETTER MEMORY
*
* MAIN PROGRAM:
*                   CLEAR MEMORY FROM #0200 T0 #3FFF
*                   ================================
*
0090      20        DEC,0          *** ADJUST FOR BAD MEMORY
0091      20        DEC,0          ***             "    "
0092      20        DEC,0          *** ADJUST FOR  "    "
0093      20        DEC,0          ***             "    "
0094      F8 FF     LDI,#FF        *** PATTERN FOR MEMORY TEST
0096      52        STR,2          *** STORE PATTERN BEGINNING AT #0200
0097      60        IRX            *** INCREMENT DATA-POINTER (REG #2)
0098      92        GHI,2
0099      FB 3F     XRI,#40        *** CLEAR FROM #0200 TO #3FFF
009B      3A 94     BNZ,#0094      *** NEXT BYTE?
*
009D      20        DEC,0          ***            BAD MEMORY
009E      20        DEC,0          *** ADJUST FOR  "     "
009F      20        DEC,0          ***             "     "
00A0      C0 00 AO  LBR,#00A0      *** LOOP FOR EVER
*
00BB      50 39 15                 *** SYNC-VECTOR
00BE      ED 30
*
*
00F0      F8 F8     LDI,#F8        *** SET INTERRUPT-SERVICE- 
00F2      20        DEC,0          *** BAD MEMORY
00F3      A1        PLO,1          *** REGISTER #1 TO ADDRESS
00F4      F8 00     LDI,#00        *** #00F8
00F6      20        DEC,0          *** BAD MEMORY
00F7      B1        PHI,1          
00F8      E2        SEX,2          *** REGISTER #2 IS DATA POITER
00F9      D1        SEP,1          *** REGISTER #1 IS PROGRAM COUNTER
00FA      A2        PLO,2          *** DATA REGISTER TO #XX00
00FB      F8 02     LDI,#02        *** SET DATA POINTER (REG #2)
00FD      B2        PHI,2          *** ON ADDR. #0200
00FE      C4        NOP            *** BAD MEMORY
00FF      F8 A0     LDI,#A0        *** >>>> TRANSPONDER WORD <<<<
0101      52        STR,2          *** STORE VIA REG #2 (DATA-POINTER)
0102      67        OUT,7          *** OUTPUT VIA PORT 7 TO TRANSPONDER
0103      F8 00     LDI,#00      
*
0105      B0        PHI,0          *** SET DMA-POINTER TO PAGE #00XX
0106      C4        NOP            *** BAD MEMORY
0107      C0 00 90  LBR,#0090      *** JUMP TO MAIN PROGRAM
*
                    END       

