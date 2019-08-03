         .org 0       ;comment test
         .db 1,2,3,4,5,6,7,8 ;define byte test
lab1:                ;label only test

                     ;blank line and comment only test
         .dw 1,32000  ;define word test
         .rs 10       ;reserve storage test
         .dw 1+lab1   ;add test
         .dw lab1-1   ;subtract test
         .dw 1*lab1   ;multiply test
         .dw 'k'      ;character test
         .db 1,d'6,077,o'77,q'77,0x77,h'77,x'aa,x'a,b'1111,b'1 ;radix test
         .db "k"      ;string test--should give no error
         .db "\n\t\b\r\f\\\'\0\145" ;string escape test sequence
         .dw 1 << 15  ;8000
         .dw x'8000 >> 15  ;0001
         .dw ~x'ffff    ;0000
         .dw -1         ;ffff
         .page
         .dw 10 /2      ;5
         .eject
         .dw 32000/2000 ;16
         .dw 27 %5      ;modulus = 2
         .dw x'5555 ~ x'5555 ;ffff
         .dw x'5555 | x'aaaa ;ffff
         .dw x'5555 ^ x'aaaa ;ffff
start:   .dw x'5555 ^ x'5555 ;0000
         .dw x'5555 & x'aaaa ;0000
         .dw x'5555 & x'5555 ;5555
         .dw 32000 + 1  ;large positive
         .dw -32000 + 1 ;small negative
         .dw 5 + - 3 * 2 /3 ;complex expression
         .dw 5 + (-3)*2/3   ;
         .dw lab2
         .dw lab2+1         ;test expression sync
         .code        ;extraneous switch to current segment
         .segment foo
         foo
         .org x'ff
         .db 1,2
         .code
         .db 3,4
         foo
lab2:    .db,5,6
         .set lab3,lab2
         .equ lab3,start
codetst:  LDN     1
          LDA     1
          LDX
          LDXA
          LDI     1
          STR     1
          STXD
          INC     1
          DEC     1
          IRX
          GLO     1
          PLO     1
          GHI     1
          PHI     1
          OR
          ORI     1
          XOR
          XRI     1
          AND
          ANI     1
          SHR
          SHRC
          RSHR
          SHL
          SHLC
          RSHL
          ADD
          ADI     1
          ADC
          ADCI    1
          SD
          SDI     1
          SDB
          SDBI    1
          SM
          SMI     1
testbr:   SMB
          SMBI    1
          BR      testbr
          NBR
          BZ      testbr
          BNZ     testbr
          BDF     testbr
          BPZ     testbr
          BGE     testbr
          BNF     testbr
          BM      testbr
          BL      testbr
          BQ      testbr
          BNQ     testbr
          B1      testbr
          BN1     testbr
          B2      testbr
          BN2     testbr
          B3      testbr
          BN3     testbr
          B4      testbr
          BN4     testbr
          LBR     testbr
          NLBR
          LBZ     testbr
          LBNZ    testbr
          LBDF    testbr
          LBNF    testbr
          LBQ     testbr
          LBNQ    testbr
          SKP
          LSKP
          LSZ
          LSNZ
          LSDF
          LSNF
          LSQ
          LSNQ
          LSIE
          IDL
          NOP
          SEP     1
          SEX     1
          SEQ
          REQ
          SAV
          MARK
          RET
          DIS
          OUT     1
          INP     1
synctest: .DIRECT   +h88 +w132
         .end  start

