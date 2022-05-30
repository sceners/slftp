unit taskcwd;

interface

uses tasksunit;

type TCWDTask = class(TTask)
       dir: string;
       constructor Create(site, dir: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, SysUtils, mystrings, DebugUnit;

const section = 'cwd';
{ TLoginTask }

constructor TCWDTask.Create(site, dir: string);
begin
  self.dir:= dir;
  inherited Create(site, tCwd);
end;

function TCWDTask.Execute(slot: Pointer): Boolean;
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

  if not s.Cwd(dir, True) then goto ujra;
  if s.lastResponseCode = 250 then response:= Trim(s.lastResponse);

  ready:= True;
end;

function TCWDTask.Name: string;
begin
  Result:= 'CWD '+site1+' '+dir;
end;

end.

