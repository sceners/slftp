unit taskgenredirlist;

interface

uses pazo, taskrace;

type
  TPazoGenreDirlistTask = class(TPazoPlainTask)
  private
    attempt: Integer;
    function FetchGenre(filename: string): string;
  public
    constructor Create(site: string; pazo: TPazo; attempt: Integer);
    function Execute(slot: Pointer): Boolean; override;
    function Name: string; override;
  end;

implementation

uses SysUtils, StrUtils, kb, debugunit, dateutils, queueunit, tags, configunit, tasksunit, dirlist, mystrings, sitesunit;

resourcestring
  section = 'taskgenredirlist';

{ TPazoGenreDirlistTask }

constructor TPazoGenreDirlistTask.Create(site: string; pazo: TPazo; attempt: Integer);
begin
  self.attempt:= attempt;
  inherited Create(site, '', tPazoGenreDirlist, pazo);
end;

function TPazoGenreDirlistTask.FetchGenre(filename: string): string;
var i: Integer;
begin
  Result:= '';
  for i:= 0 to mp3genres.Count-1 do
    if AnsiContainsText(filename, mp3genres[i]) then
    begin
      Result:= mp3genres[i];
      exit;
    end;
end;

function TPazoGenreDirlistTask.Execute(slot: Pointer): Boolean;
label ujra, folytatas;
var s: TSiteSlot;
    i, j: Integer;
    de: TDirListEntry;
    r: TPazoGenreDirlistTask;
    d: TDirList;
    event, tagfile, genre: string;
begin
  Result:= False;
  s:= slot;

  if mainpazo.stopped then
  begin
    readyerror:= True;
    exit;
  end;

  Debug(dpMessage, section, Name);

  queue_lock.Enter;
  if (mainpazo.rls is TMP3Release) then
  begin
    if (TMP3Release(mainpazo.rls).mp3genre <> '') then
    begin
      queue_lock.Leave;
      Result:= True;
      ready:= True;
      exit;
    end;
  end; // else mas nem nagyon lehet...
  queue_lock.Leave;


ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

    if not s.Dirlist(MyIncludeTrailingSlash(ps1.maindir), MyIncludeTrailingSlash(mainpazo.rls.rlsname)) then
    begin
      if s.status = ssDown then
        goto ujra;
      readyerror:= True; // <- nincs meg a dir...
      exit;
    end;


    j:= 0;
    tagfile:= '';
    d:= TDirlist.Create(nil, nil, s.lastResponse);
    for i:= 0 to d.entries.Count-1 do
    begin
      de:= TDirlistEntry(d.entries[i]);
      if ((de.Directory) or (de.filesize = 0)) then
      begin
        j:= TagComplete(de.filenamelc);
        if j <> 0 then
          tagfile:= de.filename;
        if j = 1 then
          Break;
      end;
    end;

  queue_lock.Enter;
  genre:= FetchGenre(tagfile);
  if ((j = 0) or (genre = '')) then
  begin
    if attempt < config.readInteger(section, 'readd_attempts', 5) then
    begin
      Debug(dpSpam, section, 'READD: nincs meg a complete tag vagy nincs meg a genre...');

      r:= TPazoGenreDirlistTask.Create(ps1.name, mainpazo, attempt+1);
      r.startat:= IncSecond(Now, config.ReadInteger(section, 'readd_interval', 60));
      AddTask(r);
    end else
      Debug(dpSpam, section, 'READD: nincs tobb readd...');
  end else
  begin
    if j = -1 then event:= 'NEWDIR' else event:= 'COMPLETE';
    kb_add(ps1.name, mainpazo.rls.section, genre, event, mainpazo.rls.rlsname, '');
  end;

  queue_lock.Leave;

  Result:= True;
  ready:= True;
end;

function TPazoGenreDirlistTask.Name: string;
begin
  Result:= 'PGENREDIRLIST '+IntToStr(pazo_id)+' '+mainpazo.rls.rlsname;
end;

end.
