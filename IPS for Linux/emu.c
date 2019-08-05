
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
 *  This module contains the system-independent parts of the program;
 *  i.e., the main loop of the emulator, and the primitive routines (which
 *  in a real spacecraft system would be written in machine language).
 */


#include <stdio.h>
#include <math.h>

#include "ips.h"

#define Round(x) ( (x>=0) ? (int)(x+0.5) : (int)(x-0.5) )

int depth=0;
int redraw=1;
int idle=0;

byte mem[65536];

#ifdef BIGENDIAN
  u16 peek(u16 i)
  {
     return (u16)mem[i]+((u16)mem[(i)+1]<<8);
  }

  void poke(u16 i,u16 w)
  {
     mem[i]=(w)&0xff;
     mem[(i)+1]=(w)>>8;
  }

  u32 peek32(u16 i)
  {
     return (u32)mem[i]+((u32)mem[(i)+1]<<8)+((u32)mem[(i)+2]<<16)+((u32)mem[(i)+3]<<24);
  }
#endif

u16 PPC,HP;
u16 PS=0xfff8;
u16 RS=0x4f8;

#define READYFLAG 0x42e
#define LOADFLAG 0x43b
#define UHR 0x418
#define a_PE 0x42f
#define a_PI 0x431
#define a_P1 0x433
#define a_P2 0x435
#define a_P3 0x437
#define a_NDptr 0x43e
#define a_Os 0x43c

int input_ptr=512;

void push_ps(u16 w)
{
   PS-=2;
   poke(PS,w);
}

u16 pull_ps()
{
   PS+=2;
   return peek(PS-2);
}

void push_rs(u16 w)
{
   RS-=2;
   poke(RS,w);
}

u16 pull_rs()
{
   RS+=2;
   return peek(RS-2);
}


/**************************************************************************
           Implementation of all the "primitive" IPS routines
**************************************************************************/

void c_rumpelstilzchen(void) 
{
}

void c_defex(void) 
{
   push_rs(PPC);
   PPC=HP;
   depth++;
}

void c_varex(void) 
{
   push_ps(HP);
}

void c_consex(void) 
{
   push_ps(peek(HP));
}

void c_retex(void) 
{
   depth--;
   PPC=pull_rs();
}

void c_get(void) 
{
   poke(PS,peek(peek(PS)));
}

void c_getB(void) 
{
   poke(PS,peekB(peek(PS)));
}

void c_put(void) 
{
   u16 a,v;
   a=pull_ps();
   v=pull_ps();
   if (peek(a)!=v) idle=0;
   poke(a,v);
   if (a<=0x400) redraw=1;
}

void c_putB(void) 
{
   u16 a,v;
   a=pull_ps();
   v=pull_ps();
   if (peekB(a)!=v) idle=0;
   pokeB(a,v);
   if (a<=0x400) redraw=1;
   idle=0;
}

void c_1bliteral(void) 
{
   push_ps(peekB(PPC));
   PPC++;
}

void c_2bliteral(void) 
{
   push_ps(peek(PPC));
   PPC+=2;
}

void c_bronz(void) 
{
   if ((pull_ps() & 1) ==0) PPC=peek(PPC);
   else PPC+=2;
}

void c_jump(void) 
{
   PPC=peek(PPC);
}

void c_weg(void) 
{
   PS+=2;
}

void c_pweg(void) 
{
   PS+=4;
}

void c_plus(void) 
{
   s16 v;
   v=pull_ps();
   poke(PS,peek(PS)+v);
}

void c_minus(void) 
{
   s16 v;
   v=pull_ps();
   poke(PS,peek(PS)-v);
}

void c_zwo(void) 
{
   push_ps(peek(PS+2));
}

void c_rdu(void) 
{
  s16 h;
  h=peek(PS);
  poke(PS,peek(PS+2));
  poke(PS+2,peek(PS+4));
  poke(PS+4,h);
}

void c_rdo(void) 
{
  s16 h;
  h=peek(PS+4);
  poke(PS+4,peek(PS+2));
  poke(PS+2,peek(PS));
  poke(PS,h);
}

void c_dup(void) 
{
   push_ps(peek(PS));
}

void c_pdup(void) 
{
   push_ps(peek(PS+2));
   push_ps(peek(PS+2));
}

void c_vert(void) 
{
  s16 h;
  h=peek(PS);
  poke(PS,peek(PS+2));
  poke(PS+2,h);
}

void c_index(void) 
{
   push_ps(peek(RS));
}

void c_s_to_r(void) 
{
   push_rs(pull_ps());
}

void c_r_to_s(void) 
{
   push_ps(pull_rs());
}

void c_eqz(void) 
{
   poke(PS,(peek(PS)==0));
}

void c_gz(void) 
{
   poke(PS,((s16)peek(PS)>0));
}

void c_lz(void) 
{
   poke(PS,((s16)peek(PS)<0));
}

void c_geu(void) 
{
   u16 a,b;
   b=pull_ps();
   a=peek(PS);
   poke(PS,a>=b);
}

void c_nicht(void) 
{
   poke(PS,0xffff^peek(PS));
}

void c_f_vergl(void)
{
   int t;
   u16 n,a1,a2;
   n=pull_ps();
   a2=pull_ps();
   a1=peek(PS);
   t=1;
   do {
      int b;
      b=(s16)peekB(a1++)-(s16)peekB(a2++);
      if (b>0) t=2;
      else if (b<0) t=0;
      n=(n-1)&0xff;
   } while (n);
   poke(PS,t);
}

void c_und(void) 
{
   u16 v;
   v=pull_ps();
   poke(PS,v&peek(PS));
}

void c_oder(void) 
{
   u16 v;
   v=pull_ps();
   poke(PS,v|peek(PS));
}

void c_exo(void) 
{
   u16 v;
   v=pull_ps();
   poke(PS,v^peek(PS));
}

void c_bit(void) 
{
   poke(PS,1<<peek(PS));
}

void c_cbit(void)
{
   int a,b;
   a=pull_ps();
   b=(pull_ps())&0x07;
   pokeB(a, peekB(a)&~(1<<b) );
}

void c_sbit(void)
{
   int a,b;
   a=pull_ps();
   b=(pull_ps())&0x07;
   pokeB(a, peekB(a)|(1<<b) );
}

void c_tbit(void)
{
   int a,b;
   a=pull_ps();
   b=(peek(PS))&0x07;
   if (peekB(a)&(1<<b)) poke(PS,1);
   else poke(PS,0);
}

void loop_sharedcode(int i) {
   int l;
   l=(s16)peek(RS);
   if (i<=l) {
      push_rs(i);
      PPC=peek(PPC);
   } else {
      pull_rs();
      PPC+=2;
   }
}

void c_jeex(void) 
{
   PPC=peek(PPC);
   push_rs(pull_ps());
   loop_sharedcode((s16)pull_ps());
}

void c_loopex(void) 
{
   loop_sharedcode((s16)(pull_rs()+1));
}

void c_plusloopex(void) 
{
   int i;
   i=(s16)(pull_rs());
   loop_sharedcode(i+(s16)pull_rs());
}


void c_fieldtrans(void) 
{
   /* note: cannot call memcpy() here, because memcpy()'s behaviour is not defined when source and destination areas overlap */
   /* memmove() cannot be used either, because its behaviour for overlap is different from what IPS expects */
   int n,d,s,b;
   n=pull_ps();
   d=pull_ps();
   s=pull_ps();
   do {
      b=peekB(s++);
      pokeB(d++,b);
      n=(n-1)&0xff;
   } while (n);
   if (d<=0x400) redraw=1;
   idle=0;
}

void c_pmul(void) 
{
   u32 c;
   c=pull_ps()*pull_ps();
   push_ps((s16)(c&0xffff));
   push_ps(c>>16);
}

void c_pdiv(void) 
{
   u32 q,n;
   u16 d,nh,nl,r;
   d=pull_ps();
   nh=pull_ps();
   nl=pull_ps();
   n=(nh<<16)+nl;
   if (d==0) { q=0xffff; r=0; }
   else {
      q=n/d;
      r=n%d;
      if (q>=0x10000) { q=0xffff; r=0; }
   }
   push_ps(q);
   push_ps(r);
}

int leaveloop=1;

void c_tue(void) 
{
   HP=pull_ps();
   leaveloop-=20000;
}

void c_polyname(void) 
{
   u32 x,p,d;
   d=pull_ps();
   x=pull_ps();
   p=pull_ps();
   x= x | (p&0xff00) | ((p&0xff)<<16);
   p = d ^ x ^ (x>>1) ^ (x>>2) ^ (x>>7);
   x = x ^ ((p&0xff)<<24);
   x >>= 7;
   push_ps( (x&0xff00) | ((x>>16)&0xff) );
   push_ps( (x&0xff) );
}

char *namecode_rev_(u32 nd);

void c_scode(void) 
{
   int i;
   u32 nd;
   int offs=peek(a_Os);
   i=peek(a_NDptr);
   nd=peek32(i);
   i=peek(a_P3);
   while (i) {
      i+=offs;
      if ( ( (peek32(i) ^ nd) & 0xffffff3f) ==0) {
         push_ps(i+6);
         return;
      }
      i=peek(i+4);
   }
   push_ps(0);
}

void c_cscan(void) 
{
   int a;
   int pi,pe;
   int comment=0;
   pi=peek(a_PI);
   pe=peek(a_PE);

   a=pull_ps();
   if (a==1) {
      while (pi<=pe) {
         if (comment) {
            if (peekB(pi)==')') comment=0;
         } else {
            if (peekB(pi)=='(') comment=1;
            else if (peekB(pi)!=' ') {
               poke(a_PI,pi);
               push_ps(1);
               return;
            }
         }
         pi++;
      }
      push_ps(0);
      poke(a_P2,1);
      return;
   } else {
      while (pi<=pe) {
         if (peekB(pi)==' ') {
            break;
         }
         pi++;
      }
      poke(a_PI,pi);
      push_ps(0);
   }
}

void c_chs(void) 
{
   poke(PS,-(s16)peek(PS));
}

void c_cyc2(void)
{
   u32 ch,a,crcc;
   int i;
 
   ch=pull_ps();
   a=pull_ps();
   crcc=(a>>8)|((a&0xff)<<8);
   
   ch<<=8;
   for (i=0;i<=7;i++) {
      int test;
      test=(ch^crcc)&0x8000;
      crcc<<=1;
      ch<<=1;
      if ((ch^crcc)&0x10000) crcc^=0x1021;
   }

   push_ps( ((crcc&0xff)<<8) | ((crcc>>8)&0xff) );
}

FILE *inputfile=NULL;

void c_close(void) 
{
   if (inputfile) {
      fclose(inputfile);
      inputfile=NULL;
   }
}

void c_open(void) 
{
   char filename[256];
   int namestart,namelen;

   if (inputfile) fclose(inputfile);

   namelen=pull_ps();
   namestart=pull_ps();
   if (namelen>255) namelen=255;
   memcpy(filename,mem+namestart,namelen);
   filename[namelen]=0;

   inputfile=fopen(filename,"r");
   if (!inputfile) { push_ps(0); return; }

   push_ps(1);
}

void c_oscli(void)
{
   fprintf(stderr,"OSCLI not implemented!\n");
}

void c_load(void) 
{
   FILE *f;
   char filename[256];
   int start,namestart,namelen;

   namelen=pull_ps();
   namestart=pull_ps();
   start=pull_ps();

   if (namelen>255) namelen=255;
   memcpy(filename,mem+namestart,namelen);
   filename[namelen]=0;

   f=fopen(filename,"r");
   if (!f) { push_ps(0); return; }

   fread(mem+start,1,65536-start,f);
   fclose(f);

   push_ps(1);

   if (start<=0x400) redraw=1;
}

void c_save(void) 
{
   FILE *f;
   char filename[256];
   int start,end,namestart,namelen,res;

   namelen=pull_ps();
   namestart=pull_ps();
   end=pull_ps();
   start=pull_ps();

   if (namelen>255) namelen=255;
   memcpy(filename,mem+namestart,namelen);
   filename[namelen]=0;

   f=fopen(filename,"w");
   if (!f) { push_ps(0); return; }

   res=fwrite(mem+start,end-start,1,f);
   fclose(f);

   push_ps( (res<1) ? 0 : 1 );
}

void c_setkbptr(void) 
{
   input_ptr = pull_ps() & 0x3ff;
}

void c_getPS(void) 
{
   push_ps(PS);
}

void c_setPS(void) 
{
   PS=pull_ps();
}

void c_rp_code(void) 
{
   double theta,x,y,r;
   pull_ps();
   y=(s16)pull_ps();
   x=(s16)pull_ps();
   theta=((s16)pull_ps())/10430.38;  /* convert to radians */
   theta+=atan2(y,x);
   r=sqrt(x*x+y*y)*1.6468;
   push_ps(Round(theta*10430.38));
   push_ps((int)(r+0.5));
   push_ps(0);
}

void c_tr_code(void) 
{
   double theta,x,y,r;

   pull_ps();
   y=(s16)pull_ps();
   x=(s16)pull_ps();
   theta=((s16)pull_ps())/10430.38;  /* convert to radians */
   theta+=atan2(y,x);
   r=sqrt(x*x+y*y)*1.6468;
   push_ps(0);
   push_ps(Round(r*cos(theta)));
   push_ps(Round(r*sin(theta)));
}

void c_swap3(void) 
{
   u16 h;
   h=peek(PS+6); poke(PS+6,peek(PS)); poke(PS,h);
   h=peek(PS+8); poke(PS+8,peek(PS+2)); poke(PS+2,h);
   h=peek(PS+10); poke(PS+10,peek(PS+4)); poke(PS+4,h);
}

void c_defchar(void)
{
   fprintf(stderr,"DEFCHAR not implemented!\n");
}

void c_pplus(void) 
{
   u32 a,b,c;
   u32 h;
   h=pull_ps();
   b=(h<<16)+pull_ps();
   h=pull_ps();
   a=(h<<16)+pull_ps();
   c=a+b;
   push_ps(c&0xffff);
   push_ps(c>>16);
}

void c_pminus(void) 
{
   u32 a,b,c;
   u32 h;
   h=pull_ps();
   b=(h<<16)+pull_ps();
   h=pull_ps();
   a=(h<<16)+pull_ps();
   c=a-b;
   push_ps(c&0xffff);
   push_ps(c>>16);
}

void c_sleepifidle(void)
/* extension for IPS-Mu, i.e., the linux/unix version */
{
   if (idle) {
      do_sleep();
      leaveloop=0;
   }
   idle=1;
}


/**************************************************************************
           Despatch table and the emulator itself
**************************************************************************/



void (*despatch[])(void) = {
   c_rumpelstilzchen, c_defex, c_consex, c_varex, c_retex, c_get, c_getB, c_put,
   c_putB, c_1bliteral, c_2bliteral, c_bronz, c_jump, c_weg, c_pweg, c_plus,

   c_minus, c_dup, c_pdup, c_vert, c_zwo, c_rdu, c_rdo, c_index,
   c_s_to_r, c_r_to_s, c_eqz, c_gz, c_lz, c_geu, c_f_vergl, c_nicht,

   c_und, c_oder, c_exo, c_bit, c_cbit, c_sbit, c_tbit, c_jeex,
   c_loopex, c_plusloopex, c_fieldtrans, c_pmul, c_pdiv, c_tue, c_polyname, c_scode,

   c_cscan, c_chs, c_cyc2, c_close, c_open, c_oscli, c_load, c_save,
   c_setkbptr, c_getPS, c_setPS, c_rp_code, c_tr_code, c_swap3, c_defchar, c_pplus,

   c_pminus, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen,
   c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen, c_rumpelstilzchen,

   c_sleepifidle
};



void do_20ms(void)
{
   int su;
   int sus[4]={SU0,SU1,SU2,SU3};
   int i;

   mem[UHR]+=2;
   if (mem[UHR]==100) {
      mem[UHR]=0;
      mem[UHR+1]++;
      if (mem[UHR+1]==60) {
         mem[UHR+1]=0;
         mem[UHR+2]++;
         if (mem[UHR+2]==60) {
            mem[UHR+2]=0;
            mem[UHR+3]++;
            if (mem[UHR+3]==24) {
               mem[UHR+3]=0;
               poke(UHR+4,peek(UHR+4)+1);
            }
         }
      }
   }

   for (i=0;i<4;i++) {
      su=sus[i];
      if ((mem[su]&1)==0) {
         if (mem[su]!=0) {
            mem[su]-=2;
         } else {
            if (mem[su+1]!=0) {
               mem[su]=98;
               mem[su+1]--;
            } else {
               if (mem[su+2]!=0) {
                  mem[su+1]=59;
                  mem[su+2]--;
               } else {
                  if (mem[su+3]!=0) {
                     mem[su+2]=255;
                     mem[su+3]--;
                  } else {
                     mem[su]=1;
                  }
               }
            }
         }
      }
   }

   if (redraw) {
      do_redraw();
      redraw=0;
   }
}



void read_inputfile(void)
{
   int ch;

   memset(mem+0x200,' ',0x200);

   do {
      ch=getc(inputfile);
      if (ch<1) { 
         if (input_ptr==peek(a_PI)) {
            fclose(inputfile); 
            inputfile=NULL; 
            pokeB(LOADFLAG,0); 
            input_ptr=0x200;
         }
         break; 
      }
      if (ch=='\r') {
         /* ignore \r, we expect at least also a \n as end-of-line */
      } else if (ch=='\n') {
         input_ptr=(input_ptr&0xffc0)+64;
      } else {
         pokeB(input_ptr++,ch);
      }
   } while (input_ptr<1024 && inputfile);    /* 1024 = TVE */

   if (input_ptr!=peek(a_PI)) {
      pokeB(READYFLAG,1);
      poke(a_PE,input_ptr-1);
      idle=0;
   }
}



void emulator(void)
{
   u16 CPC;
   u16 baseRS;

   PPC=0x0400;
   baseRS=peek(RS);
   idle=0;
   input_ptr=peek(a_PI);

   do {
      leaveloop=10000;

      /* main interpreter loop; this loop must be as fast as possible,
       * hence the "double" use of the variable leaveloop: it serves
       * both to test for the 20 ms interrupt and file I/O every now
       * and then, AND to jump to skip_fetchHP. Thus, only a single
       * variable needs to be tested in the most common case.
       */
      do {
         HP=peek(PPC);
         PPC+=2;
skip_fetchHP:
         CPC=peek(HP);
         HP+=2;
         (*despatch[CPC])();
      } while (--leaveloop>=0);

      if (leaveloop<=-10000) { leaveloop+=20000; goto skip_fetchHP; }

      if (test_20ms()) do_20ms();
      if (!inputfile) {
         switch (handle_keyboard()) {
            case 1:
               redraw=1;
               break;
            case 2:
               if (input_ptr!=peek(a_PI)) {
                  pokeB(READYFLAG,1);
                  poke(a_PE,input_ptr-1);
                  idle=0;
               }
               break;
         }
      } else {
         if (!(peekB(READYFLAG)&1) && (peekB(LOADFLAG)&1)) {
            read_inputfile();
         }
      }

   } while (1);

}

