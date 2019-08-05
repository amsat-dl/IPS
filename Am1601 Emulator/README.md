About Am1601em.ZIP
------------------

IPS is a powerful yet simple process control language. It is very
stable and reliable. 

A custom processor code-named the Am1601 is currently under 
development for AMSAT use. This processor is being specifically
designed to be IPS friendly.

This zip contains an Am1601 emulator program for Windows NT, and a general 
user version of IPS to run on the emulator. The purpose of the emulator
is to aid the design and development of the hardware Am1601, not to
run "real-life" programs. IPS running on the emulator is considerably
slower than it would be on a real hardware machine. That said the emulator
is a very useful tool for debugging purposes.

It is being made available to the general public for peer review
purposes, and is provided "as is" under the GNU license. This is
a work in progress, ... please remember that!

System Requirements
-------------------

Windows NT/2000/XP on a fast machine. It will run on Windows 98/ME but painfully 
slowly regardless of machine speed (due to bad thread support in 98/ME).

Contents
--------

The files & directories in this zip should be extracted to a directory called 
\Am1601em on your drive of choice. 


\Am1601em\READ1ST.TXT                  This file
\Am1601em\Am1601em.EXE	               The emulator executable	
\Am1601em\IPS-F1G.BIN                  The IPS-F1G compiled kernel binary
\Am1601em\Am1601em.INI                 Configuration File for emulator
\Am1601em\qtintf.dll		       Runtime dll	
\Am1601em\DOCS\IPS-F1G Memory Map.TXT  Memory Map for IPS-F1G	
\Am1601em\SRC\*.*                      Delphi Pascal CLX Source Code for Emulator
\Am1601em\IPS-F1G\IPS-F1G.TXT          IPS-F1G Source Code for compiling using IPS-X
\Am1601em\IPS-F1G\IPSDOS.EXE           IPSDOS Machine Executable
\Am1601em\IPS-F1G\IPS-XP.BIN           The IPS-XP compiled kernel (modified for word alignment) 
\Am1601em\IPS-F1G\IPS-X.PIF            Windows Shortcut to run IPS-X Compiler
\Am1601em\IPS-F1G\IPS-F1G.BIN          same as file in parent directory
\Am1601em\IPS-F1G\IPSDOS.CFG           Configuration file for IPSDOS

Documentation
-------------

This file is it!

The Programmers Reference for the Am1601 is available in both MS Word and .pdf formats
on the AMSAT-NA web site.

http://www.amsat.org/amsat/projects/ips/Am1601.html

Documentation on IPS and IPS-X can be found in the IPSDOS (ips.zip) file, which can 
be found here:

http://www.amsat.org/amsat/sats/ao40/ips.html


Hints
-----

1). When you run Am1601em, you'll find yourself at a blank screen. 
    Select Load from the File menu.

2). Load the IPS-F1G.BIN kernel file.

3). Select Run from the Run menu, this will start the emulator running

    You are now using a real IPS system :^)

    type 

	1 1 +

    after a bit, the text will disappear and the number 2 will be displayed in the
    stack display at the top of the IPS screen.

4). Now select Register View from the View menu, you will now see the registers and flags etc,
    all being updated in real time as IPS executes. You can pause the emulator and restart.
    In pause mode if you click on a register name it will be selected, you can enter new values
    and update register or flag contents in this way.

5). Now select Memory View A, ... yes this displays memory. You can jump to an address
    and set breakpoints etc.

This is a work in progress, more functionality will be added as needed by
the Am1601 designers.

The emulator runs very slowly when you have register or memory views open.

Have Fun!

Support
-------

Please send feedback to vp9mu@amsat.org

Linux
-----

The emulator was written using Borland's CLX Delphi libraries, it *might* compile
on Kylix under Linux, ... which I don't have. Let me know if you succeed, and maybe post
me the compiled version to be for inclusion in this zip.

(c) 2002 Paul C. L. Willmott, VP9MU, G6KCV
2002-10-28

