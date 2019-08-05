unit ufrmMain;

(*
             Am1601 Emulator - ufrmMain
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

     1.0.0      Created August 31, 2002 PCLW
     1.0.1      Memory View A-D added September 7, 2002 PCLW

*)

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QMenus, QTypes, QExtCtrls, Qt;

type

  TfrmMain = class(TForm)
    mnuMain: TMainMenu;
    mnuFile: TMenuItem;
    mnuExit: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuView: TMenuItem;
    mnuTools: TMenuItem;
    mnuOptions: TMenuItem;
    tmrClose: TTimer;
    mnuRun: TMenuItem;
    mnuStart: TMenuItem;
    pnlIPSScreen: TPanel;
    imgIPSScreen: TImage;
    mnuRegisterView: TMenuItem;
    mnuMemoryView: TMenuItem;
    mnuLoad: TMenuItem;
    mnuSave: TMenuItem;
    N1: TMenuItem;
    mnuMemoryViewB: TMenuItem;
    mnuMemoryViewC: TMenuItem;
    mnuMemoryViewD: TMenuItem;
    mnuInputPortView: TMenuItem;
    mnuOutputPortView: TMenuItem;
    dlgOpenDialog: TOpenDialog;
    dlgSaveDialog: TSaveDialog;
    procedure mnuExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuMemoryViewClick(Sender: TObject);
    procedure mnuRegisterViewClick(Sender: TObject);
    procedure mnuMemoryViewBClick(Sender: TObject);
    procedure mnuMemoryViewCClick(Sender: TObject);
    procedure mnuMemoryViewDClick(Sender: TObject);
    procedure mnuLoadClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuStartClick(Sender: TObject);
    procedure tmrRunTimer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  KBufCount : byte ;
  KBuf : array[$00..$ff] of word ;
  KBufNext : byte ;
  KBufRead : byte ;
  public
    { Public declarations }
     bStartUp : boolean ;
     procedure DrawText(wAddress:word;wChar:byte) ;
     procedure ErrorHandler(wError:word) ;
     function KeyWaiting : boolean ;
     function ReadKey : word ;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.xfm}

uses

     INIFiles ,
     umdlGlobal,
     ufrmSplash,
     ufrmAbout,
     umdlAm1601em,
     ufrmMemoryView,
     ufrmRegisterView,
     umdlRunCode ;

procedure TfrmMain.mnuExitClick(Sender: TObject);
begin
     Self.Close ;
end;

procedure TfrmMain.FormCreate(Sender: TObject);

var
     pMemINIFile : TMemINIFile ;
     ii : word ;

begin


     Am1601 := TAm1601em.Create ;

     KBufCount := 0 ;
     KBufNext := 0 ;
     KBufRead := 0 ;

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             Left := ReadInteger(Name,'Left',Left) ;
             Top := ReadInteger(Name,'Top',Top) ;
             mnuRegisterView.Checked := ReadBool(Name,'Register View',false) ;
             mnuMemoryView.Checked := ReadBool(Name,'Memory View A',false) ;
             mnuMemoryViewB.Checked := ReadBool(Name,'Memory View B',false) ;
             mnuMemoryViewC.Checked := ReadBool(Name,'Memory View C',false) ;
             mnuMemoryViewD.Checked := ReadBool(Name,'Memory View D',false) ;
         end ;
     finally
         pMemINIFile.Free ;
     end ;

     bStartUp := true ; // Force Splash Screem on Activate

     imgIPSScreen.Canvas.Font.Size := 11 ;
     imgIPSScreen.Canvas.Font.Name := 'Courier' ;
     imgIPSScreen.Canvas.Font.Style := [fsBold] ;

     for ii := 0 to 1023 do begin
         DrawText(ii,$20) ;
     end ;


end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
     pMemINIFile : TMemINIFile ;

begin

     
     if (IsRunning ) then RunCode.Destroy ;

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             WriteInteger(Name,'Left',Left) ;
             WriteInteger(Name,'Top',Top) ;
             WriteBool(Name,'Register View',mnuRegisterView.Checked) ;
             WriteBool(Name,'Memory View A',mnuMemoryView.Checked) ;
             WriteBool(Name,'Memory View B',mnuMemoryViewB.Checked) ;
             WriteBool(Name,'Memory View C',mnuMemoryViewC.Checked) ;
             WriteBool(Name,'Memory View D',mnuMemoryViewD.Checked) ;
             UpdateFile ; // Flush memory copy to disc
         end ;
     finally
         pMemINIFile.Free ;
     end ;


     Am1601.Free ;

end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin

//   Display Splash Screen on StartUp

     if (bStartUp) then begin
         frmSplash := TfrmSplash.Create(Self) ;
         frmSplash.Show ;
         if (mnuRegisterView.Checked) then begin
             mnuRegisterViewClick(Self) ;
         end ;
         if (mnuMemoryView.Checked) then begin
             mnuMemoryViewClick(Self) ;
         end ;
         if (mnuMemoryViewB.Checked) then begin
             mnuMemoryViewBClick(Self) ;
         end ;
         if (mnuMemoryViewC.Checked) then begin
             mnuMemoryViewCClick(Self) ;
         end ;
         if (mnuMemoryViewD.Checked) then begin
             mnuMemoryViewDClick(Self) ;
         end ;
         Am1601.PowerUp ;
         bStartUp := false ;
     end ;

end;

procedure TfrmMain.tmrCloseTimer(Sender: TObject);
begin
     frmSplash.Hide ;
     tmrClose.Enabled := false ;
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
     frmAbout := TfrmAbout.Create(nil) ;
     frmAbout.ShowModal ;
     Self.SetFocus ;
end;

procedure TfrmMain.DrawText(wAddress:word;wChar:byte);
var
     X, Y : integer ;
     pRect : TRect ;
begin

     X := (wAddress mod 64) * 10 ;
     Y := (wAddress div 64) * 16 ;

     pRect.Left := X ;
     pRect.Top := Y ;
     pRect.Right := X + 11 ;
     pRect.Bottom := Y + 17 ;

     if (wChar and $80 <>0) then begin
         imgIPSScreen.Canvas.Brush.Color := clBlack ;
         imgIPSScreen.Canvas.Font.Color := clBackground ;
     end
     else begin
         imgIPSScreen.Canvas.Brush.Color := clBackground ;
         imgIPSScreen.Canvas.Font.Color := clBlack ;
     end ;
     imgIPSScreen.Canvas.FillRect(pRect);
     imgIPSScreen.Canvas.TextOut(X,Y,Chr(wChar and $7F)) ;

end;

procedure TfrmMain.ErrorHandler(wError: word);
begin

end;

function TfrmMain.KeyWaiting: boolean;
begin
     KeyWaiting := KBufCount <> 0 ;
end;

function TfrmMain.ReadKey: word;
begin
     result := KBuf[KBufRead] ;
     KBufRead := kBufRead + 1 ;
     KBufCount := KBufCount - 1 ;
end;

procedure TfrmMain.mnuMemoryViewClick(Sender: TObject);
begin
     if (not mnuMemoryView.Checked) or (bStartUp) then begin
         mnuMemoryView.Checked := true ;
         frmMemoryViewA := TfrmMemoryView.Create(Self) ;
         frmMemoryViewA.PageName := 'Memory View A' ;
     end ;
     frmMemoryViewA.Show ;
end;

procedure TfrmMain.mnuRegisterViewClick(Sender: TObject);
begin
     if (not mnuRegisterView.Checked) or (bStartUp) then begin
         mnuRegisterView.Checked := true ;
         frmRegisterView := TfrmRegisterView.Create(Self) ;
     end ;
     frmRegisterView.Show ;
end;

procedure TfrmMain.mnuMemoryViewBClick(Sender: TObject);
begin
     if (not mnuMemoryViewB.Checked) or (bStartUp) then begin
         mnuMemoryViewB.Checked := true ;
         frmMemoryViewB := TfrmMemoryView.Create(Self) ;
         frmMemoryViewB.PageName := 'Memory View B' ;
     end ;
     frmMemoryViewB.Show ;

end;

procedure TfrmMain.mnuMemoryViewCClick(Sender: TObject);
begin
     if (not mnuMemoryViewC.Checked) or (bStartUp) then begin
         mnuMemoryViewC.Checked := true ;
         frmMemoryViewC := TfrmMemoryView.Create(Self) ;
         frmMemoryViewC.PageName := 'Memory View C' ;
     end ;
     frmMemoryViewC.Show ;

end;

procedure TfrmMain.mnuMemoryViewDClick(Sender: TObject);
begin
     if (not mnuMemoryViewD.Checked) or (bStartUp) then begin
         mnuMemoryViewD.Checked := true ;
         frmMemoryViewD := TfrmMemoryView.Create(Self) ;
         frmMemoryViewD.PageName := 'Memory View D' ;
     end ;
     frmMemoryViewD.Show ;

end;

procedure TfrmMain.mnuLoadClick(Sender: TObject);
var
     fIn : file of byte ;
     wByte : byte ;
     wAddress : word ;
begin
     dlgOpenDialog.FileName := '*.bin' ;
     dlgOpenDialog.Title := 'Load Memory Image' ;
     if (dlgOpenDialog.Execute) then begin
         AssignFile(fIn,dlgOpenDialog.FileName) ;
         Reset(fIn) ;
         wAddress := 0 ;
         while (not Eof(fIn)) do begin
             Read(fIn,wByte) ;
             Am1601.WriteMemory(wAddress,wByte); // Direct Hit
             Inc(wAddress);
         end ;
         Am1601.SetMemByte(0,Am1601.GetMemByte(0)) ; // Force Update
         CloseFile(fIn) ;
     end ;
end;

procedure TfrmMain.mnuSaveClick(Sender: TObject);
var
     fOut : file of byte ;
     wByte : byte ;
     wAddress : word ;
begin
     dlgSaveDialog.FileName := '*.bin' ;
     dlgSaveDialog.Title := 'Save Memory Image' ;
     if (dlgSaveDialog.Execute) then begin
         AssignFile(fOut,dlgSaveDialog.FileName) ;
         ReWrite(fOut) ;
         for wAddress := 0 to $ffff do begin
             wByte := Am1601.GetMemByte(wAddress) ;
             Write(fOut,wByte) ;
         end ;
         CloseFile(fOut) ;
     end ;

end;

procedure TfrmMain.mnuStartClick(Sender: TObject);
begin
//     tmrRun.Enabled := true ;
     RunCode := TRunCode.Create(false);
end;

procedure TfrmMain.tmrRunTimer(Sender: TObject);
begin
     Am1601.Emulate ;
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
     wKey : word ;
begin

     if      (Key=4112) then wKey := $FF00 + 71 // Home
     else if (Key=4115) then wKey := $FF00 + 72 // Up Arrow
     else if (Key=4114) then wKey := $FF00 + 75 // Left Arrow
     else if (Key=4116) then wKey := $FF00 + 77 // Right Arrow
     else if (Key=4113) then wKey := $FF00 + 79 // End
     else if (Key=4117) then wKey := $FF00 + 80 // Down Arrow
     else if (Key=4102) then wKey := $FF00 + 82 // Insert
     else if (Key=4103) then wKey := $FF00 + 83 // Delete
     else if (Key=4100) then wKey := $000D      // CR
     else if (Key=4099) then wKey := $0008      // BS
     else if (Key<128 ) then begin
          wKey := Key ;
          if not (ssShift in Shift) and (65<=wKey) and (wKey<=90) then begin
              wKey := wKey + $20 ;
          end ;
     end
     else wKey := 0 ;

     if (wKey<>0) then begin
         KBuf[KBufNext] := wKey ;
         KBufCount := KBufCount + 1 ;
         KBufNext := KBufNext + 1 ;
     end ;

end;


end.
