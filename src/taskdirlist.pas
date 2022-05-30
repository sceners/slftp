unit taskdirlist;
interface

uses tasksunit;

type TDirlistTask = class(TTask)
       forcecwd: Boolean;
       dir: string;
       constructor Create(site: string; dir: string; forcecwd: Boolean = False);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, SysUtils, mystrings, DebugUnit;

const section = 'dirlist';

{ TLoginTask }

constructor TDirlistTask.Create(site: string; dir: string; forcecwd: Boolean = False);
begin
  self.dir:= dir;
  self.forcecwd:= forcecwd;
  inherited Create(site, ttDirlist);
end;

function TDirlistTask.Execute(slot: Pointer): Boolean;
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


  if (not s.Dirlist(dir, forcecwd)) then
  begin
    if s.status <> ssOnline then
      goto ujra;
    // ha nem megszakadtunk hanem nem letezik a dir...
    readyerror:= True;
    exit;
  end;
  response:= s.lastResponse;

  Result:= True;
  ready:= True;
end;

function TDirlistTask.Name: string;
begin
  Result:= 'DIRLIST '+site1+' '+dir;
end;

end.

