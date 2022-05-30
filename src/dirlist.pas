unit dirlist;

interface

uses Contnrs, skiplists;

type
  TDirlist = class;

  TDirListEntry = class
    dirlist: TDirList;

    fDirectory: Boolean;
    subdirlist: TDirList;

    filename: string;
    filenamelc: string;
    filesize: Cardinal;
    skiplisted: Boolean;
    racedbyme: Boolean;
    done: Boolean;
    toprocess: Boolean;
    cdno: Integer;

    timestamp: TDateTime;

    sfvfirsteventvoltmar: Boolean; 
    pr: string;

    procedure CalcCDNumber;
    function Extension: string;

    constructor Create(filename: string; dirlist: TDirList); overload;
    constructor Create(de: TDirlistEntry; dirlist: TDirList); overload;
    destructor Destroy; override;

    procedure Debug;

    procedure SetDirectory(value: Boolean);

    function Useful: Boolean;
    property Directory: Boolean read fDirectory write SetDirectory;
  end;
  TDirList = class
  private
    fLastChanged: TDateTime;
    allcdshere: Boolean;
    multicdcache: Boolean; //cache
    completecache: Boolean;
    skiplist: TSkipList;
    sf_d, sf_f: TSkiplistFilter;
    procedure SetSkiplists;
    procedure SetLastChanged(value: TDateTime);
    class function Timestamp(ts: string): TDateTime;
  public
    sfv_fugges: string; // ezt a kettot "orokolnie" kell az addolt uj fajloknak
    mkd_fugges: string;

    dirlistadded: Boolean;
    mindenmehetujra: Boolean;


    biggestcd: Integer;
    lastDirlistAdded: TDateTime;
    parent: TDirListEntry;
    entries: TObjectList;
    giveup: Boolean;
    procedure Clear;
    procedure CleanToprocess;
    function hasnfo: boolean;
    function No_Raceable: Integer;
    function No_Skiplisted: Integer;
    function No_NotSkiplisted: Integer;
    constructor Create( parentdir: TDirListEntry; skiplist: TSkipList); overload;
    constructor Create( parentdir: TDirListEntry; skiplist: TSkipList; s: string); overload;
    destructor Destroy; override;
    function Depth: Integer;
    function MultiCD: Boolean;
    function Dirname: string;

    procedure Sort;
    function RegenerateSkiplist: Boolean;

    procedure Debug;


    function ParseDirlist(s: string): Boolean;
    function Complete: Boolean;
    function CompleteByTag: Boolean;

    procedure Usefulfiles(var files, size: Integer);

    function Find(filename: string): TDirListEntry;

    function FindDirlist(dirname: string): TDirList;
    function Done: Integer;
    function RacedByMe: Integer;
  published
    property LastChanged: TDateTime read fLastChanged write SetLastChanged;
  end;

implementation

uses SysUtils, DateUtils, SyncObjs, debugunit, mystrings, Math, tags;

var sort_lock: TCriticalSection;
{ TDirList }

const section = 'dirlist';

function TDirList.Complete: Boolean;
var i: Integer;
    d: TDirlistEntry;
begin
  Result:= completecache;
  if completecache then exit;

  if parent <> nil then
  begin
    // we are in a subdirectory,
    // there are two options:
    // dir cant contain an sfv
    Result:= CompleteByTag;
    if ((not Result) and (sf_f <> nil)) then
      Result:= sf_f.MatchFile('.sfv') = -1;
  end else
  begin
    // main dir vagyunk
    Result:= CompleteByTag;
    if (not Result) and (MultiCD) then
    begin
      if allcdshere then
      begin
        Result:= True;
        for i:= 0 to entries.Count -1 do
        begin
          d:= TDirlistEntry(entries[i]);
          if ((d.cdno > 0) and (d.subdirlist <> nil) and (not d.subdirlist.Complete)) then
          begin
            Result:= False;
            break;
          end;
        end;
      end;
    end;
  end;

  completecache:= Result;
end;



constructor TDirList.Create( parentdir: TDirListEntry; skiplist: TSkipList);
begin
  Create(parentdir, skiplist, '');
end;

constructor TDirList.Create( parentdir: TDirListEntry; skiplist: TSkipList; s: string);
begin
  biggestcd:= 0;
  giveup:= False;
  sfv_fugges:= '';
  mkd_fugges:= '';


  lastDirlistAdded:= Now();
  fLastChanged:= Now();
  allcdshere:= False;
  completecache:= False;
  multicdcache:= False;
  entries:= TObjectList.Create;
  self.parent:= parentdir;

  self.skiplist:= skiplist;
  SetSkiplists;

  if s <> '' then
    ParseDirlist(s);
end;

procedure TDirList.SetSkiplists;
var s: string;
begin
  s:= Dirname;
  if skiplist <> nil then
  begin
    sf_f:= skiplist.FindFileFilter(s);
    sf_d:= skiplist.FindDirFilter(s);
  end else
  begin
    sf_f:= nil;
    sf_d:= nil;
  end;
end;

procedure TDirList.Debug;
var i: Integer;
begin
  if debug_verbose then
  begin
    for i:= 0 to entries.Count -1 do
      TDirlistEntry(entries[i]).Debug;
  end;
end;

function TDirList.Depth: Integer;
begin
  if parent <> nil then
    Result:= parent.dirlist.Depth + 1
  else
    Result:= 1;
end;

destructor TDirList.Destroy;
begin
  entries.Free;
  inherited;
end;

function TDirList.Dirname: string;
begin
  if parent = nil then
  begin
    if MultiCd then
      Result:= '_MULTICDROOT_'
    else
      Result:= '_ROOT_';
  end else
    Result:= parent.filename;
end;

function TDirList.MultiCD: Boolean;
var i: Integer;
    s: string;
    de: TDirListEntry;
begin
  if parent = nil then
  begin
    if multicdcache then
    begin
      Result:= True;
      exit;
    end;

    biggestcd:= 0;
    Result:= False;
    s:= '';
    // megnezzuk van e CD1 CD2 stb jellegu direktorink
    for i:= 0 to entries.Count -1 do
    begin
      de:= TDirListEntry(entries[i]);

      if de.cdno <> 0 then
      begin
        multicdcache:= True;
        Result:= True;
        s:= s + IntToStr(de.cdno);

        if de.cdno > biggestcd then
          biggestcd:= de.cdno;
      end;
    end;

    if biggestcd > 1 then
    begin
      allcdshere:= True;
      for i:= 1 to biggestcd do
        if (0 = Pos(IntToStr(i), s)) then
        begin
          allcdshere:= False;
          Break;
        end;
    end;
  end else
    Result:= parent.dirlist.MultiCD;
end;

function TDirList.No_NotSkiplisted: Integer;
begin
  Result:= entries.Count - No_Skiplisted;
end;

function TDirList.No_Raceable: Integer;
var i: Integer;
begin
  Result:= 0;
  for i:= 0 to entries.Count -1 do
    if ((not TDirListEntry(entries[i]).skiplisted) and (not TDirListEntry(entries[i]).done)) then
      inc(Result);
end;

function TDirList.No_Skiplisted: Integer;
var i: Integer;
begin
  Result:= 0;
  for i:= 0 to entries.Count -1 do
    if TDirListEntry(entries[i]).skiplisted then
      inc(Result);
end;

class function TDirlist.Timestamp(ts: string): TDateTime;
const
  Months: array[1..12] of string =
    ('Jan ', 'Feb ', 'Mar ', 'Apr ', 'May ', 'Jun ', 'Jul ', 'Aug ', 'Sep ', 'Oct ', 'Nov ', 'Dec ');
var l,ev, ora,perc, honap, nap, i: Integer;
   evnelkul: Boolean;
begin
  Result:= 0;
  l:= length(ts);
  if ((l > 12) or (l < 11)) then exit;

  honap:= 0;
   for i:=1 to 12 do
   begin
     if (1 = Pos(Months[i], ts)) then
     begin
       honap:= i;
       Break;
     end;
  end;
  if (honap=0) then exit;

  nap:= StrToIntDef(Copy(ts, 5, 2), 0);
  if ((nap < 1) or (nap > 31)) then exit;



  ora:= 0;
  perc:= 0;
  evnelkul:= False;
  if(l = 11) then
  begin
    ev:= StrToIntDef(Copy(ts, 8, 4), 0);
    if ev < 1000 then exit;
    if not TryEncodeDateTime(ev, honap, nap, 0,0,0,0,  Result) then
      exit;
  end
  else
  begin
    evnelkul:= True;
    ora:= StrToIntDef(Copy(ts,8,2),0);
    perc:= StrToIntDef(Copy(ts,11,2),0);
    if not TryEncodeDateTime(YearOf(Now()), honap, nap, ora, perc, 0, 0, Result) then
      exit;
  end;

  if((Result > Now)and(evnelkul)) then
    TryEncodeDateTime(YearOf(Now)-1, honap, nap, ora, perc,0,0, Result);

end;

function TDirList.ParseDirlist(s: string): Boolean;
var i, j: integer;
    tmp: string;
    akttimestamp: TDateTime;
    de: TDirListEntry;
    elozospacevolt: Boolean;
    hanyadik, meretkezd, meretvege, filenevkezd: Integer;
    fn: string;
    aktfilesize: Cardinal;
    added: Boolean;
begin
  Result:= False;
  added:= False;
  i:= 1;
  while(true) do
  begin
    tmp:= SubString(s, #13#10, i);
    if tmp = '' then break;

    inc(i);

//drwxrwxrwx   2 nete     Death_Me     4096 Jan 29 05:05 Whisteria_Cottage-Heathen-RERIP-2009-pLAN9
    if (length(tmp) > 11) then
    begin
      if((tmp[1] <> 'd') and (tmp[1] <> '-') and (tmp[11] = ' ')) then
        continue;


      elozospacevolt:= False;
      hanyadik:= 0;
      meretkezd:= 0;
      meretvege:= 0;
      filenevkezd:= 0;

      for j:= 11 to Length(tmp) do
      begin
        if(tmp[j] = ' ') then
        begin
          if(not elozospacevolt) then
          begin
            if (hanyadik = 4) then
              meretvege:= j-1; //meret
          end;

          elozospacevolt:= True;
        end
        else
        begin
          if(elozospacevolt) then
          begin
            inc(hanyadik);
            if (hanyadik = 4) then
            begin
              meretkezd := j; //meret
            end
            else
            if (hanyadik = 8) then
            begin
              filenevkezd:= j;//meret
              break;
            end;
          end;

          elozospacevolt:= False;
        end;
      end; // end of for j

      if ((meretkezd <= meretvege) and (meretvege-meretkezd < 10) and (filenevkezd > 0)) then
      begin
        fn:= Copy(tmp, filenevkezd, 1000);
        if ((fn <> '.') and (fn <> '..')) then
        begin
          aktfilesize:= StrToIntDef(Copy(tmp,meretkezd, meretvege-meretkezd+1), 0 );
          akttimestamp:= Timestamp(Copy(tmp, meretvege+2, filenevkezd-meretvege-3));

          de:= Find(fn);
          if nil = de then
          begin
            added:= True;
            de:= TDirListEntry.Create(fn, self);
            de.timestamp:= akttimestamp;
            de.done:= True;
            de.directory := (tmp[1] = 'd');
            if not de.directory then
               de.filesize:= aktfilesize;

            LastChanged:= Now();
            entries.Add(de);
          end else
          if ((de.filesize < aktfilesize) or (de.timestamp <> akttimestamp)) then
          begin
            added:= True; // <- regeneraljuk a skiplistet
            if de.skiplisted then
              de.toprocess:= True; // nulla bajtos fajl lett sok bajtos, racelni kell.
            de.skiplisted:= False;
            de.filesize:= aktfilesize;
            de.timestamp:= akttimestamp;
            LastChanged:= Now();
          end;
        end;

      end;

    end;

  end;

  if parent = nil then // megvaltozhatott a MULTI CD statusz
    SetSkiplists;

  if added then
  begin
    Result:= True;

    completecache:= False;
    allcdshere:= False;
    multicdcache:= False;

    if skiplist <> nil then
    begin
      RegenerateSkiplist;
      Sort;
    end;

  end;

end;

function TDirList.RegenerateSkiplist: Boolean;
var ldepth: Integer;
    i: Integer;
    ld: TDirListEntry;
    s: string;
    sf: TSkipListFilter;
begin
  Result:= False;
  if skiplist = nil then exit;

  ldepth:= Depth();
//  if ldepth > dirdepth then// ez nem fordulhat elo elmeletileg, de inkabb kezeljuk

  for i:= 0 to entries.Count-1 do
  begin
    ld:= TDirListEntry(entries[i]);
    if not ld.skiplisted then
    begin
      if not ld.directory then
      begin
        if ((ld.filename[1] <> '.') and (ld.filesize <> 0)) then
        begin
          s:= ld.dirlist.Dirname;
          sf:= skiplist.AllowedFile(s, ld.filename);
          if sf = nil then
            ld.skiplisted:= True
          else
            Result:= True;
        end
        else
          ld.skiplisted:= True;
      end else
      begin
        if ldepth < skiplist.dirdepth then
        begin
          // vegig kell menni az alloweddirs-en es megnezni hogy
          s:= ld.dirlist.Dirname;
          sf:= skiplist.AllowedDir(s, ld.filename);
          if sf = nil then
            ld.skiplisted:= True
          else
            Result:= True;
        end else
          ld.skiplisted:= True;
      end;
    end;
  end;

end;

function DirListSorter(Item1, Item2: Pointer): Integer;
var i1, i2: TDirlistEntry;
    c1, c2: Integer;
begin
// compare: -1 bekenhagyas, jo a sorrend
// compare:  1 csere
  Result:= 0;
  i1:= TDirlistEntry(Item1);
  i2:= TDirlistEntry(Item2);
  if ((i1.skiplisted) and (i2.skiplisted)) then exit; //ezeket kurvara nem fontos mozganti

  if ((i1.directory) and (i2.directory)) then
  begin
    if (i1.dirlist.sf_d <> nil) then
    begin
      c1:= i1.dirlist.sf_d.MatchFile(i1.filename);
      c2:= i2.dirlist.sf_d.MatchFile(i2.filename);

//    if ((c1 = -1) or (c2 = -1)) then exit; // ez elvileg nem fordulhat elo, mert akkor skiplisted kene legyen

      if (c1 > c2) then
        Result:= 1
      else
      if (c1 < c2) then
        Result:= -1;
    end else
      Result:= CompareStr(i1.filename, i2.filename);
  end
  else
  if ((not i1.directory) and (not i2.directory)) then
  begin
    c1:= i1.dirlist.sf_f.MatchFile(i1.filename);
    c2:= i2.dirlist.sf_f.MatchFile(i2.filename);

//    if ((c1 = -1) or (c2 = -1)) then exit; // ez elvileg nem fordulhat elo, mert akkor skiplisted kene legyen

    if (c1 > c2) then
      Result:= 1
    else
    if (c1 < c2) then
      Result:= -1
    else
    begin
      // mindketto ugyanolyan kategoriaju fajl, itt fajlmeret alapjan rendezunk.
      if i1.filesize > i2.filesize then
        Result:= -1
      else
      if i1.filesize < i2.filesize then
        Result:= 1;
    end;
  end
  else
  if (i1.directory) then //i2 = file, elorebb kell lennie
    Result:= -1
  else
    Result:= 1; //i1 = file, jo a sorrend
end;

procedure TDirList.Sort();
begin
  sort_lock.Enter;
  entries.Sort(@DirListSorter);
  sort_lock.Leave;
end;


function TDirList.CompleteByTag: Boolean;
var i, j: Integer;
    de: TDirlistEntry;
begin
  Result:= False;
  for i:= 0 to entries.Count -1 do
  begin
    de:= TDirlistEntry(entries[i]);

    if ((de.directory) or (de.filesize = 0)) then
    begin
      j:= TagComplete(de.filenamelc);
      if (j = 1) then
      begin                     
        Result:= True;
        exit;
      end;

      // if j <> 0 then exit;
    end;
  end;
end;

procedure TDirList.Usefulfiles(var files, size: Integer);
var i: Integer;
    de: TDirlistEntry;
    afile, asize: Integer;
begin
  files:= 0;
  size:= 0;
  for i:= 0 to entries.Count-1 do
  begin
    de:= TDirlistEntry(entries[i]);
    if de.Useful then
    begin
      inc(files);
      inc(size, de.filesize);
    end;
    if ((de.directory) and (de.subdirlist <> nil)) then
    begin
      de.subdirlist.Usefulfiles(afile, asize);
      inc(files, afile);
      inc(size, asize);
    end;
  end;
end;

function TDirList.Find(filename: string): TDirListEntry;
var i: Integer;
    de: TDirListEntry;
begin
  Result:= nil;
  for i:= 0 to entries.Count -1 do
  begin
    de:= TDirListEntry(entries[i]);
    if de.filename = filename then
    begin
      Result:= de;
      exit;
    end;
  end;
end;

procedure TDirList.SetLastChanged(value: TDateTime);
begin
  fLastChanged:= Max(value, fLastChanged);
  if parent <> nil then
    parent.dirlist.LastChanged:= fLastChanged;
end;

function TDirList.FindDirlist(dirname: string): TDirList;
var p: Integer;
    firstdir, lastdir: string;
    d: TDirlistEntry;
begin
  Result:= nil;

  if dirname = '' then
  begin
    Result:= self;
    exit;
  end;

  p:= Pos('/', dirname);
  if 0 < p then
  begin
    firstdir:= Copy(dirname, 1, p-1);
    lastdir:= Copy(dirname, p+1, 1000);
  end else
  begin
    firstdir:= dirname;
    lastdir:= '';
  end;

  d:= Find(firstdir);
  if d = nil then exit;

  if not d.directory then exit;
  if d.subdirlist = nil then
    d.subdirlist:= TDirlist.Create(d, skiplist);

  Result:= d.subdirlist.FindDirlist(lastdir);
end;

function TDirList.Done: Integer;
var de: TDirlistEntry;
    i: Integer;
begin
  Result:= 0;
  for i:= 0 to entries.Count -1 do
  begin
    de:= TDirlistEntry(entries[i]);
    if de.skiplisted then Continue;
    
    if de.done then inc(Result);
    if ((de.directory) and (de.subdirlist <> nil)) then
      inc(Result, de.subdirlist.Done);
  end ;
end;
function TDirList.RacedByMe: Integer;
var de: TDirlistEntry;
    i: Integer;
begin
  Result:= 0;
  for i:= 0 to entries.Count -1 do
  begin
    de:= TDirlistEntry(entries[i]);
    if de.racedbyme then inc(Result);
    if ((de.directory) and (de.subdirlist <> nil)) then
      inc(Result, de.subdirlist.RacedbyMe);
  end ;
end;

function TDirList.hasnfo: boolean;
var i: Integer;
    de: TDirlistEntry;
begin
  Result:= False;
  for i:= 0 to entries.Count-1 do
  begin
    de:= TDirlistEntry(entries[i]);
    if de.Extension = '.nfo' then
    begin
      Result:= True;
      exit;
    end;
  end;
end;

procedure TDirList.CleanToprocess;
var i: Integer;
begin
  debugunit.Debug(dpSpam, section, 'CleanToProcess');
  for i:= 0 to entries.Count -1 do
    TDirlistEntry(entries[i]).toprocess:= True;
end;

procedure TDirList.Clear;
begin
  sfv_fugges:= '';
  mkd_fugges:= '';
  multicdcache:= False;
  allcdshere:= False;
  completecache:= False;
  fLastChanged:= 0;
  biggestcd:= 0;
  lastDirlistAdded:= 0;
  giveup:= False;
  entries.Clear;
end;

{ TDirListEntry }

constructor TDirListEntry.Create(filename: string; dirlist: TDirList);
begin
  self.pr:= '';
  self.sfvfirsteventvoltmar:= False;
  self.dirlist:= dirlist;
  self.filename:= filename;
  self.toprocess:= True;
  self.done:= False;
  self.skiplisted:= False;
  subdirlist:= nil;

  filenamelc:= LowerCase(filename);
  cdno:= 0;
end;

procedure TDirListEntry.CalcCDNumber;
const multicddirprefix : array[1..4] of string = ('cd', 'dvd', 'disc','disk');
var s: string;
    i: Integer;
begin

  s:= Csere(filenamelc, ' ', '');
  s:= Csere(s, '_', '');
  s:= Csere(s, '-', '');

  for i:= 1 to 4 do
  begin
    if (1 = Pos(multicddirprefix[i], s)) then
    begin
      cdno:= StrToIntDef(Copy(s, Length(multicddirprefix[i])+1, 1000), 0);
      exit;
    end;
  end;
end;

constructor TDirListEntry.Create(de: TDirlistEntry; dirlist: TDirList);
begin
  self.pr:= '';
  self.sfvfirsteventvoltmar:= False;
  self.filename:= de.filename;
  self.filesize:= de.filesize;
  self.directory:= de.directory;
  self.done:= False;
  self.skiplisted:= de.skiplisted;
  self.toprocess:= False;
  self.dirlist:= dirlist;
  self.subdirlist:= nil;
  self.timestamp:= de.timestamp;
  filenamelc:= LowerCase(filename);
  CalcCDnumber;
end;

procedure TDirListEntry.Debug;
begin
  if (subdirlist = nil) then
    debugunit.Debug(dpSpam, section, '%10s %u %-50s %-10u %u %u %u %u', [dirlist.Dirname, Integer(directory), Copy(filename,1,50), filesize, Integer(skiplisted), Integer(racedbyme), Integer(done), Integer(toprocess)])
  else
    subdirlist.Debug;
end;

destructor TDirListEntry.Destroy;
begin
  if subdirlist <> nil then
  begin
    subdirlist.Free;
    subdirlist:= nil;
  end;
  inherited;
end;


procedure DirlistInit;
begin
  sort_lock:= TCriticalSection.Create;
end;
procedure DirlistUninit;
begin
  sort_lock.Free;
end;

function TDirListEntry.Extension: string;
begin
  Result:= ExtractFileExt(filenamelc);
end;

function TDirListEntry.Useful: Boolean;
begin
  Result:= False;
  if filesize = 0 then exit;
  if directory then exit;
  if Extension = '.nfo' then exit;
  if Extension = '.jpg' then exit;
  if Extension = '.jpeg' then exit;

  Result:= True;
end;

procedure TDirListEntry.SetDirectory(value: Boolean);
begin
  fDirectory:= value;
  if directory then CalcCDNumber;
end;

initialization
  DirlistInit;
finalization
  DirlistUninit;
end.
