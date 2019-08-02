Memo:  GCS/970719/jrm
To:    Graham Ratcliff, Peter Gülzow, Ian Ashley, Stacey Mills, Karl Meinzer
From:  James Miller
Subj:  IPS-M & IPS-X v2.04 for Acorn Risc Computers
Date:  1997 Jul 19 [Sat] 1050 utc
______________________________________________________________________________

                IPS-M & IPS-X v2.04 for Acorn Risc Computers
                --------------------------------------------
                
                               ------------
                               Introduction
                               ------------


IPS-M and the IPS-X cross compiler have been re-written in respect of
input/output to be the same as conventional IPS-N as described in in the book
"IPS - High Level Programming of Small Systems" by Karl Meinzer (1978),
ISBN 0-9530507-0-X.

There are only minor differences:

 - Standard words are in German.  
 - At errors, the offending word in displayed in inverse video and the cursor
   placed at the start of the word.  (Like the Atari)
 - The cursor control keys may also be used.  


IPS-M is the standard end-user IPS, and is hardly changed.

IPS-X is the cross-compiler program, and is equivalent to the old IPS-X1802,
but with the 1802 assembler part removed (to file 1802/ASM).

IPS-X can be used to cross-compile *any* source, including  IPS-C3.SRC (AO-13)
IPS-C4.SRC (P3D), IPS-M.SRC (Acorn), IPS-N.SRC (Atari) etc provided you have
first loaded the appropriate assembler, either manually or by prefixing it to
the xxx.SRC file.


You might sensibly ask, "is there an IPS-X.SRC ?"  The answer is no.  The
functional equivalent is actually a program written in BASIC that takes
hundreds of DATA statements like:

   PROCint("!t"):   PROCtokenise
     DATA vert, >>>n, ;\, $halt

and lovingly builds up the IPS-X binary image.  All compilers are originally
hand coded in this way, but I chose to automate it slightly by writing a
compiler writer.  Don't ask how I learned to write.


                      --------------------------------
                      IPS-M IPS-X General Improvements
                      --------------------------------

1. Text Handling
   -------------
From the user point of view, the main change is that with the departure from
the IPS-C spacecraft style I/O, text writing routines are now useful.  That is,
you can now write programs in IPS that display their results on the screen in
real time.  Just like any language, in fact.

So if you have the Atari GS (ground station) source text file you could (say)
abstract the AO-13 tracking software part, compile and run it and get the
annotated twinkling numbers on screen.  I'd do this as a demo, but don't have
the source in paper or electronic form (hint).

Warning.
  Text is written on screen at a position given by the variable SP (see book,
  page 20).   SP is manipulated by !CHAR TLITERAL LEERZ SCHREIB and the stack-
  display.  Undisciplined text writing can make SP point outside of the screen
  buffer, #0-#3FF.

  This is almost certain to crash IPS, not least because the end of screen + 1
  happens to be SYSPAGE which contains not only the chain, but also compiler
  pointers that interface IPS definitions to code routines.  So you can crash
  the computer as well.  This is a feature of IPS , and is not confined to
  Acorns.


2. Speed Issues
   ------------
A useful spinoff of the changed I/O is that compilation of source files is now
1.7 x faster that the last version!  This is because compiling writes so much
verbiage to the screen that it slows things down; thus I wrote a driver to
replace the system OS_WriteC (write character) call.  This came about through
various influences:
 
For each block compiled:
                              Bytes printed
 - Screen is cleared              512
 - New block is displayed         512
 - Block compiled
 - Stack display cleared          128
 - Stack display re-written   typ. 32
 
That's a total of about 1200 bytes to be written on-screen per block.  But
these bytes also have to be positioned, and in many cases the equivalent
of TAB(X,Y) is required.  This requires sending an additional 3 bytes (31,X,Y)
per byte to the OS, i.e. 4 bytes per character, making a total of ~ 3000 calls
to OS_WriteC per compiled block.

Now the system call OS_WriteC is so loaded with generality that it takes
~ 500 instructions per character to execute.  Since the end result is merely
to write 8 bytes to video RAM, it is very, very slow.

100 blocks at 3000 calls/block at 500 instructions/call is 150M instructions,
and with CPU clocks in the 10's of MHz, still takes some seconds to execute. 

So I decided to write my own routine to write direct to video RAM, by-passing
the OS calls.  The resulting code is less than 40 instructions per character,
and includes an implicit "TAB".

Furthermore, since the only IPS code words that write anything to memory are
!  !B and >>>  a test in their routines to see whether they were about to
write to the screen area was added.  In this way emulation of the conventional
method of screen refresh, a regular wash 25 /sec is completely avoided.  The
IPS screen is only updated when something changes in it, which for the most
part, is hardly ever.

An additional benefit of having display under your own control is that the
characters could be doubled in height, merely by printing each pixel row
twice; it need just one additional instruction in the new  print_ch  routine!

The end result is a spectacular increase in speed, and a much improved display.

Compiling IPS-C3/SRC for the AO-13 flight sofware now takes 9.4 s on the A3010.
98% of the machine's resources are doing pure IPS, and I can't really see this
improving, since the instruction count is now minimised.  Well, I have said
that before (when the job took 45 s), but I think it must be true now.  In
fact if you don't print to the screen it takes only 8.9 sec, but then you might
just as well have switched off the monitor ...

Relative speeds doing the TAK recursion test, as coded by Stacey (TAK-M) are:

                       IHU      Atari     A3010    RPC/SA
  ---------------------------------------------------------
  IHU              :    1
  Atari 800XL      :    3.7        1       
  Acorn A3010      :   60         16         1
  Acorn RicsPC/SA  : 1120        300        19        1


3. Character Font Definitions
   --------------------------
Since the program now keeps its own table of font definitions, a new word
DEFCHAR  has been added to enable you to define your own characters.  Full
details are in file  !IPS-M.Docs.Info

You might like to add   ä ö ü µ ß ° ‰   and so on.


4. Chain
   -----
The chain has its usual 8 slots, but position 0 is occupied by the stack
display ZEIG-STAPEL.  It may be dechained with 0 AUSH .  Re-chaining it is a
bit of a mouthful, so the new word  S-ON  is provided, as per the Atari GS.   


5. Stack Display
   -------------
The stack display is positioned on-screen at the address given by the new
constant $TVS .  To place the stack display elsewhere, for example on the 6th
screen line (like the Atari), enter:   #140   ? $TVS !    Don't set $TVS larger
the #380 (15th line) or stack-display will overwrite syspage ...
 

6. ScreenDump
   ----------
If you quit IPS-M or IPS-X while the SHIFT key is pressed, a screendump is
placed in RAM disc.  You may find this useful for documentation or diagnostic
purposes.  Mostly white space, it will ZIP to under 1 Kbytes.


7. $SAVE and $LOAD
   ---------------
I don't appear to have stressed this before, but if you $SAVE the entire IPS
memory space, and then $LOAD it again, IPS resumes from where is was before.

So you can cause IPS to start up exactly as you saved it, new definitions,
chain, time and screen included.

Thus, let's imagine you have entered and compiled a tracking program for P3D.
You could save it and IPS as:

  #0 HIER   " P3D-TRACK "  $SAVE
  
Then, next time you run IPS, start the P3D tracker with:

  #0  P3D-TRACK  $LOAD

                             --+--
  
There are variations on this theme which you may not be aware of.  The default
binary that IPS-M starts with is  !IPS.M-bin, and it is invoked by the
!IPS.!Run   file on its last line which as supplied reads:

   Run <Obey$Dir>.!RunImage  M-bin

By altering the last parameter to read   Work.P3D-TRACK   !IPS-M would start up
your P3D tracker every time.

                             --+--

On the other hand, you might prefer to create a new personalised IPS
application called (say) !P3D-Track:

  1. Click MENU in a filer window, choose New Directory, and enter
     !P3D-Track  (say).
      
  2. Shift double-click on the new !P3D-Track to open it.
  
  3. Copy  the files !Run and !RunImage  from !IPS-M into !P3DTrack
  
  4. Inside !P3D-Track, create a new directory called  Work
  
  5. Copy the IPS binary P3D-TRACK into the new work directory
  
  6. Make sure that the last line of !Run is:
      Run <Obey$Dir>.!RunImage  Work.P3D-TRACK    
    
Now when you double-click on !P3D-Track, it will run automatically as your
tracking program.

                             --+--


The forgoing use of $SAVE and $LOAD has been present in all versions of IPS-M
since the days when it was written in BASIC.  I wonder if I forgot to
mention it!


8. Protecting Your Definitions
   ---------------------------
If you do a build as described above, you may want to protect protect your
definitions against deletion.  You do this with    HIER ' $LL 2 + !

Unprotecting them again is left as an exercise  ...  


9. IPS-M Source File
   -----------------
For the first time I am releasing the source of IPS-M.  It's written in IPS,
and so can be cross compiled using IPS-X running on any IPS machine, including
the Acorn and the Atari.

So if you make a complete blooper, and smash up your M-bin file due to over-
zealous application of $SAVE, simply run IPS-X, type    ~ ips-m/src ~ read
and a new binary be created in !IPS-X.Work .

Incidentally, the Acorn can read/write Atari discs, so if you have a copy
of Atari IPS-X, you might like to try compiling IPS-M.SRC on it, and
comparing the output with  M-bin.  You will probably have to amend the
compiler directives at the start and end of IPS-M.SRC to suit the Atari system.


10. Source FileTypes
    ----------------
Many of the source files will now appear with red icons.  This is because they
have file-type 006.  Their contents are of course plain-text.  As usual you can
load them into the text editor:

  - Shift double-click               (standard RiscOS way)
  - Drag onto editor's iconbar icon  (standard RiscOS way)
  - Double-click-and-hold            (StrongED way)

When you have the latest version of StrongED 4.21 (only Karl and I have this at
present), just double-clicking will suffice, and the file will be loaded in 64
column format with red ink and sundry shortcuts loaded.  I'll put the latest
editor on my web site for you shortly.

Older IPS text files have file-types 004 and 005.  This is so that a double-
click will be picked up by the P3 Command Uploader.  The files that we're
working with tend to be specifically for IPS-M and IPS-X, so the use of 4 or 5
is an inappropriate association.


11. Acknowledgements
    ----------------
Writing IPS has been a lot of fun, from its creaking beginnings in BASIC
through to the latest lightning fast ARM coded versions.

Final conversion to standard form has been greatly aided by Graham who has
retrieved his Atari 800XL from mothballs and regularly checked Acorn IPS and
Atari IPS for equivalence.

It's now up to everyone to try and break IPS-M.  It will happen; there will
be errors.  I've never used IPS-N, so I cannot tell.  Just let me know.    

<end>
