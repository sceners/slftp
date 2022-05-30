unit queueunit;

interface

uses Classes, Contnrs, tasksunit, SyncObjs;

procedure QueueFire;
procedure QueueStart;
procedure AddTask(t: TTask);
procedure QueueEmpty(sitename: string);
procedure RemovePazoDeps(t: TTask); overload;
procedure RemovePazoDeps(pazo_id: Cardinal; dstsite, dir, filename: string); overload;
procedure RemovePazo(pazo_id: Cardinal);
procedure RemoveDependencies(t: TTask);
procedure QueueDebug;

var
  queue_lock: TCriticalSection;
  tasks: TObjectList;
  queue_last_run: TDateTime;

implementation

uses SysUtils, irc, DateUtils, debugunit, sitesunit, taskidle, taskrace, taskquit, tasklogin, notify, console, kb, mainthread;

const section = 'queue';

type TQueueThread = class(TThread)
       procedure Execute; override;
  private
    procedure TryToAssignLoginSlot(t: TLoginTask);
    procedure TryToAssignSlots(t: TTask);
    procedure TryToAssignSlots2(t: TTask);
    procedure AddIdleTask(s: TSiteSlot);
    procedure AddQuitTask(s: TSiteSlot);
     end;

var
  queueevent: TEvent;
  queueth: TQueueThread;


procedure QueueFire;
begin
  queueevent.SetEvent;
end;


{ TMyQueue }



procedure QueueStart;
begin
  queueth.Resume;
end;

procedure TQueueThread.TryToAssignSlots2(t: TTask);
var s1, s2: TSite;
    i: Integer;
    ss1, ss2: TSiteSlot;
    sso: Boolean;
    num_dn, num_up: Integer;
begin
  s1:= FindSiteByName(t.site1);
  if s1 = nil then
  begin
    t.readyerror:= True;
    exit;
  end;
  s2:= FindSiteByName(t.site2);
  if s2 = nil then
  begin
    t.readyerror:= True;
    exit;
  end;

  ss1:= nil;
  sso:= False;
  num_dn:= 0;
  for i:= 0 to s1.slots.Count -1 do
  begin
    if TSiteSlot(s1.slots[i]).todotask = nil then //
    begin
      if not sso then
      begin
        ss1:= TSiteSlot(s1.slots[i]);
        if ss1.status = ssOnline then
          sso:= True;
      end;
    end;
    if TSiteSlot(s1.slots[i]).downloadingfrom then
      inc(num_dn); 
  end;
  if ss1 = nil then exit;
  if num_dn >= ss1.site.max_dn then exit;


  ss2:= nil;
  sso:= False;
  num_up:= 0;
  for i:= 0 to s2.slots.Count -1 do
  begin
    if TSiteSlot(s2.slots[i]).todotask = nil then //
    begin
      if not sso then
      begin
        ss2:= TSiteSlot(s2.slots[i]);
        if ss2.status = ssOnline then
          sso:= True;
      end;
    end;
    if TSiteSlot(s2.slots[i]).uploadingto then
      inc(num_up);
  end;
  if ss2 = nil then exit;
  if num_up >= ss2.site.max_up then exit;


  Debug(dpSpam, section, 'FOUND SLOTS FOR '+t.Name+': '+ss1.Name+' '+ss2.Name);
  t.slot1:= ss1;
  t.slot1name:= ss1.name;
  t.slot2:= ss2;
  t.slot2name:= ss2.name;
  ss1.downloadingfrom:= True;
  ss2.uploadingto:= True;
  ss1.todotask:= t;
  ss2.todotask:= t;
  ss2.Fire;
  ss1.Fire;
end;

procedure TQueueThread.TryToAssignLoginSlot(t: TLoginTask);
var s: TSite;
    i: Integer;
    ss: TSiteSlot;
    bnc: string;
begin
  ss:= nil;

    s:= FindSiteByName(t.site1);
    if s = nil then
    begin
      t.readyerror:= True;
      exit;
    end;

    bnc:= '';
    for i:= 0 to s.slots.Count -1 do
    begin
      ss:= TSiteSlot(s.slots[i]);
      bnc:= ss.bnc;
      if ((ss.todotask = nil) and (ss.Status <> ssOnline)) then //
        Break
      else
        ss:= nil;
    end;

    if ss = nil then
    begin
      // all slots are busy, which means they are already logged in, we can stop here
      if not t.noannounce then
        irc_Addtext(Format('%s IS ALREADY UP: %s', [Bold(t.site1), bnc]));
      t.ready:= True;
      exit;
    end;

  Debug(dpSpam, section, 'FOUND LOGINSLOT FOR '+t.Name+': '+ss.Name);
  t.slot1:= ss;
  t.slot1name:= ss.name;
  ss.todotask:= t;
  ss.Fire;
end;

procedure TQueueThread.TryToAssignSlots(t: TTask);
var s: TSite;
    i: Integer;
    ss: TSiteSlot;
    sso: Boolean;
begin
  if t.site2 <> '' then
  begin
    TryToAssignSlots2(t);
    exit;
  end;

  if t is TLoginTask then
  begin
    if not TLoginTask(t).readd then
    begin
      TryToAssignLoginSlot(TLoginTask(t));
      exit;
    end;
  end;

  ss:= nil;
  if t.wantedslot <> '' then
  begin
    ss:= FindSlotByName(t.wantedslot);
    if (ss = nil) then
    begin
      t.readyerror:= True;
      exit;
    end;


    if (ss.todotask <> nil) then
      exit;
  end;


  if ss = nil then
  begin
    s:= FindSiteByName(t.site1);
    if s = nil then
    begin
      t.readyerror:= True;
      exit;
    end;

    sso:= False;
    for i:= 0 to s.slots.Count -1 do
      if TSiteSlot(s.slots[i]).todotask = nil then //
      begin
        if not sso then
        begin
          ss:= TSiteSlot(s.slots[i]);
          if ss.status = ssOnline then
            sso:= True;
        end;
      end;

    if ss = nil then exit;
  end;

  Debug(dpSpam, section, 'FOUND SLOT FOR '+t.Name+': '+ss.Name);
  t.slot1:= ss;
  t.slot1name:= ss.name;
  ss.todotask:= t;
  ss.Fire;
end;

// EZT IS CSAK ZAROLVA SZABAD HIVNI
procedure QueueEmpty(sitename: string);
var i: Integer;
    t: TTask;
begin
  Debug(dpSpam, section, 'QueueEmpty '+sitename);
  for i:= 0 to tasks.Count -1 do
  begin
      t:= TTask(tasks[i]);

      if ((not t.ready) and (t.slot1 = nil) and (not t.dontremove) and ((t.site1 = sitename) or (t.site2 = sitename))) then
        t.readyerror:= True;
  end;
end;


procedure AddTask(t: TTask);
begin
  tasks.Add(t);
  Console_QueueStat(tasks.Count);
end;

procedure TQueueThread.AddQuitTask(s: TSiteSlot);
var q: TQuitTask;
begin
  q:= TQuitTask.Create(s.site.name);
  q.slot1:= s;
  q.slot1name:= s.name;
  s.todotask:= q;
  AddTask(q);
  s.Fire;
end;
procedure TQueueThread.AddIdleTask(s: TSiteSlot);
var i: TIdleTask;
begin
  i:= TIdleTask.Create(s.site.name);
  i.slot1:= s;
  i.slot1name:= s.name;
  s.todotask:= i;
  AddTask(i);
  s.Fire;
end;

procedure RemoveDependencies(t: TTask);
var i, j: integer;
    ta: TTask;
begin
  for i:= 0 to tasks.Count -1 do
  begin
    ta:= TTask(tasks[i]);
    while(true) do
    begin
      j:= ta.dependencies.IndexOf(t.UidText);
      if j = -1 then Break;

      ta.dependencies.Delete(j);

      if t.readyerror then
      begin
        // ilyenkor readyerrorra allitunk mindent ahol fugges van
        if (ta.slot1 = nil) then
          ta.readyerror:= True;
      end;
    end;
  end;
end;

procedure RemovePazo(pazo_id: Cardinal);
var i: Integer;
    p: TPazoTask;
begin
  for i:= 0 to tasks.Count -1 do
  begin
    if tasks[i] is TPazoTask then
    begin
      p:= TPazoTask(tasks[i]);
      if ((p.pazo_id = pazo_id) and (p.slot1 = nil)) then
        p.readyerror:= True; 
    end;
  end;
end;

procedure RemovePazoDeps(pazo_id: Cardinal; dstsite, dir, filename: string);
var i: Integer;
    tt: TTask;
    ttp: TPazoRaceTask;
begin
  for i:= 0 to tasks.Count -1 do
  begin
    tt:= TTask(tasks[i]);
    if (tt.ready = False) and (tt.readyerror = False) and (tt.taskType = tPazoRace) and (tt.slot1 = nil) then
    begin
      ttp:= TPazoRaceTask(tt);
      if ((ttp.pazo_id = pazo_id) and (ttp.slot1 = nil) and (ttp.site2 = dstsite) and (ttp.dir = dir) and (ttp.filename = filename)) then
         ttp.ready:= True;
    end;
  end;
end;

procedure QueueDebug;
var i: Integer;
begin
  if debug_verbose then
  begin
    for i:= 0 to tasks.Count -1 do
      TTask(tasks[i]).DebugTask;
  end;
end;

procedure RemovePazoDeps(t: TTask);
var
    tp: TPazoRaceTask;
begin
  if t.readyerror then exit;
  if t.taskType <> tPazoRace then exit;
  tp:= TPazoRaceTask(t);

  RemovePazoDeps(tp.pazo_id, tp.site2, tp.dir, tp.filename);
end;

procedure TQueueThread.Execute;
var i, j: Integer;
    t: TTask;
    s: TSiteSlot;
begin
  while ((not kilepes) and (not Terminated)) do
  begin
    queue_lock.Enter;
    queue_last_run:= Now();
    Debug(dpSpam, section, 'Queue Iteration begin');

    i:= 0;
    while i < tasks.Count do
    begin
      t:= TTask(tasks[i]);
      if (((t.ready) or (t.readyerror)) and (t.slot2 = nil)) then
      begin
        TaskReady(t);
        RemoveDependencies(t);
        RemovePazoDeps(t);
        tasks.Remove(t);
        Console_QueueStat(tasks.Count);
        Continue;
      end;

      // fuggoseg kereses
      if (t.slot1 = nil) then
        if ((t.startat = 0) or (t.startat <= queue_last_run)) then
          if (t.dependencies.Count = 0) then// nem fuggunk mar semmitol senkitol es semmitol
            TryToAssignSlots(t);

      inc(i);
    end;

    // keresunk idletennivalot a slotjainknak
    for i:= 0 to sites.Count-1 do
    begin
      for j:= 0 to TSite(sites[i]).slots.Count -1 do
      begin
        s:= TSiteSlot(TSite(sites[i]).slots[j]);
        if ((s.todotask = nil) and (s.status = ssOnline)) then
        begin
          if ((s.site.maxidle <> 0) and (MilliSecondsBetween(queue_last_run, s.lastactivity) >= s.site.maxidle * 1000)) then
            AddQuitTask(s)
          else if (MilliSecondsBetween(queue_last_run, s.lastio) > s.site.idleinterval * 1000) then
            AddIdleTask(s);
        end;
      end;
    end;

    Debug(dpSpam, section, 'Queue Iteration end');

    queue_lock.Leave;

    queueevent.WaitFor($FFFFFFFF);
  end;
end;

procedure QueueInit;
begin
  tasks:= TObjectList.Create;
  queue_lock:= TCriticalSection.Create;
  queueevent:= TEvent.Create(nil, False, False, 'queue');
  queueth:= TQueueThread.Create(True);
  queueth.FreeOnTerminate:= True;
  queue_last_run:= Now;
end;

procedure QueueUninit;
begin
  if tasks <> nil then
  begin
    tasks.Free;
    tasks:= nil;
  end;
  kb_FreeList;

  queue_lock.Free;
  queueevent.Free;
end;

initialization
  QueueInit;
finalization
  QueueUninit;
end.
