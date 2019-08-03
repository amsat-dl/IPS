0660103030566
9[....................................................]
€*******************************************************************
*               SOFT_LOADER PROGRAM   FOR OSCAR-10       V2.1     *
*        1986 DEC 11  @ 14:00 UTC     DE DB2OS                    *
*******************************************************************
0000      71        DIS            *** DISABLE INTERRUPT
0001      00        IDLE           
0002      F8 10     LDI,#10        *** SET INTERRUPT REGISTER
0004      A1        PLO,1          *** & PROGRAM-COUNTER TO #0010
0005      F8 00     LDI,#00        
0007      B1        PHI,1
0008      E2        SEX,2          *** SELECT REG. #2 AS DATA-POINTER
0009      D1        SEP,1          *** SELECT PROGRAM-COUNTER & JUMP
*
0010      F8 02     LDI,#02        *** CONTINUE FROM #0009
0012      B2        PHI,2         
0013      F8 00     LDI,#00
0015      A2        PLO,2          *** SET DATA-POINTER TO #0200
*
0016      F8 20     LDI,#20        *** FILL MEMORY WITH  'SPACE'
0018      52        STR,2          *** FROM #0200 TO #3FFF
0019      12        INC,2
001A      92        GHI,2
001B      FB 40     XRI,#40
001D      3A 16     BNZ,#0016       *** R2 = #4000
*
001F      F8 00     LDI,#00        *** SET REG. #4 TO ADDR. #0030
0021      B4        PHI,4
0022      F8 30     LDI.#30
0024      A4        PLO,4
0025      F8 24     LDI,#24        *** SET X=2 AND P=4
0027      22        DEC,2          *** STORE AT LOCATION #3FFF
0028      52        STR,2
0029      70        RET            *** ENABLE INTERRUPT, RESET X,P
*
0030      F8 00     LDI,#00        *** SET LOADER-INTERRUPT #00EC
0032      B1        PHI,1
0033      F8 EC     LDI,#EC
0035      A1        PLO,1
0036      F8 36     LDI,#36        *** SET LOADER START-ADDRESS #3600
0038      B8        PHI,8
0039      F8 00     LDI.#00
003B      A8        PLO,8
*
003C      30 43     BR,#0043       *** LOOP, BROKEN BY INTERRUPT
*
*
* HERE BELOW CONTINUE AFTER INTERRUPT-LOADER FINISHED LOADING
*
0080      F8 36     LDI,#36        *** SET INTERRUPT TO #3600
0082      B1        PHI,1          *** REG. #1 ALSO AS PROGRAMCOUNTER
0083      F8 00     LDI,#00
0085      A1        PLO,1
0086      D1        SEP,1          *** GO AHEAD!!! JUMP TO #3600
*    
*
* INTERRUPT-HANDLER (LOADS 512 BYTES INTO MEMORY SPECIFIED BY REGISTER #8)
*
*  AFTER INTERRUPT, X AND P REGISTER ARE STORED IN THE T-REGISTER
*  AND ARE SET TO NEW VALUES. #2 IN X AND #1 IN P.
*
00EB MORE 70        RET            *** RESET X,P & INCREMENT X-REG.
*
00EC IRQ  22        DEC,2
00ED      78        SAV            *** SAVE T-REG. (X,P) AFTER INTERRUPT
00EE      22        DEC,2        
00EF      6C        INP,4          *** GET BYTE FROM CMD-DECODER
00F0      42        LDA,2          *** LOAD & INCREMENT REGISTER 2
00F1      58        STR,8          *** STORE BYTE IN GOOD MEMORY
00F2      18        INC,8          *** NEXT ADRESS
00F3      98        GHI,8          
00F4      FB 38     XRI,#38        *** END-ADDRESS #37FF
00F6      3A EB     BNZ,#EB  MORE  *** ALL LOADED?
*
00F8      F8 80     LDI,#80        *** CONTINUE MAIN-PROGRAM AT #0080
00FA      A4        PLO,4          ***
00FB      20        DEC,0          *** ADJUST FOR BAD MEMORY
00FC      30 EB     BR,#00EB MORE  *** GOTO #0080 AFTER RETURN FROM INT
*
                    END

USAGE: First Reset IHU (only the first time), afterwards upload the
       SOFT_LOADER via DMA and wait a few seconds. After the SOFT_LOADER
       is running (needs a moment to catch the unwished interrupt with
       the clear routine), upload the new software module into memory
       #3600. Execution starts automatically at location #3600, after
       the last byte is loaded.
 
       

