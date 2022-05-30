unit taskidle;

interface
     
uses tasksunit;

type TIdleTask = class(TTask)
       constructor Create(site: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, SysUtils, mystrings, DebugUnit;

const section = 'idle';
  idlecommands: array[0..4] of string = (
    'REST 0',
    'SITE NEW 20',
    'SITE NEW 10',
    'STAT -l',
    'SITE ALDN'
  );

{ TLoginTask }

constructor TIdleTask.Create(site: string);
begin
  inherited Create(site, tIdle);
end;

function TIdleTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
    c: string;
begin
  Result:= False;
  s:= slot;
  debugunit.Debug(dpMessage, section, Name);

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

  c:= idlecommands[myRand(Low(idlecommands), High(idlecommands))];

  if (not s.Send(c)) then goto ujra;
  if (not s.Read()) then goto ujra;

  ready:= True;
end;

function TIdleTask.Name: string;
begin
  Result:= 'IDLE '+site1;
end;

end.

