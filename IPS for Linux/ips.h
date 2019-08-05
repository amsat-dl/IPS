
/* data types */
typedef unsigned short u16;
typedef signed short s16;
typedef unsigned long u32;
typedef unsigned char byte;

/* the 64 Kbytes of memory that the virtual system has */
extern byte mem[65536];

/* macros/functions for handling that memory */
#ifdef BIGENDIAN
  u16 peek(u16 i);
  void poke(u16 i,u16 w);
  u32 peek32(u16 i);
#else
  #define peek(i) (*(u16*)(mem+(i)))
  #define poke(i,w) (*(u16*)(mem+(i))=w)
  #define peek32(i) (*(u32*)(mem+(i)))
#endif

#define peekB(i) (mem[i])
#define pokeB(i,w) (mem[i]=w)

/* some variables of IPS also need to be accessed by the emulator; here are their addresses: */
#define READYFLAG 0x42e
#define LOADFLAG 0x43b
#define UHR 0x418
#define SU0 0x41e
#define SU1 0x422
#define SU2 0x426
#define SU3 0x42a
#define a_PE 0x42f
#define a_PI 0x431
#define a_P1 0x433
#define a_P2 0x435
#define a_P3 0x437
#define a_NDptr 0x43e
#define a_Os 0x43c

#define TVE 1023

extern int input_ptr;

void do_redraw(void);

void do_sleep(void);

int test_20ms(void);     /* returns non-zero if another 20 ms have passed by */

void emulator(void);

int handle_keyboard(void);   /* process keyboard input, if any; returns 1 if screen contents changed (thus redraw needed), 2 if enter pressed (thus input complete), 0 otherwise */
