unit ufrmRegisterView;

(*
        Am1601 Emulator - ufrmRegisterView
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

     1.0.0      Created September 1, 2002 PCLW

*)

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, ufrmTemplate, QExtCtrls;

type

  TRegNode = record
                   RegName : string ;
                   X1,Y1,X2,Y2 : integer ;
             end ;

  TfrmRegisterView = class(TfrmTemplate)
    imgDump: TImage;
    Panel1: TPanel;
    lblSelectedReg: TLabel;
    edtEditWord: TEdit;
    btnSetWord: TButton;
    lblSelectedFlag: TLabel;
    btnSetFlag: TButton;
    chkbxFlag: TCheckBox;
    Panel2: TPanel;
    btnRST: TButton;
    btnINT: TButton;
    btnStep: TButton;
    btnRun: TButton;
    btnPause: TButton;
    pnlNext: TPanel;
    imgMainView: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure imgDumpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnSetFlagClick(Sender: TObject);
    procedure btnSetWordClick(Sender: TObject);
    procedure edtEditWordKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnRSTClick(Sender: TObject);
    procedure btnINTClick(Sender: TObject);
    procedure btnStepClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
  private
    { Private declarations }
    Registers : array[0..43] of TRegNode ;
    MaxReg : integer ;
    Flags : array[0..$f] of TRegNode ;
    CCs : array[0..$f] of TRegNode ;
    MaxFlag : integer ;
    MaxCC : integer ;
  public
    { Public declarations }
    procedure SetRegNode(sRegName:string;X1,Y1:integer) ;
    procedure SetFlagNode(sFlagName:string;X1,Y1:integer) ;
    procedure SetCCNode(sCCName:string;X1,Y1:integer) ;
    procedure UpdateRegisters ;
    procedure UpdateRegister(sRegName:string;Value:word;Color:TColor) ;
    procedure UpdateFlag(sRegName:string;Value:boolean;Color:TColor) ;
    procedure UpdateCC(sRegName:string;Value:boolean;Color:TColor) ;
  end;

var
  frmRegisterView: TfrmRegisterView;

implementation

{$R *.xfm}

uses

     ufrmMain,
     umdlStrings,
     umdlAm1601em,
     umdlRunCode ;

const

     kwWidth = 20 ;
     kwDepth = 14 ;

procedure TfrmRegisterView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     inherited;
     frmMain.mnuRegisterView.Checked := false ;
end;

procedure TfrmRegisterView.FormCreate(Sender: TObject);
var ii : integer ;
begin
     inherited;

     imgDump.Canvas.Font.Size := 10 ;
     imgDump.Canvas.Font.Name := 'Courier' ;
     imgDump.Canvas.Brush.Color := clBackground ;
     imgDump.Canvas.Font.Color := clBlack ;
     imgDump.Canvas.Font.Style := [fsBold] ;

     MaxReg := 0 ;

     SetRegNode('PC'   ,220,0*kwDepth) ;
     SetRegNode('FLAGS',220,1*kwDepth) ;
     SetRegNode('PPC'  ,220,2*kwDepth) ;
     SetRegNode('HP'   ,220,3*kwDepth) ;
     SetRegNode('PSC'  ,0,17*kwDepth) ;
     SetRegNode('PSP'  ,0,18*kwDepth) ;
     SetRegNode('RSC'  ,120,17*kwDepth) ;
     SetRegNode('RSP'  ,120,18*kwDepth) ;

     for ii := 0 to $f do begin
         SetRegNode('P'+IntToStr(ii),0,ii*kwDepth) ;
         SetRegNode('R'+IntToStr(ii),120,ii*kwDepth) ;
     end ;

     MaxFlag := 0 ;
     SetFlagNode('C' ,220,5*kwDepth) ;
     SetFlagNode('Z' ,220,6*kwDepth) ;
     SetFlagNode('S' ,220,7*kwDepth) ;
     SetFlagNode('O' ,220,8*kwDepth) ;
     SetFlagNode('E' ,220,9*kwDepth) ;
     SetFlagNode('I' ,220,10*kwDepth) ;
     SetFlagNode('IE',220,11*kwDepth) ;
     SetFlagNode('EE',220,12*kwDepth) ;

     SetRegNode('EA' ,220,14*kwDepth) ;
     SetRegNode('EC' ,220,15*kwDepth) ;

     SetRegNode('RR' ,240,17*kwDepth) ;

     SetCCNode('EQ'    ,330,0*kwDepth) ;
     SetCCNode('NE'    ,330,1*kwDepth) ;
     SetCCNode('CS/HI' ,330,2*kwDepth) ;
     SetCCNode('CC/LS' ,330,3*kwDepth) ;
     SetCCNode('MI'    ,330,4*kwDepth) ;
     SetCCNode('PL'    ,330,5*kwDepth) ;
     SetCCNode('VS'    ,330,6*kwDepth) ;
     SetCCNode('VC'    ,330,7*kwDepth) ;
     SetCCNode('HS'    ,330,8*kwDepth) ;
     SetCCNode('LO'    ,330,9*kwDepth) ;
     SetCCNode('GE'    ,330,10*kwDepth) ;
     SetCCNode('LT'    ,330,11*kwDepth) ;
     SetCCNode('GT'    ,330,12*kwDepth) ;
     SetCCNode('LE'    ,330,13*kwDepth) ;
     SetCCNode('AL'    ,330,14*kwDepth) ;
     SetCCNode('NEF'   ,330,15*kwDepth) ;

     UpdateRegisters ;

end;

procedure TfrmRegisterView.SetRegNode(sRegName: string; X1, Y1: integer);

begin
     Registers[MaxReg].RegName := sRegName ;
     Registers[MaxReg].X1 := X1 ;
     Registers[MaxReg].Y1 := Y1 ;
     Registers[MaxReg].X2 := X1 + 86 ;
     Registers[MaxReg].Y2 := Y1 + kwDepth  ;
     imgDump.Canvas.TextOut(X1,Y1,sRegName) ;
     MaxReg := MaxReg + 1 ;

end;

procedure TfrmRegisterView.UpdateRegister(sRegName: string; Value: word;Color:TColor);
var
     pRect : TRect ;
     ii : integer ;
begin
     ii := 0 ;
     while (ii<=MaxReg) and (Registers[ii].RegName<>sRegName) do begin
         Inc(ii) ;
     end ;
     pRect.Left   := Registers[ii].X1 + 45 ;
     pRect.Top    := Registers[ii].Y1 ;
     pRect.Right  := Registers[ii].X2 ;
     pRect.Bottom := Registers[ii].Y2 ;

     imgDump.Canvas.Brush.Color := Color ;
     imgDump.Canvas.FillRect(pRect);

     imgDump.Canvas.TextOut(Registers[ii].X1 + 45,Registers[ii].Y1,'#'+HexW(Value)) ;

end;

procedure TfrmRegisterView.UpdateRegisters;
var

     ii : integer ;

begin

     inherited;

     imgDump.Canvas.Brush.Color := clBackground ;
     imgDump.Canvas.Font.Color := clBlack ;
     imgDump.Canvas.Font.Style := [] ;

     UpdateRegister('PC'   ,Am1601.REG_PC,clWhite) ;
     UpdateRegister('HP'   ,Am1601.REG_HP,clWhite) ;
     UpdateRegister('PPC'  ,Am1601.REG_PPC,clWhite) ;
     UpdateRegister('RR'   ,Am1601.REG_RR,clWhite) ;
     UpdateRegister('EA'   ,Am1601.REG_EA,clWhite) ;
     UpdateRegister('FLAGS',Am1601.REG_FLAGS,clWhite) ;
     UpdateRegister('PSC'  ,Am1601.REG_PSC,clWhite) ;
     UpdateRegister('PSP'  ,Am1601.REG_PSP,clWhite) ;
     UpdateRegister('RSC'  ,Am1601.REG_RSC,clWhite) ;
     UpdateRegister('RSP'  ,Am1601.REG_RSP,clWhite) ;
     UpdateRegister('EC'   ,Am1601.REG_EC,clWhite) ;
     UpdateFlag('C'   ,Am1601.FLAG_C,clWhite) ;
     UpdateFlag('Z'   ,Am1601.FLAG_Z,clWhite) ;
     UpdateFlag('S'   ,Am1601.FLAG_S,clWhite) ;
     UpdateFlag('O'   ,Am1601.FLAG_O,clWhite) ;
     UpdateFlag('E'   ,Am1601.FLAG_E,clWhite) ;
     UpdateFlag('I'   ,Am1601.FLAG_I,clWhite) ;
     UpdateFlag('IE'   ,Am1601.FLAG_IE,clWhite) ;
     UpdateCC('EQ'    ,Am1601.CC_Test($00),clWhite) ;
     UpdateCC('NE'    ,Am1601.CC_Test($01),clWhite) ;
     UpdateCC('CS/HI' ,Am1601.CC_Test($02),clWhite) ;
     UpdateCC('CC/LS' ,Am1601.CC_Test($03),clWhite) ;
     UpdateCC('MI'    ,Am1601.CC_Test($04),clWhite) ;
     UpdateCC('PL'    ,Am1601.CC_Test($05),clWhite) ;
     UpdateCC('VS'    ,Am1601.CC_Test($06),clWhite) ;
     UpdateCC('VC'    ,Am1601.CC_Test($07),clWhite) ;
     UpdateCC('HS'    ,Am1601.CC_Test($08),clWhite) ;
     UpdateCC('LO'    ,Am1601.CC_Test($09),clWhite) ;
     UpdateCC('GE'    ,Am1601.CC_Test($0A),clWhite) ;
     UpdateCC('LT'    ,Am1601.CC_Test($0B),clWhite) ;
     UpdateCC('GT'    ,Am1601.CC_Test($0C),clWhite) ;
     UpdateCC('LE'    ,Am1601.CC_Test($0D),clWhite) ;
     UpdateCC('AL'    ,Am1601.CC_Test($0E),clWhite) ;
     UpdateCC('NEF'   ,Am1601.CC_Test($0F),clWhite) ;


     btnINT.Enabled := Am1601.FLAG_IE ;
     UpdateFlag('EE'   ,Am1601.FLAG_EE,clWhite) ;

     for ii := 0 to $f do begin
         if (ii<=Am1601.REG_PSC-1) then begin
             UpdateRegister('P'+IntToStr(ii),Am1601.REG_PS[ii],clWhite) ;
         end
         else begin
             UpdateRegister('P'+IntToStr(ii),Am1601.REG_PS[ii],clGray) ;
         end ;
         if (ii<=Am1601.REG_RSC-1) then begin
             UpdateRegister('R'+IntToStr(ii),Am1601.REG_RS[ii],clWhite) ;
         end
         else begin
             UpdateRegister('R'+IntToStr(ii),Am1601.REG_RS[ii],clGray) ;
         end ;
     end ;

     pnlNext.Caption := Am1601.NextInstruction ;

     imgMainView.Picture := imgDump.Picture ;

end;

procedure TfrmRegisterView.imgDumpMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
     ii : integer ;
begin
     inherited;
     for ii := 0 to MaxReg do begin
         if (Registers[ii].X1<=X) and (X<=Registers[ii].X2) and
            (Registers[ii].Y1<=Y) and (Y<=Registers[ii].Y2) then begin
             lblSelectedReg.Caption := Registers[ii].RegName ;
             edtEditWord.Text := HexW(Am1601.GetRegValue(lblSelectedReg.Caption)) ;
             Exit ;
         end ;
     end ;
     for ii := 0 to MaxFlag do begin
         if (Flags[ii].X1<=X) and (X<=Flags[ii].X2) and
            (Flags[ii].Y1<=Y) and (Y<=Flags[ii].Y2) then begin
             lblSelectedFlag.Caption := Flags[ii].RegName ;
             chkbxFlag.Checked := Am1601.GetFlagValue(lblSelectedFlag.Caption) ;
             Exit ;
         end ;
     end ;
end;

procedure TfrmRegisterView.SetFlagNode(sFlagName: string; X1, Y1: integer);
begin
     Flags[MaxFlag].RegName := sFlagName ;
     Flags[MaxFlag].X1 := X1 ;
     Flags[MaxFlag].Y1 := Y1 ;
     Flags[MaxFlag].X2 := X1 + 54 ;
     Flags[MaxFlag].Y2 := Y1 + kwDepth  ;
     imgDump.Canvas.TextOut(X1,Y1,sFlagName) ;
     MaxFlag := MaxFlag + 1 ;
end;

procedure TfrmRegisterView.UpdateFlag(sRegName: string; Value: boolean;
  Color: TColor);
var
     pRect : TRect ;
     ii : integer ;
begin

     ii := 0 ;
     while (ii<=MaxFlag) and (Flags[ii].RegName<>sRegName) do begin
         Inc(ii) ;
     end ;

     pRect.Left   := Flags[ii].X1 + 45 ;
     pRect.Top    := Flags[ii].Y1 ;
     pRect.Right  := Flags[ii].X2 ;
     pRect.Bottom := Flags[ii].Y2 ;

     imgDump.Canvas.Brush.Color := Color ;
     imgDump.Canvas.FillRect(pRect);

     if (Value) then begin
         imgDump.Canvas.TextOut(Flags[ii].X1 + 45,Flags[ii].Y1,'1') ;
     end
     else begin
         imgDump.Canvas.TextOut(Flags[ii].X1 + 45,Flags[ii].Y1,'0') ;
     end ;

end;

procedure TfrmRegisterView.btnSetFlagClick(Sender: TObject);
begin
     inherited;
     Am1601.SetFlagValue(lblSelectedFlag.Caption,chkbxFlag.Checked);
     UpdateRegisters ;
end;

procedure TfrmRegisterView.btnSetWordClick(Sender: TObject);
begin
     inherited;
     Am1601.SetRegValue(lblSelectedReg.Caption,HexToWord(edtEditWord.Text));
     UpdateRegisters ;

end;

procedure TfrmRegisterView.edtEditWordKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     inherited;
     btnSetWord.Enabled := CheckHex(edtEditWord.Text) ;
end;

procedure TfrmRegisterView.btnRSTClick(Sender: TObject);
begin
     inherited;
//     frmMain.tmrRun.Enabled := false ;
     if (IsRunning) then begin
         RunCode.Terminate ;
     end ;
     Am1601.TriggerReset ;
     Am1601.Emulate ;
end;

procedure TfrmRegisterView.btnINTClick(Sender: TObject);
begin
     inherited;
     Am1601.TriggerInterrupt ;
end;

procedure TfrmRegisterView.btnStepClick(Sender: TObject);
begin
     inherited;
     Am1601.Emulate ;
end;

procedure TfrmRegisterView.btnRunClick(Sender: TObject);
begin
     inherited;
     frmMain.mnuStartClick(Self) ;
end;

procedure TfrmRegisterView.btnPauseClick(Sender: TObject);
begin
  inherited;
 //    frmMain.tmrRun.Enabled := false ;
  RunCode.Terminate ;
end;

procedure TfrmRegisterView.SetCCNode(sCCName: string; X1, Y1: integer);
begin
     CCs[MaxCC].RegName := sCCName ;
     CCs[MaxCC].X1 := X1 ;
     CCs[MaxCC].Y1 := Y1 ;
     CCs[MaxCC].X2 := X1 + 54 ;
     CCs[MaxCC].Y2 := Y1 + kwDepth  ;
     imgDump.Canvas.TextOut(X1,Y1,sCCName) ;
     MaxCC := MaxCC + 1 ;
end;

procedure TfrmRegisterView.UpdateCC(sRegName: string; Value: boolean;
  Color: TColor);
var
     pRect : TRect ;
     ii : integer ;
begin

     ii := 0 ;
     while (ii<=MaxCC) and (CCs[ii].RegName<>sRegName) do begin
         Inc(ii) ;
     end ;

     pRect.Left   := CCs[ii].X1 + 45 ;
     pRect.Top    := CCs[ii].Y1 ;
     pRect.Right  := CCs[ii].X2 ;
     pRect.Bottom := CCs[ii].Y2 ;

     imgDump.Canvas.Brush.Color := Color ;
     imgDump.Canvas.FillRect(pRect);

     if (Value) then begin
         imgDump.Canvas.TextOut(CCs[ii].X1 + 45,CCs[ii].Y1,'x') ;
     end
     else begin
         imgDump.Canvas.TextOut(CCs[ii].X1 + 45,CCs[ii].Y1,'-') ;
     end ;

end;

end.
