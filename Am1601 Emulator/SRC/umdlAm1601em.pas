unit umdlAm1601em;

(*
          Am1601 Emulator - umdlAm1601em2
       (c) 2002 Paul C. L. Willmott, VP9MU

 This program is free software; you can redistribute it
 and/or modify it under the terms of the GNU General
 Public License as published by the Free Software
 Foundation; either version 2 of the License, or at
 your option, any later version.

 This program is distributed in the hope that it will
 be useful, but WITHOUT ANY WARRANTY; without even the
 implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE.  See the GNU General Public
 License for more details.

 You should have received a copy of the GNU General
 Public License along with this program; if not, write
 to the Free Software Foundation, Inc., 59 Temple
 Place, Suite 330, Boston, MA  02111-1307  USA

            Contact : vp9mu@amsat.org
*)

(*
     Revision History
     ----------------

     1.0.0      Created October 19, 2002 PCLW
*)

interface

// Constants for Vectors

const

  kwResetVector                   : word = $0000 ;
  kwReturnStackUnderflowVector    : word = $0004 ;
  kwParameterStackUnderflowVector : word = $0008 ;
  kwInterruptVector               : word = $000C ;

// Error Codes for use by Error Handler

  kwUndefinedOpCode         = $1000 ; // OpCode value added to Error Code
                                      // so this error has the range #1000 - #10FF

{
  Memory Map
  ----------

  $0000..$0200 <- Vectors / Boot ROM
  $0100..$04FF <- Screen
  $FE00..$FEFF <- Return Stack Overflow Area
  $FF00..$FFFF <- Parameter Stack Overflow Area
}

const

     kwScreenStart = $0100 ;
     kwScreenEnd   = $04ff ;
     kwKeyBuffer   = $0002 ; { Keyboard Buffer - Word }
     kwKeyStatus   = $0000 ; { Keyboard Buffer Status, bit 1 set when key waiting }

type

  TInstr = procedure of object ;
  TJumpTable = array[$00..$ff] of TInstr ;
  TNameTable = array[$00..$ff] of string ;

  TAm1601em = class(TObject)
  private
    { Private declarations }

    FREG_FLAGS : word ;                                // FLAGS Register (Condition Codes)
    FMemory    : array[$0000..$ffff] of byte ;         // Memory Space (RAM)
    FIO_In     : array[$0000..$ffff] of byte ;         // Input Port Space
    FIO_Out    : array[$0000..$ffff] of byte ;         // Output Port Space
    FInstr     : TJumpTable ;                          // Instruction Lookup Table
    FInstrC0   : TJumpTable ;                          // Instruction Lookup Table ALUP1 Group
    FInstrC1   : TJumpTable ;                          // Instruction Lookup Table STACK Group
    FInstrC2   : TJumpTable ;                          // Instruction Lookup Table SHIFT Group
    FInstrN    : TNameTable ;                          // Instruction Name Table
    FInstrNC0  : TNameTable ;                          // Instruction Name Table ALUP1 Group
    FInstrNC1  : TNameTable ;                          // Instruction Name Table STACK Group
    FInstrNC2  : TNameTable ;                          // Instruction Name Table SHIFT Group
    FBreak     : array[$0000..$ffff] of boolean ;      // Breakpoints
    FFireINT   : boolean ;                             // Set True if Interrupt Requested
    FFireRST   : boolean ;                             // Set True if Reset Requested
    FEFCount   : integer ;                             // Count down until 20ms request

    procedure SetInstr(VAR JT:TJumpTable;OpC:byte;Instr:TInstr)          ; // Set procedure for Opcode in lookup table
    procedure SetInstrR(VAR JT:TJumpTable;OpCS,OpCE:word;Instr:TInstr)   ; // Set procedure for Opcode Range in lookup table
    procedure SetInstrN(VAR JT:TNameTable;OpC:byte;InstrN:string)        ; // Set name for Opcode in lookup table
    procedure SetInstrNR(VAR JT:TNameTable;OpCS,OpCE:word;InstrN:string) ; // Set name for Opcode Range in lookup table

    procedure Push_PS(Value:word) ;                    // Push value onto Parameter Stack
    function  Pop_PS:word ;                            // Pop value from parameter stack
    procedure Push_RS(Value:word) ;                    // Push value onto Return Stack
    function  Pop_RS:word ;                            // Pop value from Return Stack
    procedure Initialize ;                             // Initialize Lookup Tables etc
    function sBROffset:word ;
    function MSBitSet(wValue:word):boolean ;

    function GetFLAG_C: boolean;
    function GetFLAG_E: boolean;
    function GetFLAG_EE: boolean;
    function GetFLAG_I: boolean;
    function GetFLAG_IE: boolean;
    function GetFLAG_O: boolean;
    function GetFLAG_S: boolean;
    function GetFLAG_Z: boolean;
    function GetREG_EC: word;
    procedure SetFLAG_C(const Value: boolean);
    procedure SetFLAG_E(const Value: boolean);
    procedure SetFLAG_EE(const Value: boolean);
    procedure SetFLAG_I(const Value: boolean);
    procedure SetFLAG_IE(const Value: boolean);
    procedure SetFLAG_O(const Value: boolean);
    procedure SetFLAG_S(const Value: boolean);
    procedure SetFLAG_Z(const Value: boolean);
    procedure SetREG_EC(const Value: word);
    procedure SetREG_FLAGS(const Value: word);

    procedure NOP ;
    procedure sJMP ;
    procedure sJSR ;
    procedure sLOAD ;
    procedure sSTORE ;
    procedure sBR ;
    procedure sBSR ;
    procedure cNLOAD ;
    procedure uNLOAD ;
    procedure sNLOAD ;
    procedure cJSR ;
    procedure cJMP ;
    procedure cLOAD ;
    procedure cSTORE ;
    procedure cLOADB ;
    procedure cSTOREB ;
    procedure cpJSR ;
    procedure cpJMP ;
    procedure cpLOAD ;
    procedure cpSTORE ;
    procedure cpLOADB ;
    procedure cpSTOREB ;
    procedure cRTS ;
    procedure cpBSR ;
    procedure cBR ;
    procedure uNADD ;
    procedure uNADC ;
    procedure uNSUB ;
    procedure uNSBC ;
    procedure uNRSUB ;
    procedure uNRSBC ;
    procedure uNAND ;
    procedure uNOR ;
    procedure uNEOR ;
    procedure uNRCMP ;
    procedure uNCMP ;
    procedure uNMASK ;
    procedure uNTST ;
    procedure sNADD ;
    procedure sNADC ;
    procedure sNSUB ;
    procedure sNSBC ;
    procedure sNRSUB ;
    procedure sNRSBC ;
    procedure sNAND ;
    procedure sNOR ;
    procedure sNEOR ;
    procedure sNRCMP ;
    procedure sNCMP ;
    procedure sNTST ;
    procedure ALUP1 ;
    procedure STACK ;
    procedure SHIFT ;
    procedure PUSHPS ;
    procedure POPPS ;
    procedure PUSHRS ;
    procedure POPRS ;
    procedure mSET ;
    procedure mCLEAR ;
    procedure cIN ;
    procedure cOUT ;
    procedure cINB ;
    procedure cOUTB ;
    procedure cpIN ;
    procedure cpOUT ;
    procedure cpINB ;
    procedure cpOUTB ;
    procedure cEMULATE ;
    procedure cEXECUTE ;
    procedure cPREPARE ;
    procedure cREFRESH ;
    procedure DFX ;
    procedure BLIT ;
    procedure JPPC ;
    procedure XB ;
    procedure FLAG ;
    procedure P1ADD ;
    procedure P1ADC ;
    procedure P1RSUB ;
    procedure P1RSBC ;
    procedure P0SUB ;
    procedure P0SBC ;
    procedure P1AND ;
    procedure P1OR ;
    procedure P1EOR ;
    procedure P0CMP ;
    procedure P1RCMP ;
    procedure P0MASK ;
    procedure CPL ;
    procedure P1TST ;
    procedure NEG ;
    procedure DUPL ;
    procedure DEL ;
    procedure SWAP ;
    procedure SOT ;
    procedure RTU ;
    procedure RTD ;
    procedure PTOR ;
    procedure RTOP ;
    procedure IDX ;
    procedure XRP ;
    procedure LSL ;
    procedure LSR ;
    procedure ROL ;
    procedure ROR ;
    procedure ASR ;
  public
    { Public declarations }

    REG_PC    : word ;                                 // Program Counter
    REG_PPC   : word ;                                 // Pseudo Program Counter
    REG_HP    : word ;                                 // Header Pointer
    REG_PSC   : word ;                                 // Parameter Stack Counter
    REG_PSP   : word ;                                 // Parameter Stack Pointer (Overflow Area)
    REG_RSC   : word ;                                 // Return Stack Counter
    REG_PS    : array[$0..$f] of word ;                // Parameter Stack (Internal)
    REG_RSP   : word ;                                 // Return Stack Pointer (Overflow Area)
    REG_RS    : array[$0..$f] of word ;                // Return Stack (Internal)
    REG_RR    : word ;                                 // Refresh Register
    REG_EA    : word ;                                 // EDAC Error Address Register

    function  GetMemByte(wAddress:word):byte ;         // Get Byte from Memory
    procedure SetMemByte(wAddress:word;Value:byte) ;   // Set Byte in Memory
    function  GetMemWord(wAddress:word):word ;         // Get Word from Memory
    procedure SetMemWord(wAddress:word;Value:word) ;   // Set Word in Memory
    function  GetIOInByte(wAddress:word):byte ;        // Get Byte from Input Port
    procedure SetIOInByte(wAddress:word;Value:byte) ;  // Set Byte in Input Port
    function  GetIOOutByte(wAddress:word):byte ;       // Get Byte from Output Port
    procedure SetIOOutByte(wAddress:word;Value:byte) ; // Set Byte in Output Port
    function  GetIOInWord(wAddress:word):word ;        // Get Word from Input Port
    procedure SetIOInWord(wAddress:word;Value:word) ;  // Set Word in Input Port
    function  GetIOOutWord(wAddress:word):word ;       // Get Word from Output Port
    procedure SetIOOutWord(wAddress:word;Value:word) ; // Set Word in Output Port
    procedure Emulate ;                                // Emulate next instruction
    function  NextInstruction : string ;               // Returns Text Version of Next Instruction to Execute
    function  InstructionAt(wAddress:word) : string ;  // Returns Text Version of Instruction at Address
    procedure TriggerInterrupt ;
    procedure TriggerReset ;
    procedure PowerUp ;
    procedure SetFlagValue(sFlagName: string; Value: boolean);
    procedure SetRegValue(sRegName: string; Value: word);
    function GetRegValue(sRegName:string):word ;
    function GetFlagValue(sFlagName:string):boolean ;
    function CC_Test(cc:byte) : boolean ;

    procedure ToggleBreak(wAddress: word);
    procedure WriteMemory(wAddress: word; wByte: byte);
    function GetBreakPoint(wAddress:word):boolean ;

    property REG_FLAGS : word    read FREG_FLAGS write SetREG_FLAGS ;
    property REG_EC    : word    read GetREG_EC  write SetREG_EC    ;
    property FLAG_C    : boolean read GetFLAG_C  write SetFLAG_C    ;
    property FLAG_Z    : boolean read GetFLAG_Z  write SetFLAG_Z    ;
    property FLAG_S    : boolean read GetFLAG_S  write SetFLAG_S    ;
    property FLAG_O    : boolean read GetFLAG_O  write SetFLAG_O    ;
    property FLAG_E    : boolean read GetFLAG_E  write SetFLAG_E    ;
    property FLAG_I    : boolean read GetFLAG_I  write SetFLAG_I    ;
    property FLAG_IE   : boolean read GetFLAG_IE write SetFLAG_IE   ;
    property FLAG_EE   : boolean read GetFLAG_EE write SetFLAG_EE   ;

  end ;

var

  Am1601 : TAm1601em ;

implementation

{ TAm1601em }

uses

     ufrmMain ,
     umdlStrings ,
     ufrmMemoryView ,
     ufrmRegisterView ,
     SysUtils  ;

const

     QQ_PC    = $00 ;
     QQ_PPC   = $10 ;
     QQ_HP    = $20 ;
     QQ_FLAGS = $30 ;
     QQ_PSP   = $40 ;
     QQ_PSC   = $50 ;
     QQ_RSP   = $60 ;
     QQ_RSC   = $70 ;
     QQ_EA    = $80 ;
     QQ_RR    = $90 ;

procedure TAm1601em.ALUP1;
begin
     FInstrC0[FMemory[succ(REG_PC)]] ;
end;

procedure TAm1601em.STACK;
begin
     FInstrC1[FMemory[succ(REG_PC)]] ;
end;

procedure TAm1601em.SHIFT;
begin
     FInstrC2[FMemory[succ(REG_PC)]] ;
end;

procedure TAm1601em.Emulate;
begin

// Execute Instruction

     FInstr[FMemory[REG_PC]] ;

// Check for Reset Request, this takes priority over INT

     if (FFireRST) then begin
         REG_PC := kwResetVector ;
         FFireRST := false ;
     end

// Check for Maskable Interrupt Request

     else if (FFireINT) then begin
         FLAG_IE := false ;
         FLAG_I := true ;
         Push_RS(REG_PC) ;
         REG_PC := kwInterruptVector ;
         FFireINT := false ;
     end ;

// Check Stack Underflows

     if (REG_PSC=$ffff) then begin
         Push_RS(REG_PC) ;
         REG_PC := kwParameterStackUnderflowVector ;
     end
     else if (REG_RSC=$ffff) then begin
         Push_RS(REG_PC) ;
         REG_PC := kwReturnStackUnderflowVector ;
     end ;

// Check Hardware Ports

     if (frmMain.KeyWaiting) and (GetIOInByte(kwKeyStatus)=0) then begin
         SetIOInByte(kwKeyStatus,$01) ;
         SetIOInWord(kwKeyBuffer,frmMain.ReadKey) ;
     end ;

     if (frmMain.mnuRegisterView.Checked) then begin
         frmRegisterView.UpdateRegisters ;
     end ;
     if (frmMain.mnuMemoryView.Checked) and (frmMemoryViewA.chkLockToPC.Checked) then begin
         frmMemoryViewA.MemUpdate(REG_PC) ;
     end ;
     if (frmMain.mnuMemoryViewB.Checked) and (frmMemoryViewB.chkLockToPC.Checked) then begin
         frmMemoryViewB.MemUpdate(REG_PC) ;
     end ;
     if (frmMain.mnuMemoryViewC.Checked) and (frmMemoryViewC.chkLockToPC.Checked) then begin
         frmMemoryViewC.MemUpdate(REG_PC) ;
     end ;
     if (frmMain.mnuMemoryViewD.Checked) and (frmMemoryViewD.chkLockToPC.Checked) then begin
         frmMemoryViewD.MemUpdate(REG_PC) ;
     end ;

end;

procedure TAm1601em.PowerUp;
var
     ii : word ;
begin
     Initialize ;
     FFireINT := false ;
     FFireRST := false ;
     REG_PC := kwResetVector ;
     REG_PSC := $0 ;
     REG_RSC := $0 ;
     REG_RR := $0000 ;
     for ii := 0 to $ffff do begin
         FBreak[ii] := false ;
     end ;
end;

procedure TAm1601em.TriggerInterrupt;
begin
     if (FLAG_IE) then begin
         FFireINT := true ;
     end ;
end;

procedure TAm1601em.TriggerReset;
begin
     FFireRST := true ;
end;

function TAm1601em.GetFLAG_C: boolean;
begin
     result := (FREG_FLAGS and $01) <> 0 ;
end;

function TAm1601em.GetFLAG_E: boolean;
begin
     result := (FREG_FLAGS and $10) <> 0 ;
end;

function TAm1601em.GetFLAG_EE: boolean;
begin
     result := (FREG_FLAGS and $80) <> 0 ;
end;

function TAm1601em.GetFLAG_I: boolean;
begin
     result := (FREG_FLAGS and $20) <> 0 ;
end;

function TAm1601em.GetFLAG_IE: boolean;
begin
     result := (FREG_FLAGS and $40) <> 0 ;
end;

function TAm1601em.GetFLAG_O: boolean;
begin
     result := (FREG_FLAGS and $08) <> 0 ;
end;

function TAm1601em.GetFLAG_S: boolean;
begin
     result := (FREG_FLAGS and $04) <> 0 ;
end;

function TAm1601em.GetFLAG_Z: boolean;
begin
     result := (FREG_FLAGS and $02) <> 0 ;
end;

function TAm1601em.GetIOInByte(wAddress: word): byte;
begin
     result := FIO_In[wAddress] ;
end;

function TAm1601em.GetIOInWord(wAddress: word): word;
begin
     result := FIO_In[waddress] or FIO_In[succ(waddress)] shl 8 ;
end;

function TAm1601em.GetIOOutByte(wAddress: word): byte;
begin
     result := FIO_Out[wAddress] ;
end;

function TAm1601em.GetIOOutWord(wAddress: word): word;
begin
     result := FIO_Out[waddress] or FIO_Out[succ(wAddress)] shl 8 ;
end;

function TAm1601em.GetMemByte(wAddress: word): byte;
begin
     result := FMemory[wAddress] ;
end;

function TAm1601em.GetMemWord(wAddress: word): word;
begin
     result := FMemory[wAddress] or FMemory[succ(wAddress)] shl 8 ;
end;

function TAm1601em.GetREG_EC: word;
begin
     result := FREG_FLAGS shr 10 ;
end;

procedure TAm1601em.Initialize;
begin

// Set procedures

     SetInstrR(FInstr  ,$00,$ff,NOP) ;
     SetInstrR(FInstrC0,$00,$ff,NOP) ;
     SetInstrR(FInstrC1,$00,$ff,NOP) ;
     SetInstrR(FInstrC2,$00,$ff,NOP) ;

     SetInstrR(FInstr,$00,$0f,sJMP) ;
     SetInstrR(FInstr,$10,$1f,sJSR) ;
     SetInstrR(FInstr,$20,$2f,sLOAD) ;
     SetInstrR(FInstr,$30,$3f,sSTORE) ;
     SetInstrR(FInstr,$40,$4f,sBR) ;
     SetInstrR(FInstr,$50,$5f,sBSR) ;
     SetInstr(FInstr,$60,cNLOAD) ;
     SetInstr(FInstr,$70,uNLOAD) ;
     SetInstr(FInstr,$71,sNLOAD) ;
     SetInstr(FInstr,$80,cJSR) ;
     SetInstr(FInstr,$81,cJMP) ;
     SetInstr(FInstr,$82,cLOAD) ;
     SetInstr(FInstr,$83,cSTORE) ;
     SetInstr(FInstr,$84,cLOADB) ;
     SetInstr(FInstr,$85,cSTOREB) ;
     SetInstr(FInstr,$88,cpJSR) ;
     SetInstr(FInstr,$89,cpJMP) ;
     SetInstr(FInstr,$8a,cpLOAD) ;
     SetInstr(FInstr,$8b,cpSTORE) ;
     SetInstr(FInstr,$8c,cpLOADB) ;
     SetInstr(FInstr,$8d,cpSTOREB) ;
     SetInstr(FInstr,$8e,cRTS) ;
     SetInstr(FInstr,$8f,cpBSR) ;
     SetInstrR(FInstr,$90,$9f,cBR) ;
     SetInstr(FInstr,$a0,uNADD) ;
     SetInstr(FInstr,$a1,uNADC) ;
     SetInstr(FInstr,$a2,uNSUB) ;
     SetInstr(FInstr,$a3,uNSBC) ;
     SetInstr(FInstr,$a4,uNRSUB) ;
     SetInstr(FInstr,$a5,uNRSBC) ;
     SetInstr(FInstr,$a6,uNAND) ;
     SetInstr(FInstr,$a7,uNOR) ;
     SetInstr(FInstr,$a8,uNEOR) ;
     SetInstr(FInstr,$aa,uNRCMP) ;
     SetInstr(FInstr,$ab,uNCMP) ;
     SetInstr(FInstr,$ac,uNMASK) ;
     SetInstr(FInstr,$ae,uNTST) ;
     SetInstr(FInstr,$b0,sNADD) ;
     SetInstr(FInstr,$b1,sNADC) ;
     SetInstr(FInstr,$b2,sNSUB) ;
     SetInstr(FInstr,$b3,sNSBC) ;
     SetInstr(FInstr,$b4,sNRSUB) ;
     SetInstr(FInstr,$b5,sNRSBC) ;
     SetInstr(FInstr,$b6,sNAND) ;
     SetInstr(FInstr,$b7,sNOR) ;
     SetInstr(FInstr,$b8,sNEOR) ;
     SetInstr(FInstr,$ba,sNRCMP) ;
     SetInstr(FInstr,$bb,sNCMP) ;
     SetInstr(FInstr,$be,sNTST) ;
     SetInstr(FInstr,$c0,ALUP1) ;
     SetInstr(FInstr,$c1,STACK) ;
     SetInstr(FInstr,$c2,SHIFT) ;
     SetInstr(FInstr,$d0,PUSHPS) ;
     SetInstr(FInstr,$d1,POPPS) ;
     SetInstr(FInstr,$d2,PUSHRS) ;
     SetInstr(FInstr,$d3,POPRS) ;
     SetInstr(FInstr,$d4,mSET) ;
     SetInstr(FInstr,$d5,mCLEAR) ;
     SetInstr(FInstr,$e2,cIN) ;
     SetInstr(FInstr,$e3,cOUT) ;
     SetInstr(FInstr,$e4,cINB) ;
     SetInstr(FInstr,$e5,cOUTB) ;
     SetInstr(FInstr,$ea,cpIN) ;
     SetInstr(FInstr,$eb,cpOUT) ;
     SetInstr(FInstr,$ec,cpINB) ;
     SetInstr(FInstr,$ed,cpOUTB) ;
     SetInstr(FInstr,$f0,cEMULATE) ;
     SetInstr(FInstr,$f1,cEXECUTE) ;
     SetInstr(FInstr,$f2,cPREPARE) ;
     SetInstr(FInstr,$f6,cREFRESH) ;
     SetInstr(FInstr,$f8,DFX) ;
     SetInstr(FInstr,$fb,BLIT) ;
     SetInstr(FInstr,$fc,JPPC) ;
     SetInstr(FInstr,$fd,XB) ;
     SetInstr(FInstr,$ff,FLAG) ;
     SetInstr(FInstrC0,$00,P1ADD) ;
     SetInstr(FInstrC0,$10,P1ADC) ;
     SetInstr(FInstrC0,$20,P1RSUB) ;
     SetInstr(FInstrC0,$30,P1RSBC) ;
     SetInstr(FInstrC0,$40,P0SUB) ;
     SetInstr(FInstrC0,$50,P0SBC) ;
     SetInstr(FInstrC0,$60,P1AND) ;
     SetInstr(FInstrC0,$70,P1OR) ;
     SetInstr(FInstrC0,$80,P1EOR) ;
     SetInstr(FInstrC0,$90,NOP) ;
     SetInstr(FInstrC0,$a0,P0CMP) ;
     SetInstr(FInstrC0,$b0,P1RCMP) ;
     SetInstr(FInstrC0,$c0,P0MASK) ;
     SetInstr(FInstrC0,$d0,CPL) ;
     SetInstr(FInstrC0,$e0,P1TST) ;
     SetInstr(FInstrC0,$f0,NEG) ;
     SetInstr(FInstrC1,$00,DUPL) ;
     SetInstr(FInstrC1,$10,DEL) ;
     SetInstr(FInstrC1,$20,SWAP) ;
     SetInstr(FInstrC1,$30,SOT) ;
     SetInstr(FInstrC1,$40,RTU) ;
     SetInstr(FInstrC1,$50,RTD) ;
     SetInstr(FInstrC1,$60,PTOR) ;
     SetInstr(FInstrC1,$70,RTOP) ;
     SetInstr(FInstrC1,$80,IDX) ;
     SetInstr(FInstrC1,$90,XRP) ;
     SetInstr(FInstrC2,$00,LSL) ;
     SetInstr(FInstrC2,$10,LSR) ;
     SetInstr(FInstrC2,$20,ROL) ;
     SetInstr(FInstrC2,$30,ROR) ;
     SetInstr(FInstrC2,$40,ASR) ;

// Set Names

     SetInstrNR(FInstrN  ,$00,$ff,'*reserved*') ;
     SetInstrNR(FInstrNC0,$00,$ff,'*reserved*') ;
     SetInstrNR(FInstrNC1,$00,$ff,'*reserved*') ;
     SetInstrNR(FInstrNC2,$00,$ff,'*reserved*') ;

     SetInstrNR(FInstrN,$00,$0f,'$s sJMP') ;
     SetInstrNR(FInstrN,$10,$1f,'$s sJSR') ;
     SetInstrNR(FInstrN,$20,$2f,'$s sLOAD') ;
     SetInstrNR(FInstrN,$30,$3f,'$s sSTORE') ;
     SetInstrNR(FInstrN,$40,$4f,'$b sBR') ;
     SetInstrNR(FInstrN,$50,$5f,'$b sBSR') ;
     SetInstrN(FInstrN,$60,'$n $c cNLOAD') ;
     SetInstrN(FInstrN,$70,'$t uNLOAD') ;
     SetInstrN(FInstrN,$71,'$t sNLOAD') ;
     SetInstrN(FInstrN,$80,'$n $c cJSR') ;
     SetInstrN(FInstrN,$81,'$n $c cJMP') ;
     SetInstrN(FInstrN,$82,'$n $c cLOAD') ;
     SetInstrN(FInstrN,$83,'$n $c cSTORE') ;
     SetInstrN(FInstrN,$84,'$n $c cLOADB') ;
     SetInstrN(FInstrN,$85,'$n $c cSTOREB') ;
     SetInstrN(FInstrN,$88,'$c cpJSR') ;
     SetInstrN(FInstrN,$89,'$c cpJMP') ;
     SetInstrN(FInstrN,$8a,'$c cpLOAD') ;
     SetInstrN(FInstrN,$8b,'$c cpSTORE') ;
     SetInstrN(FInstrN,$8c,'$c cpLOADB') ;
     SetInstrN(FInstrN,$8d,'$c cpSTOREB') ;
     SetInstrN(FInstrN,$8e,'$c cRTS') ;
     SetInstrN(FInstrN,$8f,'$c cpBSR') ;
     SetInstrNR(FInstrN,$90,$9f,'$t $e cBR') ;
     SetInstrN(FInstrN,$a0,'$t uN ADD') ;
     SetInstrN(FInstrN,$a1,'$t uN ADC') ;
     SetInstrN(FInstrN,$a2,'$t uN SUB') ;
     SetInstrN(FInstrN,$a3,'$t uN SBC') ;
     SetInstrN(FInstrN,$a4,'$t uN RSUB') ;
     SetInstrN(FInstrN,$a5,'$t uN RSBC') ;
     SetInstrN(FInstrN,$a6,'$t uN AND') ;
     SetInstrN(FInstrN,$a7,'$t uN OR') ;
     SetInstrN(FInstrN,$a8,'$t uN EOR') ;
     SetInstrN(FInstrN,$aa,'$t uN RCMP') ;
     SetInstrN(FInstrN,$ab,'$t uN CMP') ;
     SetInstrN(FInstrN,$ac,'$t uN MASK') ;
     SetInstrN(FInstrN,$ae,'$t uN TST') ;
     SetInstrN(FInstrN,$b0,'$t sN ADD') ;
     SetInstrN(FInstrN,$b1,'$t sN ADC') ;
     SetInstrN(FInstrN,$b2,'$t sN SUB') ;
     SetInstrN(FInstrN,$b3,'$t sN SBC') ;
     SetInstrN(FInstrN,$b4,'$t sN RSUB') ;
     SetInstrN(FInstrN,$b5,'$t sN RSBC') ;
     SetInstrN(FInstrN,$b6,'$t sN AND') ;
     SetInstrN(FInstrN,$b7,'$t sN OR') ;
     SetInstrN(FInstrN,$b8,'$t sN EOR') ;
     SetInstrN(FInstrN,$ba,'$t sN RCMP') ;
     SetInstrN(FInstrN,$bb,'$t sN CMP') ;
     SetInstrN(FInstrN,$be,'$t sN TST') ;
     SetInstrN(FInstrN,$d0,'$q PUSHPS') ;
     SetInstrN(FInstrN,$d1,'$q POPPS') ;
     SetInstrN(FInstrN,$d2,'$q PUSHRS') ;
     SetInstrN(FInstrN,$d3,'$q POPRS') ;
     SetInstrN(FInstrN,$d4,'$m SET') ;
     SetInstrN(FInstrN,$d5,'$m CLEAR') ;
     SetInstrN(FInstrN,$e2,'$n $c cIN') ;
     SetInstrN(FInstrN,$e3,'$n $c cOUT') ;
     SetInstrN(FInstrN,$e4,'$n $c cINB') ;
     SetInstrN(FInstrN,$e5,'$n $c cOUTB') ;
     SetInstrN(FInstrN,$ea,'$c cpIN') ;
     SetInstrN(FInstrN,$eb,'$c cpOUT') ;
     SetInstrN(FInstrN,$ec,'$c cpINB') ;
     SetInstrN(FInstrN,$ed,'$c cpOUTB') ;
     SetInstrN(FInstrN,$f0,'$c EMULATE') ;
     SetInstrN(FInstrN,$f1,'$c EXECUTE') ;
     SetInstrN(FInstrN,$f2,'$c PREPARE') ;
     SetInstrN(FInstrN,$f6,'$c REFRESH') ;
     SetInstrN(FInstrN,$f8,'DFX') ;
     SetInstrN(FInstrN,$fb,'2BLIT') ;
     SetInstrN(FInstrN,$fc,'JPPC') ;
     SetInstrN(FInstrN,$fd,'XB') ;
     SetInstrN(FInstrN,$ff,'$c FLAG') ;
     SetInstrN(FInstrNC0,$00,'P1 ADD') ;
     SetInstrN(FInstrNC0,$10,'P1 ADC') ;
     SetInstrN(FInstrNC0,$20,'P1 RSUB') ;
     SetInstrN(FInstrNC0,$30,'P1 RSBC') ;
     SetInstrN(FInstrNC0,$40,'P0 SUB') ;
     SetInstrN(FInstrNC0,$50,'P0 SBC') ;
     SetInstrN(FInstrNC0,$60,'P1 AND') ;
     SetInstrN(FInstrNC0,$70,'P1 OR') ;
     SetInstrN(FInstrNC0,$80,'P1 EOR') ;
     SetInstrN(FInstrNC0,$90,'NOP') ;
     SetInstrN(FInstrNC0,$a0,'P0 CMP') ;
     SetInstrN(FInstrNC0,$b0,'P1 RCMP') ;
     SetInstrN(FInstrNC0,$c0,'P0 MASK') ;
     SetInstrN(FInstrNC0,$d0,'CPL') ;
     SetInstrN(FInstrNC0,$e0,'P1 TST') ;
     SetInstrN(FInstrNC0,$f0,'NEG') ;
     SetInstrN(FInstrNC1,$00,'DUPL') ;
     SetInstrN(FInstrNC1,$10,'DEL') ;
     SetInstrN(FInstrNC1,$20,'SWAP') ;
     SetInstrN(FInstrNC1,$30,'SOT') ;
     SetInstrN(FInstrNC1,$40,'RTU') ;
     SetInstrN(FInstrNC1,$50,'RTD') ;
     SetInstrN(FInstrNC1,$60,'PTOR') ;
     SetInstrN(FInstrNC1,$70,'RTOP') ;
     SetInstrN(FInstrNC1,$80,'IDX') ;
     SetInstrN(FInstrNC1,$90,'XRP') ;
     SetInstrN(FInstrNC2,$00,'LSL') ;
     SetInstrN(FInstrNC2,$10,'LSR') ;
     SetInstrN(FInstrNC2,$20,'ROL') ;
     SetInstrN(FInstrNC2,$30,'ROR') ;
     SetInstrN(FInstrNC2,$40,'ASR') ;

end;

function TAm1601em.Pop_PS: word;
var
     iREG : byte ;
begin
     if (REG_PSC=0) then begin
         REG_PSC := $ffff ;
     end
     else begin
         Dec(REG_PSC) ;
         result := REG_PS[0] ;
         for iREG := $0 to $e do begin
             REG_PS[iREG] := REG_PS[succ(iREG)] ;
         end ;
         if ($e<REG_PSC) then begin
             Inc(REG_PSP,2) ;
             REG_PS[$f] := GetMemWord(REG_PSP) ;
         end ;
     end ;
end;

function TAm1601em.Pop_RS: word;
var
     iREG : byte ;
begin
     if (REG_RSC=0) then begin
         REG_RSC := $ffff ;
     end
     else begin
         Dec(REG_RSC) ;
         result := REG_RS[0] ;
         for iREG := $0 to $e do begin
             REG_RS[iREG] := REG_RS[succ(iREG)] ;
         end ;
         if ($e<REG_RSC) then begin
             Inc(REG_RSP,2) ;
             REG_RS[$f] := GetMemWord(REG_RSP) ;
         end ;
     end ;
end;

procedure TAm1601em.Push_PS(Value: word);
var
     iREG : byte ;
begin
     Inc(REG_PSC) ;
     if ($f<REG_PSC) then begin
         SetMemWord(REG_PSP,REG_PS[$f]) ;
         Dec(REG_PSP,2) ;
     end ;
     for iREG := $f downto $1 do begin
         REG_PS[iREG] := REG_PS[pred(iREG)] ;
     end ;
     REG_PS[$0] := Value ;
end;

procedure TAm1601em.Push_RS(Value: word);
var
     iREG : byte ;
begin
     Inc(REG_RSC) ;
     if ($f<REG_RSC) then begin
         SetMemWord(REG_RSP,REG_RS[$f]) ;
         Dec(REG_RSP,2) ;
     end ;
     for iREG := $f downto $1 do begin
         REG_RS[iREG] := REG_RS[pred(iREG)] ;
     end ;
     REG_RS[$0] := Value ;
end;

procedure TAm1601em.SetFLAG_C(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $fffe ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $01 ;
     end ;
end;

procedure TAm1601em.SetFLAG_E(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $ffef ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $10 ;
     end ;
end;

procedure TAm1601em.SetFLAG_EE(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $ff7f ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $80 ;
     end ;
end;

procedure TAm1601em.SetFLAG_I(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $ffdf ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $20 ;
     end ;
end;

procedure TAm1601em.SetFLAG_IE(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $ffbf ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $40 ;
     end ;
end;

procedure TAm1601em.SetFLAG_O(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $fff7 ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $08 ;
     end ;
end;

procedure TAm1601em.SetFLAG_S(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $fffb ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $04 ;
     end ;
end;

procedure TAm1601em.SetFLAG_Z(const Value: boolean);
begin
     FREG_FLAGS := FREG_FLAGS and $fffd ;
     if (Value) then begin
         FREG_FLAGS := FREG_FLAGS or $02 ;
     end ;
end;

procedure TAm1601em.SetInstr(VAR JT:TJumpTable;OpC: byte; Instr: TInstr);
begin
     JT[OpC] := Instr ;
end;

procedure TAm1601em.SetInstrR(VAR JT:TJumpTable;OpCS, OpCE: word; Instr: TInstr);
begin
     while (OpCS<=OpCE) do begin
          SetInstr(JT,OpCS,Instr) ;
          Inc(OpCS) ;
     end ;
end;

procedure TAm1601em.SetIOInByte(wAddress: word; Value: byte);
begin
     FIO_In[wAddress] := Value ;
     { TODO : Update IO View }
end;

procedure TAm1601em.SetIOInWord(wAddress, Value: word);
begin
     SetIOInByte(wAddress,Lo(Value)) ;
     SetIOInByte(succ(wAddress),Hi(Value)) ;
end;

procedure TAm1601em.SetIOOutByte(wAddress: word; Value: byte);
begin
     FIO_Out[wAddress] := Value ;
     if (wAddress=kwKeyStatus) then begin
         FIO_In[wAddress] := Value ;
     end ;
     { TODO : Update IO View }
end;

procedure TAm1601em.SetIOOutWord(wAddress, Value: word);
begin
     SetIOOutByte(wAddress,Lo(Value)) ;
     SetIOOutByte(succ(wAddress),Hi(Value)) ;
end;

procedure TAm1601em.SetMemByte(wAddress: word; Value: byte);
begin
     WriteMemory(wAddress,Value) ;
     if (frmMain.mnuMemoryView.Checked) then begin
         frmMemoryViewA.MemUpdate(wAddress) ;
     end ;
     if (frmMain.mnuMemoryViewB.Checked) then begin
         frmMemoryViewB.MemUpdate(wAddress) ;
     end ;
     if (frmMain.mnuMemoryViewC.Checked) then begin
         frmMemoryViewC.MemUpdate(wAddress) ;
     end ;
     if (frmMain.mnuMemoryViewD.Checked) then begin
         frmMemoryViewD.MemUpdate(wAddress) ;
     end ;
end;

procedure TAm1601em.SetMemWord(wAddress, Value: word);
begin
     SetMemByte(wAddress,Lo(Value)) ;
     SetMemByte(succ(wAddress),Hi(Value)) ;
end;

procedure TAm1601em.SetREG_EC(const Value: word);
begin
     FREG_FLAGS := (FREG_FLAGS and $03FF) or (Value shl 10) ;
end;

procedure TAm1601em.SetREG_FLAGS(const Value: word);
begin
     FREG_FLAGS := Value;
end;

function TAm1601em.InstructionAt(wAddress: word): string;

var
     ii : byte ;

procedure ReplaceText(sToken, sText:string) ;
var
     jj : word ;
begin
     jj := Pos(sToken,Result) ;
     if (jj<>0) then begin
         Delete(Result,jj,Length(sToken)) ;
         Insert(sText,Result,jj) ;
     end ;
end { ReplaceText } ;

function CC_Test(cc:byte) : string ;
begin
(*
CODE  OLD    NEW
2     CS/HS  CS/HI
3     CC/LO  CC/LS
8     HI     HS
9     LS     LO
*)

     case cc of
     $0 : result := 'EQ' ;
     $1 : result := 'NE' ;
     $2 : result := 'CS/HI' ;
     $3 : result := 'CC/LS' ;
     $4 : result := 'MI' ;
     $5 : result := 'PL' ;
     $6 : result := 'VS' ;
     $7 : result := 'VC' ;
     $8 : result := 'HS' ;
     $9 : result := 'LO' ;
     $a : result := 'GE' ;
     $b : result := 'LT' ;
     $c : result := 'GT' ;
     $d : result := 'LE' ;
     $e : result := 'AL' ;
     $f : result := 'NEF' ;
     end ;
end ; { CC_Test }

function QQ_Test(cc:byte) : string ;
begin
     case cc of
     QQ_PC    : result := 'PC'    ;
     QQ_PPC   : result := 'PPC'   ;
     QQ_HP    : result := 'HP'    ;
     QQ_FLAGS : result := 'FLAGS' ;
     QQ_PSP   : result := 'PSP'   ;
     QQ_PSC   : result := 'PSC'   ;
     QQ_RSP   : result := 'RSP'   ;
     QQ_RSC   : result := 'RSC'   ;
     QQ_EA    : result := 'EA'    ;
     QQ_RR    : result := 'RR'    ;
     end ;
end ; { QQ_Test }

{ InstructionAt }
begin
     ii := FMemory[REG_PC] ;
     case ii of
     $c0 : result := FInstrNC0[FMemory[succ(REG_PC)]] ;
     $c1 : result := FInstrNC1[FMemory[succ(REG_PC)]] ;
     $c2 : result := FInstrNC2[FMemory[succ(REG_PC)]] ;
     else
           result := FInstrN[ii] ;
           if (Pos('$s',result)<>0) then ReplaceText('$s','#'+HexW(((ii and $0f) shl 8) or FMemory[succ(REG_PC)])) ;
           if (Pos('$b',result)<>0) then ReplaceText('$b','#'+Hex(ShortInt(FMemory[succ(REG_PC)]))) ;
           if (Pos('$n',result)<>0) then ReplaceText('$n','#'+HexW(GetMemWord(REG_PC+2))) ;
           if (Pos('$c',result)<>0) then ReplaceText('$c',CC_Test(FMemory[succ(REG_PC)])) ;
           if (Pos('$e',result)<>0) then ReplaceText('$e',CC_Test(FMemory[REG_PC] and $f)) ;
           if (Pos('$t',result)<>0) then ReplaceText('$t','#'+Hex(FMemory[succ(REG_PC)])) ;
           if (Pos('$q',result)<>0) then ReplaceText('$q',QQ_Test(FMemory[succ(REG_PC)])) ;
           if (Pos('$m',result)<>0) then ReplaceText('$m','#'+Hex(FMemory[succ(REG_PC)] shr 4)) ;
     end ;
end;

function TAm1601em.NextInstruction: string;
begin
     result := InstructionAt(REG_PC) ;
end;

procedure TAm1601em.SetInstrN(var JT: TNameTable; OpC: byte;
  InstrN: string);
begin
     JT[OpC] := InstrN ;
end;

procedure TAm1601em.SetInstrNR(var JT: TNameTable; OpCS, OpCE: word;
  InstrN: string);
begin
     while (OpCS<=OpCE) do begin
         SetInstrN(JT,OpCS,InstrN) ;
         Inc(OpCS) ;
     end ;
end;

procedure TAm1601em.SetFlagValue(sFlagName: string; Value: boolean);
begin
     if      (sFlagName='C' ) then FLAG_C  := Value
     else if (sFlagName='Z' ) then FLAG_Z  := Value
     else if (sFlagName='S' ) then FLAG_S  := Value
     else if (sFlagName='O' ) then FLAG_O  := Value
     else if (sFlagName='E' ) then FLAG_E  := Value
     else if (sFlagName='I' ) then FLAG_I  := Value
     else if (sFlagName='IE') then FLAG_IE := Value
     else if (sFlagName='EE') then FLAG_EE := Value ;
end;

procedure TAm1601em.SetRegValue(sRegName: string; Value: word);
begin
     if      (sRegName='PC')        then REG_PC    := Value
     else if (sRegName='HP')        then REG_HP    := Value
     else if (sRegName='PPC')       then REG_PPC   := Value
     else if (sRegName='FLAGS')     then REG_FLAGS := Value
     else if (sRegName='RR')        then REG_RR    := Value
     else if (sRegName='PSC')       then REG_PSC   := Value
     else if (sRegName='PSP')       then REG_PSP   := Value
     else if (sRegName='RSC')       then REG_RSC   := Value
     else if (sRegName='RSP')       then REG_RSP   := Value
     else if (sRegName='EC')        then REG_EC    := Value
     else if (sRegName='EA')        then REG_EA    := Value

     else if (Left(sRegName,1)='P') then REG_PS[StrToInt(Right(sRegName,Length(sRegName)-1))] := Value
     else if (Left(sRegName,1)='R') then REG_RS[StrToInt(Right(sRegName,Length(sRegName)-1))] := Value ;
end;

procedure TAm1601em.ToggleBreak(wAddress: word);
begin
     FBreak[wAddress] := not FBreak[wAddress] ;
     SetMemByte(wAddress,FMemory[wAddress]) ;
end;

procedure TAm1601em.WriteMemory(wAddress: word; wByte: byte);
begin
     FMemory[wAddress] := wByte ;
     if (kwScreenStart<=wAddress) and (wAddress<=kwScreenEnd) then begin
         frmMain.DrawText(wAddress-kwScreenStart,wByte) ;
     end ;
end;

function TAm1601em.CC_Test(cc: byte): boolean;
begin
     result := false ;
     case cc and $f of
     $0 : result := FLAG_Z ;
     $1 : result := not FLAG_Z ;
     $2 : result := FLAG_C ;   { CS/HI }
     $3 : result := not FLAG_C ; { CC/LS }
     $4 : result := FLAG_S ;
     $5 : result := not FLAG_S ;
     $6 : result := FLAG_O ;
     $7 : result := not FLAG_O ;
     $8 : result := FLAG_C or FLAG_Z ;  { HS }
     $9 : result := not FLAG_C and not FLAG_Z ; { LO }
     $a : result := (FLAG_S and FLAG_O) or (not FLAG_S and not FLAG_O) ;
     $b : result := (FLAG_S and not FLAG_O) or (not FLAG_S and FLAG_O) ;
     $c : result := (not FLAG_Z) and ((FLAG_S and FLAG_O) or (not FLAG_S and not FLAG_O)) ;
     $d : result := (FLAG_Z) or ((FLAG_S and not FLAG_O) or (not FLAG_S and FLAG_O)) ;
     $e : result := true ;
     $f : result := not FLAG_E ;
     end ;

(*
LO = CC .and. NE OK
HS = CS .or. EQ OK
LS = CC OK
HI = CS OK
*)


end;

procedure TAm1601em.BLIT;
begin
     Push_PS(GetMemWord(REG_PPC)) ;
     Inc(REG_PPC,2) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cBR;
begin
     if (CC_Test(FMemory[REG_PC] and $f)) then begin
         REG_PC := REG_PC + ShortInt(FMemory[succ(REG_PC)]) + 2 ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cEMULATE;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_HP := GetMemWord(REG_PPC) ;
         Inc(REG_PPC,2) ;
         REG_PC := GetMemWord(REG_HP) ;
         Inc(REG_HP,2) ;
         Inc(FEFCount) ;
         if (FEFCount>1024) then begin
             FLAG_E := true ;
             FEFCount := 0 ;
         end ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cEXECUTE;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_PC := GetMemWord(REG_HP) ;
         Inc(REG_HP,2) ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cIN;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetIOInWord(GetMemWord(REG_PC+2))) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cINB;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetIOInByte(GetMemWord(REG_PC+2))) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cJMP;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_PC := GetMemWord(REG_PC+2) ;
     end
     else begin
         Inc(REG_PC,4) ;
     end ;
end;

procedure TAm1601em.cJSR;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         Push_RS(REG_PC + 4) ;
         REG_PC := GetMemWord(REG_PC+2) ;
     end
     else begin
         Inc(REG_PC,4) ;
     end ;
end;

procedure TAm1601em.cLOAD;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetMemWord(GetMemWord(REG_PC+2))) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cNLOAD;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetMemWord(REG_PC+2)) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cOUT;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         SetIOOutWord(GetMemWord(REG_PC+2),Pop_PS) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cOUTB;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         SetIOOutByte(GetMemWord(REG_PC+2),Pop_PS) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cpBSR;
var
     iSigned : SmallInt ;
begin
     iSigned := SmallInt(Pop_PS) ;
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         Push_RS(REG_PC) ;
         REG_PC := REG_PC + iSigned + 4 ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cpIN;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetIOInWord(Pop_PS)) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpINB;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetIOInByte(Pop_PS)) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpJMP;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_PC := Pop_PS ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cpJSR;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         Push_RS(REG_PC + 2) ;
         REG_PC := Pop_PS ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cpLOAD;
var
     wAddr : word ;
begin
     wAddr := Pop_PS ;
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(GetMemWord(wAddr)) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpLOADB;
var
     wAddr : word ;
begin
     wAddr := Pop_PS ;
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(FMemory[wAddr]) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpOUT;
var
     wIOAddr : word ;
begin
     wIOAddr := Pop_PS ;
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         SetIOOutWord(wIOAddr,Pop_PS) ;
     end
     else begin
         wIOAddr := Pop_PS ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpOUTB;
var
     wIOAddr : word ;
begin
     wIOAddr := Pop_PS ;
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         SetIOOutByte(wIOAddr,Pop_PS) ;
     end
     else begin
         wIOAddr := Pop_PS ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cPREPARE;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         REG_HP := GetMemWord(REG_PPC) ;
         Inc(REG_PPC,2) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpSTORE;
var
     wAddr : word ;
begin
     wAddr := Pop_PS ;
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         SetMemWord(wAddr,Pop_PS) ;
     end
     else begin
         wAddr := Pop_PS ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cpSTOREB;
var
     wAddr : word ;
begin
     wAddr := Pop_PS ;
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         SetMemByte(wAddr,Pop_PS) ;
     end
     else begin
         wAddr := Pop_PS ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cREFRESH;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         SetMemWord(REG_RR,GetMemWord(REG_RR)) ;
         Inc(REG_RR,2) ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cRTS;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_PC := Pop_RS ;
     end
     else begin
         Inc(REG_PC,2) ;
     end ;
end;

procedure TAm1601em.cSTORE;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         SetMemWord(GetMemWord(REG_PC+2),Pop_PS) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.DFX;
begin
     Push_RS(REG_PPC) ;
     REG_PPC := REG_HP ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.FLAG;
begin
     if (CC_Test(FMemory[succ(REG_PC)])) then begin
         REG_PS[0] := 1 ;
     end
     else begin
         REG_PS[0] := 0 ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.JPPC;
begin
     REG_PPC := GetMemWord(REG_PPC) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.mCLEAR;
begin
     case FMemory[succ(REG_PC)] shr 4 of
     $0 : FLAG_C  := false ;
     $1 : FLAG_Z  := false ;
     $2 : FLAG_S  := false ;
     $3 : FLAG_O  := false ;
     $4 : FLAG_E  := false ;
     $5 : FLAG_I  := false ;
     $6 : FLAG_IE := false ;
     $7 : FLAG_EE := false ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.mSET;
begin
     case FMemory[succ(REG_PC)] shr 4 of
     $0 : FLAG_C  := true ;
     $1 : FLAG_Z  := true ;
     $2 : FLAG_S  := true ;
     $3 : FLAG_O  := true ;
     $4 : FLAG_E  := true ;
     $5 : FLAG_I  := true ;
     $6 : FLAG_IE := true ;
     $7 : FLAG_EE := true ;
     end ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.NOP;
begin
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.PUSHRS;
var
     wReg : byte ;
begin
     wReg := FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     case wReg of
     QQ_PC    : Push_RS(REG_PC-2 ) ;
     QQ_PPC   : Push_RS(REG_PPC  ) ;
     QQ_HP    : Push_RS(REG_HP   ) ;
     QQ_FLAGS : Push_RS(REG_FLAGS) ;
     QQ_PSP   : Push_RS(REG_PSP  ) ;
     QQ_PSC   : Push_RS(REG_PSC  ) ;
     QQ_RSP   : Push_RS(REG_RSP  ) ;
     QQ_RSC   : Push_RS(REG_RSC  ) ;
     QQ_EA    : Push_RS(REG_EA   ) ;
     QQ_RR    : Push_RS(REG_RR   ) ;
     end ;
end;

procedure TAm1601em.sBR;
begin
     REG_PC := REG_PC + sBROffset + 2 ;
end;

procedure TAm1601em.sBSR;
begin
     Push_RS(REG_PC + 2) ;
     REG_PC := REG_PC + sBROffset + 2 ;
end;

procedure TAm1601em.POPPS;
var
     wReg : byte ;
begin
     wReg := FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     case wReg of
     QQ_PC    : REG_PC    := Pop_PS ;
     QQ_PPC   : REG_PPC   := Pop_PS ;
     QQ_HP    : REG_HP    := Pop_PS ;
     QQ_FLAGS : REG_FLAGS := Pop_PS ;
     QQ_PSP   : REG_PSP   := Pop_PS ;
     QQ_PSC   : REG_PSC   := Pop_PS ;
     QQ_RSP   : REG_RSP   := Pop_PS ;
     QQ_RSC   : REG_RSC   := Pop_PS ;
     QQ_EA    : REG_EA    := Pop_PS ;
     QQ_RR    : REG_RR    := Pop_PS ;
     end ;
end;

procedure TAm1601em.POPRS;
var
     wReg : byte ;
begin
     wReg := FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     case wReg of
     QQ_PC    : REG_PC    := Pop_RS ;
     QQ_PPC   : REG_PPC   := Pop_RS ;
     QQ_HP    : REG_HP    := Pop_RS ;
     QQ_FLAGS : REG_FLAGS := Pop_RS ;
     QQ_PSP   : REG_PSP   := Pop_RS ;
     QQ_PSC   : REG_PSC   := Pop_RS ;
     QQ_RSP   : REG_RSP   := Pop_RS ;
     QQ_RSC   : REG_RSC   := Pop_RS ;
     QQ_EA    : REG_EA    := Pop_RS ;
     QQ_RR    : REG_RR    := Pop_RS ;
     end ;
end;

procedure TAm1601em.PUSHPS;
var
     wReg : byte ;
begin
     wReg := FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     case wReg of
     QQ_PC    : Push_PS(REG_PC-2 ) ;
     QQ_PPC   : Push_PS(REG_PPC  ) ;
     QQ_HP    : Push_PS(REG_HP   ) ;
     QQ_FLAGS : Push_PS(REG_FLAGS) ;
     QQ_PSP   : Push_PS(REG_PSP  ) ;
     QQ_PSC   : Push_PS(REG_PSC  ) ;
     QQ_RSP   : Push_PS(REG_RSP  ) ;
     QQ_RSC   : Push_PS(REG_RSC  ) ;
     QQ_EA    : Push_PS(REG_EA   ) ;
     QQ_RR    : Push_PS(REG_RR   ) ;
     end ;
end;

procedure TAm1601em.sJMP;
begin
     REG_PC := word(((FMemory[REG_PC] and $0f) * 256) or FMemory[succ(REG_PC)]) ;
end;

procedure TAm1601em.sJSR;
begin
     Push_RS(REG_PC + 2) ;
     REG_PC := word(((FMemory[REG_PC] and $0f) * 256) or FMemory[succ(REG_PC)]) ;
end;

procedure TAm1601em.sLOAD;
begin
     Push_PS(GetMemWord(word(((FMemory[REG_PC] and $0f) * 256) or FMemory[succ(REG_PC)]))) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.sNADC;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned + iSigned) ;
     if (FLAG_C) then begin
         Inc(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(iLastSigned) and MSBitSet(iSigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(iSigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(iLastSigned)) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))) ;

end;

procedure TAm1601em.sNADD;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned + iSigned) ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(iLastSigned) and MSBitSet(iSigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(iSigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(iLastSigned)) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.sNAND;
var
     iSigned, iLastsigned : SmallInt ;
begin
     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned and iSigned) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.sNCMP;
var
     iSigned, iLastsigned, iResult : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     iResult := iLastSigned - iSigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := iResult = 0 ;

     FLAG_S := MSBitSet(word(iResult)) ;

     FLAG_C := ((not MSBitSet(word(iLastSigned))) and MSBitSet(word(iSigned))) or
               (MSBitSet(word(iResult)) and MSBitSet(word(iSigned))) or
               (MSBitSet(word(iResult)) and (not MSBitSet(word(iLastSigned)))) ;

     FLAG_O := (MSBitSet(word(iSigned)) and
                MSBitSet(word(iLastSigned)) and
                (not MSBitSet(word(iResult)))
               ) or
               ((not MSBitSet(word(iSigned))) and
                (not MSBitSet(word(iLastSigned))) and
                (MSBitSet(word(iResult)))
               ) ;

end;

procedure TAm1601em.sNEOR;
var
     iSigned, iLastsigned : SmallInt ;
begin
     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned xor iSigned) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.sNLOAD;
begin
     Push_PS(ShortInt(FMemory[succ(REG_PC)])) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.sNOR;
var
     iSigned, iLastsigned : SmallInt ;
begin
     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned or iSigned) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.sNRCMP;
var
     iSigned, iLastsigned, iResult : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     iResult := iSigned - iLastSigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := iResult = 0 ;

     FLAG_S := MSBitSet(word(iResult)) ;

     FLAG_C := ((not MSBitSet(word(iSigned))) and MSBitSet(word(iLastSigned))) or
               (MSBitSet(word(iResult)) and MSBitSet(word(iLastSigned))) or
               (MSBitSet(word(iResult)) and (not MSBitSet(word(iSigned)))) ;

     FLAG_O := (MSBitSet(word(iSigned)) and
                MSBitSet(word(iLastSigned)) and
                (not MSBitSet(word(iResult)))
               ) or
               ((not MSBitSet(word(iSigned))) and
                (not MSBitSet(word(iLastSigned))) and
                (MSBitSet(word(iResult)))
               ) ;

end;

procedure TAm1601em.sNRSBC;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iSigned - iLastSigned) ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(iSigned)) and MSBitSet(iLastSigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(iLastSigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(iSigned))) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.sNRSUB;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iSigned - iLastSigned) ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(iSigned)) and MSBitSet(iLastSigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(iLastSigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(iSigned))) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.sNSBC;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned - iSigned) ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(iLastSigned)) and MSBitSet(iSigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(iSigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(iLastSigned))) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.sNSUB;
var
     iSigned, iLastsigned : SmallInt ;
begin

     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     REG_PS[0] := word(iLastSigned - iSigned) ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(iLastSigned)) and MSBitSet(iSigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(iSigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(iLastSigned))) ;

     FLAG_O := (MSBitSet(iSigned) and
                MSBitSet(iLastSigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(iSigned)) and
                (not MSBitSet(iLastSigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.sNTST;
var
     iSigned, iLastsigned : SmallInt ;
begin
     iSigned := ShortInt(FMemory[succ(REG_PC)]) ;
     iLastSigned := SmallInt(REG_PS[0]) ;
     iSigned := iLastSigned and iSigned ;
     Inc(REG_PC,2) ;
     FLAG_Z := iSigned = 0 ;
     FLAG_S := MSBitSet(word(iSigned)) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.sSTORE;
begin
     SetMemWord(((FMemory[REG_PC] and $0f) * 256) or FMemory[succ(REG_PC)],REG_PS[0]) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.uNADC;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := FMemory[succ(REG_PC)] ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned + wUnsigned ;
     if (FLAG_C) then begin
         Inc(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(wLastUnsigned) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wLastUnsigned)) ;

     FLAG_O := (MSBitSet(wUnsigned) and MSBitSet(wLastUnsigned) and (not MSBitSet(REG_PS[0]))) or
               ((not MSBitSet(wUnsigned)) and (not MSBitSet(wLastUnsigned)) and (MSBitSet(REG_PS[0]))) ;

end;

procedure TAm1601em.uNADD;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := FMemory[succ(REG_PC)] ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned + wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(wLastUnsigned) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wLastUnsigned)) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.uNAND;
begin
     REG_PS[0] := REG_PS[0] and FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.uNCMP;
var
     wUnsigned, wLastUnsigned, wResult : word ;
begin

     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     wResult := wLastUnsigned-wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := wResult = 0 ;

     FLAG_S := MSBitSet(wResult) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(wResult) and MSBitSet(wUnsigned)) or
               (MSBitSet(wResult) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(wResult))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(wResult)
               ) ;

end;

procedure TAm1601em.uNEOR;
begin
     REG_PS[0] := REG_PS[0] xor FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.uNLOAD;
begin
     Push_PS(FMemory[succ(REG_PC)]) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.uNMASK;
begin
     REG_PS[0] := 1 shl (FMemory[succ(REG_PC)] and $f) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.uNOR;
begin
     REG_PS[0] := REG_PS[0] or FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.uNRCMP;
var
     wUnsigned, wLastUnsigned, wResult : word ;
begin

     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     wResult := wUnsigned-wLastUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := wResult = 0 ;

     FLAG_S := MSBitSet(wResult) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(wResult) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(wResult) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(wResult))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(wResult)
               ) ;

end;

procedure TAm1601em.uNRSBC;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     REG_PS[0] := wUnsigned-wLastUnsigned ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(REG_PS[0])
               ) ;

end;

procedure TAm1601em.uNRSUB;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     REG_PS[0] := wUnsigned-wLastUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(REG_PS[0])
               ) ;

end;

procedure TAm1601em.uNSBC;
var
     wLastUnsigned, wUnsigned : word ;
begin
     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     REG_PS[0] := wLastUnsigned - wUnsigned ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(REG_PS[0])
               ) ;

end;

procedure TAm1601em.uNSUB;
var
     wLastUnsigned, wUnsigned : word ;
begin

     wLastUnsigned := REG_PS[0] ;
     wUnsigned := FMemory[succ(REG_PC)] ;
     REG_PS[0] := wLastUnsigned - wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                MSBitSet(REG_PS[0])
               ) ;

end;

procedure TAm1601em.uNTST;
var
     wResult : word ;
begin
     wResult := REG_PS[0] and FMemory[succ(REG_PC)] ;
     Inc(REG_PC,2) ;
     FLAG_Z := wResult = 0 ;
     FLAG_S := MSBitSet(wResult) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.XB;
begin
     REG_PS[0] := (REG_PS[0] shr 8) or (REG_PS[0] shl 8) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.cLOADB;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         Push_PS(FMemory[GetMemWord(REG_PC+2)]) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.cSTOREB;
begin
     FLAG_Z := CC_Test(FMemory[succ(REG_PC)]) ;
     if (FLAG_Z) then begin
         SetMemByte(GetMemWord(REG_PC+2),Pop_PS) ;
     end ;
     Inc(REG_PC,4) ;
end;

procedure TAm1601em.ASR;
var
     wMSBit : word ;
begin
     FLAG_C := REG_PS[0] and $0001 <> 0 ;
     wMSBit := REG_PS[0] and $8000 ;
     REG_PS[0] := (REG_PS[0] shr 1) or wMSBit ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.CPL;
begin
     FLAG_C := REG_PS[0] <> $0001 ;
     REG_PS[0] := not REG_PS[0] ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.DEL;
begin
     Pop_PS ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.DUPL;
begin
     Push_PS(REG_PS[0]) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.IDX;
begin
     Push_PS(REG_RS[0]) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.LSL;
begin
     FLAG_C := MSBitSet(REG_PS[0]) ;
     REG_PS[0] := REG_PS[0] shl 1 ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.LSR;
begin
     FLAG_C := REG_PS[0] and $0001 <> 0 ;
     REG_PS[0] := REG_PS[0] shr 1 ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.NEG;
begin
     FLAG_C := REG_PS[0] <> $0000 ;
     REG_PS[0] := word(0 - SmallInt(REG_PS[0])) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.P1ADC;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned + wUnsigned ;
     if (FLAG_C) then begin
         Inc(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(wLastUnsigned) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wLastUnsigned)) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.P1ADD;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned + wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := (MSBitSet(wLastUnsigned) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wUnsigned)) or
               ((not MSBitSet(REG_PS[0])) and MSBitSet(wLastUnsigned)) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;
end;

procedure TAm1601em.P1AND;
var
     wUnsigned : word ;
begin
     wUnsigned := Pop_PS ;
     REG_PS[0] := REG_PS[0] and wUnsigned ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.P0CMP;
var
     wUnsigned, wLastUnsigned, wResult : word ;
begin

     wUnsigned := REG_PS[0] ;
     wLastUnsigned := REG_PS[1] ;
     wResult := wLastUnsigned - wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := wResult = 0 ;

     FLAG_S := MSBitSet(wResult) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(wResult) and MSBitSet(wUnsigned)) or
               (MSBitSet(wResult) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(wResult))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(wResult))
               ) ;

end;

procedure TAm1601em.P1EOR;
var
     wUnsigned : word ;
begin
     wUnsigned := Pop_PS ;
     REG_PS[0] := REG_PS[0] xor wUnsigned ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.P0MASK;
begin
     REG_PS[0] := word(1 shl (REG_PS[0] and $f)) ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.P1OR;
var
     wUnsigned : word ;
begin
     wUnsigned := Pop_PS ;
     REG_PS[0] := REG_PS[0] or wUnsigned ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.P1RCMP;
var
     wUnsigned, wLastUnsigned, wResult : word ;
begin

     wUnsigned := REG_PS[0] ;
     wLastUnsigned := REG_PS[1] ;
     wResult := wUnsigned - wLastUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := wResult = 0 ;

     FLAG_S := MSBitSet(wResult) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(wResult) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(wResult) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(wResult))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(wResult))
               ) ;

end;

procedure TAm1601em.P1RSBC;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wUnsigned - wLastUnsigned ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;


end;

procedure TAm1601em.P1RSUB;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wUnsigned - wLastUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wUnsigned)) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wLastUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.P0SBC;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned - wUnsigned ;
     if (FLAG_C) then begin
         Dec(REG_PS[0]) ;
     end ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.P0SUB;
var
     wUnsigned, wLastUnsigned : word ;
begin

     wUnsigned := Pop_PS ;
     wLastUnsigned := REG_PS[0] ;
     REG_PS[0] := wLastUnsigned - wUnsigned ;
     Inc(REG_PC,2) ;

     FLAG_Z := REG_PS[0] = 0 ;

     FLAG_S := MSBitSet(REG_PS[0]) ;

     FLAG_C := ((not MSBitSet(wLastUnsigned)) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and MSBitSet(wUnsigned)) or
               (MSBitSet(REG_PS[0]) and (not MSBitSet(wLastUnsigned))) ;

     FLAG_O := (MSBitSet(wUnsigned) and
                MSBitSet(wLastUnsigned) and
                (not MSBitSet(REG_PS[0]))
               ) or
               ((not MSBitSet(wUnsigned)) and
                (not MSBitSet(wLastUnsigned)) and
                (MSBitSet(REG_PS[0]))
               ) ;

end;

procedure TAm1601em.P1TST;
var
     wResult : word ;
begin
     wResult := Pop_PS ; // the manual is ambiguous here the formula shows pop, but the text says that
                         // the stacks remain unchanged **** CHECK ***
     wResult := REG_PS[0] and wResult ;
     Inc(REG_PC,2) ;
     FLAG_Z := wResult = 0 ;
     FLAG_S := MSBitSet(wResult) ;
     FLAG_C := false ;
     FLAG_O := false ;
end;

procedure TAm1601em.PTOR;
begin
     Push_RS(Pop_PS) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.ROL;
var
     wCarry : word ;
begin
     if (FLAG_C) then begin
         wCarry := $0001 ;
     end
     else begin
         wCarry := $0000 ;
     end ;
     FLAG_C := MSBitSet(REG_PS[0]) ;
     REG_PS[0] := (REG_PS[0] shl 1) or wCarry ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.ROR;
var
     wCarry : word ;
begin
     if (FLAG_C) then begin
         wCarry := $8000 ;
     end
     else begin
         wCarry := $0000 ;
     end ;
     FLAG_C := REG_PS[0] and $0001 <> 0 ;
     REG_PS[0] := (REG_PS[0] shr 1) or wCarry ;
     Inc(REG_PC,2) ;
     FLAG_Z := REG_PS[0] = 0 ;
     FLAG_S := MSBitSet(REG_PS[0]) ;
     FLAG_O := false ;
end;

procedure TAm1601em.RTD;
var
     wBuffer : word ;
begin
     wBuffer   := REG_PS[2] ;
     REG_PS[2] := REG_PS[1] ;
     REG_PS[1] := REG_PS[0] ;
     REG_PS[0] := wBuffer   ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.RTOP;
begin
     Push_PS(Pop_RS) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.RTU;
var
     wBuffer : word ;
begin
     wBuffer   := REG_PS[0] ;
     REG_PS[0] := REG_PS[1] ;
     REG_PS[1] := REG_PS[2] ;
     REG_PS[2] := wBuffer ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.SOT;
begin
     Push_PS(REG_PS[1]) ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.SWAP;
var
     wBuffer : word ;
begin
     wBuffer   := REG_PS[0] ;
     REG_PS[0] := REG_PS[1] ;
     REG_PS[1] := wBuffer   ;
     Inc(REG_PC,2) ;
end;

procedure TAm1601em.XRP;
var
     wBuffer : word ;
begin
     wBuffer   := REG_PS[0] ;
     REG_PS[0] := REG_RS[0] ;
     REG_RS[0] := wBuffer   ;
     Inc(REG_PC,2) ;
end;

function TAm1601em.sBROffset: word;
begin
     result := ((FMemory[REG_PC] and $0f) * 256) or FMemory[succ(REG_PC)] ;
     if (result and $0800 <> 0) then begin
         result := result or $F000 ;
     end ;
end;

function TAm1601em.MSBitSet(wValue: word): boolean;
begin
     result := wValue and $8000 <> 0 ;
end;

function TAm1601em.GetBreakPoint(wAddress: word): boolean;
begin
     result := FBreak[wAddress] ;
end;

function TAm1601em.GetFlagValue(sFlagName: string): boolean;
begin
     if      (sFlagName='C' ) then result := FLAG_C
     else if (sFlagName='Z' ) then result := FLAG_Z
     else if (sFlagName='S' ) then result := FLAG_S
     else if (sFlagName='O' ) then result := FLAG_O
     else if (sFlagName='E' ) then result := FLAG_E
     else if (sFlagName='I' ) then result := FLAG_I
     else if (sFlagName='IE') then result := FLAG_IE
     else if (sFlagName='EE') then result := FLAG_EE ;
end;

function TAm1601em.GetRegValue(sRegName: string): word;
begin
     if      (sRegName='PC')        then result := REG_PC
     else if (sRegName='HP')        then result := REG_HP
     else if (sRegName='PPC')       then result := REG_PPC
     else if (sRegName='FLAGS')     then result := REG_FLAGS
     else if (sRegName='RR')        then result := REG_RR
     else if (sRegName='PSC')       then result := REG_PSC
     else if (sRegName='PSP')       then result := REG_PSP
     else if (sRegName='RSC')       then result := REG_RSC
     else if (sRegName='RSP')       then result := REG_RSP
     else if (sRegName='EC')        then result := REG_EC
     else if (sRegName='EA')        then result := REG_EA
     else if (Left(sRegName,1)='P') then result := REG_PS[StrToInt(Right(sRegName,Length(sRegName)-1))]
     else if (Left(sRegName,1)='R') then result := REG_RS[StrToInt(Right(sRegName,Length(sRegName)-1))] ;
end;

end.
