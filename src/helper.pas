unit helper;

interface

function MyGetPass(prompt: string): string;
function MyGetUsername: string;
procedure mySleep(sec: Integer; var kilepes: Boolean);

implementation

uses SysUtils,
{$IFDEF MSWINDOWS}
  Windows;
{$ELSE}
  Libc;
{$ENDIF}

{$IFDEF MSWINDOWS}
function MyGetPass(prompt: string) : string;
var
  OldConsInMode, NewConsInMode: DWORD;
  hConsIn: THANDLE;
begin
  // Turn off console mode echo, since we don't want clear-screen passwords
  System.Reset(Input); //{GetStdHandle(STD_INPUT_HANDLE)}
  hConsIn:= TTextRec(Input).Handle;
  if hConsIn = INVALID_HANDLE_VALUE then
  begin
    WriteLn('can''t get handle of STDIN');
    halt;
  end;
  if not GetConsoleMode(hConsIn, OldConsInMode) then
  begin
    WriteLn('can''t get current Console Mode');
    halt(1);
  end;
  NewConsInMode:= OldConsInMode and (not ENABLE_ECHO_INPUT);
  if not SetConsoleMode(hConsIn, NewConsInMode) then
  begin
    WriteLn ('unable to turn off Echo');
    halt(1);
  end;

  // Ask for the password
  write (prompt);
  readln (Result);
  // When echo is off and NewUser hits <RETURN>, CR-LF is not echoed, so do it for him
  writeln;
  if not SetConsoleMode(hConsIn, OldConsInMode) then
  begin
    WriteLn('unable to reset previous console mode');
    halt(1);
  end;
//CloseHandle (hConsIn); //commented because otherwhise it'll except

end;
{$ELSE}
function MyGetPass(prompt: string): string;
begin
  Result:= StrPas(GetPass(PChar(prompt)));
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function MyGetUsername: string;
var buf: array[1..256] of char;
    n: Cardinal;
begin
  Result:= '';

  if (False <> GetUserName(@buf, n)) then
    Result:= Copy(buf, 1, n);
end;

{$ELSE}
function MyGetUsername: string;
var pwentry: PPasswordRecord;
begin
  Result:= '';

  // pick up the current user's username
  pwentry:= getpwuid(getuid());
  if (pwentry = nil) then exit;

  Result:= StrPas(pwentry^.pw_name);
end;
{$ENDIF}

procedure mySleep(sec: Integer; var kilepes: Boolean);
var i: integer;
begin
  for i:= 1 to sec*2 do
  begin
    Sleep(500);
    if kilepes then Exit;
  end;
end;


end.
