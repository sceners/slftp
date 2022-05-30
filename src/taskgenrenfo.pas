unit taskgenrenfo;

interface

uses Classes, pazo, taskrace, idTCPClient;

type
  TPazoGenreNfoTask = class(TPazoPlainTask)
  private
    idTCP: TIdTCPClient;
    ss: TStringStream;
    attempt: Integer;
    function FetchGenre(text: string): string;
    function Konnekt(ct: Integer): string;
    function Olvass(t: Integer): string;
  public
    constructor Create(site: string; pazo: TPazo; attempt: Integer);
    destructor Destroy; override;
    function Execute(slot: Pointer): Boolean; override;
    function Name: string; override;
  end;

implementation

uses SysUtils, IdSSLOpenSSL, irc, StrUtils, kb, debugunit, dateutils, queueunit, tags, configunit, tasksunit, dirlist, mystrings, sitesunit;

resourcestring
  section = 'taskgenrenfo';

{ TPazoGenreDirlistTask }

constructor TPazoGenreNfoTask.Create(site: string; pazo: TPazo; attempt: Integer);
begin
  ss:= TStringStream.Create('');
  idTCP:= TIdTCPClient.Create(nil);
  SetupSocket(idTCP, True);
  self.attempt:= attempt;
  inherited Create(site, '', tPazoGenreNfo, pazo);
end;

function TPazoGenreNfoTask.FetchGenre(text: string): string;
var i: Integer;
    s: string;
begin
  Result:= '';
  i:= Pos('genre', LowerCase(text));
  if i = 0 then exit;

  Result:= Copy(text, i + 5, 100);
  for i:= 1 to length(Result) do
  begin
    if Result[i] in [#13,#10] then
    begin
      Result:= Copy(Result, 1, i-1);
      Break;
    end;
    if (not (Result[i] in ['a'..'z','A'..'Z'])) then
      Result[i]:= ' ';
  end;

  while(true) do
  begin
    s:= Csere(Result, '  ', ' ');
    if s = Result then Break;
    Result:= s;
  end;

  Result:= Trim(Result);
end;

function TPazoGenreNfoTask.Olvass(t: Integer): string;
begin
  Result:= '';
  try
    idTCP.ReadStream(ss, t, True);
  except on e: Exception do
    Result:= e.Message;
  end;
end;

function TPazoGenreNfoTask.Konnekt(ct: Integer): string;
begin
  Result:= '';
  try
    idTCP.Connect(ct*1000);
    with idTCP.IOHandler as TIdSSLIOHandlerSocket do
      PassThrough:= False;
  except on e: Exception do
    Result:= e.Message;
  end;
end;


function TPazoGenreNfoTask.Execute(slot: Pointer): Boolean;
label ujra, folytatas;
var s: TSiteSlot;
    i, j, k: Integer;
    de: TDirListEntry;
    r: TPazoGenreNfoTask;
    d: TDirList;
    es, event, nfofile, genre: string;
    host: string;
    port: Integer;
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
  if (mainpazo.rls is TNFORelease) then
  begin
    if (TNFORelease(mainpazo.rls).nfogenre <> '') then
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
    nfofile:= '';
    d:= TDirlist.Create(nil, nil, s.lastResponse);
    for i:= 0 to d.entries.Count-1 do
    begin
      de:= TDirlistEntry(d.entries[i]);
      if ((not de.Directory) and (de.Extension = '.nfo') and (de.filesize < 32768)) then // 32kb-nal nagyobb nfoja csak nincs senkinek
        nfofile:= de.filename;

      if ((de.Directory) or (de.filesize = 0)) then
      begin
        k:= TagComplete(de.filenamelc);
        if j = 0 then j:= k;
        if k = 1 then j:= k; 
      end;
    end;

  queue_lock.Enter;
  if (nfofile = '') then
  begin
    if attempt < config.readInteger(section, 'readd_attempts', 5) then
    begin
      Debug(dpSpam, section, 'READD: nincs meg az nfo file...');

      r:= TPazoGenreNfoTask.Create(ps1.name, mainpazo, attempt+1);
      r.startat:= IncSecond(Now, config.ReadInteger(section, 'readd_interval', 60));
      AddTask(r);
    end else
      Debug(dpSpam, section, 'READD: nincs tobb readd...');

    queue_lock.Leave;
    ready:= True;
    Result:= True;
    exit;
  end;
  queue_lock.Leave;


  // most fetchelnunk kell a fajlt...
  if not s.SendProtP then goto ujra;

    if not s.Send('PASV') then goto ujra;
    if not s.Read() then goto ujra;

    if (s.lastResponseCode <> 227) then
    begin
      irc.announce(section, True, Trim(s.lastResponse));
      response:= 'Couldnt use passive mode / '+nfofile;
      readyerror:= True;
      exit;
    end;
    ParsePasvString(s.lastResponse, host, port);
    if port = 0 then
    begin
        response:= 'Couldnt parse passive string / '+nfofile;
        readyerror:= True;
        exit;
    end;

      idTCP.Host:= host;
      idTCP.Port:= port;

      if not s.Send('REST 0') then goto ujra;
      if not s.Read() then goto ujra;

      if not s.Send('RETR %s', [nfofile]) then goto ujra;


      es:= Konnekt(s.site.connect_timeout);
      if es <> '' then
      begin
        response:= 'Couldnt connect to site ('+es+') / '+nfofile;
        readyerror:= True;
        exit;
      end;

      if not s.Read() then
      begin
        response:= 'Couldnt read response of site / '+nfofile;
        readyerror:= True;
        exit;
      end;

      es:= Olvass(s.site.io_timeout);
      if es <> '' then
      begin
        response:= 'Couldnt connect to site ('+es+') / '+nfofile;
        readyerror:= True;
        exit;
      end;

      if idTCP.Connected then
        idTCP.Disconnect;

      if not s.Read() then goto ujra;


  genre:= FetchGenre(ss.DataString);


  queue_lock.Enter; // kesz vagyunk!
  if j = 1 then event:= 'COMPLETE' else event:= 'NEWDIR';
  kb_add(ps1.name, mainpazo.rls.section, genre, event, mainpazo.rls.rlsname, '');
  queue_lock.Leave;

  Result:= True;
  ready:= True;
end;

function TPazoGenreNfoTask.Name: string;
begin
  Result:= 'PGENRENFO '+IntToStr(pazo_id);
end;

destructor TPazoGenreNfoTask.Destroy;
begin
  idTCP.Free;
  idTCP:= nil;
  ss.Free;
  inherited;
end;

end.
