/************************************************************************/
/* tape_lt.c                                                            */
/*                 DECODER FOR AMSAT ATARI INTERFACE                    */
/*                                                                      */
/*   Copyright 1998              Peter G¸lzow, DB2OS                    */
/*                                                                      */
/************************************************************************/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>
#include <conio.h>

#include "crc16.h"

#define TRUE   1
#define FALSE  0

#define DATA 0x0378
#define STATUS DATA+1
#define CONTROL DATA+2

/* IRQ priority level */
#define PIC0        0x20        /* Master PIC */
#define SETPRIO     0xC0        /* set IRQ priority */
#define irq_prio(irq)       outp (PIC0, SETPRIO | (irq-1) & 7)

void ReceiveTelemetry(void);
void open_intserv(void);
void close_intserv(void);
void interrupt far intserv(void);

int intlev=0x0f;                 /* interrupt level associated with IRQ7 */
void interrupt far (*oldfunc)();

int frame_ready=FALSE;
volatile unsigned long a;        /* 32 Bit Puffer    */
volatile unsigned char b;        /* byte buffer      */

volatile int hunting=TRUE;       /* Waiting for SYNC */
char data[514];                  /* block: Data+CRC  */
volatile byte_cnt;
volatile bit_cnt;

FILE *out;

/************************************************************************/
/**  MAIN  **************************************************************/
/************************************************************************/
void main()
{
  char    filename[80];
  char    buf[80];

  clrscr();
  puts("\n\n");
  puts("AMSAT Telemetry Decoder for ATARI Cassette Interface");
  puts("----------------------------------------------------");
  puts("                         V1.1 by Peter GÅlzow, DB2OS\n\n\n");
  printf("Please enter Filename: ");
  gets(filename);

  if ((out = fopen(filename, "wb")) == NULL)
  {
    printf("*** Can't open '%s' ?!\n\n",filename);
    return;
  }

  ReceiveTelemetry();

  fclose(out);
}

/************************************************************************/
/*  Telemetry receiver (interrupt driven)                               */
/************************************************************************/
void ReceiveTelemetry(void)
{
  char          buf[80];
  int           i,j;
  crc16_t       crc;
  crc16_table_t table;
  int           total, good, bad;


  puts("\n\n ** Press any Key to Quit **");

  crc16_init(CCITT_CRC16, table);  /* init CRC-Tabelle */
  total = good = bad = 0;

  open_intserv();
  outportb(DATA, 0x00);  /* Clear Output Port */
  /* set bit 4 on control port (irq enable)   */
  outportb(CONTROL, inportb(CONTROL) | 0x10);


  while (TRUE)
  {
    if (kbhit())
    {
      getch();
      break;
    }

    if (frame_ready)      /* a block of 514 byte data was received */
    {
      frame_ready=FALSE;
      total++;

      crc = crc16(data, 514, 0xffff, table);  /* check CRC */
      if (crc)
        bad++;
      else
      {
        good++;
        fwrite(&data, 512, 1, out); /* Data saved without CRC byte */
        fflush(out);                /* write buffer now!           */
      }

      clrscr();                     /* clear screen */
      printf("\n\n<Block %d>                                      CRC good/bad = %d/%d\n\n",
              total, good, bad);

      /* Screen Dump, 8 lines by 64 characters */
      for (j=0; j<8; j++)
      {
        for (i=0; i<64; i++)
        {
          if (isprint(data[i+j*64]))
            buf[i]=data[i+j*64];
          else
            buf[i]='.';
          buf[64]=0;
        }
        puts(buf);
      }

      if (crc)
        puts("\n** CRC failed! **");
      else
        puts("\n** CRC OK! **");
    }
  }
  close_intserv();   /* stop Interrupt-Service */
}

/************************************************************************/
/* This is written by the user.  Note that the source of the interrupt  */
/* must be cleared and then the PC 8259 cleared (int_processed).        */
/* must be included in this function.                                   */
/************************************************************************/
void interrupt far intserv(void)
{
  int i;
  unsigned char lpt_status;

  disable();
  lpt_status = inportb(STATUS);

  if (hunting)
  {
    a <<= 1;                  /* shift 1 bit left, MSB is first! */
    if (lpt_status & 0x10)    /* Select In, data bit from Modem  */
      a |= 0x00000001;        /* 32 bit buffer */

    if (a == 0x3915ed30)      /* SYNC-VECTOR   */
    {
      bit_cnt=0;              /* bit counter   */
      byte_cnt=0;             /* byte counter  */
      hunting=FALSE;          /* SYNC found!   */
    }
  }
  else
  {
    b <<= 1;                  /* shift 1 bit left, MSB is first! */
    if (lpt_status & 0x10)    /* Select In, data bit from Modem  */
      b |= 0x01;              /* 8 bit buffer  */

    bit_cnt++;

    if (bit_cnt>7)            /* one cyte received      */
    {
      bit_cnt=0;
      data[byte_cnt]=b;       /* copy into data buffer  */
      byte_cnt++;
      if (byte_cnt>=514)      /* 1 block = 512 byte data + 2 byte CRC */
      {
        frame_ready=TRUE;     /* Block finished         */
        hunting=TRUE;         /* hunt for next block    */
      }
    }
  }

  /* signals 8259 in PC that interrupt has been processed */
  outportb(0x20, 0x20);
  enable();
}

/*........................................................................*/
/* enables IRQ7 interrupt.  On interrupt (low on /ACK) jumps to intserv.  */
/* all interrupts disabled during this function; enabled on exit.         */
/*........................................................................*/
void open_intserv(void)
{
  int int_mask;

  disable();                         /* disable all ints */
  oldfunc=getvect(intlev);           /* save any old vector */
  setvect(intlev, intserv);          /* set up for new int serv */
  int_mask=inportb(0x21);            /* 1101 1111 */
  outportb(0x21, int_mask & ~0x80);  /* set bit 7 to zero */
                                     /* -leave others alone */
  irq_prio (7);                      /* boost IRQ7 to highes priority */
  enable();
}

/*........................................................................*/
/* Disable IRQ7 Interrupt                                                 */
/*........................................................................*/
void close_intserv(void)
{
  int int_mask;
  disable();
  setvect(intlev, oldfunc);
  int_mask=inportb(0x21) | 0x80;     /* bit 7 to one */
  outportb(0x21,int_mask);
  irq_prio (0);                    /* standard priority, IRQ 0 is highest */
  enable();
}


