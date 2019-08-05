unit ufrmMemoryView;

(*
         Am1601 Emulator - ufrmMemoryView
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
  QStdCtrls, ufrmTemplate, QExtCtrls, QTypes;

type
  TfrmMemoryView = class(TfrmTemplate)
    sbSlider: TScrollBar;
    imgDump: TImage;
    edtGo: TEdit;
    btnGo: TButton;
    edtEditByte: TEdit;
    btnSetByte: TButton;
    edtEditWord: TEdit;
    btnSetWord: TButton;
    tmrWait: TTimer;
    btnBreak: TButton;
    chkLockToPC: TCheckBox;
    imgMainView: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbSliderChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtGoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnGoClick(Sender: TObject);
    procedure imgDumpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtEditByteKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtEditWordKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnSetByteClick(Sender: TObject);
    procedure btnSetWordClick(Sender: TObject);
    procedure tmrWaitTimer(Sender: TObject);
    procedure btnBreakClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    pSelRect,pSelRect2 : array[0..4] of TPoint ;
    bAddrSelected : boolean ;
    wSelAddress : word ;
    FPageName: string;
     wLastHeight : integer  ;
    procedure SetPageName(const Value: string);
  public
    { Public declarations }
    procedure DispPage(wBase:word) ;
    procedure SelectAddress(wAddress:word) ;
    property PageName : string  read FPageName write SetPageName;
    procedure MemUpdate(wAddress:word) ;
  end;

var
  frmMemoryViewA: TfrmMemoryView;
  frmMemoryViewB: TfrmMemoryView;
  frmMemoryViewC: TfrmMemoryView;
  frmMemoryViewD: TfrmMemoryView;

implementation

{$R *.xfm}

uses

     ufrmMain,
     umdlStrings,
     umdlAm1601em,
     INIFiles,
     umdlGlobal,
     Math  ;

const

     kwWidth = 20 ;
     kwDepth = 14 ;

procedure TfrmMemoryView.FormClose(Sender: TObject;
  var Action: TCloseAction);

var
     pMemINIFile : TMemINIFile ;

begin

     inherited;

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             WriteInteger(PageName,'Left',Left) ;
             WriteInteger(PageName,'Top',Top) ;
             WriteInteger(PageName,'Width',Width) ;
             WriteInteger(PageName,'Height',Height) ;
             WriteBool(PageName,'Lock To PC',chkLockToPC.Checked) ;
             UpdateFile ; // Flush memory copy to disc
         end ;
     finally
         pMemINIFile.Free ;
     end ;

     Action := caFree ;

     case FPageName[Length(FPageName)] of
     'A' : frmMain.mnuMemoryView.Checked := false ;
     'B' : frmMain.mnuMemoryViewB.Checked := false ;
     'C' : frmMain.mnuMemoryViewC.Checked := false ;
     'D' : frmMain.mnuMemoryViewD.Checked := false ;
     end ;

end;

procedure TfrmMemoryView.sbSliderChange(Sender: TObject);
begin
     inherited;
     tmrWait.Enabled := false ;
     tmrWait.Interval := 100 ;
     tmrWait.Enabled := true ;
end;

procedure TfrmMemoryView.DispPage(wBase: word);
var
     wMem, wByte : word ;
     Y : integer ;
     pRect : TRect ;

procedure DispByte(wAddress:word) ;
var
     X, Y  : integer ;
     c     : char ;
     wByte : Byte ;
begin

     X := wAddress - wBase ;
     Y := X div 16 * kwDepth ;
     X := X mod 16 * kwWidth ;

     wByte := Am1601.GetMemByte(wAddress) ;

     if (Am1601.GetBreakPoint(wAddress)) then begin
         imgDump.Canvas.Font.Color := clRed ;
     end
     else begin
         imgDump.Canvas.Font.Color := clBlack ;
     end ;

     imgDump.Canvas.TextOut(kwWidth*2+X,kwDepth*1+Y,Hex(wByte)) ;

     c := Chr(wByte and $7f) ;
     if not (c in [' '..'~']) then begin
         c := '.' ;
     end ;

     imgDump.Canvas.TextOut(kwWidth*19+(X div 2),kwDepth+Y,c) ;

     imgDump.Canvas.Font.Color := clBlack ;

end ;

begin

     with imgDump.Canvas do begin

          imgDump.Width := imgMainView.Width ;
          imgDump.Height := imgMainView.Height ;

          with pRect do begin
               Left   := 0 ;
               Top    := 0 ;
               Right  := imgDump.Width ;
               Bottom := imgDump.Height ;
          end ;
          FillRect(pRect);

          Font.Style := [fsBold] ;
          TextOut(0,0,'Addr') ;

          for wMem := 0 to $f do begin
              TextOut(kwWidth*(2+wMem),0,Hex(wMem)) ;
              TextOut(kwWidth*(19)+(wMem)*kwWidth div 2 ,0,_Hex[wMem]) ;
          end ;

          wMem := wBase ;
          while (wMem<=wBase+$01ff) do begin
              Y := ((wMem - wBase) div 16 + 1)* kwDepth ;
              Font.Style := [fsBold] ;
              TextOut(0,Y,HexW(wMem)) ;
              Font.Style := [] ;
              for wByte := 0 to $f do begin
                  DispByte(wMem + wByte) ;
                  if ((wMem+wByte)=$ffff) then begin
                      Exit ;
                  end ;
              end ;
              wMem := wMem + 16 ;
          end ;

     end ;


end;

procedure TfrmMemoryView.FormCreate(Sender: TObject);
begin
     inherited ;
     imgDump.Canvas.Font.Size := 10 ;
     imgDump.Canvas.Font.Name := 'Courier' ;
     imgDump.Canvas.Brush.Color := clBackground ;
     imgDump.Canvas.Font.Color := clBlack ;
//     imgDump.Visible := false ;
     DispPage(sbSlider.Position*16) ;
     SelectAddress(0) ;
//     imgMainView.Picture := imgDump.Picture ;
 //  imgDump.Visible := true ;
end;

procedure TfrmMemoryView.edtGoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     inherited;
     btnGo.Enabled      := CheckHex(edtGo.Text) ;
     btnSetByte.Enabled := (btnGo.Enabled) and (CheckHex(edtEditByte.Text)) ;
     btnSetWord.Enabled := (btnGo.Enabled) and (CheckHex(edtEditWord.Text)) and (HexToWord(edtGo.Text) mod 2 = 0) ;

end;

procedure TfrmMemoryView.btnGoClick(Sender: TObject);
var
     sSafe : string ;
begin
     inherited;
     sSafe := edtGo.Text ;
//     imgDump.Visible := false ;
     sbSlider.Position := Min(HexToWord(sSafe) shr 4,sbSlider.Max) ;
     SelectAddress(HexToWord(sSafe)) ;
//     imgDump.Visible := true ;
end;

procedure TfrmMemoryView.imgDumpMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
     wBase, wAddress, wEnd : word ;
     XX,YY : integer ;
     pRect, pRect2 : TRect ;
begin

     inherited;

     wBase := sbSlider.Position * 16 ;

     wAddress := $0000 ;

     while (wAddress<$0200) do begin

         XX := wAddress ;
         YY := XX div 16 * kwDepth ;
         XX := XX mod 16 * kwWidth ;

         pRect.Left := kwWidth*1+XX ;
         pRect.Top := kwDepth*1+YY ;
         pRect.Right := kwWidth*3+XX+1 ;
         pRect.Bottom := kwDepth*2+YY+1 ;

         pRect2.Left := kwWidth*19+(wAddress mod 16)*(kwWidth div 2) ;
         pRect2.Top := kwDepth*1+YY ;
         pRect2.Right := kwWidth*19+(wAddress mod 16 +1)*(kwWidth div 2) + 1 ;
         pRect2.Bottom := kwDepth*2+YY+1 ;

         if ((pRect.Left<=X) and (X<=pRect.Right) and
            (pRect.Top<=Y) and (Y<=pRect.Bottom)) or
            ((pRect2.Left<=X) and (X<=pRect2.Right) and
            (pRect2.Top<=Y) and (Y<=pRect2.Bottom)) then begin
             wAddress := wAddress + wBase ;
//             imgDump.Visible := false ;
             SelectAddress(wAddress) ;
//             imgDump.Visible := true ;
//             imgMainView.Picture := imgDump.Picture ;
             Exit ;
         end ;

         Inc(wAddress) ;

     end ;

end;

procedure TfrmMemoryView.SelectAddress(wAddress: word);
var
     XX,YY : integer ;
     wBase : word ;
begin

     if (bAddrSelected) then begin
         imgDump.Canvas.Pen.Color := clBackground ;
         imgDump.Canvas.Polyline(pSelRect,0,-1);
         imgDump.Canvas.Polyline(pSelRect2,0,-1);
     end ;

     wBase := sbSlider.Position * 16 ;
     XX := wAddress - wBase ;
     YY := XX div 16 * kwDepth ;
     XX := XX mod 16 * kwWidth ;

     pSelRect[0].X := kwWidth*2+XX-3 ; pSelRect[0].Y := kwDepth*1+YY   ;
     pSelRect[1].X := kwWidth*2+XX-3 ; pSelRect[1].Y := kwDepth*2+YY+1 ;
     pSelRect[2].X := kwWidth*3+XX   ; pSelRect[2].Y := kwDepth*2+YY+1 ;
     pSelRect[3].X := kwWidth*3+XX   ; pSelRect[3].Y := kwDepth*1+YY   ;
     pSelRect[4].X := kwWidth*2+XX-3 ; pSelRect[4].Y := kwDepth*1+YY   ;

     pSelRect2[0].X := kwWidth*19+(wAddress mod 16)*(kwWidth div 2) -2 ;
     pSelRect2[0].Y := kwDepth*1+YY ;
     pSelRect2[1].X := kwWidth*19+(wAddress mod 16)*(kwWidth div 2) -2 ;
     pSelRect2[1].Y := kwDepth*2+YY+1 ;
     pSelRect2[2].X := kwWidth*19+(wAddress mod 16 +1)*(kwWidth div 2)  ;
     pSelRect2[2].Y := kwDepth*2+YY+1 ;
     pSelRect2[3].X := kwWidth*19+(wAddress mod 16 +1)*(kwWidth div 2)  ;
     pSelRect2[3].Y := kwDepth*1+YY ;
     pSelRect2[4].X := kwWidth*19+(wAddress mod 16)*(kwWidth div 2) -2 ;
     pSelRect2[4].Y := kwDepth*1+YY ;

     imgDump.Canvas.Pen.Color := clBlack ;
     imgDump.Canvas.Polyline(pSelRect,0,-1);
     imgDump.Canvas.Polyline(pSelRect2,0,-1);

     wBase := Am1601.GetMemWord(wAddress) ;
     edtGo.Text := HexW(wAddress) ;
     edtEditByte.Text := Hex(Lo(wBase)) ;
     edtEditWord.Text := HexW(wBase) ;

     btnGo.Enabled      := True ;
     btnSetByte.Enabled := True  ;
     btnSetWord.Enabled := (wAddress mod 2 = 0) ;

     wSelAddress := wAddress ;
     bAddrSelected := true ;
     imgMainView.Picture := imgDump.Picture ;

end;

procedure TfrmMemoryView.edtEditByteKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     inherited;
     btnSetByte.Enabled := CheckHex(edtEditByte.Text) and (btnGo.Enabled) ;
end;

procedure TfrmMemoryView.edtEditWordKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     inherited;
     btnSetWord.Enabled := CheckHex(edtEditWord.Text) and (btnGo.Enabled) ;
end;

procedure TfrmMemoryView.btnSetByteClick(Sender: TObject);
begin
     inherited;
     Am1601.SetMemByte(HexToWord(edtGo.Text),HexToWord(edtEditByte.Text));
     SelectAddress(HexToWord(edtGo.Text)) ;
end;

procedure TfrmMemoryView.btnSetWordClick(Sender: TObject);
begin
     inherited;
     Am1601.SetMemWord(HexToWord(edtGo.Text),HexToWord(edtEditWord.Text));
     SelectAddress(HexToWord(edtGo.Text)) ;
end;

procedure TfrmMemoryView.SetPageName(const Value: string);
var
     pMemINIFile : TMemINIFile ;

begin

     FPageName := Value;
     Caption := FPageName ;

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             Left := ReadInteger(FPageName,'Left',Left) ;
             Top := ReadInteger(FPageName,'Top',Top) ;
             Width := ReadInteger(FPageName,'Width',Width) ;
             Height := ReadInteger(FPageName,'Height',Height) ;
             chkLockToPC.Checked := ReadBool(FPageName,'Lock To PC',chkLockToPC.Checked) ;
         end ;
     finally
         pMemINIFile.Free ;
     end ;
end;

procedure TfrmMemoryView.tmrWaitTimer(Sender: TObject);
var
     wAddress : word ;
begin
     inherited;
     tmrWait.Enabled := false ;
//     imgDump.Visible := false ;
     if (wLastHeight<>Height - 45) then begin
         imgDump.Height := Height - 45 ;
         imgDump.Left := 8 ;
         wLastHeight := imgDump.Height ;
     end ;
     if (bAddrSelected) then begin
         imgDump.Canvas.Pen.Color := clBackground ;
         imgDump.Canvas.Polyline(pSelRect,0,-1);
         imgDump.Canvas.Polyline(pSelRect2,0,-1);
         bAddrSelected := false ;
     end ;
     wAddress := sbSlider.Position*16 ;
     edtGo.Text := HexW(wAddress) ;
     DispPage(wAddress) ;
     SelectAddress(wAddress) ;
//     imgDump.Visible := true ;

end;

procedure TfrmMemoryView.MemUpdate(wAddress: word);
var
     wBase : word ;
begin
     if (chkLockToPC.Checked) then begin
         sbSlider.Position := Am1601.REG_PC div 16 ;
         wBase := sbSlider.Position ;
     end
     else begin
         wBase := wAddress div 16 ;
     end ;
     if ((sbSlider.Position-32)<=wBase) and (wBase<=sbSlider.Position+32) then begin
         imgDump.Visible := false ;
         DispPage(sbSlider.Position * 16) ;
         SelectAddress(wSelAddress) ;
         imgDump.Visible := true ;
     end ;
     if (chkLockToPC.Checked) then begin
         wSelAddress := Am1601.REG_PC ;
         SelectAddress(wSelAddress) ;
     end ;
     tmrWait.Enabled := false ;
end;

procedure TfrmMemoryView.btnBreakClick(Sender: TObject);
begin
     inherited;
     Am1601.ToggleBreak(HexToWord(edtGo.Text));
end;

procedure TfrmMemoryView.FormResize(Sender: TObject);
begin
     inherited;
     imgMainView.Height := ((Height - 45) div kwDepth) * kwDepth ;
     sbSliderChange(Self) ;
end;

end.
