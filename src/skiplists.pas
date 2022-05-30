unit skiplists;

interface

uses Contnrs;

type
  TSkipListFilter = class
  private
    dirmask: TObjectList;
    filemask: TObjectList;
    function Dirmatches(dirname: string): Boolean;
  public
    function MatchFile(filename: string): Integer;
    function Match(dirname, filename: string): Boolean;
    constructor Create(dms, fms: string);
    destructor Destroy; override;
  end;

  TSkipList = class
  private
    sectionname: string;
    allowedfiles: TObjectList;
    alloweddirs: TObjectList;
    function FindDirFilterB(list: TObjectList; dirname: string): TSkiplistFilter;
  public
    dirdepth: Integer;
    constructor Create(sectionname: string);
    destructor Destroy; override;

    function FindFileFilter(dirname: string): TSkiplistFilter;
    function FindDirFilter(dirname: string): TSkiplistFilter;
    function AllowedFile(dirname, filename: string): TSkipListFilter;
    function AllowedDir(dirname, filename: string): TSkipListFilter;    
  end;

function FindSkipList(section: string): TSkipList;

implementation

uses Masks, mystrings, SysUtils;


var skiplist: TObjectList;


procedure SkiplistsInit;
var f: TextFile;
    s, s1, s2: string;
    akt: TSkipList;
    addhere: TObjectList;
begin
  skiplist:= TObjectList.Create;
  addhere:= nil;
  akt:= nil;
  AssignFile(f, ExtractFilePath(ParamStr(0))+'slftp.skip');
  Reset(f);

  while not eof(f) do
  begin
    readln(f,s);
    s:= Trim(s);
    if ((s = '') or (s[1] = '#')) then Continue;

    if Copy(s, 2, 8) = 'skiplist' then
    begin
      akt:= TSkiplist.Create(Copy(s, 11, Length(s)-11));
      skiplist.Add(akt);
    end
    else
    if akt <> nil then
    begin
      s1:= SubString(s, '=', 1);
      s2:= SubString(s, '=', 2);
      if s1 = 'dirdepth' then
        akt.dirdepth:= StrToIntDef(s2, 1)
      else
      if ((s1 = 'allowedfiles') or (s1 = 'alloweddirs')) then
      begin
        if (s1 ='allowedfiles') then
          addhere:= akt.allowedfiles
        else
        if (s1 ='alloweddirs') then
          addhere:= akt.alloweddirs;
        s1:= SubString(s2, ':', 1);
        s2:= SubString(s2, ':', 2);

        addhere.Add(TSkipListFilter.Create(s1,s2));
      end;
    end;
  end;

  CloseFile(f);

  if skiplist.Count = 0 then raise Exception.Create('slFtp cant run without skiplist initialized');
end;

procedure SkiplistsUnInit;
begin
  skiplist.Free;
end;

{ TSkipList }

function TSkipList.AllowedDir(dirname, filename: string): TSkipListFilter;
var j: Integer;
    sf: TSkipListFilter;
begin
  Result:= nil;
  for j:= 0 to alloweddirs.Count -1 do
  begin
    sf:= TSkipListFilter(alloweddirs[j]);
    if sf.Match(dirname, filename) then
    begin
      Result:= sf;
      exit;
    end;
  end;
end;

function TSkipList.AllowedFile(dirname, filename: string): TSkipListFilter;
var j: Integer;
    sf: TSkipListFilter;
begin
  Result:= nil;
  for j:= 0 to allowedfiles.Count -1 do
  begin
    sf:= TSkipListFilter(allowedfiles[j]);
    if sf.Match(dirname, filename) then
    begin
      Result:= sf;
      exit;
    end;
  end;
end;

constructor TSkipList.Create(sectionname: string);
begin
  allowedfiles:= TObjectList.Create;
  alloweddirs:= TObjectList.Create;
  self.sectionname:= UpperCase(sectionname);
  dirdepth:= 1;
end;

destructor TSkipList.Destroy;
begin
  allowedfiles.Free;
  alloweddirs.Free;
  
  inherited;
end;


function TSkipList.FindDirFilterB(list: TObjectList; dirname: string): TSkiplistFilter;
var i: Integer;
    sf: TSkiplistFilter;
begin
  Result:= nil;
  for i:= 0 to list.Count-1 do
  begin
    sf:= TSkiplistFilter(list[i]);
    if sf.DirMatches(dirname) then
    begin
      Result:= sf;
      exit;
    end;
  end;
end;
function TSkipList.FindDirFilter(dirname: string): TSkiplistFilter;
begin
  Result:= FindDirFilterB(alloweddirs, dirname);
end;

function TSkipList.FindFileFilter(dirname: string): TSkiplistFilter;
begin
  Result:= FindDirFilterB(allowedfiles, dirname);
end;

{ TSkipListFilter }

constructor TSkipListFilter.Create(dms, fms: string);
var fm: string;
    dc, fc: Integer;
    i, j: Integer;
begin
  dirmask:= TObjectList.Create;
  filemask:= TObjectList.Create;

  dc:= Count(',', dms);
  fc:= Count(',', fms);

  for i:= 1 to dc + 1 do
    dirmask.Add(TMask.Create( SubString(dms, ',', i) ));

  for j:= 1 to fc + 1 do
  begin
    fm:= SubString(fms, ',', j);
    if fm = '_RAR_' then
    begin
      filemask.Add(TMask.Create('*.rar'));
      filemask.Add(TMask.Create('*.r[0-9][0-9]'));
    end
    else
      filemask.Add(TMask.Create(fm));
  end;
end;

destructor TSkipListFilter.Destroy;
begin
  filemask.Free;
  dirmask.Free;
  inherited;
end;

function TSkiplistFilter.Dirmatches(dirname: string): Boolean;
var i: Integer;
begin
  Result:= False;
  for i:= 0 to dirmask.Count -1 do
    if TMask(dirmask[i]).Matches(dirname) then
    begin
      Result:= True;
      exit;
    end;
end;

function TSkipListFilter.Match(dirname, filename: string): Boolean;
var i: Integer;
begin
  Result:= False;

  if Dirmatches(dirname) then
    for i:= 0 to filemask.Count -1 do
      if TMask(filemask[i]).Matches(filename) then
      begin
        Result:= True;
        exit;
      end;
end;

function FindSkipList(section: string): TSkipList;
var i: Integer;
    s: TSkipList;
begin
  Result:= skiplist[0] as TSkipList;
  for i:= 1 to skiplist.Count -1 do
  begin
    s:= skiplist[i] as TSkipList;
    if s.sectionname = section then
    begin
      Result:= s;
      exit;
    end;
  end;
end;

function TSkipListFilter.MatchFile(filename: string): Integer;
var i: Integer;
begin
  Result:= -1;
  for i:= 0 to filemask.Count -1 do
    if TMask(filemask[i]).Matches(filename) then
    begin
      Result:= i;
      exit;
    end;
end;

initialization
  SkiplistsInit;
finalization
  SkiplistsUninit;
end.
