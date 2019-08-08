
From:  Stacey E. Mills, W4SM
Date:  2002-08-30

______________________________________________________________________________

                     IPS-Win for Windows 95+ Computers
                --------------------------------------------
                
                       ----------------------------
                       Introduction and User Notes
                       ----------------------------


IPS-Win is a variant of James Miller's IPS-M, which has been ported to the PC Windows environment. IPS-Win is written in Borland C++ Builder.  It has purposefully been written to be the same in respect to input/output and the "feel" of the user interface as the original IPS-N, as described in the book "IPS - High Level Programming of Small Systems" by Karl Meinzer (1978), ISBN 0-9530507-0-X.  These notes are, in part, a modification of James Millers' original notes regarding the first IPS-M.


There are only minor differences from IPS-N:

 - Standard words are in German, if you run the kernel <Ips-mw.bin>
 - Standard works are in English if you run the kernel <Ips-mpe.bin>.  
 - At errors, the offending word in displayed in inverse video and the cursor
   placed at the start of the word.  (Like the Atari)
 - The cursor control keys may also be used.  

IPS is multitasking "FORTH-like" language and is the "child" of Karl Meinzer.  The genius of this language will become more and more apparent as you delve into its workings.  This variant of IPS would not be possible without the pioneering efforts of James Miller to develop a "platform independent" version of IPS several years ago, which was then set up to run on the Acorn RiscPC.  At that time, I began re-writing the IPS primitives to function on a PC in a Windows environment.  However, I got sidetracked with other AO-40 activities.  Fortunately, Paul Willmott, resurrected this project and successfully ported IPS-M to a DOS environment.  His major efforts and a lot of his code are reflected in IPS-Win.  Paul will release his version of IPS-DOS independently. He has developed it more as a "stand alone" operating system for remote use on server PC's station control, etc.  

Paul Willmott's IPS, my IPS for Windows and James Millers' original IPS for the Acorn computer are all functionally equivalent and the same binary kernel will run on any of the programs.

My goals with IPS-Win are to provide a Windows-based IPS emulator which can be used for IPS training and testing, and also to provide an engine for cross-compiling CPU-specific IPS flight binaries.  A long-term project will incorporate this engine into a "virtual AO-40" simulator program.



1. Text Handling (German kernel)
   ------------------------------
Text is written on screen at a position given by the variable SP (see book, page 20).   SP is manipulated by !CHAR TLITERAL LEERZ SCHREIB and the stack-display.  Undisciplined text writing can make SP point outside of the screen buffer, #0-#3FF.

This is almost certain to crash IPS, not least because the end of screen + 1 happens to be SYSPAGE which contains not only the chain, but also compiler pointers that interface IPS definitions to code routines.  So you can crash the computer as well.  This is a feature of IPS. 


2. Chain
   -----
The chain has its usual 8 slots, but position 0 is occupied by the stack display ZEIG-STAPEL.  It may be dechained with 0 AUSH .  Re-chaining it is a bit of a mouthful, so the word  S-ON is provided.   


3. Stack Display
   -------------
The stack display is positioned on-screen at the address given by the new constant $TVS.  To place the stack display elsewhere, for example on the 6th screen line (like the Atari), enter:   #140   ? $TVS !    Don't set $TVS larger the #380 (15th line) or stack-display will overwrite syspage ...


4. READ
   ----
Source files may be read (and compiled as appropriate) into IPS by entering:

      " Filename " READ

Note the spaces required on each side of <Filename> after/before the quotes.  <Filename> 
may include subdirectory information.  If no subdirectory is provided, READ looks for the input file in the subdirectory specified in <IpsWin.cfg> by:

       Read Dir.    Input         ( subdirectory for READ files       )

Thus, in the intial setup, files are read by default from the "Input" subdirectory.

 

5. $SAVE and $LOAD
   ---------------
If you $SAVE the entire IPS memory space, and then $LOAD it again, IPS resumes from where is was before. So you can cause IPS to start up exactly as you saved it, new definitions,
chain, time and screen included.  Note that the default sub-directory for $SAVE and $LOAD is specified in <IpsWin.cfg> by:

       Binary Dir.  Binary        ( subdirectory for SAVE/LOAD files  )

This indicates that, unless otherwise specified, $LOAD and $SAVE commands will read and write to the "Binary" subdirectory.


Thus, let's imagine you have entered and compiled a tracking program for P3D. You could save it and IPS as:

  #0 HIER   " P3D-TRACK "  $SAVE
  
Then, next time you run IPS, start the P3D tracker with:

  #0  P3D-TRACK  $LOAD

  
There are variations on this theme.  The default binary that IPS-Win starts with is: Ips-mp.bin, and it is invoked by the <IpsWin.cfg> file line which reads:

        Kernel       Ips-mw.bin        ( emulator binary, German           )  

By altering the Kernel parameter to read:   

        Kernel       Binary\P3D-TRACK  ( emulator binary  + P3D-TRACK      )  

IPS-Win would start up your P3D tracker every time.


6. Protecting Your Definitions
   ---------------------------
If you do a build as described above, you may want to protect protect your
definitions against deletion.  You do this with    HIER ' $LL 2 + !

Unprotecting them again is left as an exercise  ...  


7. Other <IpsWin.cfg> and related functions
   ------------------------------------------

The <IpsWin.cfg> file allows other user interface values to be set on startup.  Several of these deal with timing issues:

       LoopLimit    25000         ( loop limit for 20mS test          )
       SmallLoop    10000         ( smaller loop for "catch-up"       )
       Sleep Time    7            ( 0-20 millisecs "sleep" each loop  ) 

...IPS-Win generates a pseudointerrupt to service the keyboard, screen, clocks, etc, based on the number of times around the inner interpreter loop. When "LoopLimit" is reached these functions are serviced. If a check of the computer clock shows that more 20 mS "clicks" have elapsed on the PC clock than have been accounted for by IPS-Win's clocks, the LoopLimit is switched to the "SmallLoop" value to allow "catch-up".  There is wide latitude in where these values are set, as long as they are not too high.  If the number of inner interpreter iterations set by the SmallLoop value cannot be accomplished in 20 ms, IPS will lose time.  In addition, the inner interpreter is a continuous loop so CPU utilization will be 100% if a "sleep" period is not allowed.  Because of pre-emptive multitasking in Windows, even 100% utilization does not greatly affect other programs run simultaneously.  However, by setting "Sleep Time" to a value greater than 0, CPU loading can be reduced considerably.  By definition, Sleep Time cannot be greater than 20 ms if the IPS clocks are to be maintained in an "unlocked" mode, see below.  The values listed above appear to work fine for any PC with a  400 MHz or greater speed processor.


Even with the above, given the ideosyncricities of Windows timing, IPS-Win's clocks will occasionally vary some from the system clock.  Normally this is of no consequence for our purposes.  However, if you are running a tracking program in IPS, for example, maintaining accurate time for multiple days becomes important. IPS-Win provides a way to "lock" or "unlock" the IPS clocks to the system clock at startup with the following setting.

       LockUHR      false         ( lock UHR's to system time         )

In the "locked" mode the IPS countdown timers will click 20 ms each time there is a pseudointerrupt, so the values of "LoopLimit", "SmallLoop", and "Sleep Time" continue to control these countdown timers.


Both "Sleep Time" and the lock status can also be changed from the command line:

  0 UHR-LOCK 

...unlocks the IPS-Win clocks from the system clock, and:

  1 UHR-LOCK 

...locks the IPS-Win clocks to the system clock.  Sleep Time can be changed at the command line by entering:

  <Value>  SLEEP-TIME


In the "locked" mode, IPS-Win will set all of the IPS clocks.  In order to do this properly to UTC time, the system offset from UTC must be specified in <IpsWin.cfg> by:

       TimeZone     -5            ( computer offset from UTC )



<IPSWin.cfg> allows the user to set whether the keyboard is in INSERT or OVERWRITE mode at the time of startup:

       InsertON     false         ( keyboard insert/overwrite         )


<IPSWin.cfg> will display the screen updates during the compiling of a program if the "SeeCompile" line is set thus:

       SeeCompile   true          ( display lines during compilation  )


Setting "SeeCompile" false will increase compile speed, but the screen will not update during the compilation.  Normal usage is to leave SeeCompile = true.



8. QUITING IPS-Win
  ------------------
Entering <ALT-X> from the keyboard with halt IPS-Win, leaving the screen intact.  There is currently no continuation from this point.  The program must be closed and re-started.  This is in keeping with IPS-N.  Alternately, simply L-click on the "X" at the upper right of the window and the program will end and close.


9. TEST PROGRAMS
  ---------------
This is an emulator so start writing your own programs!  However, I've included a couple for testing and experimentation.  NOTE:  These must be run with the German binary kernel, <IPS-MW.bin>. One is a recursion program that I wrote called <Tak-M.txt>.  READ it into IPS-Win and then enter: 

    6 12 18 TAK  

This rather lengthy recursion takes about 1 second on my computer.  Determining its function by deciphering the IPS code is a good exercise.

Of more value is a nice IPS tracking program called "GS2001.txt".  Note that at the end of this program you can enter your specific coordinates and change the default settings, etc. The coordinates are such that 360 degs = 65536.

Also note that if you enter: <DAY> PR

...where day is AMSAT day, you will get a nice pass chart!

In order for GS2001 to be accurate, you will need to update the keps.  A file, "Keps.txt" is included with AO-40 keps in IPS/Atari format.



10.  Cross Compiler Mode / Source Code
     -----------------------------------
It is possible to alter the IPS-M source code and recompile the binary kernel.  However, it is unlikely that you would have a reason to do this.  I have not included the IPS-MW source code, but a virtually identical version is available with Paul Willmott's DOS version of IPS.  Likewise, Paul has provided the cross compiler binary. This will run with IPS-Win, if specified as the kernel in the <IpsWin.cfg> file.

Likewise, Paul has included the source code for the IPS-DOS emulator.  This is substantively identical to the IPS-Win version, minus the overhead necessary to function in a Windows environment.

