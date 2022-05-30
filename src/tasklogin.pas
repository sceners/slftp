unit tasklogin;

interface

uses tasksunit;

type TLoginTask = class(TTask)
     private
       kill: Boolean;
     public
       noannounce: Boolean;
       readd: Boolean; // autobnctest-hez...
       constructor Create(site: string; kill: Boolean; readd: Boolean);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, queueunit, dateutils, SysUtils, irc, debugunit;

const section = 'login';

{ TLoginTask }

constructor TLoginTask.Create(site: string; kill: Boolean; readd: Boolean);
begin
  self.kill:= kill;
  self.readd:= readd;
  inherited Create(site, tLogin);
end;

function TLoginTask.Execute(slot: Pointer): Boolean;
label vege;
var s: TSiteSlot;
    i: Integer;
    l: TLoginTask;

begin
  Result:= False;
  s:= slot;
  debugunit.Debug(dpMessage, section, Name);

  if readd then
  begin
    // megnezzuk, kell e meg a taszk
    if s.RCInteger('autobnctest', 0) = 0 then
    begin
      ready:= True;
      Result:= True;
      exit;
    end;
  end;

  if ((s.Status = ssOnline) and (readd)) then
  begin
    // nem teszteljuk ujra, csak orulunk neki
    goto vege;
  end;

  s.Quit;

  Result:= s.ReLogin(1, kill);

  if s.Status = ssOnline then
    announce:= Bold(s.site.name)+': '+s.bnc;

vege:
  if readd then
  begin
    // megnezzuk, kell e meg a taszk
    i:= s.RCInteger('autobnctest', 0);
    if i > 0 then
    begin
      queue_lock.Enter;
      l:= TLoginTask.Create(site1, kill, readd);
      l.startat:= IncSecond(Now, i);
      l.dontremove:= True;
      AddTask(l);
      queue_lock.Leave;
    end;
  end;

  ready:= True;
end;

function TLoginTask.Name: string;
begin
  Result:= '';
  if readd then Result:= 'AUTO';
  Result:= Result + 'LOGIN '+site1+ScheduleText;
end;

end.
