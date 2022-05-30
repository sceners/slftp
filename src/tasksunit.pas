unit tasksunit;

interface

uses Classes;

{ TTask }
type
  TTaskType = (tLogin, tQuit, tIdle, tRaw, tDel, ttDirlist, tLame, tCWD, tPazoDirlist, tPazoMkdir, tPazoRace, tAutoDirlist, tPazoGenreDirlist, tPazoGenreNfo);

  // ez az ose az osszes feladatnak
  TTask = class
  public
    site1: string;
    slot1: Pointer;
    slot1name: string;
    site2: string;
    slot2: Pointer;
    slot2name: string;

    dontremove: Boolean;
    wantedslot: string;

    created: TDateTime;// ez ugyanaz mint az added
    startat: TDateTime;// ennel elobb nem kezdodhet

    response: string;
    announce: string;

    taskType: TTaskType;
    ready: Boolean; // ready to free
    readyerror: Boolean;

    uid: Integer;
    ido: TDateTime;

    dependencies: TStringList;

    constructor Create(site1: string; taskType: TTaskType); overload;
    constructor Create(site1, site2: string; taskType: TTaskType); overload;
    destructor Destroy; override;



    function Execute(slot: Pointer): Boolean; virtual; abstract;

    // a slot parameter itt a calling slot
    function Name: string; virtual; abstract;
    function Fullname: string; virtual;
    function UidText: string;
    function ScheduleText: string;
    procedure DebugTask;
  end;


implementation

uses SysUtils, SyncObjs, debugunit;

resourcestring
  section = 'task';

var uidg: Integer = 1;
    uid_lock: TCriticalSection;

constructor TTask.Create(site1: string; taskType: TTaskType);
begin
  Create(site1, '', tasktype);
end;

constructor TTask.Create(site1, site2: string; taskType: TTaskType);
begin
  created:= Now();
  ido:= 0;
  readyerror:= False;
  response:= '';
  wantedslot:= '';
  slot1:= nil;
  slot2:= nil;
  self.site1:= site1;
  self.site2:= site2;
  ready:= False;
  startat:= 0;
  announce:= '';
  slot1name:= '';
  slot2name:= '';
  self.taskType:= taskType;
  dependencies:= TStringList.Create;

  uid_Lock.Enter;
  uid:= uidg;
  inc(uidg);
  uid_Lock.Leave;
end;



procedure TTask.DebugTask;
begin
  Debug(dpSpam, section, '%s (%s)', [Fullname, dependencies.DelimitedText]);
end;

destructor TTask.Destroy;
begin
  dependencies.Free;

  inherited;
end;

function TTask.Fullname: string;
begin
  Result:= UidText+' ' + site1 + ' ' + name;
end;

function TTask.ScheduleText: string;
begin
  Result:= '';
  if startat <> 0 then
    Result:= ' '+TimeToStr(startat);
end;

function TTask.UidText: string;
begin
  Result:= '#'+IntToStr(uid);
end;

procedure Tasks_Init;
begin
  uid_lock:= TCriticalSection.Create;
end;
procedure Tasks_Uninit;
begin
  uid_lock.Free;
end;

initialization
  Tasks_Init;
finalization
  Tasks_Uninit;
end.
