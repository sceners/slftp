program dirlisttest;

{$APPTYPE CONSOLE}

uses
  Dirlist, skiplists, Classes, SysUtils;

function GetFileContents(fn: string):string;
var x: TStringList;
begin
  x:= TStringList.Create;
  x.LoadFromFile(fn);
  Result:= x.Text;
  x.Free;
end;

procedure TestDirlist;
var d: TDirList;
begin
  d:= TDirList.Create(nil, FindSkipList('MP3'), GetFileContents('dirlist.test'));
  d.Debug;
  d.Free;
end;

begin
  TestDirlist;
end.
