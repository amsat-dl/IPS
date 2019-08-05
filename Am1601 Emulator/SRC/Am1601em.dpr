program Am1601em;

(*
                 Am1601 Emulator
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

uses
  QForms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  ufrmTemplate in 'ufrmTemplate.pas' {frmTemplate},
  umdlGlobal in 'umdlGlobal.pas',
  ufrmSplash in 'ufrmSplash.pas' {frmSplash},
  ufrmAbout in 'ufrmAbout.pas' {frmAbout},
  ufrmMemoryView in 'ufrmMemoryView.pas' {frmMemoryView},
  ufrmRegisterView in 'ufrmRegisterView.pas' {frmRegisterView},
  umdlStrings in 'umdlStrings.PAS',
  umdlRunCode in 'umdlRunCode.pas',
  umdlAm1601em in 'umdlAm1601em.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Am1601 Emulator';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
