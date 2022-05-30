unit console;

interface

procedure ConsoleStart;
procedure ConsoleStop;
procedure Console_SiteStat(allsites, upsites, downsites, unknown: Cardinal);
procedure Console_QueueStat(queuedb: Cardinal);
procedure Console_Slot_Add(s: Pointer; add: Boolean; name, FormatStr: string; const Args: array of const);
procedure Console_Slot_Close(s: Pointer);

implementation

uses debugunit, SyncObjs, versioninfo, SysUtils, mainthread
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF}
;

const MAX_SLOT_STATS = 50;
      section = 'console';

var lock_console: TCriticalSection = nil;
    slot_stats: array[0..MAX_SLOT_STATS-1] of Pointer;
    lastqueuedb: Cardinal = 0;
{$IFDEF MSWINDOWS}
    hStdout: THandle;
{$ENDIF}

procedure gotoxy(x, y: SmallInt; msg: string); overload;
{$IFDEF MSWINDOWS}
var
    position: TCoord;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
    position.X:= x;
    position.Y:= y;    
{$ENDIF}

{$IFDEF MSWINDOWS}
  SetConsoleCursorPosition( hStdout, position ) ;
	WriteLn(msg);
{$ELSE}
	WriteLn(Format(chr($1b)+'[%dd'+chr($1b)+'[%dG%s', [y, x, msg]));
{$ENDIF}
end;

procedure gotoxy(x, y: SmallInt; FormatStr: string; const Args: array of const); overload;
begin
  GotoXy(x,y, Format(FormatStr, Args));
end;

procedure ConsoleStart;
{$IFDEF LINUX}
var i: Integer;
{$ENDIF}
begin
  lock_console.Enter;
{$IFDEF LINUX}
  for i:= 0 to 99 do // A bunch of new lines for now. It's blank, hey!
    Write(#10);
{$ENDIF}
  gotoxy(0,0, '%s started', [Get_VersionString(ParamStr(0))]);
  lock_console.Leave;

end;

procedure ConsoleStop;
begin
  lock_console.Enter;
	gotoxy(0,0, 'slFtp exiting          ');
  lock_console.Leave;
end;

{$IFDEF MSWINDOWS}
function ConProc(CtrlType : DWord) : Bool; stdcall;
begin
  kilepes:= True;
  if not running then halt;
  Result:= True;
end;
{$ENDIF}

procedure ConsoleInit;
var i: Integer;
begin
  lock_console:= TCriticalSection.Create();

  for i := 0 to MAX_SLOT_STATS -1 do
	  slot_stats[i]:= nil;

{$IFDEF MSWINDOWS}
	hStdout:= GetStdHandle(STD_OUTPUT_HANDLE) ;
  SetConsoleCtrlHandler (@ConProc, True);
{$ENDIF}
end;

procedure ConsoleUninit;
begin
  if lock_console <> nil then
  begin
    lock_console.Free;
    lock_console:= nil;
  end;
end;

procedure Console_SiteStat(allsites, upsites, downsites, unknown: Cardinal);
begin
  lock_console.Enter;
	gotoxy(30,0, 'SITES: %u/%u/%u/%-10u', [allsites, upsites, downsites, unknown]);
  lock_console.Leave;
end;
procedure Console_QueueStat(queuedb: Cardinal);
begin
  lock_console.Enter;
	if(lastqueuedb <> queuedb) then
  begin
		lastqueuedb := queuedb;
    gotoxy(60,0, 'QUEUE: %-10u', [queuedb]);
	end;
  lock_console.Leave;
end;

procedure Console_Slot_Add(s: Pointer; add: Boolean; name, FormatStr: string; const Args: array of const);
var i, freeslot, slot: Integer;
    msg: string;
begin
	if(s=nil) then exit;

  freeslot:= -1;
  slot:= -1;

  lock_console.Enter;
	for i:= 0 to MAX_SLOT_STATS -1 do
	begin
		if(slot_stats[i]= s) then
		begin
			slot := i;
			break;
		end;
		if ((slot_stats[i]= nil)and(freeslot = -1)) then
			freeslot := i;
	end;

	if((slot = -1)and(freeslot=-1)) then
	begin
    lock_console.Leave;
		exit; // beteltunk.
	end;
	if((add = False)and(slot=-1)) then // nincs addolas (site mar closeolva van)
	begin
    lock_console.Leave;
		exit;
	end;

	if(slot = -1) then
  begin
		slot := freeslot;
		slot_stats[slot]:=s;
	end;

  msg:= Copy(Format(FormatStr, Args), 1, 64);
	gotoxy(0, slot+1, '%15s %-64s', [name, msg]);

  lock_console.Leave;
end;

procedure Console_Slot_Close(s: Pointer);
var
	i: Integer;
	slot: Integer;
begin
  slot:= -1;

	if(s=nil) then exit;

  lock_console.Enter;
	for i:= 0 to MAX_SLOT_STATS-1 do
	begin
		if (slot_stats[i]=s) then
		begin
			slot := i;
			break;
		end;
	end;

	if(slot = -1) then
	begin
    lock_console.Leave;
		exit; // nem talaltuk meg
	end;

	slot_stats[slot]:= nil;

	gotoxy(0, slot+1, '%-80s', [' ']);
  lock_console.Leave;
end;


initialization
  ConsoleInit;
finalization
  ConsoleUninit;
end.
