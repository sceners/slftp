unit taskquit;

interface

uses tasksunit;

type TQuitTask = class(TTask)
       constructor Create(site: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, SysUtils, DebugUnit;

{ TLoginTask }

const section = 'quit';

constructor TQuitTask.Create;
begin
  inherited Create(site, tQuit);
end;

function TQuitTask.Execute(slot: Pointer): Boolean;
var s: TSiteSlot;
begin
  Result:= False;

  s:= slot;
  Debug(dpMessage, section, Name);

  s.Quit;
  ready:= True;
end;

function TQuitTask.Name: string;
begin
  Result:= 'QUIT '+site1;
end;

end.

