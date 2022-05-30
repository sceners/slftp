unit configunit;

interface

uses IniFiles, encinifile, md5;

procedure ReadPass;

var config: TCustomIniFile;
    config_connect_timeout: Integer;
    config_io_timeout: Integer;
    passphrase: TMD5Digest;

implementation

uses SysUtils, helper;

const timeout = 'timeout';


procedure ReadPass;
var pw: string;
begin
  pw:= MyGetPass('Password: ');
  if pw = '' then halt;
  passphrase:= MD5String(pw);
end;


procedure ConfigInit;
begin
  ReadPass;
  try
    if FileExists(ExtractFilePath(ParamStr(0))+'slftp.cini') then
      config:= TEncIniFile.Create(ExtractFilePath(ParamStr(0))+'slftp.cini', passphrase)
    else
      config:= TIniFile.Create(ExtractFilePath(ParamStr(0))+'slftp.ini');

    config_connect_timeout:= config.ReadInteger(timeout, 'connect', 20);
    config_io_timeout:= config.ReadInteger(timeout, 'io', 20);
  except
    WriteLn('Negative on that houston');
    halt;
  end;
end;
procedure ConfigUninit;
begin
  config.Free;
end;

initialization
  ConfigInit;
finalization
  ConfigUninit;
end.
