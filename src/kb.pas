unit kb;

interface

uses Classes, SyncObjs, Contnrs, encinifile;


type
  TKnownGroup = (grp_known, grp_unknown, grp_notconfigured);
  TRelease = class
    aktualizalva: Boolean;
    rlsname: string;
    rlsnamewogrp: string;
    section: string;
    words: TStringList;
    groupname: string;
    internal: Boolean;

    legnagyobbcd: Integer;
    sample: Boolean;
    covers: Boolean;
    subs: Boolean;

    fake: Boolean;
    fakereason: string;

    pretime: TDateTime;

    //fakecheckinghez
    dots: Integer;
    karakterszam: Integer;
    maganhangzok: Integer;

    knowngroup: TKnownGroup;

    constructor Create(rlsname, section: string); virtual;
    destructor Destroy; override;

    function ExtraInfo: string; virtual;

    function Aktualizald(extrainfo: string): Boolean; virtual;

    function AsText(pazo_id: Integer = -1): string; virtual;

    function Aktualizal(p: TObject): Boolean; virtual;
  end;
  TMP3Release = class(TRelease)
    mp3year: Integer;
    mp3lng: string;
    mp3genre: string;
    (*
    mp3source1: string;
    mp3source2: string;
    mp3source3: string;
    *)
    mp3source: string;
    mp3types1: string;
    mp3types2: string;
    mp3types3: string;

    mp3_number_of_cds: Integer;
    mp3_number_of_dvds: Integer;

    mp3_number_of: string;

    mp3_va: Boolean;


    function Bootleg: Boolean;
    constructor Create(rlsname, section: string); override;

    function ExtraInfo: string; override;

    function Aktualizald(extrainfo: string): Boolean; override;
    function AsText(pazo_id: Integer = -1): string;  override;
    function Numdisks: Integer;
    function Aktualizal(p: TObject): Boolean; override;
  private
    function Evszam(s: string): Boolean;
    procedure AddSource(src: string; var sources: Integer);
  end;
  TNFORelease = class(TRelease)
    nfogenre: string;
    function ExtraInfo: string; override;
    constructor Create(rlsname, section: string); override;
    function Aktualizald(extrainfo: string): Boolean; override;
    function AsText(pazo_id: Integer = -1): string;  override;
    function Aktualizal(p: TObject): Boolean; override;
  end;
  TCRelease = class of TRelease;

  TKBThread = class(TThread)
  public
    constructor Create;
    procedure Execute; override;
    destructor Destroy; override;
  end;



procedure kb_Pretime(sitename, section, rls: string; age: Integer);
function kb_Add(sitename, section, genre, event, rls, cdno: string; dontFire: Boolean = False; forceFire: Boolean = False; ts: TDateTime = 0): Integer;//forceRebuild: Boolean = False;
function FindSectionHandler(section: string): TCRelease;
procedure kb_FreeList;
procedure kb_Save;
procedure KB_start;

var sections: TStringList;
    mp3genres: TStringList;
    mp3languages: TStringList;
    mp3sources: TStringList;
    mp3types: TStringList;
    mp3livesources: TStringList;
    kb_list: THashedStringList;
    kb_thread: TKBThread;
    kb_last_saved: TDateTime;



implementation

uses debugunit, mainthread, taskgenrenfo, taskgenredirlist, configunit, tasklogin, taskrace, sitesunit, queueunit, pazo, irc, SysUtils, fake, mystrings, rulesunit, Math,
  DateUtils;

type
  TSectionRelease = record
    section: string;
    r: TCRelease;
  end;
  TSectionHandlers = array[0..4] of TSectionRelease;

resourcestring
  rsections = 'kb';

var
   sectionhandlers: TSectionHandlers = (
     (section: ''; r: TRelease),
     (section: 'PRE'; r: TMP3Release),
     (section: 'MP3'; r: TMP3Release),
     (section: 'MDVDR'; r: TNFORelease),
     (section: 'MV'; r: TNFORelease)
   );
    kb_eggyelkevesebb: THashedStringList;
    kb_announce: THashedStringList;

function FindSectionHandler(section: string): TCRelease;
var i: Integer;
begin
  Result:= sectionhandlers[0].r;
  for i:= 1 to High(sectionhandlers) do
    if (1 = Pos(sectionhandlers[i].section, section)) then
    begin
      Result:= sectionhandlers[i].r;
      exit;
    end;
end;

function kb_Add(sitename, section, genre, event, rls, cdno: string; dontFire: Boolean = False; forceFire: Boolean = False; ts: TDateTime = 0): Integer;//forceRebuild: Boolean = False;
var i: Integer;
    r: TRelease;
    rc: TCRelease;
    aktualizalva: Boolean;
    s: TSite;
    ss: string;
    added: Boolean;
    prevStatus: TRlsSiteStatus;
    p: TPazo;
    ps: TPazoSite;
    sources: TObjectList;
    x: TStringList;
    l: TLoginTask;
begin
  debug(dpSpam, rsections, '%s %s %s %s %s %s %d %d', [sitename, section, genre, event, rls, cdno, Integer(dontFire), Integer(forceFire)]);

  Result:= -1;
  i:= kb_eggyelkevesebb.IndexOf(section+'-'+rls);
  if i <> -1 then
  begin
    if -1 = kb_announce.IndexOf(sitename+'-'+section+'-'+rls) then
    begin
      kb_announce.Add(sitename+'-'+section+'-'+rls);
      irc_addtext(Format('%s @ %s is a trimmed shit!', [rls, sitename]));
    end;
    exit;
  end;

  aktualizalva:= False;
  i:= kb_list.IndexOf(section+'-'+rls);
  if i = -1 then
  begin
    // uj joveveny!
    kb_eggyelkevesebb.Add(section+'-'+Copy(rls, 1, Length(rls)-1));
    kb_eggyelkevesebb.Add(section+'-'+Copy(rls, 2, Length(rls)-1));
    rc:= FindSectionHandler(section);
    r:= rc.Create(rls, section);
    if genre <> '' then
      r.Aktualizald(genre);
    p:= PazoAdd(r);

    // meg kell keresni az osszes siteot ahol van ilyen section...
    added:= p.AddSites;

    if (ts <> 0) then
      p.autodirlist:= True; // kulso threadnek kell dirlistelnie vagy hasonlo
      
    kb_list.AddObject(section+'-'+rls, p);

    if added then
    begin
      // sorrendezes
      RulesOrder(p);

      aktualizalva:= True;
    end;
  end else
  begin
    // meg kell tudni mi valtozott
    p:= TPazo(kb_list.Objects[i]);
    r:= p.rls;
    if genre <> '' then
      aktualizalva:= p.rls.Aktualizald(genre);
  end;

  ps:= p.FindSite(sitename);
  if ps = nil then
  begin
    s:= FindSiteByName(sitename);
    if ((s <> nil) and (s.working = sstDown)) then
        AddTask(TLoginTask.Create(sitename, False, False));
    exit;
  end;

  if ts <> 0 then
    ps.ts:= ts;

  prevStatus:= ps.Status;
  if event = 'PRE' then
  begin
    s:= FindSiteByName(ps.name);
    if (s <> nil) then
      s.SetAffils(section, r.groupname, False);

    ps.Status:= rssRealPre;
  end
  else
  if event = 'COMPLETE' then
    ps.setcomplete(cdno)
  else
  if ps.status = rssNotAllowed then
    ps.status:= rssAllowed;

  if (prevStatus <> ps.Status) then
    aktualizalva:= True;

  ss:= p.StatusText;

    (* megse toroljuk
    // pazo siteslist-ben mindenhol torolni a sources dest listat
    for i:= 0 to p.sites.Count -1 do
    begin
      ps:= TPazoSite(p.sites[i]);
      ps.sources.Clear;
      ps.destinations.Clear;
    end;
    *)

    // implement firerules, routes, stb. set rs.srcsite:= rss.sitename;
    x:= TStringList.Create;
    ps:= p.FindSite(sitename);
    FireRules(p, ps, x); // eloszor az esemeny sitejan tuzelunk
    for i:= 0 to p.sites.Count -1 do
    begin
      ps:= TPazoSite(p.sites[i]);  // aztan mindenhol mashol
      FireRules(p, ps, x);
    end;
    x.Free;

  if p.StatusText <> ss then
    aktualizalva:= True;

  Result:= p.pazo_id;

  if dontFire then exit;

  if (aktualizalva) or (forceFire) then// or (forceRebuild)
  begin

    // a source siteokra rakunk dirlistet...
      sources:= p.Sources;
      if sources.Count = 0 then exit;
      for i:= 0 to p.sites.Count-1 do
      begin
        ps:= TPazoSite(p.sites[i]);

        if sources.IndexOf(ps) <> -1 then
        begin
          if ((ps.status <> rssRealPre) or (not ps.dirlistadded)) then
          begin
            AddTask(TPazoDirlistTask.Create(ps.name, p, '', ps.AllPre, True));
            ps.dirlistadded:= True;
          end;
        end
        else
        if (ps.AllPre) then
        begin
          s:= FindSiteByName(ps.name);
          if s.working <> sstDown then
          begin
            l:= TLoginTask.Create(ps.name, false, False);
            l.noannounce:= True;
            AddTask(l);
          end;
        end;
      end;
      QueueFire;
  end;
  Debug(dpSpam, rsections, p.AsText);
end;

procedure kb_Pretime(sitename, section, rls: string; age: Integer);
begin
// todo: implement
end;

{ TRelease }

function TRelease.Aktualizal(p: TObject): Boolean;
begin
  aktualizalva:= True;
  Result:= False;
end;

function TRelease.Aktualizald(extrainfo: string): Boolean;
begin
  aktualizalva:= False;
  Result:= False;
end;

function TRelease.AsText(pazo_id: Integer = -1): string;
begin
  Result:= Bold(rlsname);
  if pazo_id <> -1 then
    Result:= Result + ' ('+IntToStr(pazo_id)+')';
  Result:= Result + #13#10;

  Result:= Result + 'Knowngroup: ';
  if knowngroup = grp_known then
    Result:= Result + '1'
  else
  if knowngroup = grp_unknown then
    Result:= Result + '0';
  if knowngroup = grp_notconfigured then
    Result:= Result + '?';
  Result:= Result + #13#10;

  Result:= Result + 'Internal: '+ IntToStr(Integer(internal)) + #13#10;

end;

constructor TRelease.Create(rlsname, section: string);
var s: string;
    i: Integer;
begin
  aktualizalva:= False;
  words:= TStringList.Create;
  words.Delimiter:= ' ';
  words.CaseSensitive:= False;

  Self.section:= section;
  Self.rlsname:= rlsname;

  s:= Csere(rlsname, '(', '');
  s:= Csere(s, ')', '');
  s:= Csere(s, '.', ' ');
  s:= Csere(s, '-', ' ');
  s:= Csere(s, '_', ' ');
  words.DelimitedText:= s;


  Internal:= False;
  if words.Count > 1 then
  begin
    groupname:= words[words.Count-1];
    if (LowerCase(groupname) = 'int') then // fff_int
    begin
      groupname:= words[words.Count-2];
      Internal:= True;
    end else
    if (LowerCase(words[words.Count-2]) = 'int')then // -int-ddz
      Internal:= True
    else
    if (words.IndexOf('internal') >= words.Count - 3) then
      Internal:= True;
  end;

  dots:= 0;
  karakterszam:= 0;
  maganhangzok:= 0;
  s:= '';
  for i:= 1 to length(rlsname) do
  begin
    if 0 = Pos(rlsname[i], s) then
    begin
      inc(karakterszam);
      s:= s+ rlsname[i];
    end;
    if rlsname[i] = '.' then
      inc(dots);
    if (rlsname[i] in ['a','e','i','o','u','A','E','I','O','U']) then
      inc(maganhangzok);
  end;

  rlsnamewogrp:= Copy(rlsname, 1, Length(rlsname)-Length(groupname));

  if not fake then
    FakeCheck(self);
end;

destructor TRelease.Destroy;
begin
  words.Free;
  inherited;
end;



function TRelease.ExtraInfo: string;
begin
  Result:= '';
end;

{ TMP3Release }

function TMP3Release.Evszam(s: string): Boolean;
var i: Integer;
begin
  Result:= False;
  if (length(s) = 4) then
  begin
    i:= SzamokSzama(s);
    if (i = 4) then
    begin
      mp3Year := StrToInt(s);
      Result:= True;
    end
    else
    if ((i = 3) and ((s[4]= 'x')or(s[4]='X'))) then
    begin
      s[4] := '0';
      mp3Year := StrToInt(s);
      Result:= True;
    end;
  end;
end;

procedure TMP3Release.AddSource(src: string; var sources: Integer);
begin
        inc(sources);
        mp3source:= src;
        (*
        case sources of
          1: mp3source1:= src;
          2: mp3source2:= src;
          3: mp3source3:= src;
        end;*)
end;

constructor TMP3Release.Create(rlsname, section: string);
label ennyi;
var evszamindex, i: Integer;
    kezdoindex, szoindex, kotojelekszama: Integer;
    types, sources: Integer;
    j: Integer;
    s1, s2: string;
begin
  fake:= True;
  inherited Create(rlsname, section);
  aktualizalva:= False;

  if words.Count > 3 then
  begin
    mp3year:= 0;
    evszamindex:= 0;
    for i:= 1 to 3 do
      if Evszam(words[words.Count-i]) then
      begin
        evszamindex:= words.Count-i;
        Break;
      end;

    if mp3year = 0 then
      goto ennyi; // nem talaltuk meg az evszamot. Szopas, folosleges folytatni.

    if ((not Internal) and (evszamindex +3 = words.Count)) then
      groupname:= words[evszamindex+1]+'_'+words[evszamindex+2]; //tweak

    //nyelvkod.
    if (length(words[evszamindex-1]) = 2) then
    begin
      i:= mp3languages.IndexOf(words[evszamindex-1]);
      if (i <> -1) then
      begin
        mp3lng:= mp3languages[i];
        dec(evszamindex);
      end;
    end;

    if ((mp3lng = '') and (evszamindex -2 > 0) and (length(words[evszamindex-2]) = 2)) then
    begin
      i:= mp3languages.IndexOf(words[evszamindex-2]);
      if (i <> -1) then
      begin
        mp3lng:= mp3languages[i];
        dec(evszamindex);
      end;
    end;

    if (mp3lng = '') then mp3lng:= 'EN';

    //megkeressuk masodik kotojel utani szo indexet
    szoindex:= 0;
    kotojelekszama:= 0;
    for i:= 1 to length(rlsname) do
    begin
      if rlsname[i] = '_' then
        inc(szoindex)
      else
      if rlsname[i] = '-' then
      begin
        inc(szoindex);
        inc(kotojelekszama);
        if (kotojelekszama = 2) then
          Break;
      end;
    end;

    if kotojelekszama < 2 then
      goto ennyi;

    kezdoindex:= Min(szoindex, words.Count-1);
    kezdoindex:= Min(kezdoindex, evszamindex -3);
    kezdoindex:= Max(kezdoindex, 0);

    types:= 0;
    sources:= 0;
    mp3_number_of_cds:= 1;
    mp3_number_of_dvds:= 1;    
    for i:= kezdoindex to evszamindex-1 do
    begin
      //1CD 99DVD
      j:= length(words[i]);
      if (3 <= j) and (j <= 4) then
      begin
        s1:= RightStr(words[i], 2);
        s2:= RightStr(words[i], 3);
        if ((s1 = 'CD') and (3 = j) and (Szam(words[i][1]))) then
        begin
          mp3_number_of_cds:= StrToInt(words[i][1]);
          mp3_number_of := words[i];
          AddSource('CD', sources);
          Continue;
        end
        else
        if ((s1 = 'CD') and (4 = j) and (Szam(words[i][1])) and (Szam(words[i][2])) ) then
        begin
          mp3_number_of_cds:= StrToInt(Copy(words[i], 1, 2));
          mp3_number_of := words[i];
          AddSource('CD', sources);
          Continue;
        end
        else
        if ((s2 = 'CDR') and (4 = j) and (Szam(words[i][1])) ) then
        begin
          mp3_number_of_cds:= StrToInt(words[i][1]);
          mp3_number_of := words[i];
          AddSource('CDR', sources);

          Continue;
        end
        else
        if ((s2 = 'DVD') and (4 = j) and (Szam(words[i][1])) ) then
        begin
          mp3_number_of_dvds:= StrToInt(words[i][1]);
          mp3_number_of := words[i];
          AddSource('DVD', sources);
          Continue;
        end;
      end;
      if ((sources < 3) and (mp3sources.IndexOf(words[i]) <> -1)) then
      begin
        AddSource(words[i], sources);
      end;
      if ((types < 3) and (mp3types.IndexOf(words[i]) <> -1)) then
      begin
        inc(types);
        case types of
          1: mp3types1:= words[i];
          2: mp3types2:= words[i];
          3: mp3types3:= words[i];
        end;
      end;
    end;

    if ((words[0] = 'VA') or (words[0] = 'Va') or (words[0] = 'va')) then
      mp3_va:= True;

      (*
    if length(mp3genre) < length(genre) then
      mp3genre:= genre;
      *)

    if mp3source = '' then
      AddSource('CD', sources);

  end;

ennyi:

  if not fake then
    FakeCheck(self);
end;



function TMP3Release.Aktualizald(extrainfo: string): Boolean;
begin
  Result:= False;
  if length(extrainfo) > length(mp3genre) then
  begin
    aktualizalva:= True;
    Result:= True;
    mp3genre:= extrainfo;
  end;
end;



function GetKbPazo(p: TPazo): string;
begin
  Result:= p.rls.section+#9+p.rls.rlsname+#9+p.rls.ExtraInfo+#9+MyDateToStr(p.added);
end;

procedure kb_Save;
var i: Integer;
    seconds: Integer;
    x: TEncStringList;
    p: TPazo;
begin
  // itt kell elmenteni az slftp.kb -t
  kb_last_saved:= Now();
  Debug(dpSpam, rsections, 'kb_Save');
  seconds:= config.ReadInteger(rsections, 'kb_keep_entries', 86400*7);
  x:= TEncStringList.Create(passphrase);
  for i:= 0 to kb_list.Count -1 do
  begin
    p:= TPazo(kb_list.Objects[i]);
    if (
         (
           1 <> Pos('TRANSFER-', kb_list[i])
         )
         and
         (SecondsBetween(Now, p.added) < seconds)
       ) then
    begin
      x.Add(GetKbPazo(p));
    end;
  end;
  x.SaveToFile(ExtractFilePath(ParamStr(0))+'slftp.kb');
  x.Free;

end;

procedure kb_FreeList;
var i: Integer;
begin
  for i:= 0 to kb_list.Count- 1 do
    kb_List.Objects[i].Free;

  kb_list.Free;
  kb_eggyelkevesebb.Free;
  kb_announce.Free;
end;

procedure kb_Init;
begin
  kb_last_saved:= Now();
  kb_eggyelkevesebb:= THashedStringList.Create;
  kb_eggyelkevesebb.CaseSensitive:= False;  
  kb_announce:= THashedStringList.Create;
  kb_list:= THashedStringList.Create;
  sections:= TStringList.Create;
  sections.DelimitedText:= config.ReadString(rsections, 'sections', '');
  mp3genres:= TStringList.Create;
  mp3genres.Delimiter:= ' ';
  mp3genres.QuoteChar:= '"';
  mp3genres.DelimitedText:= config.ReadString(rsections, 'mp3genres', '');
  mp3languages:= TStringList.Create;
  mp3languages.Delimiter:= ' ';
  mp3languages.QuoteChar:= '"';
  mp3languages.DelimitedText:= config.ReadString(rsections, 'mp3languages', '');
  mp3sources:= TStringList.Create;
  mp3sources.Delimiter:= ' ';
  mp3sources.QuoteChar:= '"';
  mp3sources.DelimitedText:= config.ReadString(rsections, 'mp3sources', '');
  mp3types:= TStringList.Create;
  mp3types.Delimiter:= ' ';
  mp3types.QuoteChar:= '"';
  mp3types.DelimitedText:= config.ReadString(rsections, 'mp3types', '');
  mp3livesources:= TStringList.Create;
  mp3livesources.Delimiter:= ' ';
  mp3livesources.QuoteChar:= '"';
  mp3livesources.DelimitedText:= config.ReadString(rsections, 'mp3livesources', '');
end;

procedure kb_Uninit;
begin
  sections.Free;
  mp3livesources.Free;
  mp3genres.Free;
  mp3languages.Free;
  mp3sources.Free;
  mp3types.Free;
end;


function TMP3Release.AsText(pazo_id: Integer = -1): string;
begin
  Result:= inherited AsText(pazo_id);

  Result:= Result + 'Year: '+ IntToStr(mp3year) + #13#10;
  Result:= Result + 'Language: '+ mp3lng + #13#10;
  Result:= Result + 'Genre: '+ mp3genre + #13#10;
  Result:= Result + 'Source: '+ mp3source + #13#10;
  Result:= Result + 'Type1: '+ mp3types1 + #13#10;
  Result:= Result + 'Type2: '+ mp3types2 + #13#10;
  Result:= Result + 'Type3: '+ mp3types3 + #13#10;
  Result:= Result + 'CDs/DVDs: '+ mp3_number_of + #13#10;
  Result:= Result + 'VA: '+ IntToStr(Integer(mp3_va)) + #13#10;
end;

function TMP3Release.Bootleg: Boolean;
begin
  Result:= False;
  if 0 = AnsiCompareText(mp3types1, 'bootleg') then
    REsult:= True
  else
  if 0 = AnsiCompareText(mp3types2, 'bootleg') then
    REsult:= True
  else
  if 0 = AnsiCompareText(mp3types3, 'bootleg') then
    REsult:= True;

end;


function TMP3Release.Numdisks: Integer;
begin
  Result:= 1;
  if mp3_number_of <> '' then
  begin
    if mp3_number_of_cds <> 1 then
      Result:= mp3_number_of_cds
    else
    if mp3_number_of_dvds <> 1 then
      Result:= mp3_number_of_dvds; // aint the most professional implementation...
  end;
end;

function TMP3Release.Aktualizal(p: TObject): Boolean;
var pazo: TPazo;
    ps, shot: TPazoSite;
    i: Integer;
begin
  Result:= False;
  aktualizalva:= True;

  if 1 = Pos('PRE', section) then exit; //itt nem...

  pazo:= TPazo(p); // ugly shit

  shot:= nil;
  for i:= 0 to pazo.sites.Count -1 do
  begin
    ps:= TPazoSite(pazo.sites[i]);
    if ps.ts <> 0 then //
      shot:= ps;
  end;
  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);

      if (ps.Complete) then
        shot:= ps;
    end;

  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);
      if ps.status = rssNotAllowed then Continue;

      if (ps.destinations.Count > 0) then
        shot:= ps;
    end;

  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);

      if (ps.status = rssAllowed) then
        shot:= ps;
    end;


  if shot <> nil then
  begin
    AddTask(TPazoGenreDirlistTask.Create(shot.name, pazo, 1));
    Result:= True;
  end;
end;

function TMP3Release.ExtraInfo: string;
begin
  Result:= Mp3genre;
end;

{ TNFORelease }

function TNFORelease.Aktualizal(p: TObject): Boolean;
var pazo: TPazo;
    ps, shot: TPazoSite;
    i: Integer;
begin
  Result:= False;
  pazo:= TPazo(p); // ugly shit

  shot:= nil;
  for i:= 0 to pazo.sites.Count -1 do
  begin
    ps:= TPazoSite(pazo.sites[i]);
    if ps.ts <> 0 then //
      shot:= ps;
  end;
  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);

      if (ps.Complete) then
        shot:= ps;
    end;

  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);
      if ps.status = rssNotAllowed then Continue;

      if (ps.destinations.Count > 0) then
        shot:= ps;
    end;

  if (shot = nil) then
    for i:= 0 to pazo.sites.Count -1 do
    begin
      ps:= TPazoSite(pazo.sites[i]);

      if (ps.status = rssAllowed) then
        shot:= ps;
    end;
    
  if shot <> nil then
  begin
    AddTask(TPazoGenreNfoTask.Create(shot.name, pazo, 1));
    Result:= True;
  end;
  aktualizalva:= True;
end;

function TNFORelease.Aktualizald(extrainfo: string): Boolean;
begin
  Result:= False;
  if length(extrainfo) > length(nfogenre) then
  begin
    aktualizalva:= True;
    Result:= True;
    nfogenre:= extrainfo;
  end;
end;

function TNFORelease.AsText(pazo_id: Integer = -1): string;
begin
  Result:= inherited AsText(pazo_id);
  Result:= Result + 'nfo genre: '+ nfogenre + #13#10;
end;

constructor TNFORelease.Create(rlsname, section: string);
begin
  inherited;
  nfogenre:= '';
end;

procedure AddKbPazo(line: string);
var section, rlsname, extra: string;
    added: TDateTime;
    p: TPazo;
    r: TRelease;
    rc: TCRelease;
begin
  section:= SubString(line, #9, 1);
  rlsname:= SubString(line, #9, 2);
  extra:= SubString(line, #9, 3);
  added:= MyStrToDate(SubString(line, #9, 4));
  kb_eggyelkevesebb.Add(section+'-'+Copy(rlsname, 1, Length(rlsname)-1));
  kb_eggyelkevesebb.Add(section+'-'+Copy(rlsname, 2, Length(rlsname)-1));

  rc:= FindSectionHandler(section);
  r:= rc.Create(rlsname, section);
  r.Aktualizald(extra);
  r.aktualizalva:= True;
  p:= PazoAdd(r);
  p.added:= added;
  kb_list.AddObject(section+'-'+rlsname, p);
end;

procedure KB_start;
var x: TEncStringlist;
    i: Integer;
begin
  // itt kell betoltenunk az slftp.kb -t
  queue_lock.Enter;
  x:= TEncStringlist.Create(passphrase);
  try
    x.LoadFromFile(ExtractFilePath(ParamStr(0))+'slftp.kb');
    for i:= 0 to x.Count -1 do
      AddKbPazo(x[i]);
  finally
    x.Free;
    queue_lock.Leave;
  end;
  
  kb_thread:= TKBThread.Create;
end;

function TNFORelease.ExtraInfo: string;
begin
  Result:= nfogenre;
end;

{ TKBThread }

constructor TKBThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate:= True;
end;

destructor TKBThread.Destroy;
begin
  inherited;
  kb_thread:= nil;
end;

procedure TKBThread.Execute;
var i: Integer;
    p: TPazo;
    volt: Boolean;
begin
  while (not kilepes) do
  begin
    queue_lock.Enter;
    volt:= False;
    for i:= 0 to kb_list.Count-1 do
    begin
      p:= TPazo(kb_list.Objects[i]);
      if not p.rls.aktualizalva then
        if p.rls.Aktualizal(p) then
          volt:= True;
    end;
    if volt then
      QueueFire;

    if (SecondsBetween(Now(), kb_last_saved) > config.ReadInteger(rsections, 'kb_save_entries', 3600)) then
      kb_Save;
    queue_lock.Leave;

    sleep(500);
  end;
end;

initialization
  kb_Init;
finalization
  kb_Uninit;
end.
