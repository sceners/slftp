program cryptconf;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  helper,
  Classes,
  encinifile;

procedure Usage;
begin
  WriteLn('Usage: cryptconf -d|-e inputfile outputfile');
  exit;
end;

procedure DecryptIni(inputfile, outputfile: string);
var x: TEncStringlist;
    y: TStringList;
    password: string;
begin
  password:= MyGetPass('Password: ');
  x:= TEncStringlist.Create(password);
  y:= TStringList.Create;
  try
    x.LoadFromFile(inputfile);
    y.Assign(x);
    y.SaveToFile(outputfile);
  finally
    x.Free;
    y.Free;
  end;
end;
procedure EncryptIni(inputfile, outputfile: string);
var x: TEncStringList;
    y: TStringList;
    password: string;
begin
  password:= MyGetPass('Password: ');
  if password <> MyGetPass('Again: ') then
  begin
    Writeln('Passwords dont match');
    exit;
  end;
  x:= TEncStringList.Create(password);
  y:= TStringList.Create;
  try
    y.LoadFromFile(inputfile);
    x.Assign(y);
    x.SaveToFile(outputfile);
  finally
    x.Free;
    y.Free;
  end;
end;

begin
  if ParamCount <> 3 then
    Usage;

  if(ParamStr(1) = '-d') then
    DecryptIni(ParamStr(2), ParamStr(3))
  else
  if(ParamStr(1) = '-e') then
    EncryptIni(ParamStr(2), ParamStr(3))
  else
    Usage()
end.
