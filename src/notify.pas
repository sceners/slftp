unit notify;

// EZT AZ UNItOT A QUEUE_LOCK LEZARASA UTAN SZABAD CSAK HASZNALNI

interface

uses Classes, syncobjs, tasksunit, Contnrs;

type
  TSiteResponse  = class
    sitename: string;
    slotname: string;
    response: string;

    ido: TDateTime;

    constructor Create(sitename, slotname, response: string; ido: TDateTime);
  end;
  TTaskNotify = class
    event: TEvent;
    tasks: TList;
    tnno: Integer;

    responses: TObjectList;

    constructor Create;
    destructor Destroy; override;
  end;

procedure TaskReady(t: TTask);
function AddNotify: TTaskNotify;
procedure RemoveTN(tn: TTaskNotify);

implementation

uses SysUtils, irc;

const section = 'notify';

var tasknotifies: TObjectList;
    tnno: Integer;

function AddNotify: TTaskNotify;
begin
  Result:= TTaskNotify.Create;
  tasknotifies.Add(Result);
end;

procedure RemoveTN(tn: TTaskNotify);
begin
  tasknotifies.Remove(tn);
end;

constructor TTaskNotify.Create;
begin
  responses:= TObjectList.Create;
  tasks:= TList.Create;
  self.tnno:= tnno;
  event:= TEvent.Create(nil, False, False, 'taskno'+IntToStr(tnno));
  inc(tnno);
end;

destructor TTaskNotify.Destroy;
begin
  tasks.Free;
  event.Free;
  responses.Free;
  inherited;
end;

procedure NotifyInit;
begin
  tasknotifies:= TObjectList.Create;
  tnno:= 0;
end;
procedure NotifyUninit;
begin
  tasknotifies.Free;
end;

procedure TaskReady(t: TTask);
var i: integer;
    tn: TTaskNotify;
begin
 for i:= 0 to tasknotifies.Count-1 do
 begin
   tn:= TTaskNotify(tasknotifies[i]);
   if -1 <> tn.tasks.IndexOf(t) then
   begin
     tn.tasks.Remove(t);
     if (t.response <> '') then
       tn.responses.Add(TSiteResponse.Create(t.site1, t.slot1name, t.response, t.ido));


     if ((t.announce <> '') and (not t.readyerror)) then
       Announce(section, False, t.announce);

     if tn.tasks.Count = 0 then
       tn.event.SetEvent;
   end;
 end;
end;

{ TSiteResponse }

constructor TSiteResponse.Create(sitename, slotname, response: string; ido: TDateTime);
begin
  self.sitename:= sitename;
  self.slotname:= slotname;
  self.response:= response;
  self.ido:= ido;
end;

initialization
  NotifyInit;
finalization
  NotifyUninit;
end.
