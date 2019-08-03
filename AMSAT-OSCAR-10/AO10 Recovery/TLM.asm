
*******************************************************************
*        TELEMETRY PROGRAM  FOR OSCAR-10       V1.0               *
*        1986 NOV 13  @ 20:00 UTC     de DB2OS                    *
*******************************************************************

0000      71        DIS            *** PREVENT INTERRUPTS
0001      20        DEC,0          *** NO FUNCTION, BAD MEMORY
0002      C4        NOP
0003      F8 09     LDI,#09        *** SET INTERRUPT-SERVICE- 
0005      A1        PLO,1          *** REGISTER #1 TO ADDRESS
0006      F8 00     LDI,#00        *** #0009
0008      B1        PHI,1          
0009      E2        SEX,2          *** REGISTER #2 IS DATA PONITER
000A      D1        SEP,1          *** REGISTER #1 IS PROGRAM COUNTER
000B      A2        PLO,2          *** DATA REGISTER WAS 0
000C      F8 02     LDI,#02        *** SET DATA POINTER (REG #2)
000E      B2        PHI,2          *** ON ADDR. #0200
000F      F8 A0     LDI,#A0        *** >>>> TRANSPONDER WORD <<<<
0011      52        STR,2          *** STORE VIA REG #2 (DATA-POINTER)
0012      67        OUT,7          *** OUTPUT VIA PORT 7 TO TRANSPONDER
0013      F8 00     LDI,#00      
*
0015      B0        PHI,0          *** SET DMA-POINTER TO PAGE #00XX
0016      C0 00 90  LBR,#0090      *** JUMP TO TELEMETRY-ROUTINE         
*
*  FREE AREA FILLED WITH #FF
*
0090      B2        PHI,2          *** SET DATA-POINTER TO #0000
0091      F8 00     LDI,#0         
0093      A2        PLO,2
*
0094      F8 00     LDI,#0         *** RESET DMA-COUNTER TO PAGE #00XX
0096      B0        PHI,0
0097      3C 96     BN1,#96        *** WAIT FOR 20MS PSEUDO-INTERRUPT
*
0099      E2        SEX,2          *** REGISTER #2 IS DATA-POINTER
009A      F8 80     LDI,#80        *** SET DATA-POINTER TO #0080  
009C      A2        PLO,2
009D      F0        LDX            *** LOAD ACCU VIA DATA-POINTER
009E      AC        PLO,C          *** STORE IN REGISTER #C
009F      FC 01     ADI,#01        *** NEXT
00A1      FA 3F     ANI,#3F        *** LIMIT
00A3      52        STR,2
00A4      65        OUT 5          *** SELECT ANALOG MUX & ACK 20MS-IRPT
00A5      8C        GLO,C
00A6      A2        PLO,2          *** STORE TLM-BYTE FROM #0000 TO #003F
00A7      69        INP 9          *** GET BYTE FROM A/D-CONVERTER
00A8      C0 00 94  LBR, #0094     *** LOOP... HOPEFULLY FOR EVER
*
00BB      50 39 15                 *** SYNC-VECTOR
00BE      ED 30
*
* USE #00C0 TO #00FF FOR TEXT MESSAGES ETC.
*
                    END



TELEMETRY FORMAT V1.0
=====================

LINE
 #1 ----------------------- 64 BYTES TELEMETRY DATA --------------------
 #2 NOT USED NOT - NOT USED - NOT USED - NOT USED - NOT USED - NOT USED
 #3 ............................ PROGRAM AREA ......................SYNC
 #4 H  DB2OS  DB2OS:  TELEMETRY ACTIVATED - TELEMETRY ACTIVATED      
 #5
 #6                 SAME AS ABOVE
 #7
 #8


