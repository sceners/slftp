unit taskrace;

interface

uses SyncObjs, tasksunit, pazo;

type
     TPazoPlainTask = class(TTask) // no announce
       pazo_id: Cardinal;
       mainpazo: TPazo;
       ps1, ps2: TPazoSite;
       constructor Create(site1: string;site2: string; tipus: TTaskType; pazo: TPazo);
       destructor Destroy; override;
     end;
     TPazoTask = class(TPazoPlainTask) // announce
       constructor Create(site1: string;site2: string; tipus: TTaskType; pazo: TPazo);
       destructor Destroy; override;
     end;
     TPazoDirlistTask = class(TPazoTask)
       dir: string;
       pre: Boolean;
       cleanup: Boolean;
       constructor Create(site: string; pazo: TPazo; dir: string; pre: Boolean; cleanup: Boolean = False);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;
     TPazoMkdirTask = class(TPazoTask)
       dir: string;
       constructor Create(site: string; pazo: TPazo; dir: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;
     TPazoRaceTask = class(TPazoTask)
       dir: string;
       filename: string;
       dstevent: TEvent;
       destructor Destroy; override;
       constructor Create(site1: string;site2: string; pazo: TPazo; dir, filename: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses sitesunit, configunit, DateUtils, SysUtils, mystrings, DebugUnit, queueunit, irc, dirlist;

const section = 'taskrace';

{ TLoginTask }

constructor TPazoPlainTask.Create(site1: string;site2: string; tipus: TTaskType; pazo: TPazo);
begin
  // egy taszk letrehozasakor es felszabaditasakor a queue lock mindig aktiv
  mainpazo:= pazo; //FindPazoById(pazo_id);
  if mainpazo = nil then raise Exception.Create('Pazo not found');
  self.pazo_id:= mainpazo.pazo_id;
  mainpazo.lastTouch:= Now();

  ps1:= mainpazo.FindSite(site1);
  if ps1 = nil then raise Exception.Create('PazoSite1 not found');
  ps2:= nil;
  if site2 <> '' then
  begin
    ps2:= mainpazo.FindSite(site2);
    if ps2 = nil then raise Exception.Create('PazoSite2 not found');
  end;

  inherited Create(site1, site2, tipus);
end;

destructor TPazoPlainTask.Destroy;
begin
  if readyerror then mainpazo.readyerror:= True;

  inherited;
end;


constructor TPazoTask.Create(site1: string;site2: string; tipus: TTaskType; pazo: TPazo);
begin
  inherited Create(site1, site2, tipus, pazo);
  mainpazo.queuenumber.increase;
end;

destructor TPazoTask.Destroy;
begin
  mainpazo.queuenumber.Decrease;

  inherited;
end;



{ TPazoDirlistTask }

constructor TPazoDirlistTask.Create(site: string; pazo: TPazo; dir: string; pre: Boolean; cleanup: Boolean = False);
begin
  self.dir:= dir;
  self.cleanup:= cleanup;
  self.pre:= pre;
  inherited Create(site, '', tPazoDirlist, pazo);
end;

function TPazoDirlistTask.Execute(slot: Pointer): Boolean;
label ujra, folytatas;
var s: TSiteSlot;
    i: Integer;
    de: TDirListEntry;
    r: TPazoDirlistTask;
    d: TDirList;
    aktdir: string;
begin
  Result:= False;
  s:= slot;

  if mainpazo.stopped then
  begin
    readyerror:= True;
    exit;
  end;

  Debug(dpMessage, section, Name);

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

  queue_lock.Enter;
  // ha nem minket osztott ki a sors a globalis dirlist keszitesere akkor kilepunk
  if ((pre) and (mainpazo.dirlist <> nil) and (mainpazo.dirlist <> ps1.dirlist)) then
  begin
    ps1.CopyMainDirlist(dir);
    queue_lock.Leave;
    goto folytatas;
  end;

  // oke, innentol mi visszuk a dirlistet, tobbi presiteon nem dirlistelunk.
  if cleanup then
  begin
    d:= ps1.dirlist.FindDirlist(dir);
    if (d <> nil) then
      d.CleanToprocess;

  end;

  if ((pre) and (mainpazo.dirlist = nil)) then
    mainpazo.dirlist:= ps1.dirlist;
  queue_lock.Leave;


  // akkor kell tenylegesen dirlistelnunk, ha
  // nem presiteon vagyunk
  // VAGY
  // presiteon vagyunk ES nincs meg meg a global kess

//  if ((not cleanup) or ()) then
    if not s.Dirlist(MyIncludeTrailingSlash(ps1.maindir), MyIncludeTrailingSlash(mainpazo.rls.rlsname)+dir) then
    begin
      if s.status = ssDown then
        goto ujra;
      readyerror:= True; // <- nincs meg a dir...
      exit;
    end;


    queue_lock.Enter;
    ps1.ParseDirlist(dir, s.lastResponse);
    queue_lock.Leave;

folytatas:
  // subdirlistek addolasa
  queue_lock.Enter;
  d:= ps1.dirlist.FindDirlist(dir);
  if d <> nil then
  begin
    d.dirlistadded:= True;
    
    for i:= 0 to d.entries.Count -1 do
    begin
      de:= TDirlistEntry(d.entries[i]);
      if ((de.directory) and (not de.skiplisted) ) then
      begin
        if ((de.subdirlist <> nil) and (de.subdirlist.Complete) and (not cleanup)) then Continue; // kihagyjuk...
        if ((de.subdirlist <> nil) and (de.subdirlist.dirlistadded) and (not ps1.dirlist.mindenmehetujra)) then Continue;

      // tpazodirlisttask addolasa de.filename -mel bovitve dir-t
        aktdir:= dir;
        if aktdir <> '' then aktdir:= aktdir + '/';
        aktdir:= aktdir + de.filename;
        Debug(dpSpam, section, 'READD: subdirt ('+aktdir+') dirlisteljuk');
        AddTask(TPazoDirlistTask.Create(ps1.name, mainpazo, aktdir, pre, cleanup));
      end;
    end;
  end;

  // dirlist readd ha meg nem complete
  if ((not pre) and (d <> nil) and (not d.Complete)) then
  begin
    if (SecondsBetween(Now, d.LastChanged) < config.ReadInteger(section, 'newdir_max_unchanged', 60)) then
    begin
      Debug(dpSpam, section, 'READD: megismeteljuk dirlistet '+ps1.name+'-n mert meg nem complete, lastchange: '+DateTimeToStr(ps1.dirlist.LastChanged));
      r:= TPazoDirlistTask.Create(ps1.name, mainpazo, dir, pre);
      r.startat:=  IncMilliSecond(Now(), config.ReadInteger(section, 'newdir_dirlist_readd', 1000));
      AddTask(r);
    end else
    begin
      if not d.giveup then
      begin
        irc_addtext(mainpazo.rls.rlsname+'/'+dir+'@'+s.Name+' is still incomplete, giving up');
        d.giveup:= True;
      end;
      if dir <> '' then
        AddTask(TPazoDirlistTask.Create(ps1.name, mainpazo, '', pre));
    end;
  end;

  if ps1.dirlist.mindenmehetujra then
    ps1.dirlist.mindenmehetujra:= False;

  // uj dirlist addolasa a fodirbe ha a subdir complete
  if ((not pre) and (dir <> '')) then
  begin
    if ((d <> nil) and (d.Complete)) then
    begin
      Debug(dpSpam, section, 'READD: fodirbe rakunk dirlistet mert subdir ('+dir+') complete');
      ps1.dirlist.mindenmehetujra:= True;
      AddTask(TPazoDirlistTask.Create(ps1.name, mainpazo, '', pre));
    end;
  end;


  queueDebug;

  queue_lock.Leave;

  Result:= True;
  ready:= True;
end;

function TPazoDirlistTask.Name: string;
begin
  Result:= 'PDIRLIST '+dir+' '+IntToStr(pazo_id)+ScheduleText;
end;


{ TPazoDirlistTask }

constructor TPazoMkdirTask.Create(site: string; pazo: TPazo; dir: string);
begin
  self.dir:= dir;
  inherited Create(site, '', tPazoMkdir, pazo);
end;

function TPazoMkdirTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
    aktdir: string;
begin
  Result:= False;
  s:= slot;

  if mainpazo.stopped then
  begin
    readyerror:= True;
    exit;
  end;

  Debug(dpMessage, section, Name);
  
ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;


  aktdir:= MyIncludeTrailingSlash(mainpazo.rls.rlsname) + dir;
  if not s.Mkdir(MyIncludeTrailingSlash(ps1.maindir), aktdir) then goto ujra;

  if s.lastResponseCode <> 257 then
  begin
    if 0 = Pos('exists', s.lastResponse) then
    begin
      irc.Announce(section, True, '%s: %s', [s.Name, s.lastResponse]);
      readyerror:= True;
      exit;
    end;
  end;

  queue_lock.Enter;
  ps1.MkdirReady(dir);
  queue_lock.Leave;

  Result:= True;
  ready:= True;
end;

function TPazoMkdirTask.Name: string;
begin
  Result:= 'PMKDIR '+IntToStr(pazo_id)+' '+dir;
end;



{ TPazoRaceTask }

constructor TPazoRaceTask.Create(site1, site2: string; pazo: TPazo;
  dir, filename: string);
begin
  inherited Create(site1, site2, tPazoRace, pazo);
  self.dir:= dir;
  self.filename:= filename;
  dstevent:= TEvent.Create(nil, False, False, Name);
end;

destructor TPazoRaceTask.Destroy;
begin
  dstevent.Free;
  inherited;
end;

function TPazoRaceTask.Execute(slot: Pointer): Boolean;
label ujra;
var ssrc, sdst: TSiteSlot;
    kellssl: Boolean;
    host: string;
    port: Integer;
    byme: Boolean;
    rss, rsd: TReadStatus;
    numerrors: Integer;
    d: TDirlist;
    de: TDirlistEntry;
begin
  Result:= False;
  ssrc:= slot1;
  sdst:= slot2;
  numerrors:= 0;

  if mainpazo.stopped then
  begin
    if slot <> sdst then
      dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;

  Debug(dpMessage, section, Name);

  if slot = sdst then
  begin
    // a dst szal itt varakozik vegig
    dstevent.WaitFor($FFFFFFFF);
    Result:= True;
    exit;
  end;

ujra:
  inc(numerrors);
  if numerrors > 3 then
  begin
    if ssrc.status <> ssOnline then
      ssrc.DestroySocket(True);
    if sdst.status <> ssOnline then
      sdst.DestroySocket(True);

    dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;

  if ssrc.status <> ssOnline then
    if not ssrc.ReLogin then
    begin
      dstevent.SetEvent;
      readyerror:= True;
      exit;
    end;
  if sdst.status <> ssOnline then
    if not sdst.ReLogin then
    begin
      dstevent.SetEvent;
      readyerror:= True;
      exit;
    end;

  if not ssrc.Cwd(MyIncludeTrailingSlash(ps1.maindir) + MyIncludeTrailingSlash(mainpazo.rls.rlsname) + dir) then
    if ssrc.Status = ssDown then
       goto ujra;
  if not sdst.Cwd(MyIncludeTrailingSlash(ps2.maindir) + MyIncludeTrailingSlash(mainpazo.rls.rlsname) + dir) then
    if sdst.status = ssDown then
      goto ujra;

  if ((ssrc.site.sslfxp = srNeeded) and (sdst.site.sslfxp = srUnsupported)) then
  begin
    Debug(dpMessage, section, 'SSLFXP on site %s is not supported', [sdst.site.name]);
    dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;
  if ((ssrc.site.sslfxp = srUnsupported) and (sdst.site.sslfxp = srNeeded)) then
  begin
    Debug(dpMessage, section, 'SSLFXP on site %s is not supported', [ssrc.site.name]);
    dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;

  if ((ssrc.site.sslfxp = srNeeded) or (sdst.site.sslfxp = srNeeded)) then
  begin
    kellssl:= True;
    if not ssrc.SendProtP() then goto ujra;
    if not sdst.SendProtP() then goto ujra;
  end else
  begin
    kellssl:= False;
    if not ssrc.SendProtC() then goto ujra;
    if not sdst.SendProtC() then goto ujra;
  end;

  if (TSiteSw(ssrc.RCInteger('sw', 0)) = sswDrftpd) then
  begin
    if not ssrc.Send('PRET RETR %s', [filename]) then goto ujra;
    if not ssrc.Read then goto ujra;
  end;

	if (kellssl) then
  begin
    if not ssrc.Send('CPSV') then goto ujra;
  end
	else
  begin
    if not ssrc.Send('PASV') then goto ujra;
  end;
	if not ssrc.Read() then goto ujra;

  if ssrc.lastResponseCode <> 227 then
  begin
      if ((kellssl) and (ssrc.lastResponseCode = 500) and (0 < Pos('understood', ssrc.lastResponse))) then
        ssrc.site.sslfxp:= srUnsupported;

    dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;

  ParsePasvString(ssrc.lastResponse, host, port);


  if (TSiteSw(sdst.RCInteger('sw', 0)) = sswDrftpd) then
  begin
    if not ssrc.Send('PRET STOR %s', [filename]) then goto ujra;
    if not ssrc.Read then goto ujra;
  end;

  if not sdst.Send('PORT %s,%d,%d',[Csere(host,'.',','), port div 256, port mod 256]) then goto ujra;
  if not sdst.Read() then goto ujra;

  if not sdst.Send('STOR %s', [filename]) then goto ujra;
  if not sdst.Read() then goto ujra;

  if sdst.lastResponseCode <> 150 then
  begin

    if ((sdst.lastResponseCode = 427) and (0 < Pos('Use SSL FXP', sdst.lastResponse))) then
    begin
      sdst.site.sslfxp:= srNeeded;
      goto ujra;
    end;

    if ((sdst.lastResponseCode = 553) and (0 < Pos('out of disk space', sdst.lastResponse))) then
      sdst.site.Setoutofspace;


    dstevent.SetEvent;
    queue_lock.Enter;
    if (sdst.lastResponseCode = 550) then (* drftpd *)
    begin
      ps2.ParseDupe(dir, filename, False);
      ready:= True;
    end
    else
    if (sdst.lastResponseCode = 553) then
    begin
      ps2.ParseXdupe(dir, sdst.lastResponse);
      ps2.ParseDupe(dir, filename, False);
      ready:= True;
    end
    else
      readyerror:= True;
    queue_lock.Leave;

    exit;
  end;


  if not ssrc.Send('RETR %s', [filename]) then goto ujra;
  if not ssrc.Read() then
  begin
    // szopo van, a dst szal ugyanis meg dolgozik meg minden. lezarjuk a picsaba aztan ujra login lesz.
    sdst.DestroySocket(False);

    goto ujra;
  end;

  if ssrc.lastResponseCode <> 150 then
  begin

    if ((ssrc.lastResponseCode = 550) and (0 < Pos('credit', LowerCase(ssrc.lastResponse)))) then
      ssrc.site.SetKredits
    else
    if ((ssrc.lastResponseCode = 427) and (0 < Pos('Use SSL FXP', ssrc.lastResponse))) then
    begin
      ssrc.site.sslfxp:= srNeeded;


      // ilyenkor olvasni kell egyet desten
      if not sdst.Read() then goto ujra;

      // es kettot az src-n
      if not ssrc.Read() then goto ujra;
      if not ssrc.Read() then goto ujra;

      goto ujra;
    end
    else
    if ((ssrc.lastResponseCode = 553) and (0 < Pos('You have reached your maximum simultaneous downloads allowed', ssrc.lastResponse))) then
    begin
      irc.Announce(section, True, '%s: %s', [ssrc.site.name, ssrc.lastResponse]);
      if ssrc.site.max_dn > 1 then
        ssrc.site.max_dn:= ssrc.site.max_dn - 1;
    end else
      irc.Announce(section, True, '%s: %s', [ssrc.site.name, ssrc.lastResponse]);

    // ilyenkor a dst szalon a legjobb ha lezarjuk a geci a socketet mert az ABOR meg a sok szar amugy sem hasznalhato.
    // es majd ugyis automatan ujrabejelentkezik a cumo
    sdst.DestroySocket(False);

    dstevent.SetEvent;
    readyerror:= True;
    exit;
  end;


    queue_lock.Enter;
    RemoveDependencies(self);
    RemovePazoDeps(self);
    QueueFire;
    queue_lock.Leave;

    rss:= rsTimeout;
    rsd:= rsTimeout;
    while (true) do
    begin
      if rsd = rsTimeout then
        rsd:= sdst.ReadB(False, True, 100);
      if rsd = rsException then
      begin
        ssrc.DestroySocket(False);
        goto ujra;
      end;

      if rss = rsTimeout then
        rss:= ssrc.ReadB(False, True, 100);
      if rss = rsException then
      begin
        sdst.DestroySocket(False);
        goto ujra;
      end;

      if ((rsd = rsRead) and (rss = rsRead)) then Break;
    end;

    if (ssrc.lastResponseCode <> 226) then
      irc.Announce(section, True, '%s: %s', [ssrc.name, Trim(ssrc.lastresponse)]);
    if (sdst.lastResponseCode <> 226) then
      irc.Announce(section, True, '%s: %s', [sdst.name, Trim(sdst.lastresponse)]);

    if (
        (sdst.lastResponseCode = 452)
        and
        (
         (0 < Pos('Error writing file: Success', sdst.lastResponse))
         or
         (0 < Pos('Error writing file: No space left on device', sdst.lastResponse))
        )
       ) then
    begin
      sdst.site.SetOutofSpace;
      sdst.DestroySocket(true);
    end;

    byme:= False;
    if (ssrc.lastResponseCode = 226) and (sdst.lastResponseCode = 226) then
      byme:= True;


  queue_lock.Enter;
  if ((byme) and (0 < Pos('CRC-Check: SFV first', sdst.lastResponse))) then
  begin
    // ez egy nagyon elbaszott eset. ilyenkor megprobaljuk majd ujra.
    if ps1.dirlist <> nil then
    begin
      d:= ps1.dirlist.FindDirlist(dir);
      if d <> nil then
      begin
        de:= d.Find(filename);
        if de <> nil then
          de.toprocess:= True; // ezt majd ujra
      end;
    end;
  end else
    ps2.ParseDupe(dir, filename, byme); // ezt regen readyracenek hivtuk, de ossze lett vonva parsedupe-pal
  dstevent.SetEvent;
  queue_lock.Leave;

  debug(dpMessage, section, 'READY %s', [name]);

  Result:= True;
  if byme then
    ready:= True
  else
    readyerror:= True;
end;

function TPazoRaceTask.Name: string;
begin
  Result:= Format('RACE '+IntToStr(pazo_id)+' %s->%s: %s',[site1, site2, filename]);
end;

end.
