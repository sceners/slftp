program ruletest;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  mystrings;

var listA: TStringList;
    s, param: string;
    i: Integer;
begin
  { TODO -oUser -cConsole Main : Insert code here }
  lista:= TStringList.Create;
  lista.CaseSensitive:= False;
  param:= 'CD, CDR, CDS, DVD, DVDA';
  for i:= 1 to 1000 do
  begin
    s:= Trim(SubString(param, ',',i));
    if s = '' then Break;
    lista.Add(s);
  end;
 Writeln( lista.IndexOf('CD'));
 lista.Free;
end.
