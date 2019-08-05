UNIT umdlStrings ;

(*
           Am1601 Emulator - umdlStrings
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

     Version 1.0.0 - June  3, 2001
     Version 1.0.1 - June 14, 2001 - DVal added
     Version 1.0.2 - September 2, 2002 - Converted from Turbo Pascal to Delphi
                     Hex, HexW inserted from umdlGlobal
*)

interface

const

     _Hex : array[$0..$f] of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F') ;

function Upper(ss:string):string ;
function Left(ss:string;Len:byte):string ;
function Right(ss:string;Len:byte):string ;
function TrimL(ss:string):string ;
function TrimR(ss:string):string ;
function Trim(ss:string):string ;
procedure DecodeConfig(sLine:string;var sToken:string;var sValue:string) ;
function WVal(sValue:string):word ;
function BVal(sValue:string):byte ;
function DVal(sValue:string):double ;
function StoC(SValue:string):char ;
function Strng(cc:char;Len:byte):string ;
function WtoS(wValue:word):string ;
function WtopS(wValue:word;Len:byte):string ;

function Hex(wByte:byte):string ;
function HexW(wWord:word):string ;
function CheckHex(sHex:string):boolean ;
function HexToWord(sHex:string):word ;

implementation

{
     Return parameter string forced to upper case.
}

function Upper(ss:string):string ;
var
     Index : byte ;
begin
     for Index := 1 to Length(ss) do begin
         ss[Index] := UpCase(ss[Index]) ;
     end ;
     Upper := ss ;
end { Upper } ;

{
     Returns the left-most Len characters of the parameter
     string. If the parameter string length is less than
     Len, then it is returned unchanged.
}

function Left(ss:string;Len:byte):string ;
begin
     if (Length(ss)>Len) then begin
         SetLength(ss,Len) ;
     end ;
     Left := ss ;
end { Left } ;

{
     Returns the right-most Len characters of the parameter
     string. If the parameter string length is less than
     Len, then it is returned unchanged.
}

function Right(ss:string;Len:byte):string ;
var
     LenAct : byte ;
begin
     LenAct := Length(ss) ;
     if (Len<LenAct) then begin
         Delete(ss,1,LenAct-Len) ;
     end ;
     Right := ss ;
end { Right } ;

{
     Returns the parameter string, with all spaces to the left
     of the first non-space character removed.
}

function TrimL(ss:string):string ;
begin
     while (Length(ss)>0) and (ss[1]=' ') do begin
         Delete(ss,1,1) ;
     end ;
     TrimL := ss ;
end { TrimL } ;

{
     Returns the parameter string, with all spaces to the right
     of the last non-space character removed.
}

function TrimR(ss:string):string ;
var
     Len : byte ;
begin
     Len := Length(ss) ;
     while (Len>0) and (ss[Len]=' ') do begin
         Delete(ss,Len,1) ;
         Len := Length(ss) ;
     end ;
     TrimR := ss ;
end { TrimL } ;

{
     Returns the parameter string, with all spaces to the left
     of the first non-space character, and all spaces from the
     right of the last non-space character removed.
}

function Trim(ss:string):string ;
begin
     Trim := TrimR(TrimL(ss)) ;
end { Trim } ;

{
     Converts the parameter string to a WORD type, if the
     parameter string is prefixed with # then the number
     is treated as a Hex value. No error checking is done!
}

function WVal(sValue:string):word ;
var
     _WVAL : word    ;
     Index : word    ;
     Digit : byte    ;
     Code  : integer ;
begin
     _WVAL := $0000 ;
     if (sValue[1]='#') then begin
         Index := 2 ; { Skip # }
         while (Index<=Length(sValue)) do begin
             _WVAL := _WVAL shl 8 ;
             Digit := Ord(sValue[Index]) ;
             if (sValue[Index] in ['0'..'9']) then begin
                 _WVAL := _WVAL + Digit - Ord('0') ;
             end
             else if (sValue[Index] in ['A'..'F']) then begin
                 _WVAL := _WVAL + Digit - Ord('A') ;
             end ;
             Dec(Index) ;
         end ;
     end
     else begin
         Val(sValue,_WVAL,Code) ;
     end ;
     WVal := _WVAL ;
end { WVal } ;

{
     Converts the parameter string to a BYTE type, if the
     parameter string is prefixed with # then the number
     is treated as a Hex value. No error checking is done!
}

function BVal(sValue:string):byte ;
begin
     BVal := Lo(WVal(sValue)) ;
end { BVal } ;

{
     Converts the parameter string to a DOUBLE type.
     No error checking is done!
}

function DVal(sValue:string):double ;
VAR
     _DVAL : double  ;
     Code  : integer ;
begin
     Val(sValue,_DVAL,Code) ;
     DVal := _DVAL ;
end { DVal } ;


{
     This routine is used to split a line of the form:

     TOKEN STRING = VALUE STRING ' THIS IS A COMMENT

     into its component parts: sToken, and sValue

     Another including and after the ' character is considered
     to be a comment as is deleted.

     Double spaces are removed and the returned values are
     trimmed and changed to upper case.

     Used for reading configuration files!
}

procedure DecodeConfig(sLine:string;var sToken:string;var sValue:string) ;
var
     Index : word ;
begin

{
     Strip Comments !
}

     Index := Pos('''',sLine) ;
     while (Index<>0) do begin
         sLine := Left(sLine,Pred(Index)) ;
         Index := Pos('''',sLine) ;
     end ;

{
     Single Space
}

     sLine := Trim(sLine) + ' ' ;
     Index := Pos('  ',sLine) ;
     while (Index<>0) do begin
         Delete(sLine,Index,1) ;
         Index := Pos('  ',sLine) ;
     end ;

{
     Clear Outputs
}

     sToken := '' ;
     sValue := '' ;

{
     Split into components biased on =, and force to upper case!
}

     Index := Pos('=',sLine) ;

     if (Index<>0) then begin
         sToken := Upper(Trim(Left (sLine,Pred(Index)))) ;
         Delete(sLine,1,Index) ;
         sValue := Upper(Trim(sLine)) ;
     end
     else begin
         sToken := Upper(Trim(sLine)) ;
     end ;

end { DecodeConfig } ;

{
     This routine converts the first character of a string
     to the data type CHAR.
}

function StoC(SValue:string):char ;
begin
     StoC := sValue[1] ;
end { StoC } ;

{
     This routine returns a string of the character cc of length Len.
}

function Strng(cc:char;Len:byte):string ;
var
     ss : string ;
begin
     Fillchar(ss,SizeOf(ss),cc) ;
     SetLength(ss,Len) ;
     Strng := ss ;
end { Strng } ;

{
     This routine converts an unsigned number to a string
}

function WtoS(wValue:word):string ;
var
     ss : string ;
begin
     Str(wValue:5,ss) ;
     WtoS := Trim(ss) ;
end { WtoS } ;

{
     This routine converts an unsigned number to a string, padded with
     leading zeroes to length Len
}

function WtopS(wValue:word;Len:byte):string ;
begin
     WtopS := Right(Strng('0',Len)+WtoS(WValue),Len) ;
end { WtopS } ;

{
     Binary to Hex String Conversion Routines
}

function Hex(wByte:byte):string ;
begin
     Hex := _Hex[wByte shr 4] + _Hex[wByte and $0f] ;
end ;

function HexW(wWord:word):string ;
begin
     HexW := Hex(Hi(wWord)) + Hex(Lo(wWord)) ;
end ;

function CheckHex(sHex:string):boolean ;
var
     ii : byte ;
begin
     result := true ;
     sHex := Upper('0'+Trim(sHex)) ;
     for ii := 1 to Length(sHex) do begin
         if not (sHex[ii] in ['0'..'9','A'..'F']) then begin
            result := false ;
            Exit ;
         end ;
     end ;
end ;

function HexToWord(sHex:string):word ;
var
     ii : word ;
begin
     result := $0000 ;
     sHex := Upper('0'+Trim(sHex)) ;
     while (sHex<>'') do begin
         ii := 0 ;
         while (sHex<>'') and (_Hex[ii]<>sHex[1]) do begin
             Inc(ii) ;
         end ;
         result := result * 16 + ii ;
         Delete(sHex,1,1) ;
     end ;
end ;

end.

