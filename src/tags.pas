unit tags;

interface

function TagComplete(filename: string): Integer;

implementation

uses Classes, SysUtils, mystrings, configunit;

const section = 'tags';

var tags_complete: TStringList = nil;
    tags_incomplete: TStringList= nil;


// 1 ha complete
// -1 ha incomplete
// 0 egyebkent
function TagComplete(filename: string): Integer;
var i: Integer;
    s: string;
begin
  Result:= 0;
  i:= Pos('% complete', filename);
  if 0 <> i then
  begin
    s:= Copy(filename, i - 3, 3);
    i:= StrToIntDef(Trim(s), -1);
    if i > 0 then
    begin
      if i = 100 then
      begin
        Result:= 1;
        exit;
      end else
      begin
        Result:= -1;
        exit;
      end;
    end;
  end;

  for i:= 0 to tags_incomplete.Count -1 do
    if (0 <> Pos(tags_incomplete[i], filename)) then
    begin
      Result:= -1;
      exit;
    end;

  for i:= 0 to tags_complete.Count -1 do
    if (0 <> Pos(tags_complete[i], filename)) then
    begin
      Result:= 1;
      exit;
    end;
end;

procedure TagsInit;
var i: Integer;
    s, ss: string;
begin
  tags_complete:= TStringList.Create;
  s:= LowerCase(config.ReadString(section, 'complete', '')); // milyen elbaszott egy kibaszott szarfoshugygeci ez
  for i:= 1 to 1000 do
  begin
    ss:= SubString(s, ',', i);
    if Trim(ss) = '' then break;
    tags_complete.Add(ss);
  end;

  tags_incomplete:= TStringList.Create;
  s:= LowerCase(config.ReadString(section, 'incomplete', '')); // milyen elbaszott egy kibaszott szarfoshugygeci ez
  for i:= 1 to 1000 do
  begin
    ss:= SubString(s, ',', i);
    if Trim(ss) = '' then break;
    tags_incomplete.Add(ss);
  end;

end;

procedure TagsUninit;
begin
  if tags_complete <> nil then
  begin
    tags_complete.Free;
    tags_complete:= nil;
  end;

  if tags_incomplete <> nil then
  begin
    tags_incomplete.Free;
    tags_incomplete:= nil;
  end;
end;

initialization
  TagsInit;
finalization
  TagsUninit;
end.
