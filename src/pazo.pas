unit pazo;

// EZTA Z UNITOT CSAK A QUEUE_LOCK ZARASA UTAN SZABAD HIVNI!
interface

uses Classes, kb, SyncObjs, Contnrs, dirlist, skiplists;

type
  TQueueNotifyEvent = procedure(Sender: TObject; value: Integer) of object;
  TSafeInteger = class
  private
    fC: TCriticalSection;
    fValue: Integer;
  public
    onChange: TQueueNotifyEvent;
    procedure Increase;
    procedure Decrease;
    constructor Create;
    destructor Destroy; override;
  end;
  TPazo = class;
  TRlsSiteStatus = (rssNotAllowed,  rssAllowed, rssShouldPre, rssRealPre, rssComplete);
  TPazoSite = class
    name: string;
    maindir: string;
    pazo: TPazo;
    sources: TObjectList;
    destinations: TObjectList;
    dirlist: TDirList;

    ts: TDateTime;
    status: TRlsSiteStatus;

    reason: string;
    dirlistadded: Boolean; // presitera addoltuk e mar a dirlistet

    function AllPre: Boolean; // returns true if its a pre or at least it should be
    function Source: Boolean;
    function Complete: Boolean;

    function Age: Integer;
    function AsText: string;

    function Eljut(cel: TPazoSite): Boolean;

//    procedure RaceReady(dir, filename: string; byme: Boolean);
    function ParseDirlist(dir, liststring: string): Boolean;
    procedure CopyMainDirlist(dir: string);
    procedure MkdirReady(dir: string);
    procedure AddDestination(sitename: string); overload;
    procedure AddDestination(ps: TPazoSite); overload;
    procedure AddSource(sitename: string);
    constructor Create(pazo: TPazo; name, maindir: string);
    destructor Destroy; override;
    procedure ParseXdupe(dir, resp: string);
    procedure ParseDupe(dir, filename: string; byme: Boolean); overload;
    procedure ParseDupe(dl: TDirlist; dir, filename: string; byme: Boolean); overload;
    function Stats: string;
    function Allfiles: string;
    procedure SetComplete(cdno: string);
    function StatusText: string;
    procedure Clear;
  private
    cds: string;
    function Tuzelj(dir: string; de: TDirListEntry; x: TStringList; fugges: string = ''): Boolean; overload;
    function EljutB(cel: TPazoSite; x: TStringList): Boolean;
  end;
  TPazo = class
  private
    lastannounce: string;
    fSources: TObjectList;
    function GetSources: TObjectList;
    procedure QueueEvent(Sender: TObject; value: Integer);

    procedure MainBuildRaceTasks(ps: TPazoSite; d: TDirList; dir: string);
    function BuildRaceTasks(ps: TPazoSite; d: TDirList; dir: string): Boolean;

  public
    pazo_id: Integer;

    autodirlist: Boolean;
    srcsite: string; // <- ez a szabalyok tuzelgetesehez kell
    rls: TRelease;

    stopped: Boolean;
    ready: Boolean; // minden sikeres mindenhol minden complete
    readyerror: Boolean;
    readyat: TDateTime;
    lastTouch: TDateTime;

    sites: TObjectList;
    sl: TSkipList;

    allfiles: Integer;
    allsize: Integer;
    added: TDateTime;

    dirlist: TDirlist; // ez a globalis dirlist

     // vagyis ha tobb presite van es egyik vegez akkor ez a valtozo initelve
     // lesz es akkor a tobbi szal nem baszkural dirlistelessel
    queuenumber: TSafeInteger;

    procedure Clear;
    function StatusText: string;
    function Age: Integer;
    function AsText: string;
    function Stats: string;
    function FullStats: string;
    constructor Create(rls: TRelease;pazo_id: Integer);
    destructor Destroy; override;
    function FindSite(sitename: string): TPazoSite;
    function AddSite(sitename, maindir: string): TPazoSite;
    function AddSites(): Boolean;
  published
    property Sources: TObjectList read GetSources;
  end;

function FindPazoById(id: Integer): TPazo;
function FindPazoByName(section, rlsname: string): TPazo;
function PazoAdd(rls: TRelease): TPazo;//; addlocal: Boolean = False
procedure PazoGarbage;

var pazo_last_garbage: TDateTime;


implementation

uses SysUtils, mainthread, sitesunit, DateUtils, debugunit, queueunit, taskrace, mystrings, irc, idGlobal;

const section = 'pazo';

var
//    pazos: TObjectList;
    pazo_id: Integer;

procedure PazoGarbage;
//var i: Integer;
//    p: TPazo;
begin
(*
  queue_lock.Enter;
  i:= 0;
  while(i < pazos.Count) do
  begin
    p:= TPazo(pazos[i]);
    if ((p.ready) and (SecondsBetween(Now, p.lastTouch) > 120)) then
    begin
      Debug(dpMessage, section, 'Garbage collecting %d',[p.pazo_id]);
      pazos.Remove(p);
      Continue;
    end;

    inc(i);
  end;
  queue_lock.Leave;
*)
  pazo_last_garbage:= Now;

end;

function PazoAdd(rls: TRelease): TPazo;//; addlocal: Boolean = False
begin
  Result:= TPazo.Create(rls, pazo_id);
//  if  addlocal then
//    pazos.Add(Result);
  inc(pazo_id);
end;


(*
function FindPazoById(id: Integer): TPazo;
var i: integer;
    p: TPazo;
begin
  Result:= nil;
  for i:= pazos.Count -1 downto 0 do
  begin
    p:= TPazo(pazos[i]);
    if p.pazo_id = id then
    begin
      p.lastTouch:= Now();
      Result:= p;
      exit;
    end;
  end;
end;
*)


function FindPazoById(id: Integer): TPazo;
var i: integer;
    p: TPazo;
begin
  Result:= nil;
  for i:= kb_list.Count -1 downto 0 do
  begin
    p:= TPazo(kb_list.Objects[i]);
    if p.pazo_id = id then
    begin
      Result:= p;
      p.lastTouch:= Now();
      exit;
    end;
  end;
end;


function FindPazoByName(section, rlsname: string): TPazo;
var i: integer;
begin
  Result:= nil;
  i:= kb_list.IndexOf(section+'-'+rlsname);
  if i <> -1 then
  begin
    Result:= TPazo(kb_list.Objects[i]);
    Result.lastTouch:= Now();
    exit;
  end;
end;

procedure PazoInit;
begin
  pazo_id:= 0;
  pazo_last_garbage:= Now;
//  pazos:= TObjectList.Create;
end;
procedure PazoUnInit;
begin
//  pazos.Free;
//  pazos:= nil;
end;

function TPazoSite.Tuzelj(dir: string; de: TDirListEntry; x: TStringList; fugges: string = ''): Boolean;
var i: Integer;
    dst: TPazoSite;
    dstdl: TDirList;
    pm: TPazoMkdirTask;
    pr: TPazoRaceTask;
    dde: TDirListEntry;
    s: TSite;
begin
  Result:= False;

  for i:= 0 to destinations.Count -1 do
  begin
    dst:= TPazoSite(destinations[i]);
    if x.IndexOf( name+'-'+dst.name ) = -1 then
    begin
      x.Add(name+'-'+dst.name);

      s:= FindSiteByName(dst.name);
      if ((s = nil) or (s.working = sstDown)) then Continue;

      dstdl:= dst.dirlist.FindDirlist(dir);
      if dstdl = nil then Continue; // ez elvileg nem is fordulhatna elo

      if dstdl.entries.Count = 0 then
      begin
        // addolnunk kell TPazoMkdir taszkot dst-re dir-rel
        pm:= TPazoMkdirTask.Create(dst.name, pazo, dir);
        // mkdir-nek lehet mkdir fuggese.
        if ((dstdl.parent <> nil) and (dstdl.parent.dirlist.mkd_fugges <> '')) then
          pm.dependencies.Add(dstdl.parent.dirlist.mkd_fugges);
        tasks.Add(pm);
        dstdl.mkd_fugges:= pm.UidText;
      end;

      dde:= dstdl.Find(de.filename);
      if (dde <> nil) then
      begin
        // idokozben ezen a destination siteon megjelenhetett tovabbi destination
        // tehat tuzelnunk kell hogy ezek az uj destinationok is toltodjenek
        dst.Tuzelj(dir, dde, x, dde.pr);
      end;

      if ((dde <> nil) and (dde.done)) then continue; // ez mar xdupe soran kialakult

      if nil = dde then
      begin
        dde:= TDirlistEntry.Create(de, dstdl);
        dstdl.entries.Add(dde);           
      end;


      if not de.directory then
      begin
        // addolni kell tpazoracetask-ot
        pr:= TPazoRaceTask.Create(name, dst.name, pazo, dir, de.filename);
        if dstdl.mkd_fugges <> '' then
          pr.dependencies.Add(dstdl.mkd_fugges);
        if dstdl.sfv_fugges <> '' then
          pr.dependencies.Add(dstdl.sfv_fugges);
        if fugges <> '' then
          pr.dependencies.Add(fugges);
        dde.pr:= pr.UidText;
        tasks.Add(pr);

        if de.Extension = '.sfv' then dstdl.sfv_fugges:= pr.UidText;

        // fuggessel egyutt megy tovabb a rekurzio
        dst.Tuzelj(dir, dde, x, dde.pr);
      end;

    end;
  end;
end;

{ TPazo }

function TPazo.AddSite(sitename, maindir: string): TPazoSite;
begin
  Result:= TPazoSite.Create(self, sitename, maindir);
  sites.Add(Result);
end;

function TPazo.Age: Integer;
var i: Integer;
    ps: TPazoSite;
    a: Integer;
begin
(*
    ts: TDateTime;

  if ts <> 0 then
  begin
    Result:= SecondsBetween(Now, ts);
    exit;
  end;
*)

  Result:= -1;
  for i:= 0 to sites.Count -1 do
  begin
    ps:= TPazoSite(sites[i]);
    a:= ps.Age;
    if ((a <> -1) and ((Result = -1) or (Result < a))) then
      Result:= a; 
  end;

  if Result = -1 then
    Result:= SecondsBetween(Now, added);
end;

function TPazo.AsText: string;
var i: Integer;
   ps: TPazoSite;
begin
  Result:= rls.AsText(pazo_id);
  Result:= Result + 'Age: '+IntToStr(age) + 's'+ #13#10;
  for i:= 0 to sites.Count -1 do
  begin
    ps:= TPazoSite(sites[i]);
    Result:= Result + ps.AsText;
  end;
end;

function TPazo.BuildRaceTasks(ps: TPazoSite; d: TDirList; dir: string): Boolean;
var i: Integer; //, j
    de: TDirListEntry;
    x: TStringList;
    // mySources: TObjectList;
begin
  Result:= False;
  x:= TStringList.Create;
  for i:= 0 to d.entries.Count -1 do
  begin
    de:= TDirListEntry(d.entries[i]);
    if ((not de.skiplisted) and (de.toprocess)) then
    begin
      de.toprocess:= False;

      x.Clear;
      (* ezt nem igy hasznaljuk mar
      if ((ps.AllPre) and (ps.dirlist = self.dirlist)) then
      begin
        mySources:= Sources;
        for j:= 0 to mySources.Count -1 do
        begin
          if TPazoSite(mySources[j]).Tuzelj(dir, de, x) then
            Result:= True;
        end;
      end
      else
      begin
        if ps.Tuzelj(dir, de, x) then
          Result:= True
      end;
      *)


      if ps.Tuzelj(dir, de, x) then
        Result:= True

    end;
  end;
  x.Free;
end;

constructor TPazo.Create(rls: TRelease; pazo_id: Integer);
begin
  added:= Now;
  autodirlist:= False;
  fSources:= TObjectList.Create(False);
  queuenumber:= TSafeInteger.Create;
  queuenumber.onChange:= QueueEvent;
  dirlist:= nil;
  readyerror:= False;
  sites:= TObjectList.Create;
  self.rls:= rls;
  self.pazo_id:= pazo_id;
  stopped:= False;
  ready:= False;
  readyat:= 0;
  lastTouch:= Now();
  sl:= FindSkipList(rls.section);
  inherited Create;
end;

destructor TPazo.Destroy;
begin
  fSources.Free;
  sites.Free;
  queuenumber.Free;
  inherited;
end;

function TPazo.FindSite(sitename: string): TPazoSite;
var i: integer;
begin
  Result:= nil;
    for i:= 0 to sites.Count -1 do
      if TPazoSite(sites[i]).name = sitename then
      begin
        Result:= TPazoSite(sites[i]);
        exit;
      end;

end;

function TPazo.GetSources: TObjectList;
var i: integer;
    ps: TPazoSite;
begin
  fSources.Clear;

    for i:= 0 to sites.Count -1 do
    begin
      ps:= TPazoSite(sites[i]);
      if ((ps.sources.Count = 0) and (ps.destinations.Count > 0)) then //egyertelmu forras site
        fSources.Add(sites[i]);
    end;

    if ((fSources.Count = 0) and (sites.Count <> 0) and (TPazoSite(sites[0]).destinations.Count > 0)) then
      fSources.Add(sites[0]);

  Result:= fSources;
end;

procedure TPazo.QueueEvent(Sender: TObject; value: Integer);
var s: string;
begin
  if value < 0 then exit;


  if (value <> 0) then
  begin
    ready:= False;
    readyerror:= False;
  end
  else
  if value = 0 then
  begin
    readyat:= Now();
    ready:= True;
    if not kilepes then
    begin
      Debug(dpSpam, section, 'Number of pazo tasks is zero now! '+IntToStr(pazo_id));
      if not stopped then
      begin
        s:= Stats;
        if lastannounce <> s then
        begin
          irc_Addtext(rls.rlsname+': '+Stats);
          lastannounce:= s;
        end;
      end;
    end;
  end;
end;

function TPazo.Stats: string;
var i: Integer;
    ps: TPazoSite;
    ms: TObjectList;
//    mysources: TObjectList;
begin
  Result:= '';

  (*
  mySources:= Sources;
  for i:= 0 to Sources.Count- 1 do
    Result:= Result + TPazoSite(mySources[i]).name+'-'+IntToStr(TPazoSite(mySources[i]).dirlist.entries.Count)+' ';
  Result:= Result + '--> ';
  *)

  ms:= Sources;
  for i:= 0 to sites.Count -1 do
  begin
    ps:= TPazoSite(sites[i]);
    if ps.status = rssNotAllowed then Continue;

    if Result <> '' then Result := Result + ', ';

    if ms.IndexOf(ps) <> -1 then
      Result:=  Result + Bold(ps.Allfiles)
    else
      Result:= Result + ps.Stats;;
  end;
end;

function TPazo.FullStats: string;
var i: Integer;
    ps: TPazoSite;
    ms: TObjectList;
//    mysources: TObjectList;
begin
  Result:= '';
 
  ms:= Sources;
  for i:= 0 to sites.Count -1 do
  begin
    ps:= TPazoSite(sites[i]);
    if ps.status = rssNotAllowed then Continue;

    if Result <> '' then Result := Result + ', ';

    if ms.IndexOf(ps) <> -1 then
      Result:=  Result + Bold(ps.Allfiles)
    else
      Result:= Result + ps.AllFiles;
  end;
end;

function TPazo.StatusText: string;
var i: Integer;
begin
  Result:= '';
  for i:= 0 to sites.Count -1 do
  begin
    Result:= Result + TPazoSite(sites[i]).StatusText;
    if i <> sites.Count -1 then
      Result:= Result +  ' ';
  end;
end;

procedure TPazo.MainBuildRaceTasks(ps: TPazoSite; d: TDirList; dir: string);
begin
      if BuildRaceTasks(ps, d, dir) then
      begin
        // todo: implement movesfvsecond movenfofirst

        QueueFire;
      end;
end;

procedure TPazo.Clear;
var i: Integer;
begin
  stopped:= False; // ha stoppoltak korabban akkor ez most szivas
  for i:= 0 to sites.Count -1 do
    TPazoSite(sites[i]).Clear;
end;

function TPazo.AddSites: Boolean;
var s: TSite;
    i: Integer;
    sectiondir: string;
    ps: TPazoSite;
begin
  Result:= False;
  for i:= 0 to sitesunit.sites.Count -1 do
  begin
    s:= TSite(sitesunit.sites[i]);
    sectiondir:= s.sectiondir[rls.section];
    if ((sectiondir <> '') and (s.working <> sstDown) and (nil = FindSite(s.name))) then
    begin
      Result:= True;
      ps:= TPazoSite.Create(self, s.name, sectiondir);
      ps.status:= rssNotAllowed;
      if s.IsAffil(rls.section, rls.groupname) then
        ps.status := rssShouldPre;

      sites.Add(ps);
    end;
  end;
end;

{ TPazoSite }

procedure TPazoSite.AddDestination(sitename: string);
begin
  AddDestination(pazo.FindSite(sitename));
end;
procedure TPazoSite.AddDestination(ps: TPazoSite);
var i: Integer;
begin
  if ps <> nil then
  begin
    i:= destinations.Indexof(ps);
    if i = -1 then
    begin
      destinations.Add(ps);
      i:= ps.sources.IndexOf(self);
      if i = -1 then
        ps.sources.Add(self);
    end;
  end;
end;


procedure TPazoSite.AddSource(sitename: string);
var ps: TPazoSite;
    i: Integer;
begin
  ps:= pazo.FindSite(sitename);
  if ps <> nil then
  begin
    i:= sources.IndexOf(ps);
    if i = -1 then
    begin
      sources.Add(ps);
      i:= ps.destinations.IndexOf(self);
      if i = -1 then
        ps.destinations.Add(self);
    end;
  end;
end;



constructor TPazoSite.Create(pazo: TPazo; name, maindir: string);
begin
  inherited Create;
  self.ts:= 0;
  self.maindir:= maindir;
  self.pazo:= pazo;
  self.Name:= name;
  sources:= TObjectList.Create(False);
  destinations:= TObjectList.Create(False);

  dirlist:= TDirlist.Create(nil, pazo.sl);
end;

destructor TPazoSite.Destroy;
begin
  sources.Free;
  destinations.Free;
  dirlist.Free;
  inherited;
end;

procedure TPazoSite.MkdirReady(dir: string);
var d: TDirList;
begin
  d:= dirlist.FindDirlist(dir);
  if d <> nil then
  begin
    debug(dpSpam, section, 'MkdirReady '+name+' '+dir);
    d.mkd_fugges:= '';
  end;
end;

function TPazoSite.ParseDirlist(dir, liststring: string): Boolean;
var d: TDirList;
begin
  Result:= False;
  d:= dirlist.FindDirlist(dir);
  if d <> nil then
    if d.ParseDirlist(liststring) then
    begin
      Result:= True;

      pazo.MainBuildRaceTasks(self, d, dir);


      debug(dpSpam, section, 'DIRLIST OF %s', [name]);  
      d.Debug;
    end;
end;

procedure TPazoSite.CopyMainDirlist(dir: string);
var din, dout: TDirList;
    de: TDirlistEntry;
    i: Integer;
begin
  if pazo.dirlist = nil then exit; // ez elvileg nem fordulhat elo

  din:= pazo.dirlist.FindDirlist(dir);
  dout:= dirlist.FindDirlist(dir);
  if ((din = nil) or (dout = nil)) then exit;

  debug(dpSpam, section, 'Copymaindirlist '+' '+name+' '+dir);

  for i:= 0 to din.entries.Count-1 do
  begin
    if nil = dout.Find(TDirListEntry(din.entries[i]).filename) then
    begin
      de:= TDirListEntry.Create(TDirListEntry(din.entries[i]), dout);
      de.toprocess:= True;
      dout.entries.Add(de);
    end;
  end;

  pazo.MainBuildRaceTasks(self, dout, dir);

end;


(*
procedure TPazoSite.RaceReady(dir, filename: string; byme: Boolean);
var dl: TDirList;
    de: TDirListEntry;
begin
  dl:= dirlist.FindDirlist(dir);
  if dl = nil then exit; // ez nem fordulhat elo

  de:= dl.Find(filename);
  if de = nil then exit; // ez nem fordulhatna elo

  if de.Extension = '.sfv' then
    dl.sfv_fugges:= nil;

  de.pr:= nil;
  de.done:= True;
  de.racedbyme:= byme;
end;
*)

procedure TPazoSite.ParseDupe(dl: TDirlist; dir, filename: string; byme: Boolean);
var de: TDirlistEntry;
    x: TStringList;
begin
  de:= dl.Find(filename);
  if de = nil then
  begin
    // ez azt jelenti hogy meg nem tuzeltuk vegig
    x:= TStringList.Create;
    de:= TDirListEntry.Create(filename, dl);
    de.directory:= False;
    de.done:= True;
    de.pr:= '';
    if byme then
      de.racedbyme:= byme;
    Tuzelj(dir, de, x);
    x.Free;
  end;

  if de.Extension = '.sfv' then
    dl.sfv_fugges:= '';

  if byme then
    de.racedbyme:= byme;
  de.pr:= '';
  de.done:= True;

  // ki kell szednunk a queuebol bizonyos taszkokat
  // masokat pedig tuzelni kell
  RemovePazoDeps(pazo.pazo_id, name, dir, filename);

end;


procedure TPazoSite.ParseDupe(dir, filename: string; byme: Boolean);
var dl: TDirList;
begin
  dl:= dirlist.FindDirlist(dir);
  if dl = nil then exit;

  ParseDupe(dl, dir, filename, byme);
end;

procedure TPazoSite.ParseXdupe(dir, resp: string);
var s: string;
    dl: TDirList;
    i: Integer;
begin
  dl:= dirlist.FindDirlist(dir);
  if dl = nil then exit;

  i:= 1;
  while (true) do
  begin
    s:= SubString(resp, EOL, i);
    if s = '' then exit;

//553- X-DUPE: 09-soulless-deadly_sins.mp3
    if (Pos('553- X-DUPE: ', s) = 1) then
      ParseDupe(dl, dir, Copy(s, 14, 1000), False);

    inc(i);
  end;
end;

function TPazoSite.Stats: string;
begin
  Result:= Name;
  if dirlist <> nil then
    Result:= Name + '-'+ IntToStr(dirlist.RacedByMe);
end;

function TPazoSite.Complete: Boolean;
begin
  Result:= (status in [rssRealPre, rssComplete]);// or (dirlist.Complete);
end;

function TPazoSite.Source: Boolean;
begin
  Result:= (status = rssAllowed) or Complete;
end;

procedure TPazoSite.SetComplete(cdno: string);
var i: Integer;
begin
  cds:= cds + cdno;
  i:= StrToIntDef(cdno, 0);
  if i > dirlist.biggestcd then
    dirlist.biggestcd:= i;

  if dirlist.biggestcd = 1 then
  begin
    status:= rssAllowed; // ha elso cd complete akkor van meg tobb cd is
    exit;
  end;

  for i:= 1 to dirlist.biggestcd do
    if 0 = Pos(IntToStr(i), cds) then
      exit;
  status:= rssComplete;
end;


function TPazoSite.AsText: string;
var i: Integer;
begin
  Result:= Bold('SITE: '+name)+#13#10;
  Result:= Result + 'Maindir: '+maindir+#13#10;
  Result:= Result + 'Sources: ';
  for i:= 0 to sources.Count -1 do
    Result:= Result + TPazoSite(sources[i]).name+' ';
  Result:= Result + #13#10;
  Result:= Result + 'Destinations: ';
  for i:= 0 to destinations.Count -1 do
    Result:= Result + TPazoSite(destinations[i]).name+' ';
  Result:= Result + #13#10;
  Result:= Result + 'Status: ';
  case status of
    rssNotAllowed: Result:= Result + 'not allowed ('+reason+')';
    rssAllowed: Result:= Result + 'allowed ('+reason+')';
    rssShouldPre: Result:= Result + '(?)pre';
    rssRealPre: Result:= Result + 'pre';
    rssComplete: Result:= Result + 'complete';
  end;
  Result:= Result + #13#10;
end;

function TPazoSite.Age: Integer;
begin
  if ts <> 0 then
  begin
    Result:= SecondsBetween(Now, ts);
    exit;
  end;

  Result:= -1;
  if dirlist <> nil then
    Result:= SecondsBetween(Now, dirlist.LastChanged);
end;

function TPazoSite.Allfiles: string;
begin
  Result:= Name;
  if dirlist <> nil then
    Result:= Name + '-' + IntToStr(dirlist.Done);
end;

function TPazoSite.StatusText: string;
begin
  Result:= name + '-';
  case status of
    rssNotAllowed: Result:= Result + 'N';
    rssAllowed: Result:= Result + 'A';
    rssShouldPre: Result:= Result + 'S';
    rssRealPre: Result:= Result + 'P';
    rssComplete: Result:= Result + 'C';
  end;
end;

function TPazoSite.AllPre: Boolean;
begin
  Result:= status in [rssShouldPre, rssRealPre];
end;

procedure TPazoSite.Clear;
begin
  dirlistadded:= False;
  if dirlist <> nil then
    dirlist.Clear;
end;

function TPazoSite.EljutB(cel: TPazoSite; x: TStringList): Boolean;
var i: Integer;
    ps: TPazoSite;
begin
  Result:= destinations.IndexOf(cel) <> -1;
  if Result then exit;
  x.Add(name);

  // most jon a rekurzio
  for i:= 0 to destinations.Count -1 do
  begin
    ps:= TPazoSite(destinations[i]);
    if x.IndexOf(ps.name) = -1 then
    begin
      Result:= ps.EljutB(cel, x);
      if Result then exit;
    end;
  end;
end;

function TPazoSite.Eljut(cel: TPazoSite): Boolean;
var x: TStringList;
begin
  x:= TStringList.Create;
  Result:= EljutB(cel, x);
  x.Free;
end;

{ TSafeInteger }

constructor TSafeInteger.Create;
begin
  fC:= TCriticalSection.Create;
  onChange:= nil;
end;

procedure TSafeInteger.Decrease;
begin
  fc.Enter;
  dec(fvalue);
//  if fValue < 0 then fValue:= 0;
  if (Assigned(onChange)) then
    onChange(self, fValue);
  fc.Leave;
end;

destructor TSafeInteger.Destroy;
begin
  fC.Free;
  inherited;
end;

procedure TSafeInteger.Increase;
begin
  fc.Enter;
  inc(fValue);
  if (Assigned(onChange)) then
    onChange(self, fValue);
  fc.Leave;
end;

initialization
  PazoInit;
finalization
  PazoUninit;
end.
