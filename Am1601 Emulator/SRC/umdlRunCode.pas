unit umdlRunCode;

interface

uses
  Classes;

type
  TRunCode = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure NextStep ;
  end;


var

   RunCode : TRunCode ;
   IsRunning : boolean  ;

implementation

uses

     umdlAm1601em ;

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure RunCode.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ RunCode }

procedure TRunCode.Execute;
var ii : integer ;
begin
     Priority := tpLower ;
     IsRunning := true ;
     repeat
         Synchronize(NextStep) ;
     until (Terminated) or (Am1601.GetBreakPoint(Am1601.REG_PC))
     or (Am1601.GetBreakPoint(Am1601.REG_HP))
     or (Am1601.GetBreakPoint(Am1601.REG_PPC)) ;
     IsRunning := false ;
end;

procedure TRunCode.NextStep;
begin
     Am1601.Emulate ;
end;

end.
