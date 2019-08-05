unit ufrmAbout;

(*
            Am1601 Emulator - ufrmAbout
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

*)

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, ufrmTemplate, QExtCtrls;

type
  TfrmAbout = class(TfrmTemplate)
    imgLogo: TImage;
    Label2: TLabel;
    lblVersion: TLabel;
    lblCopyright: TLabel;
    Memo1: TMemo;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.xfm}

uses

     umdlGlobal ;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
     inherited;
     lblVersion.Caption := 'Version: ' + GetVersionNumber ;
end;

procedure TfrmAbout.btnOKClick(Sender: TObject);
begin
     inherited;
     Close ;
end;

end.
