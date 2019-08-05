
/*  IPS - virtual machine for the IPS (Interpreter for Process Structures)
 *  language / computing environment used onboard of AMSAT spacecraft
 *
 *  Copyright (C) 2003, Pieter-Tjerk de Boer -- pa3fwm@amsat.org
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of version 2 of the GNU General Public License as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *
 *  This module contains the unix- or ncurses-specific parts of the
 *  program; i.e., the processing of command-line options, the user
 *  interface and the timing stuff.
 *  It also contains the few lines of code that load the actual IPS
 *  binary image into the emulator's memory mem[] .
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <ncurses.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include "ips.h"


/**************** timing-related code **********************/

void do_sleep(void)   /* sleep for a little while, i.e., give up CPU time to other processes */
{
   struct timeval timeout;
   timeout.tv_sec=0;
   timeout.tv_usec=10000;    /* 10 milliseconds */
   select(0,NULL,NULL,NULL,&timeout);
}


int test_20ms(void)    /* test whether another 20 milliseconds have passed by */
{
   struct timeval tv;
   struct timezone tz;
   static long thr_usec=0;
   gettimeofday(&tv,&tz);
   if (tv.tv_usec<thr_usec || tv.tv_usec>=thr_usec+20000) {
      thr_usec+=20000;
      if (thr_usec==1000000) thr_usec=0;
      return 1;
   }
   return 0;
}


void init_uhr(void)   /* initialize the UHR with the present time */
{
   time_t t;
   struct tm *tm;

   time(&t);
   tm=gmtime(&t);
   pokeB(UHR,0);
   pokeB(UHR+1,tm->tm_sec);
   pokeB(UHR+2,tm->tm_min);
   pokeB(UHR+3,tm->tm_hour);

   tm->tm_mon+=2;
   if (tm->tm_mon<4) { tm->tm_year--; tm->tm_mon+=12; }
   poke(UHR+4, (tm->tm_mon*306)/10 + tm->tm_year*365 + tm->tm_year/4 + tm->tm_mday - 28553 );
}



/**************** code for handling screen and keyboard **********************/

WINDOW *w;

void do_redraw(void)   /* refresh the screen */
{
   int i,j,inv;

   werase(w);
   inv=0;
   for (j=0;j<16;j++) {
      wmove(w,j,0);
      for (i=0;i<64;i++) {
         int c=mem[j*64+i];
         int nwinv;
         nwinv=(c&0x80);
         if (inv!=nwinv) {
            inv=nwinv;
            if (inv) wattron(w,A_REVERSE);
            else wattroff(w,A_REVERSE);
         }
         c&=0x7f;
         if (c<0x20) c|=0x80;
         waddch(w,c);
      }
   }
   if (inv) wattroff(w,A_REVERSE);
   wrefresh(w);
}

void init_ncurses(void)
{
   initscr(); 
   nonl(); 
   noecho(); 
   curs_set(0); 
   cbreak(); 
   
   w=newwin(18,66,1,1);
   box(w,ACS_VLINE,ACS_HLINE);
   mvwaddch(w,0,4,ACS_RTEE);
   waddstr(w,"Meinzer M-9097 IPS Computer");
   waddch(w,ACS_LTEE);
   wrefresh(w);
   delwin(w);

   w=newwin(16,64,2,2);
   wrefresh(w);

   leaveok(w,TRUE);
   nodelay(w,TRUE); 
   keypad(w,TRUE);
}

int handle_keyboard(void)
{
   int c;
   static int insertmode=1;
   int ret=1;

   mem[input_ptr]&=0x7f;

   c=wgetch(w);

   switch (c) {
      case ERR: 
         ret=0;
         break;
      case '\n':
      case '\r':
         return 2;
      case KEY_LEFT:
         input_ptr--;
         if (input_ptr<0) input_ptr=0;
         break;
      case KEY_UP:
         input_ptr-=64;
         if (input_ptr<0) input_ptr=0;
         break;
      case KEY_RIGHT:
         input_ptr++;
         if (input_ptr>TVE) input_ptr=TVE;
         break;
      case KEY_DOWN:
         input_ptr+=64;
         if (input_ptr>TVE) input_ptr=TVE;
         break;
      case KEY_BACKSPACE:
         input_ptr--;
         if (input_ptr<0) input_ptr=0;
      case KEY_DC:
         if (insertmode) {
            memmove(mem+input_ptr,mem+input_ptr+1,TVE-input_ptr);
            mem[TVE]=' ';
         } else {
            mem[input_ptr]=' ';
         }
         break;
      case KEY_IC:
         insertmode=!insertmode;
         break;
      default:
         if (insertmode) memmove(mem+input_ptr+1,mem+input_ptr,TVE-input_ptr);
         pokeB(input_ptr++,c); 
         if (input_ptr>TVE) input_ptr=TVE;
   }

   if (!peekB(READYFLAG)) mem[input_ptr]|=0x80;

   return ret;
}

/**************** startup code **********************/

int main(int argc,char **argv)
{
   FILE *f;
   char *cmd=NULL;
   char *image="IPS-Mu.bin";

   /* parse command line */
   while (1) {
      int i;
      i=getopt(argc,argv,"c:f:i:xh");
      if (i<0) break;
      switch (i) {
         case 'c':
            if (!optarg) goto error;
            cmd=optarg;
            break;
         case 'f':
            if (!optarg) goto error;
            cmd=malloc(strlen(optarg)+16);
            if (!cmd) goto error;
            sprintf(cmd,"\" %s \" READ",optarg);
            break;
         case 'i':
            if (!optarg) goto error;
            image=optarg;
            break;
         case 'x':
            image="IPS-Xu.bin";
            break;
         default:
error:
            printf("
IPS for unix/linux
------------------
Options are:
-c <commands>   - initial IPS commands
-f <filename>   - load IPS source file, equivalent to -c '\" <filename> \" READ'
-i <filename>   - load image from file, default is IPS-Mu.bin
-x              - be cross-compiler, equivalent to -i IPS-Xu.bin
");
            return 1;
      }
   }

   /* load the image */
   f=fopen(image,"r");
   if (!f) {
      fprintf(stderr,"Can't open image file \"%s\".\n",image);
      return 1;
   }
   fread(mem,1,65536,f);
   fclose(f);

   /* if commands were given on the command line, copy them into the screen memory as input */
   if (cmd) {
      if (strlen(cmd)>64*8) {
         fprintf(stderr,"Command too long (max. 512 bytes)\n");
         return 1;
      }
      memcpy(mem+64*8,cmd,strlen(cmd));
      poke(a_PE,0x200+strlen(cmd));
      mem[READYFLAG]=1;
   }

   /* initialize the ncurses stuff */
   init_ncurses();

   /* initialize the UHR */
   init_uhr();

   /* finally, run the emulator */
   emulator();

   endwin();

   return 0;
}

