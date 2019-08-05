A virtual machine for the IPS language on Unix/Linux systems
============================================================
Copyright (C) 2003, Pieter-Tjerk de Boer -- pa3fwm@amsat.org
https://wwwhome.ewi.utwente.nl/~ptdeboer/ham/ips/


Introduction
============

IPS (Interpreter for Process Structures) is a somewhat Forth-like language
developed in the 1970s by Dr Karl Meinzer, mainly aimed at small computer
systems that control equipment.
It has been used for the on-board computer on several AMSAT (Amateur Radio)
spacecraft (AO-10, AO-13 and AO-40), and is also planned to be used on future
AMSAT spacecraft.
Versions of IPS have also been developed for use on desk-top computers,
and the present package contains such a version that should run on just
about any Linux or other Unix-like system.


Getting started
===============

First, compile the system, typically by simply typing 'make' at your unix
command prompt. You may need to slightly modify the contents of Makefile
if e.g. libraries cannot be found or your C compiler needs different options
than gcc.
If your computer is NOT a standard IBM/Intel-compatible PC, you should check
whether its CPU is big-endian or little-endian. If it is big-endian, you
must add  -DBIGENDIAN  at the end of the CFLAGS line in the Makefile.
If in doubt, it is also safe to do so since that will actually work correctly
on both types of machine; however, on little-endian machines it is more
efficient to leave it out (as is the default, since the large majority of
users probably have a PC).

Next, start the resulting binary by typing  ./ips .
If you want to run it in a different directory, you also need to copy the file
IPS-Mu.bin to that directory, or use the -i option to ips; see ips -h for more
detail.

You now have the IPS console on your screen, and can start typing IPS commands.
For example, perform a simple addition by typing
  23 45 +
(followed by <enter>).
You can define new IPS commands, for example a command to calculate factorials:
  : factorial DUP 1 <> JA? DUP 1 - factorial * DANN ;
Then
  5 factorial
will calculate 5*4*3*2*1=120
(Note however that for numbers larger than 7, the answer is not correct
since IPS works with signed 16-bit numbers.)

Two example IPS programs have been included: bigclock.ips and gs2003.ips.
The former displays a big clock, the latter is a satellite tracking program
loaded with the keppler data for AO-40.
You can load one of these by typing a command like
  " filename.ips " READ

The IPS system is closed by simply pressing the interrupt key, which is
typically Ctrl-C .

If you want to do more with IPS, you'll probably want to study the IPS book.


Background and implementation notes
===================================

The IPS system for Linux/Unix consists of three parts:
- The ``memory image'' of the system; this is the actual IPS kernel; it is
  contained in the file IPS-Mu.bin.
- A virtual machine that can interpret the above-mentioned memory image;
  this part is written in C, in the file emu.c .
- The user interface, which handles file I/O, reads the keyboard, and displays
  the IPS system's 64x16 character screen on a standard terminal (console or
  xterm), and initially sets the IPS system clock.
  This part is also written in C, in the file ips.c .
Note that in the "real" spacecraft implementations, the latter two parts are
not present: the memory image there is coded in the spacecraft CPU's native
machine code so no interpreter in the form of a virtual machine is needed,
and the keyboard and screen are replaced by telemetry up- and downlinks,
which are partially implemented in hardware and partially in software (in the
CPU's native machine code, inside the memory image).

Now you may wonder where the memory image IPS-Mu.bin comes from.
Well, its source code is included in the package: that is the file IPS-Mu.SRC .
As you can see, this is itself written in a rather IPS-like language, which
is called IPS-X.
In order to generate IPS-Mu.bin from IPS-Mu.SRC, the same virtual machine can
be used, but it needs to be loaded with a different memory image. This alternate
memory image is in the file IPS-Xu.bin, and will be loaded by invoking the
system as  ips -x . Thus, IPS-Mu.bin can be generated from IPS-Mu.SRC as follows:
- start  ips -x
- type  ~ IPS-Mu.SRC ~ read (note the use of tilde (~) instead of quote ("))
  This step will (over)write IPS-Mu.bin .
- press Ctrl-C to stop the system.

Next obvious question of course is, where does the cross-compile image IPS-Xu.bin
come from? Well, it was simply copied from Paul Wilmott's IPSDOS package (where
it was called IPS-XP.BIN).
That's the advantage of using virtual machines rather than writing the memory
image in native machine language: the memory images can be compatible among
different systems; in particular, IPS-M for Acorn, for DOS, for Windows and
for Linux/unix are compatible. 
Of course, IPS-XP.BIN does have a history of its own, but for that you should
look at the IPSDOS package.

As noted above, the virtual machines for several platforms are compatible.
As a consequence, not only the cross-compiler image could be shared among
platforms, but also the regular IPS image. However, in IPS-Mu.SRC (and thus
also in IPS-Mu.bin), some minor changes have been made, compared to their
counterparts for e.g. Acorn or DOS. These changes are:
- IPS-Mu does not have some IPS instructions that don't make sense on the
  Linux/Unix implementation, such as the DEFCHAR instruction from Acorn and
  the hardware I/O instructions from the DOS version.
- IPS-Mu contains a minor change which helps the Linux/Unix virtual machine,
  to detect whether the IPS system is just running an idle loop, and if so,
  give up some CPU time to the host operating system.
  In native implementations of IPS on board of e.g. spacecraft, IPS is the
  only process running on the CPU, so it can just use all CPU cycles. However,
  when IPS is running as one of many tasks on a Linux/Unix system, it is
  annoying when IPS takes lots of CPU cycles while idling; hence this change.

More information
================
For more information, you may want to look at the following:
- the book "IPS - High Level Programming of Small Systems" by Karl Meinzer,
  1978, second edition 1997, ISBN 0-9530507-0-X.
- http://www.jrmiller.demon.co.uk/products/ipsbk.html
- http://www.amsat.org/amsat/sats/ao40/ips.html

