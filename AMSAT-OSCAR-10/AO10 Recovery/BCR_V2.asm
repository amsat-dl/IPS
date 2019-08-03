
*******************************************************************
*        BCR - CONTROL - PROGRAM      V2.0   (Status: OK!)        *
*        1986 NOV 13  @ 22:00 UTC     de DB2OS                    *
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
0016      C0 00 90  LBR,#0090      *** JUMP TO BCR-ROUTINE         
*
*  FREE AREA FILLED WITH #FF
*
0090      F8 CB     LDI,#CB        *** BCR-SOUT  203 (13.9V) 5 !2M
0092      52        STR,2          *** ^^^^^^^^^^^^^^^^^^^^^^^^^^^
0093      62        OUT,2          *** OUTPUT FOR DATA TO BE MULTIPLEXED
0094      F8 20     LDI,#20        *** BCR-SOUT BIT 5 (#20)   
0096      52        STR,2          *** ^^^^^^^^^^^^^^^^^^^^^^^^^^^
0097      20        DEC,0          *** NO FUNCTION, BAD MEMORY LOCATION
0098      61        OUT,1          *** BITS TO STROBE DATA-WORD OF OUT 2
0099      F8 00     LDI,#00                       
009B      52        STR,2     
009C      61        OUT,1          *** CLEAR   PULSE
009D      B0        PHI,0          *** SET DMA-POINTER TO PAGE #00XX
009E      C0 00 9D  LBR,#009D      *** LOOP, HOPEFULLY FOR EVER...
*
00BB      50 39 15                 *** SYNC-VECTOR
00BE      ED 30
*
* USE #00C0 TO #00FF FOR TEXT MESSAGES ETC.
*
                    END

NOTE:   After uploading this code install the TLM-code again and verify  
-----   the correct values of BCR-OUT, 14V-ST and A-BAT. It must be a
        little bit lower as currently. The value for P-BAT is also 
        expected to decrease. 

danger: If all goes well as expected, change the following bytes as
        follows. Be sure to have it correct. A wrong value might give
        a very negative power budget.

0090      F8 F5     LDI,#F5        *** BCR-SIN   245 (28V) 4 !2M
       
0094      F8 20     LDI,#10        *** BCR-SIN   BIT 4 (#10)   


        After successfull loading, the GB will transmit the first memory
        page via the downlink. 

now:    Load the TLM-code again and let the satellite stay transmitting
        telemetry

