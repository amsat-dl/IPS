CFLAGS	= -g -Wall -O9
# Add -DBIGENDIAN to the above if your machine is big-endian.
# Doing so is also correct on little-endian machines, but results
# in slightly less efficient code.

LDFLAGS	= -lm -lncurses

ips:	ips.o emu.o

ips.o:	ips.c ips.h

emu.o:	emu.c ips.h

