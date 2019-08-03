; To become familiar with the segment feature you
; should assemble this file with and without the
; single object module swicth enabled.
;
;   a18  -o example         ;two object module files
                            ;     code.seg
                            ;     foo.seg
;
;   a18  example            ;one object module file example.obj

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
synctest: .DIRECT   +h88 +w132
         .end  start

