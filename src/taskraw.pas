unit taskraw;
interface

uses tasksunit;

type TRawTask = class(TTask)
       cmd: string;
       dir: string;
       constructor Create(site: string; dir: string; cmd: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, SysUtils, mystrings, DebugUnit;

const section = 'raw';

{ TLoginTask }

constructor TRawTask.Create(site: string; dir: string; cmd: string);
begin
  self.cmd:= cmd;
  self.dir:= dir;
  inherited Create(site, tRaw);
end;

function TRawTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
begin
  Result:= False;
  s:= slot;
  Debug(dpMessage, section, Name);

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

  if dir <> '' then
    if (not s.Cwd(dir, true)) then goto ujra;

  if (not s.Send(cmd)) then goto ujra;
  if (not s.Read()) then goto ujra;
  ido:= Now();

  response:= s.lastResponse;


  Result:= True;
  ready:= True;
end;

function TRawTask.Name: string;
begin
  Result:= 'RAW '+site1+' '+cmd;
end;

end.

