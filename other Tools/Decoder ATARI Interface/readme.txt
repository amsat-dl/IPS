(readme.txt)

                                                      Laatzen, 1998-10-06
                                                      Peter Gülzow, DB2OS

AMSAT Format Telemetry Decoder
==============================

TAPE.EXE is a program which can be used to read old cassette tapes from
the good old ATARI 800 recorded at 2400 Bit/s AMSAT Format. It would
also be possible to decode the 400 Bit/s stream from the satellite, but
this probably makes not much sense, since newer hardware and better
software is available for the PC. 

I used a 233 MHz Pentium, but it should also run on slower machines.
The software is entirely written in "C".

TAPE.EXE must only be used in an DOS environment!! It does not run in a
DOS-Box under Windows.. 

It is also recommended not to use a MOUSE driver, some mouse drivers
do block the interrupts for too long. 

The file TAPE.UIR must be in the same directory. 

After starting TAPE.EXE you can decide if you want CRC checking or not.
By default the CRC check is turned ON. The saved file format is
identical with other programs and 512 Bytes per block will be saved
(appended) in a file without CRC. 

After pressing F1 (START) you can enter a file name and the decoding
process starts. Existing files will be overwritten if you use the same
filename again. You can see valid blocks which start with the AMSAT
Sync-Vector in the output window. A valid or bad CRC is indicated and
the number of total, bad and good blocks is also shown. 

The decoding and logging can be stopped by pressing any key. 

You can restart by pressing F1 (START) again or leave the program using
ESC (QUIT). 

I have also enclosed a schematic how to connect the old ATARI cassette
interface to the LPT1 printer port of your PC. The standard LPT1 port
with IRQ7 is used only. As you can see, the modifications are simple... 

It's fun to see the old AO-10 telemetry again after such a long time :)
I hope you find this program useful to recover your old AO10 & AO13
tapes.. 

Best wishes Peter DB2OS 

