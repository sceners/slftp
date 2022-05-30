unit taskdel;

interface

uses tasksunit;

type
    TDelReleaseTask = class(TTask)
       dir: string;
       constructor Create(site: string; dir: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
  private
    function RemoveDir(slot: Pointer; dir: string): Boolean;
    end;

implementation

uses sitesunit, SysUtils, mystrings, dirlist, DebugUnit;

const section = 'del';

{ TLoginTask }

constructor TDelReleaseTask.Create(site: string; dir: string);
begin
  self.dir:= dir;
  inherited Create(site, tDel);
end;

function TDelReleaseTask.RemoveDir(slot: Pointer; dir: string): Boolean;
var s: TSiteSlot;
    d: TDirList;
    i: Integer;
    de: TDirListEntry;
begin
  Result:= True;
  s:= slot;
  if not s.Dirlist(dir) then exit;
  d:= TDirList.Create(nil, nil, s.lastResponse);
  try
    for i:= 0 to d.entries.Count -1 do
    begin
      de:= TDirListEntry(d.entries[i]);
      if not de.directory then
      begin
        if not s.RemoveFile(dir, de.filename) then
        begin
          Result:= False;
          Break;
        end;
      end;
    end;
    if Result then
    begin
      for i:= 0 to d.entries.Count -1 do
      begin
        de:= TDirListEntry(d.entries[i]);
        if de.directory then
        begin
          if not RemoveDir(slot, dir+de.filename) then
          begin
            Result:= False;
            Break;
          end;
        end;
      end;
    end;
    if Result then
    begin
      // es vegul eltavolitjuk a main direktorit
      Result:= s.RemoveDir(dir);
    end;
  finally
    d.Free;
  end;
end;

function TDelReleaseTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
begin
  Result:= False;
  s:= slot;
  Debug(dpMessage, section, Name);

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

  dir:= MyIncludeTrailingSlash(dir);
  if (not RemoveDir(s, dir)) then goto ujra;

  Result:= True;
  ready:= True;
end;

function TDelReleaseTask.Name: string;
begin
  Result:= 'DELETE '+site1+' '+dir;
end;

end.

