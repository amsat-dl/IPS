unit ufrmTemplate;

(*
          Am1601 Emulator - ufrmTemplate
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
  QStdCtrls;

type
  TfrmTemplate = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTemplate: TfrmTemplate;

implementation

{$R *.xfm}

uses

     INIFiles   ,
     umdlGlobal ;

procedure TfrmTemplate.FormClose (Sender: TObject;
  var Action: TCloseAction);

var
     pMemINIFile : TMemINIFile ;

begin

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             WriteInteger(Name,'Left',Left) ;
             WriteInteger(Name,'Top',Top) ;
             WriteInteger(Name,'Width',Width) ;
             WriteInteger(Name,'Height',Height) ;
             UpdateFile ; // Flush memory copy to disc
         end ;
     finally
         pMemINIFile.Free ;
     end ;

     Action := caFree ;

end;

procedure TfrmTemplate.FormCreate(Sender: TObject);

var
     pMemINIFile : TMemINIFile ;

begin

     pMemINIFile := TMemINIFile.Create(sINIFilename);

     try
         with pMemINIFile do begin
             Left := ReadInteger(Name,'Left',Left) ;
             Top := ReadInteger(Name,'Top',Top) ;
             Width := ReadInteger(Name,'Width',Width) ;
             Height := ReadInteger(Name,'Height',Height) ;
         end ;
     finally
         pMemINIFile.Free ;
     end ;

end;

end.
