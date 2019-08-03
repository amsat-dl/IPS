
Date sent:      	Fri, 09 Oct 1998 17:55:03 +0000
From:           	James R Miller <g3ruh@jrmiller.demon.co.uk>
To:             	pg@tasma.aball.de
Subject:        	Re: AO10 telemetry

On 8 Oct Peter Guelzow wrote:

> Enclosed are 8 MB of AO-10 telemetry...

  Many thanks!  That'll keep me busy!!  ;;-(  

  I think I'll organise them properly and place them on the ftp.amsat.org
  site for posterity.

  Also I'll rustle up some docs about telemetry equations etc., though I
  have them somewhere, you may have them closer to hand.  I think that
  stuff is on my old BBC micro system somewhere.

  Ah!  It brings back memories.  I remember listening to the 400 bps PSK
  ('83) and then looking at it on a scope and wondering what the heck it
  was. Then, gradually I designed a demodulator.  This seemed to work, but
  I still didn't have a home computer (it was on order), but I did have a
  printer, which is why the MK I decoder had a serial o/p ...  Well I
  remember the excitement as the first lot of ascii rubbish came out of
  the printer.  Indeed I think I still have it somewhere.  Soon after that
  my first home computer arrived (1984), and soon I wanted to know what
  some of the more obscure bytes in the Q-block were.  The rest is
  history.

-- 
==========================================================================
  James R Miller        WWW:        http://www.jrmiller.demon.co.uk/
    Cambridge         PGP Key:   http://www.jrmiller.demon.co.uk/key.asc
     England         Stardate:        1998 Oct 09 [Fri] 1748 utc
==========================================================================


Dear James, 

yet another funny storry. Very similar to yours...

When AO-10 was launched, we (my brother DD2OJ and I) were following the
launch and we also received it's first signals from the beacon using my
station which consists of an TS700G and 16el Tonna Yagi for 2m. 

We copied the CW beacon and than we heard the digital transmission and
wonder what that was. Than we found an article about the P3 400 Bit/s
telemetry in an older CQ/DL magazine from the DARC. I believe it was
published when P3-A was going to be launched. The arcticle was briefly
describing what the digital downlink is and a small modem schematic was
also shown. It was consisting the demodulator and a more complicated part
for serial to parallel conversion or so.. 

At that time we already had a computer based on an 8080 CPU (later
upgraded to an Z80) which my brother build and designed around an old
MITS Altair 8008 computer we got some years earlier. The MITS Altair
8008 we got from someone wo did'nt get it working. It was the first
"computer" available as a "kit". The mistake was found soon, the former
owner put a wire into the wrong "hole" and thus +5V power was shortened
to ground..hi This was good luck for us too..hi BTW: This was the same
computer which Bill Gates used when he wrote his first software.. 

Anyhow, back to Oscar-10. I can't remember if it was still the 8080 or
already the Z80 computer, but it doesn't matter so much. I also build my
first 6800 computer around that time. 64MB of memory did cost me more than
700,- DM at that time. However, we build only the Analog part of the PSK
Modem, i.e. only the first and second loop.. Clock and Data was than
directly feed into an USART (at that time these devices support
synchronous and asynchronous communication protocols).. Unfortantly the
CQ/DL article did not mentioned any further details about the protocol,
data format, etc.. 

Since there was a long gab between each subsequent block, we found
something like a Sync-Vector. But still there was nothing readable. We
tried any combination, added some stuff bits etc, but still nothing
readable. This was very frustrating indeed.. Than indeed the only option
left was to reverse the bit order and BINGO!! Suddenly we were able to
read the text blocks from AO-10!! This was fantastic! 
As you know, an unusual bit order was used..

This only happened within a few days after the launch!

Huh, this is basically the same what I have done now with the PC
to read back all the old tapes..hihi

But's that's not all.. 

A friend of mine was DL1CF in Hildesheim, with whom I had many contacts
over OSCAR-8 and he was also interested in OSCAR-9, which I also was
able to decode.. DL1CF was often in contact with DK2ZF who knew Karl...
So Heinz told Rolf and Rolf told Karl (as we learned later).. 

My brother and I were closely looking on all the progress and manoevers
with OSCAR-10. Than one day we found a text message which was like this
(in german indeed): 

"Best wishes to the station in Hannover, which is capable to read this.
Please call me..phone number...." 

When we read this, we were a little bit disapointed... "Ohhh another
station in Hannover is capable to decode the telemetry"... 

The message was unchanged for a couple of days and than we thought,
maybe he meant us? My brother give Karl a call and told him what we have
done and how we did it. Karl was very surpised, since nobody else did it
so far. In fact, there were a couple of command stations who got all the
hardware and software from AMSAT-DL and never got anything working and
than these two young guys come along, without any background information
and just do it...hi 

We also got information about how to decode the Q and Y blocks, etc..

Well, a couple of weeks later there was the AMSAT-DL annual meeting in
Marburg and Karl invited us to attend. That was the first time we meet
Karl and Werner. 

Later I've got a complete drawings of the AMSAT AFREG and Atari
Interface and build it from scratch, not having the original PCB's. I
wanted to learn IPS and decode live telemetry, so also bought an ATARI
400 computer, as the ATARI 800 was too expensive at that time.
I've got some tapes from Karl with the IPS groundstation software. But
unfortunatly it did'nt worked, until I found out that the ATARI 400 had
only 1/2 of the memory than the ATARI 800 and some other lacks. I was
able to find out how to make the ATARI 400 compatible and added more RAM
by soldering in some more RAMS over the old ones and some other small
changes.. 

Well, from there on I had complete access to all needed information and
not long I was invited again to Marburg to become a command station and
also got involved into the design and construction of OSCAR-13 & RUDAK..

My brother was not pushing these things further as I did. But he was
busy with the University and than he had to go to the german army for 18
month, etc.. He was still very interested and watched what I was doing,
but he never got as close to these things again as before.

Boy, that's long history... I'm getting old!!! ;(( 

