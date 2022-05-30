unit debugunit;

interface

type
  TDebugPriority = (dpError, dpMessage, dpSpam);

procedure Debug(priority: TDebugPriority; section, msg: string); overload;
procedure Debug(priority: TDebugPriority; const section, FormatStr: string; const Args: array of const); overload;

var
  debug_verbose: Boolean;

implementation

uses configunit, SysUtils, SyncObjs
{$IFDEF MSWINDOWS}
  , Windows
{$ELSE}
  , Libc
{$ENDIF}
;

const section = 'debug';

var f: TextFile;
    flushlines: Integer;
    lines: Integer = 0;
    verbosity: TDebugPriority = dpError;
    categorystr: string;
    debug_lock: TCriticalSection;


function MyGetCurrentProcessId(): LongWord;
begin
{$IFDEF MSWINDOWS}
  Result:= GetCurrentProcessId;
{$ELSE}
  Result:= LongWord(pthread_self());
{$ENDIF}
end;

procedure Debug(priority: TDebugPriority; section, msg: string); overload;
var nowstr: string;
begin
  if (priority <> dpError) and
     (verbosity < priority) and
     (categorystr <> ',all,') and
     (0 = Pos(','+section+',', categorystr)) then exit;
   
  DateTimeToString(nowstr, 'mm-dd hh:nn:ss.zzz', Now());
  debug_lock.Enter;
  WriteLn(f, Format('%s (%s) [%-12s] %s', [nowstr, IntToHex(MyGetCurrentProcessId(), 2), section, msg]));
  inc(lines);
  if lines >= flushlines then
  begin
    Flush(f);
    lines:= 0;
  end;
  debug_lock.Leave;  
end;

procedure Debug(priority: TDebugPriority; const section, FormatStr: string; const Args: array of const); overload;
begin
  Debug(priority, section, Format(FormatStr, Args));
end;


procedure DebugInit;
var logfilename: string;
begin
  debug_lock:= TCriticalSection.Create;

  logfilename:= config.ReadString(section, 'debugfile', ExtractFilePath(ParamStr(0))+'slftp.log');
  flushlines:= config.ReadInteger(section, 'flushlines', 16);
  categorystr:= ','+LowerCase(config.ReadString(section, 'categories', 'verbose'))+',';
  verbosity:= TDebugPriority(config.ReadInteger(section, 'verbosity', 0));

  debug_verbose:= verbosity = dpSpam;

  Assignfile(f, logfilename);
  if FileExists(logfilename) then
    Append(f)
  else
    Rewrite(f);
end;

procedure DebugUninit;
begin
  Closefile(f);
  debug_lock.Free;
end;

initialization
  DebugInit;
finalization
  DebugUnInit;
end.
