0710103030566
1MEMORY OF OSCAR-10DB2OS
2page #
9[....................................................]
€
MEMORY-TEST ON OSCAR-10    de DB2OS      1986 NOV 04  @ 22:15 UTC
=======================                  1986 NOV 05  @ 20:30 UTC
                                         1986 NOV 06  @ 19:40 UTC
#0000to#00FFupdated1986NOV18@02:00UTC


                   FF - PATTERN - TEST
                   -------------------


          #0 #1 #2 #3 #4 #5 #6 #7 #8 #9 #A #B #C #D #E #F
---------------------------------------------------------
#0000     38                FCFCFCFC..FCBCFCFC..
#0010                 .0    B6..BC B6 FC .. BC FC B6 ..
#0020     FC 3C FC FC .. BC BC .. FC FE .. B6 FC BC FC FC
#0030     B6 B6 .. FC BC FC E4 F6 FC FC EC .. BC .. B6 FC
#0040     BC .. B6 .. FC FC E4 FC FC E4 FC B6 FC FC .. FC
#0050     BC .. FC .. FC BC B6 FC BC B6 FC .. B6 FC FC FC
#0060     FC B6 B6 B6 FC FC FC FC FC B6 FC E4 FC FC .. FC
#0070     FC 7E FC 76 FC BC B6 D4 FC .. FC .. E4 FC FC .. ______
#0080     .. .. ..EA .. FA .. FA .. FA .. .. .. .. .. 7E
#0090     .. FA .. FA .. .. .. FA .. .. .. .. FC FA .. FA
#00A0     .. .. .. FA .. FA .. .. .. .. .. FA .. .. .. FA
#00B0     .. .. .. FA .. 7E .. FA .. .. ..       ..      
#00C0     FAEEEA .. .. .. .. .. EA .. EA .. FA .. FA ..
#00D0     FA .. FA .. E4B6EA .. EE .. .. .. FA .. .. ..
#00E0     .. .. .. .. FA.. .. .. EA .. FA .. FA .. .. ..
#00F0     .. .. EA .. .. .. FA .. EE .. .. .. .. .. EE .. ______
#0100     .. .. .. .. .. FC .. FC .. .. FC FC .. .. .. ..
#0110     .. FC .. .. FC FC FC FC .. .. .. .. .. FC FC FC
#0120     FC FC FC FC .. .. FC FC FC FC FC FC .. .. FC FC
#0130     .. .. .. .. .. .. FC FC FC FC .. .. FC FC FC FC
#0140     .. .. FC FC .. .. .. .. FC FC .. .. .. FC .. ..
#0150     FC .. FC FC FC FC FC FC .. .. FC FC .. .. .. ..
#0160     .. .. FC .. .. .. FC .. .. .. FC FC FC .. .. ..
#0170     FC .. .. .. FC FC FC FC .. .. FC FC .. .. FC FC ______
#0180     BE EA B6 .. .. .. AE .. .. .. .. .. B6 .. B6 B6
#0190     8E .. B6 .. .. .. B6 .. .. .. B6 .. B6 B6 B6 ..
#01A0     .. B6 .. .. .. B6 B6 B6 .. .. .. .. .. B6 EE EE
#01B0     .. .. B6 .. B6 .. .. .. .. .. EE .. .. B6 .. B6
#01C0     BE EE .. .. .. .. .. B6 B6 .. .. .. B6 .. .. ..
#01D0     B6 .. .. B6 .. BE B6 .. .. AE .. .. B6 AD .. 7E
#01E0     .. B6 .. B6 .. .. .. EE .. B6 .. EE .. .. .. ..
#01F0     .. .. B6 B6 B6 .. .. .. .. ..                  
---------------------------------------------------------
          #0 #1 #2 #3 #4 #5 #6 #7 #8 #9 #A #B #C #D #E #F


Notes:   
          '.'     = no change (#FF stored).
          'space' = not tested (program area).
          Location #0000, originally #71 was stored at uploading.
          Location #0014, Bit 0 always set to '0'.

Between NOV 04 and NOV 05,  the error ount increased by 14  memory 
locations.  Between  NOV  05 and NOV 06,  two  more  memory  cells 
failed.  Note also the difference of the failure bit image between 
each of the four 128 byte blocks.
